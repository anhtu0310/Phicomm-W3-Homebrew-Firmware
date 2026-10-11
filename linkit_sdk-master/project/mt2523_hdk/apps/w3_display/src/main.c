/*
 * Phicomm W3 custom firmware: display + touch bring-up demo.
 * Shows colour bars, the touch controller state (raw bytes, position marker)
 * and an uptime counter on the JDI MIP LCD.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#include "FreeRTOS.h"
#include "task.h"
#include "hal.h"
#include "hal_charger.h"
#include "syslog.h"
#include "sys_init.h"
#include "jdi_lcd.h"
#include "cy8c_touch.h"
#include "touch_slider.h"
#include "bhi160.h"
#include "w3_gnss.h"
#include "pah8011.h"
#include "sensor_i2c.h"
#include "w3_time.h"
#include "hal_pmu_wrap_interface.h"
#include "hal_mt2523_pmu_platform.h"
#include "usb_log.h"
#include "hal_pmu_internal.h"
#include "vibrator.h"
#include "w3_ble.h"

log_create_module(w3, PRINT_LEVEL_INFO);

/* The W3 has no button, so plugging in USB is the "enter download mode" gesture:
 * on a cable insert edge we reboot, and with USB present at boot the Boot ROM
 * opens its download window for tools/mt2523_flash.py. Only a real unplug
 * counts: VBUS must have been gone for USB_UNPLUG_TICKS loop ticks (50 ms
 * each), because short VBUS glitches happen and used to reboot the watch. */
#define USB_UNPLUG_TICKS 40
static bool usb_plugged(void)
{
    bool present = false;

    hal_charger_get_charger_detect_status(&present);
    return present;
}

static void reboot_to_download_window(void)
{
    jdi_lcd_fill_rect(0, 86, JDI_WIDTH, 58, JDI_WHITE);
    jdi_lcd_draw_text(0, 96, "REBOOTING", JDI_RED, JDI_WHITE, 1);
    jdi_lcd_draw_text(0, 108, "USB DL", JDI_RED, JDI_WHITE, 2);
    jdi_lcd_flush(false);
    LOG_I(w3, "USB plugged in: rebooting\r\n");
    vTaskDelay(50 / portTICK_RATE_MS);
    hal_wdt_software_reset();
}

/* Reset diagnostics, captured at the very start of main(). */
#define RGU_WDT_STA       (*(volatile uint32_t *)0xA205000C)
#define DIAG_RTC_OFFSET   10          /* RTC spare bytes 10..11: magic, boot count */
#define DIAG_MAGIC        0x5A

static uint32_t s_wdt_sta;
static uint8_t s_boot_count;
static uint8_t s_pmu_reason[5];       /* PMU regs 0x2D..0x31 (stock AT+RESETCAUSE) */
static uint8_t s_boot_pwrhold;        /* RG_PWRHOLD as found at boot */
static uint8_t s_boot_shdncfg1;       /* PMU 0x4D (power-key long press config) at boot */

/* After a charger-insertion power-on the PMIC does a "normal off" unless
 * software holds power (POFFSTS showed NORMOFF ~28 s after boot). The watch has
 * no power key, so also disable the long-press shutdown. */
static void pmu_hold_power(void)
{
    s_boot_pwrhold = pmu_get_register_value(PMU_RG_PWRHOLD_ADDR, PMU_RG_PWRHOLD_MASK, PMU_RG_PWRHOLD_SHIFT);
    s_boot_shdncfg1 = pmu_get_register_value(PMU_SHDNCFG1, 0xFF, 0);
    pmu_set_vrc_key_mt6385(PMIC_UNLOCK_KEY);
    pmu_set_register_value(PMU_RG_PWRHOLD_ADDR, PMU_RG_PWRHOLD_MASK, PMU_RG_PWRHOLD_SHIFT, 1);
    pmu_set_register_value(PMU_RG_PKEY_LPEN_ADDR, PMU_RG_PKEY_LPEN_MASK, PMU_RG_PKEY_LPEN_SHIFT, 0);
    pmu_set_vrc_key_mt6385(PMIC_LOCK_KEY);
}

static void capture_reset_diag(void)
{
    char rec[2] = {0, 0};
    int i;

    hal_rtc_get_data(DIAG_RTC_OFFSET, rec, sizeof(rec));
    s_boot_count = ((uint8_t)rec[0] == DIAG_MAGIC) ? (uint8_t)(rec[1] + 1) : 1;
    rec[0] = (char)DIAG_MAGIC;
    rec[1] = (char)s_boot_count;
    hal_rtc_set_data(DIAG_RTC_OFFSET, rec, sizeof(rec));
    for (i = 0; i < 5; i++) {
        s_pmu_reason[i] = pmu_get_register_value(0x2D + i, 0xFF, 0);
    }
}

static void draw_static(bool touch_ok)
{
    static const uint8_t bars[8] = {
        JDI_RED, JDI_YELLOW, JDI_GREEN, JDI_CYAN, JDI_BLUE, JDI_MAGENTA, JDI_WHITE, JDI_BLACK
    };
    int i;

    jdi_lcd_fill(JDI_WHITE);
    for (i = 0; i < 8; i++) {
        jdi_lcd_fill_rect(i * 9, 0, 9, 8, bars[i]);
    }
    char buf[16];

    snprintf(buf, sizeof(buf), "P%02X%02X%02X%02X%02X", s_pmu_reason[0], s_pmu_reason[1],
             s_pmu_reason[2], s_pmu_reason[3], s_pmu_reason[4]);
    jdi_lcd_draw_text(0, 124, buf, touch_ok ? JDI_MAGENTA : JDI_RED, JDI_WHITE, 1);
}

static void draw_bus_levels(void)
{
    char buf[16];
    uint8_t lv = cy8c_touch_bus_levels();

    snprintf(buf, sizeof(buf), "SCL%d SDA%d", (lv >> 1) & 1, lv & 1);
    jdi_lcd_draw_text(0, 114, buf, JDI_BLACK, JDI_WHITE, 1);
}

/* Front light: PMIC current sink (ISINK) channel 0, set up the way the stock
 * firmware's AT+EBLT does it. Level 0 = off, 1..3 = 4 / 8 / 12 mA.
 * s_bl_level is the level last set; s_bl_on_level the one "on" returns to. */
static unsigned int s_bl_level;
static unsigned int s_bl_on_level = 2;

static bool backlight_set(unsigned int level)
{
    static const hal_isink_current_t current[3] = {
        HAL_ISINK_OUTPUT_CURRENT_4_MA, HAL_ISINK_OUTPUT_CURRENT_8_MA, HAL_ISINK_OUTPUT_CURRENT_12_MA
    };
    bool ok;

    if (level > 3) {
        return false;
    }
    if (level == 0) {
        ok = hal_isink_deinit(HAL_ISINK_CHANNEL_0) == HAL_ISINK_STATUS_OK;
    } else {
        ok = hal_isink_init(HAL_ISINK_CHANNEL_0) == HAL_ISINK_STATUS_OK &&
             hal_isink_set_mode(HAL_ISINK_CHANNEL_0, HAL_ISINK_MODE_REGISTER) == HAL_ISINK_STATUS_OK &&
             hal_isink_set_clock_source(HAL_ISINK_CHANNEL_0, HAL_ISINK_CLOCK_SOURCE_2MHZ) == HAL_ISINK_STATUS_OK &&
             hal_isink_set_step_current(HAL_ISINK_CHANNEL_0, current[level - 1]) == HAL_ISINK_STATUS_OK;
    }
    if (ok) {
        s_bl_level = level;
        if (level != 0) {
            s_bl_on_level = level;
        }
    }
    return ok;
}

/* Front light auto-off: any activity (touch, BLE message, AT+BL) turns it on
 * and it goes off s_bl_timeout_s after the last one; 0 = never. With
 * s_bl_enabled false (LIGHT button, AT+BL=0) it stays off. */
#define BL_TIMEOUT_DEFAULT_S 30
static bool s_bl_enabled = true;
static unsigned int s_bl_timeout_s = BL_TIMEOUT_DEFAULT_S;
static TickType_t s_last_activity;

static void user_activity(void)
{
    s_last_activity = xTaskGetTickCount();
    if (s_bl_enabled && s_bl_level == 0) {
        backlight_set(s_bl_on_level);
    }
}

/* Call every display loop. */
static void backlight_service(void)
{
    if (s_bl_level != 0 && s_bl_timeout_s != 0 &&
        xTaskGetTickCount() - s_last_activity >= s_bl_timeout_s * 1000 / portTICK_RATE_MS) {
        backlight_set(0);
        ulog("light: off after %u s without activity", s_bl_timeout_s);
    }
}

/* Our slider state (see touch_slider.c) and whether the last update worked. */
static touch_slider_t s_slider;
static bool s_slider_ok;

/* Red marker on the right edge at the touched row (touch_slider.c). */
static void draw_touch_marker(void)
{
    jdi_lcd_fill_rect(JDI_WIDTH - 6, 0, 6, JDI_HEIGHT, JDI_WHITE);
    if (s_slider_ok && s_slider.down) {
        int y = s_slider.row < 2 ? 0 : s_slider.row > JDI_HEIGHT - 3 ? JDI_HEIGHT - 4 : s_slider.row - 2;

        jdi_lcd_fill_rect(JDI_WIDTH - 6, y, 6, 4, JDI_RED);
    }
}

/* BHI160 panel, left of the touch marker (x < 66, 11 characters):
 * accelerometer (mg) with a bubble level, gyroscope (deg/s), step count. */
static void draw_sensors(void)
{
    static const char *const state_text[] = {
        "BOOTING", "NO DEVICE", "BAD ROM", "CRC ERROR", "NO BOOT", "CFG ERROR", "RUN"
    };
    static const char axis[3] = {'x', 'y', 'z'};
    bhi160_data_t d;
    char buf[16];
    int i, bx, by;

    bhi160_get(&d);
    jdi_lcd_fill_rect(0, 10, JDI_WIDTH - 6, 112, JDI_WHITE);
    snprintf(buf, sizeof(buf), "BHI %s", state_text[d.state]);
    jdi_lcd_draw_text(0, 10, buf, d.state == BHI160_RUNNING ? JDI_BLUE : JDI_RED, JDI_WHITE, 1);
    if (d.state != BHI160_RUNNING) {
        snprintf(buf, sizeof(buf), "ID %02X", d.product_id);
        jdi_lcd_draw_text(0, 22, buf, JDI_BLACK, JDI_WHITE, 1);
        snprintf(buf, sizeof(buf), "ROM %04X", d.rom_version);
        jdi_lcd_draw_text(0, 31, buf, JDI_BLACK, JDI_WHITE, 1);
        return;
    }

    /* Header: accelerometer in mg, plus the pedometer step count. */
    snprintf(buf, sizeof(buf), "ACC S%u", d.steps);
    jdi_lcd_draw_text(0, 22, buf, JDI_BLACK, JDI_WHITE, 1);
    for (i = 0; i < 3; i++) {
        snprintf(buf, sizeof(buf), "%c%6d", axis[i], d.acc_mg[i]);
        jdi_lcd_draw_text(0, 31 + i * 8, buf, JDI_BLACK, JDI_WHITE, 1);
    }
    /* Bubble level: the dot moves with the tilt (x/y acceleration). */
    jdi_lcd_fill_rect(46, 30, 20, 20, JDI_BLACK);
    jdi_lcd_fill_rect(47, 31, 18, 18, JDI_WHITE);
    bx = 54 - d.acc_mg[0] * 8 / 1000;
    by = 38 + d.acc_mg[1] * 8 / 1000;
    bx = bx < 47 ? 47 : bx > 61 ? 61 : bx;
    by = by < 31 ? 31 : by > 45 ? 45 : by;
    jdi_lcd_fill_rect(bx, by, 4, 4, JDI_GREEN);

    jdi_lcd_draw_text(0, 58, "GYR dps", JDI_BLACK, JDI_WHITE, 1);
    for (i = 0; i < 3; i++) {
        snprintf(buf, sizeof(buf), "%c%6d", axis[i], d.gyro_dps[i]);
        jdi_lcd_draw_text(0, 67 + i * 8, buf, JDI_BLACK, JDI_WHITE, 1);
    }
    /* Gyroscope integrated into an angle; a tap on the screen zeroes it.
     * Turning the watch 90 degrees should read ~90 on one axis. */
    jdi_lcd_draw_text(0, 94, "ANG deg", JDI_MAGENTA, JDI_WHITE, 1);
    snprintf(buf, sizeof(buf), "x%4ld y%4ld", (long)(d.angle_mdeg[0] / 1000), (long)(d.angle_mdeg[1] / 1000));
    jdi_lcd_draw_text(0, 103, buf, JDI_MAGENTA, JDI_WHITE, 1);
    snprintf(buf, sizeof(buf), "z%4ld", (long)(d.angle_mdeg[2] / 1000));
    jdi_lcd_draw_text(0, 112, buf, JDI_MAGENTA, JDI_WHITE, 1);
}

/* Screen pages. A tap in the bottom strip (row >= PAGE_TAP_ROW) or a short
 * press of the power key moves to the next one. */
#define PAGE_CLOCK     0
#define PAGE_SENSORS   1
#define PAGE_GNSS      2
#define PAGE_HR        3
#define PAGE_CONTROLS  4
#define PAGE_COUNT     5
#define PAGE_TAP_ROW   124
static uint8_t s_page = PAGE_CLOCK;

/* Watch face: local time (RTC, UTC + timezone), date, steps, last heart rate,
 * GNSS state. Shows "--:--" until the time is set (AT+TIME or GNSS). */
static void draw_clock(void)
{
    static const char *const wday[7] = {"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"};
    w3_datetime_t t;
    bhi160_data_t b;
    pah_data_t p;
    w3_gnss_data_t g;
    char buf[16];

    w3_time_get_local(&t);
    bhi160_get(&b);
    pah8011_get(&p);
    w3_gnss_get(&g);
    jdi_lcd_fill_rect(0, 10, JDI_WIDTH - 6, 112, JDI_WHITE);
    if (w3_time_is_set()) {
        snprintf(buf, sizeof(buf), "%02u:%02u", t.hour, t.min);
        jdi_lcd_draw_text(3, 20, buf, JDI_BLACK, JDI_WHITE, 2);            /* 5 chars x 12 px */
        snprintf(buf, sizeof(buf), "%02u", t.sec);
        jdi_lcd_draw_text(26, 38, buf, JDI_BLUE, JDI_WHITE, 1);
        snprintf(buf, sizeof(buf), "%s %02u/%02u", wday[t.wday % 7], t.day, t.mon);
        jdi_lcd_draw_text(0, 52, buf, JDI_BLACK, JDI_WHITE, 1);
        snprintf(buf, sizeof(buf), "UTC%+d", w3_time_get_tz());
        jdi_lcd_draw_text(0, 61, buf, JDI_BLACK, JDI_WHITE, 1);
    } else {
        jdi_lcd_draw_text(3, 20, "--:--", JDI_BLACK, JDI_WHITE, 2);
        jdi_lcd_draw_text(0, 52, "time unset", JDI_RED, JDI_WHITE, 1);
    }
    snprintf(buf, sizeof(buf), "STEP %u", b.steps);
    jdi_lcd_draw_text(0, 76, buf, JDI_MAGENTA, JDI_WHITE, 1);
    if (p.bpm_x10[0]) {
        snprintf(buf, sizeof(buf), "HR %u", (p.bpm_x10[0] + 5) / 10);
    } else {
        snprintf(buf, sizeof(buf), "HR --");
    }
    jdi_lcd_draw_text(0, 86, buf, JDI_RED, JDI_WHITE, 1);
    snprintf(buf, sizeof(buf), g.fix ? "GPS FIX %u" : "GPS --", g.sats_used);
    jdi_lcd_draw_text(0, 96, buf, g.fix ? JDI_GREEN : JDI_BLACK, JDI_WHITE, 1);
    {
        static const char *const name[] = { "BLE off", "BLE ...", "BLE adv", "BLE conn", "BLE ERR" };
        static const uint8_t color[] = { JDI_BLACK, JDI_BLACK, JDI_BLUE, JDI_GREEN, JDI_RED };
        w3_ble_info_t ble;

        w3_ble_get(&ble);
        jdi_lcd_draw_text(0, 106, name[ble.state], color[ble.state], JDI_WHITE, 1);
    }
}

/* GNSS panel: fix, UTC time/date, satellites, position, altitude, HDOP. */
static void draw_gnss(void)
{
    w3_gnss_data_t g;
    char buf[16];
    int32_t a;

    w3_gnss_get(&g);
    jdi_lcd_fill_rect(0, 10, JDI_WIDTH - 6, 112, JDI_WHITE);
    if (g.fix) {
        snprintf(buf, sizeof(buf), "GNSS %uD FIX", g.fix_type == 3 ? 3 : 2);
    } else {
        snprintf(buf, sizeof(buf), g.sentences ? "GNSS NO FIX" : "GNSS WAIT");
    }
    jdi_lcd_draw_text(0, 10, buf, g.fix ? JDI_GREEN : JDI_RED, JDI_WHITE, 1);
    if (g.time_valid) {
        snprintf(buf, sizeof(buf), "%02u:%02u:%02u UT", g.hour, g.min, g.sec);
        jdi_lcd_draw_text(0, 22, buf, JDI_BLACK, JDI_WHITE, 1);
        snprintf(buf, sizeof(buf), "%02u/%02u/20%02u", g.day, g.month, g.year);
        jdi_lcd_draw_text(0, 31, buf, JDI_BLACK, JDI_WHITE, 1);
    }
    snprintf(buf, sizeof(buf), "SAT use %u", g.sats_used);
    jdi_lcd_draw_text(0, 42, buf, JDI_BLUE, JDI_WHITE, 1);
    snprintf(buf, sizeof(buf), "GP%2u GL%2u", g.sats_view_gps, g.sats_view_glo);
    jdi_lcd_draw_text(0, 51, buf, JDI_BLUE, JDI_WHITE, 1);
    snprintf(buf, sizeof(buf), "SNR max %u", g.snr_max);
    jdi_lcd_draw_text(0, 60, buf, JDI_BLUE, JDI_WHITE, 1);
    if (g.fix) {
        a = g.lat_e7 < 0 ? -g.lat_e7 : g.lat_e7;
        snprintf(buf, sizeof(buf), "%c%3ld.%05ld", g.lat_e7 < 0 ? 'S' : 'N', (long)(a / 10000000), (long)(a % 10000000 / 100));
        jdi_lcd_draw_text(0, 71, buf, JDI_BLACK, JDI_WHITE, 1);
        a = g.lon_e7 < 0 ? -g.lon_e7 : g.lon_e7;
        snprintf(buf, sizeof(buf), "%c%3ld.%05ld", g.lon_e7 < 0 ? 'W' : 'E', (long)(a / 10000000), (long)(a % 10000000 / 100));
        jdi_lcd_draw_text(0, 80, buf, JDI_BLACK, JDI_WHITE, 1);
        snprintf(buf, sizeof(buf), "ALT %ld.%ldm", (long)(g.alt_dm / 10), (long)((g.alt_dm < 0 ? -g.alt_dm : g.alt_dm) % 10));
        jdi_lcd_draw_text(0, 89, buf, JDI_BLACK, JDI_WHITE, 1);
        snprintf(buf, sizeof(buf), "HDOP %u.%u", g.hdop_x10 / 10, g.hdop_x10 % 10);
        jdi_lcd_draw_text(0, 98, buf, JDI_BLACK, JDI_WHITE, 1);
    }
    snprintf(buf, sizeof(buf), "n%lu", (unsigned long)g.sentences);
    jdi_lcd_draw_text(0, 108, buf, JDI_BLACK, JDI_WHITE, 1);
}

/* Heart-rate panel: BPM, pulse waveform of the better channel, per-channel
 * quality and raw values. */
static void draw_hr(void)
{
    static const char *const state_text[] = {"PPG START", "PPG NO DEV", "PPG ERROR", "PPG", "PPG OFF"};
    pah_data_t p;
    char buf[16];
    float lo, hi, span;
    int i, c, y, prev_y = -1;

    pah8011_get(&p);
    jdi_lcd_fill_rect(0, 10, JDI_WIDTH - 6, 112, JDI_WHITE);
    snprintf(buf, sizeof(buf), "%s %s", state_text[p.state], p.state == PAH_RUNNING ? (p.touch ? "SKIN" : "NO SKIN") : "");
    jdi_lcd_draw_text(0, 10, buf, p.state == PAH_RUNNING && p.touch ? JDI_GREEN : JDI_RED, JDI_WHITE, 1);
    if (p.bpm_x10[p.best]) {
        snprintf(buf, sizeof(buf), "%3u", (p.bpm_x10[p.best] + 5) / 10);
    } else {
        snprintf(buf, sizeof(buf), " --");
    }
    jdi_lcd_draw_text(0, 21, buf, JDI_RED, JDI_WHITE, 2);
    jdi_lcd_draw_text(40, 29, "bpm", JDI_BLACK, JDI_WHITE, 1);

    /* Waveform box 64 x 36 at y 40, autoscaled to the last 3 s. */
    jdi_lcd_fill_rect(0, 40, 64, 1, JDI_BLACK);
    jdi_lcd_fill_rect(0, 76, 64, 1, JDI_BLACK);
    lo = hi = p.wave[0];
    for (i = 1; i < PAH_WAVE_LEN; i++) {
        lo = p.wave[i] < lo ? p.wave[i] : lo;
        hi = p.wave[i] > hi ? p.wave[i] : hi;
    }
    span = hi - lo > 1.0f ? hi - lo : 1.0f;
    for (i = 0; i < PAH_WAVE_LEN; i++) {
        y = 74 - (int)((p.wave[i] - lo) * 32.0f / span);
        jdi_lcd_fill_rect(2 + i, y, 1, 2, JDI_BLUE);
        if (prev_y >= 0 && (y - prev_y > 2 || prev_y - y > 2)) {
            jdi_lcd_fill_rect(1 + i, y < prev_y ? y : prev_y, 1, (y < prev_y ? prev_y - y : y - prev_y) + 1, JDI_BLUE);
        }
        prev_y = y;
    }
    for (c = 0; c < PAH_CHANNELS; c++) {
        snprintf(buf, sizeof(buf), "%c%c q%2u %3u", c == p.best ? '>' : ' ', 'B' + c, p.quality[c],
                 (p.bpm_x10[c] + 5) / 10);
        jdi_lcd_draw_text(0, 80 + c * 9, buf, JDI_BLACK, JDI_WHITE, 1);
    }
    snprintf(buf, sizeof(buf), "%lu", p.batch_len ? (unsigned long)p.batch[0][p.batch_len - 1] : 0UL);
    jdi_lcd_draw_text(0, 99, buf, JDI_BLACK, JDI_WHITE, 1);
    snprintf(buf, sizeof(buf), "n%lu f%u", (unsigned long)p.batches, p.fifo_count);
    jdi_lcd_draw_text(0, 108, buf, JDI_BLACK, JDI_WHITE, 1);
}

/* BLE notification overlay: shown over any page for MSG_SHOW_MS after a
 * message arrives, or until the strip is tapped. */
#define MSG_SHOW_MS     15000
#define MSG_COLS        11          /* 6 px per character, 66 px left of the marker */
#define MSG_LINES       10
static uint32_t s_msg_seq_seen;
static TickType_t s_msg_until;
static bool s_msg_active;

/* The font is ASCII only: show each UTF-8 character as one '?'. */
static void msg_to_ascii(const char *in, char *out, size_t n)
{
    size_t j = 0;

    for (; *in && j + 1 < n; in++) {
        uint8_t c = (uint8_t)*in;

        if (c < 0x80) {
            out[j++] = (c < 0x20) ? ' ' : (char)c;
        } else if (c >= 0xC0) {
            out[j++] = '?';                 /* lead byte; continuation bytes are skipped */
        }
    }
    out[j] = 0;
}

static void draw_message(const char *text)
{
    char ascii[W3_BLE_MSG_MAX + 1];
    char line[MSG_COLS + 1];
    const char *p = ascii;
    int row = 0;

    msg_to_ascii(text, ascii, sizeof(ascii));
    jdi_lcd_fill_rect(0, 10, JDI_WIDTH - 6, 112, JDI_WHITE);
    jdi_lcd_fill_rect(0, 10, JDI_WIDTH - 6, 11, JDI_BLUE);
    jdi_lcd_draw_text(3, 12, "MESSAGE", JDI_WHITE, JDI_BLUE, 1);
    /* Word wrap: break at the last space that fits, else mid-word. */
    while (*p && row < MSG_LINES) {
        size_t len = strlen(p), cut = len;

        while (*p == ' ') {
            p++;
            len--;
        }
        if (len > MSG_COLS) {
            for (cut = MSG_COLS; cut > 0 && p[cut] != ' '; cut--) {
            }
            if (cut == 0) {
                cut = MSG_COLS;
            }
        } else {
            cut = len;
        }
        memcpy(line, p, cut);
        line[cut] = 0;
        jdi_lcd_draw_text(0, 24 + row * 9, line, JDI_BLACK, JDI_WHITE, 1);
        p += cut;
        row++;
    }
}

/* Call every loop: notices a new message. Returns true while one is shown. */
static bool message_update(void)
{
    w3_ble_info_t ble;

    w3_ble_get(&ble);
    if (ble.msg_seq != s_msg_seq_seen) {
        s_msg_seq_seen = ble.msg_seq;
        s_msg_active = true;
        user_activity();
        s_msg_until = xTaskGetTickCount() + MSG_SHOW_MS / portTICK_RATE_MS;
    }
    if (s_msg_active && (int32_t)(xTaskGetTickCount() - s_msg_until) >= 0) {
        s_msg_active = false;
    }
    if (s_msg_active) {
        draw_message(ble.msg);
    }
    return s_msg_active;
}

/* Controls page: the W3 has no physical button, so these are bands of the
 * touch slider. Each button is CTL_H rows tall with a 1-row gap; the last one
 * ends at row 119, leaving a 4-row gap above the page strip (row >= 124).
 * A press acts on release, on the button the finger was over for most
 * samples: the first and last samples of a touch are the least accurate
 * (the signal is still rising or already fading). */
#define CTL_TOP     12
#define CTL_H       26
#define CTL_PITCH   27
#define CTL_COUNT   4
#define CTL_LIGHT   0
#define CTL_BUZZ    1
#define CTL_NOTIFY  2
#define CTL_SOS     3

static int8_t s_ctl_pressed = -1;          /* highlighted while the finger is on it */

static int ctl_at_row(int row)
{
    if (row < CTL_TOP || row >= CTL_TOP + CTL_COUNT * CTL_PITCH) {
        return -1;
    }
    return (row - CTL_TOP) % CTL_PITCH < CTL_H ? (row - CTL_TOP) / CTL_PITCH : -1;
}

static void draw_controls(void)
{
    static const char *const label[CTL_COUNT] = { "LIGHT", "BUZZ", "NOTIF", "SOS" };
    int i;

    jdi_lcd_fill_rect(0, 10, JDI_WIDTH - 6, 112, JDI_WHITE);
    for (i = 0; i < CTL_COUNT; i++) {
        int y = CTL_TOP + i * CTL_PITCH;
        int len = (int)strlen(label[i]);
        uint8_t bg = i == s_ctl_pressed ? JDI_BLACK :
                     i == CTL_LIGHT && s_bl_enabled ? JDI_YELLOW : JDI_WHITE;
        uint8_t fg = i == s_ctl_pressed ? JDI_WHITE : i == CTL_SOS ? JDI_RED : JDI_BLACK;

        jdi_lcd_fill_rect(1, y, JDI_WIDTH - 8, CTL_H, JDI_BLACK);    /* 1 px border */
        jdi_lcd_fill_rect(2, y + 1, JDI_WIDTH - 10, CTL_H - 2, bg);
        /* scale 2: 12 px per character, the last 2 px of a cell are blank */
        jdi_lcd_draw_text(1 + (JDI_WIDTH - 8 - (len * 12 - 2)) / 2, y + 6, label[i], fg, bg, 2);
    }
}

static void controls_action(int i)
{
    switch (i) {
        case CTL_LIGHT:
            s_bl_enabled = !s_bl_enabled;
            if (s_bl_enabled) {
                user_activity();
            } else {
                backlight_set(0);
            }
            vibrator_pulse(30, VIB_LEVEL_3V0);
            ulog("ui: light %s", s_bl_enabled ? "auto" : "off");
            break;
        case CTL_BUZZ:
            vibrator_pulse(300, VIB_LEVEL_3V0);
            ulog("ui: buzz");
            break;
        case CTL_NOTIFY:
            vibrator_play(VIB_PATTERN_NOTIFY);
            ulog("ui: notify pattern");
            break;
        case CTL_SOS:
            vibrator_play(VIB_PATTERN_SOS);
            ulog("ui: sos pattern");
            break;
        default:
            break;
    }
}

/* Call every loop while the controls page is shown. */
static void controls_touch(bool was_down)
{
    static uint8_t votes[CTL_COUNT];
    bool down = s_slider_ok && s_slider.down;
    int i, best = -1;

    if (down && !was_down) {
        memset(votes, 0, sizeof(votes));
    }
    if (down) {
        i = ctl_at_row(s_slider.row);
        if (i >= 0 && votes[i] < 255) {
            votes[i]++;
        }
    }
    for (i = 0; i < CTL_COUNT; i++) {
        if (votes[i] != 0 && (best < 0 || votes[i] > votes[best])) {
            best = i;
        }
    }
    s_ctl_pressed = down ? (int8_t)best : -1;
    if (!down && was_down) {
        controls_action(best);
        memset(votes, 0, sizeof(votes));
    }
}

/* PPG: every new FIFO batch (raw samples per channel), and a 1 s summary. */
static void log_ppg(bool summary)
{
    static uint32_t last_batch;
    pah_data_t p;
    char line[16 * PAH_BATCH];
    int c, i, n;

    pah8011_get(&p);
    if (p.batches != last_batch) {
        last_batch = p.batches;
        for (c = 0; c < PAH_CHANNELS; c++) {
            n = 0;
            for (i = 0; i < p.batch_len; i++) {
                n += snprintf(&line[n], sizeof(line) - n, " %lu", (unsigned long)p.batch[c][i]);
            }
            ulog("ppg%c%s", 'B' + c, line);
        }
    }
    if (summary) {
        ulog("pah st=%u id=%02X touch=%u n=%lu ovf=%lu fifo=%u bpm=%u q=%u",
             p.state, p.product_id, p.touch, (unsigned long)p.batches, (unsigned long)p.overflows,
             p.fifo_count, p.bpm_x10[0], p.quality[0]);
    }
}

/* Once a second: GNSS summary plus the raw RMC/GGA sentences. */
static void log_gnss(void)
{
    static char last_other[W3_GNSS_LINE_LEN], last_version[W3_GNSS_LINE_LEN], last_gsv[W3_GNSS_LINE_LEN];
    w3_gnss_data_t g;

    w3_gnss_get(&g);
    ulog("gnss n=%lu bad=%lu fix=%u/%u used=%u view=%u+%u snr=%u lat=%ld lon=%ld alt=%ld hdop=%u aid=%u pmtk=%lu",
         (unsigned long)g.sentences, (unsigned long)g.bad_checksum, g.fix, g.fix_type, g.sats_used,
         g.sats_view_gps, g.sats_view_glo, g.snr_max, (long)g.lat_e7, (long)g.lon_e7, (long)g.alt_dm, g.hdop_x10,
         g.time_aided, (unsigned long)g.pmtk_sent);
    if (g.last_rmc[0]) {
        ulog("nmea %s", g.last_rmc);
    }
    if (g.last_gga[0]) {
        ulog("nmea %s", g.last_gga);
    }
    if (g.last_other[0] && strcmp(g.last_other, last_other) != 0) {
        ulog("nmea %s", g.last_other);
        strcpy(last_other, g.last_other);
    }
    if (g.version[0] && strcmp(g.version, last_version) != 0) {
        ulog("nmea %s", g.version);
        strcpy(last_version, g.version);
    }
    if (g.last_gsv[0] && strcmp(g.last_gsv, last_gsv) != 0) {
        ulog("nmea %s", g.last_gsv);
        strcpy(last_gsv, g.last_gsv);
    }
}

/* After boot: the 16-byte information block of every virtual sensor 1..31
 * (layout in bhi160.c). A burst of 31 lines overflows the USB log's transmit
 * buffer and lines get dropped, so this logs 4 sensors per call (every 0.5 s).
 * Returns true when the whole list has been logged. */
static bool log_bhi_sensor_list(void)
{
    static uint8_t next_id = 1;
    uint8_t info[BHI160_INFO_LEN];
    char hex[3 * BHI160_INFO_LEN + 1];
    int i, n;

    for (n = 0; n < 4 && next_id < 32; n++, next_id++) {
        if (!bhi160_get_sensor_info(next_id, info)) {
            ulog("bhi sensor %2u: no reply", next_id);
            continue;
        }
        for (i = 0; i < BHI160_INFO_LEN; i++) {
            snprintf(&hex[i * 3], 4, "%02X ", info[i]);
        }
        ulog("bhi sensor %2u: drv=%u v%u rate=%u..%uHz event=%uB  raw %s", next_id, info[1], info[2],
             info[15], info[8] | (info[9] << 8), info[14], hex);
    }
    return next_id >= 32;
}

/* Twice a second: BHI160 state and latest values. */
static void log_sensors(void)
{
    static bool listed;
    bhi160_data_t d;
    char hex[3 * sizeof(d.pedo_raw) + 1];
    int i;

    bhi160_get(&d);
    if (!listed && d.info_ready) {
        listed = log_bhi_sensor_list();
    }
    if (d.pedo_events) {
        /* Raw pedometer payload, to work out its format on a test walk. */
        for (i = 0; i < d.pedo_len; i++) {
            snprintf(&hex[i * 3], 4, "%02X ", d.pedo_raw[i]);
        }
        hex[d.pedo_len * 3] = 0;
        ulog("bhi pedo n=%lu len=%u raw %s", (unsigned long)d.pedo_events, d.pedo_len, hex);
    }
    ulog("bhi st=%u id=%02X rom=%04X ram=%04X crc=%08lX/%08lX ack=%02X %02X %02X acc=%d %d %d mg gyr=%d %d %d dps ang=%ld %ld %ld mdeg steps=%u n=%lu/%lu meta=%lu last=%02X %02X %02X",
         d.state, d.product_id, d.rom_version, d.ram_version,
         (unsigned long)d.crc_device, (unsigned long)d.crc_expected,
         d.cfg_ack[0], d.cfg_ack[1], d.cfg_ack[2], d.acc_mg[0], d.acc_mg[1], d.acc_mg[2],
         d.gyro_dps[0], d.gyro_dps[1], d.gyro_dps[2],
         (long)d.angle_mdeg[0], (long)d.angle_mdeg[1], (long)d.angle_mdeg[2],
         d.steps, (unsigned long)d.samples, (unsigned long)d.gyro_samples,
         (unsigned long)d.meta_events, d.last_meta[0], d.last_meta[1], d.last_meta[2]);
}

/* While true the display task stops polling the touch chip, so a host tool can
 * talk to the chip's bootloader through AT+TPBL without our traffic in between. */
static bool s_touch_paused;

static void usb_write_hex(const uint8_t *buf, uint32_t len)
{
    char out[4];
    uint32_t i;

    for (i = 0; i < len; i++) {
        snprintf(out, sizeof(out), "%02X", buf[i]);
        usb_log_write(out);
    }
}

/* Parse hex digits up to ',' or end of string. Returns the byte count, or -1. */
static int parse_hex(const char *s, uint8_t *buf, uint32_t max)
{
    uint32_t n = 0;
    unsigned int b;

    while (*s && *s != ',') {
        if (n >= max || sscanf(s, "%2x", &b) != 1 || !s[1] || s[1] == ',') {
            return -1;
        }
        buf[n++] = (uint8_t)b;
        s += 2;
    }
    return (int)n;
}

/* Bootloader packet: write it, wait, then read the reply. The bootloader
 * answers 0xFF bytes until its reply is ready, so poll until the reply starts
 * with the start-of-packet byte 0x01. */
static void touch_bootloader_xfer(const char *args)
{
    uint8_t pkt[96];
    uint8_t rsp[64];
    unsigned int rlen = 0, wait_ms = 20, tries;
    const char *comma = strchr(args, ',');
    int n = parse_hex(args, pkt, sizeof(pkt));

    if (n <= 0 || (comma && sscanf(comma, ",%u,%u", &rlen, &wait_ms) < 1) || rlen > sizeof(rsp)) {
        usb_log_write("ERROR args\r\n");
        return;
    }
    if (!cy8c_touch_raw_write(pkt, (uint32_t)n)) {
        usb_log_write("ERROR i2c write\r\n");
        return;
    }
    if (rlen == 0) {
        usb_log_write("OK\r\n");
        return;
    }
    for (tries = 0; tries < 50; tries++) {
        vTaskDelay(wait_ms / portTICK_RATE_MS);
        if (cy8c_touch_raw_read(rsp, rlen) && rsp[0] == 0x01) {
            usb_log_write("TPBL: ");
            usb_write_hex(rsp, rlen);
            usb_log_write("\r\nOK\r\n");
            return;
        }
        wait_ms = 10;
    }
    usb_log_write("ERROR no reply\r\n");
}

/* USB commands for the touch controller:
 *   AT+TPR=<reg hex>,<len>        read registers (write reg, read len)
 *   AT+TPPAUSE=1 / =0             stop / resume our polling (=0 also re-inits)
 *   AT+TPW=<hex bytes>            raw I2C write
 *   AT+TPRD=<len>                 raw I2C read
 *   AT+TPBL=<hex>,<rlen>[,<ms>]   raw write, wait, read an rlen-byte reply
 * and AT+BL=<0..3> for the front light (0 = off and stays off; 1..3 = 4/8/12 mA,
 * auto-off after AT+BLTO=<s> seconds without activity, default 30, 0 = never), plus:
 *   AT+TIME=YYYY-MM-DD,HH:MM:SS   set the RTC (UTC), e.g. from the PC:
 *                                  printf "AT+TIME=$(date -u +%Y-%m-%d,%H:%M:%S)\r" > /dev/ttyACM0
 *   AT+TIME?                      print UTC and local time
 *   AT+TZ=<hours>                 timezone offset for the watch face (default +7)
 *   AT+VIB=<ms>[,<level>]         one buzz; level 1/2/3 = 2.8/3.0/3.3 V (default 2,
 *                                  the stock strength); AT+VIB=0 stops
 *   AT+VIBP=<n>                   play stock pattern n: 0 notify, 1 ramp, 2 SOS
 *   AT+BLE?                       BLE state and counters
 *   AT+GNSSCMD=<PMTK body>        send a PMTK command to the GNSS receiver (checksum
 *                                  added), e.g. AT+GNSSCMD=PMTK607 (query EPO)
 *   AT+GNSSLAST?                  last PMTK reply / ack from the receiver
 *   AT+GNSSFIX?                   current fix: valid,lat*1e7,lon*1e7,alt_dm,sats */
bool usb_log_app_command(const char *line)
{
    unsigned int reg, len, i;
    uint8_t buf[64];
    char out[8];

    {
        int y, mo, d, h, mi, s, tz;
        w3_datetime_t u, l;

        if (sscanf(line, "AT+TIME=%d-%d-%d,%d:%d:%d", &y, &mo, &d, &h, &mi, &s) == 6) {
            usb_log_write(w3_time_set_utc(y, mo, d, h, mi, s) ? "OK\r\n" : "ERROR\r\n");
            return true;
        }
        if (strcmp(line, "AT+TIME?") == 0) {
            w3_time_get_utc(&u);
            w3_time_get_local(&l);
            snprintf((char *)buf, sizeof(buf), "+TIME: %04u-%02u-%02u %02u:%02u:%02u UTC\r\n",
                     u.year, u.mon, u.day, u.hour, u.min, u.sec);
            usb_log_write((char *)buf);
            snprintf((char *)buf, sizeof(buf), "+TIME: %02u:%02u:%02u local (UTC%+d)\r\nOK\r\n",
                     l.hour, l.min, l.sec, w3_time_get_tz());
            usb_log_write((char *)buf);
            return true;
        }
        if (sscanf(line, "AT+TZ=%d", &tz) == 1) {
            w3_time_set_tz(tz);
            usb_log_write(w3_time_get_tz() == tz ? "OK\r\n" : "ERROR\r\n");
            return true;
        }
    }
    if (strncmp(line, "AT+GNSSCMD=", 11) == 0) {
        usb_log_write(w3_gnss_send_pmtk(line + 11) ? "OK\r\n" : "ERROR\r\n");
        return true;
    }
    if (strcmp(line, "AT+GNSSLAST?") == 0 || strcmp(line, "AT+GNSSFIX?") == 0) {
        w3_gnss_data_t g;

        w3_gnss_get(&g);
        if (line[7] == 'L') {                    /* "AT+GNSS" is 7 chars: L(AST) or F(IX) */
            usb_log_write("+GNSSLAST: ");
            usb_log_write(g.last_other);
        } else {
            snprintf((char *)buf, sizeof(buf), "+GNSSFIX: %u,%ld,%ld,%ld,%u", g.fix, (long)g.lat_e7,
                     (long)g.lon_e7, (long)g.alt_dm, g.sats_used);
            usb_log_write((char *)buf);
        }
        usb_log_write("\r\nOK\r\n");
        return true;
    }
    if (strcmp(line, "AT+BLE?") == 0) {
        static const char *const st[] = { "off", "starting", "advertising", "connected", "error" };
        w3_ble_info_t b;

        w3_ble_get(&b);
        snprintf((char *)buf, sizeof(buf), "+BLE: %s,err=0x%08lX,conns=%lu\r\n", st[b.state],
                 (unsigned long)b.last_status, (unsigned long)b.connections);
        usb_log_write((char *)buf);
        snprintf((char *)buf, sizeof(buf), "+BLE: imu=%s,%uHz,sent=%lu,busy=%lu\r\n", b.imu_notify ? "on" : "off",
                 b.imu_rate_hz, (unsigned long)b.imu_sent, (unsigned long)b.imu_busy);
        usb_log_write((char *)buf);
        snprintf((char *)buf, sizeof(buf), "+BLE: time_syncs=%lu,msgs=%lu\r\nOK\r\n",
                 (unsigned long)b.time_syncs, (unsigned long)b.msg_seq);
        usb_log_write((char *)buf);
        return true;
    }
    if (sscanf(line, "AT+VIBP=%u", &len) == 1) {
        usb_log_write(vibrator_play(len) ? "OK\r\n" : "ERROR\r\n");
        return true;
    }
    {
        unsigned int level = VIB_LEVEL_3V0;

        if (sscanf(line, "AT+VIB=%u,%u", &len, &level) >= 1) {
            usb_log_write(vibrator_pulse(len, (uint8_t)level) ? "OK\r\n" : "ERROR\r\n");
            return true;
        }
    }
    if (sscanf(line, "AT+BLTO=%u", &len) == 1) {
        s_bl_timeout_s = len;
        user_activity();
        usb_log_write("OK\r\n");
        return true;
    }
    if (sscanf(line, "AT+BL=%u", &len) == 1) {
        bool ok = backlight_set(len);

        if (ok) {
            s_bl_enabled = len != 0;
            s_last_activity = xTaskGetTickCount();
        }
        usb_log_write(ok ? "OK\r\n" : "ERROR\r\n");
        return true;
    }
    if (strncmp(line, "AT+TPPAUSE=", 11) == 0) {
        s_touch_paused = line[11] == '1';
        if (!s_touch_paused && !cy8c_touch_init()) {
            usb_log_write("ERROR touch init\r\n");
            return true;
        }
        usb_log_write("OK\r\n");
        return true;
    }
    if (strncmp(line, "AT+TPBL=", 8) == 0) {
        touch_bootloader_xfer(line + 8);
        return true;
    }
    if (strncmp(line, "AT+TPW=", 7) == 0) {
        int n = parse_hex(line + 7, buf, sizeof(buf));

        usb_log_write(n > 0 && cy8c_touch_raw_write(buf, (uint32_t)n) ? "OK\r\n" : "ERROR\r\n");
        return true;
    }
    if (sscanf(line, "AT+TPRD=%u", &len) == 1) {
        if (len == 0 || len > sizeof(buf) || !cy8c_touch_raw_read(buf, len)) {
            usb_log_write("ERROR\r\n");
            return true;
        }
        usb_log_write("TPRD: ");
        usb_write_hex(buf, len);
        usb_log_write("\r\nOK\r\n");
        return true;
    }
    if (sscanf(line, "AT+TPR=%x,%u", &reg, &len) == 2) {
        if (len == 0 || len > sizeof(buf)) {
            usb_log_write("ERROR len 1..64\r\n");
            return true;
        }
        if (!cy8c_touch_read_reg((uint16_t)reg, buf, len)) {
            usb_log_write("ERROR i2c\r\n");
            return true;
        }
        snprintf(out, sizeof(out), "%04X:", reg);
        usb_log_write(out);
        for (i = 0; i < len; i++) {
            snprintf(out, sizeof(out), " %02X", buf[i]);
            usb_log_write(out);
        }
        usb_log_write("\r\nOK\r\n");
        return true;
    }
    return false;
}

/* Every 100 ms: chip position/status, our signals vs our baselines (top,
 * middle, bottom electrode), touch state, centroid and row, and raw counts. */
static void log_touch_dump(void)
{
    const touch_slider_t *t = &s_slider;

    if (!s_slider_ok) {
        ulog("tp ERR (needs touch firmware 0x18)");
        return;
    }
    ulog("tp chip=%3u st=%u d=%5d %5d %5d down=%u pos=%3u row=%3u raw=%u %u %u",
         t->chip_pos, t->chip_status, t->d[0], t->d[1], t->d[2], t->down,
         t->down ? t->pos : 0, t->down ? t->row : 0, t->raw[0], t->raw[1], t->raw[2]);
}

/* Power key (PMIC PWRKEY, initialised by sys_init). The keypad driver queues
 * events and calls this callback from its interrupt handler; the display loop
 * then drains the queue with hal_keypad_powerkey_get_key(). */
static volatile bool s_key_pending;

static void powerkey_callback(void *user_data)
{
    (void)user_data;
    s_key_pending = true;
}

/* Short press (released without a long-press event): next page.
 * Long press: cycle the front light 0 -> 1 -> 2 -> 3 -> 0.
 * Each action gives a short buzz as feedback. */
static void handle_power_key(void)
{
    static bool long_seen;
    hal_keypad_powerkey_event_t e;
    int n;

    if (!s_key_pending) {
        return;
    }
    s_key_pending = false;
    for (n = 0; n < 8 && hal_keypad_powerkey_get_key(&e) == HAL_KEYPAD_STATUS_OK; n++) {
        ulog("key: state=%d data=%lu", e.state, (unsigned long)e.key_data);
        if (e.state == HAL_KEYPAD_KEY_LONG_PRESS && !long_seen) {
            long_seen = true;
            backlight_set((s_bl_level + 1) % 4);
            s_bl_enabled = s_bl_level != 0;
            s_last_activity = xTaskGetTickCount();
            vibrator_pulse(80, VIB_LEVEL_3V0);
        } else if (e.state == HAL_KEYPAD_KEY_RELEASE) {
            if (!long_seen) {
                s_page = (uint8_t)((s_page + 1) % PAGE_COUNT);
                vibrator_pulse(30, VIB_LEVEL_3V0);
            }
            long_seen = false;
        }
    }
}

static void display_task(void *arg)
{
    uint32_t ticks = 0;
    uint32_t paused_ms = 0;
    char buf[16];
    uint32_t usb_absent_ticks = 0;
    bool touch_ok;
    cy8c_touch_event_t ev;

    (void)arg;
    /* Keep the chip out of deep sleep for now: in sleep the PMIC switches to
     * its sleep power mode, which may drop the panel supply (VMC). */
    hal_sleep_manager_lock_sleep(hal_sleep_manager_set_sleep_handle("w3disp"));
    hal_charger_init();
    hal_charger_reset_watchdog_timer();
    usb_log_init();
    jdi_lcd_init();
    backlight_set(2);
    s_last_activity = xTaskGetTickCount();
    touch_ok = cy8c_touch_init();
    draw_static(touch_ok);
    jdi_lcd_flush(true);
    hal_keypad_powerkey_register_callback(powerkey_callback, NULL);
    LOG_I(w3, "display up, touch %s\r\n", touch_ok ? "ok" : "fail");

    usb_absent_ticks = usb_plugged() ? 0 : USB_UNPLUG_TICKS;

    for (;;) {
        bool present;
        bool ok;

        if (s_touch_paused) {
            /* Bootloader session: just serve USB commands, quickly, and keep
             * both watchdogs fed (about every 200 ms). */
            usb_log_poll();
            if (++paused_ms % 200 == 0) {
                hal_charger_reset_watchdog_timer();
                hal_wdt_feed(HAL_WDT_FEED_MAGIC);
            }
            vTaskDelay(1);
            continue;
        }
        present = usb_plugged();
        ok = cy8c_touch_read(&ev);
        {
            static bool s_touch_consumed;   /* this touch dismissed a message: ignore it */
            bool was_down = s_slider.down;

            s_slider_ok = touch_slider_update(&s_slider);
            if (s_slider_ok && s_slider.down) {
                user_activity();            /* holding a finger keeps the light on */
            }
            if (s_slider_ok && s_slider.down && !was_down && s_msg_active) {
                s_msg_active = false;
                s_touch_consumed = true;
            } else if (!(s_slider_ok && s_slider.down)) {
                if (s_touch_consumed) {
                    s_touch_consumed = false;
                    was_down = false;           /* the release is not a button press either */
                }
            }
            if (s_touch_consumed) {
                /* nothing */
            } else if (s_slider_ok && s_slider.down && !was_down) {
                if (s_slider.row >= PAGE_TAP_ROW) {
                    s_page = (uint8_t)((s_page + 1) % PAGE_COUNT);
                } else if (s_page == PAGE_SENSORS) {
                    bhi160_reset_angles();  /* a tap zeroes the gyro angles */
                }
            }
            if (!s_touch_consumed && s_page == PAGE_CONTROLS) {
                controls_touch(was_down);
            }
        }

        if (!present) {
            usb_absent_ticks++;
        } else if (usb_absent_ticks) {
            if (usb_absent_ticks >= USB_UNPLUG_TICKS) {
                reboot_to_download_window();
            }
            ulog("usb: VBUS glitch, gone for ~%lu ms", (unsigned long)(usb_absent_ticks * 50));
            usb_absent_ticks = 0;
        }

        handle_power_key();
        backlight_service();
        /* The PPG LED only runs while its page is shown (power saving). */
        pah8011_set_active(s_page == PAGE_HR);

        if (message_update()) {
            /* the message covers the page */
        } else if (s_page == PAGE_CLOCK) {
            draw_clock();
        } else if (s_page == PAGE_GNSS) {
            draw_gnss();
        } else if (s_page == PAGE_HR) {
            draw_hr();
        } else if (s_page == PAGE_CONTROLS) {
            draw_controls();
        } else {
            draw_sensors();
        }
        draw_touch_marker();
        if (!ok) {
            draw_bus_levels();
        }
        snprintf(buf, sizeof(buf), "%5lu s", (unsigned long)(ticks / 20));
        jdi_lcd_draw_text(6, 134, buf, JDI_BLACK, JDI_WHITE, 1);
        jdi_lcd_flush(false);

        /* hal_charger_init() arms a 16 s PMU charger watchdog; if it expires the
         * charger is switched off, which kills a battery-less watch on USB. */
        usb_log_poll();
        if (ticks % 10 == 0) {
            log_sensors();
        }
        if (ticks % 20 == 5) {
            w3_gnss_data_t g;
            w3_datetime_t t;

            log_gnss();
            /* Keep the RTC on GNSS time once satellites provide a real date. */
            w3_gnss_get(&g);
            if (w3_time_sync_from_gnss(&g)) {
                w3_time_get_utc(&t);
                ulog("time: RTC set from GNSS to %04u-%02u-%02u %02u:%02u:%02u UTC",
                     t.year, t.mon, t.day, t.hour, t.min, t.sec);
            }
        }
        log_ppg(ticks % 20 == 15);
        if (ticks % 2 == 0 && s_slider.down) {
            log_touch_dump();
        }
        if (ticks % 20 == 0) {
            hal_gpio_data_t disp = HAL_GPIO_DATA_LOW;

            hal_charger_reset_watchdog_timer();
            hal_wdt_feed(HAL_WDT_FEED_MAGIC);
            hal_gpio_get_output(HAL_GPIO_15, &disp);
            ulog("pmu: boot pwrhold=%u shdncfg1=%02X | now pwrhold=%u shdncfg1=%02X ponsts=%02X poffsts=%02X",
                 s_boot_pwrhold, s_boot_shdncfg1,
                 pmu_get_register_value(PMU_RG_PWRHOLD_ADDR, PMU_RG_PWRHOLD_MASK, PMU_RG_PWRHOLD_SHIFT),
                 pmu_get_register_value(PMU_SHDNCFG1, 0xFF, 0),
                 pmu_get_register_value(PMU_PONSTS, 0xFF, 0), pmu_get_register_value(PMU_POFFSTS, 0xFF, 0));
            ulog("up=%lus boot=%u wdt_sta=%04lX pmu=%02X%02X%02X%02X%02X vmc_en=%u vmc_stb=%u disp=%d touch=%s %02X %02X %02X %02X %02X %02X",
                 (unsigned long)(ticks / 20), s_boot_count, (unsigned long)(s_wdt_sta & 0xFFFF),
                 s_pmu_reason[0], s_pmu_reason[1], s_pmu_reason[2], s_pmu_reason[3], s_pmu_reason[4],
                 pmu_get_register_value(PMU_RG_VMC_EN_ADDR, PMU_RG_VMC_EN_MASK, PMU_RG_VMC_EN_SHIFT),
                 pmu_get_register_value(PMU_RGS_VMC_STBSTS_ADDR, PMU_RGS_VMC_STBSTS_MASK, PMU_RGS_VMC_STBSTS_SHIFT),
                 disp, ok ? "ok" : "ERR", ev.raw[0], ev.raw[1], ev.raw[2], ev.raw[3], ev.raw[4], ev.raw[5]);
        }

        ticks++;
        vTaskDelay(50 / portTICK_RATE_MS);
    }
}

int main(void)
{
    /* The stock bootloader leaves the watchdog running (~30 s). A WDT register
     * write within ~4 32 kHz cycles of the previous one is ignored, so an early
     * disable can be lost: disable again after system init, and the display
     * task also feeds it every second. */
    s_wdt_sta = RGU_WDT_STA;
    hal_wdt_disable(HAL_WDT_DISABLE_MAGIC);

    system_init();
    hal_wdt_disable(HAL_WDT_DISABLE_MAGIC);
    capture_reset_diag();
    pmu_hold_power();
    log_init(NULL, NULL, NULL);
    LOG_I(w3, "w3_display start\r\n");

    xTaskCreate(display_task, "DISPLAY", 1024, NULL, 3, NULL);
    vibrator_init();
    w3_ble_start();
    sensor_i2c_init();          /* shared by the BHI160 and PAH8011 tasks */
    bhi160_start();
    w3_gnss_start();
    pah8011_start();
    SysInitStatus_Set();
    vTaskStartScheduler();

    for (;;);
}

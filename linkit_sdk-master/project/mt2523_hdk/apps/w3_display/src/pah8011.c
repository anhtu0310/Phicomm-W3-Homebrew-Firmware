#include <string.h>

#include "FreeRTOS.h"
#include "task.h"
#include "hal.h"
#include "sensor_i2c.h"
#include "heart_rate.h"
#include "pah8011.h"

/*
 * A port of the stock W3 firmware's PAH8011 driver (v1008), reconstructed by
 * disassembling it (flash 0x0803C400..0x0803E000; function names come from its
 * log strings). The stock app calls pah_init_with_flags({1, 0, 0, 0}) (flag 0 =
 * polling mode, flag 2 = LED-on-touch off, flag 3 = table set 0), then
 * pah_enter_mode(4) = PPG + touch, then pah_task() periodically.
 */

/* PPG LED power enable. The stock pah_ppg1_operate() drives it high before
 * starting the sensor and low after stopping it (pin number read from flash
 * 0x0813A163 = 0x30). The chip answers on I2C without it, but its LED stays
 * dark and every sample reads 0. */
#define PAH_POWER_PIN       HAL_GPIO_48
#define PAH_I2C_ADDR        0x15
#define PRODUCT_ID          0x11
#define REG_BANK            0x7F    /* every register access is (bank, reg) */
#define POLL_MS             50
#define REPORT_SAMPLES      20      /* stock default report_sample_num_per_ch */
#define MAX_FRAMES          64      /* samples read per poll at most */

/* Stock init table (flash 0x080D700A, "reg table v1006"). Its bank 1 regs
 * 0x21/0x23/0x25 also tell the driver which channels exist: bit 0 = PPG
 * channel enabled, bit 0 & bit 3 = channel goes into the FIFO. Here only
 * channel B (0x23 = 0x69) is enabled. */
static const uint8_t s_init_regs[][2] = {
    {0x7F, 0x00}, {0x19, 0x2E}, {0x38, 0x2E}, {0x57, 0x2E}, {0x70, 0x01}, {0x71, 0x06},
    {0x72, 0x04}, {0x73, 0x0F}, {0x74, 0x0F}, {0x75, 0x0F},
    {0x7F, 0x04}, {0x15, 0x69}, {0x2B, 0xFE}, {0x34, 0x01}, {0x70, 0x18},
    {0x7F, 0x05}, {0x58, 0x00}, {0x59, 0x00}, {0x5A, 0x00}, {0x5B, 0x00}, {0x5D, 0x08},
    {0x60, 0x35}, {0x6A, 0x6D},
    {0x7F, 0x01}, {0x02, 0x32}, {0x05, 0x04}, {0x08, 0x03}, {0x14, 0x04}, {0x1B, 0x04},
    {0x21, 0x68}, {0x23, 0x69}, {0x25, 0x68}, {0x74, 0x01}, {0x75, 0x03},
};

/* PPG 20 Hz mode table (flash 0x080D6FD7; same as PixArt's open driver). */
static const uint8_t s_ppg_20hz_regs[][2] = {
    {0x7F, 0x05}, {0x44, 0x1F},
    {0x7F, 0x01}, {0x1C, 0x04}, {0x1D, 0x04}, {0x26, 0x40}, {0x27, 0x06}, {0x12, 0x14},
    {0x3C, 0x80}, {0x3D, 0x02}, {0x44, 0x80}, {0x45, 0x02}, {0x4C, 0x80}, {0x4D, 0x02},
};

static pah_data_t s_data;
static heart_rate_t s_hr;
static uint8_t s_bank = 0xFF;
static bool s_touch_in_fifo;        /* bank 1 0x5A bit 0: touch flag in FIFO bit 0 */
static uint32_t s_since_update;
static volatile bool s_want_active; /* requested by pah8011_set_active() */

/* ---- register access ---- */

static bool wr(uint8_t reg, uint8_t value)
{
    if (reg == REG_BANK) {
        if (s_bank == value) {
            return true;
        }
        if (!sensor_i2c_write(PAH_I2C_ADDR, REG_BANK, &value, 1)) {
            s_bank = 0xFF;
            return false;
        }
        s_bank = value;
        return true;
    }
    return sensor_i2c_write(PAH_I2C_ADDR, reg, &value, 1);
}

static bool rd(uint8_t reg, uint8_t *value, uint32_t len)
{
    return sensor_i2c_read(PAH_I2C_ADDR, reg, value, len);
}

/* Read-modify-write: set and clear bits of one register in the current bank. */
static bool rmw(uint8_t reg, uint8_t set, uint8_t clear)
{
    uint8_t v;

    return rd(reg, &v, 1) && wr(reg, (uint8_t)((v | set) & ~clear));
}

static bool write_table(const uint8_t (*t)[2], uint32_t n)
{
    uint32_t i;

    for (i = 0; i < n; i++) {
        if (!wr(t[i][0], t[i][1])) {
            return false;
        }
    }
    return true;
}

static void delay_ms(uint32_t ms)
{
    vTaskDelay(ms / portTICK_RATE_MS ? ms / portTICK_RATE_MS : 1);
}

/* _pah8011_update_flag: bank 1 0x24 = 1 latches new settings, then 2 ms. */
static bool update_flag(void)
{
    if (!wr(REG_BANK, 1) || !wr(0x24, 0x01)) {
        return false;
    }
    delay_ms(2);
    return true;
}

/* _pah8011_startup / _pah8011_shutdown: bank 4 0x69 = power-down. */
static bool startup(void)
{
    if (!wr(REG_BANK, 4) || !wr(0x69, 0x00)) {
        return false;
    }
    delay_ms(2);
    return true;
}

static bool shutdown(void)
{
    if (!wr(REG_BANK, 4) || !wr(0x69, 0x01)) {
        return false;
    }
    delay_ms(1);
    return true;
}

static bool verify_product_id(void)
{
    return wr(REG_BANK, 0) && rd(0x00, &s_data.product_id, 1) && s_data.product_id == PRODUCT_ID;
}

/* _pah8011_set_report_num: bank 1 0x57/0x56 = samples per report (all channels) + 1. */
static bool set_report_num(uint32_t samples)
{
    uint32_t n = samples + 1;

    return wr(REG_BANK, 1) && wr(0x57, (uint8_t)((n >> 8) & 0x01)) && wr(0x56, (uint8_t)(n & 0xFF)) &&
           update_flag();
}

static bool clear_fifo_and_int(void)
{
    uint8_t int_req = 0;

    if (!wr(REG_BANK, 1) || !wr(0x70, 0x01) || !update_flag()) {
        return false;
    }
    delay_ms(60);
    if (!wr(REG_BANK, 1) || !wr(0x70, 0x00) || !update_flag() || !wr(REG_BANK, 2) || !rd(0x1B, &int_req, 1)) {
        return false;
    }
    return int_req == 0 || wr(0x1B, int_req);
}

/* pah_init_with_flags({1, 0, 0, 0}) */
static pah_state_t pah_init(void)
{
    if (!verify_product_id() && !(startup() && verify_product_id())) {
        return PAH_NO_DEVICE;
    }
    /* pah_8011_device_init: bank 4 0x34 = 1, then shutdown */
    if (!wr(REG_BANK, 4) || !wr(0x34, 0x01) || !shutdown()) {
        return PAH_INIT_ERROR;
    }
    /* Board setup. A stock helper returns 0x18 here, which selects 0x2B = 0xFE
     * and 0x70 = 0x18 (other boards: 0x2B = 0xFF, 0x70 = 0x08). */
    if (!wr(REG_BANK, 4) || !wr(0x15, 0x69) || !wr(0x34, 0x01) || !wr(0x2B, 0xFE) || !wr(0x70, 0x18) ||
        !shutdown()) {
        return PAH_INIT_ERROR;
    }
    return PAH_RUNNING;
}

/* pah_enter_mode(4): pah_set_mode(4) + pah_run_device(ppg) + pah_run_device(touch) */
static pah_state_t pah_enter_ppg_touch_mode(void)
{
    uint8_t v;

    /* set_mode from stop: _pah8011_startup + _pah8011_init */
    if (!startup() || !write_table(s_init_regs, sizeof(s_init_regs) / 2) || !update_flag() ||
        !wr(REG_BANK, 1) || !rmw(0x21, 0, 0x01) || !rmw(0x23, 0, 0x01) || !rmw(0x25, 0, 0x01) ||
        !rmw(0x36, 0, 0x03) || !rmw(0x37, 0x02, 0) || !rd(0x5A, &v, 1)) {
        return PAH_INIT_ERROR;
    }
    s_touch_in_fifo = v & 0x01;
    if (!wr(REG_BANK, 1) || !rmw(0x35, 0, 0x02) || !update_flag() ||
        !set_report_num(REPORT_SAMPLES * PAH_CHANNELS)) {
        return PAH_INIT_ERROR;
    }
    /* mode 4: new FIFO rate, so stop PPG + clear FIFO, then the 20 Hz table */
    if (!clear_fifo_and_int() || !write_table(s_ppg_20hz_regs, sizeof(s_ppg_20hz_regs) / 2) ||
        !set_report_num(REPORT_SAMPLES * PAH_CHANNELS) || !update_flag()) {
        return PAH_INIT_ERROR;
    }
    /* run_device(ppg): _pah8011_start_ppg (channel B only), update flag,
     * then _pah8011_start_tg */
    if (!wr(REG_BANK, 1) || !rmw(0x23, 0x01, 0) || !update_flag()) {
        return PAH_INIT_ERROR;
    }
    delay_ms(1);
    if (!wr(REG_BANK, 1) || !rmw(0x37, 0, 0x01 | 0x04 | 0x08) || !wr(0x30, 0x01)) {
        return PAH_INIT_ERROR;
    }
    delay_ms(1);
    if (!wr(REG_BANK, 2) || !wr(0x1B, 0xFF) || !wr(REG_BANK, 1) || !rmw(0x37, 0, 0x10)) {
        return PAH_INIT_ERROR;
    }
    /* run_device(touch): _pah8011_start_touch with INT2-as-touch off */
    if (!wr(REG_BANK, 1) || !rmw(0x36, 0, 0x03) || !rmw(0x37, 0, 0x02) || !update_flag()) {
        return PAH_INIT_ERROR;
    }
    return PAH_RUNNING;
}

/* ---- data ---- */

static uint32_t le32(const uint8_t *p)
{
    return p[0] | (p[1] << 8) | (p[2] << 16) | ((uint32_t)p[3] << 24);
}

static void process_samples(const uint8_t *fifo, uint32_t frames, bool touch)
{
    int32_t s[MAX_FRAMES];
    uint32_t i, keep;
    bool ok = false, updated = false;

    for (i = 0; i < frames; i++) {
        s[i] = (int32_t)le32(&fifo[i * 4 * PAH_CHANNELS]);
    }
    heart_rate_push(&s_hr, s, frames);
    s_since_update += frames;
    if (s_since_update >= HR_RATE_HZ / 2) {
        s_since_update = 0;
        ok = heart_rate_update(&s_hr, 50);
        updated = true;
    }

    taskENTER_CRITICAL();
    s_data.touch = touch;
    s_data.batches++;
    keep = frames < PAH_BATCH ? frames : PAH_BATCH;
    s_data.batch_len = (uint8_t)keep;
    for (i = 0; i < keep; i++) {
        s_data.batch[0][i] = (uint32_t)s[frames - keep + i];
    }
    if (updated) {
        s_data.quality[0] = s_hr.quality;
        s_data.bpm_x10[0] = (touch && ok) ? s_hr.bpm_x10 : 0;
        memcpy(s_data.wave, &s_hr.clean[HR_WINDOW - PAH_WAVE_LEN], sizeof(s_data.wave));
    }
    taskEXIT_CRITICAL();
}

/* pah_task() in polling mode (_pah8011_task_polling). */
static void poll(void)
{
    static uint8_t fifo[MAX_FRAMES * 4 * PAH_CHANNELS];
    uint8_t int_req = 0, cnt[2], flag = 0;
    uint32_t count, frames, off, n;
    bool touch;

    if (!wr(REG_BANK, 2) || !wr(0x7C, 0x00) || !rd(0x1B, &int_req, 1)) {
        return;
    }
    if (int_req & 0x0C) {                       /* FIFO overflow / underflow */
        s_data.overflows++;
        clear_fifo_and_int();
        return;
    }
    if (!rd(0x25, cnt, 2) || !rd(0x00, &flag, 1)) {
        return;
    }
    touch = flag & 0x01;
    count = cnt[0] | (cnt[1] << 8);
    s_data.fifo_count = (uint16_t)count;
    frames = count > 1 ? (count - 1) / PAH_CHANNELS : 0;
    if (frames > MAX_FRAMES) {
        frames = MAX_FRAMES;
    }
    if (frames) {
        /* _pah8011_enable_fifo_clk: bank 1 0x71 = 0, bank 0 0x10 = 3 */
        if (!wr(REG_BANK, 1) || !wr(0x71, 0x00) || !wr(REG_BANK, 0) || !wr(0x10, 0x03)) {
            return;
        }
        /* _pah8011_read_ppg_fifo: bank 3 from reg 0 (stock: one burst; here
         * 8-byte chunks, each from reg 0) */
        if (wr(REG_BANK, 3)) {
            for (off = 0; off < frames * 4 * PAH_CHANNELS; off += n) {
                n = frames * 4 * PAH_CHANNELS - off;
                n = n > SENSOR_I2C_MAX_XFER ? SENSOR_I2C_MAX_XFER : n;
                if (!rd(0x00, &fifo[off], n)) {
                    frames = 0;
                    break;
                }
            }
        }
        /* FIFO clock off again: bank 1 0x71 = 1, bank 0 0x10 = 0 */
        wr(REG_BANK, 1);
        wr(0x71, 0x01);
        wr(REG_BANK, 0);
        wr(0x10, 0x00);
        if (frames) {
            if (s_touch_in_fifo) {
                touch = fifo[(frames * PAH_CHANNELS - 1) * 4] & 0x01;
            }
            process_samples(fifo, frames, touch);
        }
    } else {
        s_data.touch = touch;
    }
    wr(REG_BANK, 2);
    wr(0x1B, int_req);                          /* clear the interrupt status */
}

/* Power the LED supply and start measuring (stock: pah_ppg1_operate enable). */
static pah_state_t start_measuring(void)
{
    hal_gpio_set_output(PAH_POWER_PIN, HAL_GPIO_DATA_HIGH);
    delay_ms(100);                              /* let the LED supply settle */
    s_bank = 0xFF;                              /* bank register may not survive power-down */
    heart_rate_reset(&s_hr);
    s_since_update = 0;
    return pah_enter_ppg_touch_mode();
}

/* Power the chip down and cut the LED supply (stock: pah_ppg1_operate disable). */
static void stop_measuring(void)
{
    shutdown();
    s_bank = 0xFF;
    hal_gpio_set_output(PAH_POWER_PIN, HAL_GPIO_DATA_LOW);
    taskENTER_CRITICAL();
    s_data.touch = false;
    s_data.bpm_x10[0] = 0;
    s_data.quality[0] = 0;
    taskEXIT_CRITICAL();
}

static void pah_task(void *arg)
{
    pah_state_t st;

    (void)arg;
    heart_rate_reset(&s_hr);
    hal_gpio_set_direction(PAH_POWER_PIN, HAL_GPIO_DIRECTION_OUTPUT);
    hal_gpio_set_output(PAH_POWER_PIN, HAL_GPIO_DATA_LOW);
    vTaskDelay(500 / portTICK_RATE_MS);         /* let the BHI160 upload go first */
    /* pah_init ends with the chip powered down: wait in standby until asked. */
    st = sensor_i2c_init() ? pah_init() : PAH_NO_DEVICE;
    if (st == PAH_RUNNING) {
        st = PAH_STANDBY;
    }
    for (;;) {
        if (st == PAH_STANDBY && s_want_active) {
            st = start_measuring();
        } else if (st == PAH_RUNNING && !s_want_active) {
            stop_measuring();
            st = PAH_STANDBY;
        }
        taskENTER_CRITICAL();
        s_data.state = st;
        taskEXIT_CRITICAL();
        if (st == PAH_RUNNING) {
            poll();
        }
        vTaskDelay(POLL_MS / portTICK_RATE_MS);
    }
}

void pah8011_set_active(bool on)
{
    s_want_active = on;
}

void pah8011_start(void)
{
    xTaskCreate(pah_task, "PAH8011", 1024, NULL, 2, NULL);
}

void pah8011_get(pah_data_t *out)
{
    taskENTER_CRITICAL();
    *out = s_data;
    taskEXIT_CRITICAL();
}

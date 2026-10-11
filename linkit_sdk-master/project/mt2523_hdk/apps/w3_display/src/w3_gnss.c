#include <stdlib.h>
#include <string.h>

#include "FreeRTOS.h"
#include "task.h"
#include "gnss_api.h"
#include "w3_gnss.h"
#include "w3_time.h"

#define POLL_MS        100
#define MAX_FIELDS     24

static w3_gnss_data_t s_data;
static uint8_t s_gsv_max_gp, s_gsv_max_gl;     /* SNR maxima of the GSV round in progress */
static uint8_t s_round_max_gp, s_round_max_gl; /* ... and of the last complete round */
static TickType_t s_version_asked_at;
static TickType_t s_time_aid_at;
static uint8_t s_time_aid_tries;

/* Called by the middleware from the UART/EINT interrupt and from inside
 * gnss_read_sentence(); the task simply polls, so nothing to do here. */
static void gnss_event(gnss_notification_type_t type, void *param)
{
    (void)type;
    (void)param;
}

/* XOR of everything between '$' and '*' must equal the two hex digits after '*'. */
static bool checksum_ok(const char *s)
{
    const char *star = strchr(s, '*');
    uint8_t sum = 0;

    if (s[0] != '$' || !star || !star[1] || !star[2]) {
        return false;
    }
    for (s++; s < star; s++) {
        sum ^= (uint8_t)*s;
    }
    return sum == (uint8_t)strtol(star + 1, NULL, 16);
}

/* Split in place at ',' (the '*checksum' tail is cut off first). */
static int split_fields(char *s, char **f)
{
    int n = 0;
    char *star = strchr(s, '*');

    if (star) {
        *star = 0;
    }
    f[n++] = s;
    for (; *s && n < MAX_FIELDS; s++) {
        if (*s == ',') {
            *s = 0;
            f[n++] = s + 1;
        }
    }
    return n;
}

/* "ddmm.mmmmm" (or "dddmm.mmmmm") plus hemisphere -> degrees x 1e7, integer only. */
static int32_t parse_coord(const char *v, const char *hemi)
{
    const char *dot = strchr(v, '.');
    int32_t whole = atoi(v), frac = 0, scale = 100000, deg, min_e5;
    int digits = 0;

    if (dot) {
        for (dot++; *dot >= '0' && *dot <= '9' && digits < 5; dot++, digits++) {
            frac = frac * 10 + (*dot - '0');
            scale /= 10;
        }
        frac *= scale;                  /* now in 1e-5 minutes */
    }
    deg = whole / 100;
    min_e5 = (whole % 100) * 100000 + frac;
    deg = deg * 10000000 + min_e5 * 10 / 6;     /* minutes / 60 -> degrees */
    return (hemi[0] == 'S' || hemi[0] == 'W') ? -deg : deg;
}

/* "123.4" -> 1234 (one decimal). */
static int32_t parse_x10(const char *v)
{
    const char *dot = strchr(v, '.');
    int32_t x = atoi(v) * 10;

    if (dot && dot[1] >= '0' && dot[1] <= '9') {
        x += (v[0] == '-' ? -1 : 1) * (dot[1] - '0');
    }
    return x;
}

static void parse_time(const char *t)
{
    if (strlen(t) >= 6) {
        s_data.hour = (uint8_t)((t[0] - '0') * 10 + (t[1] - '0'));
        s_data.min = (uint8_t)((t[2] - '0') * 10 + (t[3] - '0'));
        s_data.sec = (uint8_t)((t[4] - '0') * 10 + (t[5] - '0'));
        s_data.time_valid = true;
    }
}

static void copy_line(char *dst, const char *src)
{
    strncpy(dst, src, W3_GNSS_LINE_LEN - 1);
    dst[W3_GNSS_LINE_LEN - 1] = 0;
}

static void handle_sentence(char *line)
{
    char raw[W3_GNSS_LINE_LEN];
    char *f[MAX_FIELDS];
    const char *type;
    int n, i;

    if (!checksum_ok(line)) {
        s_data.bad_checksum++;
        return;
    }
    copy_line(raw, line);
    n = split_fields(line, f);
    type = f[0] + 3;                    /* "$GPRMC" -> "RMC"; talker is f[0][1..2] */
    s_data.sentences++;

    if (strcmp(type, "RMC") == 0 && n >= 10) {
        /* $..RMC,time,status,lat,N,lon,E,speed_kn,course,ddmmyy,... */
        parse_time(f[1]);
        s_data.fix = f[2][0] == 'A';
        if (s_data.fix) {
            s_data.lat_e7 = parse_coord(f[3], f[4]);
            s_data.lon_e7 = parse_coord(f[5], f[6]);
            s_data.speed_kmh_x10 = (uint16_t)(parse_x10(f[7]) * 1852 / 1000);
        }
        if (strlen(f[9]) >= 6) {
            s_data.day = (uint8_t)((f[9][0] - '0') * 10 + (f[9][1] - '0'));
            s_data.month = (uint8_t)((f[9][2] - '0') * 10 + (f[9][3] - '0'));
            s_data.year = (uint8_t)((f[9][4] - '0') * 10 + (f[9][5] - '0'));
        }
        copy_line(s_data.last_rmc, raw);
    } else if (strcmp(type, "GGA") == 0 && n >= 10) {
        /* $..GGA,time,lat,N,lon,E,quality,sats,hdop,alt,M,... */
        s_data.sats_used = (uint8_t)atoi(f[7]);
        s_data.hdop_x10 = (uint16_t)parse_x10(f[8]);
        s_data.alt_dm = parse_x10(f[9]);
        copy_line(s_data.last_gga, raw);
    } else if (strcmp(type, "GSA") == 0 && n >= 3) {
        /* $..GSA,mode,fix_type(1/2/3),prn x12,pdop,hdop,vdop */
        s_data.fix_type = (uint8_t)atoi(f[2]);
    } else if (strcmp(type, "GSV") == 0 && n >= 4) {
        /* $..GSV,total_msgs,msg_num,sats_in_view,{prn,elev,az,snr} x up to 4 */
        bool glonass = f[0][2] == 'L';
        uint8_t *round_max = glonass ? &s_gsv_max_gl : &s_gsv_max_gp;
        int msg = atoi(f[2]), total = atoi(f[1]);

        if (msg == 1) {
            *round_max = 0;
            copy_line(s_data.last_gsv, raw);
        }
        for (i = 7; i < n; i += 4) {
            uint8_t snr = (uint8_t)atoi(f[i]);

            if (snr > *round_max) {
                *round_max = snr;
            }
        }
        if (glonass) {
            s_data.sats_view_glo = (uint8_t)atoi(f[3]);
        } else {
            s_data.sats_view_gps = (uint8_t)atoi(f[3]);
        }
        if (msg == total) {
            if (glonass) {
                s_round_max_gl = *round_max;
            } else {
                s_round_max_gp = *round_max;
            }
            s_data.snr_max = s_round_max_gp > s_round_max_gl ? s_round_max_gp : s_round_max_gl;
        }
    } else if (strcmp(f[0], "$PMTK001") == 0 && n >= 3 && strcmp(f[1], "740") == 0) {
        /* $PMTK001,740,<flag>: acknowledgement of our time aiding, 3 = done */
        s_data.time_aided = atoi(f[2]) == 3;
        copy_line(s_data.last_other, raw);
    } else if (strcmp(f[0], "$PMTK705") == 0) {
        copy_line(s_data.version, raw);
    } else if (strncmp(f[0], "$PMTK", 5) == 0 || strcmp(type, "TXT") == 0) {
        copy_line(s_data.last_other, raw);
    }
}

bool w3_gnss_send_pmtk(const char *body)
{
    static int8_t cmd[200];
    uint8_t sum = 0;
    const char *p;
    int len;

    for (p = body; *p; p++) {
        sum ^= (uint8_t)*p;                     /* NMEA checksum: XOR of the body */
    }
    len = snprintf((char *)cmd, sizeof(cmd), "$%s*%02X\r\n", body, sum);
    if (len <= 0 || len >= (int)sizeof(cmd)) {
        return false;
    }
    if (gnss_send_command(cmd, len) != len) {   /* 0 until the receiver is powered */
        return false;
    }
    taskENTER_CRITICAL();
    s_data.pmtk_sent++;
    taskEXIT_CRITICAL();
    return true;
}

/* Time aiding: tell the receiver the UTC time from our RTC ($PMTK740), so it
 * can predict which satellites are up instead of searching blindly. Only when
 * the RTC holds a real time (set from the PC or GNSS; lost on unplug). Retried
 * every 5 s, up to 6 times, until the receiver acknowledges it. */
static void time_aiding(void)
{
    w3_datetime_t t;
    char body[48];

    if (s_data.time_aided || s_time_aid_tries >= 6 || !w3_time_is_set() ||
        xTaskGetTickCount() - s_time_aid_at < 5000 / portTICK_RATE_MS) {
        return;
    }
    w3_time_get_utc(&t);
    snprintf(body, sizeof(body), "PMTK740,%04u,%02u,%02u,%02u,%02u,%02u", t.year, t.mon, t.day, t.hour, t.min, t.sec);
    w3_gnss_send_pmtk(body);
    s_time_aid_at = xTaskGetTickCount();
    s_time_aid_tries++;
}

static void gnss_task(void *arg)
{
    static int8_t buf[256];
    static char line[256];
    int32_t len;

    (void)arg;
    gnss_init(gnss_event);
    gnss_power_on();
    for (;;) {
        while ((len = gnss_read_sentence(buf, sizeof(buf) - 1)) > 0) {
            /* Strip CR/LF; work on a copy so the snapshot lock stays short. */
            while (len > 0 && (buf[len - 1] == '\r' || buf[len - 1] == '\n')) {
                len--;
            }
            memcpy(line, buf, (size_t)len);
            line[len] = 0;
            taskENTER_CRITICAL();
            handle_sentence(line);
            taskEXIT_CRITICAL();
            /* Ask the MT3333 for its firmware version (reply: $PMTK705,...),
             * every 5 s until it answers: a command sent while the receiver
             * is still starting up is ignored. */
            if (!s_data.version[0] && s_data.sentences > 0 &&
                xTaskGetTickCount() - s_version_asked_at > 5000 / portTICK_RATE_MS) {
                static int8_t cmd[] = "$PMTK605*31\r\n";

                gnss_send_command(cmd, (int32_t)strlen((char *)cmd));
                s_version_asked_at = xTaskGetTickCount();
            }
            /* Same here: start aiding once the receiver has answered something. */
            if (s_data.version[0]) {
                time_aiding();
            }
        }
        vTaskDelay(POLL_MS / portTICK_RATE_MS);
    }
}

void w3_gnss_start(void)
{
    xTaskCreate(gnss_task, "GNSS", 1024, NULL, 2, NULL);
}

void w3_gnss_get(w3_gnss_data_t *out)
{
    taskENTER_CRITICAL();
    *out = s_data;
    taskEXIT_CRITICAL();
}

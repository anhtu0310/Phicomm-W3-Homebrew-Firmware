/*
 * Wall clock for the watch face.
 *
 * The MT2523 RTC keeps running from the PMIC while the CPU sleeps, but the W3
 * has no battery here, so it loses the time whenever USB is unplugged. We keep
 * the RTC in UTC and add a timezone offset for display. The time is set
 * either from the PC (AT+TIME=...) or automatically from GNSS, whose RMC
 * sentences carry UTC once any satellite is tracked (no fix needed).
 */
#ifndef __W3_TIME_H__
#define __W3_TIME_H__

#include <stdbool.h>
#include <stdint.h>

#include "w3_gnss.h"

typedef struct {
    uint16_t year;      /* e.g. 2026 */
    uint8_t mon;        /* 1..12 */
    uint8_t day;        /* 1..31 */
    uint8_t hour, min, sec;
    uint8_t wday;       /* 0 = Sunday .. 6 = Saturday */
} w3_datetime_t;

/* Set the RTC from a UTC date and time. Returns false on invalid input. */
bool w3_time_set_utc(int year, int mon, int day, int hour, int min, int sec);

/* Set / read the RTC as Unix time (seconds since 1970-01-01 UTC). */
bool w3_time_set_unix(uint32_t t);
uint32_t w3_time_get_unix(void);

/* Current UTC / local time from the RTC. */
void w3_time_get_utc(w3_datetime_t *t);
void w3_time_get_local(w3_datetime_t *t);

/* True once the RTC holds a real date (2024..2079), i.e. it was set. */
bool w3_time_is_set(void);

/* Timezone offset in hours, -12..+14 (default +7). Not saved across reboots. */
void w3_time_set_tz(int hours);
int w3_time_get_tz(void);

/* Call about once a second: sets the RTC from GNSS time when GNSS has a real
 * date and the RTC is off by more than 2 s (checked at most once a minute).
 * Returns true when it set the RTC. */
bool w3_time_sync_from_gnss(const w3_gnss_data_t *g);

#endif /* __W3_TIME_H__ */

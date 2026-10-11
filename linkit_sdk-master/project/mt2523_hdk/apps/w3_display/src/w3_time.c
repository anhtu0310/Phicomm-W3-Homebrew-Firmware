#include "FreeRTOS.h"
#include "task.h"
#include "hal.h"
#include "w3_time.h"

#define RTC_BASE_YEAR   2000    /* hal_rtc_time_t.rtc_year counts from here (0..127) */
#define SYNC_PERIOD_MS  60000
#define SYNC_TOLERANCE  2       /* seconds */

static int s_tz_hours = 7;
static TickType_t s_last_sync;
static bool s_synced_once;

/* Days since 1970-01-01 for a proleptic Gregorian date (Howard Hinnant's
 * days_from_civil). Lets us add a timezone offset or compare two times by
 * plain arithmetic instead of handling month lengths and leap years by hand. */
static int32_t days_from_civil(int y, int m, int d)
{
    int32_t era, yoe, doy, doe;

    y -= m <= 2;
    era = (y >= 0 ? y : y - 399) / 400;
    yoe = y - era * 400;                                    /* [0, 399] */
    doy = (153 * (m + (m > 2 ? -3 : 9)) + 2) / 5 + d - 1;   /* [0, 365] */
    doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;            /* [0, 146096] */
    return era * 146097 + doe - 719468;
}

/* The inverse: day number -> year/month/day. */
static void civil_from_days(int32_t z, int *y, int *m, int *d)
{
    int32_t era, doe, yoe, doy, mp;

    z += 719468;
    era = (z >= 0 ? z : z - 146096) / 146097;
    doe = z - era * 146097;
    yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    mp = (5 * doy + 2) / 153;
    *d = doy - (153 * mp + 2) / 5 + 1;
    *m = mp < 10 ? mp + 3 : mp - 9;
    *y = yoe + era * 400 + (*m <= 2);
}

static int64_t to_epoch(const w3_datetime_t *t)
{
    return (int64_t)days_from_civil(t->year, t->mon, t->day) * 86400 + t->hour * 3600 + t->min * 60 + t->sec;
}

static void from_epoch(int64_t s, w3_datetime_t *t)
{
    int32_t days = (int32_t)(s >= 0 ? s / 86400 : (s - 86399) / 86400);
    int32_t rem = (int32_t)(s - (int64_t)days * 86400);
    int y, m, d;

    civil_from_days(days, &y, &m, &d);
    t->year = (uint16_t)y;
    t->mon = (uint8_t)m;
    t->day = (uint8_t)d;
    t->hour = (uint8_t)(rem / 3600);
    t->min = (uint8_t)(rem / 60 % 60);
    t->sec = (uint8_t)(rem % 60);
    t->wday = (uint8_t)((days % 7 + 11) % 7);   /* 1970-01-01 was a Thursday (4) */
}

bool w3_time_set_utc(int year, int mon, int day, int hour, int min, int sec)
{
    hal_rtc_time_t r;
    w3_datetime_t t;

    if (year < RTC_BASE_YEAR || year > RTC_BASE_YEAR + 127 || mon < 1 || mon > 12 || day < 1 || day > 31 ||
        hour < 0 || hour > 23 || min < 0 || min > 59 || sec < 0 || sec > 59) {
        return false;
    }
    from_epoch((int64_t)days_from_civil(year, mon, day) * 86400, &t);   /* only for the weekday */
    r.rtc_year = (uint8_t)(year - RTC_BASE_YEAR);
    r.rtc_mon = (uint8_t)mon;
    r.rtc_day = (uint8_t)day;
    r.rtc_hour = (uint8_t)hour;
    r.rtc_min = (uint8_t)min;
    r.rtc_sec = (uint8_t)sec;
    r.rtc_week = t.wday;
    return hal_rtc_set_time(&r) == HAL_RTC_STATUS_OK;
}

bool w3_time_set_unix(uint32_t s)
{
    w3_datetime_t t;

    from_epoch(s, &t);
    return w3_time_set_utc(t.year, t.mon, t.day, t.hour, t.min, t.sec);
}

uint32_t w3_time_get_unix(void)
{
    w3_datetime_t t;

    w3_time_get_utc(&t);
    return (uint32_t)to_epoch(&t);
}

void w3_time_get_utc(w3_datetime_t *t)
{
    hal_rtc_time_t r;

    if (hal_rtc_get_time(&r) != HAL_RTC_STATUS_OK) {
        r.rtc_year = 0;
        r.rtc_mon = r.rtc_day = 1;
        r.rtc_hour = r.rtc_min = r.rtc_sec = 0;
    }
    t->year = (uint16_t)(RTC_BASE_YEAR + r.rtc_year);
    t->mon = r.rtc_mon;
    t->day = r.rtc_day;
    t->hour = r.rtc_hour;
    t->min = r.rtc_min;
    t->sec = r.rtc_sec;
    t->wday = r.rtc_week;
}

void w3_time_get_local(w3_datetime_t *t)
{
    w3_datetime_t utc;

    w3_time_get_utc(&utc);
    from_epoch(to_epoch(&utc) + (int64_t)s_tz_hours * 3600, t);
}

bool w3_time_is_set(void)
{
    w3_datetime_t t;

    w3_time_get_utc(&t);
    return t.year >= 2024 && t.year < 2080;   /* a cleared RTC can read 2082 */
}

void w3_time_set_tz(int hours)
{
    if (hours >= -12 && hours <= 14) {
        s_tz_hours = hours;
    }
}

int w3_time_get_tz(void)
{
    return s_tz_hours;
}

bool w3_time_sync_from_gnss(const w3_gnss_data_t *g)
{
    w3_datetime_t rtc, gps;
    int64_t diff;

    /* Before the first satellite the receiver counts from 1980-01-05, so only
     * trust a year in 2024..2079 (NMEA has a 2-digit year). */
    if (!g->time_valid || g->year < 24 || g->year >= 80 || g->month < 1 || g->month > 12 || g->day < 1) {
        return false;
    }
    if (s_synced_once && xTaskGetTickCount() - s_last_sync < SYNC_PERIOD_MS / portTICK_RATE_MS) {
        return false;
    }
    gps.year = (uint16_t)(2000 + g->year);
    gps.mon = g->month;
    gps.day = g->day;
    gps.hour = g->hour;
    gps.min = g->min;
    gps.sec = g->sec;
    w3_time_get_utc(&rtc);
    diff = to_epoch(&rtc) - to_epoch(&gps);
    s_last_sync = xTaskGetTickCount();
    s_synced_once = true;
    if (diff >= -SYNC_TOLERANCE && diff <= SYNC_TOLERANCE) {
        return false;
    }
    return w3_time_set_utc(gps.year, gps.mon, gps.day, gps.hour, gps.min, gps.sec);
}

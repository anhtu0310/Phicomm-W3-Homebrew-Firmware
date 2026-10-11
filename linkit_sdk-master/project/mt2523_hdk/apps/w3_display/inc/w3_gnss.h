/*
 * GNSS on the Phicomm W3: the MT2523G's in-package MT3333 (GPS + GLONASS).
 * Power: LDO enable on GPIO10. Data: NMEA at 1 Hz on UART3 (115200 8N1).
 * Uses the SDK's GNSS middleware for power and UART, and parses NMEA here.
 */
#ifndef __W3_GNSS_H__
#define __W3_GNSS_H__

#include <stdbool.h>
#include <stdint.h>

#define W3_GNSS_LINE_LEN 100

typedef struct {
    uint32_t sentences;     /* NMEA sentences with a good checksum */
    uint32_t bad_checksum;
    bool time_valid;        /* the receiver has UTC time (it can come before a fix) */
    uint8_t hour, min, sec;
    uint8_t day, month, year;   /* year: 2-digit */
    bool fix;               /* RMC status A */
    uint8_t fix_type;       /* GSA: 1 = none, 2 = 2D, 3 = 3D */
    uint8_t sats_used;      /* GGA */
    uint8_t sats_view_gps;  /* GSV, talker GP */
    uint8_t sats_view_glo;  /* GSV, talker GL */
    uint8_t snr_max;        /* best C/N0 seen in the last GSV round, dB-Hz */
    int32_t lat_e7;         /* degrees x 1e7, north positive */
    int32_t lon_e7;         /* degrees x 1e7, east positive */
    int32_t alt_dm;         /* altitude above mean sea level, decimetres */
    uint16_t hdop_x10;
    uint16_t speed_kmh_x10;
    char last_rmc[W3_GNSS_LINE_LEN];
    char last_gga[W3_GNSS_LINE_LEN];
    char last_gsv[W3_GNSS_LINE_LEN];    /* first GSV message of the last round */
    char version[W3_GNSS_LINE_LEN];     /* $PMTK705 reply: receiver firmware */
    char last_other[W3_GNSS_LINE_LEN];  /* other PMTK replies and TXT messages */
    bool time_aided;                    /* receiver acknowledged $PMTK740 (time aiding) */
    uint32_t pmtk_sent;                 /* PMTK commands sent with w3_gnss_send_pmtk() */
} w3_gnss_data_t;

/* Power the receiver on and start the reader task. */
void w3_gnss_start(void);

/* Send one PMTK command. body is the part between '$' and '*', e.g.
 * "PMTK605"; the checksum and CR/LF are added here. Returns false if the
 * receiver is not powered yet or its UART buffer is full (then retry).
 * Replies ($PMTK001,<cmd>,<flag>: 3 = OK) show up in last_other. */
bool w3_gnss_send_pmtk(const char *body);

/* Snapshot of the latest values (copied, safe from any task). */
void w3_gnss_get(w3_gnss_data_t *out);

#endif /* __W3_GNSS_H__ */

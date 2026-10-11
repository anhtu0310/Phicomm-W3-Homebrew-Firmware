/*
 * PixArt PAH8011 PPG (optical heart-rate) sensor on I2C0, address 0x15.
 *
 * A port of the stock W3 firmware's driver (v1008, reg table v1006),
 * reconstructed from the binary; PixArt's open driver
 * (github.com/PixartOpen/pah8011-qcom-adsp-driver) was the guide to reading
 * it. PPG at 20 Hz on channel B only, read by polling. Heart rate is computed
 * here (heart_rate.c), since PixArt's own algorithm is a closed library.
 */
#ifndef __PAH8011_H__
#define __PAH8011_H__

#include <stdbool.h>
#include <stdint.h>

#define PAH_CHANNELS        1       /* PPG channels in the FIFO (B only, per the stock table) */
#define PAH_BATCH           16      /* last samples kept for logging */
#define PAH_WAVE_LEN        60      /* detrended samples kept for the display (3 s) */

typedef enum {
    PAH_OFF = 0,
    PAH_NO_DEVICE,          /* product ID is not 0x11 */
    PAH_INIT_ERROR,
    PAH_RUNNING,            /* measuring: LED powered, PPG sampling */
    PAH_STANDBY,            /* initialised but powered down, LED off (see pah8011_set_active) */
} pah_state_t;

typedef struct {
    pah_state_t state;
    uint8_t product_id;
    bool touch;                         /* skin contact, from the sensor */
    uint32_t batches;                   /* FIFO reads with data */
    uint32_t overflows;
    uint16_t fifo_count;                /* bank 2 0x25 at the last poll */
    uint8_t batch_len;                  /* samples in batch[] */
    uint32_t batch[PAH_CHANNELS][PAH_BATCH];    /* last raw samples */
    uint16_t bpm_x10[PAH_CHANNELS];     /* heart rate per channel, 0 = none */
    uint8_t quality[PAH_CHANNELS];      /* autocorrelation peak, 0..100 */
    uint8_t best;                       /* channel shown (always 0 = B) */
    float wave[PAH_WAVE_LEN];           /* detrended signal, oldest first */
} pah_data_t;

void pah8011_start(void);

/* Measure only while needed: true powers the LED (GPIO48) and starts PPG,
 * false powers the chip down and switches the LED supply off. The task applies
 * the request within one poll (50 ms). Starts inactive. */
void pah8011_set_active(bool on);

/* Snapshot of the latest values (copied, safe from any task). */
void pah8011_get(pah_data_t *out);

#endif /* __PAH8011_H__ */

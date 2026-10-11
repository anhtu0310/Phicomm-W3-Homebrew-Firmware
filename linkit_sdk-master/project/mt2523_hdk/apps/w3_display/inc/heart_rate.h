/*
 * Heart rate from a PPG (photoplethysmogram) signal by autocorrelation.
 *
 * Each heartbeat pushes blood into the skin, which changes how much LED light
 * returns to the sensor, so the PPG signal repeats once per beat. Over the
 * last few seconds we look for the time shift (lag) at which the signal best
 * matches itself; that lag is the beat period.
 */
#ifndef __HEART_RATE_H__
#define __HEART_RATE_H__

#include <stdbool.h>
#include <stdint.h>

#define HR_RATE_HZ      20          /* PPG sample rate */
#define HR_WINDOW       160         /* analysis window: 8 s */

typedef struct {
    int32_t raw[HR_WINDOW];         /* ring buffer of raw samples */
    uint32_t count;                 /* samples received in total */
    float clean[HR_WINDOW];         /* last detrended window, oldest first */
    uint16_t bpm_x10;               /* last accepted estimate, 0 = none */
    uint8_t quality;                /* autocorrelation peak, 0..100 */
} heart_rate_t;

void heart_rate_reset(heart_rate_t *hr);

/* Add samples (oldest first). */
void heart_rate_push(heart_rate_t *hr, const int32_t *samples, uint32_t n);

/* Recompute from the current window. Returns true if a beat period with a
 * quality of at least min_quality was found (bpm_x10 is then updated). */
bool heart_rate_update(heart_rate_t *hr, uint8_t min_quality);

#endif /* __HEART_RATE_H__ */

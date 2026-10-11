#include <string.h>

#include "heart_rate.h"

#define DETREND_HALF    7           /* moving average over 15 samples (0.75 s) */
#define LAG_MIN         7           /* 20 Hz * 60 / 7  = 171 bpm */
#define LAG_MAX         30          /* 20 Hz * 60 / 30 =  40 bpm */

void heart_rate_reset(heart_rate_t *hr)
{
    memset(hr, 0, sizeof(*hr));
}

void heart_rate_push(heart_rate_t *hr, const int32_t *samples, uint32_t n)
{
    uint32_t i;

    for (i = 0; i < n; i++) {
        hr->raw[hr->count % HR_WINDOW] = samples[i];
        hr->count++;
    }
}

/* Copy the window out oldest-first and subtract a moving average, which
 * removes the large constant level and slow drift (breathing, pressure) and
 * keeps the faster pulse wave. */
static void detrend(heart_rate_t *hr, float *out)
{
    float x[HR_WINDOW];
    uint32_t i, start = hr->count - HR_WINDOW;
    int j, lo, hi;

    for (i = 0; i < HR_WINDOW; i++) {
        x[i] = (float)hr->raw[(start + i) % HR_WINDOW];
    }
    for (i = 0; i < HR_WINDOW; i++) {
        float sum = 0.0f;

        lo = (int)i - DETREND_HALF < 0 ? 0 : (int)i - DETREND_HALF;
        hi = (int)i + DETREND_HALF >= HR_WINDOW ? HR_WINDOW - 1 : (int)i + DETREND_HALF;
        for (j = lo; j <= hi; j++) {
            sum += x[j];
        }
        out[i] = x[i] - sum / (float)(hi - lo + 1);
    }
}

/* Normalised autocorrelation at one lag: 1.0 = identical, 0 = unrelated. */
static float autocorr(const float *x, int lag)
{
    float num = 0.0f, e0 = 0.0f, e1 = 0.0f;
    int i;

    for (i = 0; i + lag < HR_WINDOW; i++) {
        num += x[i] * x[i + lag];
        e0 += x[i] * x[i];
        e1 += x[i + lag] * x[i + lag];
    }
    if (e0 <= 0.0f || e1 <= 0.0f) {
        return 0.0f;
    }
    return num / __builtin_sqrtf(e0 * e1);
}

bool heart_rate_update(heart_rate_t *hr, uint8_t min_quality)
{
    float r[LAG_MAX + 2];
    float best = 0.0f, lag, d;
    int k, best_k = 0;

    if (hr->count < HR_WINDOW) {
        return false;
    }
    detrend(hr, hr->clean);
    for (k = LAG_MIN - 1; k <= LAG_MAX + 1; k++) {
        r[k] = autocorr(hr->clean, k);
    }
    /* The first strong local maximum is the beat period (later peaks are
     * multiples of it). */
    for (k = LAG_MIN; k <= LAG_MAX; k++) {
        if (r[k] > r[k - 1] && r[k] >= r[k + 1] && r[k] > best) {
            best = r[k];
            best_k = k;
            if (best * 100.0f >= (float)min_quality) {
                break;
            }
        }
    }
    hr->quality = best > 0.0f ? (uint8_t)(best * 100.0f) : 0;
    if (best_k == 0 || hr->quality < min_quality) {
        return false;
    }
    /* At 20 Hz one lag step is a big jump (10 vs 11 samples = 120 vs 109
     * bpm), so fit a parabola through the three points around the peak. */
    d = r[best_k - 1] - 2.0f * r[best_k] + r[best_k + 1];
    lag = (float)best_k + (d < 0.0f ? 0.5f * (r[best_k - 1] - r[best_k + 1]) / d : 0.0f);
    hr->bpm_x10 = (uint16_t)(600.0f * (float)HR_RATE_HZ / lag);
    return true;
}

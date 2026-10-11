#include <string.h>

#include "cy8c_touch.h"
#include "touch_slider.h"

/* Window layout of the patched touch firmware: the 14-byte app buffer, then
 * the CapSense data RAM. Each slider electrode has raw count u16, baseline
 * u16, ... (14 bytes); we only use the raw counts. */
#define WINDOW_LEN        0x6A            /* through electrode 2's raw count */
#define CHIP_VERSION_OFF  3
static const uint8_t s_electrode_off[3] = {0x4A, 0x58, 0x66};

/* Thresholds in raw counts, from logs of this unit (2026-10-11). A finger gives
 * 1500-2000 on the electrode under it. Idle noise is about +-70 on the top
 * electrode (it alternates between two levels) and +-10 on the others. */
#define TOUCH_ON          400             /* sum of signals to start a touch */
#define TOUCH_OFF         250             /* ... and to end it */
#define DRIFT_LIMIT       150             /* baseline only follows changes below this */
#define RESYNC_UPDATES    20              /* idle updates out of range before resync */
static const int16_t s_noise_floor[3] = {120, 25, 25};

/* Centroid range seen at the top and bottom edges of the glass, mapped to
 * screen rows 0 and 143. */
#define POS_TOP           10
#define POS_BOTTOM        141

static int32_t s_baseline[3];             /* raw count x 16 */
static bool s_have_baseline;
static uint8_t s_out_of_range;

static void update_baseline(const uint16_t *raw, const int16_t *d)
{
    int i;
    bool in_range = true;

    for (i = 0; i < 3; i++) {
        if (d[i] > DRIFT_LIMIT || d[i] < -DRIFT_LIMIT) {
            in_range = false;
        }
    }
    if (in_range) {
        /* Slow IIR (1/8 per update) to follow temperature drift. */
        for (i = 0; i < 3; i++) {
            s_baseline[i] += ((int32_t)raw[i] * 16 - s_baseline[i]) / 8;
        }
        s_out_of_range = 0;
    } else if (++s_out_of_range >= RESYNC_UPDATES) {
        /* Not touched, yet off by a lot for a while (e.g. it shifted while a
         * finger was down): start over from the current counts. */
        for (i = 0; i < 3; i++) {
            s_baseline[i] = (int32_t)raw[i] * 16;
        }
        s_out_of_range = 0;
    }
}

bool touch_slider_update(touch_slider_t *t)
{
    uint8_t b[WINDOW_LEN];
    int32_t w[3], sum, pos;
    int i;

    if (!cy8c_touch_read_reg(0x0000, b, sizeof(b))) {
        return false;
    }
    t->chip_pos = b[0];
    t->chip_status = b[1];
    for (i = 0; i < 3; i++) {
        t->raw[i] = (uint16_t)(b[s_electrode_off[i]] | (b[s_electrode_off[i] + 1] << 8));
    }
    if (b[CHIP_VERSION_OFF] != 0x18 || t->raw[0] == 0xFFFF) {
        return false;                     /* stock touch firmware: no electrode data */
    }
    if (!s_have_baseline) {
        for (i = 0; i < 3; i++) {
            s_baseline[i] = (int32_t)t->raw[i] * 16;
        }
        s_have_baseline = true;
    }

    sum = 0;
    for (i = 0; i < 3; i++) {
        t->d[i] = (int16_t)(t->raw[i] - s_baseline[i] / 16);
        /* Ignore noise and negative signals (a finger near the bottom pulls
         * the top electrode slightly below its baseline). */
        w[i] = t->d[i] > s_noise_floor[i] ? t->d[i] : 0;
        sum += w[i];
    }

    if (t->down ? sum < TOUCH_OFF : sum >= TOUCH_ON) {
        t->down = !t->down;
    }
    if (!t->down) {
        update_baseline(t->raw, t->d);
        return true;
    }

    /* Centroid: electrode centres sit at 0, 72 and 144 slider units. */
    pos = 72 * (w[1] + 2 * w[2]) / sum;
    t->pos = (uint16_t)pos;
    pos = (pos - POS_TOP) * 143 / (POS_BOTTOM - POS_TOP);
    t->row = (uint8_t)(pos < 0 ? 0 : pos > 143 ? 143 : pos);
    return true;
}

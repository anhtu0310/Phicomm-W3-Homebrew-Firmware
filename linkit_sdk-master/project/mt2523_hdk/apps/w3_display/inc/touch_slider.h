/*
 * Touch slider position computed on the MT2523 from the CY8C4014's raw
 * electrode counts (needs the patched touch firmware 0x18, see HARDWARE.md).
 *
 * The touch chip's own position clamps to 143 over the bottom part of the
 * screen: its baseline creeps up under a resting finger, so the middle
 * electrode's fading signal falls below its noise threshold. Here each
 * electrode gets a baseline that is frozen while touched, and the position is
 * the centroid of all three signals, which keeps changing down to the edge.
 */
#ifndef __TOUCH_SLIDER_H__
#define __TOUCH_SLIDER_H__

#include <stdbool.h>
#include <stdint.h>

typedef struct {
    bool down;              /* our touch detection */
    uint8_t row;            /* screen row 0 (top) .. 143 (bottom), valid while down */
    uint16_t pos;           /* centroid in slider units, 0 .. 144 */
    int16_t d[3];           /* signal vs our baseline: top, middle, bottom electrode */
    uint16_t raw[3];
    uint8_t chip_pos;       /* the touch chip's own position (255 = none) */
    uint8_t chip_status;    /* 3 = chip sees a touch, 2 = idle */
} touch_slider_t;

/* Read the touch chip and update t. Returns false on an I2C error or when the
 * touch firmware does not expose electrode data (stock firmware). */
bool touch_slider_update(touch_slider_t *t);

#endif /* __TOUCH_SLIDER_H__ */

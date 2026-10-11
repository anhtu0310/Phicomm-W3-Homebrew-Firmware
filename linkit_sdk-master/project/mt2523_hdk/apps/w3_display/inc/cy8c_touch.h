/*
 * Cypress CY8C4014 (PSoC 4) touch strip on the Phicomm W3.
 *
 * Protocol recovered from the stock firmware (see HARDWARE.md):
 *   Bit-banged I2C on GPIO19 (SCL) / GPIO20 (SDA), slave address 0x08
 *   (the stock firmware does not use the I2C2 hardware block).
 *   Event:   write 00 00, read up to 14 bytes (the whole EZI2C buffer)
 *            [0] position 0..144 (FF = none)  [1] 3 = touching, 2 = idle
 *            [2] direction 1 = down / 2 = up  [3] fw version (0x19)
 *            [4] command / reply              [5] active electrodes (3 = large)
 *            [6..7] top electrode raw  [8..9] its baseline
 *            [10..11] finger threshold  [12..13] swim-mode finger threshold
 *   Command: write 00 04 <cmd>, read 1 byte, expect <cmd> + 1
 *            0x65 enter deep sleep, 0x67 exit deep sleep, 0x41 soft reset,
 *            0x69 reset baselines (replies 0x70)
 *   The slider has only 3 electrodes, so the bottom strip reads as 143/144.
 */
#ifndef __CY8C_TOUCH_H__
#define __CY8C_TOUCH_H__

#include <stdbool.h>
#include <stdint.h>

typedef struct {
    uint8_t raw[6];
    uint8_t position;
    bool down;
    uint8_t version;
    uint8_t keys;
} cy8c_touch_event_t;

/* Returns true when the controller answered the wake-up command. */
bool cy8c_touch_init(void);
bool cy8c_touch_read(cy8c_touch_event_t *ev);
bool cy8c_touch_command(uint8_t cmd);
/* Write a 16-bit register address, then read len bytes. */
bool cy8c_touch_read_reg(uint16_t reg, uint8_t *buf, uint32_t len);
/* Plain I2C transfers to address 0x08 with no register prefix. The chip's
 * Cypress bootloader (entered with command 0xA5) speaks raw packets. */
bool cy8c_touch_raw_write(const uint8_t *buf, uint32_t len);
bool cy8c_touch_raw_read(uint8_t *buf, uint32_t len);
/* Idle bus levels for diagnostics: bit1 = SCL, bit0 = SDA (both 1 when idle). */
uint8_t cy8c_touch_bus_levels(void);

#endif /* __CY8C_TOUCH_H__ */

/*
 * JDI LPM009M360A colour memory-in-pixel LCD (72x144, 8 colours) driver
 * for the Phicomm W3 (MT2523G).
 *
 * Wiring (recovered from the stock firmware, see HARDWARE.md):
 *   SCLK      GPIO40  MA_SPI2_B_SCK   (HAL_SPI_MASTER_2)
 *   SI        GPIO41  MA_SPI2_B_MOSI
 *   SCS       GPIO39  GPIO, active high, driven by software
 *   DISP      GPIO15  GPIO, high = display on
 *   EXTCOMIN  GPIO11  PWM0
 *   VDD       PMIC VMC LDO, 2.8 V
 *
 * Protocol follows https://github.com/Gbertaz/JDI_MIP_Display (4-bit update
 * mode, 2 pixels per byte, nibble = R G B x) and the stock driver's framing.
 */
#ifndef __JDI_LCD_H__
#define __JDI_LCD_H__

#include <stdbool.h>
#include <stdint.h>

#define JDI_WIDTH   72
#define JDI_HEIGHT  144

/* 3-bit colours, stored in the upper 3 bits of a nibble (R=8, G=4, B=2). */
#define JDI_BLACK   0x0
#define JDI_BLUE    0x2
#define JDI_GREEN   0x4
#define JDI_CYAN    0x6
#define JDI_RED     0x8
#define JDI_MAGENTA 0xA
#define JDI_YELLOW  0xC
#define JDI_WHITE   0xE

void jdi_lcd_init(void);
void jdi_lcd_display_on(bool on);
void jdi_lcd_all_clear(void);

void jdi_lcd_fill(uint8_t color);
void jdi_lcd_set_pixel(int x, int y, uint8_t color);
void jdi_lcd_fill_rect(int x, int y, int w, int h, uint8_t color);
/* Draws ASCII text with the built-in 5x7 font; scale >= 1. Returns end x. */
int jdi_lcd_draw_text(int x, int y, const char *s, uint8_t fg, uint8_t bg, int scale);

/* Sends changed lines to the panel (all lines if force). */
void jdi_lcd_flush(bool force);

#endif /* __JDI_LCD_H__ */

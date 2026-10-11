#include <string.h>

#include "hal.h"
#include "cy8c_touch.h"

/* The stock firmware talks to the CY8C4014 with a bit-banged I2C master on
 * GPIO19 (SCL) / GPIO20 (SDA), not the I2C2 hardware block, so do the same.
 * Lines are open-drain: drive low = output 0, release high = input (the board
 * has external pull-ups). */
#define PIN_SCL          HAL_GPIO_19
#define PIN_SDA          HAL_GPIO_20
#define TOUCH_I2C_ADDR   0x08
#define HALF_PERIOD_US   5                /* ~100 kHz */
#define TOUCH_RETRIES    10

#define CMD_EXIT_SLEEP   0x67

static void line_low(hal_gpio_pin_t pin)
{
    hal_gpio_set_output(pin, HAL_GPIO_DATA_LOW);
    hal_gpio_set_direction(pin, HAL_GPIO_DIRECTION_OUTPUT);
}

static void line_release(hal_gpio_pin_t pin)
{
    hal_gpio_set_direction(pin, HAL_GPIO_DIRECTION_INPUT);
}

static int line_read(hal_gpio_pin_t pin)
{
    hal_gpio_data_t v = HAL_GPIO_DATA_LOW;

    hal_gpio_get_input(pin, &v);
    return v == HAL_GPIO_DATA_HIGH;
}

static void scl_high(void)
{
    int wait = 100;

    line_release(PIN_SCL);
    /* Allow clock stretching by the PSoC. */
    while (!line_read(PIN_SCL) && --wait) {
        hal_gpt_delay_us(1);
    }
    hal_gpt_delay_us(HALF_PERIOD_US);
}

static void i2c_start(void)
{
    line_release(PIN_SDA);
    scl_high();
    line_low(PIN_SDA);
    hal_gpt_delay_us(HALF_PERIOD_US);
    line_low(PIN_SCL);
}

static void i2c_stop(void)
{
    line_low(PIN_SDA);
    hal_gpt_delay_us(HALF_PERIOD_US);
    scl_high();
    line_release(PIN_SDA);
    hal_gpt_delay_us(HALF_PERIOD_US);
}

/* Returns true if the slave ACKed. */
static bool i2c_write_byte(uint8_t b)
{
    int i;
    bool ack;

    for (i = 7; i >= 0; i--) {
        if (b & (1 << i)) {
            line_release(PIN_SDA);
        } else {
            line_low(PIN_SDA);
        }
        hal_gpt_delay_us(HALF_PERIOD_US);
        scl_high();
        line_low(PIN_SCL);
    }
    line_release(PIN_SDA);
    hal_gpt_delay_us(HALF_PERIOD_US);
    scl_high();
    ack = !line_read(PIN_SDA);
    line_low(PIN_SCL);
    return ack;
}

static uint8_t i2c_read_byte(bool ack)
{
    uint8_t b = 0;
    int i;

    line_release(PIN_SDA);
    for (i = 0; i < 8; i++) {
        hal_gpt_delay_us(HALF_PERIOD_US);
        scl_high();
        b = (uint8_t)((b << 1) | line_read(PIN_SDA));
        line_low(PIN_SCL);
    }
    if (ack) {
        line_low(PIN_SDA);
    }
    hal_gpt_delay_us(HALF_PERIOD_US);
    scl_high();
    line_low(PIN_SCL);
    line_release(PIN_SDA);
    return b;
}

static bool i2c_xfer_write(const uint8_t *buf, uint32_t len)
{
    bool ok;
    uint32_t i;

    i2c_start();
    ok = i2c_write_byte(TOUCH_I2C_ADDR << 1);
    for (i = 0; ok && i < len; i++) {
        ok = i2c_write_byte(buf[i]);
    }
    i2c_stop();
    return ok;
}

static bool i2c_xfer_read(uint8_t *buf, uint32_t len)
{
    uint32_t i;

    i2c_start();
    if (!i2c_write_byte((TOUCH_I2C_ADDR << 1) | 1)) {
        i2c_stop();
        return false;
    }
    for (i = 0; i < len; i++) {
        buf[i] = i2c_read_byte(i + 1 < len);
    }
    i2c_stop();
    return true;
}

static bool i2c_send(const uint8_t *buf, uint32_t len)
{
    int i;

    for (i = 0; i < TOUCH_RETRIES; i++) {
        if (i2c_xfer_write(buf, len)) {
            return true;
        }
        hal_gpt_delay_ms(2);
    }
    return false;
}

static bool i2c_recv(uint8_t *buf, uint32_t len)
{
    int i;

    for (i = 0; i < TOUCH_RETRIES; i++) {
        if (i2c_xfer_read(buf, len)) {
            return true;
        }
        hal_gpt_delay_ms(2);
    }
    return false;
}

bool cy8c_touch_command(uint8_t cmd)
{
    const uint8_t buf[3] = {0x00, 0x04, cmd};
    uint8_t ack = 0;
    int tries;

    /* The stock driver retries up to 21 times, polling for cmd + 1. */
    for (tries = 0; tries < 21; tries++) {
        if (i2c_send(buf, sizeof(buf))) {
            hal_gpt_delay_ms(1);
            if (i2c_recv(&ack, 1) && ack == (uint8_t)(cmd + 1)) {
                return true;
            }
        }
        hal_gpt_delay_ms(4);
    }
    return false;
}

bool cy8c_touch_init(void)
{
    hal_gpio_init(PIN_SCL);
    hal_gpio_init(PIN_SDA);
    hal_pinmux_set_function(PIN_SCL, 0);
    hal_pinmux_set_function(PIN_SDA, 0);
    line_release(PIN_SCL);
    line_release(PIN_SDA);
    hal_gpt_delay_ms(1);
    return cy8c_touch_command(CMD_EXIT_SLEEP);
}

bool cy8c_touch_read_reg(uint16_t reg, uint8_t *buf, uint32_t len)
{
    const uint8_t addr[2] = {(uint8_t)(reg >> 8), (uint8_t)reg};

    return i2c_send(addr, sizeof(addr)) && i2c_recv(buf, len);
}

bool cy8c_touch_raw_write(const uint8_t *buf, uint32_t len)
{
    return i2c_send(buf, len);
}

bool cy8c_touch_raw_read(uint8_t *buf, uint32_t len)
{
    return i2c_recv(buf, len);
}

bool cy8c_touch_read(cy8c_touch_event_t *ev)
{
    static const uint8_t reg[2] = {0x00, 0x00};

    memset(ev, 0, sizeof(*ev));
    if (!i2c_send(reg, sizeof(reg)) || !i2c_recv(ev->raw, sizeof(ev->raw))) {
        return false;
    }
    ev->position = ev->raw[0];
    ev->down = ev->raw[1] == 1 || ev->raw[1] == 3;
    ev->version = ev->raw[3];
    ev->keys = ev->raw[5];
    return true;
}

uint8_t cy8c_touch_bus_levels(void)
{
    line_release(PIN_SCL);
    line_release(PIN_SDA);
    hal_gpt_delay_us(HALF_PERIOD_US);
    return (uint8_t)((line_read(PIN_SCL) << 1) | line_read(PIN_SDA));
}

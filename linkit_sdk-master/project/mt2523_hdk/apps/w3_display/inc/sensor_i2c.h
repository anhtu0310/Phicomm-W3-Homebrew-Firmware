/*
 * I2C0, the sensor bus (BHI160 at 0x28, PAH8011 at 0x15), 400 kHz.
 * Shared by several tasks, so every transfer takes a mutex. Polling transfers
 * only: the HAL's DMA path was slow and corrupted longer writes on this board.
 */
#ifndef __SENSOR_I2C_H__
#define __SENSOR_I2C_H__

#include <stdbool.h>
#include <stdint.h>

#include "hal.h"

/* Bytes per polling transaction (register byte included for writes). */
#define SENSOR_I2C_MAX_XFER HAL_I2C_MAXIMUM_POLLING_TRANSACTION_SIZE

/* Call once before the sensor tasks start. */
bool sensor_i2c_init(void);

/* Write len (<= SENSOR_I2C_MAX_XFER - 1) bytes starting at register reg. */
bool sensor_i2c_write(uint8_t addr, uint8_t reg, const uint8_t *data, uint32_t len);

/* Read len (<= SENSOR_I2C_MAX_XFER) bytes starting at register reg. */
bool sensor_i2c_read(uint8_t addr, uint8_t reg, uint8_t *data, uint32_t len);

#endif /* __SENSOR_I2C_H__ */

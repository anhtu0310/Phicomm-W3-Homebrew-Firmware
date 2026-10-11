#include <string.h>

#include "FreeRTOS.h"
#include "semphr.h"
#include "sensor_i2c.h"

#define SENSOR_I2C_PORT HAL_I2C_MASTER_0

static SemaphoreHandle_t s_lock;
static bool s_ready;

bool sensor_i2c_init(void)
{
    hal_i2c_config_t config;

    if (s_ready) {
        return true;
    }
    s_lock = xSemaphoreCreateMutex();
    config.frequency = HAL_I2C_FREQUENCY_400K;
    s_ready = s_lock && hal_i2c_master_init(SENSOR_I2C_PORT, &config) == HAL_I2C_STATUS_OK;
    return s_ready;
}

bool sensor_i2c_write(uint8_t addr, uint8_t reg, const uint8_t *data, uint32_t len)
{
    uint8_t buf[SENSOR_I2C_MAX_XFER];
    bool ok;

    if (!s_ready || len + 1 > sizeof(buf)) {
        return false;
    }
    buf[0] = reg;
    memcpy(&buf[1], data, len);
    xSemaphoreTake(s_lock, portMAX_DELAY);
    ok = hal_i2c_master_send_polling(SENSOR_I2C_PORT, addr, buf, len + 1) == HAL_I2C_STATUS_OK;
    xSemaphoreGive(s_lock);
    return ok;
}

bool sensor_i2c_read(uint8_t addr, uint8_t reg, uint8_t *data, uint32_t len)
{
    hal_i2c_send_to_receive_config_t config;
    bool ok;

    if (!s_ready || len > SENSOR_I2C_MAX_XFER) {
        return false;
    }
    config.slave_address = addr;
    config.send_data = &reg;
    config.send_length = 1;
    config.receive_buffer = data;
    config.receive_length = len;
    xSemaphoreTake(s_lock, portMAX_DELAY);
    ok = hal_i2c_master_send_to_receive_polling(SENSOR_I2C_PORT, &config) == HAL_I2C_STATUS_OK;
    xSemaphoreGive(s_lock);
    return ok;
}

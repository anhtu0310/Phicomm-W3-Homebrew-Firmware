/*
 * Bosch BHI160 sensor hub (BMI160 accel + gyro and a Fuser MCU) on I2C0, 0x28.
 *
 * The hub boots from ROM and needs a RAM patch uploaded by the host on every
 * power-up; after that it runs "virtual sensors" (accelerometer, gyroscope,
 * step counter, ...) and pushes their samples into a FIFO the host drains.
 * Register map and upload/config sequences follow Bosch's BHy1 driver
 * (github.com/boschsensortec/BoschSensorHub).
 */
#ifndef __BHI160_H__
#define __BHI160_H__

#include <stdbool.h>
#include <stdint.h>

#define BHI160_INFO_LEN 16  /* bytes in a sensor information block */

typedef enum {
    BHI160_OFF = 0,
    BHI160_NO_DEVICE,       /* product ID did not read as 0x83 */
    BHI160_BAD_ROM,         /* ROM version does not match the RAM patch */
    BHI160_CRC_ERROR,       /* uploaded patch CRC mismatch */
    BHI160_NO_BOOT,         /* no "initialized" meta event after the upload */
    BHI160_CONFIG_ERROR,    /* a virtual sensor was not accepted */
    BHI160_RUNNING,
} bhi160_state_t;

typedef struct {
    bhi160_state_t state;
    uint8_t product_id;
    uint16_t rom_version;
    uint16_t ram_version;
    int16_t acc_mg[3];      /* accelerometer, milli-g (range +-4 g) */
    int16_t gyro_dps[3];    /* gyroscope, degrees per second (range +-2000) */
    int16_t acc_raw[3];     /* last raw accelerometer sample: 8192 LSB/g (+-4 g) */
    int16_t gyro_raw[3];    /* last raw gyroscope sample: 32768 / 2000 = 16.4 LSB per deg/s */
    uint8_t acc_accuracy;   /* 0..3 status byte of the last accelerometer sample */
    uint16_t steps;         /* pedometer: first 16-bit value of sensor 29's payload (to be confirmed) */
    uint32_t pedo_events;   /* events received from the pedometer (sensor 29) */
    uint8_t pedo_len;       /* payload bytes in pedo_raw */
    uint8_t pedo_raw[16];   /* last pedometer payload, raw, for decoding */
    bool info_ready;        /* sensor information blocks have been read */
    uint32_t samples;       /* accelerometer samples received */
    uint32_t gyro_samples;  /* gyroscope samples received */
    int32_t angle_mdeg[3];  /* gyroscope integrated since the last reset, milli-degrees */
    uint32_t meta_events;   /* meta events received (errors, rate changes, ...) */
    uint8_t last_meta[3];   /* last meta event: type, sensor ID, value */
    uint32_t crc_expected;  /* RAM patch CRC from its header */
    uint32_t crc_device;    /* CRC the hub computed over what it received */
    uint8_t cfg_ack[3];     /* config acknowledge for accel, gyro, pedometer (C1, C4, DD = OK) */
} bhi160_data_t;

/* Start the sensor task: upload the RAM patch, read the list of virtual
 * sensors it provides, enable the accelerometer, gyroscope and the W3
 * pedometer (custom sensor 29), then poll the FIFO. */
void bhi160_start(void);

/* Copy the 16-byte sensor information block of virtual sensor id (1..31), as
 * read from the hub at boot. Returns false if it could not be read. */
bool bhi160_get_sensor_info(uint8_t id, uint8_t *info);

/* Zero the integrated gyroscope angles. */
void bhi160_reset_angles(void);

/* Snapshot of the latest values (copied, safe from any task). */
void bhi160_get(bhi160_data_t *out);

#endif /* __BHI160_H__ */

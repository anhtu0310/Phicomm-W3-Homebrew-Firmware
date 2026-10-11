/*
 * Bluetooth LE peripheral: advertises as "W3 band" and serves one custom GATT
 * service for time sync, an IMU stream and text notifications.
 *
 * Stack: MediaTek's prebuilt BLE host (libble.a) + MT2523 controller driver
 * (libbtdriver_2523.a, the same one the stock firmware links). The host runs
 * in the SDK's bt_task; it calls back into this module for events
 * (bt_app_event_callback) and for the attribute table (bt_get_gatt_server).
 * Nothing is stored in NVDM: the address is fixed (the stock one) and pairing
 * keys are kept in RAM only.
 *
 * W3 service, UUID 57330001-9c1e-4b8e-a0f3-1c5e9b7d3a42. Characteristics share
 * the base and differ in the 16-bit field (5733xxxx):
 *
 *   0002 Time    read/write  u32 Unix time UTC (LE), optional i8 timezone hours.
 *                            A read returns the same 5 bytes.
 *   0003 IMU     notify/read 16 bytes, all LE: u16 sample counter, i16 acc x,y,z
 *                            raw (8192 LSB/g), i16 gyro x,y,z raw (16.4 LSB per deg/s),
 *                            u16 milliseconds since boot (wraps).
 *                write       u8 rate in Hz (1..25, default 10; 0 = paused).
 *   0004 Notify  write       UTF-8 text, up to W3_BLE_MSG_MAX bytes: shown on the
 *                            screen with the stock double buzz.
 */
#ifndef __W3_BLE_H__
#define __W3_BLE_H__

#include <stdbool.h>
#include <stdint.h>

#define W3_BLE_NAME     "W3 band"
#define W3_BLE_MSG_MAX  120

typedef enum {
    W3_BLE_OFF = 0,
    W3_BLE_STARTING,        /* bt_task created, waiting for BT_POWER_ON_CNF */
    W3_BLE_ADVERTISING,
    W3_BLE_CONNECTED,
    W3_BLE_ERROR,           /* power-on or advertising failed (see last_status) */
} w3_ble_state_t;

typedef struct {
    w3_ble_state_t state;
    int32_t last_status;        /* last non-success bt_status_t */
    uint8_t peer[6];            /* connected peer address, LSB first */
    uint16_t conn_interval;     /* units of 1.25 ms */
    bool imu_notify;            /* client enabled IMU notifications */
    uint8_t imu_rate_hz;
    uint32_t imu_sent;
    uint32_t imu_busy;          /* sends the stack refused (buffer full) */
    uint32_t connections;
    uint32_t time_syncs;
    uint32_t msg_seq;           /* increments with every new notification text */
    char msg[W3_BLE_MSG_MAX + 1];
} w3_ble_info_t;

/* Create the BT task (powers the controller on after ~1 s) and the IMU task. */
void w3_ble_start(void);

/* Snapshot of the state (safe from any task). */
void w3_ble_get(w3_ble_info_t *out);

#endif /* __W3_BLE_H__ */

#include <stdio.h>
#include <string.h>

#include "FreeRTOS.h"
#include "task.h"
#include "bt_system.h"
#include "bt_gap_le.h"
#include "bt_gatts.h"
#include "bt_gatt.h"
#include "bt_uuid.h"
#include "bt_hci.h"
#include "bt_task.h"
#include "bhi160.h"
#include "vibrator.h"
#include "w3_time.h"
#include "usb_log.h"
#include "w3_ble.h"

#define BT_TASK_STACK_BYTES 4096
#define BT_TASK_PRIO        6       /* TASK_PRIORITY_HIGH, as in the SDK's BLE examples */
#define BLE_MAX_MTU         128     /* a 120-byte notification fits in one write */
#define CONN_MAX            1
#define TIMER_NUM           10
#define IMU_LEN             16
#define IMU_RATE_MAX        25      /* the BHI160 runs at 25 Hz */

/* Attribute handles. Each characteristic declaration names the handle of its
 * value, so these must match the order of the record lists below. */
#define H_GAP_START         0x0001
#define H_GAP_NAME          0x0003
#define H_GAP_APPEARANCE    0x0005
#define H_GAP_END           0x0005
#define H_GATT_START        0x0010
#define H_GATT_SC           0x0012
#define H_GATT_END          0x0013
#define H_W3_START          0x0020
#define H_TIME              0x0022
#define H_IMU               0x0025
#define H_NOTIFY            0x0029
#define H_W3_END            0x002A

/* 5733xxxx-9c1e-4b8e-a0f3-1c5e9b7d3a42, stored least significant byte first
 * as bt_uuid_t expects (see BT_UUID_INIT_WITH_UUID16 for the SIG base). */
#define W3_UUID(x)  {{0x42, 0x3A, 0x7D, 0x9B, 0x5E, 0x1C, 0xF3, 0xA0, \
                      0x8E, 0x4B, 0x1E, 0x9C, (uint8_t)(x), (uint8_t)((x) >> 8), 0x33, 0x57}}

/* The watch's own address from the stock NVDM ("BT"/"address" = 98BB993E7CDC,
 * OUI 98:BB:99 = Phicomm), least significant byte first. */
static bt_bd_addr_t s_public_addr = {0xDC, 0x7C, 0x3E, 0x99, 0xBB, 0x98};

/* Memory handed to the stack. TX is above the SDK's 256..512 suggestion
 * because IMU notifications are queued there. */
BT_ALIGNMENT4(static char s_timer_buf[TIMER_NUM * BT_CONTROL_BLOCK_SIZE_OF_TIMER]);
BT_ALIGNMENT4(static char s_conn_buf[CONN_MAX * BT_CONTROL_BLOCK_SIZE_OF_LE_CONNECTION]);
BT_ALIGNMENT4(static char s_tx_buf[1024]);
BT_ALIGNMENT4(static char s_rx_buf[1024]);

/* Shared with the display/AT task (w3_ble_get) and the IMU task: change only
 * inside a critical section. */
static w3_ble_info_t s_info;
static bt_handle_t s_conn;              /* 0 = not connected */
static uint16_t s_imu_cccd;             /* client characteristic configuration, bit 0 = notify */
static uint16_t s_sc_cccd;
/* Text being received: a long write arrives as several prepare-writes. */
static char s_stage[W3_BLE_MSG_MAX];
static uint16_t s_stage_len;

static void put_le16(uint8_t *p, uint16_t v)
{
    p[0] = (uint8_t)v;
    p[1] = (uint8_t)(v >> 8);
}

static void put_le32(uint8_t *p, uint32_t v)
{
    put_le16(p, (uint16_t)v);
    put_le16(p + 2, (uint16_t)(v >> 16));
}

static uint32_t get_le32(const uint8_t *p)
{
    return p[0] | (p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

/* GATTS read protocol: size 0 asks for the length; otherwise copy up to size
 * bytes starting at offset (long reads come in pieces). */
static uint32_t read_value(const void *v, uint16_t len, void *data, uint16_t size, uint16_t offset)
{
    if (size == 0) {
        return len;
    }
    if (offset >= len) {
        return 0;
    }
    if (size > len - offset) {
        size = len - offset;
    }
    memcpy(data, (const uint8_t *)v + offset, size);
    return size;
}

/* ---- GAP service (0x1800): device name, appearance ---------------------- */

static const bt_uuid_t UUID_DEVICE_NAME = BT_UUID_INIT_WITH_UUID16(BT_SIG_UUID16_DEVICE_NAME);
static const bt_uuid_t UUID_APPEARANCE = BT_UUID_INIT_WITH_UUID16(BT_SIG_UUID16_APPEARANCE);
static const bt_uuid_t UUID_SERVICE_CHANGED = BT_UUID_INIT_WITH_UUID16(BT_SIG_UUID16_SERVICE_CHANGED);

static uint32_t gap_name_cb(const uint8_t rw, uint16_t handle, void *data, uint16_t size, uint16_t offset)
{
    (void)handle;
    return rw == BT_GATTS_CALLBACK_READ ? read_value(W3_BLE_NAME, sizeof(W3_BLE_NAME) - 1, data, size, offset) : 0;
}

BT_GATTS_NEW_PRIMARY_SERVICE_16(gap_primary, BT_GATT_UUID16_GAP_SERVICE);
BT_GATTS_NEW_CHARC_16(gap_name_decl, BT_GATT_CHARC_PROP_READ, H_GAP_NAME, BT_SIG_UUID16_DEVICE_NAME);
BT_GATTS_NEW_CHARC_VALUE_CALLBACK(gap_name, UUID_DEVICE_NAME, BT_GATTS_REC_PERM_READABLE, gap_name_cb);
BT_GATTS_NEW_CHARC_16(gap_appearance_decl, BT_GATT_CHARC_PROP_READ, H_GAP_APPEARANCE, BT_SIG_UUID16_APPEARANCE);
BT_GATTS_NEW_CHARC_VALUE_UINT16(gap_appearance, UUID_APPEARANCE, BT_GATTS_REC_PERM_READABLE, 0x00C0); /* generic watch */

static const bt_gatts_service_rec_t *s_gap_recs[] = {
    (const bt_gatts_service_rec_t *)&gap_primary,
    (const bt_gatts_service_rec_t *)&gap_name_decl,
    (const bt_gatts_service_rec_t *)&gap_name,
    (const bt_gatts_service_rec_t *)&gap_appearance_decl,
    (const bt_gatts_service_rec_t *)&gap_appearance,
};

static const bt_gatts_service_t s_gap_service = {
    .starting_handle = H_GAP_START,
    .ending_handle = H_GAP_END,
    .required_encryption_key_size = 7,
    .records = s_gap_recs
};

/* ---- GATT service (0x1801): Service Changed ------------------------------
 * Never indicated; its presence tells phones not to cache our attribute
 * table across connections, which matters while the table still changes
 * from build to build. */

static uint32_t sc_cccd_cb(const uint8_t rw, uint16_t handle, void *data, uint16_t size, uint16_t offset)
{
    (void)handle;
    if (rw == BT_GATTS_CALLBACK_WRITE) {
        if (size != 2 || offset != 0) {
            return 0;
        }
        s_sc_cccd = *(const uint8_t *)data | (((const uint8_t *)data)[1] << 8);
        return 2;
    }
    return read_value(&s_sc_cccd, 2, data, size, offset);
}

BT_GATTS_NEW_PRIMARY_SERVICE_16(gatt_primary, BT_GATT_UUID16_GATT_SERVICE);
BT_GATTS_NEW_CHARC_16(gatt_sc_decl, BT_GATT_CHARC_PROP_INDICATE, H_GATT_SC, BT_SIG_UUID16_SERVICE_CHANGED);
BT_GATTS_NEW_CHARC_VALUE_UINT32(gatt_sc, UUID_SERVICE_CHANGED, 0, 0xFFFF0001);   /* range 0x0001..0xFFFF */
BT_GATTS_NEW_CLIENT_CHARC_CONFIG(gatt_sc_cccd, BT_GATTS_REC_PERM_READABLE | BT_GATTS_REC_PERM_WRITABLE, sc_cccd_cb);

static const bt_gatts_service_rec_t *s_gatt_recs[] = {
    (const bt_gatts_service_rec_t *)&gatt_primary,
    (const bt_gatts_service_rec_t *)&gatt_sc_decl,
    (const bt_gatts_service_rec_t *)&gatt_sc,
    (const bt_gatts_service_rec_t *)&gatt_sc_cccd,
};

static const bt_gatts_service_t s_gatt_service = {
    .starting_handle = H_GATT_START,
    .ending_handle = H_GATT_END,
    .required_encryption_key_size = 7,
    .records = s_gatt_recs
};

/* ---- W3 service ----------------------------------------------------------- */

static const bt_uuid_t UUID_W3_TIME = W3_UUID(0x0002);
static const bt_uuid_t UUID_W3_IMU = W3_UUID(0x0003);
static const bt_uuid_t UUID_W3_NOTIFY = W3_UUID(0x0004);

/* Time: u32 Unix time (UTC) + optional i8 timezone hours. */
static uint32_t time_cb(const uint8_t rw, uint16_t handle, void *data, uint16_t size, uint16_t offset)
{
    uint8_t v[5];
    const uint8_t *p = data;
    uint32_t t;

    (void)handle;
    if (rw == BT_GATTS_CALLBACK_READ) {
        put_le32(v, w3_time_get_unix());
        v[4] = (uint8_t)(int8_t)w3_time_get_tz();
        return read_value(v, sizeof(v), data, size, offset);
    }
    if (rw != BT_GATTS_CALLBACK_WRITE || offset != 0 || (size != 4 && size != 5)) {
        return 0;
    }
    t = get_le32(p);
    if (size == 5) {
        w3_time_set_tz((int8_t)p[4]);
    }
    if (!w3_time_set_unix(t)) {
        ulog("ble: time write %lu rejected", (unsigned long)t);
        return 0;
    }
    taskENTER_CRITICAL();
    s_info.time_syncs++;
    taskEXIT_CRITICAL();
    ulog("ble: time set to unix %lu, tz %+d", (unsigned long)t, w3_time_get_tz());
    return size;
}

static void imu_packet(uint8_t *p)
{
    bhi160_data_t d;
    int i;

    bhi160_get(&d);
    put_le16(p, (uint16_t)d.samples);
    for (i = 0; i < 3; i++) {
        put_le16(p + 2 + 2 * i, (uint16_t)d.acc_raw[i]);
        put_le16(p + 8 + 2 * i, (uint16_t)d.gyro_raw[i]);
    }
    put_le16(p + 14, (uint16_t)(xTaskGetTickCount() * portTICK_RATE_MS));
}

/* IMU: read = latest sample; write u8 = notification rate in Hz. */
static uint32_t imu_cb(const uint8_t rw, uint16_t handle, void *data, uint16_t size, uint16_t offset)
{
    uint8_t v[IMU_LEN];
    uint8_t rate;

    (void)handle;
    if (rw == BT_GATTS_CALLBACK_READ) {
        imu_packet(v);
        return read_value(v, sizeof(v), data, size, offset);
    }
    if (rw != BT_GATTS_CALLBACK_WRITE || offset != 0 || size != 1) {
        return 0;
    }
    rate = *(const uint8_t *)data;
    if (rate > IMU_RATE_MAX) {
        rate = IMU_RATE_MAX;
    }
    taskENTER_CRITICAL();
    s_info.imu_rate_hz = rate;
    taskEXIT_CRITICAL();
    ulog("ble: IMU rate %u Hz", rate);
    return 1;
}

static uint32_t imu_cccd_cb(const uint8_t rw, uint16_t handle, void *data, uint16_t size, uint16_t offset)
{
    const uint8_t *p = data;

    (void)handle;
    if (rw == BT_GATTS_CALLBACK_WRITE) {
        if (size != 2 || offset != 0) {
            return 0;
        }
        taskENTER_CRITICAL();
        s_imu_cccd = p[0] | (p[1] << 8);
        s_info.imu_notify = (s_imu_cccd & 1) != 0;
        taskEXIT_CRITICAL();
        ulog("ble: IMU notifications %s", s_imu_cccd & 1 ? "on" : "off");
        return 2;
    }
    return read_value(&s_imu_cccd, 2, data, size, offset);
}

static void stage_put(const void *data, uint16_t size, uint16_t offset)
{
    if (offset >= sizeof(s_stage)) {
        return;
    }
    if (size > sizeof(s_stage) - offset) {
        size = sizeof(s_stage) - offset;       /* longer text is cut */
    }
    memcpy(s_stage + offset, data, size);
    if (offset + size > s_stage_len) {
        s_stage_len = offset + size;
    }
}

static void stage_commit(void)
{
    taskENTER_CRITICAL();
    memcpy(s_info.msg, s_stage, s_stage_len);
    s_info.msg[s_stage_len] = 0;
    s_info.msg_seq++;
    taskEXIT_CRITICAL();
    ulog("ble: message (%u bytes): %s", s_stage_len, s_info.msg);
    vibrator_play(VIB_PATTERN_NOTIFY);
    s_stage_len = 0;
}

/* Notify: a short text arrives in one write; a longer one (more than
 * MTU - 3 bytes) as prepare-writes at increasing offsets plus an execute. */
static uint32_t notify_cb(const uint8_t rw, uint16_t handle, void *data, uint16_t size, uint16_t offset)
{
    (void)handle;
    switch (rw) {
        case BT_GATTS_CALLBACK_WRITE:
            s_stage_len = 0;
            stage_put(data, size, offset);
            stage_commit();
            return size;
        case BT_GATTS_CALLBACK_PREPARE_WRITE:
            if (offset == 0) {
                s_stage_len = 0;
            }
            stage_put(data, size, offset);
            return size;
        case BT_GATTS_CALLBACK_EXECUTE_WRITE_WRITE:
            stage_commit();
            return 0;                           /* status 0 = success */
        case BT_GATTS_CALLBACK_EXECUTE_WRITE_CANCEL:
            s_stage_len = 0;
            return 0;
        default:
            return 0;
    }
}

BT_GATTS_NEW_PRIMARY_SERVICE_128(w3_primary, W3_UUID(0x0001));
BT_GATTS_NEW_CHARC_128(w3_time_decl, BT_GATT_CHARC_PROP_READ | BT_GATT_CHARC_PROP_WRITE, H_TIME, W3_UUID(0x0002));
BT_GATTS_NEW_CHARC_VALUE_CALLBACK(w3_time, UUID_W3_TIME, BT_GATTS_REC_PERM_READABLE | BT_GATTS_REC_PERM_WRITABLE, time_cb);
BT_GATTS_NEW_CHARC_USER_DESCRIPTION_STR16(w3_time_desc, BT_GATTS_REC_PERM_READABLE, 12, "Time unix,tz");
BT_GATTS_NEW_CHARC_128(w3_imu_decl, BT_GATT_CHARC_PROP_READ | BT_GATT_CHARC_PROP_WRITE | BT_GATT_CHARC_PROP_NOTIFY,
                       H_IMU, W3_UUID(0x0003));
BT_GATTS_NEW_CHARC_VALUE_CALLBACK(w3_imu, UUID_W3_IMU, BT_GATTS_REC_PERM_READABLE | BT_GATTS_REC_PERM_WRITABLE, imu_cb);
BT_GATTS_NEW_CLIENT_CHARC_CONFIG(w3_imu_cccd, BT_GATTS_REC_PERM_READABLE | BT_GATTS_REC_PERM_WRITABLE, imu_cccd_cb);
BT_GATTS_NEW_CHARC_USER_DESCRIPTION_STR16(w3_imu_desc, BT_GATTS_REC_PERM_READABLE, 7, "IMU raw");
BT_GATTS_NEW_CHARC_128(w3_notify_decl, BT_GATT_CHARC_PROP_WRITE | BT_GATT_CHARC_PROP_WRITE_WITHOUT_RSP,
                       H_NOTIFY, W3_UUID(0x0004));
BT_GATTS_NEW_CHARC_VALUE_CALLBACK(w3_notify, UUID_W3_NOTIFY, BT_GATTS_REC_PERM_WRITABLE, notify_cb);
BT_GATTS_NEW_CHARC_USER_DESCRIPTION_STR16(w3_notify_desc, BT_GATTS_REC_PERM_READABLE, 11, "Notify text");

static const bt_gatts_service_rec_t *s_w3_recs[] = {
    (const bt_gatts_service_rec_t *)&w3_primary,        /* 0x0020 */
    (const bt_gatts_service_rec_t *)&w3_time_decl,      /* 0x0021 */
    (const bt_gatts_service_rec_t *)&w3_time,           /* 0x0022 */
    (const bt_gatts_service_rec_t *)&w3_time_desc,      /* 0x0023 */
    (const bt_gatts_service_rec_t *)&w3_imu_decl,       /* 0x0024 */
    (const bt_gatts_service_rec_t *)&w3_imu,            /* 0x0025 */
    (const bt_gatts_service_rec_t *)&w3_imu_cccd,       /* 0x0026 */
    (const bt_gatts_service_rec_t *)&w3_imu_desc,       /* 0x0027 */
    (const bt_gatts_service_rec_t *)&w3_notify_decl,    /* 0x0028 */
    (const bt_gatts_service_rec_t *)&w3_notify,         /* 0x0029 */
    (const bt_gatts_service_rec_t *)&w3_notify_desc,    /* 0x002A */
};

static const bt_gatts_service_t s_w3_service = {
    .starting_handle = H_W3_START,
    .ending_handle = H_W3_END,
    .required_encryption_key_size = 7,
    .records = s_w3_recs
};

static const bt_gatts_service_t *s_server[] = { &s_gap_service, &s_gatt_service, &s_w3_service, NULL };

/* Called by the GATTS whenever a client accesses the attribute table. */
const bt_gatts_service_t **bt_get_gatt_server(void)
{
    return s_server;
}

/* ---- Security: "just works", nothing stored ------------------------------
 * The characteristics need no encryption. If a phone asks to pair anyway it
 * gets an unauthenticated pairing without bonding; the one bonding record
 * lives in RAM and is forgotten at reset. */

static bt_gap_le_local_key_t s_local_key = {
    .encryption_info = {{0}},
    .master_id = {0},
    .identity_info = {{0x57, 0x33, 0x9C, 0x1E, 0x4B, 0x8E, 0xA0, 0xF3, 0x1C, 0x5E, 0x9B, 0x7D, 0x3A, 0x42, 0x98, 0xBB}},
    .signing_info = {{0}}
};
static bt_gap_le_local_config_req_ind_t s_local_config;
static bt_gap_le_bonding_info_t s_bond;
static const bt_gap_le_smp_pairing_config_t s_pairing = {
    .io_capability = BT_GAP_LE_SMP_NO_INPUT_NO_OUTPUT,
    .oob_data_flag = BT_GAP_LE_SMP_OOB_DATA_NOT_PRESENTED,
    .auth_req = BT_GAP_LE_SMP_AUTH_REQ_NO_BONDING,
    .maximum_encryption_key_size = 16,
    .initiator_key_distribution = 0,
    .responder_key_distribution = 0,
};

bt_gap_le_local_config_req_ind_t *bt_gap_le_get_local_config(void)
{
    s_local_config.local_key_req = &s_local_key;
    s_local_config.sc_only_mode_req = false;
    return &s_local_config;
}

bt_gap_le_bonding_info_t *bt_gap_le_get_bonding_info(const bt_addr_t remote_addr)
{
    (void)remote_addr;
    return &s_bond;
}

bt_status_t bt_gap_le_get_pairing_config(bt_gap_le_bonding_start_ind_t *ind)
{
    ind->pairing_config_req = s_pairing;
    return BT_STATUS_SUCCESS;
}

/* ---- GAP: advertising and connection events ------------------------------ */

static void set_state(w3_ble_state_t st, bt_status_t status)
{
    taskENTER_CRITICAL();
    s_info.state = st;
    if (status != BT_STATUS_SUCCESS) {
        s_info.last_status = (int32_t)status;
    }
    taskEXIT_CRITICAL();
}

/* Advertising data: flags + complete name. Scan response: the W3 service
 * UUID, so a scanner can filter for it. 100..150 ms interval: quick to find
 * while we develop; the watch runs from USB anyway. */
static void start_advertising(void)
{
    static const bt_uuid_t svc = W3_UUID(0x0001);
    bt_hci_cmd_le_set_advertising_enable_t enable = { .advertising_enable = BT_HCI_ENABLE };
    bt_hci_cmd_le_set_advertising_parameters_t param = {
        .advertising_interval_min = 0x00A0,     /* units of 0.625 ms */
        .advertising_interval_max = 0x00F0,
        .advertising_type = BT_HCI_ADV_TYPE_CONNECTABLE_UNDIRECTED,
        .own_address_type = BT_ADDR_PUBLIC,
        .advertising_channel_map = 7,
        .advertising_filter_policy = 0,
    };
    bt_hci_cmd_le_set_advertising_data_t adv;
    bt_hci_cmd_le_set_scan_response_data_t rsp;
    uint8_t n = 0, len = sizeof(W3_BLE_NAME) - 1;
    bt_status_t st;

    memset(&adv, 0, sizeof(adv));
    adv.advertising_data[n++] = 2;
    adv.advertising_data[n++] = BT_GAP_LE_AD_TYPE_FLAG;
    adv.advertising_data[n++] = BT_GAP_LE_AD_FLAG_GENERAL_DISCOVERABLE | BT_GAP_LE_AD_FLAG_BR_EDR_NOT_SUPPORTED;
    adv.advertising_data[n++] = len + 1;
    adv.advertising_data[n++] = BT_GAP_LE_AD_TYPE_NAME_COMPLETE;
    memcpy(&adv.advertising_data[n], W3_BLE_NAME, len);
    adv.advertising_data_length = n + len;

    memset(&rsp, 0, sizeof(rsp));
    rsp.scan_response_data[0] = 17;
    rsp.scan_response_data[1] = BT_GAP_LE_AD_TYPE_128_BIT_UUID_COMPLETE;
    memcpy(&rsp.scan_response_data[2], svc.uuid, 16);
    rsp.scan_response_data_length = 18;

    st = bt_gap_le_set_advertising(&enable, &param, &adv, &rsp);
    if (st != BT_STATUS_SUCCESS) {
        ulog("ble: set_advertising failed 0x%08lX", (unsigned long)st);
        set_state(W3_BLE_ERROR, st);
    }
}

/* Every stack event arrives here, in bt_task. */
bt_status_t bt_app_event_callback(bt_msg_type_t msg, bt_status_t status, void *buff)
{
    switch (msg) {
        case BT_POWER_ON_CNF:
            ulog("ble: power on %s (0x%08lX)", status == BT_STATUS_SUCCESS ? "ok" : "FAILED", (unsigned long)status);
            if (status != BT_STATUS_SUCCESS) {
                set_state(W3_BLE_ERROR, status);
                break;
            }
            bt_gatts_set_max_mtu(BLE_MAX_MTU);
            start_advertising();
            break;

        case BT_GAP_LE_SET_ADVERTISING_CNF:
            ulog("ble: advertising %s (0x%08lX)", status == BT_STATUS_SUCCESS ? "on" : "FAILED", (unsigned long)status);
            if (s_info.state != W3_BLE_CONNECTED) {
                set_state(status == BT_STATUS_SUCCESS ? W3_BLE_ADVERTISING : W3_BLE_ERROR, status);
            }
            break;

        case BT_GAP_LE_CONNECT_IND: {
            const bt_gap_le_connection_ind_t *c = buff;

            if (status != BT_STATUS_SUCCESS || c == NULL) {
                ulog("ble: connect failed 0x%08lX", (unsigned long)status);
                break;
            }
            taskENTER_CRITICAL();
            s_conn = c->connection_handle;
            s_imu_cccd = 0;
            s_info.imu_notify = false;
            s_info.state = W3_BLE_CONNECTED;
            memcpy(s_info.peer, c->peer_addr.addr, 6);
            s_info.conn_interval = c->conn_interval;
            s_info.connections++;
            taskEXIT_CRITICAL();
            ulog("ble: connected to %02X:%02X:%02X:%02X:%02X:%02X (%s), handle 0x%04X, interval %u x 1.25 ms",
                 c->peer_addr.addr[5], c->peer_addr.addr[4], c->peer_addr.addr[3],
                 c->peer_addr.addr[2], c->peer_addr.addr[1], c->peer_addr.addr[0],
                 c->peer_addr.type ? "random" : "public", c->connection_handle, c->conn_interval);
            break;
        }

        case BT_GAP_LE_CONNECTION_UPDATE_IND: {
            const bt_gap_le_connection_update_ind_t *u = buff;

            if (u != NULL) {
                taskENTER_CRITICAL();
                s_info.conn_interval = u->conn_interval;
                taskEXIT_CRITICAL();
                ulog("ble: connection interval now %u x 1.25 ms, latency %u, timeout %u0 ms",
                     u->conn_interval, u->conn_latency, u->supervision_timeout);
            }
            break;
        }

        case BT_GAP_LE_DISCONNECT_IND: {
            const bt_hci_evt_disconnect_complete_t *d = buff;

            ulog("ble: disconnected, reason 0x%02X", d ? d->reason : 0);
            taskENTER_CRITICAL();
            s_conn = 0;
            s_imu_cccd = 0;
            s_info.imu_notify = false;
            s_info.state = W3_BLE_ADVERTISING;
            taskEXIT_CRITICAL();
            start_advertising();             /* the controller stops advertising on connect */
            break;
        }

        default:
            break;
    }
    return BT_STATUS_SUCCESS;
}

/* ---- IMU notifications ---------------------------------------------------- */

static void imu_task(void *arg)
{
    /* bt_gattc_charc_value_notification_indication_t: u16 length, then the
     * ATT PDU (opcode, handle, value). length counts opcode + handle too. */
    uint32_t words[(2 + 3 + IMU_LEN + 3) / 4 + 1];
    bt_gattc_charc_value_notification_indication_t *n = (bt_gattc_charc_value_notification_indication_t *)words;
    TickType_t last = xTaskGetTickCount();

    (void)arg;
    for (;;) {
        bt_handle_t conn;
        uint8_t rate;
        bool on;
        bt_status_t st;

        taskENTER_CRITICAL();
        conn = s_conn;
        rate = s_info.imu_rate_hz;
        on = s_info.imu_notify;
        taskEXIT_CRITICAL();
        if (conn == 0 || !on || rate == 0) {
            vTaskDelay(100 / portTICK_RATE_MS);
            last = xTaskGetTickCount();
            continue;
        }
        vTaskDelayUntil(&last, (1000 / rate) / portTICK_RATE_MS);
        n->att_req.opcode = BT_ATT_OPCODE_HANDLE_VALUE_NOTIFICATION;
        n->att_req.handle = H_IMU;
        imu_packet(n->att_req.attribute_value);
        n->attribute_value_length = 3 + IMU_LEN;
        st = bt_gatts_send_charc_value_notification_indication(conn, n);
        taskENTER_CRITICAL();
        if (st == BT_STATUS_SUCCESS) {
            s_info.imu_sent++;
        } else {
            s_info.imu_busy++;                  /* TX buffer full or link gone: drop this sample */
        }
        taskEXIT_CRITICAL();
    }
}

/* ---- Public ---------------------------------------------------------------- */

void w3_ble_start(void)
{
    bt_memory_init_packet(BT_MEMORY_TX_BUFFER, s_tx_buf, sizeof(s_tx_buf));
    bt_memory_init_packet(BT_MEMORY_RX_BUFFER, s_rx_buf, sizeof(s_rx_buf));
    bt_memory_init_control_block(BT_MEMORY_CONTROL_BLOCK_TIMER, s_timer_buf, sizeof(s_timer_buf));
    bt_memory_init_control_block(BT_MEMORY_CONTROL_BLOCK_LE_CONNECTION, s_conn_buf, sizeof(s_conn_buf));
    s_info.state = W3_BLE_STARTING;
    s_info.imu_rate_hz = 10;
    /* bt_task sleeps 1 s, then bt_power_on(public, random) -> BT_POWER_ON_CNF. */
    xTaskCreate(bt_task, "bt_task", BT_TASK_STACK_BYTES / sizeof(StackType_t), s_public_addr, BT_TASK_PRIO, NULL);
    xTaskCreate(imu_task, "BLEIMU", 512, NULL, 2, NULL);
}

void w3_ble_get(w3_ble_info_t *out)
{
    taskENTER_CRITICAL();
    *out = s_info;
    taskEXIT_CRITICAL();
}

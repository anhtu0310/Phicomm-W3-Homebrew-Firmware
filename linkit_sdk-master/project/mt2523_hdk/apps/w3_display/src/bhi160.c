#include <string.h>

#include "FreeRTOS.h"
#include "task.h"
#include "hal.h"
#include "bhi160.h"
#include "bhi160_fw.h"
#include "sensor_i2c.h"

#define BHI_I2C_ADDR        0x28

/* Registers (Bosch BHy1 driver, bhy_defs_internal.h) */
#define REG_FIFO_WINDOW     0x00    /* FIFO data appears at 0x00..0x31 ... */
#define FIFO_WINDOW_LEN     50      /* ... and each read continues at (reg + n) % 50 */
#define REG_CHIP_CONTROL    0x34
#define REG_BYTES_REMAINING 0x38    /* u16 LE: bytes waiting in the FIFO */
#define REG_PARAM_ACK       0x3A
#define REG_PARAM_READ      0x3B    /* 16-byte parameter read buffer (0x3B..0x4A) */
#define REG_PAGE_SELECT     0x54
#define REG_PARAM_WRITE     0x5C    /* 8-byte parameter write buffer */
#define REG_PARAM_REQUEST   0x64
#define REG_ROM_VERSION     0x70    /* u16 LE */
#define REG_RAM_VERSION     0x72    /* u16 LE */
#define REG_PRODUCT_ID      0x90
#define REG_UPLOAD_ADDR_LO  0x94
#define REG_UPLOAD_ADDR_HI  0x95
#define REG_UPLOAD_DATA     0x96    /* RAM patch data port */
#define REG_UPLOAD_CRC      0x97    /* u32 LE: CRC the hub computed over the upload */
#define REG_RESET_REQUEST   0x9B

#define PRODUCT_ID_BHI160   0x83
#define ROM_VERSION_DI01    0x2112
#define ROM_VERSION_DI03    0x2DAD
#define CHIP_CTRL_CPU_RUN   0x01
#define CHIP_CTRL_UPLOAD    0x02
#define PAGE_SENSORS        3
#define PARAM_SENSOR_CONFIG 0xC0    /* parameter = 0xC0 + sensor ID writes its config */
#define PARAM_ACK_ERROR     0x80

/* Virtual sensor / FIFO event IDs (wake-up variants are +32) */
#define SID_ACCEL           1
#define SID_GYRO            4
#define SID_STEP_COUNTER    19      /* standard step counter: refused by the W3 patch (ack 0x80) */
#define SID_PEDOMETER       29      /* Bosch "custom sensor 4" slot, used by the W3 patch as its
                                     * pedometer (stock bhi160_pedometer_operate, 0x08039B80) */
#define SID_CUSTOM_FIRST    26      /* custom slots CUS1..CUS5 = IDs 26..30; their event */
#define SID_CUSTOM_LAST     30      /* size is not fixed, the hub reports it (see below) */
#define SID_META_WAKEUP     248
#define SID_META            254
#define META_INITIALIZED    16

#define ACC_RANGE_G         4
#define GYRO_RANGE_DPS      2000
#define SAMPLE_RATE_HZ      25
#define PEDOMETER_RATE_HZ   10      /* what the stock firmware requests for sensor 29 */
#define UPLOAD_CHUNK        4       /* bytes per write: one word (a write is reg + <= 7 bytes) */
#define POLL_MS             40

static bhi160_data_t s_data;
static bool s_initialized;          /* "initialized" meta event seen */
/* Integrated gyroscope angle in micro-degrees (int64 so rounding does not
 * accumulate: one LSB per sample is only ~2.4 milli-degrees). */
static int64_t s_angle_udeg[3];
static uint8_t s_carry[64];         /* a FIFO event split across two reads (custom events
                                     * may be longer than the standard ones) */

/* Sensor information blocks (parameter page 3, parameter = sensor ID), one per
 * virtual sensor 1..31, read once at boot. They tell which sensors this RAM
 * patch provides and how big their FIFO events are. Layout (BHI160 datasheet,
 * "sensor information structure"):
 *   [0] sensor ID  [1] driver ID  [2] driver version  [3] power (0.1 mA)
 *   [4..5] max range  [6..7] resolution  [8..9] max rate (Hz)
 *   [10..11] FIFO reserved  [12..13] FIFO max  [14] event size  [15] min rate (Hz)
 * Only valid (s_info_ok) if the hub acknowledged the read. */
static uint8_t s_info[32][BHI160_INFO_LEN];
static bool s_info_ok[32];
/* Whether the reported event size counts the ID byte too. Learned from the
 * accelerometer, whose FIFO event is known to be 8 bytes including the ID. */
static uint8_t s_size_extra;
static uint32_t s_carry_len;

/* ---- I2C0 transport (shared sensor bus, see sensor_i2c.c) ---- */
#define I2C_MAX_XFER  SENSOR_I2C_MAX_XFER

/* Write len (<= 7) bytes to consecutive registers starting at reg. */
static bool bhi_write(uint8_t reg, const uint8_t *data, uint32_t len)
{
    return sensor_i2c_write(BHI_I2C_ADDR, reg, data, len);
}

static bool bhi_write_u8(uint8_t reg, uint8_t value)
{
    return bhi_write(reg, &value, 1);
}

/* Read len (<= 8) bytes starting at register reg. */
static bool bhi_read(uint8_t reg, uint8_t *data, uint32_t len)
{
    return sensor_i2c_read(BHI_I2C_ADDR, reg, data, len);
}

static uint16_t le16(const uint8_t *p)
{
    return (uint16_t)(p[0] | (p[1] << 8));
}

/* ---- FIFO parsing ---- */

/* Total size of a FIFO event including its ID byte (Bosch frame sizes),
 * or 0 for an ID we do not know how to skip. */
static uint32_t event_size(uint8_t id)
{
    if (id >= 33 && id <= 63) {
        id -= 32;                   /* wake-up variant, same layout */
    }
    switch (id) {
        case 0:                                         /* padding */
        case 17: case 18: case 22: case 23: case 24: case 25:  /* gestures, step detector */
            return 1;
        case 21:                                        /* heart rate u8 */
            return 2;
        case 5: case 7: case 8: case 12: case 13: case 19: case 31:  /* 16-bit scalars */
        case 246: case 247: case 252: case 253:         /* timestamp LSW / MSW */
            return 3;
        case 6:                                         /* barometer u24 */
        case SID_META_WAKEUP: case SID_META:
            return 4;
        case 1: case 2: case 3: case 4: case 9: case 10:  /* 3-axis vectors + status */
            return 8;
        case 11: case 15: case 20:                      /* quaternions */
            return 11;
        case 14: case 16: case 245:                     /* uncalibrated vectors, debug */
            return 14;
        case 249: case 250: case 251:                   /* BSX */
            return 17;
        default:
            /* Custom slots (e.g. the W3 pedometer, 29): use the event size
             * the hub reported in its sensor information block. */
            if (id >= SID_CUSTOM_FIRST && id <= SID_CUSTOM_LAST && s_info_ok[id] && s_info[id][14]) {
                return s_info[id][14] + s_size_extra;
            }
            return 0;
    }
}

static void handle_event(const uint8_t *e, uint32_t size)
{
    uint8_t id = e[0];
    int i;

    if (id >= 33 && id <= 63) {
        id -= 32;
    }
    taskENTER_CRITICAL();
    switch (id) {
        case SID_ACCEL:
            for (i = 0; i < 3; i++) {
                s_data.acc_raw[i] = (int16_t)le16(&e[1 + 2 * i]);
                s_data.acc_mg[i] = (int16_t)((int32_t)s_data.acc_raw[i] * ACC_RANGE_G * 1000 / 32768);
            }
            s_data.acc_accuracy = e[7];
            s_data.samples++;
            break;
        case SID_GYRO:
            for (i = 0; i < 3; i++) {
                int32_t raw = (int16_t)le16(&e[1 + 2 * i]);

                s_data.gyro_raw[i] = (int16_t)raw;
                s_data.gyro_dps[i] = (int16_t)(raw * GYRO_RANGE_DPS / 32768);
                /* angle += rate * dt, dt = 1 / SAMPLE_RATE_HZ */
                s_angle_udeg[i] += (int64_t)raw * GYRO_RANGE_DPS * 1000000 / 32768 / SAMPLE_RATE_HZ;
                s_data.angle_mdeg[i] = (int32_t)(s_angle_udeg[i] / 1000);
            }
            s_data.gyro_samples++;
            break;
        case SID_STEP_COUNTER:
            s_data.steps = le16(&e[1]);
            break;
        case SID_PEDOMETER:
            /* Payload format not documented: keep the raw bytes for the log,
             * and show the first 16-bit value as the step count until a test
             * walk confirms (or corrects) that guess. */
            s_data.pedo_events++;
            s_data.pedo_len = (uint8_t)(size - 1 < sizeof(s_data.pedo_raw) ? size - 1 : sizeof(s_data.pedo_raw));
            memcpy(s_data.pedo_raw, &e[1], s_data.pedo_len);
            if (s_data.pedo_len >= 2) {
                s_data.steps = le16(&e[1]);
            }
            break;
        case SID_META:
        case SID_META_WAKEUP:
            memcpy(s_data.last_meta, &e[1], 3);
            s_data.meta_events++;
            if (e[1] == META_INITIALIZED) {
                s_initialized = true;
            }
            break;
        default:
            break;
    }
    taskEXIT_CRITICAL();
}

/* Parse whole events from buf; returns how many bytes were consumed. On an
 * unknown event ID everything is dropped, since we cannot find the next one. */
static uint32_t parse_events(const uint8_t *buf, uint32_t len)
{
    uint32_t pos = 0, size;

    while (pos < len) {
        size = event_size(buf[pos]);
        if (size == 0) {
            return len;
        }
        if (pos + size > len) {
            break;                  /* incomplete: keep it for the next read */
        }
        handle_event(&buf[pos], size);
        pos += size;
    }
    return pos;
}

static void drain_fifo(void)
{
    uint8_t count[2];
    uint8_t buf[sizeof(s_carry) + I2C_MAX_XFER];
    uint32_t remaining, n, total, used;
    uint8_t reg = REG_FIFO_WINDOW;

    if (!bhi_read(REG_BYTES_REMAINING, count, sizeof(count))) {
        return;
    }
    remaining = le16(count);
    while (remaining) {
        n = FIFO_WINDOW_LEN - reg;
        if (n > I2C_MAX_XFER) {
            n = I2C_MAX_XFER;
        }
        if (n > remaining) {
            n = remaining;
        }
        memcpy(buf, s_carry, s_carry_len);
        if (!bhi_read(reg, &buf[s_carry_len], n)) {
            s_carry_len = 0;
            return;
        }
        reg = (uint8_t)((reg + n) % FIFO_WINDOW_LEN);
        remaining -= n;
        total = s_carry_len + n;
        used = parse_events(buf, total);
        s_carry_len = total - used;
        if (s_carry_len > sizeof(s_carry)) {
            s_carry_len = 0;
        }
        memcpy(s_carry, &buf[used], s_carry_len);
    }
}

/* ---- Boot: RAM patch upload and sensor configuration ---- */

static bhi160_state_t upload_patch(void)
{
    const uint8_t *body = &bhi160_fw[16];
    uint32_t len = le16(&bhi160_fw[12]);
    uint32_t crc_file = bhi160_fw[4] | (bhi160_fw[5] << 8) | (bhi160_fw[6] << 16) | ((uint32_t)bhi160_fw[7] << 24);
    uint8_t rom_expected = (le16(&bhi160_fw[2]) >> 11) & 0x03;
    uint8_t chunk[UPLOAD_CHUNK], crc[4];
    uint32_t off, n, i, k;

    if (!((rom_expected == 1 && s_data.rom_version == ROM_VERSION_DI01) ||
          (rom_expected == 3 && s_data.rom_version == ROM_VERSION_DI03))) {
        return BHI160_BAD_ROM;
    }
    if (!bhi_write_u8(REG_RESET_REQUEST, 0x01)) {
        return BHI160_NO_DEVICE;
    }
    vTaskDelay(10 / portTICK_RATE_MS);
    if (!bhi_write_u8(REG_CHIP_CONTROL, CHIP_CTRL_UPLOAD) ||
        !bhi_write_u8(REG_UPLOAD_ADDR_LO, 0) || !bhi_write_u8(REG_UPLOAD_ADDR_HI, 0)) {
        return BHI160_NO_DEVICE;
    }
    /* The hub's CPU is 32-bit with the other byte order: reverse each 4-byte word. */
    for (off = 0; off < len; off += n) {
        n = len - off < UPLOAD_CHUNK ? len - off : UPLOAD_CHUNK;
        for (i = 0; i < n; i += 4) {
            for (k = 0; k < 4; k++) {
                chunk[i + k] = body[off + i + 3 - k];
            }
        }
        if (!bhi_write(REG_UPLOAD_DATA, chunk, n)) {
            return BHI160_NO_DEVICE;
        }
    }
    s_data.crc_expected = crc_file;
    if (!bhi_read(REG_UPLOAD_CRC, crc, sizeof(crc))) {
        return BHI160_NO_DEVICE;
    }
    s_data.crc_device = crc[0] | (crc[1] << 8) | (crc[2] << 16) | ((uint32_t)crc[3] << 24);
    if (s_data.crc_device != crc_file) {
        return BHI160_CRC_ERROR;
    }
    return bhi_write_u8(REG_CHIP_CONTROL, CHIP_CTRL_CPU_RUN) ? BHI160_RUNNING : BHI160_NO_DEVICE;
}

/* Sensor configuration: sample rate (Hz), max report latency (ms),
 * change sensitivity, dynamic range. Returns the last value read from the
 * acknowledge register (== 0xC0 + sensor_id on success), 0 on an I2C error. */
static uint8_t config_sensor(uint8_t sensor_id, uint16_t rate_hz, uint16_t range)
{
    const uint8_t config[8] = {
        (uint8_t)rate_hz, (uint8_t)(rate_hz >> 8), 0, 0, 0, 0, (uint8_t)range, (uint8_t)(range >> 8)
    };
    uint8_t param = PARAM_SENSOR_CONFIG + sensor_id;
    uint8_t ack = 0;
    int i;

    if (!bhi_write(REG_PARAM_WRITE, config, 4) || !bhi_write(REG_PARAM_WRITE + 4, &config[4], 4) ||
        !bhi_write_u8(REG_PAGE_SELECT, PAGE_SENSORS) || !bhi_write_u8(REG_PARAM_REQUEST, param)) {
        return 0;
    }
    for (i = 0; i < 200; i++) {                 /* up to ~1 s */
        if (!bhi_read(REG_PARAM_ACK, &ack, 1)) {
            return 0;
        }
        if (ack == param) {
            break;
        }
        vTaskDelay(5 / portTICK_RATE_MS);
    }
    /* End the transaction (as Bosch's BHy C driver does). */
    bhi_write_u8(REG_PARAM_REQUEST, 0);
    bhi_write_u8(REG_PAGE_SELECT, 0);
    return ack;
}

/* Read one 16-byte parameter (the read counterpart of config_sensor):
 * select the page, write the parameter number WITHOUT the 0x80 "write" bit,
 * wait until the acknowledge register echoes it, then read the result from
 * the parameter read buffer 0x3B..0x4A (two 8-byte reads: our I2C limit). */
static bool read_param(uint8_t page, uint8_t param, uint8_t *out)
{
    uint8_t ack = 0;
    bool ok = false;
    int i;

    if (!bhi_write_u8(REG_PAGE_SELECT, page) || !bhi_write_u8(REG_PARAM_REQUEST, param)) {
        return false;
    }
    for (i = 0; i < 100; i++) {                 /* up to ~0.5 s */
        if (!bhi_read(REG_PARAM_ACK, &ack, 1)) {
            break;
        }
        if (ack == param) {
            ok = bhi_read(REG_PARAM_READ, out, 8) && bhi_read(REG_PARAM_READ + 8, &out[8], 8);
            break;
        }
        vTaskDelay(5 / portTICK_RATE_MS);
    }
    bhi_write_u8(REG_PARAM_REQUEST, 0);         /* end the transaction */
    bhi_write_u8(REG_PAGE_SELECT, 0);
    return ok;
}

/* Ask the hub which virtual sensors its RAM patch provides (IDs 1..31). An
 * absent sensor reads back as all zeros (driver ID 0). */
static void read_sensor_info(void)
{
    uint8_t id;

    for (id = 1; id < 32; id++) {
        s_info_ok[id] = read_param(PAGE_SENSORS, id, s_info[id]);
    }
    /* The accelerometer event is 8 bytes with its ID byte; if the hub says 7,
     * its sizes exclude the ID and we add 1 when skipping custom events. */
    s_size_extra = (s_info_ok[SID_ACCEL] && s_info[SID_ACCEL][14] == 7) ? 1 : 0;
    s_data.info_ready = true;
}

static bhi160_state_t boot_hub(void)
{
    uint8_t buf[2];
    bhi160_state_t st;
    int i;

    for (i = 0; i < 5 && s_data.product_id != PRODUCT_ID_BHI160; i++) {
        if (!bhi_read(REG_PRODUCT_ID, &s_data.product_id, 1)) {
            s_data.product_id = 0;
        }
        vTaskDelay(50 / portTICK_RATE_MS);
    }
    if (s_data.product_id != PRODUCT_ID_BHI160) {
        return BHI160_NO_DEVICE;
    }
    if (bhi_read(REG_ROM_VERSION, buf, 2)) {
        s_data.rom_version = le16(buf);
    }
    st = upload_patch();
    if (st != BHI160_RUNNING) {
        return st;
    }
    /* After the CPU starts, the patch reports itself with an "initialized"
     * meta event in the FIFO. */
    for (i = 0; i < 50 && !s_initialized; i++) {
        vTaskDelay(POLL_MS / portTICK_RATE_MS);
        drain_fifo();
    }
    if (!s_initialized) {
        return BHI160_NO_BOOT;
    }
    if (bhi_read(REG_RAM_VERSION, buf, 2)) {
        s_data.ram_version = le16(buf);
    }
    /* Read the sensor list first: the FIFO parser needs the custom sensors'
     * event sizes before their first events arrive. */
    read_sensor_info();
    /* Keep going when one sensor is refused, so the others still report;
     * the acknowledge values are logged for diagnosis. The pedometer uses the
     * stock settings: 10 Hz, latency 0, sensitivity 0, range 0. */
    s_data.cfg_ack[0] = config_sensor(SID_ACCEL, SAMPLE_RATE_HZ, ACC_RANGE_G);
    s_data.cfg_ack[1] = config_sensor(SID_GYRO, SAMPLE_RATE_HZ, GYRO_RANGE_DPS);
    s_data.cfg_ack[2] = config_sensor(SID_PEDOMETER, PEDOMETER_RATE_HZ, 0);
    if (s_data.cfg_ack[0] != PARAM_SENSOR_CONFIG + SID_ACCEL &&
        s_data.cfg_ack[1] != PARAM_SENSOR_CONFIG + SID_GYRO &&
        s_data.cfg_ack[2] != PARAM_SENSOR_CONFIG + SID_PEDOMETER) {
        return BHI160_CONFIG_ERROR;
    }
    return BHI160_RUNNING;
}

static void bhi160_task(void *arg)
{
    bhi160_state_t st;

    (void)arg;
    st = sensor_i2c_init() ? boot_hub() : BHI160_NO_DEVICE;
    taskENTER_CRITICAL();
    s_data.state = st;
    taskEXIT_CRITICAL();
    for (;;) {
        if (st == BHI160_RUNNING) {
            drain_fifo();
        }
        vTaskDelay(POLL_MS / portTICK_RATE_MS);
    }
}

void bhi160_start(void)
{
    xTaskCreate(bhi160_task, "BHI160", 1024, NULL, 2, NULL);
}

void bhi160_reset_angles(void)
{
    taskENTER_CRITICAL();
    memset(s_angle_udeg, 0, sizeof(s_angle_udeg));
    memset(s_data.angle_mdeg, 0, sizeof(s_data.angle_mdeg));
    taskEXIT_CRITICAL();
}

bool bhi160_get_sensor_info(uint8_t id, uint8_t *info)
{
    if (id == 0 || id >= 32 || !s_info_ok[id]) {
        return false;
    }
    memcpy(info, s_info[id], BHI160_INFO_LEN);
    return true;
}

void bhi160_get(bhi160_data_t *out)
{
    taskENTER_CRITICAL();
    *out = s_data;
    taskEXIT_CRITICAL();
}

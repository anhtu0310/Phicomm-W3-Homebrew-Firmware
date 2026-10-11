#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "hal.h"
#include "hal_pmu_internal.h"
#include "vibrator.h"

#define MAX_PULSE_MS    5000

/* One pattern step, as in the stock tables: LDO level for ms milliseconds.
 * A step with ms == 0 ends the pattern. */
typedef struct {
    uint8_t level;
    uint16_t ms;
} vib_step_t;

/* Copied from the stock firmware (pointer table at RAM 0x1001831C; the
 * patterns themselves are const data at 0x080DCEFE, 0x080DD036, 0x080DCFC2). */
static const vib_step_t s_notify[] = {
    {2, 200}, {0, 100}, {2, 200}, {0, 100}, {0, 0}
};
static const vib_step_t s_ramp[] = {
    {2, 100}, {0, 100}, {2, 100}, {2, 100}, {2, 100}, {1, 100}, {1, 100}, {0, 100}, {0, 0}
};
static const vib_step_t s_sos[] = {
    {2, 200}, {0, 100}, {2, 200}, {0, 100}, {2, 200}, {0, 300},
    {2, 500}, {0, 100}, {2, 500}, {0, 100}, {2, 500}, {0, 300},
    {2, 200}, {0, 100}, {2, 200}, {0, 100}, {2, 200}, {0, 100}, {0, 0}
};
static const vib_step_t *const s_patterns[VIB_PATTERN_COUNT] = { s_notify, s_ramp, s_sos };

/* Queue item: a pattern, or (pattern == NULL) a single pulse; a pulse of
 * 0 ms is "stop". */
typedef struct {
    const vib_step_t *pattern;
    vib_step_t pulse;
} vib_cmd_t;

static QueueHandle_t s_queue;

/* Only the VIBR task calls this, so s_level needs no lock. The PMIC register
 * writes themselves mask interrupts around the D2D-I2C read-modify-write. */
static void motor_set(uint8_t level)
{
    static const PMIC_LDO_VOSEL vosel[4] = {
        PMIC_LDO_1P3V /* unused */, PMIC_LDO_2P8V, PMIC_LDO_3P0V, PMIC_LDO_3P3V
    };
    static uint8_t s_level = VIB_LEVEL_OFF;

    if (level > VIB_LEVEL_3V3 || level == s_level) {
        return;
    }
    if (level == VIB_LEVEL_OFF) {
        PMIC_VR_CONTROL(PMIC_VIBR, PMIC_VR_CTL_DISABLE);
    } else {
        /* Set the voltage before enabling, as stock does; the LDO's reset
         * default voltage is not one the motor is meant to run at. */
        PMIC_VR_VOSEL_INIT_CONFIG(PMIC_VIBR, vosel[level]);
        if (s_level == VIB_LEVEL_OFF) {
            PMIC_VR_CONTROL(PMIC_VIBR, PMIC_VR_CTL_ENABLE);
        }
    }
    s_level = level;
}

static void vibrator_task(void *arg)
{
    vib_step_t pulse[2] = {{0, 0}, {0, 0}};
    const vib_step_t *step = NULL;
    TickType_t wait = portMAX_DELAY;
    vib_cmd_t cmd;

    (void)arg;
    for (;;) {
        if (xQueueReceive(s_queue, &cmd, wait) == pdTRUE) {
            if (cmd.pattern != NULL) {
                step = cmd.pattern;
            } else {
                pulse[0] = cmd.pulse;
                step = pulse;
            }
        } else if (step != NULL) {
            step++;                     /* current step's time is up */
        }
        if (step != NULL && step->ms != 0) {
            motor_set(step->level);
            wait = step->ms / portTICK_RATE_MS;
            if (wait == 0) {
                wait = 1;
            }
        } else {
            step = NULL;
            motor_set(VIB_LEVEL_OFF);
            wait = portMAX_DELAY;
        }
    }
}

void vibrator_init(void)
{
    s_queue = xQueueCreate(4, sizeof(vib_cmd_t));
    xTaskCreate(vibrator_task, "VIBR", 256, NULL, 4, NULL);
}

static bool send(const vib_cmd_t *cmd)
{
    return s_queue != NULL && xQueueSend(s_queue, cmd, 0) == pdTRUE;
}

bool vibrator_pulse(uint32_t ms, uint8_t level)
{
    vib_cmd_t cmd = { NULL, { level, (uint16_t)(ms > MAX_PULSE_MS ? MAX_PULSE_MS : ms) } };

    return level <= VIB_LEVEL_3V3 && send(&cmd);
}

bool vibrator_play(unsigned int pattern)
{
    vib_cmd_t cmd = { NULL, { 0, 0 } };

    if (pattern >= VIB_PATTERN_COUNT) {
        return false;
    }
    cmd.pattern = s_patterns[pattern];
    return send(&cmd);
}

bool vibrator_stop(void)
{
    vib_cmd_t cmd = { NULL, { 0, 0 } };

    return send(&cmd);
}

/*
 * Vibration motor.
 *
 * The motor hangs off the PMIC's VIBR LDO: switching the LDO on spins it, and
 * the LDO voltage sets the strength. The stock firmware drives it exactly this
 * way (vibrator_enable() at 0x0804C8D8: PMIC_VR_VOSEL_INIT_CONFIG(PMIC_VIBR,
 * 3.0 V) then PMIC_VR_CONTROL(PMIC_VIBR, on)) and plays "patterns": lists of
 * {level, ms} steps stepped by a one-shot software timer. We play the same
 * patterns from a small task that owns the motor: commands arrive on a queue
 * and the current step's length is the queue-receive timeout. So buzz timing
 * doesn't depend on how long the display loop takes, and a new command can't
 * race a step that is just ending.
 */
#ifndef __VIBRATOR_H__
#define __VIBRATOR_H__

#include <stdbool.h>
#include <stdint.h>

/* Strength = VIBR LDO voltage. Stock uses VIB_LEVEL_3V0 for everything. */
#define VIB_LEVEL_OFF   0
#define VIB_LEVEL_2V8   1
#define VIB_LEVEL_3V0   2
#define VIB_LEVEL_3V3   3

/* Stock patterns (table at RAM 0x1001831C, initial data in flash). */
#define VIB_PATTERN_NOTIFY  0   /* double buzz: 200 on, 100 off, x2 */
#define VIB_PATTERN_RAMP    1   /* 100 ms steps: 3.0 V, off, 3.0 V x3, 2.8 V x2 */
#define VIB_PATTERN_SOS     2   /* ... --- ... (stock "find me") */
#define VIB_PATTERN_COUNT   3

/* Create the queue and the VIBR task. Call once before the scheduler starts. */
void vibrator_init(void);

/* One buzz of ms milliseconds (capped at 5000) at the given level.
 * Replaces whatever is playing. Safe to call from any task. */
bool vibrator_pulse(uint32_t ms, uint8_t level);

/* Play a stock pattern; replaces whatever is playing. */
bool vibrator_play(unsigned int pattern);

/* Stop and switch the LDO off. */
bool vibrator_stop(void);

#endif /* __VIBRATOR_H__ */

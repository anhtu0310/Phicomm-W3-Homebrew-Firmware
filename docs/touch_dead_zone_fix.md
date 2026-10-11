# Fixing the touch dead zone: patching the CY8C4014 touch controller

This is a write-up of how the "bottom strip doesn't track" problem on the Phicomm W3 was tracked down and fixed. It covers the touch chip's firmware, its bootloader, a binary patch, and a new position algorithm on the MT2523. It's written to be followed step by step, with the reasoning behind each move.

**Result:** the screen's whole height now reports a usable position. The touch chip runs a 3-instruction patch (version `0x18`), and the MT2523 computes the position itself in `touch_slider.c`.

Contents:
1. [The symptom](#1-the-symptom)
2. [Background: how a capacitive slider works](#2-background-how-a-capacitive-slider-works)
3. [Finding the touch chip's firmware](#3-finding-the-touch-chips-firmware)
4. [Reverse engineering the touch firmware](#4-reverse-engineering-the-touch-firmware)
5. [Learning the bootloader protocol from the stock updater](#5-learning-the-bootloader-protocol-from-the-stock-updater)
6. [Designing the patch](#6-designing-the-patch)
7. [Flashing it](#7-flashing-it)
8. [The data: why the chip gives up](#8-the-data-why-the-chip-gives-up)
9. [Our own position algorithm](#9-our-own-position-algorithm)
10. [Side quests](#10-side-quests)
11. [Recovery and cheat sheet](#11-recovery-and-cheat-sheet)

---

## 1. The symptom

The touch controller reports one byte of position, 0–143, plus a "touching" flag. Over the bottom strip of the screen it always says 143. Nothing in our MT2523 code could change that, because the number is computed inside the touch controller, a Cypress **CY8C4014**. That's a tiny PSoC 4 microcontroller (Cortex-M0, 16 KB flash, 2 KB RAM) running its own firmware. The MT2523 reads results from it over I2C at address `0x08`.

So the investigation had to move *into* the touch chip.

## 2. Background: how a capacitive slider works

The touch area isn't a grid like a phone screen. It's a **linear slider**: a few electrodes laid out in a row under the glass. The chip measures each electrode's capacitance as a number, the **raw count** (about 13,400–14,000 here). A finger near an electrode adds capacitance, so its raw count goes up.

Three terms come up everywhere:

| Term | Meaning |
|---|---|
| **Raw count** | The measurement right now. |
| **Baseline** | What the raw count is with *no* finger. It's tracked slowly, so temperature drift doesn't look like a touch. |
| **Diff** (signal) | raw − baseline. A finger gives roughly 1,500–2,000 counts on the electrode under it. |

The chip decides "touching" when a diff exceeds the **finger threshold** (380 here). Diffs below the **noise threshold** (100 here) are treated as 0.

**Position** comes from a *centroid* (weighted average) of the electrode signals. This slider has only **3 electrodes**, with centres at 0, 72 and 144 in slider units:

```
position = 72 × (1·d1 + 2·d2) / (d0 + d1 + d2)
```

For example, a finger exactly between electrodes 1 and 2 gives equal d1 and d2. The formula then lands at 108, halfway between 72 and 144.

**The catch:** below the bottom electrode's centre, the only thing that keeps the position below 144 is a *small* signal on the middle electrode. If that small signal is treated as 0, the position snaps to the end. Keep that in mind.

## 3. Finding the touch chip's firmware

**Step 1: read more than 6 bytes.** The stock driver reads 6 bytes from register 0. Reading 32 showed that bytes 6–13 contain more data, and 14+ read as `FF`. So the chip exposes a **14-byte buffer**. That's Cypress's **EZI2C** component, which works like a small I2C-accessible RAM with a 16-bit "sub-address". Bytes 6–9 changed with touches, but only for touches near the top. They turned out to be the top electrode's raw count and baseline.

**Step 2: look for the chip's firmware inside the MT2523 firmware.** Products that ship a touch chip usually carry its firmware so they can update it. The stock firmware strings include `ctp_cy8c4014_update` and `Bootload Err :%s`. Searching the flash dump for Cypress's firmware file format found it.

Cypress bootloader files are **`.cyacd`** text files:

```
0A46119A0000                         <- header: silicon ID 0A46119A, rev 00, checksum type 00
:00005D0040<64 bytes of data>KK       <- one flash row
 ^^ ^^^^ ^^^^                ^^
 |  |    |                   row checksum
 |  |    data length (0x40 = 64)
 |  row number (0x5D = 93)
 array ID
```

156 such lines sit at flash offset `0xC1748`. They were extracted into `stock_fw/cy8c4014/stock_touch_fw.cyacd` and turned into a flat binary, with row *n* at address *n* × 64.

What the row numbers tell us:
- **Rows 93–255** are present. 93 × 64 = `0x1740`: the application starts there.
- **Rows 0–92** are missing. That's the chip's **bootloader**, which is never shipped or overwritten. That's good news: the bootloader stays intact whatever happens to the app, so a bad app can always be reflashed.

At `0x1740` sits a Cortex-M vector table: initial stack `0x20000800` (top of 2 KB RAM) and reset handler `0x1751`. That confirmed it's Thumb code and the image was assembled correctly.

## 4. Reverse engineering the touch firmware

Disassembled with `capstone` (Thumb mode). The full listing is in `stock_fw/cy8c4014/cy8c4014_app.asm`. Useful habits:

- **Search for the constants you already know.** The command bytes (`0x65` sleep, `0x67` wake, `0x41` reset) are known from the stock driver. A `cmp r3, #0x67` led straight to the **command handler**, which showed the whole command set. Each reply is the command plus 1. `0x43`/`0x45` set the finger threshold from bytes 10–11 or 12–13, and **`0xA5` jumps to the bootloader**.
- **Follow the literal pools.** Thumb code loads 32-bit constants from nearby "pools" (`ldr r4, [pc, #...]`). Values like `0x20000164` are RAM addresses. That one is the 14-byte I2C buffer.
- **Find the I2C buffer setup.** The firmware calls `EzI2C_SetBuffer1(size=14, rwBoundary=14, buffer)`:
  ```
  0x1990  movs r1, #0xe     ; rwBoundary = 14
  0x1992  movs r2, r4       ; buffer = 0x20000164
  0x1994  movs r0, r1       ; size = 14   <- the line we'll patch
  0x1996  bl   SetBuffer1
  ```
  The argument order was confirmed in the I2C interrupt handler. The first value rejects any offset ≥ it (the size). The second limits how many bytes can be *written* (the boundary).
- **Find the CapSense configuration.** A table at `0x3C20` describes each "widget", 0x24 bytes each. Widget 0 is type 2 (**linear slider**) with **3 sensors** and resolution **144**. Widget 1 is a 1-sensor proximity sensor. The defaults at `0x3C00` give finger threshold 380, noise threshold 100, hysteresis 10.

The key discovery: the CapSense data RAM (`0x20000174`, all the raw counts and baselines) sits **right after** the 14-byte I2C buffer (`0x20000164`). If the I2C window were simply bigger, the host could read everything.

## 5. Learning the bootloader protocol from the stock updater

To change the firmware, we have to talk to the chip's bootloader. The stock MT2523 firmware already does that, so its updater was disassembled. It's Cypress's standard **Bootloader Host** library (`CyBtldr_Program`), configured with:
- **When to update:** read the version byte. If it's **≤ `0x18`**, update.
- **Enter the bootloader:** write `00 04 A5` (command `0xA5`), then wait **500 ms**.
- **Packets:** written to I2C address `0x08` in one write. Wait 20 ms, then read the reply. At most **64 bytes** per packet.

**Packet format** (same in both directions):

```
01 | cmd (or status in replies) | len lo | len hi | data... | chk lo | chk hi | 17
```

`chk` is the 16-bit two's complement of the sum of all bytes before it. "Enter bootloader" is therefore `01 38 00 00 C7 FF 17`. Recognising that well-known byte sequence is a good sanity check.

| Cmd | Name | Reply data |
|---|---|---|
| `38` | Enter bootloader | silicon ID (4), rev (1), bootloader version (3) |
| `32` | Get flash size | first row, last row |
| `37` | Send data | (a chunk of a row; buffered) |
| `39` | Program row | array ID, row, remaining data → erase + write |
| `3A` | Verify row | 1-byte checksum of that row *as stored in flash* |
| `31` | Verify app checksum | non-zero = valid |
| `3B` | Exit | none; the chip resets and starts the app if it's valid |

A 64-byte row doesn't fit in one 64-byte packet with the header, so it goes as one `37` with 57 bytes plus a `39` with the last 7.

## 6. Designing the patch

Three 2-byte changes (`tools/cy8c_patch.py`):

| Address | Before | After | Why |
|---|---|---|---|
| `0x1994` | `movs r0, r1` | `movs r0, #0x88` | I2C window 14 → **136 bytes**, so the CapSense RAM becomes readable. The write boundary stays 14, so the host still can't write into it. |
| `0x1970` | `movs r3, #0x19` | `movs r3, #0x18` | Version `0x18`. If the **stock** MT2523 firmware ever runs again, it sees ≤ `0x18` and restores the stock touch firmware automatically. That's a free safety net. |
| `0x197A` | `adds r3, #0x64` | `adds r3, #0x65` | The firmware computes the finger threshold from the same register (`0x19 + 0x64 + 0xFF = 380`). With `0x18` this keeps it at 380. |

**Checksums.** The bootloader only starts an app whose checksum matches. Two kinds:
1. **Per-row checksum in the `.cyacd`:** two's complement of the line's byte sum. The patch tool recomputes it.
2. **App checksum:** byte 0 of the **metadata row** (row 255). It's the two's complement of the 8-bit sum of every app byte, from row 93 for the length stored in the metadata (`0x26C0`). Before trusting this formula, the tool recomputes it on the *stock* image. It matched (`F6`), so the formula is right. Patched value: `56`.

Only rows **101, 102 and 255** differ from stock.

## 7. Flashing it

The PC can't reach the touch chip's I2C bus, so the watch relays packets.

**On the watch** (`w3_display`, USB AT commands):

| Command | Does |
|---|---|
| `AT+TPPAUSE=1` / `=0` | stop / resume our own touch polling. `=0` also re-wakes the chip. |
| `AT+TPW=<hex>` | raw I2C write |
| `AT+TPRD=<n>` | raw I2C read |
| `AT+TPBL=<hex>,<n>` | write a packet, wait 20 ms, read an *n*-byte reply. Retries while the reply doesn't start with `01`, because the bootloader returns `FF` until it's ready. |
| `AT+TPR=<reg>,<n>` | normal register read (16-bit sub-address) |

**On the PC:** `tools/cy8c_bootload.py` builds packets, checks every reply's length, checksum and status, and retries garbled replies. The steps, in order of increasing risk:

1. `info`: enter, print IDs, exit. The result was silicon ID `0A46119A` rev 00 (matches the file), bootloader 1.32.1, app rows 93–255.
2. `verify stock_touch_fw.cyacd`: compares every row's checksum with the file and **writes nothing**. All 156 rows matched and the app checksum was valid. That proved the chip runs exactly the extracted firmware *and* that the tool's maths is right.
3. `program --diff stock_touch_fw.cyacd patched_touch_fw.cyacd`: writes only rows that differ from stock (1.8 s).

**Lesson learned:** the first attempt picked "changed rows" by comparing the chip's *row checksums* with the file, and it missed row 101. That row's two edits (`19→18` is −1, `64→65` is +1) cancel out in an 8-bit sum, so the checksum doesn't change. An 8-bit checksum can't prove two rows are equal. Now rows are selected by comparing **file contents** (`--diff`), and checksums are only used to confirm a write.

After flashing, `AT+TPR=0,64` returns the CapSense RAM:

| Window offset | Contents |
|---|---|
| `0x00` | the 14-byte app buffer (version now `0x18`) |
| `0x2A` | slider settings: resolution, finger threshold 380, noise threshold 100, ... |
| `0x4A` / `0x58` / `0x66` | electrode 0 (top) / 1 / 2 (bottom): raw u16, baseline u16, ... (14 bytes each) |
| `0x74` | proximity electrode |

## 8. The data: why the chip gives up

With all three electrodes logged at 10 Hz (`tp …` lines), a slow swipe into the bottom strip looked like this. "Ours" means measured against the idle raw count just before the touch:

| Chip position | Middle electrode, chip's diff | Middle electrode, **our** diff | Bottom electrode, our diff |
|---|---|---|---|
| 100 | 1586 | 1865 | 1170 |
| 128 | 338 | 920 | 1880 |
| **143** | 71 | **660** | 1915 |
| **143** | −268 | **320** | 1925 |
| **143** | −10 | **90** | 1865 |
| **143** (held at the bottom) | −10 | **55–65** | 1790 |

**What's happening:** the chip's **baseline creeps up under a resting finger**. You can see it in the logs: the baseline rises about 40 counts every 150 ms while touched. So the chip's view of the middle electrode's fading signal hits its noise threshold (100) early, even goes negative, and the position snaps to 143. The real signal is still clearly there and fades smoothly to about 60 at the bottom edge. It never reaches zero. The same creep also makes a long press fade out.

So the "dead zone" wasn't missing hardware. It was **signal processing**: baseline drift combined with a noise threshold.

## 9. Our own position algorithm

`src/touch_slider.c` runs on the MT2523 every 50 ms:

1. **Read the window** (106 bytes, through electrode 2's raw count).
2. **Our own baseline per electrode.** It only updates while *not* touching, with a slow IIR (1/8 per update) and only for changes under 150 counts. While touched it's **frozen**. If it's off by more than 150 for 1 s while idle, it resyncs.
3. **Signals** = raw − our baseline. Values below a noise floor become 0: 120 for the top electrode, which jitters ±70 between two levels, and 25 for the others (±10). Negative values also become 0, because a finger at the bottom pulls the top electrode slightly *below* its baseline.
4. **Touch detection**: the sum of signals goes above 400 → down, below 250 → up. The gap between the two (hysteresis) stops flicker. Because the baseline is frozen, a long press no longer fades.
5. **Centroid**: `72 × (d1 + 2·d2) / sum`, giving 0–144.
6. **Screen row**: the top and bottom edges of the glass measured about 10 and 141, so `row = (pos − 10) × 143 / 131`, clamped to 0–143.

Checked against the logged swipe: the chip's 143 region now reads 126 → 131 → 135 → 139 → 141 → 142, and holding at the bottom gives row 143.

**Tuning knobs:** `POS_TOP`/`POS_BOTTOM` (edge calibration), `TOUCH_ON`/`TOUCH_OFF`, and the noise floors. All live at the top of `touch_slider.c`.

## 10. Side quests

- **Random reboots / "silent" USB.** The boot counter in the log (`boot=N`) showed real reboots with no watchdog. Brief **VBUS dips** (USB power) looked like "cable plugged in", and the firmware's "plug-in → reboot into download mode" rule fired. This unit runs from USB alone, where a real unplug just powers it off, so that rule only ever fired on glitches. Now USB must be absent ≥ 2 s to count, and shorter dips are logged as `usb: VBUS glitch`. The dips themselves point to the cable or port. A powered hub or another cable helps.
- **Garbled replies.** Rarely, a reply line over USB loses characters. Every tool checks lengths and checksums and retries, so it's harmless.
- **ModemManager** probes new `ttyACM` ports and briefly blocks them. The tools retry opening the port.
- **Front light.** The stock `AT+EBLT=<n>` handler drives the PMIC's **ISINK channel 0** in register mode at 2 MHz with 4/8/12 mA. Our firmware turns it on at 8 mA at boot, and `AT+BL=<0..3>` changes it.

## 11. Recovery and cheat sheet

**Go back to the stock touch firmware:**

```bash
python3 tools/cy8c_bootload.py program stock_fw/cy8c4014/stock_touch_fw.cyacd
```

Or flash the stock MT2523 firmware: it sees version `0x18` and restores the stock touch firmware by itself. If a touch update is interrupted, the chip stays in its bootloader (the app checksum is invalid) and the same command can be run again.

**Commands:**

```bash
# Patch tool: stock .cyacd -> patched .cyacd (verifies the stock checksum first)
python3 tools/cy8c_patch.py stock_fw/cy8c4014/stock_touch_fw.cyacd stock_fw/cy8c4014/patched_touch_fw.cyacd

# Touch bootloader (via the watch's USB AT port)
python3 tools/cy8c_bootload.py info
python3 tools/cy8c_bootload.py verify  stock_fw/cy8c4014/stock_touch_fw.cyacd
python3 tools/cy8c_bootload.py program --diff stock_fw/cy8c4014/stock_touch_fw.cyacd stock_fw/cy8c4014/patched_touch_fw.cyacd

# Watch log to a file
stty -F /dev/ttyACM0 raw -echo && cat /dev/ttyACM0 | tee touch_log.txt

# Reboot the watch / flash the MT2523 firmware
stty -F /dev/ttyACM0 raw -echo && printf 'AT+EWDT=1\r' > /dev/ttyACM0
python3 tools/mt2523_flash.py --reboot-from /dev/ttyACM0 --timeout 60 write 0x08010000 linkit_sdk-master/out/mt2523_hdk/w3_display/w3_display.bin
```

**Files:**

| File | What |
|---|---|
| `stock_fw/cy8c4014/stock_touch_fw.cyacd` | the touch firmware extracted from the stock flash |
| `stock_fw/cy8c4014/patched_touch_fw.cyacd` | the patched version (rows 101, 102, 255 differ) |
| `stock_fw/cy8c4014/cy8c4014_app.asm` | disassembly of the touch app |
| `tools/cy8c_patch.py` | applies the patch and fixes checksums |
| `tools/cy8c_bootload.py` | bootloader host over the watch's USB passthrough |
| `tools/touch_probe.py` | PC-side electrode logger (polls over AT) |
| `…/w3_display/src/touch_slider.c` | our baseline, touch detection and position |
| `HARDWARE.md` | register map and command reference |

**Ideas for next steps:**
- Calibrate `POS_TOP`/`POS_BOTTOM` by touching the exact edges, and check that the row tracks the finger linearly in the middle too.
- Use the proximity electrode (`0x74`) for wake-on-approach.
- Lower the chip's own noise threshold in the firmware defaults (`0x3C04`). This isn't needed for our algorithm, but it's a nice next patch to practise on.

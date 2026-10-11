# Phicomm band (MT2523G) — hardware map

This map was recovered from the running stock firmware without opening the case. It comes from the factory AT interface (live GPIO and RAM reads) and from disassembling a full flash dump.
Confidence: **[C]** confirmed from code or live registers; **[L]** likely, from strong circumstantial evidence; **[?]** unknown.

## Device
- Product: **Phicomm W3** band. The firmware project is `project/mt2523_hdk/apps/phicomm_band`, built 2018-05-30 on LinkIt SDK 4.x. Serial `A1EL0087J8`.
- `AT+EVERINFO=0` returns `W3_B0_V1.21_A01_0530_WB`. Read as: model W3, HW rev B0, FW V1.21, build 05-30. `AT+EVERINFO=1` returns `mt2523_hdk`.
- SoC: MT2523G, a Cortex-M4 (r0p1) with built-in PMIC, charger and fuel gauge, BT/BLE, and in-package GNSS.
- Flash: 4 MB SFC at `0x08000000`. PSRAM: 4 MB at `0x00000000` (and its alias at `0x10000000`). TCM: 128 KB at `0x04008000`.

### Flash layout (same as the SDK `flash.ld`)
| Range | Content |
|---|---|
| 0x08000000–0x0800FFFF | Bootloader |
| 0x08010000–~0x081D0000 | Application. Reset vector is 0x08010001 |
| 0x080D0104 (inside the app) | BHI160 RAM patch, 19500 B, extracted to `stock_fw/bhi160_ram_patch.fw` |
| 0x083F0000 | NVDM (settings, barcode, user data) |

## USB (normal mode, VID:PID 0e8d:0023, 2× CDC-ACM)
- `ttyACM0` = USB COM1 = **ATCI**: factory AT commands, 115200 baud (ignored over USB).
- `ttyACM1` = USB COM2 = **syslog**. Most modules are off. Turn them on with `AT+SYSLOG=<module>,0,<level>`.

The full list of factory AT commands, with test results, is in [Factory AT command reference](#factory-at-command-reference) below.

## Pin map (live config decoded with `hal_pinmux_define.h`)
| GPIO | Mode | Use |
|---|---|---|
| 2 / 3 | U3RXD / U3TXD | **GNSS UART** (HAL_UART_3) [C] |
| 10 | GPIO out | **GNSS LDO enable** (`BSP_GNSS_POWER_PIN`=10) [C] |
| 12 | EINT10 | **GNSS interrupt** [C] |
| 16 / 17 | U0RXD / U0TXD | UART0, the SDK debug UART; look for test pads [L] |
| 36 / 37 | SCL0 / SDA0 | **I2C0, sensor bus, 400 kHz** [C] |
| 8 / 9 | EINT7 / EINT8 | Sensor interrupts: BHI160 and PAH8011, set up in sensor init [C/L] |
| 19 / 20 | SCL2 / SDA2 (mux set only while in use) | **I2C2, touch controller bus** [C] |
| 13 | EINT11 | Touch interrupt [L] |
| 48 | GPIO out | **PPG (PAH8011) LED power enable**, high = on. The stock `pah_ppg1_operate()` drives it [C] |
| 40 / 41 | MA_SPI2_B SCK / MOSI | **LCD SPI** (HAL_SPI_MASTER_2) [C] |
| 39 | GPIO out | **LCD SCS, active high**, toggled by software [C] |
| 15 | GPIO out (high) | **LCD DISP on** [C] |
| 11 | PWM0 | LCD EXTCOMIN (VCOM toggle). 120 Hz awake, 20 Hz asleep, 10% duty [L] |
| 6 | GPIO out | [?] Possibly an LED, which the SDK's `AT+ELED` drives on GPIO4/5/6 |
| Others | Pulled down | Unused |

## Peripherals
| Part | Bus / address | Notes |
|---|---|---|
| **Bosch BHI160** sensor hub (accel + gyro, **no magnetometer**) | I2C0 **0x28** | Needs the RAM patch uploaded at boot (working, see "BHI160 sensor hub" below). Virtual sensors used: step, activity, sleep, swim, wrist-tilt, PDR. Gyro self-test passes; mag is "undefined" [C] |
| **PixArt PAH8011** PPG heart-rate | I2C0 **0x15** | Product ID 0x11. Driver v1008, reg table v1006, PixArt pah8series algorithm v5421. Only PPG channel B is used. LED power is enabled by GPIO48. Factory test PASS. Working with our driver: see "PAH8011 heart-rate sensor" below [C] |
| **Cypress CY8C4014** (PSoC 4) touch key/slider | I2C2 **0x08** | Custom PSoC firmware with "swimming mode" (water lock) and a watchdog [C] |
| **Display: JDI colour memory-in-pixel LCD, 72×144** | SPI2, 1 MHz, mode 0, MSB first | Likely the JDI LPM009M360A (0.86"); check the FPC marking [L] |
| GNSS: **MT3333** (in-package), FW `AXN_5.10_3333_18031200` | UART3 + EINT10 + LDO on GPIO10 | GPS+GLONASS NMEA at 1 Hz. SDK GNSS middleware; EPO assist supported. 3D fix outdoors with our firmware, see "GNSS" below [C] |
| Vibration motor | PMIC VIBR LDO, 3.0 V | Stock `vibrator_enable()` (`0x0804C8D8`) = `PMIC_VR_VOSEL_INIT_CONFIG(PMIC_VIBR, PMIC_LDO_3P0V)` + `PMIC_VR_CONTROL(PMIC_VIBR, 1)`. Working in `w3_display` [C] |
| Battery / charger | Internal PMIC + FGADC fuel gauge | SDK `battery_management` [C] |
| Power key | PMIC PWRKEY, active low (pulled up inside the PMIC) | SDK `keypad powerkey`. **No button is fitted on this unit**; the touch strip is the only input [C] |
| Barometer | **None** | The factory test `hw_auto_002` fails, and no driver exists [C] |
| Magnetometer | **None** | `sanity` reports "Mag FAIL"; the sensor manager reports type 1 as undefined [C] |

## Display protocol (from the stock driver)
Each SPI frame is sent with SCS high. The display needs a ≥6 µs setup time after SCS goes high.

| Command | Bytes | Meaning |
|---|---|---|
| `0x20 0x00` | 2 | All clear |
| `0x90, line, 36 data bytes` | 38 per line | 4-bit mode: 72 px × (R,G,B,dummy) |
| `0x80, line, 27 data bytes` | 29 per line | 3-bit mode |
| `0x88, line, 9 data bytes` | 11 per line | 1-bit mode |
| `0x00 0x00` | 2 | Trailing dummy |

- The line address is 1–144. The stock driver writes `144 - y`, so the panel is mounted rotated.
- Colour comes from thresholding RGB565: R ≥ 0x8000, G6 > 31, B5 > 15. That gives 8 colours.
- Init sequence: SPI init, then all-clear, then DISP high, then wait 30 ms, then start EXTCOMIN PWM.

## Touch controller (CY8C4014) protocol and internals
The stock MT2523 firmware embeds the touch chip's application as a `.cyacd` image (flash `0xC1748`, silicon ID `0A46119A`, 64-byte rows 93–255; rows 0–92 are the on-chip bootloader and are not included). It has been extracted to `stock_fw/cy8c4014/`: the `.cyacd`, a flat binary and a disassembly. The image writes version `0x19` to byte 3, the same value this unit reports, so this is the firmware that is running. [C]

It is a Cypress CapSense (v3+ data structures) project with two widgets [C]:
- **Widget 0: linear slider with only 3 electrodes**, centroid resolution 144 (multiplier `0x4800`). Finger threshold 380, noise threshold 100, hysteresis 10, on-debounce 2, 14-bit scan.
- Widget 1: proximity sensor, 1 electrode, used for wake-up.

**EZI2C buffer at address 0x08: 14 bytes, all writable.** In the stock firmware, offsets above 13 read as `FF` and the CapSense data RAM (`0x20000174`) is not exposed. **This unit now runs a patched touch firmware (version `0x18`)** whose readable window is 136 bytes; see below and `docs/touch_dead_zone_fix.md`.

| Offset | Meaning |
|---|---|
| 0 | Slider position 0–144 (`FF` = no touch) |
| 1 | 2 = idle, 3 = touching |
| 2 | Movement direction while touching: 1 = position increased, 2 = decreased (by more than 9), 0 = still |
| 3 | Firmware version (`0x19`) |
| 4 | Command / reply register (see below) |
| 5 | Number of active slider electrodes (popcount of the sensor status). The stock driver discards events with 3 as a "large touch" |
| 6–7 | Electrode 0 (top) raw count, LE |
| 8–9 | Electrode 0 baseline, LE. It creeps towards the raw count during a long touch and resets on release |
| 10–11 | Normal finger threshold (default 380) |
| 12–13 | Swim-mode finger threshold (default 1000) |

Commands are written to offset 4 (`00 04 <cmd>`); the chip replies `<cmd>+1`, except where noted:
`0x41` software reset · `0x43` finger threshold = bytes 12–13 · `0x45` finger threshold = bytes 10–11 · `0x59` swim mode on (reply `0x60`) · `0x61` swim mode off · `0x65` deep sleep · `0x67` wake · `0x69` reset baselines (reply `0x70`) · `0xA5` jump to bootloader.

**Bottom dead zone (explained and fixed):** the chip's baseline creeps up under a resting finger (about 40 counts per 150 ms). So the middle electrode's fading signal drops below the noise threshold (100), and the centroid snaps to 143/144. With a baseline frozen during the touch, that signal still fades smoothly to about 60 at the bottom edge. The MT2523 now computes the position itself from the raw counts (`w3_display/src/touch_slider.c`). [C]

**Patched touch firmware (version `0x18`)**, made by `tools/cy8c_patch.py` and flashed with `tools/cy8c_bootload.py`:
- **Readable window 136 bytes.** Writes are still limited to offsets 0–13.
- **Version byte:** a stock MT2523 firmware would restore the stock touch firmware itself, because it updates whenever the version is ≤ `0x18`.

| Window offset | Contents |
|---|---|
| `0x00` | App buffer (table above) |
| `0x10` | CapSense data RAM starts (`0x20000174`) |
| `0x2A` | Slider widget RAM: resolution, finger threshold u16, noise threshold, negative noise threshold, hysteresis, on-debounce, low-baseline reset, IDAC, sense clock …, position at `+0x0E` (finger threshold at `+2` and position at `+0x0E` confirmed; the other names follow the CapSense defaults table at flash `0x3C00`) |
| `0x38` | Proximity widget RAM |
| `0x4A` / `0x58` / `0x66` | Electrode 0 (top) / 1 / 2 (bottom): raw u16, baseline u16, … (14 bytes each) |
| `0x74` | Proximity electrode |

**Touch bootloader** (rows 0–92, version 1.32.1):
- **Entering it:** the app enters it on command `0xA5`; wait 500 ms afterwards.
- **Packets:** `01 cmd lenLE data chkLE 17`, where the checksum is the 16-bit two's complement of the byte sum. Maximum 64 bytes per packet.
- **Commands:** `38` enter, `32` flash size, `37` send data, `39` program row, `3A` verify row, `31` verify app, `3B` exit.
- **App checksum:** byte 0 of row 255, the two's complement of the 8-bit sum of rows 93–247. [C]

## BHI160 sensor hub (working in `w3_display`)
Driver: `w3_display/src/bhi160.c`. The register map and sequences follow Bosch's BHy1 driver (`ref/BoschSensorHub`). [C]
- **Bus:** I2C0 at 400 kHz, address `0x28`, product ID `0x83`, ROM `0x2DAD` (revision DI03). The pins are already muxed by the EPT config.
- **Use polling transfers only** (8 bytes per transaction max). The HAL's DMA path took ~30 ms per transfer, and 17-byte writes corrupted the upload.
- **RAM patch** (`stock_fw/bhi160_ram_patch.fw` → `inc/bhi160_fw.h`):
  - **Header:** `2A 65` signature; flags `0x1A00` mean ROM DI03; CRC `0xC69A2374`; 19,484 data bytes.
  - **Upload:** reset (`0x9B`=1), wait 10 ms, chip control `0x34`=`0x02`, upload address `0x94`/`0x95`=0. Then write 4 bytes at a time to `0x96`, **each 4-byte word byte-reversed**.
  - **Finish:** compare the CRC at `0x97` with the header, then set `0x34`=`0x01` (run). The upload takes about 1 s.
  - **Result:** the patch reports RAM version `0x2DB0`, then puts meta event 16 ("initialized") in the FIFO.
- **Sensor config:**
  - Write 8 bytes to `0x5C` (two 4-byte writes): rate Hz, latency ms, sensitivity, range.
  - Then page `0x54`=3 and request `0x64`=`0xC0`+ID.
  - Poll the acknowledge register `0x3A` until it echoes the request, then write 0 to `0x64` and `0x54`.
  - Accelerometer (ID 1) and gyro (ID 4) are accepted. **The standard step counter (ID 19) is not in this patch** (ack `0x80`; its info block is all zeros).
- **Pedometer = custom sensor 29 (CUS4).**
  - **Stock code:** `bhi160_pedometer_operate` at `0x08039B80` enables it at 10 Hz, latency = the "Cust" value (0 by default).
  - **Event:** 3 bytes = ID + u16, the step count.
  - **Ours:** enabled with the same settings, ack `0xDD`. The value isn't yet confirmed on a counted walk.
- **Sensor list:** read from the hub at boot. Each block is page 3, parameter = sensor ID (no write bit), 16 bytes from `0x3B`: `[0]` ID, `[1]` driver ID, `[2]` version, `[8..9]` max rate, `[14]` **event size including the ID byte**, `[15]` min rate.
  - **IDs and driver IDs present:**
    - 1 accel (48), 2 mag (11), 3 orientation (254), 4 gyro (49)
    - 14 uncalibrated mag (11), 15 game rotation vector (252), 16 uncalibrated gyro (49), 17 significant motion (250)
    - 18 (137, 7 B; stock uses it for **swim**), 20 geomagnetic rotation vector (253)
    - 22 tilt (236, 2 B), 23 wake (232), 24 glance (234), 25 pick-up (233)
    - 27 CUS2 (147, 2 B, stock **activity**), 28 CUS3 (148, 1 B), **29 CUS4 (149, 3 B, stock pedometer)**, 30 CUS5 (165, 8 B, stock **sleep**)
  - **Absent:** 5–8, 13, 19, 21, 31. Not captured: 9–12 and 26 (log lines were dropped). Stock uses 26 (CUS1) for **PDR** at 50 Hz.
  - **The log drops lines:** a burst of 31 lines overflows the USB log's transmit buffer, so the firmware now logs 4 per 0.5 s.
  - **Stock feature → sensor ID:** acc 1 @20 Hz, orientation 3 @10, gyro 4 @20, mag 14 @10, swim 18 @25, tilt 22 (wake-up) @10, wake gesture 23 (wake-up) @10, PDR 26 @50, activity 27 @10, pedometer 29 @10, sleep 30 @1.
- **FIFO:** bytes waiting at `0x38` (u16). Data is read from `0x00`; each read continues at `(reg + n) % 50`. Event = ID byte + payload (Bosch frame sizes: vector 8, quaternion 11, meta 4, timestamp 3, …).
- **Scaling verified:**
  - **Accelerometer** ±4 g: 1000 mg at rest.
  - **Gyro** ±2000 °/s: zero at rest, and its integrated angle matches a 90° turn.
  - **Rate:** 25 Hz (about 24.5 samples/s measured).

## GNSS (in-package MT3333; working in `w3_display`, `src/w3_gnss.c`)
**Status (2026-10-11): 3D fix outdoors.** Indoors it sees 0 satellites. Stock firmware uses GPS for sport tracks (`outdoor_/hiking_/cycling_/swimming_sport_gps_append`), track records with lat/lon/speed/altitude, and sunrise/sunset time, so the board has a real antenna. [C]

- **Power and data:** the same SDK GNSS middleware as stock (`middleware/MTK/gnss`, identical log strings). LDO enable is GPIO10 high, the interrupt is EINT10, UART3 runs at 115200 8N1 with DMA VFIFO. Use `gnss_init()` → `gnss_power_on()` → `gnss_read_sentence()`.
  - `gnss_driver_init_coclock()` is an undefined weak symbol, so the linker turns the call into a `nop`. That's fine: the stock bootloader calibrates the DCXO.
  - The HDK's 32 kHz clock output on GPIO13 is compiled out, so it doesn't clash with the touch EINT.
- **Receiver firmware:** `$PMTK605` returns `$PMTK705,AXN_5.10_3333_18031200`, the same as stock.
  - **Commands are ignored right after power-on,** so retry until answered (we resend every 5 s).
  - `gnss_send_command()` only writes once the middleware state is `POWER_ON`, which happens on the first UART data.
- **At boot** it sends `$PMTK010,002`, meaning EPO aiding is wanted. EPO is optional; it only shortens the first fix.
- **Output:** about 8 sentences/s at 1 Hz, talker `GN` (GPS+GLONASS combined): RMC, GGA, GSA, GSV (`GP`/`GL`), VTG, ACCURACY. Before the first satellite, the time counts from 1980-01-05 00:00 (RMC `050180`). Once any satellite is tracked, RMC carries the correct UTC time and date, even without a fix.
- **Parsed fields** (checksum-checked): RMC (time, date, valid, lat/lon, speed), GGA (satellites used, HDOP, altitude), GSA (2D/3D), GSV (satellites in view per GPS/GLONASS, best C/N0).
- **Time to fix:** a cold start needs about 30–40 s of *uninterrupted* signal per satellite to download its ephemeris, and at least 4 satellites for 3D.
  - **Observed:** 2 min after power-on near a wall, 6 satellites in view (C/N0 up to 42 dB-Hz) and no fix yet. A few minutes later, with more sky, it got a 3D fix.
  - **Keep fingers off the antenna:** the gold trace on the back, at the USB end.
- **Screen:** the GNSS page (tap the bottom strip) shows fix state, UTC time and date, satellites used and in view (GP/GL), max SNR, lat/lon, altitude and HDOP. The log prints a `gnss …` summary plus raw `$GNRMC`/`$GNGGA`/GSV lines once a second.
- **Stock GPIO6** is only the SDK `AT+ELED` test LED (GPIO4/5/6), not an antenna amplifier enable.
- **Assistance (`tools/w3_gnss_assist.py` + firmware), added 2026-10-11:**
  - **Time aiding:** `$PMTK740,YYYY,MM,DD,hh,mm,ss` (UTC), ack `$PMTK001,740,3`. The firmware sends it automatically from the RTC at GNSS start when the RTC is set (retried every 5 s, up to 6 times); the tool sends it too.
  - **Position aiding:** `$PMTK741,lat,lon,alt,YYYY,MM,DD,hh,mm,ss`. The tool uses `--lat/--lon`, or the last fix it saw (`epo/last_fix.json`, saved whenever the watch reports a fix through `AT+GNSSFIX?`).
  - **EPO:**
    - The file is `http://wepodownload.mediatek.com/EPO_GR_3_1.DAT`, downloaded without a key (2026-10-11): 48,384 bytes = 12 segments × 6 h × (32 GPS + 24 GLONASS) × 72-byte records.
    - **Record format:** 18 little-endian words. Byte 3 is the satellite ID (GPS 1–32, GLONASS 65–88). The low 24 bits of a segment's first word are its start in hours since 1980-01-06.
    - **Upload, as in the SDK's `gnss_get_location/src/epo_demo.c`:** only the **current** segment, one `$PMTK721,<sat hex>,<18 words hex>` per satellite. The receiver keeps one record per satellite, so later segments overwrite earlier ones.
    - **Ack:** `$PMTK001,721,3,<sat>,<bits>`. The data lives in receiver RAM, so re-send it after power-up and every 6 h. `$PMTK607` → `$PMTK707` still reports 0 "stored" sets, because that counts flash-stored EPO only.
    - **Firmware commands:** `AT+GNSSCMD=<body>` (checksum added), `AT+GNSSLAST?` (last PMTK reply), `AT+GNSSFIX?` (`valid,lat*1e7,lon*1e7,alt_dm,sats`).
  - **Benefit:** the effect on time-to-fix is not measured yet (needs an outdoor test).

## PAH8011 heart-rate sensor (working in `w3_display`: `src/pah8011.c`, `src/heart_rate.c`)
**Status (2026-10-11):** the LED lights and real PPG samples arrive. The driver is a port of the **stock firmware's own driver** (v1008, reg table v1006), reconstructed by disassembling the stock binary (code at flash `0x0803C400`–`0x0803E000`; function names come from its log strings). PixArt's open driver (`ref/pah8011-qcom-adsp-driver`, v1004, BSD licence) was the guide to reading that code. Heart rate is our own algorithm, because PixArt's pah8series v5421 algorithm is a closed library. [C]

### Hardware
- **I2C0 at `0x15`**, shared with the BHI160 through `src/sensor_i2c.c` (one mutex, polling transfers of at most 8 bytes). Product ID: bank 0 register `0x00` = `0x11`.
- **GPIO48 = LED power enable, high = on.** The stock `pah_ppg1_operate()` drives it high before starting and low after stopping (the pin number `0x30` is stored at flash `0x0813A163`). Without it the chip still answers on I2C and its FIFO fills at 20 Hz, but the LED stays dark and every sample reads 0.
- **Interrupt:** EINT8 (GPIO9). We don't use it; we poll.
- **Power saving (ours):** the sensor measures only while the heart-rate page is shown (`pah8011_set_active`). Otherwise it is powered down (bank 4 `0x69` = 1) with GPIO48 low, so the LED is off; the log shows `pah st=4`. Starting again: GPIO48 high, wait 100 ms, then the full `pah_enter_mode(4)` sequence.

### Register model
8-bit registers in banks 0–5; writing `0x7F` = bank selects one (the driver caches the current bank). Bank 1 `0x24` = 1 is the "update flag" that latches new settings (followed by a 2 ms wait). Bank 4 `0x69` = 1/0 is power-down/startup.

### Stock sequence (what `pah8011.c` does)
1. **`pah_init_with_flags({1,0,0,0})`:**
   - The flags mean: flag 0 = polling mode, flag 2 = LED-on-touch off, flag 3 = table set 0.
   - Check the product ID; if it fails, run startup and check again.
   - `device_init`: bank 4 `0x34` = 1, then shutdown.
   - Board setup: bank 4 `0x15` = `0x69`, `0x34` = 1, `0x2B` = `0xFE`, `0x70` = `0x18`. A stock helper returns `0x18`, which selects this branch; other boards would get `0x2B` = `0xFF`, `0x70` = `0x08`. Then shutdown.
2. **`pah_enter_mode(4)` (PPG + touch), part 1 (startup and init table):**
   - Startup, then the **stock init table** (34 writes, flash `0x080D700A`, also in `stock_fw/pah8011_stock_init.txt`), then the update flag.
   - Bank 1: `0x21`/`0x23`/`0x25` &= ~1, **`0x36` &= ~3**, `0x37` |= 2. Read `0x5A`: bit 0 means the touch flag is in FIFO bit 0.
   - Bank 1 **`0x35` &= ~2**, then the update flag.
   - Report size: bank 1 `0x57`/`0x56` = 20 samples × 1 channel + 1.
3. **`pah_enter_mode(4)`, part 2 (FIFO rate and PPG table):**
   - Clear the FIFO: bank 1 `0x70` = 1, update, wait 60 ms, `0x70` = 0, update, then read and clear bank 2 `0x1B`.
   - **PPG 20 Hz table** (flash `0x080D6FD7`; identical in the open driver), report size again, update flag.
4. **`pah_enter_mode(4)`, part 3 (start PPG, timing and touch):**
   - **`start_ppg`:** bank 1 `0x23` |= 1, **channel B only**, then the update flag.
   - **`start_tg`:** bank 1 `0x37` &= ~0x0D, `0x30` = 1, bank 2 `0x1B` = `0xFF`, bank 1 `0x37` &= ~0x10.
   - **`start_touch`:** bank 1 `0x36` &= ~3, `0x37` &= ~2, then the update flag.
5. **Polling (`_pah8011_task_polling`)** every 50 ms:
   1. Bank 2 `0x7C` = 0; read `0x1B` (int_req). `0x0C` = overflow/underflow, which means clear the FIFO.
   2. Read the sample count from `0x25` (u16) and touch from `0x00` bit 0. Frames = count − 1.
   3. **Enable the FIFO clock:** bank 1 `0x71` = 0, bank 0 `0x10` = 3.
   4. Read frames × 4 bytes from bank 3, register 0. Stock does this in one burst; we read 8-byte chunks, each from register 0, and that works.
   5. **FIFO clock off:** bank 1 `0x71` = 1, bank 0 `0x10` = 0.
   6. Clear: bank 2 `0x1B` = int_req.
   - There's no checksum in polling mode. One sample is 4 bytes, little-endian.
- **How the stock driver knows the channels:** they come from the init table itself. For `0x21`/`0x23`/`0x25`, bit 0 means PPG channel A/B/C is enabled, and bit 0 & bit 3 means that channel goes into the FIFO. The stock table has `0x21` = `0x68`, `0x23` = `0x69`, `0x25` = `0x68`, so **only channel B** is used.
- **LED in the stock app:** with flag 2 = 0, the stock driver never writes the LED registers (bank 0 `0x70`–`0x72`). `_pah8011_turn_led(1)` (`0x70`/`0x71`/`0x72` = 1/2/4; off = 0/0/0) only runs in the LED-on-touch configuration. The stock app also starts in mode 2 (touch only) and switches to mode 4 once touched; we go straight to mode 4.

### Heart rate (`heart_rate.c`)
- 8 s window at 20 Hz.
- Subtract a 0.75 s moving average.
- Normalised autocorrelation at lags 7–30 (171–40 bpm); the first strong local maximum is the beat period.
- Parabolic interpolation between lags.
- Accepted when the quality (peak × 100) is ≥ 50 and skin is touched.
- Recomputed every 0.5 s.
- **Screen and log:** page 3 (tap the bottom strip) shows BPM, a 3 s waveform, skin contact and quality. The log prints `ppgB …` raw samples and a `pah st=… touch=… n=… ovf=… fifo=… bpm=… q=…` line every second.

### How it was made to work (debug history)
| Build | Change | Result | Lesson |
|---|---|---|---|
| 1 | Open-driver sequence + **stock init table**, channels B+C, interrupt-mode FIFO read with checksum | All samples 0, "checksum OK" | XOR of all-zero data is 0, so the checksum proved nothing |
| 2 | + LED on (bank 0 `0x70`/`0x71`/`0x72` = 1/2/4) | Still 0, LED dark | — |
| 3 | Open driver's **full** 75-write table (it configures each channel's LED and exposure, LED on) | Still 0, LED dark | Not a table problem |
| 4 | **Port of the stock driver from the binary**: one channel, `0x36` &= ~3, `0x35` &= ~2, board setup, polling read with FIFO clock enable/disable | FIFO fills at 20 Hz, still 0, LED dark | The chip runs, so the LED has no power |
| 5 | + **GPIO48 high** (found in the stock `pah_ppg1_operate`) | **LED lights, real samples** | The missing piece was a board-level power switch, not a register |

**Takeaways:**
- When a sensor answers on I2C and even counts samples but reads 0, check the board-level power and enable pins the vendor app drives, not only the driver registers.
- Mixing one source's register table with another source's sequence is risky. The stock table was "incomplete" because the stock code fills in the rest at runtime.

## Clock (RTC), vibration, power key (`w3_display`, added 2026-10-11)
- **RTC:**
  - Keeps running across warm resets and reflashing, but **this battery-less unit loses it on unplug**.
  - `src/w3_time.c` keeps the RTC in **UTC** (`hal_rtc_set_time`, base year 2000) and shows local time with a timezone offset (default +7, `AT+TZ=`).
  - Set it with `AT+TIME=YYYY-MM-DD,HH:MM:SS` (UTC), or automatically from GNSS: once a minute, when RMC carries a real date (year 2024–2079), and only if the RTC is off by > 2 s. Verified within 1 s of the PC.
  - Watch face = page 0.
- **Vibration motor (working, `src/vibrator.c`):** PMIC VIBR LDO. [C]
  - **Stock driver:** `vibrator_enable()` at `0x0804C8D8` calls `PMIC_VR_VOSEL_INIT_CONFIG(PMIC_VIBR=11, PMIC_LDO_3P0V=6)`, then `PMIC_VR_CONTROL(PMIC_VIBR, 1)`; `vibrator_disable()` at `0x0804C910` calls `PMIC_VR_CONTROL(PMIC_VIBR, 0)`. **Set the voltage before enabling**; our first version only enabled the LDO.
  - **Stock patterns:** `custom_get_vib_patterns()` (`0x0804C7B8`) indexes a pointer table at RAM `0x1001831C` (`.data`, loaded from flash `0x08166B28` + offset − `0x10017D20`). Each step is `{u8 level, u8 pad, u16 ms}`, ending at ms = 0. Level 0 = off, 1 = 2.8 V, 2 = 3.0 V, 3 = 3.3 V. The player (`0x0804C68C`) steps them with the `uem_vibrate_timer` software timer.
    - 0 (`0x080DCEFE`) notify: 3.0 V 200 / off 100, twice.
    - 1 (`0x080DD036`): 100 ms steps 2,0,2,2,2,1,1,0.
    - 2 (`0x080DCFC2`) SOS: 200/100 ×3, off 300, 500/100 ×3, off 300, 200/100 ×3.
  - **Ours:** a `VIBR` task (priority 4) takes pulses and patterns from a queue; the step length is the queue-receive timeout. `AT+VIB=<ms>[,<level>]`, `AT+VIBP=<n>`, and the controls page.
- **Power key:** PMIC PWRKEY, initialised by `sys_init` (`hal_keypad_powerkey_init`); events are read with `hal_keypad_powerkey_register_callback` + `hal_keypad_powerkey_get_key`. Short press = next page, long press = cycle the front light, with a short buzz as feedback. Events are logged as `key: state=…`. *Not yet tested by pressing.*

## Bluetooth LE (`w3_display/src/w3_ble.c`, added 2026-10-11)
- **Stack:** the SDK's prebuilt BLE host `libble.a` (`MTK_BLE_ONLY_ENABLE=y`) and controller driver `libbtdriver_2523.a`. The stock firmware links the same driver: its strings match `libbtdriver_2523`, not the band variant `libbtdriver_2523_tx`. Nothing board-specific was needed: `bt_power_on()` works with the HAL as is. [C]
- **App hooks the libraries call:** `bt_app_event_callback` (events), `bt_get_gatt_server` (attribute table), `bt_gap_le_get_local_config` / `_pairing_config` / `_bonding_info`. None of them needs NVDM; we keep everything in RAM.
- **Address:** stock NVDM `BT/address` = `98BB993E7CDC` (record status `FC` = valid; older `68DB54…` records are `F8` = deleted), `BT/ble_address` = `98BB993E7CDB`. We use `98:BB:99:3E:7C:DC` (OUI 98:BB:99 = Phicomm) as the public address, hard-coded.
- **GATT:** GAP (0x0001–0x0005), GATT with Service Changed (0x0010–0x0013), W3 service `57330001-9c1e-4b8e-a0f3-1c5e9b7d3a42` (0x0020–0x002A): Time `…0002` (u32 Unix UTC + i8 tz, R/W), IMU `…0003` (16 bytes: u16 counter, raw acc xyz 8192 LSB/g, raw gyro xyz 16.4 LSB/(°/s), u16 ms; notify; write u8 = rate 1–25 Hz), Notify `…0004` (UTF-8 text ≤ 120 bytes, write; long writes supported). Max MTU 128.
- **Verified 2026-10-11:** advertising, connection from Android nRF Connect, service discovery, reads (IMU sample gave |a| = 1.02 g at rest).

## Front light
PMIC current sink **ISINK channel 0**, register mode, 2 MHz clock. The stock `AT+EBLT=1..3` uses 4 / 8 / 12 mA, and `=0` deinits it. `w3_display` turns it on at 8 mA at boot and switches it off 30 s after the last activity (touch, BLE message, `AT+BL`); the next touch turns it back on. `AT+BL=<0..3>` changes the level, `AT+BLTO=<s>` the delay. [C]

## Flashing
- **Untethered reflash** (`tools/mt2523_flash.py --reboot`, or `--reboot-from <port>`): our `AT+EWDT=1` now calls `hal_usb_deinit()` and waits 300 ms before `hal_wdt_software_reset()`. Resetting with the USB link still up often made the BROM download window go unnoticed, so the watch booted straight back into the firmware. With the clean disconnect it worked first time twice in a row (2026-10-11).
- **The BROM port's ttyACM number is not predictable.** `cdc_acm` reuses a number only after every program has closed it, so a program still holding the old port pushes BROM to ACM1/ACM2. The flasher therefore follows the watch by its USB device in sysfs (the same `1-1.1.1` directory, PID `0023` → `0003`), not by tty name.
- SDK tool: `linkit_sdk-master/tools/PC_tool.zip` → IoT_Flash_Tool (Windows), MT2523 USB download.
  Config: `tools/config/mt2523_hdk/download/default/flash_download.cfg`.
- Backup: `stock_fw/flash_4MB.bin`, sha256 `184168dd…cca01ae`. It's a full 4 MB image including the bootloader and NVDM.

## Factory AT command reference
All commands below were tested on this unit on 2026-10-10 over `ttyACM0`. The stock firmware registers 59 commands; the table is at `0x08167628` in flash. Some details:
- Many handlers `printf` their output, so it appears on the **syslog port `ttyACM1`** as plain text, not in the AT reply.
- Sensor data only appears in syslog after you turn on the `sensor` log module with `AT+SYSLOG="sensor",0,1`. The module name must be quoted. To turn it back off, use `AT+SYSLOG="sensor",1,1` (the stock setting). Filter changes are saved to NVDM `common/syslog_filters`.

Legend:
- ✅ tested and works
- ⚠️ tested, with a caveat
- ❌ returns ERROR or "Not Support"
- 🚫 **not run**: destructive, persistent, or reboots the device
- ➖ not applicable or not tested

### Info / read-only
| Command | Result on this unit | |
|---|---|---|
| `AT` | `OK` | ✅ |
| `AT+EVERINFO=0` / `=1` | `W3_B0_V1.21_A01_0530_WB` / `mt2523_hdk` | ✅ |
| `AT+RESETCAUSE?` | `pmu_reg[2D]=0x04,[2E]=0x00,[2F]=0x7f,[30]=0xff,[31]=0x00` (raw PMU reset-cause registers) | ✅ |
| `AT+BATPERCENT=1` | `Battery Percent:100` | ✅ |
| `AT+ECHAR` | `+ECHAR:4475,25,200,4787`: Vbat mV, temp °C, charge current, Vcharger mV | ✅ |
| `AT+ECHAR?` | `+ECHAR: 1`: cable present | ✅ |
| `AT+CAPID=3` / `=4` | eFuse CAPID = 0 (never burned) / current crystal trim = 408 | ✅ |
| `AT+ESETRTC=0` | Reads the RTC: `2017-10-01 0:03:59`. The RTC was reset, which means the battery ran flat at some point | ✅ |
| `AT+CPUFGET?` / `=0` | Current 104000 kHz; available 208000/104000/26000 | ✅ |
| `AT+DVFSDBG=?` | `+DVFSDBG=0` | ✅ |
| `AT+CLOCK?` | Dumps clock tree info to syslog | ✅ |
| `AT+SYSTEM=task` | FreeRTOS task list. 19 tasks: ATCI, BMT, CTP, SensorMgr, UI_DEMO, DataMgr, bt_task, ancs_data_pro, notify_service, epo_download_ta, sport_data_mana, key_process_pro, wdt_process_pro, USB, SYSLOG, CONSOLE, bt_devtk, Tmr Svc, IDLE | ✅ |
| `AT+SYSTEM=mem` | Heap 1048576 total, 939728 free, 938288 minimum free | ✅ |
| `AT+UTILIZATION=duration,1000` | CPU profile: IDLE 82%, BMT (battery task) 16% while charging | ✅ |
| `AT+MEM?` / `AT+MEM=dump,<a>,<len>` | Memory regions; dump of RAM only (max 0x2100 bytes) | ✅ |
| `AT+EREG=0,<hex>` | Raw 32-bit read, returns the low 16 bits only. Works on any address, flash included; this is how the backup was made | ✅ |
| `AT+EPMUREG=0,<hex>` | PMU register read. reg0=0x11, reg1=0x85 | ✅ |
| `AT+ERTCREG=0,<hex>` | RTC register read | ➖ |
| `AT+EGPIO=GPIO_GET` | All 49 GPIOs: mode, direction, pull, output and input | ✅ |
| `AT+EPORT=0` / `=4` | syslog = USB COM2 (dev 5), atci = USB COM1 (dev 4); UART baud index 12 | ✅ |
| `AT+ENVDM=0,<group>,<item>` | Read any NVDM item; see the NVDM section below | ✅ |
| `AT+SYSLOG?` | Per-module log switch and level | ✅ |
| `AT+ECRYPTO=AES,{128,192,256},{CBC,ECB}?` | Hardware AES self-test: `AES CBC/ECB TEst 128b ok`, and likewise for 256b | ✅ |
| `AT+TEST?` | `+TEST:0`, the vendor's test mode | ✅ |
| `AT+SM?`, `AT+EBTPW?`, `AT+EBTAT=?`, `AT+EKEYURC?`, `AT+EPENURC?`, `AT+EMSDC?`, `AT+ERTC32K?` | `Not Support` / `ERROR` in the read form | ❌ |

### Hardware tests (reversible)
| Command | What it does | Result | |
|---|---|---|---|
| `AT+ELCM=0/1/2/3` | Fill the LCD red / green / blue / white-black pattern | `+ELCM:n OK` | ✅ (visual check needed) |
| `AT+ELCM=10/11/12` | Black / white / WB, as listed by `=?` | `ERROR`: the parser only takes 1 digit | ❌ |
| `AT+EBLT=1` / `=0` | Backlight (front light) on / off | `+EBLT:1/0 OK` | ✅ (visual check needed) |
| `AT+EVIB=1/2/3` / `=0` | Vibrator on via the PMIC VIBR LDO at 2.8 / 3.0 / 3.3 V; off | `OK` | ✅ (feel check needed) |
| `AT+ELED=4/5/6` / `=1/2/3` | SDK RGB LED test on GPIO4/5/6 | `OK`. Side effect: GPIO4/5 are left as outputs driven low until reboot. Probably no LED fitted | ⚠️ |
| `AT+ESENSOR=0,1` / `0,0` | Subscribe / unsubscribe the accelerometer. Data goes to syslog | BHI160 enables (`Enable(C001)`) | ✅ |
| `AT+ESENSOR=1,1` / `1,0` | Accelerometer + gyro | BHI160 enables (`Enable(C009)`) | ✅ |
| `AT+ESENSOR=2,1` | Magnetometer | `sensor type 1 undefined` | ⚠️ (no mag) |
| `AT+ESENSOR=3,1` / `4,1` / `5,1` | Pressure / proximity / all | No such sensors | ⚠️ |
| `AT+ESENSORTEST=hw_00{1..5},on/off` | Same as ESENSOR, numbered: 1 acc, 2 acc+gyro, 3 mag, 4 baro, 5 prox | — | ➖ |
| `AT+ESENSORTEST=sanity` | Checks acc → gyro → mag → baro → prox and stops at the first failure | `Mag FAIL`, so acc and gyro are OK | ⚠️ |
| `AT+ESENSORTEST=hw_auto_001` | Gyro offset auto-test (2 s) | `hw_auto_001 PASS` | ✅ |
| `AT+ESENSORTEST=hw_auto_002` | Barometer auto-test | `hw_auto_002 FAIL`: no barometer | ⚠️ |
| `AT+EGSENSOR=0..3` | Vendor BHI160 data stream | `ERROR` every time I tried | ❌ |
| `AT+EBIO=1` / `=0` | PAH8011 PPG on / off. Streams 3 raw values per line on ATCI, e.g. `51671,51629,51541`. Touch (skin) detect works | ✅ |
| `AT+EBIO=2` | PixArt factory test (light leak, touch, INT, LED) | `PASS`. Product ID 0x11 | ✅ |
| `AT+EGPSC=1` / `=0` | GNSS power on / off. NMEA streams on ATCI. `=2`/`=3` turn NMEA output off/on | Works: `$PMTK011,MTKGPS`, then GGA/GSA/GSV/RMC/VTG/ACCURACY at 1 Hz. No fix indoors | ✅ |
| `AT+EGPSS=<PMTK sentence>` | Send a raw PMTK command to the MT3333 | `$PMTK605*31` returns `$PMTK705,AXN_5.10_3333_18031200,0000,,` | ✅ |
| `AT+EKEYURC=1` / `=0` | Report button presses as URC on ATCI | Needs someone to press the buttons | ➖ |
| `AT+EPENURC=1` / `=0` | Report touch events as URC on ATCI | Needs someone to touch the panel | ➖ |
| `AT+EKP=<key>:<action>` | Inject a simulated key event into the UI | — | ➖ |
| `AT+ECTP=(<x>,<y>):<action>;…` | Inject a simulated touch event into the UI | — | ➖ |
| `AT+EAUDIO=…` | Audio/DSP tests. The board has no audio hardware | — | ➖ |
| `AT+EMSDC=…` | SD-card tests. The board has no SD slot | — | ➖ |
| `AT+E*_DEMO`, `AT+EBLESA_DEMO`, `AT+EBLECON_DEMO`, etc. | BLE/BT demo commands: advertise, scan, connect | — | ➖ |
| `AT+EBTER`, `AT+EBTSHC`, `AT+EBTTB` | BT RF test modes and testbox. These interrupt the BLE stack | — | ➖ |

### 🚫 Dangerous: not run
| Command | Why |
|---|---|
| `AT+EREG=1,<a>,<v>`, `AT+EPMUREG=1,…`, `AT+ERTCREG=1,…` | Raw register **writes** to the SoC, PMIC or RTC |
| `AT+ENVDM=1,…` / `AT+ENVDM=2[,<group>]` | Write / **reset** NVDM. Reset would wipe the barcode and settings |
| `AT+EPORT=1/2/3,…` | Reassigns the serial ports and saves it. This can lose ATCI access |
| `AT+CAPID=1,<v>` / `AT+CAPID=2,<v>,<n>` | Changes crystal trim; `=2` **burns an eFuse, which is permanent** |
| `AT+CAPID=0,<port>` | Puts the device in UART relay mode |
| `AT+EWDT=1` | Triggers a watchdog reset (reboot) |
| `AT+SYSTEM=crash` | Forces an assert and crash dump |
| `AT+EBTEDL=…` | BT download mode |
| `AT+CPUFSET=…`, `AT+DVFSDBG=…` | Changes CPU frequency or voltage |
| `AT+ESETRTC=1,…`, `AT+ERTCREG=2/3`, `AT+ERTC=…` | Sets the RTC time, mode or alarm. `ERTCREG=3` can put the RTC into power-off mode |
| `AT+ESENSORTEST=cal_001,on`, `AT+EGSENSOR=4` | Sensor calibration, which saves calibration data |
| `AT+TEST=<n>` | Vendor test: changes log level, deinits or disconnects BT, ANCS init |
| `AT+SYSLOG="<mod>",…` | Persistent, but harmless and reversible. It was used for `sensor` and then restored |

### NVDM contents (`AT+ENVDM=0,<group>,<item>`)
The unit is effectively factory-fresh: no paired phones (`m_devg/m_devi00..0f` are all 0) and no user ID (`device_data_g/user_id` = `FFFFFFFF`).

| Group / item | Value |
|---|---|
| `factory_setting/barcode_str_config` | `A1EL0087J8` |
| `factory_setting/test_flag_str_config` | All zero |
| `user_setting/*` | 14 items: language, backlight=2, first_booting, distance_unit, no_interrupt_mode=1, heart_rate_status, time_unit, time_fetching_mode, time_indicator, long_stay_func=1, hand_lift_func=1, auto_pause_func, pool, home_page |
| `user_data/step_aim` | 8000 |
| `user_data/sleep_aim` | `14 00 08 00` (8 h) |
| `user_data/time_zone_config` | 0x320 = 800, i.e. UTC+8 |
| `user_data/charge_time_item` | 0x5B18FF88 = 2018-06-07 |
| `user_data/body_info_detail` | Default profile (contains floats) |
| `user_data/*` | Other items, all empty: alarm_list, alarm_raw, lastest_hr_data, training_plan, user_hand_setting, fav_sport, weather_list, hr_alert_config, sunshine_data |
| `port_service/port_assign` | `syslog`→5, `atci`→4 |
| `port_service/port_config` | `0c 0c 0c 0c 09 0c` |
| `common/syslog_filters` | Text list of module switches and levels |
| `data_manager/running_data`, `persion_data`, `data_index` | Empty activity storage |
| `ios_notig/ios_notii`, `first_contype/contype_item`, `spmode_g/spmode_i` | 0 / 0 / FF |

## USB download mode (BROM + DA), tested from Linux
- **Getting in.** Send `AT+EWDT=1` to the stock firmware. The watch resets, and the BROM USB window appears as `0e8d:0003` for about 1 s. A power-off followed by USB plug-in should also work. If nothing talks to it, the BROM and the DA both time out and the stock firmware boots again.
- **BROM.** Version 0x05. `0xFD`/`0xFC` echo only, so it's the old IoT BROM. `GET_TARGET_CONFIG` returns 0, meaning **no secure boot, no SLA, no DAA**.
- **DA.** From the SDK's IoT Flash Tool, `MTK_AllInOne_DA.bin` v2.5.00.00, MT2523 entry 0 (hw 0x2523; sub-codes 0x8100 and 0x8000 carry the same payload). Bring-up follows mtkclient's MT2523 path:
  1. env region → 0x04015000 (BROM cmd `0xD9`)
  2. stage 1 → 0x04008000 (`0xD7`/`0xD5`), sync `0xC0`
  3. `3F/F3/C0/0C` handshake
  4. chip ID, then flash table entry
- **Flash.** Macronix **MX25R3235F**, chip ID `c2 28 16`, 4 MB at 0x08000000.
- **DA commands** (dispatcher at 0x0400AC7C):
  - `D6` read: absolute addr, len, packet. ~444 KB/s. **Verified** against the AT dump.
  - `B2` NOR write
  - `D4` format
  - `DB` arm watchdog / reboot (u16)
  - `D9` finish
- **`B2` write framing** (from disassembly, **not yet tested**):
  1. Host sends the header; the DA ACKs, erases, and ACKs again.
  2. Per packet: host sends data plus a big-endian `sum16` checksum; the DA replies `0x69`.
  3. At the end: the DA sends `0x5A`, the host sends the total u16 checksum (`5A` ok / `A5`+u32 on mismatch), then the host sends a flag byte and the DA replies `5A`.
- **Tools:**
  - `tools/mt2523_brom.py` (BROM probe/explore)
  - `tools/mt2523_flash.py` (`info`, `read`, `reboot`)
  - Full USB readback: `stock_fw/flash_4MB_usb_readback.bin`. Identical to the AT dump except the NVDM sectors 0x083F0000 and 0x083F4000, which change at runtime.

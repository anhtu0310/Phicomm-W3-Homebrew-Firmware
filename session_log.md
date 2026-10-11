# Session log: Phicomm W3 (MT2523G) custom firmware, 2026-10-10 to 2026-10-11

This log covers what was done, what works, where everything is, and how to continue. For register-level detail, see `HARDWARE.md`. For the touch-chip story in tutorial form, see `docs/touch_dead_zone_fix.md`.

## 1. Where things stand

| Part | Status | Code |
|---|---|---|
| JDI 72×144 colour MIP display | ✅ working (from earlier) | `src/jdi_lcd.c` |
| Front light (PMIC ISINK ch0) | ✅ 8 mA; **auto-off 30 s after the last touch/message** (`AT+BLTO=<s>`, 0 = never); `AT+BL=0..3`; LIGHT button = auto / always off | `src/main.c` `backlight_set()`, `user_activity()`, `backlight_service()` |
| Touch strip (CY8C4014) | ✅ **full height**: touch chip patched, position computed on the MT2523 | `src/cy8c_touch.c`, `src/touch_slider.c` |
| BHI160 accel + gyro | ✅ 25 Hz, scale verified | `src/bhi160.c`, `inc/bhi160_fw.h` |
| BHI160 pedometer | 🟡 stock **custom sensor 29** enabled (ack `DD`); a u16 count is shown as `STEP`, but it hasn't been checked on a counted walk | `src/bhi160.c` |
| Watch face + RTC | ✅ page 0: local time (UTC+7), date, steps, HR, GPS. Set with `AT+TIME=` or from GNSS; lost on unplug (no battery) | `src/w3_time.c`, `main.c` `draw_clock()` |
| Vibration motor | ✅ PMIC VIBR LDO at 3.0 V (the stock setting) + stock patterns; confirmed by feel 2026-10-11 | `src/vibrator.c` |
| Controls page | ✅ touch buttons: LIGHT toggle, BUZZ, NOTIF, SOS (the W3 has no physical button) | `main.c` `draw_controls()`, `controls_touch()` |
| Power key | ➖ code present, but **this unit has no power button** (PWRKEY is active low: pulled up in the PMIC, pressed = GND) | `main.c` `handle_power_key()` |
| GNSS (MT3333, GPS+GLONASS) | ✅ 3D fix outdoors (0 satellites indoors). Time, position and EPO assistance work (`tools/w3_gnss_assist.py`); effect on fix time not yet measured | `src/w3_gnss.c` + SDK `middleware/MTK/gnss` |
| PAH8011 heart rate | ✅ LED on, real PPG samples; BPM by our own algorithm. BPM accuracy not yet checked against a reference. Runs only while its page is shown (power saving) | `src/pah8011.c`, `src/heart_rate.c` |
| Bluetooth LE | 🟡 advertising as "W3 band" (stock address `98:BB:99:3E:7C:DC`), phone connects, GATT table and reads OK in nRF Connect (2026-10-11). Writes (time, message) and the web console not yet confirmed | `src/w3_ble.c`, `tools/w3_ble.py`, `tools/web/index.html` |
| USB log + AT commands, untethered flashing | ✅ (see the caveats in §7) | `src/usb_log.c`, `tools/mt2523_flash.py` |

All firmware source is in `linkit_sdk-master/project/mt2523_hdk/apps/w3_display/` (`src/`, `inc/`, `GCC/Makefile`).

## 2. What was achieved, in order

### 2.1 Touch dead zone (bottom strip always read 143)
- **Cause:**
  - The CY8C4014 runs a Cypress CapSense **3-electrode** linear slider.
  - Its baseline creeps up under a resting finger, so the middle electrode's fading signal drops below the chip's noise threshold (100) and the position snaps to 143.
  - The real signal still fades smoothly down to the bottom edge.
- **Fix, part 1: patch the touch chip's firmware.** Three instructions changed, in rows 101, 102 and 255:
  - **I2C window 14 → 136 bytes** (the write boundary stays 14), exposing the CapSense RAM with all 3 electrodes' raw counts and baselines.
  - **Version `0x19` → `0x18`.** The stock MT2523 firmware auto-restores the stock touch firmware whenever the version is ≤ `0x18`, which gives a free way back.
  - **Finger threshold kept at 380.**
  - **How it was done:**
    - Extracted the `.cyacd` from the stock flash.
    - Disassembled it.
    - Learned the Cypress bootloader protocol from the stock updater.
    - Flashed through a USB → I2C passthrough in our firmware.
- **Fix, part 2: compute the position ourselves** (`touch_slider.c`):
  - **Baseline:** our own per-electrode baseline, frozen while touched.
  - **Touch detection:** on above 400, off below 250 (sum of signals).
  - **Noise floors:** 120 for the top electrode, 25 for the others.
  - **Position:** the centroid `72×(d1+2·d2)/sum`, mapped to rows with `POS_TOP=10`, `POS_BOTTOM=141` (calibrated on this unit).
- **Lesson:** an 8-bit row checksum can't prove a row is unchanged (row 101's −1/+1 edits cancelled out). Pick rows by comparing file contents (`--diff`).

### 2.2 USB robustness
- **Random reboots** came from VBUS dips that triggered the "plug-in → reboot to download mode" rule. Now USB must be absent ≥ 2 s to count as a plug-in, and shorter dips are logged as `usb: VBUS glitch`.
- **`AT+EWDT=1` needed sending twice** because ModemManager's binary probes sat in the line buffer:
  - **Watch:** drops lines containing non-printable bytes.
  - **Flasher:** sends CR/LF first, waits for the reply, and retries.
- **The watch's tty number moves around** (ACM0/1/2). `tools/w3_logcap.py` finds it by USB ID and reconnects.

### 2.3 Front light
The stock `AT+EBLT` handler drives PMIC ISINK channel 0 (register mode, 2 MHz, 4/8/12 mA). Ours turns on at 8 mA at boot; `AT+BL=n` changes it.

### 2.4 BHI160
- **Bus:** I2C0 at `0x28`, product ID `0x83`, ROM `0x2DAD` (revision DI03).
- **RAM patch:** 19,500 bytes from the stock flash, word-reversed upload to `0x96`, CRC `0xC69A2374` (OK). It reports RAM `0x2DB0` and sends the "initialized" meta event.
- **Sensor config:** parameter page 3, `0xC0`+ID, then write 0 to `0x64`/`0x54` afterwards. **Use polling I2C only:** the DMA path was slow and corrupted 17-byte writes.
- **Verified:** 1000 mg at rest; gyro 0 at rest; a 90° turn integrates to about 90°; about 24.5 samples/s.
- **Not working:** the step counter (ID 19) is refused by this patch. The stock app may count steps through another virtual sensor.

### 2.5 GNSS
- **Stack:** the SDK GNSS middleware, exactly as stock (GPIO10 LDO, UART3 115200, EINT10), plus our NMEA parser: RMC, GGA, GSA, GSV, with checksums checked.
- **Receiver firmware:** `AXN_5.10_3333_18031200`. It ignores commands right after power-on, so they're retried.
- **Result:** a 3D fix outdoors. A cold start needs 30–40 s of uninterrupted signal per satellite. The antenna is the gold trace on the back at the USB end; keep fingers off it.

### 2.6 PAH8011 heart rate
- **Approach:** ported the **stock driver from the binary**, after 4 failed builds (see the table in `HARDWARE.md`).
- **The missing piece:** **GPIO48 = LED power enable**, found in the stock `pah_ppg1_operate()`.
- **Also required:**
  - The stock init table (34 writes).
  - Channel B only.
  - Bank 1 `0x36` &= ~3 and `0x35` &= ~2.
  - Board setup in bank 4.
  - A polling FIFO read with the **FIFO clock enabled around the read** (bank 1 `0x71`=0, bank 0 `0x10`=3, then back to 1/0).
- **Heart rate:** our own autocorrelation algorithm over 8 s at 20 Hz.

## 3. Firmware layout (`w3_display`)

**Tasks:**

| Task | Priority | Job |
|---|---|---|
| `VIBR` | 4 | owns the vibration motor; plays pulses and patterns from a queue |
| `DISPLAY` | 3 | touch, power key, screen, USB log/AT, GNSS→RTC sync, watchdogs; 50 ms loop |
| `BHI160` | 2 | upload the RAM patch, drain the FIFO every 40 ms |
| `GNSS` | 2 | read NMEA every 100 ms |
| `bt_task` | 6 | SDK BLE host + controller driver (prebuilt `libble.a`, `libbtdriver_2523.a`) |
| `BLEIMU` | 2 | sends IMU notifications at the client's rate |
| `PAH8011` | 2 | poll the PPG every 50 ms |

**Modules:**

| File | Role |
|---|---|
| `main.c` | display task, screen pages, logging, AT commands, backlight |
| `usb_log.c` | USB CDC log port and AT line handler |
| `jdi_lcd.c` | display driver |
| `cy8c_touch.c` | bit-banged I2C2 to the touch chip, raw register access |
| `touch_slider.c` | our baseline, touch detection and position (needs touch firmware `0x18`) |
| `sensor_i2c.c` | **shared I2C0 with a mutex** (BHI160 + PAH8011); polling only, ≤ 8 bytes per transfer |
| `bhi160.c`, `inc/bhi160_fw.h` | BHI160 driver and RAM patch |
| `w3_gnss.c` | GNSS start-up and NMEA parsing |
| `pah8011.c` | PAH8011 driver (stock port) |
| `heart_rate.c` | heart-rate algorithm |
| `w3_time.c` | RTC in UTC, timezone, date maths, GNSS time sync |
| `vibrator.c` | vibration motor: VIBR LDO voltage + on/off, stock patterns, own task |
| `w3_ble.c` | BLE: power-on, advertising, GATT table (W3 service), events, IMU notifications; no NVDM use |

**Screen:** 5 pages.
- **Tapping the bottom strip** (row ≥ 124) cycles: clock → sensors → GNSS → heart rate → controls.
- **Controls page:** four 26-row touch buttons (LIGHT, BUZZ, NOTIF, SOS). A button acts on release, choosing the button the finger was over for most samples; it is highlighted while touched.
- **A long press of the power key** cycles the front light.
- **The red bar on the right edge** follows the finger on every page.
- **On the sensor page,** a tap elsewhere zeroes the gyro angles.

**USB AT commands** (log port = CDC interface 00):

| Command | Does |
|---|---|
| `AT` | `OK` |
| `AT+EWDT=1` | reboot (used by `--reboot-from` to reach the download window) |
| `AT+BL=0..3` | front light off (stays off) / 4 / 8 / 12 mA (auto-off) |
| `AT+BLTO=<s>` | front light auto-off delay in seconds (default 30, 0 = never) |
| `AT+BLE?` | BLE state, connections, IMU stream counters, time syncs, messages |
| `AT+TIME=YYYY-MM-DD,HH:MM:SS` / `AT+TIME?` | set (UTC) / read the RTC. From the PC: `printf "AT+TIME=$(date -u +%Y-%m-%d,%H:%M:%S)\r" > /dev/ttyACM0` |
| `AT+TZ=<hours>` | timezone for the watch face (default +7) |
| `AT+VIB=<ms>[,<level>]` | one buzz (max 5000 ms); level 1/2/3 = 2.8/3.0/3.3 V, default 2; `AT+VIB=0` stops |
| `AT+VIBP=<n>` | stock pattern: 0 notify (double), 1 ramp, 2 SOS |
| `AT+GNSSCMD=<PMTK body>` / `AT+GNSSLAST?` / `AT+GNSSFIX?` | send a PMTK command (checksum added) / last PMTK reply / current fix |
| `AT+TPR=<reg hex>,<len>` | read touch-chip registers |
| `AT+TPW=<hex>` / `AT+TPRD=<n>` | raw I2C write/read to the touch chip |
| `AT+TPBL=<hex>,<rlen>[,<ms>]` | touch bootloader packet exchange |
| `AT+TPPAUSE=1/0` | pause or resume our touch polling (needed while bootloading) |

**Log line prefixes:**
- `tp` (touch, while down, 10 Hz)
- `bhi` (2 Hz), `bhi sensor N:` (sensor list after boot), `bhi pedo` (pedometer payload)
- `key:` (power key), `time:` (RTC set from GNSS), `ui:` (controls page button)
- `gnss` + `nmea` (1 Hz)
- `ppgB` (raw PPG) and `pah` (1 Hz)
- `up=… boot=…` and `pmu:` (1 Hz)
- `usb: VBUS glitch`
- `ble:` (power on, advertising, connect/disconnect, time set, messages), `light:` (auto-off)

## 4. How to build, flash, log

```bash
cd /media/anhtu/01DB4AC8DC2F3EC0/code/MT2523/linkit_sdk-master
./build.sh mt2523_hdk w3_display -o=BINPATH=/opt/gcc-arm-none-eabi/bin     # bundled GCC 4.8 is broken
# output: out/mt2523_hdk/w3_display/w3_display.bin ; errors in out/.../log/err.log

cd /media/anhtu/01DB4AC8DC2F3EC0/code/MT2523
python3 tools/mt2523_flash.py --reboot --timeout 60 write 0x08010000 linkit_sdk-master/out/mt2523_hdk/w3_display/w3_display.bin
#   --reboot finds the watch's AT port by USB ID (ttyACM0/1/2 doesn't matter)
#   if it waits for download mode: unplug/replug the cable (battery-less unit, so replug = cold boot = BROM window)

python3 tools/w3_logcap.py my_log.txt --seconds 600                       # log capture that follows re-enumerations
stty -F /dev/ttyACM0 raw -echo && cat /dev/ttyACM0 | tee log.txt          # simple alternative
python3 -m serial.tools.miniterm /dev/ttyACM0 115200                      # interactive
```

BLE clients:
```bash
python3 tools/w3_ble.py scan | time | notify "text" | imu --rate 25 --csv imu.csv   # PC (bleak), needs a working BT adapter
python3 -m http.server 8000 -d tools/web        # web console: open http://localhost:8000 in Chrome
adb reverse tcp:8000 tcp:8000                    # phone: then http://localhost:8000 in Android Chrome
```
Web Bluetooth needs a secure context (localhost or HTTPS). Chrome on Linux also needs `chrome://flags/#enable-experimental-web-platform-features`.

Touch chip (only if re-patching or restoring):
```bash
python3 tools/cy8c_patch.py stock_fw/cy8c4014/stock_touch_fw.cyacd stock_fw/cy8c4014/patched_touch_fw.cyacd
python3 tools/cy8c_bootload.py info | verify <cyacd> | program --diff <stock> <patched>
python3 tools/cy8c_bootload.py program stock_fw/cy8c4014/stock_touch_fw.cyacd     # restore stock
```

## 5. Files and locations (project root `/media/anhtu/01DB4AC8DC2F3EC0/code/MT2523`)

| Path | What |
|---|---|
| `HARDWARE.md` | hardware map, pinout, every peripheral's protocol, AT command reference |
| `docs/touch_dead_zone_fix.md` | tutorial-style write-up of the touch patch |
| `session_log.md` | this file |
| `stock_fw/flash_4MB_usb_readback.bin` | **full stock flash backup** (also `flash_4MB.bin`); the reference for all reverse engineering |
| `stock_fw/strings.txt` | strings of the stock firmware (search here first) |
| `stock_fw/bhi160_ram_patch.fw` | BHI160 RAM patch extracted from stock |
| `stock_fw/pah8011_stock_init.txt` | PAH8011 stock init table |
| `stock_fw/gpio_get_stock.txt` | stock GPIO state dump |
| `stock_fw/cy8c4014/` | touch firmware: stock `.cyacd`, patched `.cyacd`, flat binary, disassembly |
| `tools/mt2523_flash.py`, `tools/mt2523_brom.py` | MT2523 BROM/DA flasher |
| `tools/cy8c_patch.py`, `tools/cy8c_bootload.py` | touch-chip patcher and bootloader host |
| `tools/w3_logcap.py` | robust USB log capture |
| `tools/w3_gnss_assist.py` | GNSS assistance: sets the watch clock, time + position aiding, EPO upload (downloads `epo/EPO_GR_3_1.DAT` when it expires) |
| `epo/` | cached EPO file and `last_fix.json` |
| `tools/touch_probe.py` | PC-side touch electrode logger (polls over AT) |
| `tools/armdis.py` | Thumb disassembler for the stock dump (`python3 tools/armdis.py stock_fw/flash_4MB_usb_readback.bin 0x3d900 0x3da00`) |
| `ref/BoschSensorHub/` | Bosch BHI160 Arduino driver (reference) |
| `ref/pah8011-qcom-adsp-driver/` | PixArt PAH8011 open driver (reference) |
| `gnss_test.log`, `gnss_antenna.log` | GNSS captures (indoor; the outdoor fix was seen on screen) |
| `hr_test.log` | PAH8011 captures from the failing builds (all-zero samples) |
| `touch_probe.csv`, `touch_slide.csv`, `w3_usb.log` | touch analysis data |

**Useful stock-firmware addresses:**
- PAH8011 driver code: `0x0803C400`–`0x0803E000`.
- `pah_ppg1_operate`: `0x0803E21C`.
- Touch-chip `.cyacd`: `0x080C1748`.
- BHI160 patch: `0x080D0104`.
- Stock `hal_gpio_set_output`: `0x0804EEC0`.

## 6. Key numbers

| What | Value |
|---|---|
| Touch electrodes | 3 (centres 0/72/144) |
| Touch thresholds | ON 400, OFF 250 |
| Touch calibration | `POS_TOP` 10, `POS_BOTTOM` 141 |
| BHI160 | accel ±4 g, gyro ±2000 °/s, 25 Hz |
| GNSS | 1 Hz, about 8 NMEA sentences/s |
| PAH8011 | 20 Hz, report 20 samples, channel B, 4 bytes/sample |
| Heart rate | 8 s window, lags 7–30, quality ≥ 50 |
| Front light | 8 mA |
| VBUS unplug debounce | 2 s |

## 7. Known issues and caveats
- **USB power is flaky in this setup.**
  - VBUS dips re-enumerate the watch.
  - The PC restarted twice around a replug.
  - **The project drive dropped with I/O errors when the PC went to sleep**, so keep the PC awake during long captures (`systemd-inhibit`).
  - ModemManager probes the port. Optional fix:
    ```bash
    echo 'ATTRS{idVendor}=="0e8d", ENV{ID_MM_DEVICE_IGNORE}="1"' | sudo tee /etc/udev/rules.d/99-w3-no-modemmanager.rules && sudo udevadm control --reload
    ```
- **`--reboot-from`** used to miss the BROM window often. Two fixes:
  - `AT+EWDT=1` now disconnects USB cleanly before resetting.
  - **The flasher tracks the watch by USB device, not tty name** (fixed 2026-10-11). If another program (a forgotten miniterm, ModemManager, `w3_logcap`) still holds the old ttyACM, the kernel can't reuse that number, so BROM comes up as ACM1/ACM2. The old code then re-opened the old name for up to 30 s and missed the ~1 s window. Now the trigger returns as soon as the watch's USB device leaves firmware mode (PID ≠ `0023`), whoever read the `OK`. Use `--reboot` to also find the AT port automatically.
  - If it ever misses, replug while the flasher waits.
- **The USB log drops lines in bursts** (the transmit ring overflows). Log big dumps a few lines at a time.
- **The unit has no battery:** unplugging powers it off.
- **The PAH8011 runs only on the heart-rate page.** Stock instead waits in touch-only mode until skin is detected; that finer power saving isn't copied yet.
- **BPM accuracy is unverified:** there's no logged working run yet. Compare against a phone or chest strap.
- **The PAH8011 FIFO is read in 8-byte chunks** (each from register 0) instead of the stock single burst. It works now, but keep it in mind if samples look odd.
- **The touch calibration** (`POS_TOP`/`POS_BOTTOM`, noise floors) was measured on this unit. Re-check on other boards.
- **The BHI160's standard step counter (19) isn't in the RAM patch.** Steps come from the stock custom sensor 29; the value isn't yet confirmed on a walk.
- **The gyro angle drifts** about 2°/min (normal integration drift; tap to zero).

## 8. Suggested next steps
Progress on 2026-10-11 (second half):
- **Pedometer:** found and enabled (sensor 29).
- **Watch face + RTC:** done.
- **Vibration and power key:** written.
- **PPG power saving:** on its page only.
- **Reboot-to-flash:** fixed.
- **Sensor list:** logged.

Still to do:
1. **Tests that need hands:**
   - Walk a counted number of steps and check `STEP`, and the `bhi pedo` lines.
   - Log a heart-rate run (`tools/w3_logcap.py`) against a reference BPM.
2. **Heart rate:** tune `MIN_QUALITY`, the window and the detrend length; maybe add motion rejection using the BHI160 accelerometer.
3. **Finer PPG power saving:** copy stock, with touch-only mode (2) and switching to PPG (4) on skin contact.
4. **More BHI160 features from the stock map:** activity (27), sleep (30), swim (18), PDR (26), wake/tilt gestures (22/23). Each needs its payload decoded the same way as the pedometer.
5. **GNSS:** measure time-to-fix outdoors with and without `tools/w3_gnss_assist.py`. Optionally re-send EPO automatically every 6 h while plugged in, and add track logging.
6. **BLE:** confirm writes (time, message) and the web console's 3D IMU demo; then maybe the stock-style features (ANCS phone notifications on iOS, a standard Current Time Service client).
7. **Remaining hardware:** battery/charger status on a unit with a battery.

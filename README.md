# Phicomm W3 homebrew firmware

Custom firmware for the **Phicomm W3** fitness band, a discontinued MT2523G watch whose phone app no longer works. Everything here was reverse engineered from the running stock firmware and a full flash dump, without opening the case.

The hardware map, every peripheral's protocol and the factory AT command reference are in **[HARDWARE.md](HARDWARE.md)**. The project diary, with status, known issues and next steps, is in [session_log.md](session_log.md).

## What works

| Part | Status |
|---|---|
| JDI 72×144 colour memory-in-pixel display | ✅ |
| Front light | ✅ turns off 30 s after the last activity |
| Touch strip (CY8C4014) | ✅ full height, after a patch to the touch chip's firmware ([how](docs/touch_dead_zone_fix.md)) |
| BHI160 accelerometer and gyroscope | ✅ 25 Hz |
| Step counter | 🟡 enabled, not yet checked on a counted walk |
| GNSS (MT3333, GPS + GLONASS) | ✅ 3D fix outdoors, time sync, EPO assistance |
| PAH8011 heart rate | ✅ raw PPG and our own BPM estimate |
| Vibration motor | ✅ including the stock patterns |
| Real-time clock and watch face | ✅ set over USB, BLE or GNSS |
| Bluetooth LE | 🟡 time sync, IMU stream and text notifications; connection and reads confirmed |
| USB log, AT commands, flashing from Linux | ✅ |

The W3 has no physical button. All input is the touch strip.

## Repository layout

| Path | What |
|---|---|
| [`linkit_sdk-master/project/mt2523_hdk/apps/w3_display/`](linkit_sdk-master/project/mt2523_hdk/apps/w3_display/) | The firmware: `src/`, `inc/`, `GCC/` (Makefile, `feature.mk`, linker script). Only this app is tracked; the rest of the SDK is not |
| [`tools/`](tools/) | Linux flasher, log capture, BLE client, GNSS assistance, touch-chip tools, disassembler |
| [`tools/web/`](tools/web/) | Web Bluetooth console with a 3D orientation demo |
| [`stock_fw/`](stock_fw/) | Material extracted from the stock firmware: strings, touch-chip images, sensor tables. The full flash dumps are not in git |
| [`docs/`](docs/) | Write-ups |
| [`HARDWARE.md`](HARDWARE.md) | Hardware map and protocols |

## Building

The firmware builds inside the MediaTek LinkIt SDK for RTOS (v4.x, MT2523). This project used a GitHub archive of it (`linkit_sdk-master.zip`, archive commit `5c5fe159`) that includes the GNSS middleware. The package from labs.mediatek.com leaves the GNSS middleware out.

1. **Get the SDK into the repository folder.** A clone already contains `linkit_sdk-master/project/mt2523_hdk/apps/w3_display/`. Unzip the SDK over it; `-n` keeps our files:
   ```bash
   git clone git@github.com:anhtu0310/Phicomm-W3-Homebrew-Firmware.git
   cd Phicomm-W3-Homebrew-Firmware
   unzip -n /path/to/linkit_sdk-master.zip
   ```
2. **Install a toolchain.** The GCC 4.8 bundled with the SDK does not work. Arm GNU Toolchain 12.2 (`arm-none-eabi`) does; this project keeps it in `/opt/gcc-arm-none-eabi`.
3. **Build:**
   ```bash
   cd linkit_sdk-master
   ./build.sh mt2523_hdk w3_display -o=BINPATH=/opt/gcc-arm-none-eabi/bin
   ```
   The output is `out/mt2523_hdk/w3_display/w3_display.bin`. Errors are in `out/mt2523_hdk/w3_display/log/err.log`.

## Flashing (Linux)

The Python tools need these packages:
```bash
pip install pyserial bleak capstone
```

The watch shows up as two USB serial ports (`0e8d:0023`). Interface 00 is the log and AT port, usually `/dev/ttyACM0`, but the number can change.

**Back up the whole flash first.** The dump is the only way back to the stock firmware:
```bash
python3 tools/mt2523_flash.py --reboot read 0x08000000 0x400000 my_w3_backup.bin
```

**Flash the firmware:**
```bash
python3 tools/mt2523_flash.py --reboot --timeout 60 write 0x08010000 linkit_sdk-master/out/mt2523_hdk/w3_display/w3_display.bin
```
- **How `--reboot` works:** it finds the watch's AT port by its USB ID and sends `AT+EWDT=1`. The watch then reboots into the Boot ROM's download window, which lasts about 1 s. The tool loads MediaTek's download agent, writes the image and verifies it by reading it back.
- **If it keeps waiting for download mode,** unplug and replug the cable. A unit without a battery cold-boots straight into the download window.
- **The bootloader area is protected:** the tool refuses to write below `0x08010000` unless `MT2523_ALLOW_BOOTLOADER=1` is set.
- **On Linux, ModemManager probes new serial ports.** To keep it away from the watch:
  ```bash
  echo 'ATTRS{idVendor}=="0e8d", ENV{ID_MM_DEVICE_IGNORE}="1"' | sudo tee /etc/udev/rules.d/99-w3-no-modemmanager.rules && sudo udevadm control --reload
  ```

Other flasher commands are `info`, `read ADDR LEN FILE`, `erase ADDR LEN` and `reboot`. Run `python3 tools/mt2523_flash.py --help` for details.

## Using the watch

### On the watch

| Page | Shows |
|---|---|
| Clock | Local time, date, steps, heart rate, GNSS and BLE status |
| Sensors | Accelerometer with a bubble level, gyroscope and angles. A tap zeroes the angles |
| GNSS | Fix, satellites, position |
| Heart rate | BPM, PPG waveform, skin contact. The sensor runs only on this page |
| Controls | Touch buttons: LIGHT (auto or off), BUZZ, NOTIF, SOS |

- **Change page:** tap the bottom of the strip.
- **Front light:** any touch turns it on.
- **Messages from BLE:** shown full screen for 15 s, or until the next tap.

### USB log and AT commands

```bash
python3 tools/w3_logcap.py w3_log.txt --seconds 600      # log capture that follows reconnects
python3 -m serial.tools.miniterm /dev/ttyACM0 115200       # interactive AT session
```

| Command | Does |
|---|---|
| `AT+TIME=YYYY-MM-DD,HH:MM:SS` / `AT+TIME?` | Set (UTC) or read the clock. From the PC: `printf "AT+TIME=$(date -u +%Y-%m-%d,%H:%M:%S)\r" > /dev/ttyACM0` |
| `AT+TZ=<hours>` | Timezone for the watch face (default +7) |
| `AT+BL=<0..3>` | Front light: off (stays off) or 4 / 8 / 12 mA |
| `AT+BLTO=<s>` | Front light auto-off delay (default 30 s; 0 = never) |
| `AT+VIB=<ms>[,<1..3>]` | One buzz at 2.8 / 3.0 / 3.3 V |
| `AT+VIBP=<0..2>` | Stock pattern: notify, ramp, SOS |
| `AT+BLE?` | BLE state and counters |
| `AT+GNSSCMD=<PMTK>` / `AT+GNSSFIX?` / `AT+GNSSLAST?` | Send a raw command to the GNSS receiver, read the fix, read the last reply |
| `AT+EWDT=1` | Reboot (used by the flasher) |

The touch-chip commands (`AT+TP…`) are listed in [session_log.md](session_log.md).

### GNSS assistance

```bash
python3 tools/w3_gnss_assist.py                          # set the clock, send time, last position and EPO orbit data
python3 tools/w3_gnss_assist.py --lat 21.03 --lon 105.85 # give an approximate position
```
A cold start without help needs several minutes of open sky. The assistance should shorten that, but the gain has not been measured yet. The receiver keeps the data in RAM, so run this again after each power-up.

### Bluetooth LE

The watch advertises as **"W3 band"** and serves one service, `57330001-9c1e-4b8e-a0f3-1c5e9b7d3a42`:

| Characteristic | Access | Format |
|---|---|---|
| `57330002-…` Time | read, write | u32 Unix time (UTC) + optional i8 timezone in hours |
| `57330003-…` IMU | notify, read; write u8 = rate in Hz (1–25) | 16 bytes LE: u16 counter, i16 accel xyz (8192 LSB/g), i16 gyro xyz (16.4 LSB per °/s), u16 milliseconds |
| `57330004-…` Notify | write | UTF-8 text, up to 120 bytes |

**From a PC** (needs a working Bluetooth adapter):
```bash
python3 tools/w3_ble.py scan
python3 tools/w3_ble.py time
python3 tools/w3_ble.py notify "Lunch at 12"
python3 tools/w3_ble.py imu --rate 25 --seconds 10 --csv imu.csv
```

**From a phone,** any generic BLE app such as nRF Connect can read and write the characteristics above.

**Web console with a 3D demo.** [`tools/web/index.html`](tools/web/index.html) connects through Web Bluetooth. It syncs the time, sends messages and shows a 3D model of the watch that follows its movement. Web Bluetooth needs HTTPS or `localhost`:
- **GitHub Pages:** the workflow in `.github/workflows/pages.yml` publishes `tools/web/` to https://anhtu0310.github.io/Phicomm-W3-Homebrew-Firmware/ (Pages must be enabled in the repository settings).
- **Locally:**
  ```bash
  python3 -m http.server 8000 -d tools/web        # then open http://localhost:8000
  adb reverse tcp:8000 tcp:8000                    # an Android phone on USB can open http://localhost:8000 too
  ```

Use Chrome or Edge. Chrome on Linux also needs `chrome://flags/#enable-experimental-web-platform-features`. The watch accepts one connection at a time, so disconnect other apps first.

## Safety notes

- **Keep your flash backup.** It holds the watch's calibration and settings area as well as the stock firmware.
- **This firmware writes nothing to the settings area (NVDM)** and never touches the bootloader.
- **The touch-chip patch is reversible:**
  ```bash
  python3 tools/cy8c_bootload.py program stock_fw/cy8c4014/stock_touch_fw.cyacd
  ```
  The stock firmware also restores its own touch firmware automatically.
- **On a unit without a battery,** unplugging USB powers it off and clears the clock.

#!/usr/bin/env python3
"""Talk to the W3 watch over Bluetooth LE (w3_display firmware, src/w3_ble.c).

  python3 tools/w3_ble.py scan                     # list nearby devices, mark the W3
  python3 tools/w3_ble.py time [--tz 7]            # set the watch clock from this PC
  python3 tools/w3_ble.py notify "Lunch at 12"     # show a message + double buzz
  python3 tools/w3_ble.py imu [--rate 25] [--seconds 10] [--csv imu.csv]

The watch advertises as "W3 band". Pass --address AA:BB:... to skip the scan
(the watch uses the stock public address 98:BB:99:3E:7C:DC).

GATT service 57330001-9c1e-4b8e-a0f3-1c5e9b7d3a42:
  ...0002 Time    read/write  u32 Unix time UTC + i8 timezone hours
  ...0003 IMU     notify      u16 counter, i16 acc xyz (8192 LSB/g), i16 gyro xyz
                              (16.4 LSB per deg/s), u16 ms; write u8 = rate Hz
  ...0004 Notify  write       UTF-8 text (max 120 bytes)
"""
import argparse
import asyncio
import struct
import sys
import time

from bleak import BleakClient, BleakScanner

NAME = 'W3 band'
BASE = '5733%04x-9c1e-4b8e-a0f3-1c5e9b7d3a42'
SERVICE, TIME, IMU, NOTIFY = (BASE % n for n in (1, 2, 3, 4))
ACC_LSB_PER_G = 8192.0
GYRO_LSB_PER_DPS = 32768.0 / 2000.0


async def find(args):
    if args.address:
        return args.address
    print('Scanning for "%s"...' % NAME)
    dev = await BleakScanner.find_device_by_filter(
        lambda d, ad: (d.name == NAME or ad.local_name == NAME or SERVICE in ad.service_uuids), timeout=args.timeout)
    if dev is None:
        raise SystemExit('W3 not found (is it advertising? check AT+BLE? on the USB port)')
    print('Found %s' % dev.address)
    return dev


async def cmd_scan(args):
    found = await BleakScanner.discover(timeout=args.timeout, return_adv=True)
    for addr, (d, ad) in sorted(found.items(), key=lambda kv: -kv[1][1].rssi):
        mark = '  <-- W3' if (ad.local_name == NAME or SERVICE in ad.service_uuids) else ''
        print('%s  %4d dBm  %s%s' % (addr, ad.rssi, ad.local_name or d.name or '', mark))


async def cmd_time(args):
    async with BleakClient(await find(args)) as c:
        before = struct.unpack('<Ib', await c.read_gatt_char(TIME))
        now = int(time.time())
        tz = args.tz if args.tz is not None else round(time.localtime().tm_gmtoff / 3600)
        await c.write_gatt_char(TIME, struct.pack('<Ib', now, tz), response=True)
        after = struct.unpack('<Ib', await c.read_gatt_char(TIME))
        print('watch was %s (tz %+d), off by %+d s' % (time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime(before[0])),
                                                        before[1], before[0] - now))
        print('watch now %s UTC (tz %+d)' % (time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime(after[0])), after[1]))


async def cmd_notify(args):
    data = args.text.encode('utf-8')[:120]
    async with BleakClient(await find(args)) as c:
        await c.write_gatt_char(NOTIFY, data, response=True)
        print('sent %d bytes' % len(data))


async def cmd_imu(args):
    out = open(args.csv, 'w') if args.csv else None
    if out:
        out.write('pc_time,counter,watch_ms,ax_g,ay_g,az_g,gx_dps,gy_dps,gz_dps\n')
    stats = {'n': 0}

    def on_data(_, data):
        cnt, ax, ay, az, gx, gy, gz, ms = struct.unpack('<H6hH', bytes(data))
        stats['n'] += 1
        acc = [v / ACC_LSB_PER_G for v in (ax, ay, az)]
        gyr = [v / GYRO_LSB_PER_DPS for v in (gx, gy, gz)]
        if out:
            out.write('%.3f,%d,%d,%s,%s\n' % (time.time(), cnt, ms, ','.join('%.4f' % v for v in acc),
                                               ','.join('%.2f' % v for v in gyr)))
        print('#%5d  acc %+6.3f %+6.3f %+6.3f g   gyro %+8.2f %+8.2f %+8.2f dps' % ((cnt,) + tuple(acc) + tuple(gyr)))

    async with BleakClient(await find(args)) as c:
        await c.write_gatt_char(IMU, bytes([args.rate]), response=True)
        await c.start_notify(IMU, on_data)
        t0 = time.time()
        await asyncio.sleep(args.seconds)
        await c.stop_notify(IMU)
        dt = time.time() - t0
    print('%d samples in %.1f s = %.1f Hz' % (stats['n'], dt, stats['n'] / dt))
    if out:
        out.close()
        print('saved %s' % args.csv)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--address', help='watch BLE address (skips the scan)')
    ap.add_argument('--timeout', type=float, default=10, help='scan time, s')
    sub = ap.add_subparsers(dest='cmd', required=True)
    sub.add_parser('scan')
    p = sub.add_parser('time')
    p.add_argument('--tz', type=int, help='timezone hours (default: this PC\'s)')
    p = sub.add_parser('notify')
    p.add_argument('text')
    p = sub.add_parser('imu')
    p.add_argument('--rate', type=int, default=10, help='Hz, 1..25')
    p.add_argument('--seconds', type=float, default=10)
    p.add_argument('--csv')
    args = ap.parse_args()
    asyncio.run({'scan': cmd_scan, 'time': cmd_time, 'notify': cmd_notify, 'imu': cmd_imu}[args.cmd](args))


if __name__ == '__main__':
    sys.exit(main())

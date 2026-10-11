#!/usr/bin/env python3
"""Capture the w3_display USB log to a file, following the watch across
re-enumerations (its ttyACM number changes after a reset or a VBUS glitch).

The log port is the watch's CDC interface 00 (VID:PID 0e8d:0023).
  python3 tools/w3_logcap.py w3_log.txt --seconds 600
Lines are timestamped with the PC's clock; '--- port ...' lines mark reconnects.
"""
import argparse
import glob
import os
import time

import serial


def find_log_port():
    for path in sorted(glob.glob('/dev/ttyACM*')):
        base = '/sys/class/tty/%s/device' % os.path.basename(path)
        try:
            iface = open(base + '/bInterfaceNumber').read().strip()
            usb = os.path.realpath(base + '/..')
            vid = open(usb + '/idVendor').read().strip()
            pid = open(usb + '/idProduct').read().strip()
        except OSError:
            continue
        if vid == '0e8d' and pid == '0023' and iface == '00':
            return path
    return None


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('out')
    ap.add_argument('--seconds', type=float, default=600)
    args = ap.parse_args()

    end = time.time() + args.seconds
    out = open(args.out, 'a')
    ser, pending = None, b''
    while time.time() < end:
        if ser is None:
            port = find_log_port()
            if port:
                try:
                    ser = serial.Serial(port, 115200, timeout=0.3, exclusive=True)
                    out.write('%s --- port %s open\n' % (time.strftime('%H:%M:%S'), port))
                    out.flush()
                except (serial.SerialException, OSError):
                    ser = None
            if ser is None:
                time.sleep(0.5)
                continue
        try:
            pending += ser.read(4096)
        except (serial.SerialException, OSError):
            out.write('%s --- port lost\n' % time.strftime('%H:%M:%S'))
            out.flush()
            # Close at once: while a dead tty stays open, the kernel can't reuse
            # its ttyACM number and the watch comes back under a new one.
            try:
                ser.close()
            except (serial.SerialException, OSError):
                pass
            ser, pending = None, b''
            continue
        while b'\n' in pending:
            line, pending = pending.split(b'\n', 1)
            out.write('%s %s\n' % (time.strftime('%H:%M:%S'), line.decode(errors='replace').rstrip('\r')))
        out.flush()


if __name__ == '__main__':
    main()

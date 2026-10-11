#!/usr/bin/env python3
"""Log the W3 touch slider's per-electrode signals (needs the patched CY8C4014
firmware, version 0x18, whose I2C window is 136 bytes).

Polls AT+TPR=0,74 over the w3_display USB AT port and prints/saves:
  pos   position from the chip (0..144, 255 = none)
  st    3 = touching, 2 = idle
  act   number of active electrodes
  d0..d2  raw - baseline for electrodes 0 (top), 1, 2 (bottom), signed
  dp    the same for the proximity electrode

Layout of the window (CapSense data RAM follows the 14-byte app buffer):
  0x00  app buffer (see HARDWARE.md)
  0x2A  slider widget RAM: resolution, finger th, noise th, ..., position at +0x0E
  0x38  proximity widget RAM
  0x4A, 0x58, 0x66  slider electrode 0/1/2: raw u16, baseline u16, ... (14 bytes each)
  0x74  proximity electrode
"""
import argparse
import sys
import time

import serial

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from cy8c_bootload import AtLink, TransportError   # noqa: E402

SENSORS = (0x4A, 0x58, 0x66, 0x74)


def u16(b, o):
    return b[o] | b[o + 1] << 8


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--port', default='/dev/ttyACM0')
    ap.add_argument('--seconds', type=float, default=120)
    ap.add_argument('--csv', help='also write rows to this CSV file')
    args = ap.parse_args()

    link = AtLink(args.port)
    out = open(args.csv, 'w') if args.csv else None
    if out:
        out.write('t,pos,st,act,d0,d1,d2,dp,raw0,raw1,raw2,bsln0,bsln1,bsln2\n')
    t0 = time.time()
    while time.time() - t0 < args.seconds:
        b = b''
        try:
            for off in (0, 0x40):   # two reads: one AT reply holds at most 64 bytes
                line = [l for l in link.cmd('AT+TPR=%x,%d' % (off, 64 if off == 0 else 0x78 - 0x40))
                        if l.startswith('%04X:' % off)][0]
                b += bytes.fromhex(line[5:].replace(' ', ''))
        except (TransportError, IndexError, ValueError) as e:
            print('read error:', e)
            continue
        except (serial.SerialException, OSError) as e:
            print('USB link lost (%s); reconnecting' % e)
            time.sleep(1)
            link = AtLink(args.port)
            continue
        if len(b) != 0x78:          # a garbled (short) reply line
            print('read error: got %d bytes' % len(b))
            continue
        raw = [u16(b, o) for o in SENSORS]
        bsln = [u16(b, o + 2) for o in SENSORS]
        d = [r - s for r, s in zip(raw, bsln)]
        t = time.time() - t0
        print('%6.2f pos=%3d st=%d act=%d  d0=%5d d1=%5d d2=%5d  dp=%5d' % (t, b[0], b[1], b[5], d[0], d[1], d[2], d[3]))
        if out:
            out.write('%.2f,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n' % ((t, b[0], b[1], b[5]) + tuple(d) + tuple(raw[:3]) + tuple(bsln[:3])))
            out.flush()
        time.sleep(0.05)


if __name__ == '__main__':
    main()

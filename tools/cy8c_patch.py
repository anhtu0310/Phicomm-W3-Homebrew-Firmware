#!/usr/bin/env python3
"""Patch the Phicomm W3 touch-controller (CY8C4014) firmware image.

Reads the stock .cyacd extracted from the MT2523 flash, applies a few byte
patches, fixes the checksums and writes a new .cyacd for cy8c_bootload.py.

.cyacd format (Cypress bootloader host file, one row per line):
  header  SSSSSSSS RR CC      silicon ID, silicon rev, checksum type (00 = sum)
  rows    :AA RRRR LLLL <data> KK
          array ID, row number, data length (all big-endian hex),
          data, then KK = two's complement of the 8-bit sum of every byte
          from AA to the end of the data.

Bootloadable metadata (last flash row, 255 here) starts with a 1-byte app
checksum: the two's complement of the 8-bit sum of all app bytes. Here the
app is rows 93..247 (length 0x26C0 is also stored in the metadata). The
bootloader recomputes it at reset and only starts the app if it matches.

Patches (addresses are CY8C4014 flash addresses):
  0x1970  movs r3,#0x19 -> #0x18      version byte (buffer[3]) 0x19 -> 0x18
  0x197A  adds r3,#0x64 -> #0x65      keep the finger threshold at 380
                                      (it is computed from the same r3)
  0x1994  movs r0,r1    -> movs r0,#0x88
                                      EZI2C buffer size 14 -> 136 bytes, so the
                                      host can read the CapSense data RAM that
                                      sits right after the 14-byte buffer. The
                                      write boundary (r1) stays at 14.
Version 0x18 is deliberate: the stock MT2523 firmware reflashes the touch chip
with its own copy whenever the version is <= 0x18, so going back to stock
firmware also restores the stock touch firmware.
"""
import argparse
import sys

ROW = 64
APP_FIRST_ROW = 93
METADATA_ROW = 255

# (address, original bytes, new bytes, description)
PATCHES = [
    (0x1970, bytes.fromhex('1923'), bytes.fromhex('1823'), 'version 0x19 -> 0x18'),
    (0x197A, bytes.fromhex('6433'), bytes.fromhex('6533'), 'keep finger threshold 380'),
    (0x1994, bytes.fromhex('0800'), bytes.fromhex('8820'), 'EZI2C buffer size 14 -> 136'),
]


def read_cyacd(path):
    lines = open(path).read().split()
    header, rows = lines[0], {}
    for line in lines[1:]:
        raw = bytes.fromhex(line[1:])
        array_id, row = raw[0], int.from_bytes(raw[1:3], 'big')
        size = int.from_bytes(raw[3:5], 'big')
        data, chk = raw[5:5 + size], raw[5 + size]
        if (sum(raw[:5 + size]) + chk) & 0xFF:
            sys.exit('bad row checksum in row %d' % row)
        rows[row] = (array_id, bytearray(data))
    return header, rows


def write_cyacd(path, header, rows):
    out = [header]
    for row in sorted(rows):
        array_id, data = rows[row]
        raw = bytes([array_id]) + row.to_bytes(2, 'big') + len(data).to_bytes(2, 'big') + bytes(data)
        out.append(':' + (raw + bytes([(-sum(raw)) & 0xFF])).hex().upper())
    open(path, 'w', newline='').write('\r\n'.join(out) + '\r\n')


def app_checksum(rows, app_len):
    image = b''.join(bytes(rows[r][1]) for r in range(APP_FIRST_ROW, APP_FIRST_ROW + app_len // ROW))
    return (-sum(image)) & 0xFF


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('stock', help='stock .cyacd')
    ap.add_argument('out', help='patched .cyacd to write')
    args = ap.parse_args()

    header, rows = read_cyacd(args.stock)
    meta = rows[METADATA_ROW][1]
    app_len = int.from_bytes(meta[9:13], 'little')
    if app_checksum(rows, app_len) != meta[0]:
        sys.exit('stock app checksum does not match metadata; wrong input?')
    print('stock image OK: app rows %d..%d, checksum %02X' %
          (APP_FIRST_ROW, APP_FIRST_ROW + app_len // ROW - 1, meta[0]))

    changed = set()
    for addr, old, new, what in PATCHES:
        row, off = divmod(addr, ROW)
        data = rows[row][1]
        if data[off:off + len(old)] != old:
            sys.exit('0x%04X: expected %s, found %s' % (addr, old.hex(), data[off:off + len(old)].hex()))
        data[off:off + len(new)] = new
        changed.add(row)
        print('0x%04X row %3d: %s -> %s  (%s)' % (addr, row, old.hex(), new.hex(), what))

    meta[0] = app_checksum(rows, app_len)
    changed.add(METADATA_ROW)
    print('new app checksum %02X (row %d)' % (meta[0], METADATA_ROW))
    write_cyacd(args.out, header, rows)
    print('wrote %s; rows that differ from stock: %s' % (args.out, sorted(changed)))


if __name__ == '__main__':
    main()

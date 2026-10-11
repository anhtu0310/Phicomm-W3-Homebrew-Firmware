#!/usr/bin/env python3
"""Cypress PSoC 4 bootloader host for the Phicomm W3 touch controller (CY8C4014).

The PC cannot reach the touch chip's I2C bus directly, so every packet goes
through the w3_display firmware's USB AT passthrough:
  AT+TPPAUSE=1/0                stop/resume the firmware's own touch polling
  AT+TPR=<reg>,<len>            read app registers (EZI2C, 16-bit sub-address)
  AT+TPW=<hex>                  raw I2C write to 0x08
  AT+TPBL=<hex>,<rlen>[,<ms>]   raw write, wait, read an rlen-byte reply

Bootloader packet format (both directions), checksum type 0 = summation:
  01 | cmd/status | len lo | len hi | data... | chk lo | chk hi | 17
  chk = two's complement (16-bit) of the sum of all bytes before it.

Commands used (same flow as the stock firmware's CyBtldr_Program):
  0x38 enter bootloader  -> silicon ID (4, LE), silicon rev (1), BL version (3)
  0x32 get flash size    -> first app row (2), last row (2)
  0x37 send data         (row data in chunks; packets are kept <= 64 bytes)
  0x39 program row       array ID, row (LE), remaining data
  0x3A verify row        -> 1-byte checksum of the row in flash
  0x31 verify checksum   -> nonzero if the app checksum is valid
  0x3B exit bootloader   (chip resets, the bootloader checks the app and runs it)

The running app enters the bootloader on command 0xA5 (write 00 04 A5); the
stock firmware then waits 500 ms before the first packet.
"""
import argparse
import sys
import time

import serial

SOP, EOP = 0x01, 0x17
CMD_VERIFY_CHECKSUM = 0x31
CMD_GET_FLASH_SIZE = 0x32
CMD_SEND_DATA = 0x37
CMD_ENTER = 0x38
CMD_PROGRAM_ROW = 0x39
CMD_VERIFY_ROW = 0x3A
CMD_EXIT = 0x3B
MAX_PACKET = 64                 # the stock host uses MaxTransferSize = 0x40
STATUS = {0x00: 'success', 0x02: 'verify failed', 0x03: 'bad length', 0x04: 'bad data',
          0x05: 'bad command', 0x08: 'bad checksum', 0x09: 'bad array', 0x0A: 'bad row',
          0x0C: 'bad app', 0x0D: 'app active', 0x0F: 'unknown error'}


class TransportError(IOError):
    """The reply got lost or garbled on the way (USB text link / I2C)."""


class AtLink:
    def __init__(self, port):
        # ModemManager briefly grabs new ttyACM ports, so retry for a while.
        for _ in range(150):
            try:
                self.ser = serial.Serial(port, 115200, timeout=0.2, exclusive=True)
                break
            except serial.SerialException:
                time.sleep(0.2)
        else:
            raise SystemExit('cannot open %s' % port)
        time.sleep(0.2)
        self.ser.reset_input_buffer()

    def cmd(self, line, timeout=3.0):
        """Send one AT line, return the reply lines up to OK (raise on ERROR)."""
        self.ser.reset_input_buffer()          # drop log lines and stale replies
        self.ser.write((line + '\r').encode())
        lines, buf, end = [], b'', time.time() + timeout
        while time.time() < end:
            buf += self.ser.read(256)
            while b'\n' in buf:
                raw, buf = buf.split(b'\n', 1)
                text = raw.decode(errors='replace').strip()
                if text == 'OK':
                    return lines
                if text.startswith('ERROR'):
                    raise TransportError('%s -> %s' % (line[:40], text))
                if text and not text.startswith('['):     # skip ulog lines
                    lines.append(text)
        raise TransportError('%s -> timeout' % line[:40])


def packet(cmd, data=b''):
    body = bytes([SOP, cmd, len(data) & 0xFF, len(data) >> 8]) + bytes(data)
    return body + ((-sum(body)) & 0xFFFF).to_bytes(2, 'little') + bytes([EOP])


class Bootloader:
    def __init__(self, link, verbose=False):
        self.link = link
        self.verbose = verbose

    def xfer(self, cmd, data=b'', rlen=0):
        """Send a packet; rlen = expected reply data bytes (None = no reply)."""
        pkt = packet(cmd, data)
        assert len(pkt) <= MAX_PACKET
        if rlen is None:
            self.link.cmd('AT+TPBL=%s' % pkt.hex().upper())
            return None
        total = 7 + rlen
        lines = self.link.cmd('AT+TPBL=%s,%d' % (pkt.hex().upper(), total))
        try:
            rsp = bytes.fromhex([l for l in lines if l.startswith('TPBL:')][0][5:].strip())
        except (IndexError, ValueError):
            raise TransportError('unreadable reply %r' % lines)
        if self.verbose:
            print('  >', pkt.hex(' '), '\n  <', rsp.hex(' '))
        n = int.from_bytes(rsp[2:4], 'little')
        if len(rsp) != total or rsp[0] != SOP or rsp[-1] != EOP or n != rlen:
            raise TransportError('malformed reply %s' % rsp.hex(' '))
        if (sum(rsp[:4 + n]) + int.from_bytes(rsp[4 + n:6 + n], 'little')) & 0xFFFF:
            raise TransportError('reply checksum error %s' % rsp.hex(' '))
        if rsp[1] != 0:
            raise IOError('cmd %02X: status %02X (%s)' % (cmd, rsp[1], STATUS.get(rsp[1], '?')))
        return rsp[4:4 + n]

    def enter(self):
        d = self.xfer(CMD_ENTER, rlen=8)
        return int.from_bytes(d[0:4], 'little'), d[4], d[5:8]

    def flash_size(self, array_id=0):
        d = self.xfer(CMD_GET_FLASH_SIZE, bytes([array_id]), rlen=4)
        return int.from_bytes(d[0:2], 'little'), int.from_bytes(d[2:4], 'little')

    def program_row(self, array_id, row, data):
        offset = 0
        chunk = MAX_PACKET - 7                    # a full SEND_DATA packet
        while len(data) - offset > MAX_PACKET - 10:
            self.xfer(CMD_SEND_DATA, data[offset:offset + chunk], rlen=0)
            offset += chunk
        self.xfer(CMD_PROGRAM_ROW, bytes([array_id]) + row.to_bytes(2, 'little') + data[offset:], rlen=0)

    def retry(self, fn, *args):
        """Run a read-only command again if its reply got garbled."""
        for attempt in range(3):
            try:
                return fn(*args)
            except TransportError as e:
                print('\n  retry after: %s' % e)
        return fn(*args)

    def verify_row(self, array_id, row):
        return self.retry(lambda: self.xfer(CMD_VERIFY_ROW, bytes([array_id]) + row.to_bytes(2, 'little'), rlen=1)[0])

    def verify_app(self):
        return self.retry(lambda: self.xfer(CMD_VERIFY_CHECKSUM, rlen=1)[0])

    def exit(self):
        self.xfer(CMD_EXIT, rlen=None)


def read_cyacd(path):
    lines = open(path).read().split()
    header = bytes.fromhex(lines[0])
    rows = []
    for line in lines[1:]:
        raw = bytes.fromhex(line[1:])
        size = int.from_bytes(raw[3:5], 'big')
        rows.append((raw[0], int.from_bytes(raw[1:3], 'big'), raw[5:5 + size], raw[5 + size]))
    return int.from_bytes(header[0:4], 'big'), header[4], header[5], rows


def expected_row_checksum(array_id, row, data, line_chk):
    """What VERIFY_ROW returns for a correctly written row (CyBtldr formula)."""
    size = len(data)
    return (line_chk + array_id + (row & 0xFF) + (row >> 8) + (size & 0xFF) + (size >> 8)) & 0xFF


def read_app_regs(link):
    """Read the app's first 6 registers (raises if the app does not answer)."""
    lines = [l for l in link.cmd('AT+TPR=0,6') if l.startswith('0000:')]
    if not lines:
        raise IOError('no register reply')
    return bytes.fromhex(lines[0][5:].replace(' ', ''))


def start(link, bl, si_id_expected=None):
    """Pause our polling, put the touch chip into its bootloader, say hello."""
    link.cmd('AT+TPPAUSE=1')
    try:
        regs = read_app_regs(link)
        print('app running: version 0x%02X, regs %s' % (regs[3], regs.hex(' ')))
        link.cmd('AT+TPW=0004A5')
        time.sleep(0.5)
    except IOError as e:
        print('no app reply (%s); assuming the bootloader is already active' % e)
    si_id, si_rev, bl_ver = bl.enter()
    print('bootloader: silicon ID %08X rev %02X, bootloader version %s' % (si_id, si_rev, bl_ver[::-1].hex()))
    if si_id_expected is not None and si_id != si_id_expected:
        raise IOError('silicon ID mismatch: file %08X, chip %08X' % (si_id_expected, si_id))
    first, last = bl.flash_size(0)
    print('app flash rows %d..%d' % (first, last))
    return first, last


def finish(link, bl):
    bl.exit()
    # The chip resets, the bootloader checks the app checksum, then the app
    # starts; give it a few tries to answer the wake-up command.
    for attempt in range(10):
        time.sleep(0.5)
        try:
            link.cmd('AT+TPPAUSE=0')
            break
        except TransportError:
            link.cmd('AT+TPPAUSE=1')
    else:
        raise IOError('touch app did not come back')
    regs = read_app_regs(link)
    print('app running again: version 0x%02X, regs %s' % (regs[3], regs.hex(' ')))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--port', default='/dev/ttyACM0')
    ap.add_argument('-v', '--verbose', action='store_true', help='print every packet')
    sub = ap.add_subparsers(dest='action', required=True)
    sub.add_parser('info', help='enter the bootloader, print IDs, exit')
    p = sub.add_parser('verify', help='compare every row in the chip with a .cyacd (no writes)')
    p.add_argument('cyacd')
    p = sub.add_parser('program', help='write a .cyacd')
    p.add_argument('cyacd')
    p.add_argument('--diff', metavar='REF',
                   help='only write rows whose data differs from REF.cyacd (e.g. the stock image the chip runs). '
                        'Do not pick rows by comparing chip checksums: a patch can leave an 8-bit row sum unchanged')
    sub.add_parser('exit', help='leave the bootloader and resume polling')
    args = ap.parse_args()

    link = AtLink(args.port)
    bl = Bootloader(link, args.verbose)

    if args.action == 'exit':
        finish(link, bl)
        return
    if args.action == 'info':
        start(link, bl)
        finish(link, bl)
        return

    si_id, si_rev, chk_type, rows = read_cyacd(args.cyacd)
    if chk_type != 0:
        sys.exit('only summation checksums are supported')
    first, last = start(link, bl, si_id)
    for _, row, _, _ in rows:
        if not first <= row <= last:
            sys.exit('row %d outside the app area %d..%d' % (row, first, last))

    if args.action == 'verify':
        bad = []
        for array_id, row, data, chk in rows:
            got, want = bl.verify_row(array_id, row), expected_row_checksum(array_id, row, data, chk)
            if got != want:
                bad.append(row)
            sys.stdout.write('\rrow %3d: chip %02X file %02X %s' % (row, got, want, 'ok ' if got == want else 'DIFF\n'))
        print('\n%d rows checked, %d differ: %s' % (len(rows), len(bad), bad))
        print('app checksum valid' if bl.verify_app() else 'app checksum INVALID')
        finish(link, bl)
        return

    todo = rows
    if args.diff:
        ref = {row: data for _, row, data, _ in read_cyacd(args.diff)[3]}
        todo = [r for r in rows if ref.get(r[1]) != r[2]]
        print('%d of %d rows differ from %s: %s' % (len(todo), len(rows), args.diff, [r[1] for r in todo]))
    t0 = time.time()
    for i, (array_id, row, data, chk) in enumerate(todo):
        want = expected_row_checksum(array_id, row, data, chk)
        for attempt in range(3):
            # Any command other than SEND_DATA resets the bootloader's data
            # buffer, so a failed row can simply be sent again from the start.
            try:
                bl.program_row(array_id, row, data)
            except TransportError as e:
                print('\n  row %d: %s; retrying' % (row, e))
                continue
            got = bl.verify_row(array_id, row)
            if got == want:
                break
            print('\n  row %d: chip %02X, expected %02X; retrying' % (row, got, want))
        else:
            sys.exit('\nrow %d failed 3 times (chip stays in bootloader; rerun)' % row)
        sys.stdout.write('\rprogrammed row %3d (%d/%d)' % (row, i + 1, len(todo)))
        sys.stdout.flush()
    print('\n%d rows in %.1f s' % (len(todo), time.time() - t0))
    if not bl.verify_app():
        sys.exit('app checksum INVALID; chip stays in bootloader. Reprogram (e.g. the stock .cyacd).')
    print('app checksum valid')
    finish(link, bl)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""MT2523 USB flash tool for Linux (BROM + MediaTek legacy IoT DA).

Talks to the MT2523 Boot ROM over USB CDC, uploads MediaTek's own download
agent (tools/da/MTK_AllInOne_DA.bin, from the LinkIt SDK IoT Flash Tool) and
uses it to access the internal NOR flash. The DA bring-up sequence follows
mtkclient's MT2523 path (bkerler/mtkclient, Library/DA/legacy/dalegacy_lib.py).

Entering BROM download mode: either power the watch off and plug in USB while
this tool is waiting, or pass --reboot (or --reboot-from /dev/ttyACMx) to make
the running firmware reboot itself (AT+EWDT=1) into the BROM USB window.
--reboot finds the watch's AT port by USB ID; with --reboot-from, the given
port is used if it is the watch, else it falls back to the same search.

Commands:
  info                         connect, print flash info
  read ADDR LEN FILE           read flash (ADDR absolute, or an offset into flash)
  write ADDR FILE              write + verify (bootloader area is protected)
  erase ADDR LEN               fill a range with 0xFF
  reboot                       reset the watch via the DA watchdog

Example (stock firmware running, app slot at 0x08010000):
  tools/mt2523_flash.py --reboot write 0x08010000 app.bin
"""
import argparse
import os
import struct
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mt2523_brom import Brom, trigger_wdt_reboot, wait_for_brom_port  # noqa: E402

DA_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'da', 'MTK_AllInOne_DA.bin')
FLASH_BASE = 0x08000000
ACK = b'\x5A'
NACK = b'\xA5'


class DaEntry:
    """One MT2523 entry from a legacy MTK_AllInOne_DA.bin."""

    def __init__(self, path, hw_code=0x2523):
        d = open(path, 'rb').read()
        if not d.startswith(b'MTK_DOWNLOAD_AGENT'):
            raise SystemExit('%s is not a legacy DA file' % path)
        _, magic, count = struct.unpack_from('<III', d, 0x60)
        for n in range(count):
            off = 0x6C + n * 0xDC
            magic, hw, sub = struct.unpack_from('<3H', d, off)
            index, cnt = struct.unpack_from('<2H', d, off + 16)
            pagesize = struct.unpack_from('<H', d, off + 12)[0]
            if magic == 0xDADA and hw == hw_code and pagesize == 0:
                self.entry_region_index = index
                self.regions = []
                for r in range(cnt):
                    buf, ln, start, _, sig = struct.unpack_from('<5I', d, off + 20 + r * 20)
                    self.regions.append(dict(data=d[buf:buf + ln], start=start, sig=sig))
                return
        raise SystemExit('no DA entry for hw code 0x%04X' % hw_code)


def prepare_data(data):
    if len(data) % 2:
        data += b'\x00'
    chk = 0
    for i in range(0, len(data), 2):
        chk ^= struct.unpack_from('<H', data, i)[0]
    return chk, data


class Mt2523(Brom):
    verbose = False

    def log(self, msg):
        if self.verbose:
            print('  [dbg] ' + msg)

    def w(self, data):
        self.s.write(data)

    def r(self, n):
        out = b''
        deadline = time.time() + 5
        while len(out) < n and time.time() < deadline:
            out += self.s.read(n - len(out))
        if len(out) != n:
            raise IOError('timeout reading %d bytes (got %s)' % (n, out.hex()))
        return out

    def rword(self):
        return struct.unpack('>H', self.r(2))[0]

    def rdword(self):
        return struct.unpack('>I', self.r(4))[0]

    def echo32(self, v):
        self._echo(struct.pack('>I', v))

    def upload(self, data, chk):
        for i in range(0, len(data), 0x400):
            self.w(data[i:i + 0x400])
        self.s.flush()
        time.sleep(0.12)
        rchk, status = self.rword(), self.rword()
        self.log('upload checksum host 0x%04X dev 0x%04X status 0x%04X' % (chk, rchk, status))
        if status > 0xFF:
            raise IOError('upload status 0x%04X' % status)
        if rchk not in (chk, 0):
            raise IOError('upload checksum mismatch: host 0x%04X dev 0x%04X' % (chk, rchk))

    def send_env_prepare(self, addr, data):
        chk, data = prepare_data(data)
        self._echo(b'\xD9')
        self.echo32(addr)
        self.echo32(len(data))
        self.echo32(0x0400A000)
        self.echo32(0x1000)
        st = self.rword()
        if st != 0:
            raise IOError('SEND_ENV_PREPARE status 0x%04X' % st)
        self.upload(data, chk)
        # Exchange with the env program (EMI/clock setup), as captured from
        # the official tool; values are logged only.
        seq = ['d', 'w', 'A', 'w', 'A', '\x00', 'w', 'A', 'w', 'A', 'i', 'w', 'A', 'w', 'A',
               'w', 'd', 'A', 'w', 'd']
        for op in seq:
            if op == 'd':
                self.log('env dword 0x%08X' % self.rdword())
            elif op == 'w':
                self.log('env word  0x%04X' % self.rword())
            elif op == 'A':
                self.w(ACK)
            elif op == 'i':
                self.w(b'\x69')
            else:
                self.w(op.encode())

    def send_da(self, addr, data, sig_len=0):
        chk, data = prepare_data(data)
        self._echo(b'\xD7')
        self.echo32(addr)
        self.echo32(len(data))
        self.echo32(sig_len)
        st = self.rword()
        if st > 0xFF:
            raise IOError('SEND_DA status 0x%04X' % st)
        self.upload(data, chk)

    def jump_da(self, addr):
        self._echo(b'\xD5')
        self.w(struct.pack('>I', addr))
        if self.rdword() != addr:
            raise IOError('JUMP_DA address echo mismatch')
        st = self.rword()
        if st != 0:
            raise IOError('JUMP_DA status 0x%04X' % st)

    def connect_da(self, da):
        env = da.regions[0]
        print('Uploading DA env (%d bytes) to 0x%08X' % (len(env['data']), env['start']))
        self.send_env_prepare(env['start'], env['data'])
        st1 = da.regions[da.entry_region_index]
        print('Uploading DA stage 1 (%d bytes) to 0x%08X' % (len(st1['data']), st1['start']))
        self.send_da(st1['start'], st1['data'], st1['sig'])
        self.jump_da(st1['start'])
        sync = self.r(1)
        if sync != b'\xC0':
            raise IOError('no DA sync (got %s)' % sync.hex())
        print('DA running (sync 0xC0)')
        for tx in (b'\x3F', b'\xF3', b'\xC0', b'\x0C'):
            self.w(tx)
            self.log('handshake %s -> %s' % (tx.hex(), self.r(1).hex()))
        for tx in (b'\x00', b'\x01'):
            self.w(tx)
            self.log('conf %s -> %s' % (tx.hex(), self.r(1).hex()))
        self.w(ACK)
        chipid = self.r(6)
        print('Flash chip ID: %s' % chipid.hex())
        chipdb = da.regions[4]['data']
        esize = len(da.regions[5]['data'])
        for off in range(0, len(chipdb), esize):
            entry = chipdb[off:off + esize]
            if entry[0x11:0x17] != chipid:
                continue
            self.w(bytes([esize]))
            if self.r(1) != ACK:
                raise IOError('no ACK for flash table entry size')
            self.w(entry)
            st = self.rdword()
            if st != 0:
                raise IOError('flash setup status 0x%08X' % st)
            info = self.r(0x3E)
            if self.r(1) != ACK:
                raise IOError('no ACK after flash info')
            self.w(ACK)
            base, size = struct.unpack_from('>II', info, 0)
            print('NOR flash: base 0x%08X size 0x%X (%d KB)' % (base, size, size // 1024))
            self.flash_base, self.flash_size = base, size
            return
        raise IOError('flash chip %s not in DA table' % chipid.hex())

    def read_flash(self, addr, length, packet=0x1000, progress=True):
        self.w(b'\xD6')
        self.w(struct.pack('>III', addr, length, packet))
        ack = self.r(1)
        if ack != ACK:
            self.w(NACK)
            raise IOError('READ_CMD rejected: %s status 0x%08X' % (ack.hex(), struct.unpack('<I', self.r(4))[0]))
        out = bytearray()
        t0 = time.time()
        while len(out) < length:
            n = min(packet, length - len(out))
            chunk = self.r(n)
            dev_chk = self.rword()
            host_chk = sum(chunk) & 0xFFFF
            if dev_chk != host_chk:
                self.log('chunk @0x%X checksum dev 0x%04X host-sum 0x%04X' % (addr + len(out), dev_chk, host_chk))
            out += chunk
            self.w(ACK)
            if progress:
                rate = len(out) / max(time.time() - t0, 1e-3) / 1024
                sys.stdout.write('\r  read %d/%d KB (%.0f KB/s)' % (len(out) // 1024, length // 1024, rate))
                sys.stdout.flush()
        if progress:
            print()
        return bytes(out)

    def write_flash(self, addr, data, packet=0x1000, progress=True):
        """DA command 0xB2 (NOR write; the DA erases sectors as it goes).

        Framing: header -> 5A (accepted) 5A (first erase done); per packet:
        data + sum16(BE) -> 69; after the last packet the DA also sends 5A;
        then total sum16(BE) -> 5A, flag byte 0 -> 5A.
        """
        if len(data) % packet:
            data += b'\xFF' * (packet - len(data) % packet)
        self.w(b'\xB2' + struct.pack('>III', addr, len(data), packet))
        for step in ('header', 'erase'):
            ack = self.r(1)
            if ack != ACK:
                raise IOError('NOR write rejected after %s: %s' % (step, ack.hex()))
        t0 = time.time()
        for off in range(0, len(data), packet):
            chunk = data[off:off + packet]
            self.w(chunk + struct.pack('>H', sum(chunk) & 0xFFFF))
            r = self.r(1)
            if r != b'\x69':
                raise IOError('packet at 0x%08X not accepted: %s' % (addr + off, r.hex()))
            if progress:
                rate = (off + packet) / max(time.time() - t0, 1e-3) / 1024
                sys.stdout.write('\r  write %d/%d KB (%.0f KB/s)' % ((off + packet) // 1024, len(data) // 1024, rate))
                sys.stdout.flush()
        if progress:
            print()
        if self.r(1) != ACK:
            raise IOError('no ACK after last packet')
        self.w(struct.pack('>H', sum(data) & 0xFFFF))
        r = self.r(1)
        if r != ACK:
            raise IOError('total checksum rejected: %s %s' % (r.hex(), self.r(4).hex()))
        self.w(b'\x00')
        if self.r(1) != ACK:
            raise IOError('no final ACK')
        return len(data)


def _reboot(self, ms):
    """DA command 0xDB: arm the watchdog (u16 timeout) to reset the chip."""
    self.w(b'\xDB')
    self.w(struct.pack('>H', ms))
    try:
        ack = self.r(1)
    except (IOError, OSError):
        ack = b''
    if ack != ACK:
        print('warning: ENABLE_WATCHDOG reply %r (the watch usually resets anyway)' % ack)


Mt2523.reboot = _reboot


def open_device(args):
    if args.attached:
        dev = Mt2523(wait_for_brom_port(args.timeout))
        dev.verbose = args.verbose
        print('Attached to an already running DA')
        return dev
    if args.reboot_from:
        trigger_wdt_reboot(None if args.reboot_from == 'auto' else args.reboot_from)
    dev = Mt2523(wait_for_brom_port(args.timeout, rebooting=bool(args.reboot_from)))
    dev.verbose = args.verbose
    dev.handshake()
    print('BROM handshake OK, BROM version 0x%02X' % (dev._u8(b'\xFF')))
    cfg, _ = dev.get_target_config()
    if cfg & 0x7:
        raise SystemExit('target security enabled (config 0x%08X), not supported' % cfg)
    dev.connect_da(DaEntry(args.da))
    return dev


def parse_addr(s):
    """The DA expects absolute addresses; accept offsets into flash too."""
    v = int(s, 0)
    return v if v >= FLASH_BASE else FLASH_BASE + v


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--reboot-from', metavar='TTY', help='firmware AT port to send AT+EWDT=1 to')
    ap.add_argument('--reboot', dest='reboot_from', action='store_const', const='auto',
                    help='send AT+EWDT=1 to the watch, finding its AT port by USB ID')
    ap.add_argument('--da', default=DA_FILE)
    ap.add_argument('--timeout', type=float, default=120)
    ap.add_argument('-v', '--verbose', action='store_true')
    ap.add_argument('--attached', action='store_true', help='DA is already running (skip BROM/DA bring-up)')
    ap.add_argument('--no-reboot', action='store_true', help='leave the DA running afterwards')
    sub = ap.add_subparsers(dest='cmd', required=True)
    sub.add_parser('info')
    p = sub.add_parser('reboot', help='reset the watch via the DA watchdog command')
    p.add_argument('--ms', type=lambda x: int(x, 0), default=1000)
    p = sub.add_parser('read')
    p.add_argument('addr')
    p.add_argument('length')
    p.add_argument('file')
    p = sub.add_parser('write', help='write FILE at ADDR (erases as needed), then verify by readback')
    p.add_argument('addr')
    p.add_argument('file')
    p.add_argument('--no-verify', action='store_true')
    p = sub.add_parser('erase', help='set a range to 0xFF (via write of 0xFF bytes)')
    p.add_argument('addr')
    p.add_argument('length')
    args = ap.parse_args()

    dev = open_device(args)
    if args.cmd in ('write', 'erase'):
        addr = parse_addr(args.addr)
        data = open(args.file, 'rb').read() if args.cmd == 'write' else b'\xFF' * int(args.length, 0)
        if addr < FLASH_BASE + 0x10000 and not os.environ.get('MT2523_ALLOW_BOOTLOADER'):
            raise SystemExit('refusing to touch the bootloader (0x08000000-0x0800FFFF); '
                             'set MT2523_ALLOW_BOOTLOADER=1 to override')
        print('Writing %d bytes to 0x%08X' % (len(data), addr))
        n = dev.write_flash(addr, data)
        if not args.cmd == 'write' or not args.no_verify:
            rb = dev.read_flash(addr, len(data), progress=False)
            if rb != data:
                bad = next(i for i in range(len(data)) if rb[i] != data[i])
                raise SystemExit('VERIFY FAILED at 0x%08X' % (addr + bad))
            print('Verified %d bytes (%d written incl. padding)' % (len(data), n))
    if args.cmd == 'reboot':
        dev.reboot(args.ms)
        print('Watchdog armed, watch will reset')
    elif args.cmd == 'read':
        addr, length = parse_addr(args.addr), int(args.length, 0)
        data = dev.read_flash(addr, length)
        open(args.file, 'wb').write(data)
        print('Saved %d bytes from 0x%08X to %s' % (len(data), addr, args.file))
    if args.cmd != 'reboot' and not args.no_reboot:
        dev.reboot(1000)
        print('Rebooting the watch')


if __name__ == '__main__':
    main()

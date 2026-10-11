#!/usr/bin/env python3
"""MT2523 Boot ROM (BROM) USB probe for Linux.

Waits for the MT2523 to enumerate in BROM download mode (power the watch off,
start this script, then plug in USB), performs the MediaTek BROM handshake and
reads chip identification. It never writes to flash.

Usage:
  python3 tools/mt2523_brom.py probe            # identify, then reboot via WDT
  python3 tools/mt2523_brom.py probe --stay     # identify, leave in BROM

BROM commands used (standard MediaTek BROM protocol, big-endian):
  0xA0 0x0A 0x50 0x05  handshake (replies are the bitwise inverse)
  0xFD                 GET_HW_CODE  -> hw_code(2), status(2)
  0xFC                 GET_HW_SW_VER-> hw_subcode(2), hw_ver(2), sw_ver(2), status(2)
  0xFE                 GET_BL_VER   -> 1 byte (echo means BROM, not preloader)
  0xD8                 GET_TARGET_CONFIG -> config(4), status(2)
  0xD1                 READ32 addr, count
  0xD4                 WRITE32 addr, count, values  (used only for WDT reset)
"""
import argparse
import glob
import os
import struct
import sys
import time

import serial

MTK_VID = '0e8d'
NORMAL_PIDS = {'0023'}           # stock firmware composite CDC device
WDT_BASE = 0xA2050000
WDT_MODE = WDT_BASE + 0x00
WDT_SWRST = WDT_BASE + 0x1C


def usb_ids(tty):
    dev = os.path.realpath('/sys/class/tty/%s/device' % tty)
    for _ in range(4):
        vid = os.path.join(dev, 'idVendor')
        if os.path.exists(vid):
            return open(vid).read().strip(), open(os.path.join(dev, 'idProduct')).read().strip()
        dev = os.path.dirname(dev)
    return None, None


def tty_usb_info(path):
    """(USB device sysfs dir, VID, PID, interface number) of a ttyACM node, or None.

    The sysfs dir (e.g. .../usb1/1-1/1-1.1/1-1.1.1) names the physical USB
    port, so it stays the same when the watch re-enumerates under another
    ttyACM number, while the PID tells firmware (0023) from BROM (0003)."""
    base = '/sys/class/tty/%s/device' % os.path.basename(path)
    try:
        iface = open(base + '/bInterfaceNumber').read().strip()
        usb = os.path.realpath(base + '/..')
        return usb, open(usb + '/idVendor').read().strip(), open(usb + '/idProduct').read().strip(), iface
    except OSError:
        return None


def find_at_port():
    """The running firmware's AT port: CDC interface 00 of 0e8d:0023, whatever its ttyACM number."""
    for path in sorted(glob.glob('/dev/ttyACM*')):
        info = tty_usb_info(path)
        if info and info[1] == MTK_VID and info[2] in NORMAL_PIDS and info[3] == '00':
            return path
    return None


def firmware_gone(usb):
    """True once the watch at USB dir usb has left firmware mode (unplugged or now in BROM)."""
    try:
        return open(usb + '/idProduct').read().strip() not in NORMAL_PIDS
    except OSError:
        return True


def wait_for_brom_port(timeout, rebooting=False):
    print('Waiting for MT2523 in download mode (VID %s, not PID %s)...' % (MTK_VID, '/'.join(NORMAL_PIDS)))
    if rebooting:
        print('-> If it does not show up within a few seconds, unplug and replug the USB cable.')
    else:
        print('-> Power the watch OFF, then plug in the USB cable now.')
    deadline = time.time() + timeout
    while time.time() < deadline:
        for path in glob.glob('/dev/ttyACM*'):
            vid, pid = usb_ids(os.path.basename(path))
            if vid == MTK_VID and pid not in NORMAL_PIDS:
                print('Found %s (%s:%s)' % (path, vid, pid))
                return path
        time.sleep(0.005)
    raise SystemExit('timeout: no download-mode port appeared')


class Brom:
    def __init__(self, port):
        for _ in range(200):
            try:
                self.s = serial.Serial(port, 115200, timeout=0.5)
                break
            except serial.SerialException:
                time.sleep(0.005)
        else:
            raise SystemExit('cannot open %s' % port)

    def handshake(self):
        self.s.reset_input_buffer()
        for _ in range(500):
            self.s.write(b'\xA0')
            r = self.s.read(1)
            if r == b'\x5F':
                break
            if r:
                self.s.reset_input_buffer()
        else:
            raise SystemExit('no reply to 0xA0 handshake')
        for b in (0x0A, 0x50, 0x05):
            self.s.write(bytes([b]))
            r = self.s.read(1)
            if r != bytes([b ^ 0xFF]):
                raise SystemExit('handshake failed at 0x%02X: got %r' % (b, r))

    def _echo(self, data):
        self.s.write(data)
        r = self.s.read(len(data))
        if r != data:
            raise IOError('echo mismatch: sent %s got %s' % (data.hex(), r.hex()))

    def _u16(self):
        r = self.s.read(2)
        if len(r) != 2:
            raise IOError('short read')
        return struct.unpack('>H', r)[0]

    def _u32(self):
        r = self.s.read(4)
        if len(r) != 4:
            raise IOError('short read')
        return struct.unpack('>I', r)[0]

    def _u8(self, cmd):
        """Send a one-byte command whose reply is a single byte (e.g. 0xFF)."""
        self.s.write(cmd)
        r = self.s.read(1)
        if len(r) != 1:
            raise IOError('no reply to %s' % cmd.hex())
        return r[0]

    def get_hw_code(self):
        self._echo(b'\xFD')
        return self._u16(), self._u16()

    def get_hw_sw_ver(self):
        self._echo(b'\xFC')
        return self._u16(), self._u16(), self._u16(), self._u16()

    def get_bl_ver(self):
        self.s.write(b'\xFE')
        return self.s.read(1)

    def get_target_config(self):
        self._echo(b'\xD8')
        return self._u32(), self._u16()

    def read32(self, addr, count=1):
        self._echo(b'\xD1')
        self._echo(struct.pack('>I', addr))
        self._echo(struct.pack('>I', count))
        st = self._u16()
        if st > 0xFF:
            raise IOError('READ32 status 0x%04X' % st)
        vals = [self._u32() for _ in range(count)]
        self._u16()
        return vals

    def write32(self, addr, values):
        self._echo(b'\xD4')
        self._echo(struct.pack('>I', addr))
        self._echo(struct.pack('>I', len(values)))
        st = self._u16()
        if st > 0xFF:
            raise IOError('WRITE32 status 0x%04X' % st)
        for v in values:
            self._echo(struct.pack('>I', v))
        return self._u16()


def probe(args):
    port = wait_for_brom_port(args.timeout, rebooting=bool(args.reboot_from))
    b = Brom(port)
    b.handshake()
    print('Handshake OK')
    hw, st = b.get_hw_code()
    print('HW code      : 0x%04X (status 0x%04X)' % (hw, st))
    sub, hwv, swv, st = b.get_hw_sw_ver()
    print('HW subcode   : 0x%04X  HW ver: 0x%04X  SW ver: 0x%04X' % (sub, hwv, swv))
    blv = b.get_bl_ver()
    print('BL ver reply : %r (0xFE echoed = BROM)' % blv)
    try:
        cfg, st = b.get_target_config()
        print('Target config: 0x%08X (SBC=%d SLA=%d DAA=%d) status 0x%04X' % (
            cfg, cfg & 1, (cfg >> 1) & 1, (cfg >> 2) & 1, st))
    except IOError as e:
        print('Target config: not supported (%s)' % e)
    try:
        print('WDT_MODE     : 0x%08X' % b.read32(WDT_MODE)[0])
    except IOError as e:
        print('READ32       : not allowed (%s)' % e)
    if args.stay:
        print('Leaving device in BROM mode.')
        return
    print('Rebooting via watchdog...')
    try:
        b.write32(WDT_SWRST, [0x1209])
    except IOError:
        pass


def explore(args):
    """Send raw hex chunks after the handshake and print every byte returned."""
    port = wait_for_brom_port(args.timeout)
    b = Brom(port)
    b.handshake()
    print('Handshake OK')
    for chunk in args.chunks:
        data = bytes.fromhex(chunk)
        b.s.write(data)
        time.sleep(args.gap)
        r = b.s.read(b.s.in_waiting or 0)
        print('%-12s -> %s' % (data.hex(), r.hex() or '(nothing)'))


def trigger_wdt_reboot(at_port=None):
    """Reboot the running firmware into BROM's USB window via AT+EWDT=1.

    Returns as soon as the watch drops off USB, so the caller can start
    looking for the BROM port (it is only up for about a second).

    The watch is tracked by its USB device, not by the tty name: the BROM
    port often comes up under another ttyACM number (the kernel only reuses
    a number once every program has closed it, and a forgotten miniterm or
    ModemManager may still hold the old one). Re-opening the old name in a
    loop used to miss the whole download window. at_port is used if it is
    the watch's firmware AT port; otherwise (or if None) the port is found
    by USB ID.
    """
    deadline = time.time() + 30
    attempt = 0
    while time.time() < deadline:
        port = at_port
        info = tty_usb_info(port) if port else None
        if not info or info[1] != MTK_VID or info[2] not in NORMAL_PIDS:
            if at_port and attempt == 0:
                print('%s is not the watch firmware AT port; searching by USB ID' % at_port)
            port = find_at_port()
            info = tty_usb_info(port) if port else None
        if not info:
            time.sleep(0.2)
            continue
        usb = info[0]
        # ModemManager briefly opens freshly enumerated ACM ports; retry while busy.
        try:
            s = serial.Serial(port, 115200, timeout=0.3)
        except (serial.SerialException, OSError):
            time.sleep(0.2)
            continue
        # A leading CR/LF ends any junk already in the watch's line buffer (e.g.
        # from ModemManager's probes), which otherwise makes the first command
        # fail. Another program reading the same port (miniterm, w3_logcap) can
        # take the reply, so the watch leaving USB counts as success too.
        reply = b''
        try:
            s.reset_input_buffer()
            s.write(b'\r\nAT+EWDT=1\r\n')
            s.flush()
            end = time.time() + 1.5
            while time.time() < end and not firmware_gone(usb):
                reply += s.read(256)
        except (serial.SerialException, OSError):
            pass                                    # the port vanished: the watch reset
        finally:
            try:
                s.close()
            except (serial.SerialException, OSError):
                pass
        attempt += 1
        # Our firmware replies, then resets 300 ms later; give it time to go.
        end = time.time() + 1.0
        while time.time() < end and not firmware_gone(usb):
            time.sleep(0.01)
        if firmware_gone(usb):
            print('Sent AT+EWDT=1 on %s: watch left USB (%s), rebooting'
                  % (port, 'acknowledged' if b'OK' in reply or b'rebooting' in reply else 'no reply seen'))
            return True
        if attempt >= 3:
            print('Sent AT+EWDT=1 on %s %d times, but the watch stayed on USB; continuing' % (port, attempt))
            return False
        print('Watch still on USB after AT+EWDT=1 on %s, retrying' % port)
    print('Could not find or open the watch AT port within 30 s')
    return False


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--reboot-from', metavar='TTY',
                    help='send AT+EWDT=1 to this firmware AT port first (e.g. /dev/ttyACM0)')
    ap.add_argument('--reboot', dest='reboot_from', action='store_const', const='auto',
                    help='like --reboot-from, but find the AT port by USB ID')
    sub = ap.add_subparsers(dest='cmd', required=True)
    p = sub.add_parser('probe')
    p.add_argument('--stay', action='store_true', help='do not reboot afterwards')
    p.add_argument('--timeout', type=float, default=120)
    p = sub.add_parser('explore')
    p.add_argument('chunks', nargs='+', help='hex byte strings sent one after another')
    p.add_argument('--gap', type=float, default=0.3, help='seconds to wait for a reply')
    p.add_argument('--timeout', type=float, default=120)
    args = ap.parse_args()
    if args.reboot_from:
        trigger_wdt_reboot(None if args.reboot_from == 'auto' else args.reboot_from)
    if args.cmd == 'probe':
        probe(args)
    elif args.cmd == 'explore':
        explore(args)


if __name__ == '__main__':
    sys.exit(main())

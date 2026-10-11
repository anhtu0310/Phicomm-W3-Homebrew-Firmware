#!/usr/bin/env python3
"""Disassemble a range of the stock MT2523 flash dump (Thumb-2, Cortex-M4).

  python3 tools/armdis.py stock_fw/flash_4MB_usb_readback.bin 0x3d900 0x3da00

Offsets are file offsets; printed addresses are file offset + 0x08000000 (the
XIP flash base). PC-relative loads show the loaded constant, and the string
it points to when it looks like text, which is how log messages identify
functions in a stripped firmware.
"""
import struct
import sys

import capstone

BASE = 0x08000000


def main():
    data = open(sys.argv[1], 'rb').read()
    addr, end = int(sys.argv[2], 16), int(sys.argv[3], 16)
    md = capstone.Cs(capstone.CS_ARCH_ARM, capstone.CS_MODE_THUMB | capstone.CS_MODE_MCLASS)
    while addr < end:
        insn = next(md.disasm(data[addr:addr + 4], BASE + addr), None)
        if insn is None:
            print('%08X: .hword %s' % (BASE + addr, data[addr:addr + 2].hex()))
            addr += 2
            continue
        extra = ''
        if insn.mnemonic.startswith('ldr') and 'pc' in insn.op_str and '#' in insn.op_str:
            try:
                imm = int(insn.op_str.split('#')[1].rstrip(']'), 16)
                lit = ((BASE + addr + 4) & ~3) + imm - BASE
                value = struct.unpack('<I', data[lit:lit + 4])[0]
                extra = '  ; =0x%08X' % value
                if BASE <= value < BASE + len(data):
                    s = data[value - BASE:value - BASE + 60].split(b'\0')[0]
                    if s and all(32 <= c < 127 or c in (9, 10, 13) for c in s):
                        extra += ' "%s"' % s.decode().strip()
            except (ValueError, struct.error):
                pass
        print('%08X: %-8s %s%s' % (insn.address, insn.mnemonic, insn.op_str, extra))
        addr += insn.size


if __name__ == '__main__':
    main()

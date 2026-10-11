#!/usr/bin/env python3
"""Generate an EPT ept_gpio_drv.h that reproduces a live GPIO configuration.

Inputs:
  template   - an SDK ept_gpio_drv.h (defines which macros exist per pin)
  pinmux     - driver/chip/mt2523/inc/hal_pinmux_define.h (for mode comments)
  gpio_dump  - output of `AT+EGPIO=GPIO_GET` (as saved by at.py)
  overrides  - optional "pin:field=value" arguments, e.g. 15:OUTPUT_LEVEL=0

Pull encoding in the dump: "PULLEN PULLSEL *" for pull-type pins,
"PUPD R1 R0" for PUPD-type pins.
"""
import ast
import re
import sys


def load_dump(path):
    text = open(path).read()
    raw = text.split('\n', 1)[1].strip()
    if raw.startswith("b'") or raw.startswith('b"'):
        raw = ast.literal_eval(raw).decode()
    pins = {}
    for line in raw.splitlines():
        p = line.split()
        if len(p) == 6 and p[0].isdigit():
            pin, mode, d, pull, out, _ = p
            pins[int(pin)] = dict(mode=int(mode), dir=int(d), pull=pull, out=int(out))
    return pins


def load_pinmux(path):
    names = {}
    for m in re.finditer(r'#define\s+HAL_GPIO_(\d+)_(\w+)\s+(\d+)', open(path).read()):
        names[(int(m[1]), int(m[3]))] = m[2]
    return names


def main():
    template, pinmux, dump = sys.argv[1:4]
    overrides = {}
    for arg in sys.argv[4:]:
        pin, kv = arg.split(':', 1)
        field, value = kv.split('=', 1)
        overrides[(int(pin), field)] = value
    pins = load_dump(dump)
    names = load_pinmux(pinmux)

    def value_for(pin, field, old):
        if (pin, field) in overrides:
            return overrides[(pin, field)]
        cfg = pins.get(pin)
        if cfg is None:
            return old
        pull = cfg['pull']
        pull_type = pull.endswith('*')
        if field == 'MODE':
            return 'MODE_%d // %d:%s' % (cfg['mode'], cfg['mode'], names.get((pin, cfg['mode']), '?'))
        if field == 'DIR':
            return 'DIR_OUTPUT' if cfg['dir'] else 'DIR_INPUT'
        if field == 'OUTPUT_LEVEL':
            return str(cfg['out'] if cfg['dir'] else 0)
        if field == 'PULL':
            return 'PULL_ENABLE' if pull_type and pull[0] == '1' else '0'
        if field == 'PULL_SEL':
            return pull[1] if pull_type else '0'
        if field == 'PUPD':
            return pull[0] if not pull_type else '0'
        if field == 'R1':
            return pull[1] if not pull_type else '0'
        if field == 'R0':
            return pull[2] if not pull_type else '0'
        return old

    out = []
    rx = re.compile(r'^(#define\s+GPIO_PORT(\d+)_(MODE|DIR|OUTPUT_LEVEL|PULL_SEL|PULL|PUPD|R1|R0)\s+)(\S+.*)$')
    for line in open(template).read().splitlines():
        m = rx.match(line)
        if m:
            line = m[1] + value_for(int(m[2]), m[3], m[4])
        out.append(line)
    sys.stdout.write('\n'.join(out) + '\n')


if __name__ == '__main__':
    main()

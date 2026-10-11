#!/usr/bin/env python3
"""GNSS assistance for the Phicomm W3 (MT3333 receiver), sent over the
w3_display USB AT port. A cold receiver must download every satellite's orbit
(ephemeris) over the air, ~30-40 s each with an unbroken signal, so a first
fix takes minutes. This tool gives it a head start:

  1. time     : sets the watch RTC from this PC (AT+TIME) and sends $PMTK740
                (UTC). The firmware also sends $PMTK740 itself at GNSS start
                whenever its RTC is set.
  2. position : sends $PMTK741 with an approximate position: --lat/--lon, or
                the last fix this tool saw (saved in epo/last_fix.json).
  3. EPO      : MediaTek "Extended Prediction Orbit" file, predicted orbits for
                3 days. Only the 6-hour segment covering NOW is sent (as the
                SDK's epo_demo.c does): each 72-byte satellite record becomes
                one $PMTK721,<sat>,<18 words> command, and the receiver keeps
                one record per satellite, so sending a later segment would
                overwrite the current one. The receiver holds it in RAM: re-run
                after every power-up and every 6 hours. Each record is
                acknowledged with $PMTK001,721,3,<sat>,... ($PMTK707 still
                reports 0 "stored" sets; that counts flash-stored EPO only).

EPO file format (EPO_GR_3_1.DAT, GPS + GLONASS):
  12 segments of 6 hours; each segment = 32 GPS + 24 GLONASS records of 72 bytes
  (18 little-endian 32-bit words). Byte 3 of a record is the satellite ID
  (GPS 1..32, GLONASS 65..88). The low 24 bits of a segment's first word are
  its start time in hours since the GPS epoch (1980-01-06).

  python3 tools/w3_gnss_assist.py                  # time + position + current EPO segment
  python3 tools/w3_gnss_assist.py --lat 10.77 --lon 106.70 --no-epo
"""
import argparse
import datetime
import json
import os
import struct
import sys
import time
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cy8c_bootload import AtLink, TransportError   # noqa: E402
from w3_logcap import find_log_port                 # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EPO_DIR = os.path.join(ROOT, 'epo')
EPO_FILE = os.path.join(EPO_DIR, 'EPO_GR_3_1.DAT')
EPO_URL = 'http://wepodownload.mediatek.com/EPO_GR_3_1.DAT'
LAST_FIX = os.path.join(EPO_DIR, 'last_fix.json')
REC, SATS_PER_SEG = 72, 56
GPS_EPOCH = datetime.datetime(1980, 1, 6, tzinfo=datetime.timezone.utc)


def utcnow():
    return datetime.datetime.now(datetime.timezone.utc)


def epo_segments(data):
    """[(start_utc, [72-byte records])] for every 6-hour segment."""
    seg_len = REC * SATS_PER_SEG
    if len(data) == 0 or len(data) % seg_len:
        raise ValueError('EPO size %d is not a multiple of %d' % (len(data), seg_len))
    out = []
    for base in range(0, len(data), seg_len):
        hours = struct.unpack('<I', data[base:base + 4])[0] & 0x00FFFFFF
        start = GPS_EPOCH + datetime.timedelta(hours=hours)
        out.append((start, [data[base + i * REC:base + (i + 1) * REC] for i in range(SATS_PER_SEG)]))
    return out


def load_epo(force_download):
    """Use the cached EPO file unless it is missing or ends within 6 hours."""
    data = open(EPO_FILE, 'rb').read() if os.path.exists(EPO_FILE) else b''
    fresh = False
    if data and not force_download:
        segs = epo_segments(data)
        fresh = segs[-1][0] + datetime.timedelta(hours=6) > utcnow() + datetime.timedelta(hours=6)
    if not fresh:
        print('downloading', EPO_URL)
        os.makedirs(EPO_DIR, exist_ok=True)
        data = urllib.request.urlopen(EPO_URL, timeout=30).read()
        open(EPO_FILE, 'wb').write(data)
    return epo_segments(data)


def pmtk721(record):
    """One EPO satellite record -> PMTK721 body: satellite ID, then 18 words, hex."""
    words = struct.unpack('<18I', record)
    return 'PMTK721,%X,' % record[3] + ','.join('%X' % w for w in words)


def send(link, body, tries=5):
    for _ in range(tries):
        try:
            link.cmd('AT+GNSSCMD=' + body)
            return True
        except TransportError:
            time.sleep(0.2)                 # receiver UART busy or not ready yet
    return False


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--port', help='watch log/AT port (default: found by USB ID)')
    ap.add_argument('--lat', type=float)
    ap.add_argument('--lon', type=float)
    ap.add_argument('--alt', type=float, default=0.0)
    ap.add_argument('--no-epo', action='store_true')
    ap.add_argument('--download', action='store_true', help='fetch a fresh EPO file even if the cached one is valid')
    args = ap.parse_args()

    link = AtLink(args.port or find_log_port())
    now = utcnow()

    # 1. Time: watch RTC from this PC, then time aiding.
    link.cmd('AT+TIME=' + now.strftime('%Y-%m-%d,%H:%M:%S'))
    print('watch RTC set to', now.strftime('%Y-%m-%d %H:%M:%S UTC'))

    # Remember the watch's current fix, if it has one, for next time.
    fix = [l for l in link.cmd('AT+GNSSFIX?') if l.startswith('+GNSSFIX:')]
    if fix:
        valid, lat, lon, alt, sats = (int(x) for x in fix[0].split(':')[1].split(','))
        if valid:
            os.makedirs(EPO_DIR, exist_ok=True)
            json.dump({'lat': lat / 1e7, 'lon': lon / 1e7, 'alt': alt / 10, 'utc': now.isoformat()},
                      open(LAST_FIX, 'w'))
            print('watch has a fix (%d satellites): saved to %s' % (sats, LAST_FIX))

    now = utcnow()
    stamp = now.strftime('%Y,%m,%d,%H,%M,%S')
    send(link, 'PMTK740,' + stamp)

    # 2. Position aiding.
    lat, lon, alt = args.lat, args.lon, args.alt
    if lat is None and os.path.exists(LAST_FIX):
        last = json.load(open(LAST_FIX))
        lat, lon, alt = last['lat'], last['lon'], last['alt']
        print('using last fix from', last['utc'])
    if lat is not None and lon is not None:
        send(link, 'PMTK741,%.6f,%.6f,%.0f,%s' % (lat, lon, alt, stamp))
        print('position aiding: %.4f, %.4f' % (lat, lon))
    else:
        print('no position known yet (pass --lat/--lon, or run again after a fix)')

    # 3. EPO.
    if not args.no_epo:
        segs = load_epo(args.download)
        current = [i for i, (start, _) in enumerate(segs) if start <= now < start + datetime.timedelta(hours=6)]
        if not current:
            sys.exit('EPO file does not cover now (%s .. %s); try --download' %
                     (segs[0][0], segs[-1][0] + datetime.timedelta(hours=6)))
        chosen = [segs[current[0]]]
        total = len(chosen[0][1])
        print('EPO: sending the segment from %s (%d satellites), valid until %s UTC' % (
            chosen[0][0].strftime('%Y-%m-%d %H:%M'), total,
            (chosen[0][0] + datetime.timedelta(hours=6)).strftime('%H:%M')))
        sent = failed = 0
        for start, records in chosen:
            for rec in records:
                if send(link, pmtk721(rec)):
                    sent += 1
                else:
                    failed += 1
                sys.stdout.write('\r  %d/%d sent, %d failed' % (sent, total, failed))
                sys.stdout.flush()
        print()
        # The last record's acknowledgement: $PMTK001,721,3,<sat>,... (3 = OK)
        time.sleep(1.0)
        last = [l for l in link.cmd('AT+GNSSLAST?') if l.startswith('+GNSSLAST:')]
        print('receiver:', last[0] if last else '(no reply)')


if __name__ == '__main__':
    main()

# Read flash via AT+EREG=0,<addr> (returns low 16 bits). Pipelined, resumable.
import serial, sys, time, re, os
port, start, length, out = sys.argv[1], int(sys.argv[2],16), int(sys.argv[3],16), sys.argv[4]
win = int(sys.argv[5]) if len(sys.argv)>5 else 1
s = serial.Serial(port, 115200, timeout=2); s.reset_input_buffer()
data = bytearray(open(out,'rb').read()) if os.path.exists(out) else bytearray()
addr = start + len(data) - (len(data)%2); del data[len(data)-(len(data)%2):]
end = start + length
rx = re.compile(rb'\+EREG:0x([0-9a-f]+),0x([0-9a-f]+)\r\nOK\r\n')
buf=b''; pending=[]; t0=time.time(); n0=len(data); f=open(out,'ab'); f.truncate(len(data))
nxt=addr; got={}
while addr < end:
    while len(pending)<win and nxt<end:
        s.write(b'AT+EREG=0,%08X\r\n'%nxt); pending.append(nxt); nxt+=2
    d=s.read(max(1,s.in_waiting))
    if not d: raise SystemExit(f'timeout at {addr:08x}')
    buf+=d
    for m in rx.finditer(buf):
        a=int(m[1],16); v=int(m[2],16); got[a]=v
        if a in pending: pending.remove(a)
    buf=buf[buf.rfind(b'OK\r\n')+4:] if b'OK\r\n' in buf else buf
    while addr in got:
        f.write(got.pop(addr).to_bytes(2,'little')); addr+=2
    if (addr-start)%0x4000==0 and addr>start:
        f.flush(); r=(addr-start-n0)/(time.time()-t0+1e-9)
        print(f'{addr:08x} {r:.0f} B/s', flush=True)
f.close(); print('done', time.time()-t0)

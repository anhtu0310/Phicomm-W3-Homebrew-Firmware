import serial, sys, time
port=sys.argv[1]; cmds=sys.argv[2:]
s=serial.Serial(port,115200,timeout=0.3); s.dtr=True; s.rts=True
s.reset_input_buffer()
for c in cmds:
    s.write((c+'\r\n').encode()); time.sleep(0.1)
    out=b''; t=time.time()
    while time.time()-t<1.5:
        d=s.read(4096); out+=d
        if d: t=time.time()-1.0
    print(f'>>> {c!r}\n{out!r}\n')
s.close()

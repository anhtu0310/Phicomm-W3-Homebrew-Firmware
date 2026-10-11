01800: 0000     movs    r0, r0
01802: 0440     ands    r4, r0
01804: 0800     movs    r0, r1
01806: 0440     ands    r4, r0
01808: 1800     movs    r0, r3
0180A: 0440     ands    r4, r0
0180C: 0001     lsls    r0, r0, #4
0180E: 0440     ands    r4, r0
01810: 2009     lsrs    r0, r4, #4
01812: 1800     movs    r0, r3
01814: 0801     lsls    r0, r1, #4
01816: 0440     ands    r4, r0
01818: 1801     lsls    r0, r3, #4
0181A: 0440     ands    r4, r0
0181C: 0003     lsls    r0, r0, #0xc
0181E: 0140     ands    r1, r0
01820: 40ff0080 vhadd.u8 d24, d0, d0
01824: 0000     movs    r0, r0
01826: 0140     ands    r1, r0
01828: 0403     lsls    r4, r0, #0xc
0182A: 0140     ands    r1, r0
0182C: 41ff0080 vhadd.u8 d24, d1, d0
01830: 0803     lsls    r0, r1, #0xc
01832: 0140     ands    r1, r0
01834: 42ff0080 vhadd.u8 d24, d2, d0
01838: 2800     movs    r0, r5
0183A: 0340     ands    r3, r0
0183C: 0801     lsls    r0, r1, #4
0183E: 0140     ands    r1, r0
01840: 0401     lsls    r4, r0, #4
01842: 0140     ands    r1, r0
01844: 0001     lsls    r0, r0, #4
01846: 0140     ands    r1, r0
01848: 10b5     push    {r4, lr}
0184A: 064c     ldr     r4, [pc, #0x18]
0184C: 2378     ldrb    r3, [r4]
0184E: 002b     cmp     r3, #0
01850: 07d1     bne     #0x1862
01852: 054b     ldr     r3, [pc, #0x14]
01854: 002b     cmp     r3, #0
01856: 02d0     beq     #0x185e
01858: 0448     ldr     r0, [pc, #0x10]
0185A: 00e0     b       #0x185e
0185C: 00bf     nop     
0185E: 0123     movs    r3, #1
01860: 2370     strb    r3, [r4]
01862: 10bd     pop     {r4, pc}
01864: f800     lsls    r0, r7, #3
01866: 0020     movs    r0, #0
01868: 0000     movs    r0, r0
0186A: 0000     movs    r0, r0
0186C: fc3b     subs    r3, #0xfc
0186E: 0000     movs    r0, r0
01870: 084b     ldr     r3, [pc, #0x20]
01872: 10b5     push    {r4, lr}
01874: 002b     cmp     r3, #0
01876: 03d0     beq     #0x1880
01878: 0749     ldr     r1, [pc, #0x1c]
0187A: 0848     ldr     r0, [pc, #0x20]
0187C: 00e0     b       #0x1880
0187E: 00bf     nop     
01880: 0748     ldr     r0, [pc, #0x1c]
01882: 0368     ldr     r3, [r0]
01884: 002b     cmp     r3, #0
01886: 00d1     bne     #0x188a
01888: 10bd     pop     {r4, pc}
0188A: 064b     ldr     r3, [pc, #0x18]
0188C: 002b     cmp     r3, #0
0188E: fbd0     beq     #0x1888
01890: 9847     blx     r3
01892: f9e7     b       #0x1888
01894: 0000     movs    r0, r0
01896: 0000     movs    r0, r0
01898: fc00     lsls    r4, r7, #3
0189A: 0020     movs    r0, #0
0189C: fc3b     subs    r3, #0xfc
0189E: 0000     movs    r0, r0
018A0: 7000     lsls    r0, r6, #1
018A2: 0020     movs    r0, #0
018A4: 0000     movs    r0, r0
018A6: 0000     movs    r0, r0
018A8: 70b5     push    {r4, r5, r6, lr}
018AA: 01f0bffe bl      #0x362c
018AE: 01f0b7fe bl      #0x3620
018B2: 094d     ldr     r5, [pc, #0x24]
018B4: 2b68     ldr     r3, [r5]
018B6: c018     adds    r0, r0, r3
018B8: 01f0a8fe bl      #0x360c
018BC: 074c     ldr     r4, [pc, #0x1c]
018BE: 2378     ldrb    r3, [r4]
018C0: 012b     cmp     r3, #1
018C2: 06d1     bne     #0x18d2
018C4: 2868     ldr     r0, [r5]
018C6: 2821     movs    r1, #0x28
018C8: 01f0e4ff bl      #0x3894
018CC: 6568     ldr     r5, [r4, #4]
018CE: 4519     adds    r5, r0, r5
018D0: 6560     str     r5, [r4, #4]
018D2: 0123     movs    r3, #1
018D4: 2372     strb    r3, [r4, #8]
018D6: 70bd     pop     {r4, r5, r6, pc}
018D8: 7400     lsls    r4, r6, #1
018DA: 0020     movs    r0, #0
018DC: 1401     lsls    r4, r2, #4
018DE: 0020     movs    r0, #0
018E0: 0023     movs    r3, #0
018E2: 13b5     push    {r0, r1, r4, lr}
018E4: 084c     ldr     r4, [pc, #0x20]
018E6: 2821     movs    r1, #0x28
018E8: 2068     ldr     r0, [r4]
018EA: 0193     str     r3, [sp, #4]
018EC: 01f0d2ff bl      #0x3894
018F0: fa23     movs    r3, #0xfa
018F2: 9b00     lsls    r3, r3, #2
018F4: 5843     muls    r0, r3, r0
018F6: 01a9     add     r1, sp, #4
018F8: 01f00cfe bl      #0x3514
018FC: 0028     cmp     r0, #0
018FE: 01d1     bne     #0x1904
01900: 019b     ldr     r3, [sp, #4]
01902: 2360     str     r3, [r4]
01904: 13bd     pop     {r0, r1, r4, pc}
01906: c046     mov     r8, r8
01908: 7400     lsls    r4, r6, #1
0190A: 0020     movs    r0, #0
0190C: 10b5     push    {r4, lr}
0190E: 0949     ldr     r1, [pc, #0x24]
01910: 0420     movs    r0, #4
01912: 01f049fd bl      #0x33a8
01916: fff7e3ff bl      #0x18e0
0191A: 01f081fe bl      #0x3620
0191E: 064b     ldr     r3, [pc, #0x18]
01920: 1b68     ldr     r3, [r3]
01922: c018     adds    r0, r0, r3
01924: 01f072fe bl      #0x360c
01928: 01f090fe bl      #0x364c
0192C: 0420     movs    r0, #4
0192E: 01f05dfd bl      #0x33ec
01932: 10bd     pop     {r4, pc}
01934: a918     adds    r1, r5, r2
01936: 0000     movs    r0, r0
01938: 7400     lsls    r4, r6, #1
0193A: 0020     movs    r0, #0
0193C: 10b5     push    {r4, lr}
0193E: 01f0c5fe bl      #0x36cc
01942: 0a4c     ldr     r4, [pc, #0x28]
01944: e060     str     r0, [r4, #0xc]
01946: 01f0dbfa bl      #0x2f00
0194A: 8306     lsls    r3, r0, #0x1a
0194C: 09d4     bmi     #0x1962
0194E: 01f0cdfd bl      #0x34ec
01952: 01f06dfa bl      #0x2e30
01956: 01f097fd bl      #0x3488
0195A: 01f06dfa bl      #0x2e38
0195E: 01f0abfd bl      #0x34b8
01962: e068     ldr     r0, [r4, #0xc]
01964: c0b2     uxtb    r0, r0
01966: 01f0b5fe bl      #0x36d4
0196A: 10bd     pop     {r4, pc}
0196C: 1401     lsls    r4, r2, #4
0196E: 0020     movs    r0, #0
01970: 1923     movs    r3, #0x19
01972: f0b5     push    {r4, r5, r6, r7, lr}
01974: a34c     ldr     r4, [pc, #0x28c]
01976: ff25     movs    r5, #0xff
01978: e370     strb    r3, [r4, #3]
0197A: 6433     adds    r3, #0x64
0197C: ff33     adds    r3, #0xff
0197E: 6381     strh    r3, [r4, #0xa]
01980: fa23     movs    r3, #0xfa
01982: 9b00     lsls    r3, r3, #2
01984: 85b0     sub     sp, #0x14
01986: 2571     strb    r5, [r4, #4]
01988: a381     strh    r3, [r4, #0xc]
0198A: 62b6     cpsie   i
0198C: 01f024fa bl      #0x2dd8
01990: 0e21     movs    r1, #0xe
01992: 2200     movs    r2, r4
01994: 0800     movs    r0, r1
01996: 01f0c5fa bl      #0x2f24
0199A: 00f0c5f9 bl      #0x1d28
0199E: 0020     movs    r0, #0
019A0: 00f038fd bl      #0x2414
019A4: fff7b2ff bl      #0x190c
019A8: 0020     movs    r0, #0
019AA: 01f06dfe bl      #0x3688
019AE: 0020     movs    r0, #0
019B0: 01f076fe bl      #0x36a0
019B4: 0023     movs    r3, #0
019B6: 0395     str     r5, [sp, #0xc]
019B8: 0293     str     r3, [sp, #8]
019BA: 0193     str     r3, [sp, #4]
019BC: fe3d     subs    r5, #0xfe
019BE: 2e00     movs    r6, r5
019C0: 701e     subs    r0, r6, #1
019C2: 0328     cmp     r0, #3
019C4: fdd8     bhi     #0x19c2
019C6: 01f05bff bl      #0x3880
019CA: 021f     subs    r2, r0, #4
019CC: 30ad     add     r5, sp, #0xc0
019CE: 00f019fd bl      #0x2404
019D2: 071e     subs    r7, r0, #0
019D4: f4d1     bne     #0x19c0
019D6: 00f015fc bl      #0x2204
019DA: 0128     cmp     r0, #1
019DC: 09d1     bne     #0x19f2
019DE: 012d     cmp     r5, #1
019E0: 03d1     bne     #0x19ea
019E2: 3800     movs    r0, r7
019E4: 00f0dcff bl      #0x29a0
019E8: 05e0     b       #0x19f6
019EA: 3900     movs    r1, r7
019EC: 01f000f8 bl      #0x29f0
019F0: 05e0     b       #0x19fe
019F2: 012d     cmp     r5, #1
019F4: 03d1     bne     #0x19fe
019F6: 00f04fff bl      #0x2898
019FA: 0125     movs    r5, #1
019FC: 02e0     b       #0x1a04
019FE: 00f0f1fe bl      #0x27e4
01A02: 0025     movs    r5, #0
01A04: 0226     movs    r6, #2
01A06: dbe7     b       #0x19c0
01A08: 01f060fe bl      #0x36cc
01A0C: 7e4f     ldr     r7, [pc, #0x1f8]
01A0E: f860     str     r0, [r7, #0xc]
01A10: 00f0f8fc bl      #0x2404
01A14: 0028     cmp     r0, #0
01A16: 02d0     beq     #0x1a1e
01A18: 01f028fd bl      #0x346c
01A1C: 00e0     b       #0x1a20
01A1E: 0326     movs    r6, #3
01A20: f868     ldr     r0, [r7, #0xc]
01A22: c0b2     uxtb    r0, r0
01A24: 01f056fe bl      #0x36d4
01A28: cae7     b       #0x19c0
01A2A: 012d     cmp     r5, #1
01A2C: 67d1     bne     #0x1afe
01A2E: 3f21     movs    r1, #0x3f
01A30: 0020     movs    r0, #0
01A32: 00f0bbf9 bl      #0x1dac
01A36: 0020     movs    r0, #0
01A38: 00f0c4fb bl      #0x21c4
01A3C: 2070     strb    r0, [r4]
01A3E: 0600     movs    r6, r0
01A40: 0020     movs    r0, #0
01A42: 00f0b3fb bl      #0x21ac
01A46: ff23     movs    r3, #0xff
01A48: 0028     cmp     r0, #0
01A4A: 03d0     beq     #0x1a54
01A4C: 1e40     ands    r6, r3
01A4E: 9e42     cmp     r6, r3
01A50: 06d1     bne     #0x1a60
01A52: 01e0     b       #0x1a58
01A54: 2370     strb    r3, [r4]
01A56: 0293     str     r3, [sp, #8]
01A58: 0223     movs    r3, #2
01A5A: ff26     movs    r6, #0xff
01A5C: 6370     strb    r3, [r4, #1]
01A5E: 01e0     b       #0x1a64
01A60: 0323     movs    r3, #3
01A62: 6370     strb    r3, [r4, #1]
01A64: 6378     ldrb    r3, [r4, #1]
01A66: 012b     cmp     r3, #1
01A68: 0ed0     beq     #0x1a88
01A6A: 032b     cmp     r3, #3
01A6C: 0dd1     bne     #0x1a8a
01A6E: 029b     ldr     r3, [sp, #8]
01A70: 9e42     cmp     r6, r3
01A72: 02d9     bls     #0x1a7a
01A74: f31a     subs    r3, r6, r3
01A76: 0122     movs    r2, #1
01A78: 02e0     b       #0x1a80
01A7A: 0222     movs    r2, #2
01A7C: 029b     ldr     r3, [sp, #8]
01A7E: 9b1b     subs    r3, r3, r6
01A80: a270     strb    r2, [r4, #2]
01A82: 092b     cmp     r3, #9
01A84: 03d8     bhi     #0x1a8e
01A86: 00e0     b       #0x1a8a
01A88: 0296     str     r6, [sp, #8]
01A8A: 0023     movs    r3, #0
01A8C: a370     strb    r3, [r4, #2]
01A8E: 039b     ldr     r3, [sp, #0xc]
01A90: 9e42     cmp     r6, r3
01A92: 0bd0     beq     #0x1aac
01A94: 002e     cmp     r6, #0
01A96: 09d0     beq     #0x1aac
01A98: 0020     movs    r0, #0
01A9A: 01f0dffd bl      #0x365c
01A9E: 6420     movs    r0, #0x64
01AA0: 01f0dafc bl      #0x3458
01AA4: 0120     movs    r0, #1
01AA6: 01f0d9fd bl      #0x365c
01AAA: 0396     str     r6, [sp, #0xc]
01AAC: 574e     ldr     r6, [pc, #0x15c]
01AAE: 0020     movs    r0, #0
01AB0: 738f     ldrh    r3, [r6, #0x3a]
01AB2: e380     strh    r3, [r4, #6]
01AB4: b38f     ldrh    r3, [r6, #0x3c]
01AB6: 2381     strh    r3, [r4, #8]
01AB8: 00f078fb bl      #0x21ac
01ABC: 071e     subs    r7, r0, #0
01ABE: 0cd0     beq     #0x1ada
01AC0: 0022     movs    r2, #0
01AC2: 337d     ldrb    r3, [r6, #0x14]
01AC4: 002b     cmp     r3, #0
01AC6: 04d0     beq     #0x1ad2
01AC8: 591e     subs    r1, r3, #1
01ACA: 0132     adds    r2, #1
01ACC: 0b40     ands    r3, r1
01ACE: d2b2     uxtb    r2, r2
01AD0: f8e7     b       #0x1ac4
01AD2: 6271     strb    r2, [r4, #5]
01AD4: 0193     str     r3, [sp, #4]
01AD6: 0426     movs    r6, #4
01AD8: 72e7     b       #0x19c0
01ADA: 019b     ldr     r3, [sp, #4]
01ADC: 0426     movs    r6, #4
01ADE: 0133     adds    r3, #1
01AE0: 9bb2     uxth    r3, r3
01AE2: 0193     str     r3, [sp, #4]
01AE4: f92b     cmp     r3, #0xf9
01AE6: 00d8     bhi     #0x1aea
01AE8: 6ae7     b       #0x19c0
01AEA: 9622     movs    r2, #0x96
01AEC: 484b     ldr     r3, [pc, #0x120]
01AEE: 1201     lsls    r2, r2, #4
01AF0: 0100     movs    r1, r0
01AF2: 0120     movs    r0, #1
01AF4: 1a60     str     r2, [r3]
01AF6: 3d00     movs    r5, r7
01AF8: 00f07aff bl      #0x29f0
01AFC: 60e7     b       #0x19c0
01AFE: 0120     movs    r0, #1
01B00: 00f036f9 bl      #0x1d70
01B04: 0120     movs    r0, #1
01B06: 00f051fb bl      #0x21ac
01B0A: 0028     cmp     r0, #0
01B0C: 01d1     bne     #0x1b12
01B0E: 0500     movs    r5, r0
01B10: e1e7     b       #0x1ad6
01B12: c822     movs    r2, #0xc8
01B14: 3e4b     ldr     r3, [pc, #0xf8]
01B16: 9200     lsls    r2, r2, #2
01B18: 0020     movs    r0, #0
01B1A: 1a60     str     r2, [r3]
01B1C: 0125     movs    r5, #1
01B1E: 00f079fc bl      #0x2414
01B22: 4ce7     b       #0x19be
01B24: 384f     ldr     r7, [pc, #0xe0]
01B26: 3b78     ldrb    r3, [r7]
01B28: 002b     cmp     r3, #0
01B2A: 09d0     beq     #0x1b40
01B2C: 7a68     ldr     r2, [r7, #4]
01B2E: 394b     ldr     r3, [pc, #0xe4]
01B30: 9a42     cmp     r2, r3
01B32: 05d9     bls     #0x1b40
01B34: 0120     movs    r0, #1
01B36: 01f0a7fd bl      #0x3688
01B3A: 0120     movs    r0, #1
01B3C: 01f0b0fd bl      #0x36a0
01B40: fff7fcfe bl      #0x193c
01B44: 2379     ldrb    r3, [r4, #4]
01B46: 612b     cmp     r3, #0x61
01B48: 41d0     beq     #0x1bce
01B4A: 12d8     bhi     #0x1b72
01B4C: 432b     cmp     r3, #0x43
01B4E: 43d0     beq     #0x1bd8
01B50: 05d8     bhi     #0x1b5e
01B52: 412b     cmp     r3, #0x41
01B54: 4cd1     bne     #0x1bf0
01B56: 01f05dfc bl      #0x3414
01B5A: 4223     movs    r3, #0x42
01B5C: 47e0     b       #0x1bee
01B5E: 452b     cmp     r3, #0x45
01B60: 40d0     beq     #0x1be4
01B62: 592b     cmp     r3, #0x59
01B64: 44d1     bne     #0x1bf0
01B66: 0123     movs    r3, #1
01B68: 3b70     strb    r3, [r7]
01B6A: 0023     movs    r3, #0
01B6C: 7b60     str     r3, [r7, #4]
01B6E: 6033     adds    r3, #0x60
01B70: 3de0     b       #0x1bee
01B72: 672b     cmp     r3, #0x67
01B74: 16d0     beq     #0x1ba4
01B76: 07d8     bhi     #0x1b88
01B78: 652b     cmp     r3, #0x65
01B7A: 39d1     bne     #0x1bf0
01B7C: 01f05efd bl      #0x363c
01B80: 01f03cfd bl      #0x35fc
01B84: 6623     movs    r3, #0x66
01B86: 32e0     b       #0x1bee
01B88: 692b     cmp     r3, #0x69
01B8A: 19d0     beq     #0x1bc0
01B8C: a52b     cmp     r3, #0xa5
01B8E: 2fd1     bne     #0x1bf0
01B90: 0020     movs    r0, #0
01B92: 01f079fd bl      #0x3688
01B96: 0020     movs    r0, #0
01B98: 01f082fd bl      #0x36a0
01B9C: 01f06afd bl      #0x3674
01BA0: a623     movs    r3, #0xa6
01BA2: 24e0     b       #0x1bee
01BA4: c822     movs    r2, #0xc8
01BA6: 1a4b     ldr     r3, [pc, #0x68]
01BA8: 9200     lsls    r2, r2, #2
01BAA: 0020     movs    r0, #0
01BAC: 1a60     str     r2, [r3]
01BAE: 00f031fc bl      #0x2414
01BB2: 6823     movs    r3, #0x68
01BB4: 0125     movs    r5, #1
01BB6: 2371     strb    r3, [r4, #4]
01BB8: 0023     movs    r3, #0
01BBA: 2e00     movs    r6, r5
01BBC: 0193     str     r3, [sp, #4]
01BBE: 17e0     b       #0x1bf0
01BC0: 6420     movs    r0, #0x64
01BC2: 01f033fc bl      #0x342c
01BC6: 00f0adfb bl      #0x2324
01BCA: 7023     movs    r3, #0x70
01BCC: 0fe0     b       #0x1bee
01BCE: 0023     movs    r3, #0
01BD0: 3b70     strb    r3, [r7]
01BD2: 7b60     str     r3, [r7, #4]
01BD4: 6233     adds    r3, #0x62
01BD6: 0ae0     b       #0x1bee
01BD8: a189     ldrh    r1, [r4, #0xc]
01BDA: 0f48     ldr     r0, [pc, #0x3c]
01BDC: 00f0c2fa bl      #0x2164
01BE0: 4423     movs    r3, #0x44
01BE2: 04e0     b       #0x1bee
01BE4: 6189     ldrh    r1, [r4, #0xa]
01BE6: 0c48     ldr     r0, [pc, #0x30]
01BE8: 00f0bcfa bl      #0x2164
01BEC: 4623     movs    r3, #0x46
01BEE: 2371     strb    r3, [r4, #4]
01BF0: 3b7a     ldrb    r3, [r7, #8]
01BF2: 002b     cmp     r3, #0
01BF4: 00d1     bne     #0x1bf8
01BF6: e3e6     b       #0x19c0
01BF8: 0023     movs    r3, #0
01BFA: 0126     movs    r6, #1
01BFC: 3b72     strb    r3, [r7, #8]
01BFE: fff76ffe bl      #0x18e0
01C02: dde6     b       #0x19c0
01C04: 6401     lsls    r4, r4, #5
01C06: 0020     movs    r0, #0
01C08: 1401     lsls    r4, r2, #4
01C0A: 0020     movs    r0, #0
01C0C: 7401     lsls    r4, r6, #5
01C0E: 0020     movs    r0, #0
01C10: 7400     lsls    r4, r6, #1
01C12: 0020     movs    r0, #0
01C14: 204e     ldr     r6, [pc, #0x80]
01C16: 0000     movs    r0, r0
01C18: 1c00     movs    r4, r3
01C1A: 80a7     adr     r7, #0x200
01C1C: 0b4a     ldr     r2, [pc, #0x2c]
01C1E: 10b5     push    {r4, lr}
01C20: 1368     ldr     r3, [r2]
01C22: 0028     cmp     r0, #0
01C24: 03d0     beq     #0x1c2e
01C26: 8021     movs    r1, #0x80
01C28: 0906     lsls    r1, r1, #0x18
01C2A: 0b43     orrs    r3, r1
01C2C: 01e0     b       #0x1c32
01C2E: 5b00     lsls    r3, r3, #1
01C30: 5b08     lsrs    r3, r3, #1
01C32: 1360     str     r3, [r2]
01C34: 064b     ldr     r3, [pc, #0x18]
01C36: 2024     movs    r4, #0x20
01C38: 1968     ldr     r1, [r3]
01C3A: 0a00     movs    r2, r1
01C3C: a243     bics    r2, r4
01C3E: 0028     cmp     r0, #0
01C40: 01d0     beq     #0x1c46
01C42: 2200     movs    r2, r4
01C44: 0a43     orrs    r2, r1
01C46: 1a60     str     r2, [r3]
01C48: 10bd     pop     {r4, pc}
01C4A: c046     mov     r8, r8
01C4C: 0020     movs    r0, #0
01C4E: 0240     ands    r2, r0
01C50: 2800     movs    r0, r5
01C52: 0340     ands    r3, r0
01C54: 10b5     push    {r4, lr}
01C56: 01f093ff bl      #0x3b80
01C5A: 0368     ldr     r3, [r0]
01C5C: 0c2b     cmp     r3, #0xc
01C5E: 00d1     bne     #0x1c62
01C60: fee7     b       #0x1c60
01C62: fee7     b       #0x1c62
01C64: f8b5     push    {r3, r4, r5, r6, r7, lr}
01C66: 0025     movs    r5, #0
01C68: 0f49     ldr     r1, [pc, #0x3c]
01C6A: 104b     ldr     r3, [pc, #0x40]
01C6C: 0139     subs    r1, #1
01C6E: 4a1c     adds    r2, r1, #1
01C70: 14d0     beq     #0x1c9c
01C72: 0022     movs    r2, #0
01C74: 1f68     ldr     r7, [r3]
01C76: 5c68     ldr     r4, [r3, #4]
01C78: 9e68     ldr     r6, [r3, #8]
01C7A: a018     adds    r0, r4, r2
01C7C: b242     cmp     r2, r6
01C7E: 03d0     beq     #0x1c88
01C80: b858     ldr     r0, [r7, r2]
01C82: a050     str     r0, [r4, r2]
01C84: 0432     adds    r2, #4
01C86: f8e7     b       #0x1c7a
01C88: 0200     movs    r2, r0
01C8A: de68     ldr     r6, [r3, #0xc]
01C8C: 141a     subs    r4, r2, r0
01C8E: a642     cmp     r6, r4
01C90: 01d0     beq     #0x1c96
01C92: 20c2     stm     r2!, {r5}
01C94: fae7     b       #0x1c8c
01C96: 1033     adds    r3, #0x10
01C98: 0139     subs    r1, #1
01C9A: e8e7     b       #0x1c6e
01C9C: 01f076ff bl      #0x3b8c
01CA0: fff766fe bl      #0x1970
01CA4: fee7     b       #0x1ca4
01CA6: c046     mov     r8, r8
01CA8: 0100     movs    r1, r0
01CAA: 0000     movs    r0, r0
01CAC: 3c3d     subs    r5, #0x3c
01CAE: 0000     movs    r0, r0
01CB0: 0121     movs    r1, #1
01CB2: 0f4a     ldr     r2, [pc, #0x3c]
01CB4: 70b5     push    {r4, r5, r6, lr}
01CB6: 1368     ldr     r3, [r2]
01CB8: 1400     movs    r4, r2
01CBA: 8b43     bics    r3, r1
01CBC: 1360     str     r3, [r2]
01CBE: 0023     movs    r3, #0
01CC0: 0c4d     ldr     r5, [pc, #0x30]
01CC2: 0d4e     ldr     r6, [pc, #0x34]
01CC4: 0d48     ldr     r0, [pc, #0x34]
01CC6: 9a00     lsls    r2, r3, #2
01CC8: 2900     movs    r1, r5
01CCA: 032b     cmp     r3, #3
01CCC: 00d8     bhi     #0x1cd0
01CCE: b158     ldr     r1, [r6, r2]
01CD0: 0133     adds    r3, #1
01CD2: 8150     str     r1, [r0, r2]
01CD4: 192b     cmp     r3, #0x19
01CD6: f6d1     bne     #0x1cc6
01CD8: fff744fd bl      #0x1764
01CDC: 084b     ldr     r3, [pc, #0x20]
01CDE: 1a68     ldr     r2, [r3]
01CE0: 002a     cmp     r2, #0
01CE2: 00d1     bne     #0x1ce6
01CE4: 1a60     str     r2, [r3]
01CE6: 0122     movs    r2, #1
01CE8: 2368     ldr     r3, [r4]
01CEA: 1343     orrs    r3, r2
01CEC: 2360     str     r3, [r4]
01CEE: 70bd     pop     {r4, r5, r6, pc}
01CF0: 0000     movs    r0, r0
01CF2: 1040     ands    r0, r2
01CF4: 551c     adds    r5, r2, #1
01CF6: 0000     movs    r0, r0
01CF8: 4017     asrs    r0, r0, #0x1d
01CFA: 0000     movs    r0, r0
01CFC: 0000     movs    r0, r0
01CFE: 0020     movs    r0, #0
01D00: 6800     lsls    r0, r5, #1
01D02: 0020     movs    r0, #0
01D04: 10b5     push    {r4, lr}
01D06: 074c     ldr     r4, [pc, #0x1c]
01D08: 2378     ldrb    r3, [r4]
01D0A: 002b     cmp     r3, #0
01D0C: 05d1     bne     #0x1d1a
01D0E: 00f0fff9 bl      #0x2110
01D12: 00f06dfa bl      #0x21f0
01D16: 0123     movs    r3, #1
01D18: 2370     strb    r3, [r4]
01D1A: 00f073f8 bl      #0x1e04
01D1E: 00f083fc bl      #0x2628
01D22: 10bd     pop     {r4, pc}
01D24: 2401     lsls    r4, r4, #4
01D26: 0020     movs    r0, #0
01D28: 70b5     push    {r4, r5, r6, lr}
01D2A: fff7ebff bl      #0x1d04
01D2E: 041e     subs    r4, r0, #0
01D30: 17d1     bne     #0x1d62
01D32: 00f016fc bl      #0x2562
01D36: 041e     subs    r4, r0, #0
01D38: 13d1     bne     #0x1d62
01D3A: 00f093fb bl      #0x2464
01D3E: 041e     subs    r4, r0, #0
01D40: 0fd1     bne     #0x1d62
01D42: 01f0c3fc bl      #0x36cc
01D46: 0500     movs    r5, r0
01D48: 00f05cfb bl      #0x2404
01D4C: 0028     cmp     r0, #0
01D4E: 05d0     beq     #0x1d5c
01D50: 01f08cfb bl      #0x346c
01D54: 2800     movs    r0, r5
01D56: 01f0bdfc bl      #0x36d4
01D5A: f2e7     b       #0x1d42
01D5C: 2800     movs    r0, r5
01D5E: 01f0b9fc bl      #0x36d4
01D62: 00f015fb bl      #0x2390
01D66: 00f0ddfa bl      #0x2324
01D6A: 2000     movs    r0, r4
01D6C: 70bd     pop     {r4, r5, r6, pc}
01D6E: 0000     movs    r0, r0
01D70: 70b5     push    {r4, r5, r6, lr}
01D72: 0126     movs    r6, #1
01D74: 0400     movs    r4, r0
01D76: b042     cmp     r0, r6
01D78: 11d8     bhi     #0x1d9e
01D7A: 0a4b     ldr     r3, [pc, #0x28]
01D7C: 1036     adds    r6, #0x10
01D7E: db68     ldr     r3, [r3, #0xc]
01D80: c340     lsrs    r3, r0
01D82: db07     lsls    r3, r3, #0x1f
01D84: 0bd5     bpl     #0x1d9e
01D86: 2425     movs    r5, #0x24
01D88: 4543     muls    r5, r0, r5
01D8A: 074b     ldr     r3, [pc, #0x1c]
01D8C: ed18     adds    r5, r5, r3
01D8E: 2800     movs    r0, r5
01D90: 00f077f8 bl      #0x1e82
01D94: 2900     movs    r1, r5
01D96: 0600     movs    r6, r0
01D98: 2000     movs    r0, r4
01D9A: 00f065f9 bl      #0x2068
01D9E: 3000     movs    r0, r6
01DA0: 70bd     pop     {r4, r5, r6, pc}
01DA2: c046     mov     r8, r8
01DA4: 7401     lsls    r4, r6, #5
01DA6: 0020     movs    r0, #0
01DA8: 203c     subs    r4, #0x20
01DAA: 0000     movs    r0, r0
01DAC: 0123     movs    r3, #1
01DAE: f0b5     push    {r4, r5, r6, r7, lr}
01DB0: 85b0     sub     sp, #0x14
01DB2: 0090     str     r0, [sp]
01DB4: 0291     str     r1, [sp, #8]
01DB6: 0193     str     r3, [sp, #4]
01DB8: 0128     cmp     r0, #1
01DBA: 1ed8     bhi     #0x1dfa
01DBC: 2424     movs    r4, #0x24
01DBE: 4443     muls    r4, r0, r4
01DC0: 0f4b     ldr     r3, [pc, #0x3c]
01DC2: e418     adds    r4, r4, r3
01DC4: 237e     ldrb    r3, [r4, #0x18]
01DC6: a668     ldr     r6, [r4, #8]
01DC8: e768     ldr     r7, [r4, #0xc]
01DCA: e58a     ldrh    r5, [r4, #0x16]
01DCC: 0393     str     r3, [sp, #0xc]
01DCE: 029b     ldr     r3, [sp, #8]
01DD0: 002d     cmp     r5, #0
01DD2: 0cd0     beq     #0x1dee
01DD4: 3100     movs    r1, r6
01DD6: 3a00     movs    r2, r7
01DD8: 2000     movs    r0, r4
01DDA: 00f07ef8 bl      #0x1eda
01DDE: 039b     ldr     r3, [sp, #0xc]
01DE0: 0190     str     r0, [sp, #4]
01DE2: 0e36     adds    r6, #0xe
01DE4: 062b     cmp     r3, #6
01DE6: 00d0     beq     #0x1dea
01DE8: 0237     adds    r7, #2
01DEA: 013d     subs    r5, #1
01DEC: efe7     b       #0x1dce
01DEE: 9b06     lsls    r3, r3, #0x1a
01DF0: 03d5     bpl     #0x1dfa
01DF2: 2100     movs    r1, r4
01DF4: 0098     ldr     r0, [sp]
01DF6: 00f037f9 bl      #0x2068
01DFA: 0198     ldr     r0, [sp, #4]
01DFC: 05b0     add     sp, #0x14
01DFE: f0bd     pop     {r4, r5, r6, r7, pc}
01E00: 203c     subs    r4, #0x20
01E02: 0000     movs    r0, r0
01E04: f8b5     push    {r3, r4, r5, r6, r7, lr}
01E06: 0126     movs    r6, #1
01E08: 0022     movs    r2, #0
01E0A: 144b     ldr     r3, [pc, #0x50]
01E0C: 7642     rsbs    r6, r6, #0
01E0E: 144c     ldr     r4, [pc, #0x50]
01E10: 144d     ldr     r5, [pc, #0x50]
01E12: 154f     ldr     r7, [pc, #0x54]
01E14: 1a61     str     r2, [r3, #0x10]
01E16: de60     str     r6, [r3, #0xc]
01E18: af42     cmp     r7, r5
01E1A: 1dd0     beq     #0x1e58
01E1C: 0022     movs    r2, #0
01E1E: 237d     ldrb    r3, [r4, #0x14]
01E20: 2168     ldr     r1, [r4]
01E22: 2a70     strb    r2, [r5]
01E24: 022b     cmp     r3, #2
01E26: 14d3     blo     #0x1e52
01E28: 032b     cmp     r3, #3
01E2A: 02d9     bls     #0x1e32
01E2C: 062b     cmp     r3, #6
01E2E: 08d0     beq     #0x1e42
01E30: 0fe0     b       #0x1e52
01E32: e368     ldr     r3, [r4, #0xc]
01E34: 002b     cmp     r3, #0
01E36: 01d0     beq     #0x1e3c
01E38: ca79     ldrb    r2, [r1, #7]
01E3A: 1a70     strb    r2, [r3]
01E3C: 2368     ldr     r3, [r4]
01E3E: de81     strh    r6, [r3, #0xe]
01E40: 07e0     b       #0x1e52
01E42: e068     ldr     r0, [r4, #0xc]
01E44: 0028     cmp     r0, #0
01E46: 04d0     beq     #0x1e52
01E48: 628a     ldrh    r2, [r4, #0x12]
01E4A: c979     ldrb    r1, [r1, #7]
01E4C: 5200     lsls    r2, r2, #1
01E4E: 01f0ccfe bl      #0x3bea
01E52: 2434     adds    r4, #0x24
01E54: 013d     subs    r5, #1
01E56: dfe7     b       #0x1e18
01E58: f8bd     pop     {r3, r4, r5, r6, r7, pc}
01E5A: c046     mov     r8, r8
01E5C: 7401     lsls    r4, r6, #5
01E5E: 0020     movs    r0, #0
01E60: 243c     subs    r4, #0x24
01E62: 0000     movs    r0, r0
01E64: 8901     lsls    r1, r1, #6
01E66: 0020     movs    r0, #0
01E68: 8701     lsls    r7, r0, #6
01E6A: 0020     movs    r0, #0
01E6C: 10b5     push    {r4, lr}
01E6E: 0024     movs    r4, #0
01E70: 4a88     ldrh    r2, [r1, #2]
01E72: 0b88     ldrh    r3, [r1]
01E74: cc80     strh    r4, [r1, #6]
01E76: 9b1a     subs    r3, r3, r2
01E78: 0279     ldrb    r2, [r0, #4]
01E7A: 9342     cmp     r3, r2
01E7C: 00dd     ble     #0x1e80
01E7E: cb80     strh    r3, [r1, #6]
01E80: 10bd     pop     {r4, pc}
01E82: f0b5     push    {r4, r5, r6, r7, lr}
01E84: 0024     movs    r4, #0
01E86: 0500     movs    r5, r0
01E88: c368     ldr     r3, [r0, #0xc]
01E8A: 85b0     sub     sp, #0x14
01E8C: 077e     ldrb    r7, [r0, #0x18]
01E8E: 0093     str     r3, [sp]
01E90: 8368     ldr     r3, [r0, #8]
01E92: 0194     str     r4, [sp, #4]
01E94: 0393     str     r3, [sp, #0xc]
01E96: 4368     ldr     r3, [r0, #4]
01E98: 0293     str     r3, [sp, #8]
01E9A: 0e26     movs    r6, #0xe
01E9C: 6643     muls    r6, r4, r6
01E9E: 039b     ldr     r3, [sp, #0xc]
01EA0: 9e19     adds    r6, r3, r6
01EA2: eb8a     ldrh    r3, [r5, #0x16]
01EA4: 9c42     cmp     r4, r3
01EA6: 15d2     bhs     #0x1ed4
01EA8: 3a00     movs    r2, r7
01EAA: 3100     movs    r1, r6
01EAC: 0098     ldr     r0, [sp]
01EAE: 00f09bfa bl      #0x23e8
01EB2: 3100     movs    r1, r6
01EB4: 3a00     movs    r2, r7
01EB6: 0298     ldr     r0, [sp, #8]
01EB8: 00f03cfa bl      #0x2334
01EBC: 3100     movs    r1, r6
01EBE: 0190     str     r0, [sp, #4]
01EC0: 0298     ldr     r0, [sp, #8]
01EC2: fff7d3ff bl      #0x1e6c
01EC6: 062f     cmp     r7, #6
01EC8: 02d0     beq     #0x1ed0
01ECA: 009b     ldr     r3, [sp]
01ECC: 0233     adds    r3, #2
01ECE: 0093     str     r3, [sp]
01ED0: 0134     adds    r4, #1
01ED2: e2e7     b       #0x1e9a
01ED4: 0198     ldr     r0, [sp, #4]
01ED6: 05b0     add     sp, #0x14
01ED8: f0bd     pop     {r4, r5, r6, r7, pc}
01EDA: f7b5     push    {r0, r1, r2, r4, r5, r6, r7, lr}
01EDC: 1e00     movs    r6, r3
01EDE: 4368     ldr     r3, [r0, #4]
01EE0: 077e     ldrb    r7, [r0, #0x18]
01EE2: 0c00     movs    r4, r1
01EE4: 1500     movs    r5, r2
01EE6: 0193     str     r3, [sp, #4]
01EE8: f307     lsls    r3, r6, #0x1f
01EEA: 03d5     bpl     #0x1ef4
01EEC: 3a00     movs    r2, r7
01EEE: 2800     movs    r0, r5
01EF0: 00f07afa bl      #0x23e8
01EF4: 0025     movs    r5, #0
01EF6: b307     lsls    r3, r6, #0x1e
01EF8: 05d5     bpl     #0x1f06
01EFA: 3a00     movs    r2, r7
01EFC: 2100     movs    r1, r4
01EFE: 0198     ldr     r0, [sp, #4]
01F00: 00f018fa bl      #0x2334
01F04: 0500     movs    r5, r0
01F06: 7307     lsls    r3, r6, #0x1d
01F08: 03d5     bpl     #0x1f12
01F0A: 2100     movs    r1, r4
01F0C: 0198     ldr     r0, [sp, #4]
01F0E: fff7adff bl      #0x1e6c
01F12: 2800     movs    r0, r5
01F14: febd     pop     {r1, r2, r3, r4, r5, r6, r7, pc}
01F16: 0000     movs    r0, r0
01F18: f7b5     push    {r0, r1, r2, r4, r5, r6, r7, lr}
01F1A: cb8a     ldrh    r3, [r1, #0x16]
01F1C: 0a69     ldr     r2, [r1, #0x10]
01F1E: 5b00     lsls    r3, r3, #1
01F20: d318     adds    r3, r2, r3
01F22: 0193     str     r3, [sp, #4]
01F24: 0123     movs    r3, #1
01F26: 8f68     ldr     r7, [r1, #8]
01F28: 4d68     ldr     r5, [r1, #4]
01F2A: 0199     ldr     r1, [sp, #4]
01F2C: 8a42     cmp     r2, r1
01F2E: 29d0     beq     #0x1f84
01F30: f988     ldrh    r1, [r7, #6]
01F32: 154c     ldr     r4, [pc, #0x54]
01F34: 8c46     mov     ip, r1
01F36: 6988     ldrh    r1, [r5, #2]
01F38: 2342     tst     r3, r4
01F3A: 01d1     bne     #0x1f40
01F3C: e989     ldrh    r1, [r5, #0xe]
01F3E: 0e37     adds    r7, #0xe
01F40: 1c00     movs    r4, r3
01F42: ae79     ldrb    r6, [r5, #6]
01F44: 0440     ands    r4, r0
01F46: 03d1     bne     #0x1f50
01F48: 7118     adds    r1, r6, r1
01F4A: 8c45     cmp     ip, r1
01F4C: 03d8     bhi     #0x1f56
01F4E: 17e0     b       #0x1f80
01F50: 891b     subs    r1, r1, r6
01F52: 8c45     cmp     ip, r1
01F54: 03d9     bls     #0x1f5e
01F56: a342     cmp     r3, r4
01F58: 08d0     beq     #0x1f6c
01F5A: 1c00     movs    r4, r3
01F5C: 00e0     b       #0x1f60
01F5E: 0024     movs    r4, #0
01F60: 1178     ldrb    r1, [r2]
01F62: 0139     subs    r1, #1
01F64: c9b2     uxtb    r1, r1
01F66: 1170     strb    r1, [r2]
01F68: 0029     cmp     r1, #0
01F6A: 06d1     bne     #0x1f7a
01F6C: 9843     bics    r0, r3
01F6E: 2043     orrs    r0, r4
01F70: 0121     movs    r1, #1
01F72: 002c     cmp     r4, #0
01F74: 00d1     bne     #0x1f78
01F76: e979     ldrb    r1, [r5, #7]
01F78: 1170     strb    r1, [r2]
01F7A: 0132     adds    r2, #1
01F7C: 5b00     lsls    r3, r3, #1
01F7E: d4e7     b       #0x1f2a
01F80: 9843     bics    r0, r3
01F82: f8e7     b       #0x1f76
01F84: febd     pop     {r1, r2, r3, r4, r5, r6, r7, pc}
01F86: c046     mov     r8, r8
01F88: 5555     strb    r5, [r2, r5]
01F8A: 5555     strb    r5, [r2, r5]
01F8C: f0b5     push    {r4, r5, r6, r7, lr}
01F8E: 0d00     movs    r5, r1
01F90: cb8a     ldrh    r3, [r1, #0x16]
01F92: 6f68     ldr     r7, [r5, #4]
01F94: 85b0     sub     sp, #0x14
01F96: 0193     str     r3, [sp, #4]
01F98: 7c88     ldrh    r4, [r7, #2]
01F9A: ba79     ldrb    r2, [r7, #6]
01F9C: 8968     ldr     r1, [r1, #8]
01F9E: a61a     subs    r6, r4, r2
01FA0: 2b69     ldr     r3, [r5, #0x10]
01FA2: b446     mov     ip, r6
01FA4: 0028     cmp     r0, #0
01FA6: 01d1     bne     #0x1fac
01FA8: a218     adds    r2, r4, r2
01FAA: 9446     mov     ip, r2
01FAC: 0024     movs    r4, #0
01FAE: 0122     movs    r2, #1
01FB0: 0092     str     r2, [sp]
01FB2: 019a     ldr     r2, [sp, #4]
01FB4: 561e     subs    r6, r2, #1
01FB6: 0196     str     r6, [sp, #4]
01FB8: 0ad3     blo     #0x1fd0
01FBA: ce88     ldrh    r6, [r1, #6]
01FBC: 3200     movs    r2, r6
01FBE: 0026     movs    r6, #0
01FC0: 9445     cmp     ip, r2
01FC2: 00d2     bhs     #0x1fc6
01FC4: 009e     ldr     r6, [sp]
01FC6: 009a     ldr     r2, [sp]
01FC8: 3443     orrs    r4, r6
01FCA: 0e31     adds    r1, #0xe
01FCC: 5200     lsls    r2, r2, #1
01FCE: efe7     b       #0x1fb0
01FD0: 002c     cmp     r4, #0
01FD2: 08d0     beq     #0x1fe6
01FD4: 1a78     ldrb    r2, [r3]
01FD6: 002a     cmp     r2, #0
01FD8: 01d0     beq     #0x1fde
01FDA: 013a     subs    r2, #1
01FDC: 1a70     strb    r2, [r3]
01FDE: 1b78     ldrb    r3, [r3]
01FE0: 002b     cmp     r3, #0
01FE2: 06d0     beq     #0x1ff2
01FE4: 02e0     b       #0x1fec
01FE6: fa79     ldrb    r2, [r7, #7]
01FE8: 1a70     strb    r2, [r3]
01FEA: 33e0     b       #0x2054
01FEC: 0028     cmp     r0, #0
01FEE: 32d0     beq     #0x2056
01FF0: 0400     movs    r4, r0
01FF2: ee8a     ldrh    r6, [r5, #0x16]
01FF4: 7b88     ldrh    r3, [r7, #2]
01FF6: ba79     ldrb    r2, [r7, #6]
01FF8: 3100     movs    r1, r6
01FFA: 9a1a     subs    r2, r3, r2
01FFC: a868     ldr     r0, [r5, #8]
01FFE: 00f05bfe bl      #0x2cb8
02002: 0028     cmp     r0, #0
02004: 26d0     beq     #0x2054
02006: 2b7e     ldrb    r3, [r5, #0x18]
02008: 022b     cmp     r3, #2
0200A: 28d1     bne     #0x205e
0200C: 3200     movs    r2, r6
0200E: e969     ldr     r1, [r5, #0x1c]
02010: 03a8     add     r0, sp, #0xc
02012: 00f09ffe bl      #0x2d54
02016: 3e00     movs    r6, r7
02018: ab8a     ldrh    r3, [r5, #0x14]
0201A: 0025     movs    r5, #0
0201C: 0090     str     r0, [sp]
0201E: 0193     str     r3, [sp, #4]
02020: 0e36     adds    r6, #0xe
02022: 009b     ldr     r3, [sp]
02024: ab42     cmp     r3, r5
02026: 03d1     bne     #0x2030
02028: 009b     ldr     r3, [sp]
0202A: 002b     cmp     r3, #0
0202C: 14d0     beq     #0x2058
0202E: 16e0     b       #0x205e
02030: 6b00     lsls    r3, r5, #1
02032: 03aa     add     r2, sp, #0xc
02034: 985a     ldrh    r0, [r3, r2]
02036: 3188     ldrh    r1, [r6]
02038: 0a4b     ldr     r3, [pc, #0x28]
0203A: 9942     cmp     r1, r3
0203C: 00d1     bne     #0x2040
0203E: 0100     movs    r1, r0
02040: 8022     movs    r2, #0x80
02042: 019b     ldr     r3, [sp, #4]
02044: 1342     tst     r3, r2
02046: 01d0     beq     #0x204c
02048: 00f0d2f9 bl      #0x23f0
0204C: 3080     strh    r0, [r6]
0204E: 0135     adds    r5, #1
02050: 0236     adds    r6, #2
02052: e6e7     b       #0x2022
02054: 2000     movs    r0, r4
02056: 0400     movs    r4, r0
02058: 0123     movs    r3, #1
0205A: 5b42     rsbs    r3, r3, #0
0205C: fb81     strh    r3, [r7, #0xe]
0205E: 2000     movs    r0, r4
02060: 05b0     add     sp, #0x14
02062: f0bd     pop     {r4, r5, r6, r7, pc}
02064: ffff .hword
02066: 0000     movs    r0, r0
02068: 70b5     push    {r4, r5, r6, lr}
0206A: 114c     ldr     r4, [pc, #0x44]
0206C: 0500     movs    r5, r0
0206E: 2318     adds    r3, r4, r0
02070: 187d     ldrb    r0, [r3, #0x14]
02072: 0b7e     ldrb    r3, [r1, #0x18]
02074: 022b     cmp     r3, #2
02076: 08d3     blo     #0x208a
02078: 032b     cmp     r3, #3
0207A: 04d9     bls     #0x2086
0207C: 062b     cmp     r3, #6
0207E: 04d1     bne     #0x208a
02080: fff74aff bl      #0x1f18
02084: 01e0     b       #0x208a
02086: fff781ff bl      #0x1f8c
0208A: 1f22     movs    r2, #0x1f
0208C: 6319     adds    r3, r4, r5
0208E: 1875     strb    r0, [r3, #0x14]
02090: 6b09     lsrs    r3, r5, #5
02092: 0433     adds    r3, #4
02094: 1540     ands    r5, r2
02096: 9b00     lsls    r3, r3, #2
02098: 1e3a     subs    r2, #0x1e
0209A: aa40     lsls    r2, r5
0209C: e158     ldr     r1, [r4, r3]
0209E: 0028     cmp     r0, #0
020A0: 02d1     bne     #0x20a8
020A2: 9143     bics    r1, r2
020A4: 0a00     movs    r2, r1
020A6: 00e0     b       #0x20aa
020A8: 0a43     orrs    r2, r1
020AA: e250     str     r2, [r4, r3]
020AC: 70bd     pop     {r4, r5, r6, pc}
020AE: c046     mov     r8, r8
020B0: 7401     lsls    r4, r6, #5
020B2: 0020     movs    r0, #0
020B4: 0123     movs    r3, #1
020B6: c20d     lsrs    r2, r0, #0x17
020B8: 1a40     ands    r2, r3
020BA: ca70     strb    r2, [r1, #3]
020BC: 4202     lsls    r2, r0, #9
020BE: 520e     lsrs    r2, r2, #0x19
020C0: 70b5     push    {r4, r5, r6, lr}
020C2: 8a70     strb    r2, [r1, #2]
020C4: 84b2     uxth    r4, r0
020C6: 820f     lsrs    r2, r0, #0x1e
020C8: 060f     lsrs    r6, r0, #0x1c
020CA: 450f     lsrs    r5, r0, #0x1d
020CC: 0001     lsls    r0, r0, #4
020CE: 000f     lsrs    r0, r0, #0x1c
020D0: 1e40     ands    r6, r3
020D2: 1d40     ands    r5, r3
020D4: 0871     strb    r0, [r1, #4]
020D6: 0c80     strh    r4, [r1]
020D8: ca71     strb    r2, [r1, #7]
020DA: 4e71     strb    r6, [r1, #5]
020DC: 8d71     strb    r5, [r1, #6]
020DE: 1800     movs    r0, r3
020E0: 002e     cmp     r6, #0
020E2: 02d1     bne     #0x20ea
020E4: 772c     cmp     r4, #0x77
020E6: 12d8     bhi     #0x210e
020E8: 03e0     b       #0x20f2
020EA: 002d     cmp     r5, #0
020EC: 0fd1     bne     #0x210e
020EE: 4b2c     cmp     r4, #0x4b
020F0: 0dd8     bhi     #0x210e
020F2: 2340     ands    r3, r4
020F4: 1800     movs    r0, r3
020F6: 022a     cmp     r2, #2
020F8: 09d0     beq     #0x210e
020FA: 032a     cmp     r2, #3
020FC: 03d0     beq     #0x2106
020FE: 501e     subs    r0, r2, #1
02100: 431e     subs    r3, r0, #1
02102: 9841     sbcs    r0, r3
02104: 03e0     b       #0x210e
02106: 2000     movs    r0, r4
02108: 1040     ands    r0, r2
0210A: 421e     subs    r2, r0, #1
0210C: 9041     sbcs    r0, r2
0210E: 70bd     pop     {r4, r5, r6, pc}
02110: 70b5     push    {r4, r5, r6, lr}
02112: 114c     ldr     r4, [pc, #0x44]
02114: 7822     movs    r2, #0x78
02116: 0021     movs    r1, #0
02118: 2000     movs    r0, r4
0211A: 01f066fd bl      #0x3bea
0211E: 0f4b     ldr     r3, [pc, #0x3c]
02120: 2025     movs    r5, #0x20
02122: 2380     strh    r3, [r4]
02124: 8c23     movs    r3, #0x8c
02126: 9b00     lsls    r3, r3, #2
02128: 6380     strh    r3, [r4, #2]
0212A: 2000     movs    r0, r4
0212C: 0223     movs    r3, #2
0212E: 2a00     movs    r2, r5
02130: e382     strh    r3, [r4, #0x16]
02132: 0b49     ldr     r1, [pc, #0x2c]
02134: 013b     subs    r3, #1
02136: 1a30     adds    r0, #0x1a
02138: 2376     strb    r3, [r4, #0x18]
0213A: 01f04dfd bl      #0x3bd8
0213E: 2300     movs    r3, r4
02140: 4633     adds    r3, #0x46
02142: 1d70     strb    r5, [r3]
02144: 2300     movs    r3, r4
02146: 5433     adds    r3, #0x54
02148: 1d70     strb    r5, [r3]
0214A: 2300     movs    r3, r4
0214C: 7034     adds    r4, #0x70
0214E: 6233     adds    r3, #0x62
02150: 1d70     strb    r5, [r3]
02152: 2570     strb    r5, [r4]
02154: 70bd     pop     {r4, r5, r6, pc}
02156: c046     mov     r8, r8
02158: 7401     lsls    r4, r6, #5
0215A: 0020     movs    r0, #0
0215C: 0e18     adds    r6, r1, r0
0215E: 0000     movs    r0, r0
02160: 003c     subs    r4, #0
02162: 0000     movs    r0, r0
02164: 13b5     push    {r0, r1, r4, lr}
02166: 0c00     movs    r4, r1
02168: 6946     mov     r1, sp
0216A: fff7a3ff bl      #0x20b4
0216E: 0028     cmp     r0, #0
02170: 18d1     bne     #0x21a4
02172: 6b46     mov     r3, sp
02174: 9b79     ldrb    r3, [r3, #6]
02176: 002b     cmp     r3, #0
02178: 01d1     bne     #0x217e
0217A: 0120     movs    r0, #1
0217C: 12e0     b       #0x21a4
0217E: 6b46     mov     r3, sp
02180: 1a88     ldrh    r2, [r3]
02182: 094b     ldr     r3, [pc, #0x24]
02184: d318     adds    r3, r2, r3
02186: 6a46     mov     r2, sp
02188: d279     ldrb    r2, [r2, #7]
0218A: 012a     cmp     r2, #1
0218C: 02d1     bne     #0x2194
0218E: e4b2     uxtb    r4, r4
02190: 1c70     strb    r4, [r3]
02192: 07e0     b       #0x21a4
02194: 022a     cmp     r2, #2
02196: 02d1     bne     #0x219e
02198: a4b2     uxth    r4, r4
0219A: 1c80     strh    r4, [r3]
0219C: 02e0     b       #0x21a4
0219E: 032a     cmp     r2, #3
021A0: 00d1     bne     #0x21a4
021A2: 1c60     str     r4, [r3]
021A4: 16bd     pop     {r1, r2, r4, pc}
021A6: c046     mov     r8, r8
021A8: 7401     lsls    r4, r6, #5
021AA: 0020     movs    r0, #0
021AC: 0300     movs    r3, r0
021AE: 0020     movs    r0, #0
021B0: 012b     cmp     r3, #1
021B2: 04d8     bhi     #0x21be
021B4: 0130     adds    r0, #1
021B6: 9840     lsls    r0, r3
021B8: 014b     ldr     r3, [pc, #4]
021BA: 1b69     ldr     r3, [r3, #0x10]
021BC: 1840     ands    r0, r3
021BE: 7047     bx      lr
021C0: 7401     lsls    r4, r6, #5
021C2: 0020     movs    r0, #0
021C4: 0128     cmp     r0, #1
021C6: 0cd8     bhi     #0x21e2
021C8: 2423     movs    r3, #0x24
021CA: 5843     muls    r0, r3, r0
021CC: 064a     ldr     r2, [pc, #0x18]
021CE: 1318     adds    r3, r2, r0
021D0: 3833     adds    r3, #0x38
021D2: 1b78     ldrb    r3, [r3]
021D4: 023b     subs    r3, #2
021D6: 012b     cmp     r3, #1
021D8: 03d8     bhi     #0x21e2
021DA: 1018     adds    r0, r2, r0
021DC: 436a     ldr     r3, [r0, #0x24]
021DE: d889     ldrh    r0, [r3, #0xe]
021E0: 00e0     b       #0x21e4
021E2: 0248     ldr     r0, [pc, #8]
021E4: 7047     bx      lr
021E6: c046     mov     r8, r8
021E8: 003c     subs    r4, #0
021EA: 0000     movs    r0, r0
021EC: ffff .hword
021EE: 0000     movs    r0, r0
021F0: 0023     movs    r3, #0
021F2: 024a     ldr     r2, [pc, #8]
021F4: 9380     strh    r3, [r2, #4]
021F6: 024a     ldr     r2, [pc, #8]
021F8: 1360     str     r3, [r2]
021FA: 7047     bx      lr
021FC: 7401     lsls    r4, r6, #5
021FE: 0020     movs    r0, #0
02200: 3401     lsls    r4, r6, #4
02202: 0020     movs    r0, #0
02204: f7b5     push    {r0, r1, r2, r4, r5, r6, r7, lr}
02206: 0027     movs    r7, #0
02208: 2a4d     ldr     r5, [pc, #0xa8]
0220A: 2b4e     ldr     r6, [pc, #0xac]
0220C: ab88     ldrh    r3, [r5, #4]
0220E: 2c00     movs    r4, r5
02210: dbb2     uxtb    r3, r3
02212: 581e     subs    r0, r3, #1
02214: 0193     str     r3, [sp, #4]
02216: 0428     cmp     r0, #4
02218: 1ed8     bhi     #0x2258
0221A: 01f031fb bl      #0x3880
0221E: 0305     lsls    r3, r0, #0x14
02220: 070d     lsrs    r7, r0, #0x14
02222: 0f00     movs    r7, r1
02224: 0123     movs    r3, #1
02226: 08e0     b       #0x223a
02228: 0023     movs    r3, #0
0222A: 06e0     b       #0x223a
0222C: fff77cfd bl      #0x1d28
02230: 0023     movs    r3, #0
02232: 0127     movs    r7, #1
02234: 3360     str     r3, [r6]
02236: 01e0     b       #0x223c
02238: 0223     movs    r3, #2
0223A: 3360     str     r3, [r6]
0223C: 01f046fa bl      #0x36cc
02240: ab88     ldrh    r3, [r5, #4]
02242: 019a     ldr     r2, [sp, #4]
02244: dbb2     uxtb    r3, r3
02246: 9a42     cmp     r2, r3
02248: 04d1     bne     #0x2254
0224A: 8023     movs    r3, #0x80
0224C: aa88     ldrh    r2, [r5, #4]
0224E: 1b02     lsls    r3, r3, #8
02250: 1343     orrs    r3, r2
02252: ab80     strh    r3, [r5, #4]
02254: 01f03efa bl      #0x36d4
02258: 3368     ldr     r3, [r6]
0225A: 012b     cmp     r3, #1
0225C: d4d0     beq     #0x2208
0225E: 022b     cmp     r3, #2
02260: 25d1     bne     #0x22ae
02262: 2300     movs    r3, r4
02264: 2200     movs    r2, r4
02266: 7233     adds    r3, #0x72
02268: 1b78     ldrb    r3, [r3]
0226A: 7332     adds    r2, #0x73
0226C: 1178     ldrb    r1, [r2]
0226E: dbb2     uxtb    r3, r3
02270: c9b2     uxtb    r1, r1
02272: 012b     cmp     r3, #1
02274: 1bd8     bhi     #0x22ae
02276: 2422     movs    r2, #0x24
02278: 5343     muls    r3, r2, r3
0227A: 104a     ldr     r2, [pc, #0x40]
0227C: d318     adds    r3, r2, r3
0227E: da8a     ldrh    r2, [r3, #0x16]
02280: 9142     cmp     r1, r2
02282: 14d2     bhs     #0x22ae
02284: 2500     movs    r5, r4
02286: 7435     adds    r5, #0x74
02288: e088     ldrh    r0, [r4, #6]
0228A: 2a88     ldrh    r2, [r5]
0228C: 9042     cmp     r0, r2
0228E: 0ed0     beq     #0x22ae
02290: 0e26     movs    r6, #0xe
02292: 7143     muls    r1, r6, r1
02294: 9b68     ldr     r3, [r3, #8]
02296: 5e18     adds    r6, r3, r1
02298: 01f018fa bl      #0x36cc
0229C: e388     ldrh    r3, [r4, #6]
0229E: 7634     adds    r4, #0x76
022A0: 9bb2     uxth    r3, r3
022A2: 2b80     strh    r3, [r5]
022A4: 3388     ldrh    r3, [r6]
022A6: 9bb2     uxth    r3, r3
022A8: 2380     strh    r3, [r4]
022AA: 01f013fa bl      #0x36d4
022AE: 3800     movs    r0, r7
022B0: febd     pop     {r1, r2, r3, r4, r5, r6, r7, pc}
022B2: c046     mov     r8, r8
022B4: 7401     lsls    r4, r6, #5
022B6: 0020     movs    r0, #0
022B8: 3401     lsls    r4, r6, #4
022BA: 0020     movs    r0, #0
022BC: 203c     subs    r4, #0x20
022BE: 0000     movs    r0, r0
022C0: 0021     movs    r1, #0
022C2: 8318     adds    r3, r0, r2
022C4: 5200     lsls    r2, r2, #1
022C6: 1971     strb    r1, [r3, #4]
022C8: 8018     adds    r0, r0, r2
022CA: 0288     ldrh    r2, [r0]
022CC: 4280     strh    r2, [r0, #2]
022CE: 1972     strb    r1, [r3, #8]
022D0: 7047     bx      lr
022D2: 10b5     push    {r4, lr}
022D4: 0022     movs    r2, #0
022D6: fff7f3ff bl      #0x22c0
022DA: 10bd     pop     {r4, pc}
022DC: 2423     movs    r3, #0x24
022DE: 5843     muls    r0, r3, r0
022E0: 054b     ldr     r3, [pc, #0x14]
022E2: 10b5     push    {r4, lr}
022E4: 1b18     adds    r3, r3, r0
022E6: 9c68     ldr     r4, [r3, #8]
022E8: 1a7e     ldrb    r2, [r3, #0x18]
022EA: 0e23     movs    r3, #0xe
022EC: 4b43     muls    r3, r1, r3
022EE: 1100     movs    r1, r2
022F0: e018     adds    r0, r4, r3
022F2: fff7eeff bl      #0x22d2
022F6: 10bd     pop     {r4, pc}
022F8: 203c     subs    r4, #0x20
022FA: 0000     movs    r0, r0
022FC: 2423     movs    r3, #0x24
022FE: 70b5     push    {r4, r5, r6, lr}
02300: 0400     movs    r4, r0
02302: 4343     muls    r3, r0, r3
02304: 064a     ldr     r2, [pc, #0x18]
02306: d318     adds    r3, r2, r3
02308: db8a     ldrh    r3, [r3, #0x16]
0230A: 5d1e     subs    r5, r3, #1
0230C: 002b     cmp     r3, #0
0230E: 05d0     beq     #0x231c
02310: 2900     movs    r1, r5
02312: 2000     movs    r0, r4
02314: fff7e2ff bl      #0x22dc
02318: 2b00     movs    r3, r5
0231A: f6e7     b       #0x230a
0231C: 70bd     pop     {r4, r5, r6, pc}
0231E: c046     mov     r8, r8
02320: 203c     subs    r4, #0x20
02322: 0000     movs    r0, r0
02324: 10b5     push    {r4, lr}
02326: 0120     movs    r0, #1
02328: fff7e8ff bl      #0x22fc
0232C: 0020     movs    r0, #0
0232E: fff7e5ff bl      #0x22fc
02332: 10bd     pop     {r4, pc}
02334: 70b5     push    {r4, r5, r6, lr}
02336: 0500     movs    r5, r0
02338: 0800     movs    r0, r1
0233A: 0488     ldrh    r4, [r0]
0233C: 4388     ldrh    r3, [r0, #2]
0233E: 1100     movs    r1, r2
02340: 9c42     cmp     r4, r3
02342: 04d2     bhs     #0x234e
02344: 6e79     ldrb    r6, [r5, #5]
02346: 1a1b     subs    r2, r3, r4
02348: b242     cmp     r2, r6
0234A: 0ed8     bhi     #0x236a
0234C: 01e0     b       #0x2352
0234E: 0022     movs    r2, #0
02350: 0272     strb    r2, [r0, #8]
02352: ff25     movs    r5, #0xff
02354: 0279     ldrb    r2, [r0, #4]
02356: 1b02     lsls    r3, r3, #8
02358: 1343     orrs    r3, r2
0235A: 6b43     muls    r3, r5, r3
0235C: 2402     lsls    r4, r4, #8
0235E: 1b19     adds    r3, r3, r4
02360: 1a0a     lsrs    r2, r3, #8
02362: 1b0c     lsrs    r3, r3, #0x10
02364: 4380     strh    r3, [r0, #2]
02366: 0271     strb    r2, [r0, #4]
02368: 09e0     b       #0x237e
0236A: 037a     ldrb    r3, [r0, #8]
0236C: 2a7a     ldrb    r2, [r5, #8]
0236E: 9a42     cmp     r2, r3
02370: 02d9     bls     #0x2378
02372: 0133     adds    r3, #1
02374: 0372     strb    r3, [r0, #8]
02376: 02e0     b       #0x237e
02378: 0022     movs    r2, #0
0237A: fff7a1ff bl      #0x22c0
0237E: 0020     movs    r0, #0
02380: 70bd     pop     {r4, r5, r6, pc}
02382: d2b2     uxtb    r2, r2
02384: 062a     cmp     r2, #6
02386: 01d0     beq     #0x238c
02388: 0b88     ldrh    r3, [r1]
0238A: 0380     strh    r3, [r0]
0238C: 7047     bx      lr
0238E: 0000     movs    r0, r0
02390: f8b5     push    {r3, r4, r5, r6, r7, lr}
02392: 0d4c     ldr     r4, [pc, #0x34]
02394: 0d4b     ldr     r3, [pc, #0x34]
02396: 9c42     cmp     r4, r3
02398: 15d0     beq     #0x23c6
0239A: 0e26     movs    r6, #0xe
0239C: e589     ldrh    r5, [r4, #0xe]
0239E: 0c4b     ldr     r3, [pc, #0x30]
023A0: 6e43     muls    r6, r5, r6
023A2: ef18     adds    r7, r5, r3
023A4: 0e3e     subs    r6, #0xe
023A6: 7f00     lsls    r7, r7, #1
023A8: 002d     cmp     r5, #0
023AA: 0ad0     beq     #0x23c2
023AC: 6368     ldr     r3, [r4, #4]
023AE: 227c     ldrb    r2, [r4, #0x10]
023B0: d819     adds    r0, r3, r7
023B2: 2368     ldr     r3, [r4]
023B4: 013d     subs    r5, #1
023B6: 9919     adds    r1, r3, r6
023B8: fff7e3ff bl      #0x2382
023BC: 0e3e     subs    r6, #0xe
023BE: 023f     subs    r7, #2
023C0: f2e7     b       #0x23a8
023C2: 243c     subs    r4, #0x24
023C4: e6e7     b       #0x2394
023C6: f8bd     pop     {r3, r4, r5, r6, r7, pc}
023C8: 4c3c     subs    r4, #0x4c
023CA: 0000     movs    r0, r0
023CC: 043c     subs    r4, #4
023CE: 0000     movs    r0, r0
023D0: ffff .hword
023D2: ff7f     ldrb    r7, [r7, #0x1f]
023D4: d2b2     uxtb    r2, r2
023D6: 062a     cmp     r2, #6
023D8: 05d0     beq     #0x23e6
023DA: 0b88     ldrh    r3, [r1]
023DC: 0288     ldrh    r2, [r0]
023DE: d318     adds    r3, r2, r3
023E0: 5b08     lsrs    r3, r3, #1
023E2: 0380     strh    r3, [r0]
023E4: 0b80     strh    r3, [r1]
023E6: 7047     bx      lr
023E8: 10b5     push    {r4, lr}
023EA: fff7f3ff bl      #0x23d4
023EE: 10bd     pop     {r4, pc}
023F0: 8142     cmp     r1, r0
023F2: 01d9     bls     #0x23f8
023F4: 0130     adds    r0, #1
023F6: 03e0     b       #0x2400
023F8: 8142     cmp     r1, r0
023FA: 8941     sbcs    r1, r1
023FC: 4942     rsbs    r1, r1, #0
023FE: 401a     subs    r0, r0, r1
02400: 7047     bx      lr
02402: 0000     movs    r0, r0
02404: 024b     ldr     r3, [pc, #8]
02406: 9868     ldr     r0, [r3, #8]
02408: 8023     movs    r3, #0x80
0240A: 1840     ands    r0, r3
0240C: 7047     bx      lr
0240E: c046     mov     r8, r8
02410: 7401     lsls    r4, r6, #5
02412: 0020     movs    r0, #0
02414: 10b5     push    {r4, lr}
02416: 8024     movs    r4, #0x80
02418: 094a     ldr     r2, [pc, #0x24]
0241A: 6402     lsls    r4, r4, #9
0241C: 9368     ldr     r3, [r2, #8]
0241E: 1c40     ands    r4, r3
02420: 1123     movs    r3, #0x11
02422: 002c     cmp     r4, #0
02424: 09d1     bne     #0x243a
02426: 103b     subs    r3, #0x10
02428: 9842     cmp     r0, r3
0242A: 06d8     bhi     #0x243a
0242C: d268     ldr     r2, [r2, #0xc]
0242E: c240     lsrs    r2, r0
02430: 1a42     tst     r2, r3
02432: 02d0     beq     #0x243a
02434: 00f0b4fa bl      #0x29a0
02438: 2300     movs    r3, r4
0243A: 1800     movs    r0, r3
0243C: 10bd     pop     {r4, pc}
0243E: c046     mov     r8, r8
02440: 7401     lsls    r4, r6, #5
02442: 0020     movs    r0, #0
02444: 064b     ldr     r3, [pc, #0x18]
02446: 10b5     push    {r4, lr}
02448: 9c68     ldr     r4, [r3, #8]
0244A: 8023     movs    r3, #0x80
0244C: 5b02     lsls    r3, r3, #9
0244E: 1c40     ands    r4, r3
02450: 1120     movs    r0, #0x11
02452: 002c     cmp     r4, #0
02454: 02d1     bne     #0x245c
02456: 00f01ffa bl      #0x2898
0245A: 2000     movs    r0, r4
0245C: 10bd     pop     {r4, pc}
0245E: c046     mov     r8, r8
02460: 7401     lsls    r4, r6, #5
02462: 0020     movs    r0, #0
02464: 0d4b     ldr     r3, [pc, #0x34]
02466: 10b5     push    {r4, lr}
02468: 9868     ldr     r0, [r3, #8]
0246A: 8023     movs    r3, #0x80
0246C: 0340     ands    r3, r0
0246E: 1120     movs    r0, #0x11
02470: 002b     cmp     r3, #0
02472: 12d1     bne     #0x249a
02474: 1800     movs    r0, r3
02476: fff7cdff bl      #0x2414
0247A: 0028     cmp     r0, #0
0247C: 09d0     beq     #0x2492
0247E: 0120     movs    r0, #1
02480: fff7c8ff bl      #0x2414
02484: 0028     cmp     r0, #0
02486: 08d1     bne     #0x249a
02488: 054b     ldr     r3, [pc, #0x14]
0248A: 1870     strb    r0, [r3]
0248C: fff7daff bl      #0x2444
02490: 03e0     b       #0x249a
02492: 0122     movs    r2, #1
02494: 024b     ldr     r3, [pc, #8]
02496: 1a70     strb    r2, [r3]
02498: f8e7     b       #0x248c
0249A: 10bd     pop     {r4, pc}
0249C: 7401     lsls    r4, r6, #5
0249E: 0020     movs    r0, #0
024A0: 3801     lsls    r0, r7, #4
024A2: 0020     movs    r0, #0
024A4: 10b5     push    {r4, lr}
024A6: 114c     ldr     r4, [pc, #0x44]
024A8: 6378     ldrb    r3, [r4, #1]
024AA: 0133     adds    r3, #1
024AC: dbb2     uxtb    r3, r3
024AE: 6370     strb    r3, [r4, #1]
024B0: 6078     ldrb    r0, [r4, #1]
024B2: c0b2     uxtb    r0, r0
024B4: fff7aeff bl      #0x2414
024B8: 6378     ldrb    r3, [r4, #1]
024BA: 0028     cmp     r0, #0
024BC: 05d1     bne     #0x24ca
024BE: 012b     cmp     r3, #1
024C0: 00d1     bne     #0x24c4
024C2: 2070     strb    r0, [r4]
024C4: fff7beff bl      #0x2444
024C8: 0fe0     b       #0x24ea
024CA: 094a     ldr     r2, [pc, #0x24]
024CC: 0006     lsls    r0, r0, #0x18
024CE: 012b     cmp     r3, #1
024D0: 05d1     bne     #0x24de
024D2: 9168     ldr     r1, [r2, #8]
024D4: 074b     ldr     r3, [pc, #0x1c]
024D6: 0b40     ands    r3, r1
024D8: 1843     orrs    r0, r3
024DA: 9060     str     r0, [r2, #8]
024DC: 05e0     b       #0x24ea
024DE: 9368     ldr     r3, [r2, #8]
024E0: 1b02     lsls    r3, r3, #8
024E2: 1b0a     lsrs    r3, r3, #8
024E4: 1843     orrs    r0, r3
024E6: 9060     str     r0, [r2, #8]
024E8: dde7     b       #0x24a6
024EA: 10bd     pop     {r4, pc}
024EC: 3801     lsls    r0, r7, #4
024EE: 0020     movs    r0, #0
024F0: 7401     lsls    r4, r6, #5
024F2: 0020     movs    r0, #0
024F4: 7fff .hword
024F6: ff00     lsls    r7, r7, #3
024F8: 064a     ldr     r2, [pc, #0x18]
024FA: 074b     ldr     r3, [pc, #0x1c]
024FC: 0138     subs    r0, #1
024FE: 1a60     str     r2, [r3]
02500: 064a     ldr     r2, [pc, #0x18]
02502: 0002     lsls    r0, r0, #8
02504: 1060     str     r0, [r2]
02506: 1a68     ldr     r2, [r3]
02508: 002a     cmp     r2, #0
0250A: fcdb     blt     #0x2506
0250C: 044a     ldr     r2, [pc, #0x10]
0250E: 024b     ldr     r3, [pc, #8]
02510: 1a60     str     r2, [r3]
02512: 7047     bx      lr
02514: 4000     lsls    r0, r0, #1
02516: 0040     ands    r0, r0
02518: 0000     movs    r0, r0
0251A: 0140     ands    r1, r0
0251C: 0003     lsls    r0, r0, #0xc
0251E: 0140     ands    r1, r0
02520: 40ff0080 vhadd.u8 d24, d0, d0
02524: 064a     ldr     r2, [pc, #0x18]
02526: 074b     ldr     r3, [pc, #0x1c]
02528: 0138     subs    r0, #1
0252A: 1a60     str     r2, [r3]
0252C: 064a     ldr     r2, [pc, #0x18]
0252E: 0002     lsls    r0, r0, #8
02530: 1060     str     r0, [r2]
02532: 1a68     ldr     r2, [r3]
02534: 002a     cmp     r2, #0
02536: fcdb     blt     #0x2532
02538: 044a     ldr     r2, [pc, #0x10]
0253A: 024b     ldr     r3, [pc, #8]
0253C: 1a60     str     r2, [r3]
0253E: 7047     bx      lr
02540: 4100     lsls    r1, r0, #1
02542: 0040     ands    r0, r0
02544: 0000     movs    r0, r0
02546: 0140     ands    r1, r0
02548: 0403     lsls    r4, r0, #0xc
0254A: 0140     ands    r1, r0
0254C: 41ff0080 vhadd.u8 d24, d1, d0
02550: 10b5     push    {r4, lr}
02552: 0128     cmp     r0, #1
02554: 01d9     bls     #0x255a
02556: 0120     movs    r0, #1
02558: 02e0     b       #0x2560
0255A: 5521     movs    r1, #0x55
0255C: 00f0c8fa bl      #0x2af0
02560: 10bd     pop     {r4, pc}
02562: 10b5     push    {r4, lr}
02564: 0020     movs    r0, #0
02566: fff7f3ff bl      #0x2550
0256A: 0400     movs    r4, r0
0256C: 0120     movs    r0, #1
0256E: fff7efff bl      #0x2550
02572: 2043     orrs    r0, r4
02574: 10bd     pop     {r4, pc}
02576: 0000     movs    r0, r0
02578: f7b5     push    {r0, r1, r2, r4, r5, r6, r7, lr}
0257A: 144c     ldr     r4, [pc, #0x50]
0257C: 0026     movs    r6, #0
0257E: 2368     ldr     r3, [r4]
02580: 0193     str     r3, [sp, #4]
02582: a37d     ldrb    r3, [r4, #0x16]
02584: 9e42     cmp     r6, r3
02586: 1cd2     bhs     #0x25c2
02588: 0422     movs    r2, #4
0258A: a38a     ldrh    r3, [r4, #0x14]
0258C: 1342     tst     r3, r2
0258E: 10d0     beq     #0x25b2
02590: 0027     movs    r7, #0
02592: 2368     ldr     r3, [r4]
02594: b500     lsls    r5, r6, #2
02596: 5d19     adds    r5, r3, r5
02598: ab78     ldrb    r3, [r5, #2]
0259A: 9f42     cmp     r7, r3
0259C: 0fd2     bhs     #0x25be
0259E: 1c23     movs    r3, #0x1c
025A0: 2888     ldrh    r0, [r5]
025A2: c019     adds    r0, r0, r7
025A4: 5843     muls    r0, r3, r0
025A6: 0a4b     ldr     r3, [pc, #0x28]
025A8: 0137     adds    r7, #1
025AA: c018     adds    r0, r0, r3
025AC: 00f0aaf9 bl      #0x2904
025B0: f2e7     b       #0x2598
025B2: 1c20     movs    r0, #0x1c
025B4: 7043     muls    r0, r6, r0
025B6: 019b     ldr     r3, [sp, #4]
025B8: 1818     adds    r0, r3, r0
025BA: 00f0a3f9 bl      #0x2904
025BE: 0136     adds    r6, #1
025C0: dfe7     b       #0x2582
025C2: 044b     ldr     r3, [pc, #0x10]
025C4: 2434     adds    r4, #0x24
025C6: a342     cmp     r3, r4
025C8: d8d1     bne     #0x257c
025CA: f7bd     pop     {r0, r1, r2, r4, r5, r6, r7, pc}
025CC: 203c     subs    r4, #0x20
025CE: 0000     movs    r0, r0
025D0: 6c3c     subs    r4, #0x6c
025D2: 0000     movs    r0, r0
025D4: 683c     subs    r4, #0x68
025D6: 0000     movs    r0, r0
025D8: 0122     movs    r2, #1
025DA: 8a40     lsls    r2, r1
025DC: 084b     ldr     r3, [pc, #0x20]
025DE: 013a     subs    r2, #1
025E0: 197e     ldrb    r1, [r3, #0x18]
025E2: c023     movs    r3, #0xc0
025E4: 5143     muls    r1, r2, r1
025E6: 0203     lsls    r2, r0, #0xc
025E8: 121a     subs    r2, r2, r0
025EA: 8a42     cmp     r2, r1
025EC: 05d3     blo     #0x25fa
025EE: ff22     movs    r2, #0xff
025F0: 5043     muls    r0, r2, r0
025F2: 8842     cmp     r0, r1
025F4: 9b41     sbcs    r3, r3
025F6: 5b42     rsbs    r3, r3, #0
025F8: 9b01     lsls    r3, r3, #6
025FA: d8b2     uxtb    r0, r3
025FC: 7047     bx      lr
025FE: c046     mov     r8, r8
02600: 7401     lsls    r4, r6, #5
02602: 0020     movs    r0, #0
02604: 70b5     push    {r4, r5, r6, lr}
02606: 074d     ldr     r5, [pc, #0x1c]
02608: 6c68     ldr     r4, [r5, #4]
0260A: 2188     ldrh    r1, [r4]
0260C: e07a     ldrb    r0, [r4, #0xb]
0260E: fff7e3ff bl      #0x25d8
02612: 2073     strb    r0, [r4, #0xc]
02614: ac6a     ldr     r4, [r5, #0x28]
02616: 2188     ldrh    r1, [r4]
02618: e07a     ldrb    r0, [r4, #0xb]
0261A: fff7ddff bl      #0x25d8
0261E: 2073     strb    r0, [r4, #0xc]
02620: 70bd     pop     {r4, r5, r6, pc}
02622: c046     mov     r8, r8
02624: 203c     subs    r4, #0x20
02626: 0000     movs    r0, r0
02628: 0f20     movs    r0, #0xf
0262A: 70b5     push    {r4, r5, r6, lr}
0262C: 0a4c     ldr     r4, [pc, #0x28]
0262E: f022     movs    r2, #0xf0
02630: 2368     ldr     r3, [r4]
02632: 0a4d     ldr     r5, [pc, #0x28]
02634: 8343     bics    r3, r0
02636: 1900     movs    r1, r3
02638: 2b78     ldrb    r3, [r5]
0263A: 0340     ands    r3, r0
0263C: 0b43     orrs    r3, r1
0263E: 9343     bics    r3, r2
02640: 1a00     movs    r2, r3
02642: 2b78     ldrb    r3, [r5]
02644: 8343     bics    r3, r0
02646: 1343     orrs    r3, r2
02648: 2360     str     r3, [r4]
0264A: fff7dbff bl      #0x2604
0264E: 00f015f8 bl      #0x267c
02652: 0020     movs    r0, #0
02654: 70bd     pop     {r4, r5, r6, pc}
02656: c046     mov     r8, r8
02658: 00ff0840 vhadd.u8 d4, d0, d8
0265C: 62f1ff0f sbc     pc, r2, #0xff
02660: c022     movs    r2, #0xc0
02662: 10b5     push    {r4, lr}
02664: 044c     ldr     r4, [pc, #0x10]
02666: 2368     ldr     r3, [r4]
02668: 9343     bics    r3, r2
0266A: 0343     orrs    r3, r0
0266C: 0800     movs    r0, r1
0266E: 2360     str     r3, [r4]
02670: fff758ff bl      #0x2524
02674: 10bd     pop     {r4, pc}
02676: c046     mov     r8, r8
02678: 7800     lsls    r0, r7, #1
0267A: 0020     movs    r0, #0
0267C: 10b5     push    {r4, lr}
0267E: fff77bff bl      #0x2578
02682: 094a     ldr     r2, [pc, #0x24]
02684: 094b     ldr     r3, [pc, #0x24]
02686: 1a60     str     r2, [r3]
02688: 094a     ldr     r2, [pc, #0x24]
0268A: 0a4b     ldr     r3, [pc, #0x28]
0268C: 1168     ldr     r1, [r2]
0268E: 0b40     ands    r3, r1
02690: c021     movs    r1, #0xc0
02692: c902     lsls    r1, r1, #0xb
02694: 0b43     orrs    r3, r1
02696: 1360     str     r3, [r2]
02698: 074b     ldr     r3, [pc, #0x1c]
0269A: 084a     ldr     r2, [pc, #0x20]
0269C: 1b68     ldr     r3, [r3]
0269E: 1343     orrs    r3, r2
026A0: 074a     ldr     r2, [pc, #0x1c]
026A2: 1360     str     r3, [r2]
026A4: 10bd     pop     {r4, pc}
026A6: c046     mov     r8, r8
026A8: 0002     lsls    r0, r0, #8
026AA: 0001     lsls    r0, r0, #4
026AC: 0800     movs    r0, r1
026AE: 0840     ands    r0, r1
026B0: 0000     movs    r0, r0
026B2: 0240     ands    r2, r0
026B4: ffff .hword
026B6: f0ff7800 vshr.u32 q8, q12, #0x10
026BA: 0020     movs    r0, #0
026BC: 2008     lsrs    r0, r4, #0x20
026BE: e881     strh    r0, [r5, #0xe]
026C0: 0400     movs    r4, r0
026C2: 0840     ands    r0, r1
026C4: 70b5     push    {r4, r5, r6, lr}
026C6: 0500     movs    r5, r0
026C8: 0a4c     ldr     r4, [pc, #0x28]
026CA: 00f0ffff bl      #0x36cc
026CE: 2268     ldr     r2, [r4]
026D0: 094b     ldr     r3, [pc, #0x24]
026D2: 0a49     ldr     r1, [pc, #0x28]
026D4: 1a40     ands    r2, r3
026D6: 0a4b     ldr     r3, [pc, #0x28]
026D8: 0968     ldr     r1, [r1]
026DA: 1b78     ldrb    r3, [r3]
026DC: c918     adds    r1, r1, r3
026DE: 0e7b     ldrb    r6, [r1, #0xc]
026E0: eb18     adds    r3, r5, r3
026E2: 3604     lsls    r6, r6, #0x10
026E4: 997a     ldrb    r1, [r3, #0xa]
026E6: 3300     movs    r3, r6
026E8: 0b43     orrs    r3, r1
026EA: 1343     orrs    r3, r2
026EC: 2360     str     r3, [r4]
026EE: 00f0f1ff bl      #0x36d4
026F2: 70bd     pop     {r4, r5, r6, pc}
026F4: 0800     movs    r0, r1
026F6: 0840     ands    r0, r1
026F8: 00ff80ff vpmax.f32 d15, d16, d0
026FC: ec01     lsls    r4, r5, #7
026FE: 0020     movs    r0, #0
02700: 143d     subs    r5, #0x14
02702: 0000     movs    r0, r0
02704: 10b5     push    {r4, lr}
02706: 064b     ldr     r3, [pc, #0x18]
02708: 1a78     ldrb    r2, [r3]
0270A: 2423     movs    r3, #0x24
0270C: 5343     muls    r3, r2, r3
0270E: 054a     ldr     r2, [pc, #0x14]
02710: d318     adds    r3, r2, r3
02712: 5b68     ldr     r3, [r3, #4]
02714: d97a     ldrb    r1, [r3, #0xb]
02716: 187b     ldrb    r0, [r3, #0xc]
02718: fff7a2ff bl      #0x2660
0271C: 10bd     pop     {r4, pc}
0271E: c046     mov     r8, r8
02720: 3901     lsls    r1, r7, #4
02722: 0020     movs    r0, #0
02724: 203c     subs    r4, #0x20
02726: 0000     movs    r0, r0
02728: 0123     movs    r3, #1
0272A: 0288     ldrh    r2, [r0]
0272C: 9340     lsls    r3, r2
0272E: 024a     ldr     r2, [pc, #8]
02730: 013b     subs    r3, #1
02732: 1b04     lsls    r3, r3, #0x10
02734: 5360     str     r3, [r2, #4]
02736: 7047     bx      lr
02738: 7800     lsls    r0, r7, #1
0273A: 0020     movs    r0, #0
0273C: f7b5     push    {r0, r1, r2, r4, r5, r6, r7, lr}
0273E: 00f0c5ff bl      #0x36cc
02742: 1c4c     ldr     r4, [pc, #0x70]
02744: 1c4b     ldr     r3, [pc, #0x70]
02746: 2268     ldr     r2, [r4]
02748: 1c4e     ldr     r6, [pc, #0x70]
0274A: 1343     orrs    r3, r2
0274C: 3360     str     r3, [r6]
0274E: 1c4b     ldr     r3, [pc, #0x70]
02750: 0700     movs    r7, r0
02752: 187e     ldrb    r0, [r3, #0x18]
02754: fff7d0fe bl      #0x24f8
02758: 1a4b     ldr     r3, [pc, #0x68]
0275A: 1b4a     ldr     r2, [pc, #0x6c]
0275C: 1a60     str     r2, [r3]
0275E: 1a68     ldr     r2, [r3]
02760: 002a     cmp     r2, #0
02762: fcdb     blt     #0x275e
02764: 194a     ldr     r2, [pc, #0x64]
02766: 174b     ldr     r3, [pc, #0x5c]
02768: 194d     ldr     r5, [pc, #0x64]
0276A: 1a60     str     r2, [r3]
0276C: 2b68     ldr     r3, [r5]
0276E: 0f20     movs    r0, #0xf
02770: 0193     str     r3, [sp, #4]
02772: 00f0a1ff bl      #0x36b8
02776: 174b     ldr     r3, [pc, #0x5c]
02778: 0821     movs    r1, #8
0277A: 2b60     str     r3, [r5]
0277C: f123     movs    r3, #0xf1
0277E: 164a     ldr     r2, [pc, #0x58]
02780: 1068     ldr     r0, [r2]
02782: 0842     tst     r0, r1
02784: 02d1     bne     #0x278c
02786: 013b     subs    r3, #1
02788: 002b     cmp     r3, #0
0278A: f9d1     bne     #0x2780
0278C: 019b     ldr     r3, [sp, #4]
0278E: 0720     movs    r0, #7
02790: 2b60     str     r3, [r5]
02792: 2268     ldr     r2, [r4]
02794: 114b     ldr     r3, [pc, #0x44]
02796: 1343     orrs    r3, r2
02798: 3360     str     r3, [r6]
0279A: 00f027fe bl      #0x33ec
0279E: 3320     movs    r0, #0x33
027A0: 00f08aff bl      #0x36b8
027A4: 6268     ldr     r2, [r4, #4]
027A6: 0e4b     ldr     r3, [pc, #0x38]
027A8: 3800     movs    r0, r7
027AA: 1a60     str     r2, [r3]
027AC: 00f092ff bl      #0x36d4
027B0: f7bd     pop     {r0, r1, r2, r4, r5, r6, r7, pc}
027B2: c046     mov     r8, r8
027B4: 7800     lsls    r0, r7, #1
027B6: 0020     movs    r0, #0
027B8: 2008     lsrs    r0, r4, #0x20
027BA: e881     strh    r0, [r5, #0xe]
027BC: 0400     movs    r4, r0
027BE: 0840     ands    r0, r1
027C0: 7401     lsls    r4, r6, #5
027C2: 0020     movs    r0, #0
027C4: 0000     movs    r0, r0
027C6: 0140     ands    r1, r0
027C8: 4100     lsls    r1, r0, #1
027CA: 0040     ands    r0, r0
027CC: 41ff0080 vhadd.u8 d24, d1, d0
027D0: 0800     movs    r0, r1
027D2: 0840     ands    r0, r1
027D4: f006     lsls    r0, r6, #0x1b
027D6: 0040     ands    r0, r0
027D8: 1000     movs    r0, r2
027DA: 0840     ands    r0, r1
027DC: 2018     adds    r0, r4, r0
027DE: e881     strh    r0, [r5, #0xe]
027E0: 0c00     movs    r4, r1
027E2: 0840     ands    r0, r1
027E4: 10b5     push    {r4, lr}
027E6: 044a     ldr     r2, [pc, #0x10]
027E8: 044b     ldr     r3, [pc, #0x10]
027EA: 9168     ldr     r1, [r2, #8]
027EC: 0b43     orrs    r3, r1
027EE: 9360     str     r3, [r2, #8]
027F0: fff7a4ff bl      #0x273c
027F4: 10bd     pop     {r4, pc}
027F6: c046     mov     r8, r8
027F8: 7401     lsls    r4, r6, #5
027FA: 0020     movs    r0, #0
027FC: 8000     lsls    r0, r0, #2
027FE: 0100     movs    r1, r0
02800: f8b5     push    {r3, r4, r5, r6, r7, lr}
02802: 0400     movs    r4, r0
02804: 077e     ldrb    r7, [r0, #0x18]
02806: 857e     ldrb    r5, [r0, #0x1a]
02808: 00f060ff bl      #0x36cc
0280C: 0f22     movs    r2, #0xf
0280E: ba40     lsls    r2, r7
02810: 2668     ldr     r6, [r4]
02812: 0721     movs    r1, #7
02814: 3368     ldr     r3, [r6]
02816: a940     lsls    r1, r5
02818: 9343     bics    r3, r2
0281A: 1a00     movs    r2, r3
0281C: 0423     movs    r3, #4
0281E: bb40     lsls    r3, r7
02820: 6468     ldr     r4, [r4, #4]
02822: 1343     orrs    r3, r2
02824: 2268     ldr     r2, [r4]
02826: 8a43     bics    r2, r1
02828: 2260     str     r2, [r4]
0282A: 3360     str     r3, [r6]
0282C: 00f052ff bl      #0x36d4
02830: f8bd     pop     {r3, r4, r5, r6, r7, pc}
02832: 0000     movs    r0, r0
02834: 2422     movs    r2, #0x24
02836: 1300     movs    r3, r2
02838: 083a     subs    r2, #8
0283A: 4343     muls    r3, r0, r3
0283C: 1000     movs    r0, r2
0283E: 70b5     push    {r4, r5, r6, lr}
02840: 4843     muls    r0, r1, r0
02842: 114d     ldr     r5, [pc, #0x44]
02844: 5c59     ldr     r4, [r3, r5]
02846: eb18     adds    r3, r5, r3
02848: 2018     adds    r0, r4, r0
0284A: 9b8a     ldrh    r3, [r3, #0x14]
0284C: 0f4c     ldr     r4, [pc, #0x3c]
0284E: 2060     str     r0, [r4]
02850: 5b07     lsls    r3, r3, #0x1d
02852: 15d5     bpl     #0x2880
02854: 1823     movs    r3, #0x18
02856: 5b42     rsbs    r3, r3, #0
02858: 5943     muls    r1, r3, r1
0285A: 0d4b     ldr     r3, [pc, #0x34]
0285C: 4018     adds    r0, r0, r1
0285E: 1860     str     r0, [r3]
02860: 0388     ldrh    r3, [r0]
02862: 8578     ldrb    r5, [r0, #2]
02864: 5a43     muls    r2, r3, r2
02866: 0b4b     ldr     r3, [pc, #0x2c]
02868: d218     adds    r2, r2, r3
0286A: 2260     str     r2, [r4]
0286C: 2068     ldr     r0, [r4]
0286E: fff7c7ff bl      #0x2800
02872: 2368     ldr     r3, [r4]
02874: 013d     subs    r5, #1
02876: 1c33     adds    r3, #0x1c
02878: 2360     str     r3, [r4]
0287A: 002d     cmp     r5, #0
0287C: f6d1     bne     #0x286c
0287E: 01e0     b       #0x2884
02880: fff7beff bl      #0x2800
02884: 70bd     pop     {r4, r5, r6, pc}
02886: c046     mov     r8, r8
02888: 203c     subs    r4, #0x20
0288A: 0000     movs    r0, r0
0288C: f001     lsls    r0, r6, #7
0288E: 0020     movs    r0, #0
02890: 3c01     lsls    r4, r7, #4
02892: 0020     movs    r0, #0
02894: 6c3c     subs    r4, #0x6c
02896: 0000     movs    r0, r0
02898: f8b5     push    {r3, r4, r5, r6, r7, lr}
0289A: 2424     movs    r4, #0x24
0289C: 134d     ldr     r5, [pc, #0x4c]
0289E: 144f     ldr     r7, [pc, #0x50]
028A0: 2b78     ldrb    r3, [r5]
028A2: 144e     ldr     r6, [pc, #0x50]
028A4: 6343     muls    r3, r4, r3
028A6: fb18     adds    r3, r7, r3
028A8: 5868     ldr     r0, [r3, #4]
028AA: 0023     movs    r3, #0
028AC: 3370     strb    r3, [r6]
028AE: 2a78     ldrb    r2, [r5]
028B0: 3178     ldrb    r1, [r6]
028B2: 6243     muls    r2, r4, r2
028B4: 0e33     adds    r3, #0xe
028B6: 4b43     muls    r3, r1, r3
028B8: ba18     adds    r2, r7, r2
028BA: 9268     ldr     r2, [r2, #8]
028BC: d318     adds    r3, r2, r3
028BE: 0e4a     ldr     r2, [pc, #0x38]
028C0: 1360     str     r3, [r2]
028C2: fff7fffe bl      #0x26c4
028C6: 2b78     ldrb    r3, [r5]
028C8: 0c48     ldr     r0, [pc, #0x30]
028CA: 5c43     muls    r4, r3, r4
028CC: 3c19     adds    r4, r7, r4
028CE: a38a     ldrh    r3, [r4, #0x14]
028D0: 5b07     lsls    r3, r3, #0x1d
028D2: 00d4     bmi     #0x28d6
028D4: 0a48     ldr     r0, [pc, #0x28]
028D6: 00f0effc bl      #0x32b8
028DA: 2878     ldrb    r0, [r5]
028DC: 3178     ldrb    r1, [r6]
028DE: c0b2     uxtb    r0, r0
028E0: c9b2     uxtb    r1, r1
028E2: fff7a7ff bl      #0x2834
028E6: fff77dff bl      #0x27e4
028EA: f8bd     pop     {r3, r4, r5, r6, r7, pc}
028EC: 3901     lsls    r1, r7, #4
028EE: 0020     movs    r0, #0
028F0: 203c     subs    r4, #0x20
028F2: 0000     movs    r0, r0
028F4: 4401     lsls    r4, r0, #5
028F6: 0020     movs    r0, #0
028F8: ec01     lsls    r4, r5, #7
028FA: 0020     movs    r0, #0
028FC: 3938     subs    r0, #0x39
028FE: 0000     movs    r0, r0
02900: e137     adds    r7, #0xe1
02902: 0000     movs    r0, r0
02904: 0f22     movs    r2, #0xf
02906: 70b5     push    {r4, r5, r6, lr}
02908: 0168     ldr     r1, [r0]
0290A: 857e     ldrb    r5, [r0, #0x1a]
0290C: 0400     movs    r4, r0
0290E: 007e     ldrb    r0, [r0, #0x18]
02910: 0b68     ldr     r3, [r1]
02912: 8240     lsls    r2, r0
02914: 9343     bics    r3, r2
02916: 0b60     str     r3, [r1]
02918: 00f0d8fe bl      #0x36cc
0291C: 0722     movs    r2, #7
0291E: aa40     lsls    r2, r5
02920: 6168     ldr     r1, [r4, #4]
02922: 0b68     ldr     r3, [r1]
02924: 9343     bics    r3, r2
02926: 1a00     movs    r2, r3
02928: 0623     movs    r3, #6
0292A: ab40     lsls    r3, r5
0292C: 1343     orrs    r3, r2
0292E: 0b60     str     r3, [r1]
02930: 00f0d0fe bl      #0x36d4
02934: 0122     movs    r2, #1
02936: 607e     ldrb    r0, [r4, #0x19]
02938: a168     ldr     r1, [r4, #8]
0293A: 8240     lsls    r2, r0
0293C: 0b68     ldr     r3, [r1]
0293E: 9343     bics    r3, r2
02940: 0b60     str     r3, [r1]
02942: 70bd     pop     {r4, r5, r6, pc}
02944: 70b5     push    {r4, r5, r6, lr}
02946: 114d     ldr     r5, [pc, #0x44]
02948: 2b78     ldrb    r3, [r5]
0294A: 012b     cmp     r3, #1
0294C: 1dd1     bne     #0x298a
0294E: 104b     ldr     r3, [pc, #0x40]
02950: 104c     ldr     r4, [pc, #0x40]
02952: 1b68     ldr     r3, [r3]
02954: 9b8a     ldrh    r3, [r3, #0x14]
02956: 5b07     lsls    r3, r3, #0x1d
02958: 12d5     bpl     #0x2980
0295A: 0f4b     ldr     r3, [pc, #0x3c]
0295C: 1b68     ldr     r3, [r3]
0295E: 1a88     ldrh    r2, [r3]
02960: 9e78     ldrb    r6, [r3, #2]
02962: 1c23     movs    r3, #0x1c
02964: 5343     muls    r3, r2, r3
02966: 0d4a     ldr     r2, [pc, #0x34]
02968: 9b18     adds    r3, r3, r2
0296A: 2360     str     r3, [r4]
0296C: 2068     ldr     r0, [r4]
0296E: fff7c9ff bl      #0x2904
02972: 2368     ldr     r3, [r4]
02974: 013e     subs    r6, #1
02976: 1c33     adds    r3, #0x1c
02978: 2360     str     r3, [r4]
0297A: 002e     cmp     r6, #0
0297C: f6d1     bne     #0x296c
0297E: 02e0     b       #0x2986
02980: 2068     ldr     r0, [r4]
02982: fff7bfff bl      #0x2904
02986: 0023     movs    r3, #0
02988: 2b70     strb    r3, [r5]
0298A: 70bd     pop     {r4, r5, r6, pc}
0298C: 4501     lsls    r5, r0, #5
0298E: 0020     movs    r0, #0
02990: 4001     lsls    r0, r0, #5
02992: 0020     movs    r0, #0
02994: f001     lsls    r0, r6, #7
02996: 0020     movs    r0, #0
02998: 3c01     lsls    r4, r7, #4
0299A: 0020     movs    r0, #0
0299C: 6c3c     subs    r4, #0x6c
0299E: 0000     movs    r0, r0
029A0: f8b5     push    {r3, r4, r5, r6, r7, lr}
029A2: 2424     movs    r4, #0x24
029A4: 2300     movs    r3, r4
029A6: 0700     movs    r7, r0
029A8: 4343     muls    r3, r0, r3
029AA: 0d4d     ldr     r5, [pc, #0x34]
029AC: ffb2     uxtb    r7, r7
029AE: eb18     adds    r3, r5, r3
029B0: 5e68     ldr     r6, [r3, #4]
029B2: fff7c7ff bl      #0x2944
029B6: 0b4b     ldr     r3, [pc, #0x2c]
029B8: 1f70     strb    r7, [r3]
029BA: 1a78     ldrb    r2, [r3]
029BC: 1b78     ldrb    r3, [r3]
029BE: 5443     muls    r4, r2, r4
029C0: 094a     ldr     r2, [pc, #0x24]
029C2: 6159     ldr     r1, [r4, r5]
029C4: 1160     str     r1, [r2]
029C6: 7f22     movs    r2, #0x7f
029C8: 0849     ldr     r1, [pc, #0x20]
029CA: 8868     ldr     r0, [r1, #8]
029CC: 9043     bics    r0, r2
029CE: 0343     orrs    r3, r0
029D0: 3000     movs    r0, r6
029D2: 8b60     str     r3, [r1, #8]
029D4: fff7a8fe bl      #0x2728
029D8: fff794fe bl      #0x2704
029DC: f8bd     pop     {r3, r4, r5, r6, r7, pc}
029DE: c046     mov     r8, r8
029E0: 203c     subs    r4, #0x20
029E2: 0000     movs    r0, r0
029E4: 3901     lsls    r1, r7, #4
029E6: 0020     movs    r0, #0
029E8: f001     lsls    r0, r6, #7
029EA: 0020     movs    r0, #0
029EC: 7401     lsls    r4, r6, #5
029EE: 0020     movs    r0, #0
029F0: f7b5     push    {r0, r1, r2, r4, r5, r6, r7, lr}
029F2: 2424     movs    r4, #0x24
029F4: 4443     muls    r4, r0, r4
029F6: 164f     ldr     r7, [pc, #0x58]
029F8: 0091     str     r1, [sp]
029FA: 3c19     adds    r4, r7, r4
029FC: 6368     ldr     r3, [r4, #4]
029FE: 154d     ldr     r5, [pc, #0x54]
02A00: 0193     str     r3, [sp, #4]
02A02: 6b46     mov     r3, sp
02A04: 1b78     ldrb    r3, [r3]
02A06: 0600     movs    r6, r0
02A08: 2b70     strb    r3, [r5]
02A0A: 0e23     movs    r3, #0xe
02A0C: 2a78     ldrb    r2, [r5]
02A0E: 5343     muls    r3, r2, r3
02A10: a268     ldr     r2, [r4, #8]
02A12: d318     adds    r3, r2, r3
02A14: 104a     ldr     r2, [pc, #0x40]
02A16: 1360     str     r3, [r2]
02A18: fff7c2ff bl      #0x29a0
02A1C: 0198     ldr     r0, [sp, #4]
02A1E: fff751fe bl      #0x26c4
02A22: 0e4b     ldr     r3, [pc, #0x38]
02A24: 3000     movs    r0, r6
02A26: 0099     ldr     r1, [sp]
02A28: 1c60     str     r4, [r3]
02A2A: fff703ff bl      #0x2834
02A2E: 2421     movs    r1, #0x24
02A30: 0b4b     ldr     r3, [pc, #0x2c]
02A32: 0c48     ldr     r0, [pc, #0x30]
02A34: 1a78     ldrb    r2, [r3]
02A36: 2b78     ldrb    r3, [r5]
02A38: 4a43     muls    r2, r1, r2
02A3A: d259     ldr     r2, [r2, r7]
02A3C: 9b00     lsls    r3, r3, #2
02A3E: d318     adds    r3, r2, r3
02A40: 094a     ldr     r2, [pc, #0x24]
02A42: 1360     str     r3, [r2]
02A44: 0122     movs    r2, #1
02A46: 094b     ldr     r3, [pc, #0x24]
02A48: 1a70     strb    r2, [r3]
02A4A: 00f035fc bl      #0x32b8
02A4E: f7bd     pop     {r0, r1, r2, r4, r5, r6, r7, pc}
02A50: 203c     subs    r4, #0x20
02A52: 0000     movs    r0, r0
02A54: 4401     lsls    r4, r0, #5
02A56: 0020     movs    r0, #0
02A58: ec01     lsls    r4, r5, #7
02A5A: 0020     movs    r0, #0
02A5C: 4001     lsls    r0, r0, #5
02A5E: 0020     movs    r0, #0
02A60: 3901     lsls    r1, r7, #4
02A62: 0020     movs    r0, #0
02A64: 9d37     adds    r7, #0x9d
02A66: 0000     movs    r0, r0
02A68: 3c01     lsls    r4, r7, #4
02A6A: 0020     movs    r0, #0
02A6C: 4501     lsls    r5, r0, #5
02A6E: 0020     movs    r0, #0
02A70: 2422     movs    r2, #0x24
02A72: 1300     movs    r3, r2
02A74: 083a     subs    r2, #8
02A76: 4343     muls    r3, r0, r3
02A78: 1000     movs    r0, r2
02A7A: 70b5     push    {r4, r5, r6, lr}
02A7C: 4843     muls    r0, r1, r0
02A7E: 114d     ldr     r5, [pc, #0x44]
02A80: 5c59     ldr     r4, [r3, r5]
02A82: eb18     adds    r3, r5, r3
02A84: 2018     adds    r0, r4, r0
02A86: 9b8a     ldrh    r3, [r3, #0x14]
02A88: 0f4c     ldr     r4, [pc, #0x3c]
02A8A: 2060     str     r0, [r4]
02A8C: 5b07     lsls    r3, r3, #0x1d
02A8E: 15d5     bpl     #0x2abc
02A90: 1823     movs    r3, #0x18
02A92: 5b42     rsbs    r3, r3, #0
02A94: 5943     muls    r1, r3, r1
02A96: 0d4b     ldr     r3, [pc, #0x34]
02A98: 4018     adds    r0, r0, r1
02A9A: 1860     str     r0, [r3]
02A9C: 0388     ldrh    r3, [r0]
02A9E: 8578     ldrb    r5, [r0, #2]
02AA0: 5a43     muls    r2, r3, r2
02AA2: 0b4b     ldr     r3, [pc, #0x2c]
02AA4: d218     adds    r2, r2, r3
02AA6: 2260     str     r2, [r4]
02AA8: 2068     ldr     r0, [r4]
02AAA: fff72bff bl      #0x2904
02AAE: 2368     ldr     r3, [r4]
02AB0: 013d     subs    r5, #1
02AB2: 1c33     adds    r3, #0x1c
02AB4: 2360     str     r3, [r4]
02AB6: 002d     cmp     r5, #0
02AB8: f6d1     bne     #0x2aa8
02ABA: 01e0     b       #0x2ac0
02ABC: fff722ff bl      #0x2904
02AC0: 70bd     pop     {r4, r5, r6, pc}
02AC2: c046     mov     r8, r8
02AC4: 203c     subs    r4, #0x20
02AC6: 0000     movs    r0, r0
02AC8: f001     lsls    r0, r6, #7
02ACA: 0020     movs    r0, #0
02ACC: 3c01     lsls    r4, r7, #4
02ACE: 0020     movs    r0, #0
02AD0: 6c3c     subs    r4, #0x6c
02AD2: 0000     movs    r0, r0
02AD4: 044a     ldr     r2, [pc, #0x10]
02AD6: 054b     ldr     r3, [pc, #0x14]
02AD8: 1168     ldr     r1, [r2]
02ADA: 0b40     ands    r3, r1
02ADC: 8021     movs    r1, #0x80
02ADE: 8900     lsls    r1, r1, #2
02AE0: 0b43     orrs    r3, r1
02AE2: 1360     str     r3, [r2]
02AE4: 7047     bx      lr
02AE6: c046     mov     r8, r8
02AE8: 0800     movs    r0, r1
02AEA: 0840     ands    r0, r1
02AEC: fffcfffc ldc2l   p12, c15, [pc], #0x3fc
02AF0: f0b5     push    {r4, r5, r6, r7, lr}
02AF2: 0125     movs    r5, #1
02AF4: 2424     movs    r4, #0x24
02AF6: 0300     movs    r3, r0
02AF8: 89b0     sub     sp, #0x24
02AFA: 0490     str     r0, [sp, #0x10]
02AFC: 2800     movs    r0, r5
02AFE: 6343     muls    r3, r4, r3
02B00: 634a     ldr     r2, [pc, #0x18c]
02B02: 0691     str     r1, [sp, #0x18]
02B04: d318     adds    r3, r2, r3
02B06: 5e68     ldr     r6, [r3, #4]
02B08: 3388     ldrh    r3, [r6]
02B0A: 9840     lsls    r0, r3
02B0C: 0138     subs    r0, #1
02B0E: 4843     muls    r0, r1, r0
02B10: 6421     movs    r1, #0x64
02B12: 00f0bffe bl      #0x3894
02B16: 6b46     mov     r3, sp
02B18: 1a7c     ldrb    r2, [r3, #0x10]
02B1A: 5e4b     ldr     r3, [pc, #0x178]
02B1C: 0700     movs    r7, r0
02B1E: 5e48     ldr     r0, [pc, #0x178]
02B20: 1a70     strb    r2, [r3]
02B22: 00f0c9fb bl      #0x32b8
02B26: 0023     movs    r3, #0
02B28: 5c4a     ldr     r2, [pc, #0x170]
02B2A: 0195     str     r5, [sp, #4]
02B2C: 1370     strb    r3, [r2]
02B2E: 0293     str     r3, [sp, #8]
02B30: 0794     str     r4, [sp, #0x1c]
02B32: 049b     ldr     r3, [sp, #0x10]
02B34: 079d     ldr     r5, [sp, #0x1c]
02B36: 5649     ldr     r1, [pc, #0x158]
02B38: 5d43     muls    r5, r3, r5
02B3A: 4d19     adds    r5, r1, r5
02B3C: 6b7e     ldrb    r3, [r5, #0x19]
02B3E: 574a     ldr     r2, [pc, #0x15c]
02B40: 0393     str     r3, [sp, #0xc]
02B42: 0398     ldr     r0, [sp, #0xc]
02B44: 1378     ldrb    r3, [r2]
02B46: 9842     cmp     r0, r3
02B48: 6dd9     bls     #0x2c26
02B4A: 5248     ldr     r0, [pc, #0x148]
02B4C: 079c     ldr     r4, [sp, #0x1c]
02B4E: 0378     ldrb    r3, [r0]
02B50: 0078     ldrb    r0, [r0]
02B52: 6343     muls    r3, r4, r3
02B54: cb18     adds    r3, r1, r3
02B56: 5b68     ldr     r3, [r3, #4]
02B58: 1178     ldrb    r1, [r2]
02B5A: 0593     str     r3, [sp, #0x14]
02B5C: 8023     movs    r3, #0x80
02B5E: c0b2     uxtb    r0, r0
02B60: b372     strb    r3, [r6, #0xa]
02B62: c9b2     uxtb    r1, r1
02B64: fff744ff bl      #0x29f0
02B68: 0824     movs    r4, #8
02B6A: fff7b3ff bl      #0x2ad4
02B6E: 8025     movs    r5, #0x80
02B70: fff738fe bl      #0x27e4
02B74: 4a4b     ldr     r3, [pc, #0x128]
02B76: 4b49     ldr     r1, [pc, #0x12c]
02B78: 0a7a     ldrb    r2, [r1, #8]
02B7A: 52b2     sxtb    r2, r2
02B7C: 002a     cmp     r2, #0
02B7E: 02da     bge     #0x2b86
02B80: 013b     subs    r3, #1
02B82: 002b     cmp     r3, #0
02B84: f8d1     bne     #0x2b78
02B86: 484b     ldr     r3, [pc, #0x120]
02B88: 1b68     ldr     r3, [r3]
02B8A: 1b88     ldrh    r3, [r3]
02B8C: 0393     str     r3, [sp, #0xc]
02B8E: 9f42     cmp     r7, r3
02B90: 02d9     bls     #0x2b98
02B92: b37a     ldrb    r3, [r6, #0xa]
02B94: ab43     bics    r3, r5
02B96: b372     strb    r3, [r6, #0xa]
02B98: b37a     ldrb    r3, [r6, #0xa]
02B9A: 6d08     lsrs    r5, r5, #1
02B9C: 2b43     orrs    r3, r5
02B9E: b372     strb    r3, [r6, #0xa]
02BA0: 0598     ldr     r0, [sp, #0x14]
02BA2: 013c     subs    r4, #1
02BA4: fff78efd bl      #0x26c4
02BA8: 002c     cmp     r4, #0
02BAA: e1d1     bne     #0x2b70
02BAC: 394b     ldr     r3, [pc, #0xe4]
02BAE: 1878     ldrb    r0, [r3]
02BB0: 3a4b     ldr     r3, [pc, #0xe8]
02BB2: c0b2     uxtb    r0, r0
02BB4: 1978     ldrb    r1, [r3]
02BB6: c9b2     uxtb    r1, r1
02BB8: fff75aff bl      #0x2a70
02BBC: 3b4b     ldr     r3, [pc, #0xec]
02BBE: 3c4a     ldr     r2, [pc, #0xf0]
02BC0: 1c70     strb    r4, [r3]
02BC2: 3c4b     ldr     r3, [pc, #0xf0]
02BC4: 0134     adds    r4, #1
02BC6: 1a60     str     r2, [r3]
02BC8: 059b     ldr     r3, [sp, #0x14]
02BCA: 0a20     movs    r0, #0xa
02BCC: 1b88     ldrh    r3, [r3]
02BCE: 6421     movs    r1, #0x64
02BD0: 9c40     lsls    r4, r3
02BD2: 013c     subs    r4, #1
02BD4: 6043     muls    r0, r4, r0
02BD6: 00f05dfe bl      #0x3894
02BDA: 0130     adds    r0, #1
02BDC: 8742     cmp     r7, r0
02BDE: 04d3     blo     #0x2bea
02BE0: 0399     ldr     r1, [sp, #0xc]
02BE2: 3a1a     subs    r2, r7, r0
02BE4: 0623     movs    r3, #6
02BE6: 9142     cmp     r1, r2
02BE8: 08d3     blo     #0x2bfc
02BEA: 3818     adds    r0, r7, r0
02BEC: 8442     cmp     r4, r0
02BEE: 00d9     bls     #0x2bf2
02BF0: 0400     movs    r4, r0
02BF2: 039a     ldr     r2, [sp, #0xc]
02BF4: 0023     movs    r3, #0
02BF6: 9442     cmp     r4, r2
02BF8: 00d2     bhs     #0x2bfc
02BFA: 0633     adds    r3, #6
02BFC: b27a     ldrb    r2, [r6, #0xa]
02BFE: 0198     ldr     r0, [sp, #4]
02C00: 111c     adds    r1, r2, #0
02C02: 8242     cmp     r2, r0
02C04: 01d2     bhs     #0x2c0a
02C06: 6946     mov     r1, sp
02C08: 0979     ldrb    r1, [r1, #4]
02C0A: c9b2     uxtb    r1, r1
02C0C: 0191     str     r1, [sp, #4]
02C0E: 2649     ldr     r1, [pc, #0x98]
02C10: 0968     ldr     r1, [r1]
02C12: 0a73     strb    r2, [r1, #0xc]
02C14: 029a     ldr     r2, [sp, #8]
02C16: 1a43     orrs    r2, r3
02C18: 0292     str     r2, [sp, #8]
02C1A: 204a     ldr     r2, [pc, #0x80]
02C1C: 1378     ldrb    r3, [r2]
02C1E: 0133     adds    r3, #1
02C20: dbb2     uxtb    r3, r3
02C22: 1370     strb    r3, [r2]
02C24: 85e7     b       #0x2b32
02C26: 019b     ldr     r3, [sp, #4]
02C28: 0e27     movs    r7, #0xe
02C2A: 0133     adds    r3, #1
02C2C: 5b08     lsrs    r3, r3, #1
02C2E: b372     strb    r3, [r6, #0xa]
02C30: 0023     movs    r3, #0
02C32: 1370     strb    r3, [r2]
02C34: 1c4a     ldr     r2, [pc, #0x70]
02C36: 1468     ldr     r4, [r2]
02C38: 184a     ldr     r2, [pc, #0x60]
02C3A: 0399     ldr     r1, [sp, #0xc]
02C3C: 1078     ldrb    r0, [r2]
02C3E: 9446     mov     ip, r2
02C40: 8142     cmp     r1, r0
02C42: 1ad9     bls     #0x2c7a
02C44: 1478     ldrb    r4, [r2]
02C46: ab68     ldr     r3, [r5, #8]
02C48: 7c43     muls    r4, r7, r4
02C4A: 1c19     adds    r4, r3, r4
02C4C: 237b     ldrb    r3, [r4, #0xc]
02C4E: b07a     ldrb    r0, [r6, #0xa]
02C50: 8342     cmp     r3, r0
02C52: 09d3     blo     #0x2c68
02C54: 181a     subs    r0, r3, r0
02C56: 069b     ldr     r3, [sp, #0x18]
02C58: c0b2     uxtb    r0, r0
02C5A: 5843     muls    r0, r3, r0
02C5C: 6421     movs    r1, #0x64
02C5E: 6330     adds    r0, #0x63
02C60: 00f018fe bl      #0x3894
02C64: 2073     strb    r0, [r4, #0xc]
02C66: 01e0     b       #0x2c6c
02C68: 0023     movs    r3, #0
02C6A: 2373     strb    r3, [r4, #0xc]
02C6C: 0b4a     ldr     r2, [pc, #0x2c]
02C6E: 1378     ldrb    r3, [r2]
02C70: 0133     adds    r3, #1
02C72: dbb2     uxtb    r3, r3
02C74: 1370     strb    r3, [r2]
02C76: 0123     movs    r3, #1
02C78: dee7     b       #0x2c38
02C7A: 002b     cmp     r3, #0
02C7C: 01d0     beq     #0x2c82
02C7E: 0a4b     ldr     r3, [pc, #0x28]
02C80: 1c60     str     r4, [r3]
02C82: 0023     movs    r3, #0
02C84: 6246     mov     r2, ip
02C86: 0298     ldr     r0, [sp, #8]
02C88: 1370     strb    r3, [r2]
02C8A: 09b0     add     sp, #0x24
02C8C: f0bd     pop     {r4, r5, r6, r7, pc}
02C8E: c046     mov     r8, r8
02C90: 203c     subs    r4, #0x20
02C92: 0000     movs    r0, r0
02C94: 3901     lsls    r1, r7, #4
02C96: 0020     movs    r0, #0
02C98: 9d37     adds    r7, #0x9d
02C9A: 0000     movs    r0, r0
02C9C: 4401     lsls    r4, r0, #5
02C9E: 0020     movs    r0, #0
02CA0: 3433     adds    r3, #0x34
02CA2: 0000     movs    r0, r0
02CA4: 7401     lsls    r4, r6, #5
02CA6: 0020     movs    r0, #0
02CA8: ec01     lsls    r4, r5, #7
02CAA: 0020     movs    r0, #0
02CAC: 4501     lsls    r5, r0, #5
02CAE: 0020     movs    r0, #0
02CB0: 0002     lsls    r0, r0, #8
02CB2: 0001     lsls    r0, r0, #4
02CB4: 0800     movs    r0, r1
02CB6: 0840     ands    r0, r1
02CB8: 0023     movs    r3, #0
02CBA: f0b5     push    {r4, r5, r6, r7, lr}
02CBC: 85b0     sub     sp, #0x14
02CBE: 0392     str     r2, [sp, #0xc]
02CC0: 234a     ldr     r2, [pc, #0x8c]
02CC2: 0400     movs    r4, r0
02CC4: 1370     strb    r3, [r2]
02CC6: 5278     ldrb    r2, [r2, #1]
02CC8: 0500     movs    r5, r0
02CCA: 0292     str     r2, [sp, #8]
02CCC: 9c46     mov     ip, r3
02CCE: 1f00     movs    r7, r3
02CD0: 1a00     movs    r2, r3
02CD2: 1800     movs    r0, r3
02CD4: 0191     str     r1, [sp, #4]
02CD6: 0199     ldr     r1, [sp, #4]
02CD8: 8842     cmp     r0, r1
02CDA: 0ed0     beq     #0x2cfa
02CDC: ee88     ldrh    r6, [r5, #6]
02CDE: 0399     ldr     r1, [sp, #0xc]
02CE0: 8e42     cmp     r6, r1
02CE2: 07d9     bls     #0x2cf4
02CE4: b242     cmp     r2, r6
02CE6: 05d2     bhs     #0x2cf4
02CE8: c3b2     uxtb    r3, r0
02CEA: 0293     str     r3, [sp, #8]
02CEC: 0123     movs    r3, #1
02CEE: 3200     movs    r2, r6
02CF0: 9c46     mov     ip, r3
02CF2: 1f00     movs    r7, r3
02CF4: 0e35     adds    r5, #0xe
02CF6: 0130     adds    r0, #1
02CF8: ede7     b       #0x2cd6
02CFA: 154a     ldr     r2, [pc, #0x54]
02CFC: 002f     cmp     r7, #0
02CFE: 02d0     beq     #0x2d06
02D00: 6946     mov     r1, sp
02D02: 097a     ldrb    r1, [r1, #8]
02D04: 5170     strb    r1, [r2, #1]
02D06: 002b     cmp     r3, #0
02D08: 01d0     beq     #0x2d0e
02D0A: 6346     mov     r3, ip
02D0C: 1370     strb    r3, [r2]
02D0E: 1078     ldrb    r0, [r2]
02D10: 0028     cmp     r0, #0
02D12: 1bd0     beq     #0x2d4c
02D14: 0e23     movs    r3, #0xe
02D16: 1d00     movs    r5, r3
02D18: 5778     ldrb    r7, [r2, #1]
02D1A: 961c     adds    r6, r2, #2
02D1C: 7d43     muls    r5, r7, r5
02D1E: 6519     adds    r5, r4, r5
02D20: e988     ldrh    r1, [r5, #6]
02D22: 7180     strh    r1, [r6, #2]
02D24: 0199     ldr     r1, [sp, #4]
02D26: 002f     cmp     r7, #0
02D28: 05d1     bne     #0x2d36
02D2A: 5943     muls    r1, r3, r1
02D2C: 6418     adds    r4, r4, r1
02D2E: 0e3c     subs    r4, #0xe
02D30: e388     ldrh    r3, [r4, #6]
02D32: 5380     strh    r3, [r2, #2]
02D34: 08e0     b       #0x2d48
02D36: 2b00     movs    r3, r5
02D38: 0e3b     subs    r3, #0xe
02D3A: db88     ldrh    r3, [r3, #6]
02D3C: 0139     subs    r1, #1
02D3E: 5380     strh    r3, [r2, #2]
02D40: 8f42     cmp     r7, r1
02D42: 01d1     bne     #0x2d48
02D44: e388     ldrh    r3, [r4, #6]
02D46: 00e0     b       #0x2d4a
02D48: ab8a     ldrh    r3, [r5, #0x14]
02D4A: b380     strh    r3, [r6, #4]
02D4C: 05b0     add     sp, #0x14
02D4E: f0bd     pop     {r4, r5, r6, r7, pc}
02D50: 4601     lsls    r6, r0, #5
02D52: 0020     movs    r0, #0
02D54: f0b5     push    {r4, r5, r6, r7, lr}
02D56: 0025     movs    r5, #0
02D58: 174b     ldr     r3, [pc, #0x5c]
02D5A: 85b0     sub     sp, #0x14
02D5C: 0f00     movs    r7, r1
02D5E: 9c1c     adds    r4, r3, #2
02D60: 1978     ldrb    r1, [r3]
02D62: 0133     adds    r3, #1
02D64: 0293     str     r3, [sp, #8]
02D66: 531e     subs    r3, r2, #1
02D68: 0190     str     r0, [sp, #4]
02D6A: 0091     str     r1, [sp]
02D6C: 0393     str     r3, [sp, #0xc]
02D6E: 009b     ldr     r3, [sp]
02D70: 9d42     cmp     r5, r3
02D72: 1dd2     bhs     #0x2db0
02D74: 029b     ldr     r3, [sp, #8]
02D76: ee5c     ldrb    r6, [r5, r3]
02D78: 002e     cmp     r6, #0
02D7A: 01d1     bne     #0x2d80
02D7C: 2680     strh    r6, [r4]
02D7E: 04e0     b       #0x2d8a
02D80: 039b     ldr     r3, [sp, #0xc]
02D82: 9e42     cmp     r6, r3
02D84: 01d1     bne     #0x2d8a
02D86: 0023     movs    r3, #0
02D88: a380     strh    r3, [r4, #4]
02D8A: a388     ldrh    r3, [r4, #4]
02D8C: 6288     ldrh    r2, [r4, #2]
02D8E: 2188     ldrh    r1, [r4]
02D90: 7e43     muls    r6, r7, r6
02D92: 581a     subs    r0, r3, r1
02D94: 5118     adds    r1, r2, r1
02D96: c918     adds    r1, r1, r3
02D98: 7843     muls    r0, r7, r0
02D9A: 00f005fe bl      #0x39a8
02D9E: 3018     adds    r0, r6, r0
02DA0: 7f30     adds    r0, #0x7f
02DA2: 019a     ldr     r2, [sp, #4]
02DA4: 6b00     lsls    r3, r5, #1
02DA6: 000a     lsrs    r0, r0, #8
02DA8: d052     strh    r0, [r2, r3]
02DAA: 0135     adds    r5, #1
02DAC: 0634     adds    r4, #6
02DAE: dee7     b       #0x2d6e
02DB0: 1800     movs    r0, r3
02DB2: 05b0     add     sp, #0x14
02DB4: f0bd     pop     {r4, r5, r6, r7, pc}
02DB6: c046     mov     r8, r8
02DB8: 4601     lsls    r6, r0, #5
02DBA: 0020     movs    r0, #0
02DBC: 8021     movs    r1, #0x80
02DBE: 054a     ldr     r2, [pc, #0x14]
02DC0: 10b5     push    {r4, lr}
02DC2: 1368     ldr     r3, [r2]
02DC4: 0906     lsls    r1, r1, #0x18
02DC6: 0b43     orrs    r3, r1
02DC8: 1360     str     r3, [r2]
02DCA: 0520     movs    r0, #5
02DCC: 00f00efb bl      #0x33ec
02DD0: 10bd     pop     {r4, pc}
02DD2: c046     mov     r8, r8
02DD4: 0000     movs    r0, r0
02DD6: 0640     ands    r6, r0
02DD8: 10b5     push    {r4, lr}
02DDA: 054c     ldr     r4, [pc, #0x14]
02DDC: 2378     ldrb    r3, [r4]
02DDE: 002b     cmp     r3, #0
02DE0: 03d1     bne     #0x2dea
02DE2: 00f02df8 bl      #0x2e40
02DE6: 0123     movs    r3, #1
02DE8: 2370     strb    r3, [r4]
02DEA: fff7e7ff bl      #0x2dbc
02DEE: 10bd     pop     {r4, pc}
02DF0: 5001     lsls    r0, r2, #5
02DF2: 0020     movs    r0, #0
02DF4: 8020     movs    r0, #0x80
02DF6: 0a4b     ldr     r3, [pc, #0x28]
02DF8: 4000     lsls    r0, r0, #1
02DFA: 1a68     ldr     r2, [r3]
02DFC: 0242     tst     r2, r0
02DFE: 0ad0     beq     #0x2e16
02E00: 084a     ldr     r2, [pc, #0x20]
02E02: 1268     ldr     r2, [r2]
02E04: 5204     lsls    r2, r2, #0x11
02E06: 06d4     bmi     #0x2e16
02E08: 1a68     ldr     r2, [r3]
02E0A: 0749     ldr     r1, [pc, #0x1c]
02E0C: 1140     ands    r1, r2
02E0E: 1960     str     r1, [r3]
02E10: 1a68     ldr     r2, [r3]
02E12: 0243     orrs    r2, r0
02E14: 1a60     str     r2, [r3]
02E16: 0222     movs    r2, #2
02E18: 044b     ldr     r3, [pc, #0x10]
02E1A: 1a60     str     r2, [r3]
02E1C: 7047     bx      lr
02E1E: c046     mov     r8, r8
02E20: 0000     movs    r0, r0
02E22: 0640     ands    r6, r0
02E24: 6000     lsls    r0, r4, #1
02E26: 0640     ands    r6, r0
02E28: fffeffff mrc2    p15, #7, apsr_nzcv, c15, c15, #7
02E2C: 6c00     lsls    r4, r5, #1
02E2E: 0640     ands    r6, r0
02E30: 10b5     push    {r4, lr}
02E32: 00f08ff8 bl      #0x2f54
02E36: 10bd     pop     {r4, pc}
02E38: 10b5     push    {r4, lr}
02E3A: 00f095f8 bl      #0x2f68
02E3E: 10bd     pop     {r4, pc}
02E40: 8022     movs    r2, #0x80
02E42: 10b5     push    {r4, lr}
02E44: 0024     movs    r4, #0
02E46: 1a4b     ldr     r3, [pc, #0x68]
02E48: 5200     lsls    r2, r2, #1
02E4A: 1a60     str     r2, [r3]
02E4C: 194a     ldr     r2, [pc, #0x64]
02E4E: 1a4b     ldr     r3, [pc, #0x68]
02E50: 1a49     ldr     r1, [pc, #0x68]
02E52: 1a60     str     r2, [r3]
02E54: 1a4b     ldr     r3, [pc, #0x68]
02E56: 1b4a     ldr     r2, [pc, #0x6c]
02E58: 0520     movs    r0, #5
02E5A: 1360     str     r3, [r2]
02E5C: 1a4a     ldr     r2, [pc, #0x68]
02E5E: 1460     str     r4, [r2]
02E60: 1a4a     ldr     r2, [pc, #0x68]
02E62: 1160     str     r1, [r2]
02E64: 1a4a     ldr     r2, [pc, #0x68]
02E66: 1360     str     r3, [r2]
02E68: 1a4b     ldr     r3, [pc, #0x68]
02E6A: 1c60     str     r4, [r3]
02E6C: 00f0c8fa bl      #0x3400
02E70: 0321     movs    r1, #3
02E72: 0520     movs    r0, #5
02E74: 00f0a0fa bl      #0x33b8
02E78: 1749     ldr     r1, [pc, #0x5c]
02E7A: 0520     movs    r0, #5
02E7C: 00f094fa bl      #0x33a8
02E80: 5222     movs    r2, #0x52
02E82: 164b     ldr     r3, [pc, #0x58]
02E84: ff32     adds    r2, #0xff
02E86: 1c60     str     r4, [r3]
02E88: 154b     ldr     r3, [pc, #0x54]
02E8A: 1a60     str     r2, [r3]
02E8C: 154b     ldr     r3, [pc, #0x54]
02E8E: 503a     subs    r2, #0x50
02E90: 1c60     str     r4, [r3]
02E92: 154b     ldr     r3, [pc, #0x54]
02E94: ff3a     subs    r2, #0xff
02E96: 1c60     str     r4, [r3]
02E98: 144b     ldr     r3, [pc, #0x50]
02E9A: 1c60     str     r4, [r3]
02E9C: 144b     ldr     r3, [pc, #0x50]
02E9E: 1a70     strb    r2, [r3]
02EA0: 144b     ldr     r3, [pc, #0x50]
02EA2: 1c70     strb    r4, [r3]
02EA4: 144b     ldr     r3, [pc, #0x50]
02EA6: 1c80     strh    r4, [r3]
02EA8: 144b     ldr     r3, [pc, #0x50]
02EAA: 1c80     strh    r4, [r3]
02EAC: 10bd     pop     {r4, pc}
02EAE: c046     mov     r8, r8
02EB0: 0000     movs    r0, r0
02EB2: 0640     ands    r6, r0
02EB4: 0008     lsrs    r0, r0, #0x20
02EB6: 0040     ands    r0, r0
02EB8: 6000     lsls    r0, r4, #1
02EBA: 0640     ands    r6, r0
02EBC: 1000     movs    r0, r2
02EBE: fe00     lsls    r6, r7, #3
02EC0: 0701     lsls    r7, r0, #4
02EC2: 0080     strh    r0, [r0]
02EC4: 0003     lsls    r0, r0, #0xc
02EC6: 0640     ands    r6, r0
02EC8: 0403     lsls    r4, r0, #0xc
02ECA: 0640     ands    r6, r0
02ECC: 1003     lsls    r0, r2, #0xc
02ECE: 0640     ands    r6, r0
02ED0: 0002     lsls    r0, r0, #8
02ED2: 0640     ands    r6, r0
02ED4: 0402     lsls    r4, r0, #8
02ED6: 0640     ands    r6, r0
02ED8: 7d2f     cmp     r7, #0x7d
02EDA: 0000     movs    r0, r0
02EDC: 880e     lsrs    r0, r1, #0x1a
02EDE: 0640     ands    r6, r0
02EE0: 480f     lsrs    r0, r1, #0x1d
02EE2: 0640     ands    r6, r0
02EE4: 080f     lsrs    r0, r1, #0x1c
02EE6: 0640     ands    r6, r0
02EE8: c80f     lsrs    r0, r1, #0x1f
02EEA: 0640     ands    r6, r0
02EEC: 880f     lsrs    r0, r1, #0x1e
02EEE: 0640     ands    r6, r0
02EF0: f801     lsls    r0, r7, #7
02EF2: 0020     movs    r0, #0
02EF4: fc01     lsls    r4, r7, #7
02EF6: 0020     movs    r0, #0
02EF8: f601     lsls    r6, r6, #7
02EFA: 0020     movs    r0, #0
02EFC: f401     lsls    r4, r6, #7
02EFE: 0020     movs    r0, #0
02F00: 10b5     push    {r4, lr}
02F02: 0520     movs    r0, #5
02F04: 00f07cfa bl      #0x3400
02F08: 1f21     movs    r1, #0x1f
02F0A: 054b     ldr     r3, [pc, #0x14]
02F0C: 0520     movs    r0, #5
02F0E: 1c78     ldrb    r4, [r3]
02F10: 1a78     ldrb    r2, [r3]
02F12: e4b2     uxtb    r4, r4
02F14: 8a43     bics    r2, r1
02F16: 1a70     strb    r2, [r3]
02F18: 00f068fa bl      #0x33ec
02F1C: 2000     movs    r0, r4
02F1E: 10bd     pop     {r4, pc}
02F20: fc01     lsls    r4, r7, #7
02F22: 0020     movs    r0, #0
02F24: 70b5     push    {r4, r5, r6, lr}
02F26: 0600     movs    r6, r0
02F28: 0d00     movs    r5, r1
02F2A: 141e     subs    r4, r2, #0
02F2C: 0bd0     beq     #0x2f46
02F2E: 0520     movs    r0, #5
02F30: 00f066fa bl      #0x3400
02F34: 044b     ldr     r3, [pc, #0x10]
02F36: 0520     movs    r0, #5
02F38: 1c60     str     r4, [r3]
02F3A: 044b     ldr     r3, [pc, #0x10]
02F3C: 1e80     strh    r6, [r3]
02F3E: 044b     ldr     r3, [pc, #0x10]
02F40: 1d80     strh    r5, [r3]
02F42: 00f053fa bl      #0x33ec
02F46: 70bd     pop     {r4, r5, r6, pc}
02F48: 0002     lsls    r0, r0, #8
02F4A: 0020     movs    r0, #0
02F4C: 0402     lsls    r4, r0, #8
02F4E: 0020     movs    r0, #0
02F50: fa01     lsls    r2, r7, #7
02F52: 0020     movs    r0, #0
02F54: 10b5     push    {r4, lr}
02F56: 00f0cff9 bl      #0x32f8
02F5A: 0122     movs    r2, #1
02F5C: 014b     ldr     r3, [pc, #4]
02F5E: 1a60     str     r2, [r3]
02F60: 10bd     pop     {r4, pc}
02F62: c046     mov     r8, r8
02F64: 880e     lsrs    r0, r1, #0x1a
02F66: 0640     ands    r6, r0
02F68: 0022     movs    r2, #0
02F6A: 10b5     push    {r4, lr}
02F6C: 024b     ldr     r3, [pc, #8]
02F6E: ff20     movs    r0, #0xff
02F70: 1a60     str     r2, [r3]
02F72: 00f0b3f9 bl      #0x32dc
02F76: 10bd     pop     {r4, pc}
02F78: 880e     lsrs    r0, r1, #0x1a
02F7A: 0640     ands    r6, r0
02F7C: f0b5     push    {r4, r5, r6, r7, lr}
02F7E: a74b     ldr     r3, [pc, #0x29c]
02F80: 85b0     sub     sp, #0x14
02F82: 1b68     ldr     r3, [r3]
02F84: 002b     cmp     r3, #0
02F86: 00d0     beq     #0x2f8a
02F88: 9847     blx     r3
02F8A: a549     ldr     r1, [pc, #0x294]
02F8C: a54a     ldr     r2, [pc, #0x294]
02F8E: 0d68     ldr     r5, [r1]
02F90: 1368     ldr     r3, [r2]
02F92: a548     ldr     r0, [pc, #0x294]
02F94: 0093     str     r3, [sp]
02F96: 0223     movs    r3, #2
02F98: ff33     adds    r3, #0xff
02F9A: 0488     ldrh    r4, [r0]
02F9C: 2b40     ands    r3, r5
02F9E: 0290     str     r0, [sp, #8]
02FA0: 0191     str     r1, [sp, #4]
02FA2: 0392     str     r2, [sp, #0xc]
02FA4: 2ed0     beq     #0x3004
02FA6: 2020     movs    r0, #0x20
02FA8: a04a     ldr     r2, [pc, #0x280]
02FAA: 1368     ldr     r3, [r2]
02FAC: 5b00     lsls    r3, r3, #1
02FAE: 5b08     lsrs    r3, r3, #1
02FB0: 1360     str     r3, [r2]
02FB2: 9f4b     ldr     r3, [pc, #0x27c]
02FB4: 1978     ldrb    r1, [r3]
02FB6: 8143     bics    r1, r0
02FB8: 1970     strb    r1, [r3]
02FBA: 1978     ldrb    r1, [r3]
02FBC: 1038     subs    r0, #0x10
02FBE: 0143     orrs    r1, r0
02FC0: 1970     strb    r1, [r3]
02FC2: 9c49     ldr     r1, [pc, #0x270]
02FC4: 0d68     ldr     r5, [r1]
02FC6: 0542     tst     r5, r0
02FC8: 06d1     bne     #0x2fd8
02FCA: 9b48     ldr     r0, [pc, #0x26c]
02FCC: 0088     ldrh    r0, [r0]
02FCE: a042     cmp     r0, r4
02FD0: 06d0     beq     #0x2fe0
02FD2: 1878     ldrb    r0, [r3]
02FD4: 0825     movs    r5, #8
02FD6: 01e0     b       #0x2fdc
02FD8: 0225     movs    r5, #2
02FDA: 1878     ldrb    r0, [r3]
02FDC: 2843     orrs    r0, r5
02FDE: 1870     strb    r0, [r3]
02FE0: 9648     ldr     r0, [pc, #0x258]
02FE2: 974b     ldr     r3, [pc, #0x25c]
02FE4: 0568     ldr     r5, [r0]
02FE6: 2b40     ands    r3, r5
02FE8: 0360     str     r3, [r0]
02FEA: 0023     movs    r3, #0
02FEC: 9548     ldr     r0, [pc, #0x254]
02FEE: 0360     str     r3, [r0]
02FF0: 0b60     str     r3, [r1]
02FF2: 0221     movs    r1, #2
02FF4: 944b     ldr     r3, [pc, #0x250]
02FF6: 1970     strb    r1, [r3]
02FF8: 8021     movs    r1, #0x80
02FFA: 1368     ldr     r3, [r2]
02FFC: 0906     lsls    r1, r1, #0x18
02FFE: 0b43     orrs    r3, r1
03000: 1360     str     r3, [r2]
03002: 07e1     b       #0x3214
03004: 009a     ldr     r2, [sp]
03006: d206     lsls    r2, r2, #0x1b
03008: 01d5     bpl     #0x300e
0300A: 904a     ldr     r2, [pc, #0x240]
0300C: 1360     str     r3, [r2]
0300E: 0a23     movs    r3, #0xa
03010: 009a     ldr     r2, [sp]
03012: 1a42     tst     r2, r3
03014: 00d1     bne     #0x3018
03016: 8ce0     b       #0x3132
03018: 8d4b     ldr     r3, [pc, #0x234]
0301A: 1b68     ldr     r3, [r3]
0301C: 5b07     lsls    r3, r3, #0x1d
0301E: 53d5     bpl     #0x30c8
03020: 8949     ldr     r1, [pc, #0x224]
03022: 8c4b     ldr     r3, [pc, #0x230]
03024: 0a78     ldrb    r2, [r1]
03026: 1e68     ldr     r6, [r3]
03028: 0800     movs    r0, r1
0302A: 012a     cmp     r2, #1
0302C: 0cd0     beq     #0x3048
0302E: 002a     cmp     r2, #0
03030: 19d0     beq     #0x3066
03032: 022a     cmp     r2, #2
03034: 46d1     bne     #0x30c4
03036: 0122     movs    r2, #1
03038: 874b     ldr     r3, [pc, #0x21c]
0303A: 1a60     str     r2, [r3]
0303C: 874a     ldr     r2, [pc, #0x21c]
0303E: f3b2     uxtb    r3, r6
03040: 1380     strh    r3, [r2]
03042: 0023     movs    r3, #0
03044: 0b70     strb    r3, [r1]
03046: 3de0     b       #0x30c4
03048: 8448     ldr     r0, [pc, #0x210]
0304A: 0188     ldrh    r1, [r0]
0304C: 0029     cmp     r1, #0
0304E: 37d0     beq     #0x30c0
03050: 814b     ldr     r3, [pc, #0x204]
03052: 0139     subs    r1, #1
03054: 1a60     str     r2, [r3]
03056: 824b     ldr     r3, [pc, #0x208]
03058: 0180     strh    r1, [r0]
0305A: 1a68     ldr     r2, [r3]
0305C: f3b2     uxtb    r3, r6
0305E: 1219     adds    r2, r2, r4
03060: 1370     strb    r3, [r2]
03062: 0134     adds    r4, #1
03064: 2ee0     b       #0x30c4
03066: 7d49     ldr     r1, [pc, #0x1f4]
03068: 0b88     ldrh    r3, [r1]
0306A: 1b02     lsls    r3, r3, #8
0306C: 3343     orrs    r3, r6
0306E: 7d4e     ldr     r6, [pc, #0x1f4]
03070: 3688     ldrh    r6, [r6]
03072: b342     cmp     r3, r6
03074: 24d2     bhs     #0x30c0
03076: 0126     movs    r6, #1
03078: 774c     ldr     r4, [pc, #0x1dc]
0307A: 2660     str     r6, [r4]
0307C: 7a4c     ldr     r4, [pc, #0x1e8]
0307E: 2488     ldrh    r4, [r4]
03080: a342     cmp     r3, r4
03082: 01d2     bhs     #0x3088
03084: e21a     subs    r2, r4, r3
03086: 92b2     uxth    r2, r2
03088: 0a80     strh    r2, [r1]
0308A: 072a     cmp     r2, #7
0308C: 02d8     bhi     #0x3094
0308E: 0122     movs    r2, #1
03090: 0270     strb    r2, [r0]
03092: 11e0     b       #0x30b8
03094: 6949     ldr     r1, [pc, #0x1a4]
03096: 6b48     ldr     r0, [pc, #0x1ac]
03098: 082a     cmp     r2, #8
0309A: 06d1     bne     #0x30aa
0309C: a024     movs    r4, #0xa0
0309E: 0a68     ldr     r2, [r1]
030A0: 2402     lsls    r4, r4, #8
030A2: 2243     orrs    r2, r4
030A4: 0a60     str     r2, [r1]
030A6: 0022     movs    r2, #0
030A8: 05e0     b       #0x30b6
030AA: 8024     movs    r4, #0x80
030AC: 0a68     ldr     r2, [r1]
030AE: a401     lsls    r4, r4, #6
030B0: 2243     orrs    r2, r4
030B2: 0a60     str     r2, [r1]
030B4: 0822     movs    r2, #8
030B6: 0260     str     r2, [r0]
030B8: 5f4a     ldr     r2, [pc, #0x17c]
030BA: 1c00     movs    r4, r3
030BC: 1380     strh    r3, [r2]
030BE: 01e0     b       #0x30c4
030C0: fff798fe bl      #0x2df4
030C4: 0422     movs    r2, #4
030C6: 32e0     b       #0x312e
030C8: 5c49     ldr     r1, [pc, #0x170]
030CA: 0b68     ldr     r3, [r1]
030CC: 9b04     lsls    r3, r3, #0x12
030CE: 30d5     bpl     #0x3132
030D0: 0222     movs    r2, #2
030D2: 009b     ldr     r3, [sp]
030D4: 1a40     ands    r2, r3
030D6: 08d0     beq     #0x30ea
030D8: 644b     ldr     r3, [pc, #0x190]
030DA: 1a68     ldr     r2, [r3]
030DC: 0f23     movs    r3, #0xf
030DE: 0868     ldr     r0, [r1]
030E0: 1340     ands    r3, r2
030E2: 574a     ldr     r2, [pc, #0x15c]
030E4: 0240     ands    r2, r0
030E6: 0a60     str     r2, [r1]
030E8: 07e0     b       #0x30fa
030EA: 5c48     ldr     r0, [pc, #0x170]
030EC: 0388     ldrh    r3, [r0]
030EE: 083b     subs    r3, #8
030F0: 9bb2     uxth    r3, r3
030F2: 0380     strh    r3, [r0]
030F4: 082b     cmp     r3, #8
030F6: 01d9     bls     #0x30fc
030F8: 0823     movs    r3, #8
030FA: 0122     movs    r2, #1
030FC: 5548     ldr     r0, [pc, #0x154]
030FE: 584f     ldr     r7, [pc, #0x160]
03100: 8446     mov     ip, r0
03102: e418     adds    r4, r4, r3
03104: e01a     subs    r0, r4, r3
03106: 002b     cmp     r3, #0
03108: 07d0     beq     #0x311a
0310A: 3e68     ldr     r6, [r7]
0310C: 013b     subs    r3, #1
0310E: 3018     adds    r0, r6, r0
03110: 6646     mov     r6, ip
03112: 3668     ldr     r6, [r6]
03114: f6b2     uxtb    r6, r6
03116: 0670     strb    r6, [r0]
03118: f4e7     b       #0x3104
0311A: 002a     cmp     r2, #0
0311C: 06d1     bne     #0x312c
0311E: 8020     movs    r0, #0x80
03120: 0b68     ldr     r3, [r1]
03122: 0002     lsls    r0, r0, #8
03124: 0343     orrs    r3, r0
03126: 0b60     str     r3, [r1]
03128: 464b     ldr     r3, [pc, #0x118]
0312A: 1a60     str     r2, [r3]
0312C: 0c22     movs    r2, #0xc
0312E: 504b     ldr     r3, [pc, #0x140]
03130: 1a60     str     r2, [r3]
03132: 0223     movs    r3, #2
03134: 009a     ldr     r2, [sp]
03136: 1a42     tst     r2, r3
03138: 47d0     beq     #0x31ca
0313A: ea06     lsls    r2, r5, #0x1b
0313C: 13d5     bpl     #0x3166
0313E: 0022     movs    r2, #0
03140: 4049     ldr     r1, [pc, #0x100]
03142: 0a60     str     r2, [r1]
03144: 3b49     ldr     r1, [pc, #0xec]
03146: 0a60     str     r2, [r1]
03148: 3b4a     ldr     r2, [pc, #0xec]
0314A: 1288     ldrh    r2, [r2]
0314C: 9442     cmp     r4, r2
0314E: 00d0     beq     #0x3152
03150: 0833     adds    r3, #8
03152: 374a     ldr     r2, [pc, #0xdc]
03154: 2b40     ands    r3, r5
03156: 1178     ldrb    r1, [r2]
03158: 0b43     orrs    r3, r1
0315A: 2021     movs    r1, #0x20
0315C: 8b43     bics    r3, r1
0315E: 1370     strb    r3, [r2]
03160: 0222     movs    r2, #2
03162: 394b     ldr     r3, [pc, #0xe4]
03164: 1a70     strb    r2, [r3]
03166: 6b06     lsls    r3, r5, #0x19
03168: 2dd5     bpl     #0x31c6
0316A: 2021     movs    r1, #0x20
0316C: 304a     ldr     r2, [pc, #0xc0]
0316E: 1378     ldrb    r3, [r2]
03170: 0b43     orrs    r3, r1
03172: 1370     strb    r3, [r2]
03174: 304b     ldr     r3, [pc, #0xc0]
03176: 1039     subs    r1, #0x10
03178: 1c88     ldrh    r4, [r3]
0317A: 3e4b     ldr     r3, [pc, #0xf8]
0317C: 1b68     ldr     r3, [r3]
0317E: 0b42     tst     r3, r1
03180: 11d0     beq     #0x31a6
03182: 8020     movs    r0, #0x80
03184: 374b     ldr     r3, [pc, #0xdc]
03186: 354a     ldr     r2, [pc, #0xd4]
03188: 1b88     ldrh    r3, [r3]
0318A: 4002     lsls    r0, r0, #9
0318C: 1b1b     subs    r3, r3, r4
0318E: 1380     strh    r3, [r2]
03190: 394b     ldr     r3, [pc, #0xe4]
03192: 1a68     ldr     r2, [r3]
03194: 0243     orrs    r2, r0
03196: 1a60     str     r2, [r3]
03198: 1868     ldr     r0, [r3]
0319A: 384a     ldr     r2, [pc, #0xe0]
0319C: 0240     ands    r2, r0
0319E: 1a60     str     r2, [r3]
031A0: 244b     ldr     r3, [pc, #0x90]
031A2: 1960     str     r1, [r3]
031A4: 02e0     b       #0x31ac
031A6: 0422     movs    r2, #4
031A8: 264b     ldr     r3, [pc, #0x98]
031AA: 1a60     str     r2, [r3]
031AC: 0122     movs    r2, #1
031AE: 1020     movs    r0, #0x10
031B0: 334b     ldr     r3, [pc, #0xcc]
031B2: 0199     ldr     r1, [sp, #4]
031B4: 1a60     str     r2, [r3]
031B6: 334b     ldr     r3, [pc, #0xcc]
031B8: 0b60     str     r3, [r1]
031BA: 3349     ldr     r1, [pc, #0xcc]
031BC: 0b68     ldr     r3, [r1]
031BE: 0343     orrs    r3, r0
031C0: 0b60     str     r3, [r1]
031C2: 254b     ldr     r3, [pc, #0x94]
031C4: 1a60     str     r2, [r3]
031C6: 019b     ldr     r3, [sp, #4]
031C8: 1d60     str     r5, [r3]
031CA: 039b     ldr     r3, [sp, #0xc]
031CC: 1b68     ldr     r3, [r3]
031CE: 5b07     lsls    r3, r3, #0x1d
031D0: 20d5     bpl     #0x3214
031D2: ff21     movs    r1, #0xff
031D4: 0020     movs    r0, #0
031D6: 8c46     mov     ip, r1
031D8: 0f26     movs    r6, #0xf
031DA: 214b     ldr     r3, [pc, #0x84]
031DC: 1f4a     ldr     r2, [pc, #0x7c]
031DE: 1f68     ldr     r7, [r3]
031E0: 2a4d     ldr     r5, [pc, #0xa8]
031E2: 1388     ldrh    r3, [r2]
031E4: 002b     cmp     r3, #0
031E6: 08d0     beq     #0x31fa
031E8: 3919     adds    r1, r7, r4
031EA: 0978     ldrb    r1, [r1]
031EC: 013b     subs    r3, #1
031EE: c9b2     uxtb    r1, r1
031F0: 2960     str     r1, [r5]
031F2: 0134     adds    r4, #1
031F4: 9bb2     uxth    r3, r3
031F6: 0120     movs    r0, #1
031F8: 01e0     b       #0x31fe
031FA: 6146     mov     r1, ip
031FC: 2960     str     r1, [r5]
031FE: 2449     ldr     r1, [pc, #0x90]
03200: 0968     ldr     r1, [r1]
03202: 3140     ands    r1, r6
03204: 0829     cmp     r1, #8
03206: edd1     bne     #0x31e4
03208: 0028     cmp     r0, #0
0320A: 00d0     beq     #0x320e
0320C: 1380     strh    r3, [r2]
0320E: 1022     movs    r2, #0x10
03210: 204b     ldr     r3, [pc, #0x80]
03212: 1a60     str     r2, [r3]
03214: 029b     ldr     r3, [sp, #8]
03216: 1c80     strh    r4, [r3]
03218: 05b0     add     sp, #0x14
0321A: f0bd     pop     {r4, r5, r6, r7, pc}
0321C: 5401     lsls    r4, r2, #5
0321E: 0020     movs    r0, #0
03220: 400f     lsrs    r0, r0, #0x1d
03222: 0640     ands    r6, r0
03224: 000e     lsrs    r0, r0, #0x18
03226: 0640     ands    r6, r0
03228: f601     lsls    r6, r6, #7
0322A: 0020     movs    r0, #0
0322C: 0000     movs    r0, r0
0322E: 0640     ands    r6, r0
03230: fc01     lsls    r4, r7, #7
03232: 0020     movs    r0, #0
03234: 880f     lsrs    r0, r1, #0x1e
03236: 0640     ands    r6, r0
03238: f401     lsls    r4, r6, #7
0323A: 0020     movs    r0, #0
0323C: 6000     lsls    r0, r4, #1
0323E: 0640     ands    r6, r0
03240: ff5f     ldrsh   r7, [r7, r7]
03242: ffff .hword
03244: c80f     lsrs    r0, r1, #0x1f
03246: 0640     ands    r6, r0
03248: f801     lsls    r0, r7, #7
0324A: 0020     movs    r0, #0
0324C: 880e     lsrs    r0, r1, #0x1a
0324E: 0640     ands    r6, r0
03250: cc0f     lsrs    r4, r1, #0x1f
03252: 0640     ands    r6, r0
03254: 4003     lsls    r0, r0, #0xd
03256: 0640     ands    r6, r0
03258: 6c00     lsls    r4, r5, #1
0325A: 0640     ands    r6, r0
0325C: 5801     lsls    r0, r3, #5
0325E: 0020     movs    r0, #0
03260: 0002     lsls    r0, r0, #8
03262: 0020     movs    r0, #0
03264: 0402     lsls    r4, r0, #8
03266: 0020     movs    r0, #0
03268: fa01     lsls    r2, r7, #7
0326A: 0020     movs    r0, #0
0326C: 0803     lsls    r0, r1, #0xc
0326E: 0640     ands    r6, r0
03270: c00f     lsrs    r0, r0, #0x1f
03272: 0640     ands    r6, r0
03274: 6400     lsls    r4, r4, #1
03276: 0640     ands    r6, r0
03278: 0402     lsls    r4, r0, #8
0327A: 0640     ands    r6, r0
0327C: ffff .hword
0327E: feff .hword
03280: 800e     lsrs    r0, r0, #0x1a
03282: 0640     ands    r6, r0
03284: ff0f     lsrs    r7, r7, #0x1f
03286: 0000     movs    r0, r0
03288: 480f     lsrs    r0, r1, #0x1d
0328A: 0640     ands    r6, r0
0328C: 4002     lsls    r0, r0, #9
0328E: 0640     ands    r6, r0
03290: 0802     lsls    r0, r1, #8
03292: 0640     ands    r6, r0
03294: 800f     lsrs    r0, r0, #0x1e
03296: 0640     ands    r6, r0
03298: 10b5     push    {r4, lr}
0329A: 0400     movs    r4, r0
0329C: 00f016fa bl      #0x36cc
032A0: 044a     ldr     r2, [pc, #0x10]
032A2: a407     lsls    r4, r4, #0x1e
032A4: 1368     ldr     r3, [r2]
032A6: 9b00     lsls    r3, r3, #2
032A8: 9b08     lsrs    r3, r3, #2
032AA: 1c43     orrs    r4, r3
032AC: 1460     str     r4, [r2]
032AE: 00f011fa bl      #0x36d4
032B2: 10bd     pop     {r4, pc}
032B4: 04e4     b       #0x2ac0
032B6: 00e0     b       #0x32ba
032B8: 10b5     push    {r4, lr}
032BA: 8024     movs    r4, #0x80
032BC: 044b     ldr     r3, [pc, #0x10]
032BE: 1c60     str     r4, [r3]
032C0: 044b     ldr     r3, [pc, #0x10]
032C2: d865     str     r0, [r3, #0x5c]
032C4: 0320     movs    r0, #3
032C6: fff7e7ff bl      #0x3298
032CA: 034b     ldr     r3, [pc, #0xc]
032CC: 1c60     str     r4, [r3]
032CE: 10bd     pop     {r4, pc}
032D0: 80e1     b       #0x35d4
032D2: 00e0     b       #0x32d6
032D4: 0000     movs    r0, r0
032D6: 0020     movs    r0, #0
032D8: 00e1     b       #0x34dc
032DA: 00e0     b       #0x32de
032DC: 044a     ldr     r2, [pc, #0x10]
032DE: 1368     ldr     r3, [r2]
032E0: 002b     cmp     r3, #0
032E2: fcdb     blt     #0x32de
032E4: 034b     ldr     r3, [pc, #0xc]
032E6: 0002     lsls    r0, r0, #8
032E8: 1843     orrs    r0, r3
032EA: 014b     ldr     r3, [pc, #4]
032EC: 1860     str     r0, [r3]
032EE: 7047     bx      lr
032F0: 0000     movs    r0, r0
032F2: 0140     ands    r1, r0
032F4: 4200     lsls    r2, r0, #1
032F6: 0080     strh    r0, [r0]
032F8: 034a     ldr     r2, [pc, #0xc]
032FA: 1368     ldr     r3, [r2]
032FC: 002b     cmp     r3, #0
032FE: fcdb     blt     #0x32fa
03300: 024a     ldr     r2, [pc, #8]
03302: 014b     ldr     r3, [pc, #4]
03304: 1a60     str     r2, [r3]
03306: 7047     bx      lr
03308: 0000     movs    r0, r0
0330A: 0140     ands    r1, r0
0330C: 4200     lsls    r2, r0, #1
0330E: 0040     ands    r0, r0
03310: f8b5     push    {r3, r4, r5, r6, r7, lr}
03312: 0400     movs    r4, r0
03314: 1828     cmp     r0, #0x18
03316: 04d0     beq     #0x3322
03318: 1023     movs    r3, #0x10
0331A: 0200     movs    r2, r0
0331C: 9a43     bics    r2, r3
0331E: 202a     cmp     r2, #0x20
03320: 35d1     bne     #0x338e
03322: 0726     movs    r6, #7
03324: 00f0d2f9 bl      #0x36cc
03328: 194d     ldr     r5, [pc, #0x64]
0332A: 1a4a     ldr     r2, [pc, #0x68]
0332C: 2b68     ldr     r3, [r5]
0332E: 1a49     ldr     r1, [pc, #0x68]
03330: b343     bics    r3, r6
03332: 2b60     str     r3, [r5]
03334: 194b     ldr     r3, [pc, #0x64]
03336: 0700     movs    r7, r0
03338: e318     adds    r3, r4, r3
0333A: 1b78     ldrb    r3, [r3]
0333C: dbb2     uxtb    r3, r3
0333E: 1360     str     r3, [r2]
03340: 174a     ldr     r2, [pc, #0x5c]
03342: 1368     ldr     r3, [r2]
03344: b343     bics    r3, r6
03346: 1360     str     r3, [r2]
03348: 164b     ldr     r3, [pc, #0x58]
0334A: 0a68     ldr     r2, [r1]
0334C: e318     adds    r3, r4, r3
0334E: 1878     ldrb    r0, [r3]
03350: 7f23     movs    r3, #0x7f
03352: 9a43     bics    r2, r3
03354: 0340     ands    r3, r0
03356: 1343     orrs    r3, r2
03358: 0b60     str     r3, [r1]
0335A: 3220     movs    r0, #0x32
0335C: 00f0acf9 bl      #0x36b8
03360: 182c     cmp     r4, #0x18
03362: 11d9     bls     #0x3388
03364: 2300     movs    r3, r4
03366: 2a68     ldr     r2, [r5]
03368: 1c3b     subs    r3, #0x1c
0336A: 9b08     lsrs    r3, r3, #2
0336C: b243     bics    r2, r6
0336E: 3340     ands    r3, r6
03370: 1343     orrs    r3, r2
03372: 2b60     str     r3, [r5]
03374: 3220     movs    r0, #0x32
03376: 00f09ff9 bl      #0x36b8
0337A: 183c     subs    r4, #0x18
0337C: 2b68     ldr     r3, [r5]
0337E: a408     lsrs    r4, r4, #2
03380: 3440     ands    r4, r6
03382: b343     bics    r3, r6
03384: 1c43     orrs    r4, r3
03386: 2c60     str     r4, [r5]
03388: 3800     movs    r0, r7
0338A: 00f0a3f9 bl      #0x36d4
0338E: f8bd     pop     {r3, r4, r5, r6, r7, pc}
03390: 080f     lsrs    r0, r1, #0x1c
03392: 0340     ands    r3, r0
03394: 0c0f     lsrs    r4, r1, #0x1c
03396: 0340     ands    r3, r0
03398: 180f     lsrs    r0, r3, #0x1c
0339A: 0340     ands    r3, r0
0339C: cdf1ff0f rsb.w   pc, sp, #0xff
033A0: 100f     lsrs    r0, r2, #0x1c
033A2: 0340     ands    r3, r0
033A4: b4f1ff0f cmp.w   r4, #0xff
033A8: 024b     ldr     r3, [pc, #8]
033AA: 8000     lsls    r0, r0, #2
033AC: c318     adds    r3, r0, r3
033AE: 1868     ldr     r0, [r3]
033B0: 1960     str     r1, [r3]
033B2: 7047     bx      lr
033B4: 4000     lsls    r0, r0, #1
033B6: 0020     movs    r0, #0
033B8: f8b5     push    {r3, r4, r5, r6, r7, lr}
033BA: 0326     movs    r6, #3
033BC: 0500     movs    r5, r0
033BE: 3540     ands    r5, r6
033C0: b540     lsls    r5, r6
033C2: 0f00     movs    r7, r1
033C4: 0400     movs    r4, r0
033C6: 0635     adds    r5, #6
033C8: ae40     lsls    r6, r5
033CA: af40     lsls    r7, r5
033CC: 00f07ef9 bl      #0x36cc
033D0: a408     lsrs    r4, r4, #2
033D2: 054b     ldr     r3, [pc, #0x14]
033D4: a400     lsls    r4, r4, #2
033D6: e418     adds    r4, r4, r3
033D8: 2368     ldr     r3, [r4]
033DA: b343     bics    r3, r6
033DC: 1f43     orrs    r7, r3
033DE: 2760     str     r7, [r4]
033E0: 00f078f9 bl      #0x36d4
033E4: f8bd     pop     {r3, r4, r5, r6, r7, pc}
033E6: c046     mov     r8, r8
033E8: 00e4     b       #0x2bec
033EA: 00e0     b       #0x33ee
033EC: 1f23     movs    r3, #0x1f
033EE: 1840     ands    r0, r3
033F0: 1e3b     subs    r3, #0x1e
033F2: 8340     lsls    r3, r0
033F4: 014a     ldr     r2, [pc, #4]
033F6: 1360     str     r3, [r2]
033F8: 7047     bx      lr
033FA: c046     mov     r8, r8
033FC: 00e1     b       #0x3600
033FE: 00e0     b       #0x3402
03400: 1f23     movs    r3, #0x1f
03402: 1840     ands    r0, r3
03404: 1e3b     subs    r3, #0x1e
03406: 8340     lsls    r3, r0
03408: 014a     ldr     r2, [pc, #4]
0340A: 1360     str     r3, [r2]
0340C: 7047     bx      lr
0340E: c046     mov     r8, r8
03410: 80e1     b       #0x3714
03412: 00e0     b       #0x3416
03414: 034a     ldr     r2, [pc, #0xc]
03416: 0449     ldr     r1, [pc, #0x10]
03418: 1368     ldr     r3, [r2]
0341A: 9bb2     uxth    r3, r3
0341C: 0b43     orrs    r3, r1
0341E: 1360     str     r3, [r2]
03420: 7047     bx      lr
03422: c046     mov     r8, r8
03424: 0ced00e0 stc     p0, c14, [ip, #-0]
03428: 0400     movs    r4, r0
0342A: fa05     lsls    r2, r7, #0x17
0342C: 70b5     push    {r4, r5, r6, lr}
0342E: 8025     movs    r5, #0x80
03430: 0400     movs    r4, r0
03432: 2d02     lsls    r5, r5, #8
03434: 064b     ldr     r3, [pc, #0x18]
03436: ac42     cmp     r4, r5
03438: 05d9     bls     #0x3446
0343A: 5868     ldr     r0, [r3, #4]
0343C: 00f03cf9 bl      #0x36b8
03440: 044b     ldr     r3, [pc, #0x10]
03442: e418     adds    r4, r4, r3
03444: f6e7     b       #0x3434
03446: 9868     ldr     r0, [r3, #8]
03448: 6043     muls    r0, r4, r0
0344A: 00f035f9 bl      #0x36b8
0344E: 70bd     pop     {r4, r5, r6, pc}
03450: 8000     lsls    r0, r0, #2
03452: 0020     movs    r0, #0
03454: 0080     strh    r0, [r0]
03456: ffff10b5 vsli.32 d27, d0, #0x1f
0345A: 034b     ldr     r3, [pc, #0xc]
0345C: 1b7b     ldrb    r3, [r3, #0xc]
0345E: 5843     muls    r0, r3, r0
03460: 00f02af9 bl      #0x36b8
03464: 10bd     pop     {r4, pc}
03466: c046     mov     r8, r8
03468: 8000     lsls    r0, r0, #2
0346A: 0020     movs    r0, #0
0346C: 10b5     push    {r4, lr}
0346E: 00f02df9 bl      #0x36cc
03472: 0421     movs    r1, #4
03474: 034a     ldr     r2, [pc, #0xc]
03476: 1368     ldr     r3, [r2]
03478: 8b43     bics    r3, r1
0347A: 1360     str     r3, [r2]
0347C: 30bf     wfi     
0347E: 00f029f9 bl      #0x36d4
03482: 10bd     pop     {r4, pc}
03484: 10ed00e0 ldc     p0, c14, [r0, #-0]
03488: 10b5     push    {r4, lr}
0348A: 00f01ff9 bl      #0x36cc
0348E: 0421     movs    r1, #4
03490: 064b     ldr     r3, [pc, #0x18]
03492: 074a     ldr     r2, [pc, #0x1c]
03494: 1b88     ldrh    r3, [r3]
03496: 9bb2     uxth    r3, r3
03498: 1360     str     r3, [r2]
0349A: 064a     ldr     r2, [pc, #0x18]
0349C: 1368     ldr     r3, [r2]
0349E: 0b43     orrs    r3, r1
034A0: 1360     str     r3, [r2]
034A2: 30bf     wfi     
034A4: 00f016f9 bl      #0x36d4
034A8: 10bd     pop     {r4, pc}
034AA: c046     mov     r8, r8
034AC: 52f1ff0f adcs    pc, r2, #0xff
034B0: 0400     movs    r4, r0
034B2: 0340     ands    r3, r0
034B4: 10ed00e0 ldc     p0, c14, [r0, #-0]
034B8: 074a     ldr     r2, [pc, #0x1c]
034BA: 084b     ldr     r3, [pc, #0x20]
034BC: 1168     ldr     r1, [r2]
034BE: 0b40     ands    r3, r1
034C0: 8021     movs    r1, #0x80
034C2: 4900     lsls    r1, r1, #1
034C4: 0b43     orrs    r3, r1
034C6: 1360     str     r3, [r2]
034C8: 054a     ldr     r2, [pc, #0x14]
034CA: 064b     ldr     r3, [pc, #0x18]
034CC: 1168     ldr     r1, [r2]
034CE: 0b40     ands    r3, r1
034D0: 0549     ldr     r1, [pc, #0x14]
034D2: 0b43     orrs    r3, r1
034D4: 1360     str     r3, [r2]
034D6: 7047     bx      lr
034D8: 3400     movs    r4, r6
034DA: 0340     ands    r3, r0
034DC: fff0ffff bl      #0x1034de
034E0: 1800     movs    r0, r3
034E2: 0340     ands    r3, r0
034E4: f0f0ffff bl      #0xf44e6
034E8: 0809     lsrs    r0, r1, #4
034EA: 0000     movs    r0, r0
034EC: 054a     ldr     r2, [pc, #0x14]
034EE: 064b     ldr     r3, [pc, #0x18]
034F0: 1168     ldr     r1, [r2]
034F2: 0b40     ands    r3, r1
034F4: 1360     str     r3, [r2]
034F6: 054a     ldr     r2, [pc, #0x14]
034F8: 054b     ldr     r3, [pc, #0x14]
034FA: 1168     ldr     r1, [r2]
034FC: 0b40     ands    r3, r1
034FE: 1360     str     r3, [r2]
03500: 7047     bx      lr
03502: c046     mov     r8, r8
03504: 3400     movs    r4, r6
03506: 0340     ands    r3, r0
03508: fff0ffff bl      #0x10350a
0350C: 1800     movs    r0, r3
0350E: 0340     ands    r3, r0
03510: 0f0f     lsrs    r7, r1, #0x1c
03512: 0000     movs    r0, r0
03514: f8b5     push    {r3, r4, r5, r6, r7, lr}
03516: 0f00     movs    r7, r1
03518: 8021     movs    r1, #0x80
0351A: 2a4b     ldr     r3, [pc, #0xa8]
0351C: 4900     lsls    r1, r1, #1
0351E: 1a68     ldr     r2, [r3]
03520: 294b     ldr     r3, [pc, #0xa4]
03522: 1a40     ands    r2, r3
03524: 1123     movs    r3, #0x11
03526: 8a42     cmp     r2, r1
03528: 49d1     bne     #0x35be
0352A: 284a     ldr     r2, [pc, #0xa0]
0352C: 1168     ldr     r1, [r2]
0352E: 284a     ldr     r2, [pc, #0xa0]
03530: 9142     cmp     r1, r2
03532: 44d1     bne     #0x35be
03534: 0200     movs    r2, r0
03536: 2749     ldr     r1, [pc, #0x9c]
03538: 643a     subs    r2, #0x64
0353A: 8a42     cmp     r2, r1
0353C: 3fd8     bhi     #0x35be
0353E: 002f     cmp     r7, #0
03540: 3dd0     beq     #0x35be
03542: 254b     ldr     r3, [pc, #0x94]
03544: 2549     ldr     r1, [pc, #0x94]
03546: 1a68     ldr     r2, [r3]
03548: 002a     cmp     r2, #0
0354A: 31d0     beq     #0x35b0
0354C: 0a68     ldr     r2, [r1]
0354E: 0723     movs    r3, #7
03550: 002a     cmp     r2, #0
03552: 34da     bge     #0x35be
03554: 224e     ldr     r6, [pc, #0x88]
03556: 0a33     adds    r3, #0xa
03558: 3268     ldr     r2, [r6]
0355A: 002a     cmp     r2, #0
0355C: 2fd0     beq     #0x35be
0355E: 5333     adds    r3, #0x53
03560: 4343     muls    r3, r0, r3
03562: 1c00     movs    r4, r3
03564: 1f4b     ldr     r3, [pc, #0x7c]
03566: 2049     ldr     r1, [pc, #0x80]
03568: e418     adds    r4, r4, r3
0356A: 2000     movs    r0, r4
0356C: 00f092f9 bl      #0x3894
03570: 1e4b     ldr     r3, [pc, #0x78]
03572: 0500     movs    r5, r0
03574: 1968     ldr     r1, [r3]
03576: 3068     ldr     r0, [r6]
03578: 1d4a     ldr     r2, [pc, #0x74]
0357A: 4843     muls    r0, r1, r0
0357C: 890a     lsrs    r1, r1, #0xa
0357E: 9542     cmp     r5, r2
03580: 0bd9     bls     #0x359a
03582: 00f087f9 bl      #0x3894
03586: 2821     movs    r1, #0x28
03588: 00f084f9 bl      #0x3894
0358C: 1949     ldr     r1, [pc, #0x64]
0358E: 0500     movs    r5, r0
03590: 2000     movs    r0, r4
03592: 00f07ff9 bl      #0x3894
03596: 6843     muls    r0, r5, r0
03598: 05e0     b       #0x35a6
0359A: 00f07bf9 bl      #0x3894
0359E: 1649     ldr     r1, [pc, #0x58]
035A0: 6843     muls    r0, r5, r0
035A2: 00f077f9 bl      #0x3894
035A6: 0023     movs    r3, #0
035A8: 0b4a     ldr     r2, [pc, #0x2c]
035AA: 3860     str     r0, [r7]
035AC: 1360     str     r3, [r2]
035AE: 06e0     b       #0x35be
035B0: 0e4a     ldr     r2, [pc, #0x38]
035B2: 1268     ldr     r2, [r2]
035B4: 920a     lsrs    r2, r2, #0xa
035B6: 0a60     str     r2, [r1]
035B8: 0122     movs    r2, #1
035BA: 1a60     str     r2, [r3]
035BC: 0723     movs    r3, #7
035BE: 1800     movs    r0, r3
035C0: f8bd     pop     {r3, r4, r5, r6, r7, pc}
035C2: c046     mov     r8, r8
035C4: 3400     movs    r4, r6
035C6: 0340     ands    r3, r0
035C8: 0f0f     lsrs    r7, r1, #0x1c
035CA: 0000     movs    r0, r0
035CC: 1800     movs    r0, r3
035CE: 0340     ands    r3, r0
035D0: 0809     lsrs    r0, r1, #4
035D2: 0000     movs    r0, r0
035D4: 1c84     strh    r4, [r3, #0x20]
035D6: 1e00     movs    r6, r3
035D8: 5c01     lsls    r4, r3, #5
035DA: 0020     movs    r0, #0
035DC: 1c00     movs    r4, r3
035DE: 0340     ands    r3, r0
035E0: 2000     movs    r0, r4
035E2: 0340     ands    r3, r0
035E4: 7102     lsls    r1, r6, #9
035E6: 0000     movs    r0, r0
035E8: c409     lsrs    r4, r0, #7
035EA: 0000     movs    r0, r0
035EC: 9000     lsls    r0, r2, #2
035EE: 0020     movs    r0, #0
035F0: 60d1     bne     #0x36b4
035F2: 0000     movs    r0, r0
035F4: a025     movs    r5, #0xa0
035F6: 2600     movs    r6, r4
035F8: 409c     ldr     r4, [sp, #0x100]
035FA: 0000     movs    r0, r0
035FC: 014a     ldr     r2, [pc, #4]
035FE: 024b     ldr     r3, [pc, #8]
03600: 1a60     str     r2, [r3]
03602: 7047     bx      lr
03604: 6588     ldrh    r5, [r4, #2]
03606: edac     add     r4, sp, #0x3b4
03608: 3800     movs    r0, r7
0360A: 0340     ands    r3, r0
0360C: 034a     ldr     r2, [pc, #0xc]
0360E: 80b2     uxth    r0, r0
03610: 1368     ldr     r3, [r2]
03612: 1b0c     lsrs    r3, r3, #0x10
03614: 1b04     lsls    r3, r3, #0x10
03616: 1843     orrs    r0, r3
03618: 1060     str     r0, [r2]
0361A: 7047     bx      lr
0361C: 4000     lsls    r0, r0, #1
0361E: 0340     ands    r3, r0
03620: 014b     ldr     r3, [pc, #4]
03622: 1868     ldr     r0, [r3]
03624: 80b2     uxth    r0, r0
03626: 7047     bx      lr
03628: 4000     lsls    r0, r0, #1
0362A: 0340     ands    r3, r0
0362C: 0121     movs    r1, #1
0362E: 024a     ldr     r2, [pc, #8]
03630: 1368     ldr     r3, [r2]
03632: 0b43     orrs    r3, r1
03634: 1360     str     r3, [r2]
03636: 7047     bx      lr
03638: 4400     lsls    r4, r0, #1
0363A: 0340     ands    r3, r0
0363C: 0121     movs    r1, #1
0363E: 024a     ldr     r2, [pc, #8]
03640: 1368     ldr     r3, [r2]
03642: 8b43     bics    r3, r1
03644: 1360     str     r3, [r2]
03646: 7047     bx      lr
03648: 4c00     lsls    r4, r1, #1
0364A: 0340     ands    r3, r0
0364C: 0121     movs    r1, #1
0364E: 024a     ldr     r2, [pc, #8]
03650: 1368     ldr     r3, [r2]
03652: 0b43     orrs    r3, r1
03654: 1360     str     r3, [r2]
03656: 7047     bx      lr
03658: 4c00     lsls    r4, r1, #1
0365A: 0340     ands    r3, r0
0365C: 0223     movs    r3, #2
0365E: 0449     ldr     r1, [pc, #0x10]
03660: 4000     lsls    r0, r0, #1
03662: 0a68     ldr     r2, [r1]
03664: 9a43     bics    r2, r3
03666: d2b2     uxtb    r2, r2
03668: 0340     ands    r3, r0
0366A: 1343     orrs    r3, r2
0366C: 0b60     str     r3, [r1]
0366E: 7047     bx      lr
03670: 0001     lsls    r0, r0, #4
03672: 0440     ands    r4, r0
03674: 4022     movs    r2, #0x40
03676: 10b5     push    {r4, lr}
03678: 024b     ldr     r3, [pc, #8]
0367A: 1a60     str     r2, [r3]
0367C: fff7cafe bl      #0x3414
03680: 10bd     pop     {r4, pc}
03682: c046     mov     r8, r8
03684: 6800     lsls    r0, r5, #1
03686: 0020     movs    r0, #0
03688: 4023     movs    r3, #0x40
0368A: 0449     ldr     r1, [pc, #0x10]
0368C: 8001     lsls    r0, r0, #6
0368E: 0a68     ldr     r2, [r1]
03690: 9a43     bics    r2, r3
03692: d2b2     uxtb    r2, r2
03694: 0340     ands    r3, r0
03696: 1343     orrs    r3, r2
03698: 0b60     str     r3, [r1]
0369A: 7047     bx      lr
0369C: 0001     lsls    r0, r0, #4
0369E: 0440     ands    r4, r0
036A0: 4023     movs    r3, #0x40
036A2: 0449     ldr     r1, [pc, #0x10]
036A4: 8001     lsls    r0, r0, #6
036A6: 0a68     ldr     r2, [r1]
036A8: 9a43     bics    r2, r3
036AA: d2b2     uxtb    r2, r2
036AC: 0340     ands    r3, r0
036AE: 1343     orrs    r3, r2
036B0: 0b60     str     r3, [r1]
036B2: 7047     bx      lr
036B4: 0000     movs    r0, r0
036B6: 0440     ands    r4, r0
036B8: 0230     adds    r0, #2
036BA: 8008     lsrs    r0, r0, #2
036BC: 04d0     beq     #0x36c8
036BE: c046     mov     r8, r8
036C0: 0138     subs    r0, #1
036C2: fdd1     bne     #0x36c0
036C4: c046     mov     r8, r8
036C6: c046     mov     r8, r8
036C8: c046     mov     r8, r8
036CA: 7047     bx      lr
036CC: eff3 .hword
036CE: 1080     strh    r0, [r2]
036D0: 72b6     cpsid   i
036D2: 7047     bx      lr
036D4: 80f3 .hword
036D6: 1088     ldrh    r0, [r2]
036D8: 7047     bx      lr
036DA: c046     mov     r8, r8
036DC: 044b     ldr     r3, [pc, #0x10]
036DE: 1968     ldr     r1, [r3]
036E0: 044b     ldr     r3, [pc, #0x10]
036E2: 1a68     ldr     r2, [r3]
036E4: 044b     ldr     r3, [pc, #0x10]
036E6: 1b78     ldrb    r3, [r3]
036E8: 5b00     lsls    r3, r3, #1
036EA: 9952     strh    r1, [r3, r2]
036EC: 7047     bx      lr
036EE: c046     mov     r8, r8
036F0: 0c00     movs    r4, r1
036F2: 0840     ands    r0, r1
036F4: ec01     lsls    r4, r5, #7
036F6: 0020     movs    r0, #0
036F8: 143d     subs    r5, #0x14
036FA: 0000     movs    r0, r0
036FC: 2423     movs    r3, #0x24
036FE: 70b5     push    {r4, r5, r6, lr}
03700: 1e4d     ldr     r5, [pc, #0x78]
03702: 1f49     ldr     r1, [pc, #0x7c]
03704: 2a78     ldrb    r2, [r5]
03706: 2878     ldrb    r0, [r5]
03708: 1e4c     ldr     r4, [pc, #0x78]
0370A: 5843     muls    r0, r3, r0
0370C: 0818     adds    r0, r1, r0
0370E: 807d     ldrb    r0, [r0, #0x16]
03710: 2678     ldrb    r6, [r4]
03712: 0138     subs    r0, #1
03714: d2b2     uxtb    r2, r2
03716: b042     cmp     r0, r6
03718: 1bd9     bls     #0x3752
0371A: 5a43     muls    r2, r3, r2
0371C: 8a18     adds    r2, r1, r2
0371E: 5068     ldr     r0, [r2, #4]
03720: 2278     ldrb    r2, [r4]
03722: 0132     adds    r2, #1
03724: d2b2     uxtb    r2, r2
03726: 2270     strb    r2, [r4]
03728: 2a78     ldrb    r2, [r5]
0372A: 2678     ldrb    r6, [r4]
0372C: 5343     muls    r3, r2, r3
0372E: 0e22     movs    r2, #0xe
03730: 7243     muls    r2, r6, r2
03732: cb18     adds    r3, r1, r3
03734: 9b68     ldr     r3, [r3, #8]
03736: 9b18     adds    r3, r3, r2
03738: 134a     ldr     r2, [pc, #0x4c]
0373A: 1360     str     r3, [r2]
0373C: fef7c2ff bl      #0x26c4
03740: 2878     ldrb    r0, [r5]
03742: 2178     ldrb    r1, [r4]
03744: c0b2     uxtb    r0, r0
03746: c9b2     uxtb    r1, r1
03748: fff774f8 bl      #0x2834
0374C: fef7f6ff bl      #0x273c
03750: 13e0     b       #0x377a
03752: 0023     movs    r3, #0
03754: 2370     strb    r3, [r4]
03756: 0d4b     ldr     r3, [pc, #0x34]
03758: 0d4a     ldr     r2, [pc, #0x34]
0375A: 9868     ldr     r0, [r3, #8]
0375C: 0d49     ldr     r1, [pc, #0x34]
0375E: 1278     ldrb    r2, [r2]
03760: 0140     ands    r1, r0
03762: 9960     str     r1, [r3, #8]
03764: 012a     cmp     r2, #1
03766: 02d1     bne     #0x376e
03768: fef79cfe bl      #0x24a4
0376C: 05e0     b       #0x377a
0376E: 0a4a     ldr     r2, [pc, #0x28]
03770: 0240     ands    r2, r0
03772: 9a60     str     r2, [r3, #8]
03774: da88     ldrh    r2, [r3, #6]
03776: 0132     adds    r2, #1
03778: da80     strh    r2, [r3, #6]
0377A: 70bd     pop     {r4, r5, r6, pc}
0377C: 3901     lsls    r1, r7, #4
0377E: 0020     movs    r0, #0
03780: 203c     subs    r4, #0x20
03782: 0000     movs    r0, r0
03784: 4401     lsls    r4, r0, #5
03786: 0020     movs    r0, #0
03788: ec01     lsls    r4, r5, #7
0378A: 0020     movs    r0, #0
0378C: 7401     lsls    r4, r6, #5
0378E: 0020     movs    r0, #0
03790: 3801     lsls    r0, r7, #4
03792: 0020     movs    r0, #0
03794: ffff .hword
03796: feff .hword
03798: 7fff .hword
0379A: feff .hword
0379C: 0122     movs    r2, #1
0379E: 0a4b     ldr     r3, [pc, #0x28]
037A0: 10b5     push    {r4, lr}
037A2: 1a60     str     r2, [r3]
037A4: fff79aff bl      #0x36dc
037A8: 084b     ldr     r3, [pc, #0x20]
037AA: 094a     ldr     r2, [pc, #0x24]
037AC: 1b68     ldr     r3, [r3]
037AE: 1343     orrs    r3, r2
037B0: 084a     ldr     r2, [pc, #0x20]
037B2: 1360     str     r3, [r2]
037B4: 084b     ldr     r3, [pc, #0x20]
037B6: da88     ldrh    r2, [r3, #6]
037B8: 9968     ldr     r1, [r3, #8]
037BA: 0132     adds    r2, #1
037BC: da80     strh    r2, [r3, #6]
037BE: 074a     ldr     r2, [pc, #0x1c]
037C0: 0a40     ands    r2, r1
037C2: 9a60     str     r2, [r3, #8]
037C4: 10bd     pop     {r4, pc}
037C6: c046     mov     r8, r8
037C8: 1400     movs    r4, r2
037CA: 0840     ands    r0, r1
037CC: 7800     lsls    r0, r7, #1
037CE: 0020     movs    r0, #0
037D0: 2008     lsrs    r0, r4, #0x20
037D2: e881     strh    r0, [r5, #0xe]
037D4: 0400     movs    r4, r0
037D6: 0840     ands    r0, r1
037D8: 7401     lsls    r4, r6, #5
037DA: 0020     movs    r0, #0
037DC: 7fff .hword
037DE: feff10b5 vsli.32 d27, d0, #0x1e
037E2: 0e4b     ldr     r3, [pc, #0x38]
037E4: 1a78     ldrb    r2, [r3]
037E6: 0e4b     ldr     r3, [pc, #0x38]
037E8: 1c78     ldrb    r4, [r3]
037EA: 2423     movs    r3, #0x24
037EC: 5a43     muls    r2, r3, r2
037EE: 083b     subs    r3, #8
037F0: 5c43     muls    r4, r3, r4
037F2: 0c4b     ldr     r3, [pc, #0x30]
037F4: d358     ldr     r3, [r2, r3]
037F6: 0122     movs    r2, #1
037F8: 1c19     adds    r4, r3, r4
037FA: 0b4b     ldr     r3, [pc, #0x2c]
037FC: 1a60     str     r2, [r3]
037FE: fff76dff bl      #0x36dc
03802: 0a4b     ldr     r3, [pc, #0x28]
03804: 0a4a     ldr     r2, [pc, #0x28]
03806: 1b68     ldr     r3, [r3]
03808: 2000     movs    r0, r4
0380A: 1343     orrs    r3, r2
0380C: 094a     ldr     r2, [pc, #0x24]
0380E: 1360     str     r3, [r2]
03810: fff778f8 bl      #0x2904
03814: fff772ff bl      #0x36fc
03818: 10bd     pop     {r4, pc}
0381A: c046     mov     r8, r8
0381C: 3901     lsls    r1, r7, #4
0381E: 0020     movs    r0, #0
03820: 4401     lsls    r4, r0, #5
03822: 0020     movs    r0, #0
03824: 203c     subs    r4, #0x20
03826: 0000     movs    r0, r0
03828: 1400     movs    r4, r2
0382A: 0840     ands    r0, r1
0382C: 7800     lsls    r0, r7, #1
0382E: 0020     movs    r0, #0
03830: 2008     lsrs    r0, r4, #0x20
03832: e881     strh    r0, [r5, #0xe]
03834: 0400     movs    r4, r0
03836: 0840     ands    r0, r1
03838: 0122     movs    r2, #1
0383A: 0b4b     ldr     r3, [pc, #0x2c]
0383C: 10b5     push    {r4, lr}
0383E: 1a60     str     r2, [r3]
03840: fff74cff bl      #0x36dc
03844: 094b     ldr     r3, [pc, #0x24]
03846: 0a4a     ldr     r2, [pc, #0x28]
03848: 1b68     ldr     r3, [r3]
0384A: 1343     orrs    r3, r2
0384C: 094a     ldr     r2, [pc, #0x24]
0384E: 1360     str     r3, [r2]
03850: 094b     ldr     r3, [pc, #0x24]
03852: 1878     ldrb    r0, [r3]
03854: 094b     ldr     r3, [pc, #0x24]
03856: c0b2     uxtb    r0, r0
03858: 1978     ldrb    r1, [r3]
0385A: c9b2     uxtb    r1, r1
0385C: fff708f9 bl      #0x2a70
03860: fff74cff bl      #0x36fc
03864: 10bd     pop     {r4, pc}
03866: c046     mov     r8, r8
03868: 1400     movs    r4, r2
0386A: 0840     ands    r0, r1
0386C: 7800     lsls    r0, r7, #1
0386E: 0020     movs    r0, #0
03870: 2008     lsrs    r0, r4, #0x20
03872: e881     strh    r0, [r5, #0xe]
03874: 0400     movs    r4, r0
03876: 0840     ands    r0, r1
03878: 3901     lsls    r1, r7, #4
0387A: 0020     movs    r0, #0
0387C: 4401     lsls    r4, r0, #5
0387E: 0020     movs    r0, #0
03880: 02b4     push    {r1}
03882: 7146     mov     r1, lr
03884: 4908     lsrs    r1, r1, #1
03886: 4900     lsls    r1, r1, #1
03888: 095c     ldrb    r1, [r1, r0]
0388A: 4900     lsls    r1, r1, #1
0388C: 8e44     add     lr, r1
0388E: 02bc     pop     {r1}
03890: 7047     bx      lr
03892: c046     mov     r8, r8
03894: 0022     movs    r2, #0
03896: 4308     lsrs    r3, r0, #1
03898: 8b42     cmp     r3, r1
0389A: 74d3     blo     #0x3986
0389C: 0309     lsrs    r3, r0, #4
0389E: 8b42     cmp     r3, r1
038A0: 5fd3     blo     #0x3962
038A2: 030a     lsrs    r3, r0, #8
038A4: 8b42     cmp     r3, r1
038A6: 44d3     blo     #0x3932
038A8: 030b     lsrs    r3, r0, #0xc
038AA: 8b42     cmp     r3, r1
038AC: 28d3     blo     #0x3900
038AE: 030c     lsrs    r3, r0, #0x10
038B0: 8b42     cmp     r3, r1
038B2: 0dd3     blo     #0x38d0
038B4: ff22     movs    r2, #0xff
038B6: 0902     lsls    r1, r1, #8
038B8: 12ba     rev     r2, r2
038BA: 030c     lsrs    r3, r0, #0x10
038BC: 8b42     cmp     r3, r1
038BE: 02d3     blo     #0x38c6
038C0: 1212     asrs    r2, r2, #8
038C2: 0902     lsls    r1, r1, #8
038C4: 65d0     beq     #0x3992
038C6: 030b     lsrs    r3, r0, #0xc
038C8: 8b42     cmp     r3, r1
038CA: 19d3     blo     #0x3900
038CC: 00e0     b       #0x38d0
038CE: 090a     lsrs    r1, r1, #8
038D0: c30b     lsrs    r3, r0, #0xf
038D2: 8b42     cmp     r3, r1
038D4: 01d3     blo     #0x38da
038D6: cb03     lsls    r3, r1, #0xf
038D8: c01a     subs    r0, r0, r3
038DA: 5241     adcs    r2, r2
038DC: 830b     lsrs    r3, r0, #0xe
038DE: 8b42     cmp     r3, r1
038E0: 01d3     blo     #0x38e6
038E2: 8b03     lsls    r3, r1, #0xe
038E4: c01a     subs    r0, r0, r3
038E6: 5241     adcs    r2, r2
038E8: 430b     lsrs    r3, r0, #0xd
038EA: 8b42     cmp     r3, r1
038EC: 01d3     blo     #0x38f2
038EE: 4b03     lsls    r3, r1, #0xd
038F0: c01a     subs    r0, r0, r3
038F2: 5241     adcs    r2, r2
038F4: 030b     lsrs    r3, r0, #0xc
038F6: 8b42     cmp     r3, r1
038F8: 01d3     blo     #0x38fe
038FA: 0b03     lsls    r3, r1, #0xc
038FC: c01a     subs    r0, r0, r3
038FE: 5241     adcs    r2, r2
03900: c30a     lsrs    r3, r0, #0xb
03902: 8b42     cmp     r3, r1
03904: 01d3     blo     #0x390a
03906: cb02     lsls    r3, r1, #0xb
03908: c01a     subs    r0, r0, r3
0390A: 5241     adcs    r2, r2
0390C: 830a     lsrs    r3, r0, #0xa
0390E: 8b42     cmp     r3, r1
03910: 01d3     blo     #0x3916
03912: 8b02     lsls    r3, r1, #0xa
03914: c01a     subs    r0, r0, r3
03916: 5241     adcs    r2, r2
03918: 430a     lsrs    r3, r0, #9
0391A: 8b42     cmp     r3, r1
0391C: 01d3     blo     #0x3922
0391E: 4b02     lsls    r3, r1, #9
03920: c01a     subs    r0, r0, r3
03922: 5241     adcs    r2, r2
03924: 030a     lsrs    r3, r0, #8
03926: 8b42     cmp     r3, r1
03928: 01d3     blo     #0x392e
0392A: 0b02     lsls    r3, r1, #8
0392C: c01a     subs    r0, r0, r3
0392E: 5241     adcs    r2, r2
03930: cdd2     bhs     #0x38ce
03932: c309     lsrs    r3, r0, #7
03934: 8b42     cmp     r3, r1
03936: 01d3     blo     #0x393c
03938: cb01     lsls    r3, r1, #7
0393A: c01a     subs    r0, r0, r3
0393C: 5241     adcs    r2, r2
0393E: 8309     lsrs    r3, r0, #6
03940: 8b42     cmp     r3, r1
03942: 01d3     blo     #0x3948
03944: 8b01     lsls    r3, r1, #6
03946: c01a     subs    r0, r0, r3
03948: 5241     adcs    r2, r2
0394A: 4309     lsrs    r3, r0, #5
0394C: 8b42     cmp     r3, r1
0394E: 01d3     blo     #0x3954
03950: 4b01     lsls    r3, r1, #5
03952: c01a     subs    r0, r0, r3
03954: 5241     adcs    r2, r2
03956: 0309     lsrs    r3, r0, #4
03958: 8b42     cmp     r3, r1
0395A: 01d3     blo     #0x3960
0395C: 0b01     lsls    r3, r1, #4
0395E: c01a     subs    r0, r0, r3
03960: 5241     adcs    r2, r2
03962: c308     lsrs    r3, r0, #3
03964: 8b42     cmp     r3, r1
03966: 01d3     blo     #0x396c
03968: cb00     lsls    r3, r1, #3
0396A: c01a     subs    r0, r0, r3
0396C: 5241     adcs    r2, r2
0396E: 8308     lsrs    r3, r0, #2
03970: 8b42     cmp     r3, r1
03972: 01d3     blo     #0x3978
03974: 8b00     lsls    r3, r1, #2
03976: c01a     subs    r0, r0, r3
03978: 5241     adcs    r2, r2
0397A: 4308     lsrs    r3, r0, #1
0397C: 8b42     cmp     r3, r1
0397E: 01d3     blo     #0x3984
03980: 4b00     lsls    r3, r1, #1
03982: c01a     subs    r0, r0, r3
03984: 5241     adcs    r2, r2
03986: 411a     subs    r1, r0, r1
03988: 00d2     bhs     #0x398c
0398A: 0146     mov     r1, r0
0398C: 5241     adcs    r2, r2
0398E: 1046     mov     r0, r2
03990: 7047     bx      lr
03992: ffe7     b       #0x3994
03994: 01b5     push    {r0, lr}
03996: 0020     movs    r0, #0
03998: 00f0f0f8 bl      #0x3b7c
0399C: 02bd     pop     {r1, pc}
0399E: c046     mov     r8, r8
039A0: 0029     cmp     r1, #0
039A2: f7d0     beq     #0x3994
039A4: 76e7     b       #0x3894
039A6: 7047     bx      lr
039A8: 0346     mov     r3, r0
039AA: 0b43     orrs    r3, r1
039AC: 7fd4     bmi     #0x3aae
039AE: 0022     movs    r2, #0
039B0: 4308     lsrs    r3, r0, #1
039B2: 8b42     cmp     r3, r1
039B4: 74d3     blo     #0x3aa0
039B6: 0309     lsrs    r3, r0, #4
039B8: 8b42     cmp     r3, r1
039BA: 5fd3     blo     #0x3a7c
039BC: 030a     lsrs    r3, r0, #8
039BE: 8b42     cmp     r3, r1
039C0: 44d3     blo     #0x3a4c
039C2: 030b     lsrs    r3, r0, #0xc
039C4: 8b42     cmp     r3, r1
039C6: 28d3     blo     #0x3a1a
039C8: 030c     lsrs    r3, r0, #0x10
039CA: 8b42     cmp     r3, r1
039CC: 0dd3     blo     #0x39ea
039CE: ff22     movs    r2, #0xff
039D0: 0902     lsls    r1, r1, #8
039D2: 12ba     rev     r2, r2
039D4: 030c     lsrs    r3, r0, #0x10
039D6: 8b42     cmp     r3, r1
039D8: 02d3     blo     #0x39e0
039DA: 1212     asrs    r2, r2, #8
039DC: 0902     lsls    r1, r1, #8
039DE: 65d0     beq     #0x3aac
039E0: 030b     lsrs    r3, r0, #0xc
039E2: 8b42     cmp     r3, r1
039E4: 19d3     blo     #0x3a1a
039E6: 00e0     b       #0x39ea
039E8: 090a     lsrs    r1, r1, #8
039EA: c30b     lsrs    r3, r0, #0xf
039EC: 8b42     cmp     r3, r1
039EE: 01d3     blo     #0x39f4
039F0: cb03     lsls    r3, r1, #0xf
039F2: c01a     subs    r0, r0, r3
039F4: 5241     adcs    r2, r2
039F6: 830b     lsrs    r3, r0, #0xe
039F8: 8b42     cmp     r3, r1
039FA: 01d3     blo     #0x3a00
039FC: 8b03     lsls    r3, r1, #0xe
039FE: c01a     subs    r0, r0, r3
03A00: 5241     adcs    r2, r2
03A02: 430b     lsrs    r3, r0, #0xd
03A04: 8b42     cmp     r3, r1
03A06: 01d3     blo     #0x3a0c
03A08: 4b03     lsls    r3, r1, #0xd
03A0A: c01a     subs    r0, r0, r3
03A0C: 5241     adcs    r2, r2
03A0E: 030b     lsrs    r3, r0, #0xc
03A10: 8b42     cmp     r3, r1
03A12: 01d3     blo     #0x3a18
03A14: 0b03     lsls    r3, r1, #0xc
03A16: c01a     subs    r0, r0, r3
03A18: 5241     adcs    r2, r2
03A1A: c30a     lsrs    r3, r0, #0xb
03A1C: 8b42     cmp     r3, r1
03A1E: 01d3     blo     #0x3a24
03A20: cb02     lsls    r3, r1, #0xb
03A22: c01a     subs    r0, r0, r3
03A24: 5241     adcs    r2, r2
03A26: 830a     lsrs    r3, r0, #0xa
03A28: 8b42     cmp     r3, r1
03A2A: 01d3     blo     #0x3a30
03A2C: 8b02     lsls    r3, r1, #0xa
03A2E: c01a     subs    r0, r0, r3
03A30: 5241     adcs    r2, r2
03A32: 430a     lsrs    r3, r0, #9
03A34: 8b42     cmp     r3, r1
03A36: 01d3     blo     #0x3a3c
03A38: 4b02     lsls    r3, r1, #9
03A3A: c01a     subs    r0, r0, r3
03A3C: 5241     adcs    r2, r2
03A3E: 030a     lsrs    r3, r0, #8
03A40: 8b42     cmp     r3, r1
03A42: 01d3     blo     #0x3a48
03A44: 0b02     lsls    r3, r1, #8
03A46: c01a     subs    r0, r0, r3
03A48: 5241     adcs    r2, r2
03A4A: cdd2     bhs     #0x39e8
03A4C: c309     lsrs    r3, r0, #7
03A4E: 8b42     cmp     r3, r1
03A50: 01d3     blo     #0x3a56
03A52: cb01     lsls    r3, r1, #7
03A54: c01a     subs    r0, r0, r3
03A56: 5241     adcs    r2, r2
03A58: 8309     lsrs    r3, r0, #6
03A5A: 8b42     cmp     r3, r1
03A5C: 01d3     blo     #0x3a62
03A5E: 8b01     lsls    r3, r1, #6
03A60: c01a     subs    r0, r0, r3
03A62: 5241     adcs    r2, r2
03A64: 4309     lsrs    r3, r0, #5
03A66: 8b42     cmp     r3, r1
03A68: 01d3     blo     #0x3a6e
03A6A: 4b01     lsls    r3, r1, #5
03A6C: c01a     subs    r0, r0, r3
03A6E: 5241     adcs    r2, r2
03A70: 0309     lsrs    r3, r0, #4
03A72: 8b42     cmp     r3, r1
03A74: 01d3     blo     #0x3a7a
03A76: 0b01     lsls    r3, r1, #4
03A78: c01a     subs    r0, r0, r3
03A7A: 5241     adcs    r2, r2
03A7C: c308     lsrs    r3, r0, #3
03A7E: 8b42     cmp     r3, r1
03A80: 01d3     blo     #0x3a86
03A82: cb00     lsls    r3, r1, #3
03A84: c01a     subs    r0, r0, r3
03A86: 5241     adcs    r2, r2
03A88: 8308     lsrs    r3, r0, #2
03A8A: 8b42     cmp     r3, r1
03A8C: 01d3     blo     #0x3a92
03A8E: 8b00     lsls    r3, r1, #2
03A90: c01a     subs    r0, r0, r3
03A92: 5241     adcs    r2, r2
03A94: 4308     lsrs    r3, r0, #1
03A96: 8b42     cmp     r3, r1
03A98: 01d3     blo     #0x3a9e
03A9A: 4b00     lsls    r3, r1, #1
03A9C: c01a     subs    r0, r0, r3
03A9E: 5241     adcs    r2, r2
03AA0: 411a     subs    r1, r0, r1
03AA2: 00d2     bhs     #0x3aa6
03AA4: 0146     mov     r1, r0
03AA6: 5241     adcs    r2, r2
03AA8: 1046     mov     r0, r2
03AAA: 7047     bx      lr
03AAC: 5de0     b       #0x3b6a
03AAE: ca0f     lsrs    r2, r1, #0x1f
03AB0: 00d0     beq     #0x3ab4
03AB2: 4942     rsbs    r1, r1, #0
03AB4: 0310     asrs    r3, r0, #0x20
03AB6: 00d3     blo     #0x3aba
03AB8: 4042     rsbs    r0, r0, #0
03ABA: 5340     eors    r3, r2
03ABC: 0022     movs    r2, #0
03ABE: 9c46     mov     ip, r3
03AC0: 0309     lsrs    r3, r0, #4
03AC2: 8b42     cmp     r3, r1
03AC4: 2dd3     blo     #0x3b22
03AC6: 030a     lsrs    r3, r0, #8
03AC8: 8b42     cmp     r3, r1
03ACA: 12d3     blo     #0x3af2
03ACC: fc22     movs    r2, #0xfc
03ACE: 8901     lsls    r1, r1, #6
03AD0: 12ba     rev     r2, r2
03AD2: 030a     lsrs    r3, r0, #8
03AD4: 8b42     cmp     r3, r1
03AD6: 0cd3     blo     #0x3af2
03AD8: 8901     lsls    r1, r1, #6
03ADA: 9211     asrs    r2, r2, #6
03ADC: 8b42     cmp     r3, r1
03ADE: 08d3     blo     #0x3af2
03AE0: 8901     lsls    r1, r1, #6
03AE2: 9211     asrs    r2, r2, #6
03AE4: 8b42     cmp     r3, r1
03AE6: 04d3     blo     #0x3af2
03AE8: 8901     lsls    r1, r1, #6
03AEA: 3ad0     beq     #0x3b62
03AEC: 9211     asrs    r2, r2, #6
03AEE: 00e0     b       #0x3af2
03AF0: 8909     lsrs    r1, r1, #6
03AF2: c309     lsrs    r3, r0, #7
03AF4: 8b42     cmp     r3, r1
03AF6: 01d3     blo     #0x3afc
03AF8: cb01     lsls    r3, r1, #7
03AFA: c01a     subs    r0, r0, r3
03AFC: 5241     adcs    r2, r2
03AFE: 8309     lsrs    r3, r0, #6
03B00: 8b42     cmp     r3, r1
03B02: 01d3     blo     #0x3b08
03B04: 8b01     lsls    r3, r1, #6
03B06: c01a     subs    r0, r0, r3
03B08: 5241     adcs    r2, r2
03B0A: 4309     lsrs    r3, r0, #5
03B0C: 8b42     cmp     r3, r1
03B0E: 01d3     blo     #0x3b14
03B10: 4b01     lsls    r3, r1, #5
03B12: c01a     subs    r0, r0, r3
03B14: 5241     adcs    r2, r2
03B16: 0309     lsrs    r3, r0, #4
03B18: 8b42     cmp     r3, r1
03B1A: 01d3     blo     #0x3b20
03B1C: 0b01     lsls    r3, r1, #4
03B1E: c01a     subs    r0, r0, r3
03B20: 5241     adcs    r2, r2
03B22: c308     lsrs    r3, r0, #3
03B24: 8b42     cmp     r3, r1
03B26: 01d3     blo     #0x3b2c
03B28: cb00     lsls    r3, r1, #3
03B2A: c01a     subs    r0, r0, r3
03B2C: 5241     adcs    r2, r2
03B2E: 8308     lsrs    r3, r0, #2
03B30: 8b42     cmp     r3, r1
03B32: 01d3     blo     #0x3b38
03B34: 8b00     lsls    r3, r1, #2
03B36: c01a     subs    r0, r0, r3
03B38: 5241     adcs    r2, r2
03B3A: d9d2     bhs     #0x3af0
03B3C: 4308     lsrs    r3, r0, #1
03B3E: 8b42     cmp     r3, r1
03B40: 01d3     blo     #0x3b46
03B42: 4b00     lsls    r3, r1, #1
03B44: c01a     subs    r0, r0, r3
03B46: 5241     adcs    r2, r2
03B48: 411a     subs    r1, r0, r1
03B4A: 00d2     bhs     #0x3b4e
03B4C: 0146     mov     r1, r0
03B4E: 6346     mov     r3, ip
03B50: 5241     adcs    r2, r2
03B52: 5b10     asrs    r3, r3, #1
03B54: 1046     mov     r0, r2
03B56: 01d3     blo     #0x3b5c
03B58: 4042     rsbs    r0, r0, #0
03B5A: 002b     cmp     r3, #0
03B5C: 00d5     bpl     #0x3b60
03B5E: 4942     rsbs    r1, r1, #0
03B60: 7047     bx      lr
03B62: 6346     mov     r3, ip
03B64: 5b10     asrs    r3, r3, #1
03B66: 00d3     blo     #0x3b6a
03B68: 4042     rsbs    r0, r0, #0
03B6A: 01b5     push    {r0, lr}
03B6C: 0020     movs    r0, #0
03B6E: 00f005f8 bl      #0x3b7c
03B72: 02bd     pop     {r1, pc}
03B74: 0029     cmp     r1, #0
03B76: f8d0     beq     #0x3b6a
03B78: 16e7     b       #0x39a8
03B7A: 7047     bx      lr
03B7C: 7047     bx      lr
03B7E: c046     mov     r8, r8
03B80: 014b     ldr     r3, [pc, #4]
03B82: 1868     ldr     r0, [r3]
03B84: 7047     bx      lr
03B86: c046     mov     r8, r8
03B88: f400     lsls    r4, r6, #3
03B8A: 0020     movs    r0, #0
03B8C: 0e4b     ldr     r3, [pc, #0x38]
03B8E: 70b5     push    {r4, r5, r6, lr}
03B90: 0025     movs    r5, #0
03B92: 1e00     movs    r6, r3
03B94: 0d4c     ldr     r4, [pc, #0x34]
03B96: e41a     subs    r4, r4, r3
03B98: a410     asrs    r4, r4, #2
03B9A: a542     cmp     r5, r4
03B9C: 04d0     beq     #0x3ba8
03B9E: ab00     lsls    r3, r5, #2
03BA0: f358     ldr     r3, [r6, r3]
03BA2: 9847     blx     r3
03BA4: 0135     adds    r5, #1
03BA6: f8e7     b       #0x3b9a
03BA8: 00f0b6f8 bl      #0x3d18
03BAC: 084b     ldr     r3, [pc, #0x20]
03BAE: 0025     movs    r5, #0
03BB0: 1e00     movs    r6, r3
03BB2: 084c     ldr     r4, [pc, #0x20]
03BB4: e41a     subs    r4, r4, r3
03BB6: a410     asrs    r4, r4, #2
03BB8: a542     cmp     r5, r4
03BBA: 04d0     beq     #0x3bc6
03BBC: ab00     lsls    r3, r5, #2
03BBE: f358     ldr     r3, [r6, r3]
03BC0: 9847     blx     r3
03BC2: 0135     adds    r5, #1
03BC4: f8e7     b       #0x3bb8
03BC6: 70bd     pop     {r4, r5, r6, pc}
03BC8: 243d     subs    r5, #0x24
03BCA: 0000     movs    r0, r0
03BCC: 243d     subs    r5, #0x24
03BCE: 0000     movs    r0, r0
03BD0: 243d     subs    r5, #0x24
03BD2: 0000     movs    r0, r0
03BD4: 2c3d     subs    r5, #0x2c
03BD6: 0000     movs    r0, r0
03BD8: 0023     movs    r3, #0
03BDA: 10b5     push    {r4, lr}
03BDC: 9a42     cmp     r2, r3
03BDE: 03d0     beq     #0x3be8
03BE0: cc5c     ldrb    r4, [r1, r3]
03BE2: c454     strb    r4, [r0, r3]
03BE4: 0133     adds    r3, #1
03BE6: f9e7     b       #0x3bdc
03BE8: 10bd     pop     {r4, pc}
03BEA: 0300     movs    r3, r0
03BEC: 8218     adds    r2, r0, r2
03BEE: 9342     cmp     r3, r2
03BF0: 02d0     beq     #0x3bf8
03BF2: 1970     strb    r1, [r3]
03BF4: 0133     adds    r3, #1
03BF6: fae7     b       #0x3bee
03BF8: 7047     bx      lr
03BFA: 0000     movs    r0, r0
03BFC: 0000     movs    r0, r0
03BFE: 0000     movs    r0, r0
03C00: 0e00     movs    r6, r1
03C02: 7c01     lsls    r4, r7, #5
03C04: 6464     str     r4, [r4, #0x44]
03C06: 0a02     lsls    r2, r1, #8
03C08: 0f64     str     r7, [r1, #0x40]
03C0A: 2002     lsls    r0, r4, #8
03C0C: 0000     movs    r0, r0
03C0E: ffff .hword
03C10: 0e00     movs    r6, r1
03C12: 3700     movs    r7, r6
03C14: 1e1e     subs    r6, r3, #0
03C16: 0501     lsls    r5, r0, #4
03C18: 1464     str     r4, [r2, #0x40]
03C1A: 2002     lsls    r0, r4, #8
03C1C: 0000     movs    r0, r0
03C1E: 3700     movs    r7, r6
03C20: 6c3c     subs    r4, #0x6c
03C22: 0000     movs    r0, r0
03C24: 8e01     lsls    r6, r1, #6
03C26: 0020     movs    r0, #0
03C28: ae01     lsls    r6, r5, #6
03C2A: 0020     movs    r0, #0
03C2C: 2a01     lsls    r2, r5, #4
03C2E: 0020     movs    r0, #0
03C30: 3201     lsls    r2, r6, #4
03C32: 0020     movs    r0, #0
03C34: 8900     lsls    r1, r1, #2
03C36: 0300     movs    r3, r0
03C38: 0203     lsls    r2, r0, #0xc
03C3A: 9000     lsls    r0, r2, #2
03C3C: 0048     ldr     r0, [pc, #0]
03C3E: 0000     movs    r0, r0
03C40: 2601     lsls    r6, r4, #4
03C42: 0020     movs    r0, #0
03C44: 683c     subs    r4, #0x68
03C46: 0000     movs    r0, r0
03C48: 9e01     lsls    r6, r3, #6
03C4A: 0020     movs    r0, #0
03C4C: d801     lsls    r0, r3, #7
03C4E: 0020     movs    r0, #0
03C50: 0000     movs    r0, r0
03C52: 0000     movs    r0, r0
03C54: 3001     lsls    r0, r6, #4
03C56: 0020     movs    r0, #0
03C58: 0500     movs    r5, r0
03C5A: 0100     movs    r1, r0
03C5C: 0601     lsls    r6, r0, #4
03C5E: 0000     movs    r0, r0
03C60: 0000     movs    r0, r0
03C62: 0000     movs    r0, r0
03C64: 0000     movs    r0, r0
03C66: 0000     movs    r0, r0
03C68: 0300     movs    r3, r0
03C6A: 0301     lsls    r3, r0, #4
03C6C: 0000     movs    r0, r0
03C6E: 0240     ands    r2, r0
03C70: 0800     movs    r0, r1
03C72: 0440     ands    r4, r0
03C74: 0000     movs    r0, r0
03C76: 0440     ands    r4, r0
03C78: 0400     movs    r4, r0
03C7A: 0440     ands    r4, r0
03C7C: f000     lsls    r0, r6, #3
03C7E: 0000     movs    r0, r0
03C80: 0200     movs    r2, r0
03C82: 0000     movs    r0, r0
03C84: 0401     lsls    r4, r0, #4
03C86: 0300     movs    r3, r0
03C88: 0000     movs    r0, r0
03C8A: 0240     ands    r2, r0
03C8C: 0800     movs    r0, r1
03C8E: 0440     ands    r4, r0
03C90: 0000     movs    r0, r0
03C92: 0440     ands    r4, r0
03C94: 0400     movs    r4, r0
03C96: 0440     ands    r4, r0
03C98: 000f     lsrs    r0, r0, #0x1c
03C9A: 0000     movs    r0, r0
03C9C: 0400     movs    r4, r0
03C9E: 0000     movs    r0, r0
03CA0: 0802     lsls    r0, r1, #8
03CA2: 0600     movs    r6, r0
03CA4: 0001     lsls    r0, r0, #4
03CA6: 0240     ands    r2, r0
03CA8: 0801     lsls    r0, r1, #4
03CAA: 0440     ands    r4, r0
03CAC: 0001     lsls    r0, r0, #4
03CAE: 0440     ands    r4, r0
03CB0: 0401     lsls    r4, r0, #4
03CB2: 0440     ands    r4, r0
03CB4: 0000     movs    r0, r0
03CB6: 00f08000 and     r0, r0, #0x80
03CBA: 0000     movs    r0, r0
03CBC: 1c07     lsls    r4, r3, #0x1c
03CBE: 1500     movs    r5, r2
03CC0: 0000     movs    r0, r0
03CC2: 0240     ands    r2, r0
03CC4: 0800     movs    r0, r1
03CC6: 0440     ands    r4, r0
03CC8: 0000     movs    r0, r0
03CCA: 0440     ands    r4, r0
03CCC: 0400     movs    r4, r0
03CCE: 0440     ands    r4, r0
03CD0: f000     lsls    r0, r6, #3
03CD2: 0000     movs    r0, r0
03CD4: 0200     movs    r2, r0
03CD6: 0000     movs    r0, r0
03CD8: 0401     lsls    r4, r0, #4
03CDA: 0300     movs    r3, r0
03CDC: 0000     movs    r0, r0
03CDE: 0240     ands    r2, r0
03CE0: 0800     movs    r0, r1
03CE2: 0440     ands    r4, r0
03CE4: 0000     movs    r0, r0
03CE6: 0440     ands    r4, r0
03CE8: 0400     movs    r4, r0
03CEA: 0440     ands    r4, r0
03CEC: 000f     lsrs    r0, r0, #0x1c
03CEE: 0000     movs    r0, r0
03CF0: 0400     movs    r4, r0
03CF2: 0000     movs    r0, r0
03CF4: 0802     lsls    r0, r1, #8
03CF6: 0600     movs    r6, r0
03CF8: 0001     lsls    r0, r0, #4
03CFA: 0240     ands    r2, r0
03CFC: 0801     lsls    r0, r1, #4
03CFE: 0440     ands    r4, r0
03D00: 0001     lsls    r0, r0, #4
03D02: 0440     ands    r4, r0
03D04: 0401     lsls    r4, r0, #4
03D06: 0440     ands    r4, r0
03D08: 0000     movs    r0, r0
03D0A: 00f08000 and     r0, r0, #0x80
03D0E: 0000     movs    r0, r0
03D10: 1c07     lsls    r4, r3, #0x1c
03D12: 1500     movs    r5, r2
03D14: 0043     orrs    r0, r0
03D16: 0000     movs    r0, r0
03D18: f8b5     push    {r3, r4, r5, r6, r7, lr}
03D1A: c046     mov     r8, r8
03D1C: f8bc     pop     {r3, r4, r5, r6, r7}
03D1E: 08bc     pop     {r3}
03D20: 9e46     mov     lr, r3
03D22: 7047     bx      lr
03D24: 7118     adds    r1, r6, r1
03D26: 0000     movs    r0, r0
03D28: b11c     adds    r1, r6, #2
03D2A: 0000     movs    r0, r0
03D2C: f8b5     push    {r3, r4, r5, r6, r7, lr}
03D2E: c046     mov     r8, r8
03D30: f8bc     pop     {r3, r4, r5, r6, r7}
03D32: 08bc     pop     {r3}
03D34: 9e46     mov     lr, r3
03D36: 7047     bx      lr
03D38: 4918     adds    r1, r1, r1
03D3A: 0000     movs    r0, r0
03D3C: 503d     subs    r5, #0x50
03D3E: 0000     movs    r0, r0
03D40: 7000     lsls    r0, r6, #1
03D42: 0020     movs    r0, #0
03D44: 8800     lsls    r0, r1, #2
03D46: 0000     movs    r0, r0
03D48: 1001     lsls    r0, r2, #4
03D4A: 0000     movs    r0, r0
03D4C: 0000     movs    r0, r0
03D4E: 0000     movs    r0, r0
03D50: 0000     movs    r0, r0
03D52: 0000     movs    r0, r0
03D54: 2003     lsls    r0, r4, #0xc
03D56: 0000     movs    r0, r0
03D58: 0008     lsrs    r0, r0, #0x20
03D5A: c001     lsls    r0, r0, #7
03D5C: 0000     movs    r0, r0
03D5E: ff0f     lsrs    r7, r7, #0x1f
03D60: 0100     movs    r1, r0
03D62: 0000     movs    r0, r0
03D64: 0000     movs    r0, r0
03D66: 7017     asrs    r0, r6, #0x1d
03D68: e02e     cmp     r6, #0xe0
03D6A: 0000     movs    r0, r0
03D6C: 0c00     movs    r4, r1
03D6E: 0000     movs    r0, r0
03D70: 001b     subs    r0, r0, r4
03D72: b700     lsls    r7, r6, #2
03D74: 0000     movs    r0, r0
03D76: 0000     movs    r0, r0
03D78: 0000     movs    r0, r0
03D7A: 0000     movs    r0, r0
03D7C: 0000     movs    r0, r0
03D7E: 0000     movs    r0, r0
03D80: 0000     movs    r0, r0
03D82: 0000     movs    r0, r0
03D84: 0000     movs    r0, r0
03D86: 0000     movs    r0, r0
03D88: 0000     movs    r0, r0
03D8A: 0000     movs    r0, r0
03D8C: 0000     movs    r0, r0
03D8E: 0000     movs    r0, r0
03D90: 0000     movs    r0, r0
03D92: 0000     movs    r0, r0
03D94: 153d     subs    r5, #0x15
03D96: 0000     movs    r0, r0
03D98: 0000     movs    r0, r0
03D9A: 0000     movs    r0, r0
03D9C: 0000     movs    r0, r0
03D9E: 0000     movs    r0, r0
03DA0: 0000     movs    r0, r0
03DA2: 0000     movs    r0, r0
03DA4: 0000     movs    r0, r0
03DA6: 0000     movs    r0, r0
03DA8: 0000     movs    r0, r0
03DAA: 0000     movs    r0, r0
03DAC: 0000     movs    r0, r0
03DAE: 0000     movs    r0, r0
03DB0: 0000     movs    r0, r0
03DB2: 0000     movs    r0, r0
03DB4: 0000     movs    r0, r0
03DB6: 0000     movs    r0, r0
03DB8: 0000     movs    r0, r0
03DBA: 0000     movs    r0, r0
03DBC: 0000     movs    r0, r0
03DBE: 0000     movs    r0, r0
03DC0: 0000     movs    r0, r0
03DC2: 0000     movs    r0, r0
03DC4: 0000     movs    r0, r0
03DC6: 0000     movs    r0, r0
03DC8: 0000     movs    r0, r0
03DCA: 0000     movs    r0, r0
03DCC: 0000     movs    r0, r0
03DCE: 0000     movs    r0, r0
03DD0: 0000     movs    r0, r0
03DD2: 0000     movs    r0, r0
03DD4: 9400     lsls    r4, r2, #2
03DD6: 0020     movs    r0, #0
03DD8: 0000     movs    r0, r0
03DDA: 0000     movs    r0, r0
03DDC: 0000     movs    r0, r0
03DDE: 0000     movs    r0, r0
03DE0: 0000     movs    r0, r0
03DE2: 0000     movs    r0, r0
03DE4: 0000     movs    r0, r0
03DE6: 0000     movs    r0, r0
03DE8: 0000     movs    r0, r0
03DEA: 0000     movs    r0, r0
03DEC: 0000     movs    r0, r0
03DEE: 0000     movs    r0, r0
03DF0: 0000     movs    r0, r0
03DF2: 0000     movs    r0, r0
03DF4: 0000     movs    r0, r0
03DF6: 0000     movs    r0, r0
03DF8: 0000     movs    r0, r0
03DFA: 0000     movs    r0, r0
03DFC: 0000     movs    r0, r0
03DFE: 0000     movs    r0, r0


...

/* 0003EC A400042C 8FB6000C */  lw          $s6, 0xc($sp) # s6 = *(sp + 0xc) (same s6 as at 0xA40000E8 afaict, from ipl2) = ("encrypted seed value" >> 8) & 0xFF

...

/* 0004A0 A40004E0 254A0000 */  addiu       $t2, $t2, %lo(D_A4000000) # t2 = D_A4000000
/* 0004A4 A40004E4 3C0BFFF0 */  lui         $t3, 0xfff0 # t3 = 0xfff00000
/* 0004A8 A40004E8 3C090010 */  lui         $t1, 0x10 # t1 = 0x100000
/* 0004AC A40004EC 014B5024 */  and         $t2, $t2, $t3 # t2 = D_A4000000 & 0xfff00000 = 0xA4000000
/* 0004B0 A40004F0 3C08A400 */  lui         $t0, %hi(func_A4000554)
/* 0004B4 A40004F4 2529FFFF */  addiu       $t1, $t1, -0x1 # t1 = 0xfffff
/* 0004B8 A40004F8 3C0BA400 */  lui         $t3, %hi(D_A4000888)
/* 0004BC A40004FC 25080554 */  addiu       $t0, $t0, %lo(func_A4000554) # t0 = func_A4000554
/* 0004C0 A4000500 256B0888 */  addiu       $t3, $t3, %lo(D_A4000888) # t3 = D_A4000888
/* 0004C4 A4000504 01094024 */  and         $t0, $t0, $t1 # t0 = func_A4000554 & 0xfffff = 0x554
/* 0004C8 A4000508 01695824 */  and         $t3, $t3, $t1 # t3 = D_A4000888 & 0xfffff = 0x888
/* 0004CC A400050C 3C01A408 */  lui         $at, %hi(D_A4080000)
/* 0004D0 A4000510 3C09A000 */  lui         $t1, %hi(D_A0000004)
/* 0004D4 A4000514 AC200000 */  sw          $zero, %lo(D_A4080000)($at) # SP_PC = 0
/* 0004D8 A4000518 010A4025 */  or          $t0, $t0, $t2 # t0 = 0x554 | 0xA4000000 = 0xA4000554
/* 0004DC A400051C 016A5825 */  or          $t3, $t3, $t2 # t3 = 0x888 | 0xA4000000 = 0xA4000888
/* 0004E0 A4000520 25290004 */  addiu       $t1, $t1, %lo(D_A0000004) # t1 = D_A0000004
1: # copy [0xA4000554 ; 0xA4000888[ to 0xA0000004 (move from dmem to rdram)
/* 0004E4 A4000524 8D0D0000 */  lw          $t5, 0x0($t0) # t5 = *t0
/* 0004E8 A4000528 25080004 */  addiu       $t0, $t0, 0x4 # t0 += 4
/* 0004EC A400052C 010B082B */  sltu        $at, $t0, $t3 # at = (t0 < t3)
/* 0004F0 A4000530 25290004 */  addiu       $t1, $t1, 0x4 # t1 += 4
/* 0004F4 A4000534 1420FFFB */  bnez        $at, 1b # continue if t0 < t3
/* 0004F8 A4000538 AD2DFFFC */   sw         $t5, -0x4($t1) # *(t1 - 4) = t5
/* 0004FC A400053C 3C0C8000 */  lui         $t4, %hi(jtbl_80000004)
/* 000500 A4000540 240A00AD */  addiu       $t2, $zero, 0xad # t2 = 0xad
/* 000504 A4000544 3C01A404 */  lui         $at, %hi(D_A4040010)
/* 000508 A4000548 258C0004 */  addiu       $t4, $t4, %lo(jtbl_80000004)
/* 00050C A400054C 01800008 */  jr          $t4 # j 0x80000004 (func_A4000554)
/* 000510 A4000550 AC2A0010 */   sw         $t2, %lo(D_A4040010)($at) # SP_STATUS = t2 = 0xad = clr_halt | clr_broke | clr_intr | clr_sstep | clr_intbreak

/* Handwritten function */
glabel func_A4000554 # 1
/* 000514 A4000554 3C0BB000 */  lui         $t3, %hi(jtbl_B0000008) # t3 = 0xB0000000
/* 000518 A4000558 8D690008 */  lw          $t1, %lo(jtbl_B0000008)($t3) # t1 = initial PC
/* 00051C A400055C 3C0A1FFF */  lui         $t2, (0x1FFFFFFF >> 16)
/* 000520 A4000560 354AFFFF */  ori         $t2, $t2, (0x1FFFFFFF & 0xFFFF) # t2 = 0x1FFFFFFF
/* 000524 A4000564 3C01A460 */  lui         $at, %hi(D_A4600000)
/* 000528 A4000568 012A4824 */  and         $t1, $t1, $t2
/* 00052C A400056C AC290000 */  sw          $t1, %lo(D_A4600000)($at) # PI_DRAM_ADDR_REG = t1
/* 000530 A4000570 3C08A460 */  lui         $t0, %hi(D_A4600010)
1: # wait PI not IO busy
/* 000534 A4000574 8D080010 */  lw          $t0, %lo(D_A4600010)($t0) # t0 = PI_STATUS_REG
/* 000538 A4000578 31080002 */  andi        $t0, $t0, 0x2 # t0 = PI_STATUS_REG & "IO Busy"
/* 00053C A400057C 5500FFFD */  bnel        $t0, $zero, 1b
/* 000540 A4000580 3C08A460 */   lui        $t0, %hi(D_A4600010)
/* 000544 A4000584 24081000 */  addiu       $t0, $zero, 0x1000 # t0 = 0x1000
/* 000548 A4000588 010B4020 */  add         $t0, $t0, $t3 # t0 += t3=0xB0000000
/* 00054C A400058C 010A4024 */  and         $t0, $t0, $t2 # t0 &= t2=0x1FFFFFFF (t0 = (0xB0001000) & 0x1FFFFFFF = 0x10001000)
/* 000550 A4000590 3C01A460 */  lui         $at, %hi(D_A4600004)
/* 000554 A4000594 AC280004 */  sw          $t0, %lo(D_A4600004)($at) # PI_CART_ADDR_REG = 0x10001000
/* 000558 A4000598 3C0A0010 */  lui         $t2, 0x10 # t2 = 1MB
/* 00055C A400059C 254AFFFF */  addiu       $t2, $t2, -0x1
/* 000560 A40005A0 3C01A460 */  lui         $at, %hi(D_A460000C)
/* 000564 A40005A4 AC2A000C */  sw          $t2, %lo(D_A460000C)($at) # PI_WR_LEN_REG = 1MB - 1
1: # wait PI not DMA busy
/* 000568 A40005A8 00000000 */  nop
/* 00056C A40005AC 00000000 */  nop
/* 000570 A40005B0 00000000 */  nop
/* 000574 A40005B4 00000000 */  nop
/* 000578 A40005B8 00000000 */  nop
/* 00057C A40005BC 00000000 */  nop
/* 000580 A40005C0 00000000 */  nop
/* 000584 A40005C4 00000000 */  nop
/* 000588 A40005C8 00000000 */  nop
/* 00058C A40005CC 00000000 */  nop
/* 000590 A40005D0 00000000 */  nop
/* 000594 A40005D4 00000000 */  nop
/* 000598 A40005D8 00000000 */  nop
/* 00059C A40005DC 00000000 */  nop
/* 0005A0 A40005E0 00000000 */  nop
/* 0005A4 A40005E4 00000000 */  nop
/* 0005A8 A40005E8 3C0BA460 */  lui         $t3, %hi(D_A4600010)
/* 0005AC A40005EC 8D6B0010 */  lw          $t3, %lo(D_A4600010)($t3) # t3 = PI_STATUS_REG
/* 0005B0 A40005F0 316B0001 */  andi        $t3, $t3, 0x1 # t3 = PI_STATUS_REG & "DMA busy"
/* 0005B4 A40005F4 1560FFEC */  bnez        $t3, 1b
/* 0005B8 A40005F8 00000000 */   nop
/* 0005BC A40005FC 3C01A404 */  lui         $at, %hi(D_A404001C)
/* 0005C0 A4000600 AC20001C */  sw          $zero, %lo(D_A404001C)($at) # SP_SEMAPHORE = 0
/* 0005C4 A4000604 3C0BB000 */  lui         $t3, %hi(jtbl_B0000008)
/* 0005C8 A4000608 8D640008 */  lw          $a0, %lo(jtbl_B0000008)($t3) # a0 = *0xB0000008 = initial PC (rom header + 0x8)
/* 0005CC A400060C 02C02825 */  move        $a1, $s6 # a1 = s6
/* 0005D0 A4000610 3C015D58 */  lui         $at, (0x5D588B65 >> 16)
/* 0005D4 A4000614 34218B65 */  ori         $at, $at, (0x5D588B65 & 0xFFFF) # at = 0x5D588B65
/* 0005D8 A4000618 00A10019 */  multu       $a1, $at
/* 0005DC A400061C 27BDFFE0 */  addiu       $sp, $sp, -0x20 # sp -= 0x20
/* 0005E0 A4000620 AFBF001C */  sw          $ra, 0x1c($sp)
/* 0005E4 A4000624 AFB00014 */  sw          $s0, 0x14($sp)
/* 0005E8 A4000628 3C16A000 */  lui         $s6, %hi(D_A0000200)
/* 0005EC A400062C 26D60200 */  addiu       $s6, $s6, %lo(D_A0000200) # s6 = 0xA0000200
/* 0005F0 A4000630 3C1F0010 */  lui         $ra, 0x10 # ra = 0x100000 (1MB)
/* 0005F4 A4000634 00001825 */  move        $v1, $zero
/* 0005F8 A4000638 00004025 */  move        $t0, $zero # t0 = 0
/* 0005FC A400063C 00804825 */  move        $t1, $a0 # t1 = a0 = initial PC = address of first byte from the copied 1MB of rom
/* 000600 A4000640 00001012 */  mflo        $v0 # v0 = (lo(a1 * at) above)
/* 000604 A4000644 24420001 */  addiu       $v0, $v0, 0x1 # v0 += 1
/* 000608 A4000648 00403825 */  move        $a3, $v0 # a3 = v0
/* 00060C A400064C 00405025 */  move        $t2, $v0 # t2 = v0
/* 000610 A4000650 00405825 */  move        $t3, $v0 # t3 = v0
/* 000614 A4000654 00408025 */  move        $s0, $v0 # s0 = v0
/* 000618 A4000658 00403025 */  move        $a2, $v0 # a2 = v0
/* 00061C A400065C 00406025 */  move        $t4, $v0 # t4 = v0
/* 000620 A4000660 240D0020 */  addiu       $t5, $zero, 0x20 # t5 = 0x20
.checksum_loop:
/* 000624 A4000664 8D220000 */  lw          $v0, 0x0($t1) # v0 = *t1
/* 000628 A4000668 00E21821 */  addu        $v1, $a3, $v0 # v1 = a3 + v0
/* 00062C A400066C 0067082B */  sltu        $at, $v1, $a3 # at = (v1 < a3)
/* 000630 A4000670 10200002 */  beqz        $at, 1f # if (v1 < a3) then t2 +=1 else don't
/* 000634 A4000674 00602825 */   move       $a1, $v1 # a1 = v1
/* 000638 A4000678 254A0001 */  addiu       $t2, $t2, 0x1 # t2 += 1
1:
/* 00063C A400067C 3043001F */  andi        $v1, $v0, 0x1f # v1 = v0 & 0x1f
/* 000640 A4000680 01A37823 */  subu        $t7, $t5, $v1 # t7 = t5 - v1
/* 000644 A4000684 01E2C006 */  srlv        $t8, $v0, $t7 # t8 = v0 >> t7
/* 000648 A4000688 00627004 */  sllv        $t6, $v0, $v1 # t6 = v0 << v1
/* 00064C A400068C 01D82025 */  or          $a0, $t6, $t8 # a0 = t6 | t8
/* 000650 A4000690 00C2082B */  sltu        $at, $a2, $v0 # at = (a2 < v0)
/* 000654 A4000694 00A03825 */  move        $a3, $a1 # a3 = a1
/* 000658 A4000698 01625826 */  xor         $t3, $t3, $v0 # t3 ^= v0
/* 00065C A400069C 10200004 */  beqz        $at, 1f
/* 000660 A40006A0 02048021 */   addu       $s0, $s0, $a0 # s0 += a0
/* 000664 A40006A4 00E2C826 */  xor         $t9, $a3, $v0 # t9 = a3 ^ v0
/* 000668 A40006A8 10000002 */  b           2f
/* 00066C A40006AC 03263026 */   xor        $a2, $t9, $a2 # a2 ^= t9
1:
/* 000670 A40006B0 00C43026 */  xor         $a2, $a2, $a0 # a2 ^= a0
2:
/* 000674 A40006B4 8ECF0000 */  lw          $t7, 0x0($s6) # t7 = *s6
/* 000678 A40006B8 25080004 */  addiu       $t0, $t0, 0x4 # t0 += 4
/* 00067C A40006BC 26D60004 */  addiu       $s6, $s6, 0x4 # s6 += 4
/* 000680 A40006C0 004F7826 */  xor         $t7, $v0, $t7 # t7 ^= v0
/* 000684 A40006C4 01EC6021 */  addu        $t4, $t7, $t4 # t4 += t7
/* 000688 A40006C8 3C0FA000 */  lui         $t7, (0xA00002FF >> 16)
/* 00068C A40006CC 35EF02FF */  ori         $t7, $t7, (0xA00002FF & 0xFFFF) # t7 = 0xA00002FF
/* 000690 A40006D0 25290004 */  addiu       $t1, $t1, 0x4 # t1 += 4
/* 000694 A40006D4 151FFFE3 */  bne         $t0, $ra, .checksum_loop
/* 000698 A40006D8 02CFB024 */   and        $s6, $s6, $t7 # s6 &= t7
/* 00069C A40006DC 00EA7026 */  xor         $t6, $a3, $t2 # t6 = a3 ^ t2
/* 0006A0 A40006E0 01CB3826 */  xor         $a3, $t6, $t3 # a3 = t6 ^ t3
/* 0006A4 A40006E4 3C0B00AA */  lui         $t3, (0xAAAAAE >> 16)
/* 0006A8 A40006E8 356BAAAE */  ori         $t3, $t3, (0xAAAAAE & 0xFFFF)
/* 0006AC A40006EC 3C01A404 */  lui         $at, %hi(D_A4040010)
/* 0006B0 A40006F0 AC2B0010 */  sw          $t3, %lo(D_A4040010)($at)
/* 0006B4 A40006F4 3C01A430 */  lui         $at, %hi(D_A430000C)
/* 0006B8 A40006F8 24080555 */  addiu       $t0, $zero, 0x555
/* 0006BC A40006FC AC28000C */  sw          $t0, %lo(D_A430000C)($at)
/* 0006C0 A4000700 3C01A480 */  lui         $at, %hi(D_A4800018)
/* 0006C4 A4000704 AC200018 */  sw          $zero, %lo(D_A4800018)($at)
/* 0006C8 A4000708 3C01A450 */  lui         $at, %hi(D_A450000C)
/* 0006CC A400070C AC20000C */  sw          $zero, %lo(D_A450000C)($at)
/* 0006D0 A4000710 3C01A430 */  lui         $at, %hi(D_A4300000)
/* 0006D4 A4000714 24090800 */  addiu       $t1, $zero, 0x800
/* 0006D8 A4000718 AC290000 */  sw          $t1, %lo(D_A4300000)($at)
/* 0006DC A400071C 24090002 */  addiu       $t1, $zero, 0x2
/* 0006E0 A4000720 3C01A460 */  lui         $at, %hi(D_A4600010)
/* 0006E4 A4000724 AC290010 */  sw          $t1, %lo(D_A4600010)($at)
/* 0006E8 A4000728 3C08A000 */  lui         $t0, (0xA0000300 >> 16)
/* 0006EC A400072C 35080300 */  ori         $t0, $t0, (0xA0000300 & 0xFFFF)
/* 0006F0 A4000730 0206C026 */  xor         $t8, $s0, $a2 # t8 = s0 ^ a2
/* 0006F4 A4000734 240917D9 */  addiu       $t1, $zero, 0x17d9
/* 0006F8 A4000738 030C8026 */  xor         $s0, $t8, $t4 # s0 = t8 ^ t4
/* 0006FC A400073C AD090010 */  sw          $t1, 0x10($t0) # set osCicId
/* 000700 A4000740 AD140000 */  sw          $s4, 0x0($t0) # set osTvType
/* 000704 A4000744 AD130004 */  sw          $s3, 0x4($t0) # set osRomType
/* 000708 A4000748 AD15000C */  sw          $s5, 0xc($t0) # set osResetType
/* 00070C A400074C 12600004 */  beqz        $s3, 1f
/* 000710 A4000750 AD170014 */   sw         $s7, 0x14($t0) # set osVersion
/* 000714 A4000754 3C09A600 */  lui         $t1, %hi(D_A6000000)
/* 000718 A4000758 10000003 */  b           2f
/* 00071C A400075C 25290000 */   addiu      $t1, $t1, %lo(D_A6000000)
1:
/* 000720 A4000760 3C09B000 */  lui         $t1, %hi(D_B0000000)
/* 000724 A4000764 25290000 */  addiu       $t1, $t1, %lo(D_B0000000)
2: # a3, s0 == checksum hi, lo
/* 000728 A4000768 AD090008 */  sw          $t1, 0x8($t0) # set osRomBase
/* 00072C A400076C 8D0900F0 */  lw          $t1, 0xf0($t0)
/* 000730 A4000770 3C0BB000 */  lui         $t3, %hi(D_B0000010)
/* 000734 A4000774 AD090018 */  sw          $t1, 0x18($t0) # set osMemSize
/* 000738 A4000778 8D680010 */  lw          $t0, %lo(D_B0000010)($t3) # check checksum hi word
/* 00073C A400077C 14E80006 */  bne         $a3, $t0, .LA4000798
/* 000740 A4000780 00000000 */   nop
/* 000744 A4000784 8D680014 */  lw          $t0, %lo(D_B0000014)($t3) # check checksum lo word
/* 000748 A4000788 16080003 */  bne         $s0, $t0, .LA4000798
/* 00074C A400078C 00000000 */   nop
/* 000750 A4000790 04110003 */  bgezal      $zero, .LA40007A0 # "bgezal $zero," is to be understood as a "relative jump", branch is always taken
/* 000754 A4000794 00000000 */   nop
.LA4000798: # infinite loop
/* 000758 A4000798 0411FFFF */  bgezal      $zero, .LA4000798
/* 00075C A400079C 00000000 */   nop
.LA40007A0:
/* 000760 A40007A0 3C08A400 */  lui         $t0, %hi(D_A4000000)
/* 000764 A40007A4 25080000 */  addiu       $t0, $t0, %lo(D_A4000000) # t0 = 0xA4000000
/* 000768 A40007A8 8FB00014 */  lw          $s0, 0x14($sp)
/* 00076C A40007AC 8FBF001C */  lw          $ra, 0x1c($sp)
/* 000770 A40007B0 27BD0020 */  addiu       $sp, $sp, 0x20
/* 000774 A40007B4 21092000 */  addi        $t1, $t0, 0x2000 # t1 = t0 + 0x2000 = 0xA4002000
.LA40007B8: # set [0xA4000000 ; 0xA4002000 [ (rsp dmem and imem) to 0xA4002000
/* 000778 A40007B8 25080004 */  addiu       $t0, $t0, 0x4
/* 00077C A40007BC 1509FFFE */  bne         $t0, $t1, .LA40007B8
/* 000780 A40007C0 AD09FFFC */   sw         $t1, -0x4($t0)
# load and jump to initial PC (rom header + 0x8)
/* 000784 A40007C4 3C0BB000 */  lui         $t3, %hi(jtbl_B0000008)
/* 000788 A40007C8 8D690008 */  lw          $t1, %lo(jtbl_B0000008)($t3)
/* 00078C A40007CC 01200008 */  jr          $t1
/* 000790 A40007D0 00000000 */   nop

...

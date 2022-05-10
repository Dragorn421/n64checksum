
...

glabel func_A40010D4 # 1
/* 0000D4 A40010D4 3C0DBFC0 */  lui         $t5, %hi(D_BFC007FC)
.LA40010D8:
/* 0000D8 A40010D8 8DA807FC */  lw          $t0, %lo(D_BFC007FC)($t5)
/* 0000DC A40010DC 25AD07C0 */  addiu       $t5, $t5, %lo(D_BFC007C0) # t5 = 0xBFC007C0
/* 0000E0 A40010E0 31080080 */  andi        $t0, $t0, 0x80
/* 0000E4 A40010E4 5500FFFC */  bnel        $t0, $zero, .LA40010D8 # /!\ branch likely, delay slot only executed if branch is taken
/* 0000E8 A40010E8 3C0DBFC0 */   lui        $t5, %hi(D_BFC007FC)
/* 0000EC A40010EC 8DA80024 */  lw          $t0, 0x24($t5) # t0 = *0xBFC007E4 = "encrypted seed value"
...
/* 00010C A400110C 0008B202 */  srl         $s6, $t0, 8
...
/* 000120 A4001120 32D600FF */  andi        $s6, $s6, 0xff

...

# jump to ipl3
/* 000708 A4001708 256B0000 */  addiu       $t3, $t3, %lo(D_A4000000) # t3 = 0xA4000000
/* 00070C A400170C 216B0040 */  addi        $t3, $t3, 0x40 # t3 = 0xA4000040
/* 000710 A4001710 01600008 */  jr          $t3 # j 0xA4000040

...

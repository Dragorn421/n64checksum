Compiling the disassembly to make sure the assembler did its job correctly, you never know

I'm using the `mips32-elf-` toolchain because I happen to have built and installed it, but maybe you would want to `apt install binutils-mips-linux-gnu` and use `mips-linux-gnu-`

# Compile pifdata

need macro.inc from https://github.com/zeldaret/mm/blob/0ccd71c2da5c078878b6428e40952ab221ff8ead/include/macro.inc

and the botched linker script syms.ld (in this folder) or something to define symbols

```
mips32-elf-as -march=vr4300 -32 pifdata.s/pifdata_A4001000.text.s -o pifdata_as.o
mips32-elf-objcopy -I elf32-bigmips -O binary pifdata_as.o pifdata_as.bin

mips32-elf-ld --defsym VRAM=0xA4001000 -T syms.ld pifdata_as.o -o pifdata_as_linked.o
mips32-elf-objcopy -j .text -I elf32-bigmips -O binary pifdata_as_linked.o pifdata_as_linked.bin
```

Compare resulting binary to original binary:

```
diff -qs pifdata.bin pifdata_as_linked.bin
vbindiff pifdata.bin pifdata_as.bin

mips32-elf-objcopy --binary-architecture mips:4000 -I binary -O elf32-bigmips pifdata_as_linked.bin pifdata_as_linked.bin.o
```

# Compile ipl3

Replace bits from the disassembly with bits from the "--disasm-unk" disassembly as needed (i.e. everything up to 0xA4000550 except the dozen words near the start), compile the non-"--disasm-unk" one

```
mips32-elf-as -march=vr4300 -32 ipl3.s/ipl3_A4000040.text.s -o ipl3_as.o
mips32-elf-ld --defsym VRAM=0xA4000040 -T syms.ld ipl3_as.o -o ipl3_as_linked.o
```

actually use "`--defsym VRAM=0x84000040`" to hackily "fix" linking errors like "`(.text+0xa7c): relocation truncated to fit: R_MIPS_26 against `func_84000B44'`"

```
mips32-elf-objcopy -j .text -I elf32-bigmips -O binary ipl3_as_linked.o ipl3_as_linked.bin

diff -qs ipl3.bin ipl3_as_linked.bin
vbindiff ipl3.bin ipl3_as_linked.bin
```

differs by one byte due to the "--defsym VRAM=0x84000040" hack, so OK for what I want to do with this

Comments on this some time later:
- after reading IPL3 somewhat thoroughly I think a proper disassembly would probably want to split it into parts and link each against a different starting address but idk.
- using proper symbols instead of my botched job of a disassembly and a linker script for symbols would help too

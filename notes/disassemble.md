# N64 ipl disassembly notes

- https://n64brew.dev/wiki/PIF-NUS
- https://n64brew.dev/wiki/Memory_map

Disassembler I used: https://github.com/Decompollaborate/py-mips-disasm
(its advantage: output can be `as`sembled out of the box)

Also note I'm coming from OoT64 modding so how I do things may look/be weird idk

# Disassemble pifdata (ipl1 & ipl2)

pifdata.bin (dump from console)

IPL1 "0x1FC00000 - 0x1FC007BF   PIF ROM (IPL1/2)"
IPL2 "0x04001000 - 0x04001FFF   RSP IMEM"
-> does the memory address matter?

./simpleDisasm.py pifdata.bin pifdata.s --vram 0xA4001000
or "--vram 0xBFC00000" ? 0xA4001000 seems to work (when assembling then)

# Disassemble ipl3

ipl3.bin (extract from a rom, several versions, using OoT64's for now (note: not a common version of ipl3 (md5 `ff22a296e55d34ab0a077dc2ba5f5796` (CIC 6105/7105))))
	`dd skip=64 count=4032 if=rom.z64 of=ipl3.bin bs=1`

"0x04000000 - 0x04000FFF   RSP DMEM"
skip the first 0x40 bytes of rom header, execute from 0x04000040

./simpleDisasm.py ipl3.bin ipl3.s --vram 0xA4000040
also make another disassembly with "--disasm-unk" passed because there's some gibberish at the start that prevents some actual instructions from being disassembled

If you're interested in hastily written notes, start with disassemble.md then compile.md

I went through the steps described in those before documenting parts of ipl1/2/3, which results can be found in pifdata.s / ipl3_6105.s

------------------

I didn't put the full disassembly, only the parts I commented on

for pifdata it's the value used for initializing the checksum computation and jumping to ipl3 that was of interest to me so I put that in pifdata.s

for ipl3 I put everything from ipl3 moving its execution to rdram, to jumping to game code, which includes loading 1MB of rom into ram, and computing and checking the checksum on it

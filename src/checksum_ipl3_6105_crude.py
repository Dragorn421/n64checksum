
"""
computes the checksum for a rom using a cic-6105 (or 7105), such as OoT64

I know the code is awful, it is a straight translation from ipl3-for-cic-6105 assembly
but it seems to work (computes the correct checksum for my rom)

the plan is to polish this and also write a C implementation, but keep this as a "bare-bones reference"


Usage: change "rom.z64" below if your rom is somewhere else
the checksum will be printed to standard output (among other stuff)
"""

# "convert" an integer to u32, with the assumption of common 2's complement and overflow
def u32(v):
    v = ((v % 0x1_0000_0000) + 0x1_0000_0000) % 0x1_0000_0000
    return v

# rom_bytes: list of bytes in the rom
# seed_ipl3: see main readme. for cic-6105/7105, the seed is 0x91
def calcu(rom_bytes, seed_ipl3 = 0x91):

    rom_words = [] # list of words in the rom
    for i in range(0x101000): # intends to only convert 0x101000 bytes, but (my bad) this should be 0x101000 / 4 (words) instead
        rom_words.append((rom_bytes[4*i] << 24) | (rom_bytes[4*i+1] << 16) | (rom_bytes[4*i+2] << 8) | (rom_bytes[4*i+3] << 0))

    s6 = seed_ipl3

    # ipl3 reads the rom header, and the rom from rdram.
    # simulate the behavior here knowing the entrypoint address,
    # but a true implementation would just read directly the rom from 0x1000 after the rom header
    INI_PC = 0x8000_0400

    a0 = INI_PC

    # ((())) a0 = *0xB0000008 = initial PC (rom header + 0x8) ((()))

    # comments like the following "0005CC - 0005D8", or "000670", indicate an (inclusive) range of instruction offsets in
    # the ipl3 code (0x40 to 0x1000 in rom) corresponding to what the following python "emulates"

    # 0005CC - 0005D8
    a1 = s6
    at = 0x5D588B65
    lo = u32(a1 * at)

    # 0005E8 - 0005F0
    s6 = 0xA0000200
    ra = 0x100000 #(1MB)

    # note: useless v1 = 0 at 0005F4

    # 0005F8 - 000620
    t0 = 0
    t1 = a0 #= initial PC = address of first byte from the copied 1MB of rom
    v0 = lo # v0 = (lo(a1 * at) above)
    v0 += 1
    a3 = v0
    t2 = v0
    t3 = v0
    s0 = v0
    a2 = v0
    t4 = v0
    t5 = 0x20

    # 000624 - 000698
    while t0 != ra: # should technically be a do while to match what the assembly does, but a while is the same

        # 000624 - 00062C
        # t1 - INI_PC + 0x1000 converts t1 from ram to rom
        v0 = rom_words[(t1 - INI_PC + 0x1000) // 4] # v0 = *t1
        v0 = u32(v0)
        v1 = a3 + v0
        v1 = u32(v1)
        at = 1 if u32(v1) < u32(a3) else 0 # (sltu) at = (v1 < a3)

        # 000634 (delay slot)
        a1 = v1
        # 000630, 000638
        if not (at == 0): # if (v1 < a3) then t2 +=1 else don't
            t2 += 1
            t2 = u32(t2)

        # 00063C - 000658
        v1 = v0 & 0x1f
        t7 = t5 - v1
        t7 = u32(t7)
        t8 = v0 >> t7
        t6 = v0 << v1
        t6 = u32(t6)
        a0 = t6 | t8
        at = 1 if u32(a2) < u32(v0) else 0 # sltu at = (a2 < v0)
        a3 = a1
        t3 ^= v0

        # 000660 (delay slot)
        s0 += a0
        s0 = u32(s0)
        # 00065C, 000664 - 000670
        if at == 0: # 00065C
            # 000670
            a2 ^= a0
        else: # 000668
            # 000664
            t9 = a3 ^ v0
            # 00066C (delay slot)
            a2 ^= t9

        # 000674 - 000690
        # convert s6 from ram to rom offset
        # (IPL3 (0004D0 - 0004F8) copies [0xA4000554 ; 0xA4000888[ (aka IPL3 000514 - 000844) to 0xA0000004)
        # 0x40 is the IPL3 offset in rom
        t7 = rom_words[(s6 - 0xA0000004 + 0x000514 + 0x40) // 4] # t7 = *s6
        t7 = u32(t7)
        t0 += 4
        t0 = u32(t0)
        s6 += 4
        s6 = u32(s6)
        t7 ^= v0
        t4 += t7
        t4 = u32(t4)
        t7 = 0xA00002FF
        t1 += 4
        t1 = u32(t1)

        # 000698 (delay slot)
        s6 &= t7

    # 00069C
    t6 = a3 ^ t2
    # 0006A0
    a3 = t6 ^ t3

    # 0006F0
    t8 = s0 ^ a2
    # 0006F8
    s0 = t8 ^ t4

    checksum = (a3, s0)

    return checksum


# read rom, compute and show checksum

with open("rom.z64", "rb") as f:
    rom_data_ = f.read()

data = rom_data_
#data = rom_data[0x1000:][:0x10000]

print(len(data))
print(data[:8])
print(data[-8:])

checksum = calcu(data)
checksum32 = u32(checksum[0]), u32(checksum[1])

print(checksum, f"{checksum[0]:X}", f"{checksum[1]:X}")
print(checksum32, f"{checksum32[0]:X}", f"{checksum32[1]:X}")

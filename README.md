# N64 rom checksum

Implementations and research notes on the checksum found in N64 rom headers.

I'm writing what follows after some time put into reading and researching, and finally a working crude implementation for the IPL3 with md5 `ff22a296e55d34ab0a077dc2ba5f5796` (CIC 6105/7105).

## What is this checksum

N64 roms have a 0x1000-bytes-long header, which includes a 8-bytes checksum starting at offset 0x10 in the rom. ( https://n64brew.dev/wiki/ROM_Header )
This checksum is computed from 1MB of rom, from 0x1000 to 0x101000.

The checksum is computed from the rom when the N64 boots, and if it doesn't correspond to the one in the header then the game doesn't start. (  )

So for modding and homebrew we need tools to compute the right checksum and write it in the rom header.
This repo is about implementing such tools.

## History

The only implementation I know of is http://n64dev.org/n64crc.html (there are a lot of variants based on this source file, all I have seen seemed to stem from it).

But it is GPL-2 licensed, and I would like a public domain version. Being interested in the topic of the N64 boot sequence anyway, I figured I could figure out my own implementation.

## Different checksum types

The checksum is computed by IPL3 ( https://n64brew.dev/wiki/Initial_Program_Load ), which is code stored in the rom header.

There are different IPL3 versions: (thanks Bigbass from the N64brew discord for the following checksums https://discord.com/channels/205520502922543113/205520502922543113/968583064492064869 )

```
MD5 Hashes (over entire IPL3):
6102/7101 = E24DD796B2FA16511521139D28C8356B
6103/7103 = 319038097346E12C26C3C21B56F86F23
6105/7105 = FF22A296E55D34AB0A077DC2BA5F5796
6106/7106 = 6460387749AC0BD925AA5430BC7864FE
     6101 = 900B4A5B68EDB71F4C7ED52ACD814FC5
     7102 = 955894C2E40A698BF98A67B78A4E28FA
  dynamic = 2B51BC28EA1262345799A48402F6C8EB
Xplorer64 = AC250EEEF53E5F3D767BCD2B06D2355F

CRC32 (over entire IPL3):
6102/7101 = 0x90BB6CB5
6103/7103 = 0x0B050EE0
6105/7105 = 0x98BC2C86
6106/7106 = 0xACC8580A
     6101 = 0x6170A4A1
     7102 = 0x009E9EA3
  dynamic = 0xE8B8467D
Xplorer64 = 0x2E46B62B

"dynamic" includes the GameBooster, GameShark Pro, and Action Replay Pro 64, which dynamically loads the IPL3 from another game.

Xplorer64 is another cheat device, similar to the GameShark, but significantly more rare, and has very little documented about it.
```

The reference implementation linked above handles most of these, the checksum for each is mostly computed almost the same way for each.

## Resources

A disassembly of IPL3 for NUS-CIC-6102 https://github.com/PeterLemon/N64/blob/0dad89d7bb9e5687c885c741b899a9c147128a93/BOOTCODE/BOOTCODE.asm (I didn't look at it much, I wanted to do things from scratch for fun and license reasons)

A list of what games use which CIC https://onedrive.live.com/view.aspx?resid=3E0FF504D0091341!184&ithint=file,xlsx&authkey=!ANIbMGHFVJCPv90

### On the topic of "seed" values:

What are they

- https://n64brew.dev/wiki/PIF-NUS
- https://recon.cx/2015/slides/recon2015-19-mike-ryan-john-mcmaster-marshallh-Reversing-the-Nintendo-64-CIC.pdf
- https://youtu.be/HwEdqAb2l50

The values in emulators:

- https://github.com/mupen64plus/mupen64plus-core/blob/9eb6a7cbefe663c0a7c527afc705f5dea5197d7c/src/device/pif/cic.c#L35
- https://github.com/ares-emulator/ares/blob/3ca1f9ebb4ae3f472f7fba661746058f84126536/ares/n64/pi/pi.cpp#L38
- https://github.com/n64dev/cen64/blob/1b31ca9b3c3bb783391ab9773bd26c50db2056a8/si/cic.c#L21-L27

#### How I summarized it

( or read the full discussion on N64brew around https://discord.com/channels/205520502922543113/205520502922543113/973452641067741184 )

To summarize,

The CIC sends an encoded "seed" value to the PIF, `BD 39 3D` (recon2015 56th slide)
This gets decoded to `B5 3F 3F` (recon2015 calls `B5` an "encryption key", slide 55)
The actual seed value is `0x3F3F` (the only place I found/saw the full two-bytes seed values seems to be in cen64 https://github.com/n64dev/cen64/blob/1b31ca9b3c3bb783391ab9773bd26c50db2056a8/si/cic.c#L21-L27 )

The lower byte of that (bits 0..7) is used (in the PIF?) to initialize the checksum calculation on IPL3 (to check IPL3 integrity) (implemented in https://github.com/jago85/PifChecksum, the readme may be slightly misleading talking about 4KB of rom starting at 0x40, probably means 0x40 to 0xFFF)

The higher byte (bits 8..15) is used (in IPL3, the byte is passed directly from IPL2 through register $s6) to initialize the checksum calculation on 1MB of rom starting at 0x1000 (right after the rom header / IPL3)
(note: at that point IPL3 has copied the 1MB of rom to rdram already, it doesn't read from rom to compute the checksum)

and as noted above the 1MB-of-rom checksum initialization in the main and only modern implementation, doesn't use the seed itself but `seed * 0x5D588B65 + 1` (truncated to 32bits) directly
http://n64dev.org/n64crc.html

this is true for IPL3s associated to 6102 and 6105 CICs, probably `0x5D588B65` is a different value for others. Based on the implementation acting the same for every CIC all IPL3s probably use the same algorithm
```c
// 0x3F*0x5D588B65+1 = 0x16f8ca4ddc (ok)
#define CHECKSUM_CIC6102 0xF8CA4DDC
// 0x78*0x5D588B65+1 = 0x2bc1815759 (different)
#define CHECKSUM_CIC6103 0xA3886759
// 0x91*0x5D588B65+1 = 0x34df26f436 (ok)
#define CHECKSUM_CIC6105 0xDF26F436
// 0x85*0x5D588B65+1 = 0x307f006b7a (different)
#define CHECKSUM_CIC6106 0x1FEA617A
```

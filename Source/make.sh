#!/bin/sh

[ -f ./grafika.bin ] && rm ./grafika.bin
[ -f ./grafika.tap ] && rm ./grafika.tap

ls ./Bin
ls ./Bin -l | awk 'BEGIN{ first_adr=24320; adr=first_adr; sum=1; printf("; SPRITY      od adresy $%X   = %i\n",adr,adr); } { if ($9!="") printf("%16s    equ $%X   ; %i %3i. = %5i, +%i\n",$9,adr,adr,sum++,$5,adr-first_adr); adr+=$5; } END{ 
printf("; first address after   $%X   = %i\n\nSeg_Screen equ $40\nAdr_Screen equ $4000\nSeg_Attr_Screen equ $58\nAdr_Attr_Screen equ $5800\nSeg_Buffer equ $%X\nAdr_Buffer equ (256*Seg_Buffer)\nSeg_Attr_Buffer equ $%X\nAdr_Attr_Buffer equ (256*Seg_Attr_Buffer)\nAdr_Buf_end equ $%X00",adr, adr, 1+(adr/256), 25+(adr/256), 28+(adr/256) ); 
printf("\n\n\
Xm5     equ $FB00\n\
Xm4     equ $FC00\n\
Xm3     equ $FD00\n\
Xm2     equ $FE00\n\
Xm1     equ $FF00\n\
X00     equ $0000\n\
X01     equ $0100\n\
X02     equ $0200\n\
X03     equ $0300\n\
X04     equ $0400\n\
X05     equ $0500\n\
X06     equ $0600\n\
X07     equ $0700\n\
X08     equ $0800\n\
X09     equ $0900\n\
X10     equ $0A00\n\
X11     equ $0B00\n\
X12     equ $0C00\n\
X13     equ $0D00\n\
X14     equ $0E00\n\
X15     equ $0F00\n\
X16     equ $1000\n\
X17     equ $1100\n\
X18     equ $1200\n\
X19     equ $1300\n\
X20     equ $1400\n\
X21     equ $1500\n\
X22     equ $1600\n\
X23     equ $1700\n\
X24     equ $1800\n\
X25     equ $1900\n\
X26     equ $1A00\n\
X27     equ $1B00\n\
X28     equ $1C00\n\
X29     equ $1D00\n\
X30     equ $1E00\n\
X31     equ $1F00\n\
\n\
Y00     equ $00\n\
Y01     equ $20\n\
Y02     equ $40\n\
Y03     equ $60\n\
Y04     equ $80\n\
Y05     equ $A0\n\
Y06     equ $C0\n\
Y07     equ $E0\n\
Y08     equ $09\n\
Y09     equ $29\n\
Y10     equ $49\n\
Y11     equ $69\n\
Y12     equ $89\n\
Y13     equ $A9\n\
Y14     equ $C9\n\
Y15     equ $E9\n\
Y16     equ $12\n\
Y17     equ $32\n\
Y18     equ $52\n\
Y19     equ $72\n\
Y20     equ $92\n\
Y21     equ $B2\n\
Y22     equ $D2\n\
Y23     equ $F2\n\
\n\
Z00     equ $04\n\
Z01     equ $24\n\
Z02     equ $44\n\
Z03     equ $64\n\
Z04     equ $84\n\
Z05     equ $A4\n\
Z06     equ $C4\n\
Z07     equ $E4\n\
Z08     equ $0D\n\
Z09     equ $2D\n\
Z10     equ $4D\n\
Z11     equ $6D\n\
Z12     equ $8D\n\
Z13     equ $AD\n\
Z14     equ $CD\n\
Z15     equ $ED\n\
Z16     equ $16\n\
Z17     equ $36\n\
Z18     equ $56\n\
Z19     equ $76\n\
Z20     equ $96\n\
Z21     equ $B6\n\
Z22     equ $D6\n\
Z23     equ $F6\n");
}' > ./sprites.h

cat ./Bin/* >> ./grafika.bin 
#./bin2tap grafika.bin

pasmo -d dungeon_v_0_7.asm dungeon7.bin > test.asm
#./bin2tap dungeon7.bin
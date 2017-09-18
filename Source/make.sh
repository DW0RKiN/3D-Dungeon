#!/bin/sh

[ -f ./grafika.bin ] && rm ./grafika.bin
[ -f ./grafika.tap ] && rm ./grafika.tap

ls ./Bin -l 
ls ./Bin -l | awk 'BEGIN{ first_adr=24320; adr=first_adr; sum=1; printf("; SPRITY      od adresy $%X   = %i\n",adr,adr); } { if ($9!="") printf("%16s    equ $%X   ; %i %3i. = %5i, +%i\n",$9,adr,adr,sum++,$5,adr-first_adr); adr+=$5; } END{ printf("; first address after   $%X   = %i",adr, adr); }' > ./sprites.h

cat ./Bin/* >> ./grafika.bin 
#./bin2tap grafika.bin

pasmo -d dungeon_v_0_7.asm dungeon7.bin > test.asm
#./bin2tap dungeon7.bin
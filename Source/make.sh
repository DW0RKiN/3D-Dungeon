#!/bin/sh

rm ./grafika.bin
rm ./grafika.tap

ls ./Bin -l 
ls ./Bin -l | awk 'BEGIN{ adr=24320; sum=1; printf("; SPRITY od adresy $%x = %i\n",adr,adr); } { if ($9!="") printf("%s\tequ\t$%x\t;%i %i. = %i\n",$9,adr,adr,sum++,$5); adr+=$5; } END{ print "; end sprites\t"adr; }' > ./sprites.h

cat ./Bin/* >> ./grafika.bin 
./bin2tap grafika.bin

pasmo -d dungeon_v_0_7.asm dungeon7.bin > test.asm
#./bin2tap dungeon7.bin
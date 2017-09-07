#!/bin/sh

mkdir bin
rm ./grafika.bin
rm ./grafika.tap
rm ./bin/*

for soubor in ./gif/*.gif 
do 
	naco=${soubor##*/}
	naco="./bin/${naco%.*}"  
	./gif2bin ${soubor} ${naco} 
done 

ls ./bin -l 
ls ./bin -l | awk 'BEGIN{ adr=24320; sum=1; printf("; SPRITY od adresy $%x = %i\n",adr,adr); } { if ($9!="") printf("%s\tequ\t$%x\t;%i %i. = %i\n",$9,adr,adr,sum++,$5); adr+=$5; } END{ print "; end sprites\t"adr; }' > ./sprites.h

cat ./bin/* >> ./grafika.bin 
./bin2tap grafika.bin


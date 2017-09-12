#!/bin/sh

gcc gif2bin.c -o gif2bin
#gcc gif2bin.c -o gif2bin -D INFO


mkdir Bin
rm ./Bin/*

for soubor in ./Gif/*.gif 
do 
	naco=${soubor##*/}
	naco="./Bin/${naco%.*}"  
	./gif2bin ${soubor} ${naco} > /dev/null
done 

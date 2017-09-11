#!/bin/sh

mkdir Bin
rm ./Bin/*

for soubor in ./Gif/*.gif 
do 
	naco=${soubor##*/}
	naco="./Bin/${naco%.*}"  
	./gif2bin ${soubor} ${naco} 
done 

#!/bin/sh

# Ocekavan zadny nebo jeden parametr obsahujici cestu k adresari s gify

if [ "$1" == "" ]
then
	source="./Gif"
else
	source="$1"
fi

gcc gif2bin.c -o gif2bin
#gcc gif2bin.c -o gif2bin -D INFO

[ ! -d ./Bin ] && mkdir Bin
rm ./Bin/*


for soubor in ${source}/*.gif
do 
	naco=${soubor##*/}
	naco="./Bin/${naco%.*}"  
	./gif2bin ${soubor} ${naco} 61 > /dev/null
done 

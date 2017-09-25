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

sirka=`tput cols`
nyni=0

for soubor in ${source}/*.gif
do 
	nyni=$(($nyni+20))
	if [ $nyni -gt $sirka ]
	then
		echo
		nyni=20
	fi

	naco=${soubor##*/}
	printf "%20s" $naco
	naco="./Bin/${naco%.*}" 
	./gif2bin ${soubor} ${naco} 61 > /dev/null
done 
echo

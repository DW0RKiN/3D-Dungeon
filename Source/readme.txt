# 0.
# gcc gif2bin.c -o gif2bin
# grep -B 2 --include=\*.{asm,h} -rnw 'directory' -e 'pattern'
"
1. zkompiluje gif2bin a prevede vsechny gify na bin format
bash gif2bin.sh
#bash gif2bin.sh ./Gif_original

2. vytvor sprites.h z bin obrazku, slepi je do grafika.bin a zkompiluje dungeon_v_?_?.bin
bash make.sh

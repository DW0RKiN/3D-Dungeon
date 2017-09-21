; Cte se z portu 31
; D0- joy RIGHT
; D1- joy LEFT
; D2- joy DOWN
; D3- joy UP
; D4- joy FIRE 1
; D5- joy FIRE 2 (podporovano jen u K-MOUSE interface, kde je podpora vsech trech tlacitek joysticku)
; D6- joy FIRE 3 (podporovano jen u K-MOUSE interface, kde je podpora vsech trech tlacitek joysticku)
; D7- nepouzito, obycejne zde vraci log.0
DATA_KEMPSTON:
;       right       left        up+r        up+l        down        up          fire        down+r      down+l      up+l+f
defb    $01,        $02,        $09,        $0a,        $04,        $08,        $10,        $05,        $06,        $1a 
defb    KEY_VPRAVO, KEY_VLEVO,  KEY_DOPRAVA,KEY_DOLEVA, KEY_DOZADU, KEY_DOPREDU,KEY_SPACE,  KEY_POLOZ,  KEY_VEZMI,  KEY_INVENTAR
; VYSTUP:         v "a" ascii kod stisknute klavesy 
;                 vraci zero flag kdyz nic...
TEST_KEMPSTON:
    xor     a                       ;cbb2   a = 0 
    ld      h,a                     ;cbb3   h = stav joystiku
    ld      l,a                     ;cbb4   hl = 0 
TK_NOVY_STAV:
    ld      b,6                     ;cbb5   pocet opakovani cteni stavu joysticku po kazde zmene
    or      h                       ;cbb7   pridame k puvodnimu stavu novy
    ld      h,a                     ;cbb8   ulozime do puvodniho
TK_LOOP:
    halt                            ;cbb9
    in      a,(31)                  ;cbba   cteme stav joysticku
    and     31                      ;cbbc   odmazem sum v hornich bitech, krome spodnich 5
    cp      31                      ;cbbe   je neco stisknuto? 
    ret     z                       ;cbc0
    cp      l                       ;cbc1   lisi se nove cteni od predchoziho? 
    ld      l,a                     ;cbc2   posledni cteni do registru "l"
    jr      nz,TK_NOVY_STAV         ;cbc3   lisi se 
    djnz    TK_LOOP                 ;cbc5   nelisilo se, snizime pocitadlo
    
    ld      a,h                     ;cbc7   vysledny stav do akumulatoru
    ld      hl,DATA_KEMPSTON        ;cbc8 21 9e cb         ! . . 
    ld      b,00ah                  ;cbcb 06 0a         . . 
    ld      c,B                     ;cbcd 48         H 
TK_TEST_STAVU:
    cp      (hl)                    ;cbce be         . 
    jr      z,TK_SHODNY_STAV        ;cbcf 28 27         ( ' 
    inc     hl                      ;cbd1 23         # 
    djnz    TK_TEST_STAVU           ;cbd2 10 fa         . .
    
    inc     b                       ;cbd4   b = 1 
    cp      011h                    ;cbd5   fire+right
    jr      z,TK_ZMENA_AKT_POSTAVY  ;cbd7 
    ld      b,0ffh                  ;cbd9   b = -1 
    cp      012h                    ;cbdb   fire+left 
    jr      z,TK_ZMENA_AKT_POSTAVY  ;cbdd 
    xor     a                       ;cbdf af         . 
    ret                             ;cbe0 c9         . 
    
TK_ZMENA_AKT_POSTAVY:
    ld      c,031h                  ;cbe1   znak "1" 
    ld      hl,HLAVNI_POSTAVA       ;cbe3         
    ld      a,(hl)                  ;cbe6        
    add     A, B                    ;cbe7   aktivni postava +- 1 
    inc     hl                      ;cbe8   nemeni priznaky, hl = SUM_POSTAV 
    jp      m,TK_PODTECENI          ;cbe9   mozne podteceni v pripade 0-1
    cp      (hl)                    ;cbec   porovnani s MAX_POSTAVA_PLUS_1
    jr      z,TK_PRETECENI          ;cbed   mozna shoda s MAX_POSTAVA+1 = MAX_POSTAVA_PLUS_1
    add     a,c                     ;cbef   + znak "1" a nastavi priznaky ( zrusi zero-flag )
    ret                             ;cbf0        
    
TK_PRETECENI:
    ld      a,c                     ;cbf1   a = znak "1"
    or      a                       ;cbf2   nastavi priznaky ( zrusi zero-flag )
    ret                             ;cbf3         
    
TK_PODTECENI:
    ld      a,(hl)                  ;cbf4         
    dec     a                       ;cbf5   a = MAX_POSTAVA
    add     a,c                     ;cbf6   + znak "1" a nastavi priznaky ( zrusi zero-flag )
    ret                             ;cbf7

TK_SHODNY_STAV:
    ld      b,0                     ;cbf8
    add     hl,BC                   ;cbfa   offset + 10 
    ld      a,(hl)                  ;cbfb   nahradi stav joysticku ekvivalentnim znakem klavesnice 
    or      a                       ;cbfc   nastavi priznaky ( zrusi zero-flag )
    ret                             ;cbfd 

    
    
; ----------------------------------------------
; VSTUP: nic
; VYSTUP:
;
KEYPRESSED:
    ld      de,TIMER_ADR
    ld      a,(de)
    and     FLOP_BIT_ATTACK/2
    ld      b,a
    ld      hl,LAST_KEY_ADR         ; 10:3 23560 = LAST K system variable.
KEYPRESSED_NO:

    ld      a,(de)
    and     FLOP_BIT_ATTACK/2
    xor     b
    ret     nz
    
    ld      a,(hl)                  ;  7:1 a = LAST K
    or      a                       ;  4:1 nula?
    push    hl
    push    bc
    call    z,TEST_KEMPSTON
    pop     bc
    pop     hl
    
    jr      z,KEYPRESSED_NO         ;12/7:2 v tehle smycce bude Z80 nejdelsi dobu... 

    ld      b,0                     ;  7:2  br 0x9434
    ld      (hl),b                  ;  7:1 smazem, LAST K = 0

    ld      hl,(LOCATION)           ; 16:3 l=LOCATION, h=VECTOR
    ld      c,h                     ;  4:1 (VECTOR)
    ld      h,DUNGEON_MAP/256       ;  7:2 HL = aktualni pozice na mape 

;        b = 0 = stisknuto_dopredu = offset radku tabulky VEKTORY_POHYBU
    cp      KEY_DOPREDU             ;  7:2, "w" = dopredu
    jp      z,POSUN

    ld      b,stisknuto_dozadu      ;  7:2, offset radku tabulky VEKTORY_POHYBU
    cp      KEY_DOZADU              ;  7:2, "s" = dozadu
    jp      z,POSUN

    ld      b,stisknuto_vlevo       ;  7:2, offset radku tabulky VEKTORY_POHYBU
    cp      KEY_VLEVO               ;  7:2, "a" = vlevo
    jp      z,POSUN

    ld      b,stisknuto_vpravo      ;  7:2, offset radku tabulky VEKTORY_POHYBU
    cp      KEY_VPRAVO              ;  7:2, "d" = vpravo
    jp      z,POSUN

    ld      b,-1                    ;  7:2, pouzito pro VECTOR += b
    cp      KEY_DOLEVA              ;  7:2, "q" = otoc se vlevo
    jr      z,OTOC_SE
    
    ld      b,1                     ;  7:2, pouzito pro VECTOR += b
    cp      KEY_DOPRAVA             ;  7:2, "e" = otoc se vpravo
    jr      z, OTOC_SE

    cp      KEY_SPACE               ;  7:2, "mezernik/asi space" = prepnuti paky
    jp      z, PREHOD_PREPINAC

    cp      KEY_INVENTAR            ;  7:2 "i" = inventar / hraci
    jp      z,SET_RIGHT_PANEL

    cp      55                      ;  7:2 
    jr      nc,KEYPRESSED_NO_NUMBER_1_6     ; vetsi nebo rovno jak hodnota znaku "7"
    cp      49                      ;  7:2 
    jr      c,KEYPRESSED_NO_NUMBER_1_6      ; mensi jak hodnota znaku "1"
    jp      NEW_PLAYER_ACTIVE
KEYPRESSED_NO_NUMBER_1_6:

    cp      42                      ;  7:2 "*" = ctrl+b ( nastavi border pro test synchronizace obrazu )
    jp      z,SET_BORDER
    
    cp      KEY_POLOZ               ;  7:2 "p"
    jp      z,VLOZ_ITEM_NA_POZICI

    cp      KEY_VEZMI               ;  7:2 "o"
    jp      z,VEZMI_ITEM_Z_POZICE
    
    cp      96                      ; ctrl+x
    jp      nz,HELP                 ; jina klavesa? zobraz napovedu! Pozor      tohle musi byt posledni test klavesy, protoze pokracovani je ukonceni programu
    
;EXIT_PROGRAM:
    pop     hl                      ; zrusim ret
    call    POP_ALL
    ret                             ; do BASICu
;------

SET_BORDER:
    ld      a, (BORDER)
    xor     $07
    ld      (BORDER), a
    ret
    
    
    

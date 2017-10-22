MEZERA  equ $40


; Upravi fci COPY_SPRITE2BUFFER tak aby zapisovala do bufferu
; MENI: akumulator
SET_TARGET_BUFFER:
    ld      A, Seg_Buffer                       ;  
    ld      (  CS2B_SELF_ADR_DATA_BUFF+1), A
    ld      (CS2B_Z_SELF_ADR_DATA_BUFF+1), A
    ld      A, Seg_Attr_Buffer                  ;  
    ld      (  CS2B_SELF_ADR_ATTR_BUFF+1), A
    ld      (CS2B_Z_SELF_ADR_ATTR_BUFF+1), A
    ret

; --------------------
; Upravi fci COPY_SPRITE2BUFFER tak aby zapisovala na SCREEN
; MENI: akumulator
SET_TARGET_SCREEN:
    ld      A, $40                              ;  
    ld      (  CS2B_SELF_ADR_DATA_BUFF+1), A
    ld      (CS2B_Z_SELF_ADR_DATA_BUFF+1), A
    ld      A, $58                              ;  
    ld      (  CS2B_SELF_ADR_ATTR_BUFF+1), A
    ld      (CS2B_Z_SELF_ADR_ATTR_BUFF+1), A
    ret
 
; --------------------
; Upravi fci COPY_SPRITE2BUFFER tak aby nekreslila za sloupec 31
; MENI: akumulator
SET_MAX_31:
    ld      A, 31                               ;
    ld      (CS2B_SELF_MAXSLOUPEC+1), A
    ld      (CS2B_Z_SELF_MAXSLOUPEC+1), A
    ret

; --------------------
; Upravi fci COPY_SPRITE2BUFFER tak aby nekreslila za sloupec 17
; MENI: akumulator
SET_MAX_17:
    ld      A, 17                               ;
    ld      (CS2B_SELF_MAXSLOUPEC+1), A
    ld      (CS2B_Z_SELF_MAXSLOUPEC+1), A
    ret
 
; --------------------
; Kopirovani spritu do bufferu
; Obrazky se vykresluji po sloupcich, aby slo snadneji kreslit mimo buffer a posouvat tak sprity vlevo a vpravo, i kdyz se tak musi hlidat tretiny...
 
; Vstup:	DE ...adresa hlavicky patternu
;		BC ...b=sloupec {0..17+},c=radek {0..13} souradnice kam ukladat v bufferu, pokud je radek zaporny, tak se kresli zprava doleva

; Buffer je identicky se ZX Screen oblasti
; Sprite obrazek ma na zacatku hlavicku:

;typedef struct
;{252
;    unsigned char	Offset na PIXel data;
;    unsigned char	Pocet_sloupcu_spritu;
;    unsigned char	Pocet_radku_spritu;
;} ZXHeader;
; nasleduje Atribute data jednotlivych znaku ...
; nasleduje pIXel data znaku po 8 bajtech ( pripadne 16 pokud znak obsahuje masku )... ( neda se zjistit delka, protoze nektere znaky mohou mit jen atribut )
; znaky jsou ulozeny prednostne dolu po sloupci a pak zpet nahoru a doprava na novy sloupec

; Specialni hodnoty atributu
; atribut = MEZERA:
;	znaci preskoc znak, je to dira v datech, predstavuje to celopruhledny znak
; atribut s PAPER nastaveno na 0:
;	znaci polopruhledny znak, INK je pomoci OR vlozeno na puvodni znak a prepsan INK v atributu ( PAPER hodnota zustava puvodni )
;	INK vzdy prebira BRIGHTNESS puvodni hodnoty ( nikdy neni nastaven v spritu )
; atribut s FLASH:
; 	znaci ze v datech je ulozena i maska kde v masce 1 je PRUHLEDNY ( ( puvodni AND maska ) OR novy )
; 	pokud i PAPER = 0 tak to znamena ze vetsina obrazku je pruhledna, ale ta drobna cast potrebuje zachovat PAPER i kdyby
; 	pod tim byla jednicka (INK), ale protoze je to mensi cast puvodniho znaku tak hodnota barvy zustane puvodni
; Chce to zakazat preruseni protoze SP bude pod 18
 COPY_SPRITE2BUFFER:	; ver 5 (faster)
    di
    push    IY

    ld      A, (DE)                 ;  7:1 Offset_Dat
    add     A, E                    ;  4:1
    exx                             ;  4:1
    ld      L, A                    ;  4:1
    exx                             ;  4:1
    adc     A, D                    ;  4:1
    exx                             ;  4:1
    sub     L                       ;  4:1
    ld      H, A                    ;  4:1 HL = SPRITE_DATA_ADR = Adresa hlavicky + Offset_Dat
    exx                             ;  4:1
    
    inc     DE                      ;  6:1
    ld      A, (DE)                 ;  7:1 
    ld      IYH, A                  ;  8:2 sirka spritu
    inc     DE                      ;  6:1
    ld      A, (DE)                 ;  7:1 
    ld      IXH, A                  ;  8:2 vyska spritu ( delka sloupce )

    bit     BIT_ZRCADLOVE, C        ;  8:2
    jp      nz, CS2B_ZRCADLOVE

    ; --------------- Vykreslovani jak pismo

if ( Adr_Attr_Buffer < $8000 )
    .error 'Adresa bufferu obrazovky nema horni bit nastaveny na jednicku!'
endif

    bit     7, B                    ;  8:2 zaporny sloupec?
    ld      L, B                    ;  4:1 vnejsi citac se zapornym sloupcem
    ld      H, 0                    ;  7:2 Pokud budeme orezavat pocatek tak odsud nacteme novou hodnotu pro prvni sloupec ( B ma byt 0)
    call    nz, IGNORE_COLUMN
    
; kontrola zda nemame zkratit pocet sloupcu spritu
CS2B_SELF_MAXSLOUPEC:
    ld      A, $1F                  ;  8:2 implicitni je 31, zkraceny je 17
    sub     B                       ;  4:1 max - pocatek < 0? Nezaciname vpravo od maxima a pritom kreslime doprava?
    jp      m, CS2B_EXIT_SP_OK      ; 10:3
CS2B_TEST_ZKRACENI_SIRKY:
    inc     A                       ;  4:1 zbyvajicich sloupcu pocitano od jednicky
    cp      IYH                     ; - kolik ma sloupcu sprite
    jr      nc, CS2B_KONEC_OK
    ld      IYH, A                  ; zkratime pocet sloupcu spritu
CS2B_KONEC_OK:

if (1)
    ld      A, C                    ;  4:1 Y radek 
    and     %00000011               ;  7:2
CS2B_SELF_ADR_ATTR_BUFF:
    add     A, Seg_Attr_Buffer      ;  7:2
    ld      (CS2B_SELF_H+1), A      ; 13:3 inicializace pro "ld H,n"
    ld      H, A                    ;  4:1
    ld      A, C                    ;  4:1
    and     %11100000               ;  7:2
    add     A, B                    ;  4:1 prictem X sloupec
    ld      IYL, A                  ;  8:2 IYL = offset prvniho znaku leziciho uvnitr bufferu, potrebujeme pro zacatek dalsiho sloupce
    ld      L, A                    ;  4:1 HL = BUFF_ATTR_ADR
    exx
    ld      (CS2B_EXIT+1), SP       ; 20:4 uloz puvodni ukazatel zasobniku
    ld      SP, HL                  ;  6:1 SP = SPRITE_DATA_ADR, DE = SPRITE_ATTR_ADR - 1
    ld      L, A                    ;  4:1 L'
    exx                             ;  4:1
    ld      A, C                    ;  4:1 Y radek
    exx                             ;  4:1
    and     %00011000               ;  7:2
CS2B_SELF_ADR_DATA_BUFF:
    add     A, Seg_Buffer           ;  7:2
    ld      (CS2B_SELF_H_SHADOW+1), A ;  13:3 inicializace pro "ld H, n"    
    ld      H, A                    ;  4:1 HL' = BUFF_DATA_ADR
    exx                             ;  4:1
else
    ; prohodi stinove a normalni registry
    ld      A, C                    ;  4:1 Y radek 
    and     %00011000               ;  7:2
CS2B_SELF_ADR_DATA_BUFF:
    add     A, Seg_Buffer           ;  7:2
    ld      (CS2B_SELF_H_SHADOW+1), A ;  13:3 inicializace pro "ld H, n"    
    ld      H, A                    ;  4:1 budouci H' = segment BUFF_DATA_ADR
    ld      A, C                    ;  4:1
    and     %11100000               ;  7:2
    add     A, B                    ;  4:1 prictem X sloupec
    ld      IYL, A                  ;  8:2 IYL = offset prvniho znaku leziciho uvnitr bufferu, potrebujeme pro zacatek dalsiho sloupce
    ld      L, A                    ;  4:1 buduci HL' = BUFF_DATA_ADR
    exx
    ; v zatim stinovych mame ulozeny v HL adresu SPRITE_DATA_ADR
    ld      (CS2B_EXIT+1), SP     ; 20:4 uloz puvodni ukazatel zasobniku
    ld      SP, HL                  ;  6:1 SP = SPRITE_DATA_ADR, DE = SPRITE_ATTR_ADR - 1
    ld      L, A                    ;  4:1 budouci L
    exx                             ;  4:1
    ld      A, C                    ;  4:1 Y radek (puvodni C)
    exx                             ;  4:1
    and     %00000011               ;  7:2
CS2B_SELF_ADR_ATTR_BUFF:
    add     A, Seg_Attr_Buffer      ;  7:2
    ld      (CS2B_SELF_H+1), A    ; 13:3 inicializace pro "ld H,n"
    ld      H, A                    ;  4:1 HL = BUFF_ATTR_ADR
    ; chyba! prohodi DE a DE'
endif
    
    ld      B, IYH                  ;  8:2  sirka spritu
    ld      IXL, IXH                ;  8:2  vyska ( delka sloupce )

; -------------- konec inicializaci
; aktualne
;   DE = SPRITE_ATTR_ADR-1 
;   B  = sirka spritu
;   B'C' = volne

; mapa registru

;   IXH = IXL = Pocet_radku_spritu ( delka sloupce )
;   IYL = offset prvniho znaku leziciho uvnitr bufferu

;   SP = SPRITE_DATA_ADR
;   HL' = BUFF_DATA_ADR
;   kopirujeme HL' <- SP

;   DE = SPRITE_ATTR_ADR
;   HL = BUFF_ATTR_ADR
;   kopirujeme HL <- DE

    jp      CS2B_POCATEK            ;

; -------------------------------
; Kopirovani znaku do bufferu pomoci masky ( nulove bity smazou puvodni ) a nasledne OR s novym
CS2B_MASK:
    add     A, A                    ;  7:2 odstranime FLASH, zbude jen 2xPAPER
    ld      A, C                    ;  7:1
    jr      nz, CS2B_MASK_NEZACHOVAT_PAPER
  
    xor     (HL)                    ;  7:1 (BUF_ATTR_ADR)
    and     %00000111               ;  7:2 old FLASH + old BRIGHTNESS + old PAPER + new INK
    xor     (HL)                    ;  7:1 (BUF_ATTR_ADR)
CS2B_MASK_NEZACHOVAT_PAPER:
    and     $7f                     ;  7:2 zrusime FLASH
    ld      (HL), A                 ;  7:1 (BUF_ATTR_ADR) ulozime novy atribut bez flash ( ale mozna s puvodnim PAPER ) 

    exx                             ;  4:1
    ld      B, $08                  ;  ?:2 Self-modifying, je tu bud "ld B,8" nebo "jr CS2B_MASK_ZRCADLOVE"
    ld      C, H                    ;  4:1
CS2B_MASK_LOOP
    pop     DE                      ; 10:1
    ld      A, (HL)                 ;  7:1 (BUFF_DATA_ADR)
    and     E                       ;  4:1 vynulujeme misto kam budeme kreslit novy znak
    or      D                       ;  4:1 pridame novy znak
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    djnz    CS2B_MASK_LOOP
    
    dec     IXL                     ;  8:2 snizime pocitadlo znaku v sloupci
    jp      nz, CS2B_O_ZNAK_NIZE    ; 10:3
;     jp      CS2B_FIRST_ROW        ; 10:3 

;-------------------------------



CS2B_FIRST_ROW:                     ; jsme ve stinovych registrech
CS2B_SELF_H_SHADOW:
    ld      H, $00                  ;  7:2 self-modifying code, navrat na prvni radek
    ld      IXL, IXH                ;  8:2 obnovime citac pro Pocet_radku_spritu ( delka sloupce )
    inc     IYL                     ;  8:2 o znak vpravo
    ld      A, IYL                  ;  8:2 offset znaku na prvnim radku
    ld      L, A                    ;  4:1 L' = offset znaku na prvnim radku

    exx
CS2B_SELF_H:
    ld      H, $00                  ; self-modifying code hl = BUF_ATTR_ADR prvniho radku
    ld      L, A
    djnz    CS2B_POCATEK            ; B = zbyvajici sirka spritu

CS2B_EXIT:
    ld      SP, $0000               ; self-modifying code
CS2B_EXIT_SP_OK:
    pop     IY
    ei
    ret

CS2B_TRETINA:
    exx                             ; navrat z Jeho Bozskeho Stinu
    inc     H                       ;  4:1  hl++ == BUF_ATTR_ADR += 256
    jr      CS2B_ATTR_NEXT

CS2B_CELOPRUHLEDNY:
    exx                             ; Dira v datech, cely znak je pruhledny
    ld      C, H
    ld      A, H
    add     A, $08                  ; simulace kopirovani
    ld      H, A

; ----------------------------------
CS2B_DOLU:
    dec     IXL                     ;  8:2 snizime pocitadlo znaku v sloupci
    jr      z, CS2B_FIRST_ROW       ;12/7:2 
CS2B_O_ZNAK_NIZE:                   ; jsme ve stinovych registrech	

    ld      A, $20                  ; A = 32
    add     A, L
    ld      L, A                    ;  4:1 L'+=32 == BUFF_DATA_ADR+=32

    jr      c, CS2B_TRETINA         ; skok pokud jsme v dalsi tretine
    ld      H, C                    ; H = H - 8 = old H
    exx

CS2B_ATTR_NEXT:
    ld      L, A                    ; L+=32 == BUF_ATTR_ADR += 32
    
; ----------------------------------
; Cast vetvici kopirovani znaku podle typu atributu na prepisovani, pripisovani, a oboji s pomoci masky
CS2B_POCATEK:

    inc     DE                      ;  6:1 DE++ = SPRITE_ATTR_ADR++
    ld      A, (DE)                 ;  7:1 (SPRITE_ATTR_ADR)
    ld      C, A                    ;  4:1
    and     %10111000               ; FLASH + PAPER
    jr      z, CS2B_ADD_INK         ; PAPER = black
    jp      m, CS2B_MASK

; ----------------------------------
; nepruhledne = prepisovani
    ld      (HL), C                 ;  7:1 (BUF_ATTR_ADR)
    exx                             ;  4:1

    ld      C, H                    ;  4:1
    pop     DE                      ; 10:1
    ld      (HL), E                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      (HL), D                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    pop     DE                      ; 10:1
    ld      (HL), E                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      (HL), D                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    pop     DE                      ; 10:1
    ld      (HL), E                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      (HL), D                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    pop     DE                      ; 10:1
    ld      (HL), E                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      (HL), D                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    
    ; kvuli zrychleni o 5 taktu duplicitni kod
    dec     IXL                     ;  8:2 snizime pocitadlo znaku v sloupci
    jp      nz, CS2B_O_ZNAK_NIZE    ; 10:3
    jp      CS2B_FIRST_ROW          ; 10:3 

; ----------------------------------
; Kopirovani znaku do bufferu metodou stare OR nove
; PAPER ve spritu je nulovy (cerny), je to znameni ze je pruhledny a bude ignorovan
CS2B_ADD_INK:

; Test kolize novy INK == puvodni PAPER  
    ld      A, C                    ;  4:1 (SPRITE_ATTR_ADR)
    add     A, A                    ;  4:1
if ( MEZERA != $40 )
    .error 'Zmenit kod, MEZERA != $.1000...!'
endif
    add     A, A                    ;  4:1
    jr      c, CS2B_CELOPRUHLEDNY    
    add     A, A                    ;  4:1 INK -> PAPER
    xor     (HL)                    ;  7:1 (BUF_ATTR_ADR)
    and     %00111000               ;  7:2 
    jr      z, CS2B_DELETE_INK      ; novy INK je shodny s puvodnim PAPER, takze jen vymazavam puvodni INK

    ld      A, (HL)                 ;  7:1 (BUF_ATTR_ADR)
    and     %11111000               ;  7:2
    or      C                       ;  4:1
    ld      (HL), A                 ;  7:1 (BUF_ATTR_ADR) zachovame puvodni hodnotu PAPER a BRIGHT

    exx

    ld      B, $02                  ;  7:2
    ld      C, H                    ;  4:1
CS2B_ADD_INK_LOOP:
    pop     DE                      ; 10:1
    ld      A, (HL)                 ;  7:1 (BUFF_DATA_ADR)
    or      E                       ;  4:1
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      A, (HL)                 ;  7:1 (BUFF_DATA_ADR)
    or      D                       ;  4:1
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    pop     DE                      ; 10:1
    ld      A, (HL)                 ;  7:1 (BUFF_DATA_ADR)
    or      E                       ;  4:1
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      A, (HL)                 ;  7:1 (BUFF_DATA_ADR)
    or      D                       ;  4:1
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    djnz    CS2B_ADD_INK_LOOP

    ; kvuli zrychleni o 5 taktu duplicitni kod
    dec     IXL                     ;  8:2 snizime pocitadlo znaku v sloupci
    jp      nz, CS2B_O_ZNAK_NIZE    ; 10:3
    jp      CS2B_FIRST_ROW          ; 10:3 


; ---------------------------------------------------------
; novy INK je shodny s puvodnim PAPER, takze jen vymazavam puvodni INK
; ld   A, E        ld   A, E
; cpl              or   (HL)
; and  (HL)        xor  E
; ld   (HL), A     ld   (HL),A

CS2B_DELETE_INK:
    exx
    ld      B, $04                  ;
    ld      C, H                    ;  4:1
CS2B_DEL_INK_LOOP:
    pop     DE                      ; 10:1
    ld      A, E                    ;  4:1
    cpl                             ;  4:1 inverze bitu
    and     (HL)                    ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      A, D                    ;  4:1
    cpl                             ;  4:1 inverze bitu
    and     (HL)                    ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1 = 62 / 2 = 31 T/byte
    djnz    CS2B_DEL_INK_LOOP
    
    jp      CS2B_DOLU               ; 10:3 

; ---------------------------------
    
    
    
    

    
; ==================================
; Zrcadlove vykreslovani
CS2B_ZRCADLOVE:
CS2B_Z_SELF_MAXSLOUPEC:
    ld      A, $1F                   ;  7:2 Self-modifying, implicitni je 31, zkracene je 17
    ld      H, A                    ;  4:1 Pokud budeme orezavat pocatek tak odsud nacteme novou hodnotu pro prvni sloupec ( B ma byt 17 nebo 31)
    sub     B                       ;  4:1 MAX_BUF - pocatecni sloupec
    ld      L, A                    ;  4:1 mozna zaporna hodnota poctu sloupcu ktere mam preskocit
    call    m, IGNORE_COLUMN        ; zrus neviditelne pocatecni sloupce
    
; kontrola zda nemame zkratit pocet sloupcu spritu
    ld      A, B
    or      A
    jp      m, CS2B_EXIT_SP_OK      ; zaciname vlevo od leveho minima ( nuly ) a kreslime doleva takze...
    inc     A                       ;  4:1 zbyvajicich sloupcu pocitano od jednicky
    cp      IYH                     ; - kolik ma sloupcu sprite
    jr      nc, CS2B_Z_KONEC_OK
    ld      IYH, A                  ; zkratime pocet sloupcu spritu
CS2B_Z_KONEC_OK:

if (1)
    ld      A, C                    ;  4:1 Y radek 
    and     %00000011               ;  7:2
CS2B_Z_SELF_ADR_ATTR_BUFF:
    add     A, Seg_Attr_Buffer      ;  7:2
    ld      (CS2B_Z_SELF_H+1), A    ; 13:3 inicializace pro "ld H,n"
    ld      H, A                    ;  4:1
    ld      A, C                    ;  4:1
    and     %11100000               ;  7:2
    add     A, B                    ;  4:1 prictem X sloupec
    ld      IYL, A                  ;  8:2 IYL = offset prvniho znaku leziciho uvnitr bufferu, potrebujeme pro zacatek dalsiho sloupce
    ld      L, A                    ;  4:1 HL = BUFF_ATTR_ADR
    exx
    ld      (CS2B_Z_EXIT+1), SP     ; 20:4 uloz puvodni ukazatel zasobniku
    ld      SP, HL                  ;  6:1 SP = SPRITE_DATA_ADR, DE = SPRITE_ATTR_ADR - 1
    ld      L, A                    ;  4:1 L'
    exx                             ;  4:1
    ld      A, C                    ;  4:1 Y radek
    exx                             ;  4:1
    and     %00011000               ;  7:2
CS2B_Z_SELF_ADR_DATA_BUFF:
    add     A, Seg_Buffer           ;  7:2
    ld      (CS2B_Z_SELF_H_SHADOW+1), A ;  13:3 inicializace pro "ld H, n"    
    ld      H, A                    ;  4:1 HL' = BUFF_DATA_ADR
    exx                             ;  4:1
else
    ; prohodi stinove a normalni registry
    ld      A, C                    ;  4:1 Y radek 
    and     %00011000               ;  7:2
CS2B_Z_SELF_ADR_DATA_BUFF:
    add     A, Seg_Buffer           ;  7:2
    ld      (CS2B_Z_SELF_H_SHADOW+1), A ;  13:3 inicializace pro "ld H, n"    
    ld      H, A                    ;  4:1 budouci H' = segment BUFF_DATA_ADR
    ld      A, C                    ;  4:1
    and     %11100000               ;  7:2
    add     A, B                    ;  4:1 prictem X sloupec
    ld      IYL, A                  ;  8:2 IYL = offset prvniho znaku leziciho uvnitr bufferu, potrebujeme pro zacatek dalsiho sloupce
    ld      L, A                    ;  4:1 buduci HL' = BUFF_DATA_ADR
    exx
    ; v zatim stinovych mame ulozeny v HL adresu SPRITE_DATA_ADR
    ld      (CS2B_Z_EXIT+1), SP     ; 20:4 uloz puvodni ukazatel zasobniku
    ld      SP, HL                  ;  6:1 SP = SPRITE_DATA_ADR, DE = SPRITE_ATTR_ADR - 1
    ld      L, A                    ;  4:1 budouci L
    exx                             ;  4:1
    ld      A, C                    ;  4:1 Y radek (puvodni C)
    exx                             ;  4:1
    and     %00000011               ;  7:2
CS2B_Z_SELF_ADR_ATTR_BUFF:
    add     A, Seg_Attr_Buffer      ;  7:2
    ld      (CS2B_Z_SELF_H+1), A    ; 13:3 inicializace pro "ld H,n"
    ld      H, A                    ;  4:1 HL = BUFF_ATTR_ADR
    ; chyba! prohodi DE a DE'
endif
    
    ld      B, IYH                  ;  8:2  sirka spritu
    ld      IXL, IXH                ;  8:2  vyska spritu ( delka sloupce )
    

; -------------- konec inicializaci
; aktualne
;   DE = SPRITE_ATTR_ADR-1 
;   B  = sirka spritu
;   B'C' = volne

; mapa registru

;   IXH = IXL = Pocet_radku_spritu ( delka sloupce )
;   IYL = offset prvniho znaku leziciho uvnitr bufferu

;   SP = SPRITE_DATA_ADR
;   HL' = BUFF_DATA_ADR
;   kopirujeme HL' <- SP

;   DE = SPRITE_ATTR_ADR
;   HL = BUFF_ATTR_ADR
;   kopirujeme HL <- DE


    jp      CS2B_Z_POCATEK          ;

; -------------------------------
; Kopirovani znaku do bufferu pomoci masky ( nulove bity smazou puvodni ) a nasledne OR s novym
CS2B_Z_MASK:
    add     A, A                    ;  7:2 odstranime FLASH, zbude jen 2xPAPER
    ld      A, C                    ;  7:1
    jr      nz, CS2B_Z_MASK_NEW_PAPER
  
    xor     (HL)                    ;  7:1 (BUF_ATTR_ADR)
    and     %00000111               ;  7:2 old FLASH + old BRIGHTNESS + old PAPER + new INK
    xor     (HL)                    ;  7:1 (BUF_ATTR_ADR)
CS2B_Z_MASK_NEW_PAPER:
    and     $7f                     ;  7:2 zrusime FLASH
    ld      (HL), A                 ;  7:1 (BUF_ATTR_ADR) ulozime novy atribut bez flash ( ale mozna s puvodnim PAPER ) 

    exx                             ;  4:1
    ex      DE, HL                  ;  4:1
    ld      B, $08                  ;  7:2
CS2B_Z_MASK_LOOP:
    pop     hl                      ; 10:1
    ld      A, (DE)                 ;  7:1 (BUFF_DATA_ADR)
    ld      C, H                    ;  4:1
    ld      H, ZRCADLOVY/256        ;  7:2    
    and     (HL)                    ;  7:1 vynulujeme misto kam budeme kreslit novy znak
    ld      L, C                    ;  4:1
    or      (HL)                    ;  7:1 pridame novy znak
    ld      (DE), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     D                       ;  4:1
    djnz    CS2B_Z_MASK_LOOP

    ex      DE, HL                  ;  4:1
    jr      CS2B_Z_DOLU             ; 12:2

;-------------------------------

CS2B_Z_FIRST_ROW:                   ; jsme ve stinovych registrech
CS2B_Z_SELF_H_SHADOW:
    ld      H, $00                  ;  7:2 self-modifying code, navrat na prvni radek
    ld      IXL, IXH                ;  8:2 obnovime citac pro Pocet_radku_spritu ( delka sloupce )
    dec     IYL                     ;  8:2 o znak vlevo u zrcadloveho kresleni
    ld      A, IYL                  ;  8:2 offset znaku na prvnim radku
    ld      L, A                    ;  4:1 l' = offset znaku na prvnim radku

    exx
CS2B_Z_SELF_H:
    ld      H, $00                  ; self-modifying code hl = BUF_ATTR_ADR prvniho radku
    ld      L, A
    djnz    CS2B_Z_POCATEK          ; b = zbyvajici Pocet_sloupcu_spritu

CS2B_Z_EXIT:
    ld      SP, $0000               ; self-modifying code
    pop     IY
    ei
    ret

CS2B_Z_TRETINA:
    exx                             ; navrat z Jeho Bozskeho Stinu
    inc     H                       ;  4:1  hl++ == BUF_ATTR_ADR += 256
    jr      CS2B_Z_ATTR_NEXT

    
CS2B_Z_CELOPRUHLEDNY:
    exx                             ; Dira v datech, cely znak je pruhledny
    ld      A, H
    add     A, $08                  ; simulace kopirovani
    ld      H, A
; ----------------------------------
CS2B_Z_DOLU:
    dec     IXL                     ;  8:2 snizime pocitadlo znaku v sloupci
    jr      z, CS2B_Z_FIRST_ROW     ;12/7:2 
CS2B_Z_O_ZNAK_NIZE:                 ; jsme ve stinovych registrech	

    ld      A, $20                  ; A = 32
    add     A, L
    ld      L, A                    ; 4:1 l'+=32 == BUFF_DATA_ADR+=32

    jr      c, CS2B_Z_TRETINA       ; skok pokud jsme v dalsi tretine
    ld      A, H
    sub     $08                     ; 
    ld      H, A                    ;  4:1 h'-=8 == BUFF_DATA_ADR-=8*256
    ld      A, L
    exx

CS2B_Z_ATTR_NEXT:
    ld      L, A                    ; l+=32 == BUF_ATTR_ADR += 32
    
; ----------------------------------
; Cast vetvici kopirovani znaku podle typu atributu na prepisovani, pripisovani, a oboji s pomoci masky
CS2B_Z_POCATEK:

    inc     DE                      ;  6:1 DE++ = SPRITE_ATTR_ADR++
    ld      A, (DE)                 ;  7:1 (SPRITE_ATTR_ADR)
    ld      C, A                    ;  4:1
    and     %10111000               ; FLASH + PAPER
    jr      z, CS2B_Z_ADD_INK       ; PAPER = black
    jp      m, CS2B_Z_MASK

; ----------------------------------
; nepruhledne = prepisovani
CS2B_Z_ADD_ALL:
    ld      (HL), C                 ;  7:1 (BUF_ATTR_ADR)
    exx                             ;  4:1
    ld      B, $04                  ;  7:2

CS2B_Z_ADD_ALL_LOOP:
    pop     DE                      ; 10:1
    ld      C, D                    ;  4:1
    ld      D, ZRCADLOVY/256        ;  7:2
    ld      A, (DE)                 ;  7:1
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      E, C                    ;  4:1
    ld      A, (DE)                 ;  7:1
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    djnz    CS2B_Z_ADD_ALL_LOOP
    ; kvuli zrychleni o 5 taktu duplicitni kod
    dec     IXL                     ;  8:2 snizime pocitadlo znaku v sloupci
    jp      nz, CS2B_Z_O_ZNAK_NIZE  ; 10:3
    jp      CS2B_Z_FIRST_ROW        ; 10:3

; -------------------------------
; Kopirovani znaku do bufferu metodou stare OR nove
; PAPER ve spritu je nulovy (cerny), je to znameni ze je pruhledny a bude ignorovan
CS2B_Z_ADD_INK:
; Test kolize novy INK == puvodni PAPER  
    ld      A, C                    ;  4:1 (SPRITE_ATTR_ADR)
    add     A, A                    ;  4:1
if ( MEZERA != $40 )
    .error 'Zmenit kod, MEZERA != $.1000...!'
endif
    add     A, A                    ;  4:1
    jr      c, CS2B_Z_CELOPRUHLEDNY    
    add     A, A                    ;  4:1 INK -> PAPER
    xor     (HL)                    ;  7:1 (BUF_ATTR_ADR)
    and     %00111000               ;  7:2 
    jr      z, CS2B_Z_DELETE_INK    ; novy INK je shodny s puvodnim PAPER, takze jen vymazavam puvodni INK

    ld      A, (HL)                 ;  7:1 (BUF_ATTR_ADR)
    and     %11111000               ;  7:2
    or      C                       ;  4:1
    ld      (HL), A                 ;  7:1 (BUF_ATTR_ADR) zachovame puvodni hodnotu PAPER a BRIGHT

    exx
    ld      B, $04
CS2B_Z_ADD_INK_LOOP:
    pop     DE                      ; 10:1
    ld      C, D                    ;  4:1
    ld      D, ZRCADLOVY/256        ;  7:2
    ld      A, (DE)                 ;  7:1 zrcadleny sprite
    or      (HL)                    ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      E, C                    ;  4:1 
    ld      A, (DE)                 ;  7:1 zrcadleny sprite
    or      (HL)                    ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    djnz    CS2B_Z_ADD_INK_LOOP
    ; kvuli zrychleni o 5 taktu duplicitni kod
    dec     IXL                     ;  8:2 snizime pocitadlo znaku v sloupci
    jp      nz, CS2B_Z_O_ZNAK_NIZE  ; 10:3
    jp      CS2B_Z_FIRST_ROW        ; 10:3 

; ---------------------------------------------------------
; novy INK je shodny s puvodnim PAPER, takze jen vymazavam puvodni INK
; ld   A, E        ld   A, E
; cpl              or   (HL)
; and  (HL)        xor  E
; ld   (HL), A     ld   (HL),A

CS2B_Z_DELETE_INK:
    exx
    ld      B, $04                  ;  7:2
CS2B_Z_DEL_LOOP:
    pop     DE                      ; 10:1
    ld      C, D                    ;  4:1
    ld      D, ZRCADLOVY/256        ;  7:2
    ld      A, (DE)                 ;  7:1 zrcadleny sprite
    cpl                             ;  4:1
    and     (HL)                    ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      E, C                    ;  4:1 
    ld      A, (DE)                 ;  7:1 zrcadleny sprite
    cpl                             ;  4:1
    and     (HL)                    ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    djnz    CS2B_Z_DEL_LOOP

    jp      CS2B_Z_DOLU             ; 10:3 


; ==========================================================================================
; Osetreni pocatku a konce spritu pokud leze mimo povolene meze.
; Pokud IYL je zaporna hodnota a priznaky nastavene na "sign" tak prvni sloupec je zacina mimo povoleny vyrez bufferu, takze posunu DE a HL' na viditelny zacatek.
; VSTUP:
;   IYH nezkraceny pocet sloupcu spritu
;   IXH vyska spritu
;   H nova hodnota B pokud orezavame pocatek
;   L zaporna hodnota poctu sloupcu ktere mam preskocit
;   DE ukazuje na pred prvni atribut spritu
;   HL' ukazuje na DATA spritu
; VYSTUP:
;   HL' = SPRITE_DATA_ADR bude zvetsen a nastaven na prvni skutecne zobrazeny sloupec
;   DE  = SPRITE_ATTR_ADR bude zvetsen a nastaven na prvni skutecne zobrazeny sloupec
;   L = 0
;   IYH = zkraceny pocet sloupcu spritu
IGNORE_COLUMN:
    exx                             ;  4:1
    ld      DE, $0008               ;  7:2 DE'
    exx                             ;  4:1
IC_COLUMN_LOOP:
    ld      B, IXH                  ;  8:2 B = vyska
IC_ROW_LOOP:
    inc     DE                      ;  6:1 SPRITE_ATTR_ADR++
    ld      A, (DE)                 ;  7:1 (SPRITE_ATTR_ADR)
    exx                             ;  4:1
    and     %11111000               ;  7:2 FLASH + BRIGHTNESS + PAPER
    cp      MEZERA                  ;  7:2
    jr      z, IC_NO_DATA           ;12/7:2 nic tam neni
    add     A, A                    ;  4:1
    jr      nc, IC_NO_MASK          ;12/7:2 neobsahuje masku
    add     HL, DE                  ; 11:1
IC_NO_MASK:
    add     HL, DE                  ; 11:1
IC_NO_DATA:
    exx                             ;  4:1
    djnz    IC_ROW_LOOP             ;13/8:2 
                             
    dec     IYH                     ;  8:2 Pocet_sloupcu_spritu-- protoze spritu zbyva o sloupec mene
    jr      z, IC_EXIT_SPRITE2BUFFER; 10:3
    inc     L                       ;  4:1 jsme uz v nultem sloupci?
    jr      nz, IC_COLUMN_LOOP
    ld      B, H                    ;  4:1 0 nebo 17 nebo 31
    ret                             ; 10:1
IC_EXIT_SPRITE2BUFFER:
    ; nastava u mecu a mescu
    pop     AF                      ; 10:1 zrusi RET
    jp      CS2B_EXIT_SP_OK         ; 10:3


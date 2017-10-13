; =====================================================
; Nastavi zero flag kdyz nejsme v inventari
; Do akumulatoru vlozi kurzor      v inventari
TEST_OTEVRENY_INVENTAR:
    ld      a, (PRIZNAKY)               ;caa6        3a 13 c6 
    and     PRIZNAK_OTEVRENY_INVENTAR   ;caa9        e6 01 
    ld      a, (KURZOR_V_INVENTARI)     ;caab        3a 66 ce 
    ret
    
    
; =====================================================
; VYSTUP:
;   DE = @(INVENTORY_ITEMS[HLAVNI_POSTAVA])    
DE_INVENTORY_ITEMS_AKTIVNI:
    ld      A, (HLAVNI_POSTAVA)     ; 13:3
    ld      E, A                    ;  4:1
    
; -----------------------------------------------------
; VSTUP:
;   A = E = 0..5
; VYSTUP:
;   DE = @(INVENTORY_ITEMS[A])
DE_INVENTORY_ITEMS_A:

if ( MAX_INVENTORY != 31 )
    .error 'Zmenit kod pro nasobeni 27x'
endif

    add     A, A                    ;  4:1 2x 
    add     A, A                    ;  4:1 4x 
    add     A, A                    ;  4:1 8x 
    add     A, A                    ;  4:1 16x 
    add     A, A                    ;  4:1 32x 
    sub     E                       ;  4:1 31x 
    add     A, INVENTORY_ITEMS % 256;  7:2
    ld      E, A                    ;  4:1
    
if ( INVENTORY_ITEMS/256 != (INVENTORY_ITEMS_END+1)/256)
     .warning 'Delsi kod o 2 bajty! Pole INVENTORY_ITEMS = preleza segment!'
     
    adc     A, INVENTORY_ITEMS / 256;  7:2
    sub     E                       ;  4:1
    ld      D, A                    ;  4:1
else
    ld      D, INVENTORY_ITEMS / 256;  7:2     
endif
    ret
    

    
; =====================================================
SET_RIGHT_PANEL:
    ld      hl,PRIZNAKY                 ; 10:3
    ld      a,(hl)                      ; 7:1
    xor     PRIZNAK_OTEVRENY_INVENTAR   ; 7:2
    ld      (hl),a                      ; 7:1
    and     PRIZNAK_OTEVRENY_INVENTAR   ; 7:2

    jp      nz,INVENTORY_WINDOW_OPEN
    jr      PLAYERS_WINDOW

    
; =====================================================
NEW_PLAYER_ACTIVE:
    ; je nastaveny pravy panel na zobrazeni vsech hracu?
    call    TEST_OTEVRENY_INVENTAR  ;dc11
    jp      nz, INVENTORY_WINDOW_REFRESH; uz se nevratime
    ; jinak pokracujem v PLAYER_WINDOW
;     ret
    
; -----------------------------------------------------
PLAYERS_WINDOW:

    ; Vymazani vseho krome casti s avatarem a rukama
    ld      bc,$0E01                    ; blok o 14 sloupcich a 1 radku
    ld      hl,Adr_Attr_Buffer + $12
    call    FILL_ATTR_BLOCK

    ld      bc,$0E03                    ; blok o 14 sloupcich a 3 radcich
    ld      hl,Adr_Attr_Buffer + $B2
    call    FILL_ATTR_BLOCK
    
    ld      bc,$0E03                    ; blok o 14 sloupcich a 3 radcich
    ld      hl,Adr_Attr_Buffer + $192
    call    FILL_ATTR_BLOCK

    ld      bc,$0E01                    ; blok o 14 sloupcich a 1 radku
    ld      hl,Adr_Attr_Buffer + $272
    call    FILL_ATTR_BLOCK


    ; Vypsani textu u vsech postav ( jmena + HP )
    ld      IX, NAMES                   ; 14:4
    ld      BC,(HLAVNI_POSTAVA)         ; 20:4
    inc     C                           ;  4:1
    
    ld      HL, Adr_Attr_Buffer+$12     ; 10:3
    ld      DE, Adr_Attr_Buffer+$19     ; 10:3

PW_JMENA_LOOP:
    ld      A, COLOR_ACTIVE_PLAYER      ;  7:2
    dec     C
    jr      z, PW_AKTIVNI               ;12/7:2
    ld      A, COLOR_OTHER_PLAYERS      ;  7:2
PW_AKTIVNI:
    push    AF                          ; 11:1 color    
    call    PRINT_STRING_OBAL           ; 17:3
    
    ld      A, L                        ;  4:1
    add     A, $A0                      ;  7:2
    ld      L, A                        ;  4:1
    adc     A, H                        ;  4:1
    sub     L                           ;  4:1
    ld      H, A                        ;  4:1
    pop     AF                          ; 10:1
    
    push    IX                          ; 15:2
    ld      IX, VETA_HP                 ; 14:4
    call    PRINT_STRING_OBAL           ; 17:3
    pop     IX                          ; 14:2
    
    ld      A, L                        ;  4:1
    add     A, $40                      ;  7:2
    ld      L, A                        ;  4:1
    adc     A, H                        ;  4:1
    sub     L                           ;  4:1
    ld      H, A                        ;  4:1
    
    ex      DE, HL                      ;  4:1
    djnz    PW_JMENA_LOOP               ;13/8:2
    
    
    ld      ix, INVENTORY_ITEMS         ; 
    xor     a                           ; 
    push    AF                          ; stop symbol
    ld      c, MAX_INVENTORY            ; 
PW_HANDS_LOOP:
    ld      B, A                        ; "b" = cislo ruky 0..11
    ld      a,(ix+$14)                  ; leva ruka
    call    VYKRESLI_RUKU               ; 
    inc     B                           ; 
    ld      a,(ix+$19)                  ; prava ruka 
    call    VYKRESLI_RUKU               ;
    inc     B                           ;
    ld      A, B                        ; schovame cislo ruky do akumulatoru 
    ld      B, $00                      ;
    add     ix,BC                       ; + MAX_INVENTORY = inventar dalsi postavy  
    cp      12                          ; pocet zobrazenych ruk
    jp      nz,PW_HANDS_LOOP            ;
    
    call    SET_MAX_31                  ;dcbe cd 8c d8         . . . 
    di                                  ;dce1        
    call    KRESLI_ZE_ZASOBNIKU         ;dce4
    
    ld      hl,AVATARS                  ; odkud se budou cist data
    ld      B, $06                      ; citac 
PW_AVATARS:
    call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG ;dced        cd 9d d6         . . . 
    djnz    PW_AVATARS                  ;
    
    call    ZOBRAZ_ZIVOTY               ;dd02 cd 4b df         . K . 
    ei                                  ;dd05 fb         . 
    call    SET_MAX_17                  ;dd06 cd 95 d8         . . . 
    ret                                 ;dd0c c9         . 

    
; =====================================================
; Tento vstup se pouzije pokud predtim byl vykreslen jiny panel
INVENTORY_WINDOW_OPEN:

INVENTORY_WINDOW_KURZOR:
INVENTORY_WINDOW_REFRESH:

    ld      bc,$0804                ; blok o 8 sloupcich a 4 radcich
    ld      hl,Adr_Attr_Buffer + $98
    call    FILL_ATTR_BLOCK

    ld      bc,$0808                ; blok o 8 sloupcich a 8 radcich
    ld      hl,Adr_Attr_Buffer + $118
    call    FILL_ATTR_BLOCK
    
    ld      bc,$0804                ; blok o 8 sloupcich a 4 radcich
    ld      hl,Adr_Attr_Buffer + $218
    call    FILL_ATTR_BLOCK


; ---------------
; Menime jen aktivni postavu
; INVENTORY_WINDOW_REFRESH:
    ; napravo od tvare, mazem jmeno predchozi postavy
    ld      bc,$0A04        ; blok o 10 sloupcich a 4 radcich
    ld      hl,Adr_Attr_Buffer + $16
    call    FILL_ATTR_BLOCK

    ld      a,(HLAVNI_POSTAVA)
    push    af                      ; ulozime aktivni postavu na zasobnik
    inc     a
    ld      bc,NEXT_NAME
    ld      hl,NAMES-NEXT_NAME
IW_NEXT_NAME:        
    add     hl,bc
    dec     a
    jr      nz,IW_NEXT_NAME
    push    hl
    pop     ix                      ; ix <- hl
    ld      hl, Adr_Attr_Buffer + $16
    call    PRINT_STRING
    
    pop     af                      ; nacteme aktivni postavu ze zasobniku
    add     a,a                     ; 2x
    add     a,a                     ; 4x
    add     a,AVATARS % 256
    ld      l,a
    adc     a,AVATARS / 256
    sub     l
    ld      h,a                     ; hl = index na avatar aktivniho hrace

    ld      e,(hl)
    inc     hl
    ld      d,(hl)                  ; de = ukazatel na sprite avatara aktivniho hrace
    
    ld      bc,$1200
    call    SET_MAX_31              ; meni jen akumulator
    di
    call    COPY_SPRITE2BUFFER
    
    
if (0)
    jr      INVENTORY_POKRACUJ
; ---------------
; Menime jen kurzor      
; INVENTORY_WINDOW_KURZOR:
    call    SET_MAX_31              ; meni jen akumulator
    di
INVENTORY_POKRACUJ:
endif

;--- Nastrkame spravna data (parametry dale volane fce) na zasobnik a protoze je to zasobnik, posledni bude prvni kreslene.

; Vykresleni v poradi:
; 2 x pul silueta postavy
; toulec
; pokud je predmet a nebo mensi jak 17 tak modre pozadi
; pokud kurzor tak vzdy pozadi a to fialove
; ram
; kdyz je na pozici predmet tak vykresleni predmetu
; prostirani
; kdyz je presouvany predmet a nesmi tam tak mrizka

; kdyz je presouvany predmet tak najit pozici a posunout ji o jedno nahoru a doleva
; nakreslit podklad
; nakreslit ram
; nakreslit presouvany predmet

    xor     A
    push    AF                      ; zarazka na zasobnik
    ; init VYKRESLI_ITEM_NA_POZICI_B
    exx
    ld      HL, POZICE_V_INVENTARI_HOLD_END
    exx
    ld      HL, MAX_HOLD_INVENTORY  ; 10:3 
    call    DE_INVENTORY_ITEMS_AKTIVNI; nacist do DE adresu radku aktivni postavy z INVENTORY_ITEMS
    add     HL, DE
    ld      B, MAX_HOLD_INVENTORY   ;  7:2
IW_LOOP:
    call    VYKRESLI_ITEM_NA_POZICI_B  
    djnz    IW_LOOP

    ld      DE, I_toulec
    push    DE
    ld      DE, POZICE_TOULEC
    push    DE
    ld      DE, Body_left
    push    DE
    ld      DE, $1907
    push    DE
    ld      DE, Body_left
    push    DE
    ld      DE, $1DF8               ; 7bit znaci zrcadlove kresleni
    push    DE
; v zasobniku mame za sebou souradnice a pod tim adresu obrazku
    call    KRESLI_ZE_ZASOBNIKU

    call    VYKRESLI_AKTIVNI_PREDMET
    ei
    call    SET_MAX_17                  ; 
    
    ret



; =====================================================
; Ulozi na zasobnik dvojice 16 bitovych hodnot (adresu a pak souradnice) pro pozdejsi vykresleni
; VSTUP:
;   B = index pozice 1..MAX_INVENTORY
;   HL' = ukazatel na souradnice spritu na obrazovce
;   HL = ukazatel na typ predmetu
; VYSTUP:
;   HL' += 2
;   HL++
VYKRESLI_ITEM_NA_POZICI_B:
    pop     DE
    ld      (VINPB_SELF+1), DE

    exx
    dec     HL
    ld      D, (HL)
    dec     HL
    ld      E, (HL)                 ; DE = pozice
    exx

    ; vykresleni mrizky
    ld      A, (PRESOUVANY_PREDMET) ; 13:3
    ld      C, A                    ;  4:1
    call    TEST_NEPOVOLENE_POZICE  ; 17:3
    
    jr      z, IW_BEZ_MRIZKY
    ld      DE, I_zakazano          ; vykresleni mrizky
    push    DE                      ; ulozeni adresy spritu
    exx                 
    push    DE                      ; ulozeni pozice
    exx
IW_BEZ_MRIZKY:


    ; vykresleni predmetu
    ld      C, B                ; C = B = priznak ze je prazdne policko;
if (INVENTORY_ITEMS/256 != INVENTORY_ITEMS_END/256)
    .warning 'Pomalejsi kod, INVENTORY_ITEMS preleza segment!'
    dec     HL
else
    dec     L
endif
    ld      A, (HL)
    add     A, A
    jr      z, IW_BEZ_PREDMETU
    
    push    HL
    call    DE_2DSPRITE_A
    pop     HL
    push    DE                      ; ulozeni predmetu
    exx
    push    DE                      ; ulozeni pozice
    exx    
    dec     C                       ; zrusime priznak prazdneho policka
IW_BEZ_PREDMETU:

    ; vykresleni prostirani
    ld      A, B
    cp      INDEX_PROSTIRANI
    jr      nz, IW_NENI_PROSTIRANI
    ld      DE, I_prostirani        ; adresa spritu
    push    DE
    exx
    push    DE                      ; ulozeni pozice
    exx        
IW_NENI_PROSTIRANI:

    ; vykresleni prazdneho ramu nebo modreho/fialoveho podkladu
    ld      DE, I_ram               ; adresa spritu
    cp      1+INDEX_PROSTIRANI
    jr      c, IW_MODRY             ; prvnich 16 pozic ma vzdy modre pozadi
    jr      z, IW_MODRY             ; pod prostiranim je take modro
    ; vykresleni mozneho podkladu
    cp      C
    jr      z, IW_PRAZDNE_POLICKO   ; zero = prazdne policko
IW_MODRY:
    ld      DE, I_bg                ; modry podklad
IW_PRAZDNE_POLICKO:
    ; fialovy podklad je pod kurzorem vzdy
    ld      A, (KURZOR_V_INVENTARI)
    inc     A
    cp      B
    jr      nz, IW_NEJSME_NA_KURZORU
    ld      DE, I_bgm               ; fialovy podklad pro kurzor
IW_NEJSME_NA_KURZORU:
    push    DE
    exx                 
    push    DE                      ; ulozeni pozice
    exx

VINPB_SELF:
    jp      $0000

    
; =====================================================
KRESLI_ZE_ZASOBNIKU:
    pop     HL                          ; navratova adresa
    pop     BC
    inc     B
    dec     B
    jr      z, KZZ_EXIT    
    pop     DE
    push    HL                          ; navratova adresa
    call    COPY_SPRITE2BUFFER
    jr      KRESLI_ZE_ZASOBNIKU
KZZ_EXIT:
    push    HL
    ret                                 ; return
    

    
; =====================================================
; VSTUP:
;   A = 2*PODTYP
; VYSTUP:
;   DE = adresa spritu
; MENI:
;   AF,HL
DE_2DSPRITE_A:      
    add     A, ITEM2SPRITE % 256            ;
    ld      L, A
if (ITEM2SPRITE/256 != ITEM2SPRITE_END/256)
    .warning 'ITEM2SPRITE preleze segment!'
    adc     A, ITEM2SPRITE / 256
    sub     L
    ld      H, A
    ld      E, (HL)
    inc     HL
else
    ld      H, ITEM2SPRITE / 256
    ld      E, (HL)
    inc     L
endif
    ld      D, (HL)
    ret
    
    
; =====================================================
; VSTUP:
;   H = roh
;   L = lokace
; VYSTUP:
;   A = PODTYP_ITEM
; MENI:
;   AF
A_NAJDI_POLOZENY_PREDMET_HL:
    push    HL
    push    BC
    push    DE

    call    DEH_FIND_LAST_ITEM_HL
    ; H = TYP_ITEM + roh
    ex      DE, HL
    dec     HL                      ; PODTYP
    ld      A, (HL)
    dec     HL                      ; zamky + typ + roh
    ld      B, (HL)
    dec     HL                      ; lokace
    ld      C, (HL)
    ex      DE, HL

    sbc     HL, BC
    jr      z, NPP_EXIT
    xor     A
NPP_EXIT:
    pop     DE
    pop     BC
    pop     HL
    ret
    
    
        
; =====================================================
VYKRESLI_AKTIVNI_PREDMET:
    call    TEST_OTEVRENY_INVENTAR      ;
    ret     z                           ; u zavreneho nebudem vykreslovat presah
    

    ; predmety nahore strcim do poslednich 4 polozek inventare
    call    DE_INVENTORY_ITEMS_AKTIVNI
    push    DE
    pop     IX
    ; polozeny predmet na zemi
    ld      HL, (LOCATION)              ; 16:3 L=LOCATION, H=VECTOR=ROH VLEVO VZADU
    call    A_NAJDI_POLOZENY_PREDMET_HL ; roh 0 (vlevo vzadu)
    ld      (IX+INDEX_ZEM_LD_M1), A
    inc     H
    call    A_NAJDI_POLOZENY_PREDMET_HL ; roh 1 (vpravo vzadu)
    ld      (IX+INDEX_ZEM_RD_M1), A
    call    HL_VEPREDU                  ; 17:3
    dec     H                           ; roh 3 (-1)  
    call    A_NAJDI_POLOZENY_PREDMET_HL ; roh vlevo vepredu na ctverci pred nama
    ld      (IX+INDEX_ZEM_LU_M1), A
    dec     H                           ; roh 2 (-2)
    call    A_NAJDI_POLOZENY_PREDMET_HL ; roh vpravo vepredu na ctverci pred nama
    ld      (IX+INDEX_ZEM_RU_M1), A

    ; vykreslim odzadu posledni 4 polozky inventare
    xor     A
    push    AF                          ; zarazka na zasobnik
    ; init VYKRESLI_ITEM_NA_POZICI_B
    exx
    ld      HL, POZICE_V_INVENTARI_END
    exx
    ld      HL, MAX_INVENTORY           ; 10:3 
    call    DE_INVENTORY_ITEMS_AKTIVNI  ; nacist do DE adresu radku aktivni postavy z INVENTORY_ITEMS
    add     HL, DE
    ld      B, MAX_INVENTORY            ;  7:2
VAP_LOOP:
    call    VYKRESLI_ITEM_NA_POZICI_B
    dec     B
    ld      A, INDEX_PPRSTEN
    cp      B
    jr      nz, VAP_LOOP
    call    KRESLI_ZE_ZASOBNIKU


    ld      a, (PRESOUVANY_PREDMET)
    add     a, a                        ; 2x
    ret     z                           ; nic nedrzi

    add     a, ITEM2SPRITE % 256
    ld      l, a
if ( ITEM2SPRITE / 256 != ITEM2SPRITE_END )
    adc     a, ITEM2SPRITE / 256
    sub     l
    ld      h, a    
    ld      e, (hl)
    inc     hl
else
    ld      h, ITEM2SPRITE / 256
    ld      e, (hl)
    inc     l
endif
    ld      d, (hl)
    push    de
    
    ld      a,(KURZOR_V_INVENTARI)
    add     a,a
    add     a,POZICE_V_INVENTARI % 256
    ld      l,a
    adc     a,POZICE_V_INVENTARI / 256
    sub     l
    ld      h,a
    ld      c,(hl)
    inc     hl
    ld      b,(hl)
    dec     b                           ; posunem doleva
    dec     c                           ; posunem nahoru
        
    ld      de,I_bgm
    push    bc
    call    COPY_SPRITE2BUFFER
    
    pop     bc
    pop     de
    call    COPY_SPRITE2BUFFER
    ret


; =====================================================  
; VSTUP:
;   C = PODTYP_ITEM testovaneho predmetu ( 0 = povolen vzdy )
;   B = index testovane pozice 1..MAX_INVENTORY
; VYSTUP:
;   zero = povoleno
;   not zero = zakazano
; MENI:
;   AF
TEST_NEPOVOLENE_POZICE:
    ld      A, B
    dec     A                       ; 1+ -> 0+
    
    cp      INDEX_ZEM_LU_M1
    jr      c, TNP_NOSENE
    ; pozice na zemi
    ; sude jsou vzdy povolene
    ; liche jen kdyz neni pred nama stena
    and     $01
    ret     z
    ; byla to suda pozice
    push    HL
    call    HL_VEPREDU
    ld      H, DUNGEON_MAP / 256    ;  7:2
    bit     BIT_NEPRUCHOZI, (HL)
    pop     HL
    ret
TNP_NOSENE:

    and     $F0                     ; cokoliv na mensi pozici je povoleno
    ret     z                       ; vracim ZERO

    ld      A, C
    or      A
    ret     z                       ; vracim ZERO
    
POZICE_M1   equ POVOLENE_POZICE-1
    push    HL
    add     A, POZICE_M1 % 256
    ld      L, A
    adc     A, POZICE_M1 / 256
    sub     L
    ld      H, A

    ld      A, B
    cp      INDEX_PPRSTEN
    jr      nz, TNP_NENI_PRSTEN
    ld      A, INDEX_LPRSTEN        ; tabulka ukazuje jen na levy prst
TNP_NENI_PRSTEN:

    cp      INDEX_PRUKA
    jr      nz, TNP_NENI_RUKA
    ld      A, INDEX_LRUKA          ; tabulka obsahuje jen na levou ruku
TNP_NENI_RUKA:

    cp      (HL)                    ; jedina povolena pozice
    pop     HL
    ret     
 

; =====================================================
DE_POZICE_RUKOU_A:
; MENI: 
;   AF, DE, HL
if ( POZICE_RUKOU / 256 ) != ( POZICE_RUKOU_END / 256 )
    .error      'Seznam POZICE_RUKOU prekracuje 256 bajtovy segment!'
endif    
;     push    HL
    add     A, A                    ; polozky jsou word
    add     A, POZICE_RUKOU % 256
    ld      L, A                    ;
    ld      H, POZICE_RUKOU / 256
    ld      E, (HL)
    inc     L
    ld      D, (HL)
;     pop     HL
    ret
    
    
; =====================================================    
; VSTUP:    
;   A = PODTYP predmetu
;   B = cislo ruky od 0
; MENI:
;   A, HL, DE
; VYSTUP:   
;   ulozi na zasobnik 4x word (pozice, pozadi, pozice, ruku/predmet)
VYKRESLI_RUKU:

    pop     HL                      ; vytahni navratovou adresu
    ld      (VR_SELF+1), HL         ; nastav "jp nn" na konci fce

    ld      DE, I_empty             ; obrazek prazdne dlane kdyz nic nedrzi
    add     A, A                    ; v tabulce jsou 16 bit hodnoty
    jr      z, VR_PRAZDNA
    
    add     A, ITEM2SPRITE % 256
    ld      L, A
if ( ITEM2SPRITE / 256 != ITEM2SPRITE_END / 256 )
    adc     A, ITEM2SPRITE / 256
    sub     L
    ld      H, A
    ld      E, (HL)
    inc     HL
else
    ld      H, ITEM2SPRITE / 256
    ld      E, (HL)
    inc     L
endif
    ld      D, (HL)
VR_PRAZDNA:
    push    DE                      ; adresa ruky/predmetu

    ld      A, B
    call    DE_POZICE_RUKOU_A
    push    DE                      ; XY pozice ruky

    ld      HL, I_bg                ;
    push    HL                      ; prazdny podklad
    push    DE                      ; XY pozice ruky
      
VR_SELF:
    jp      0                       ; self-modifying


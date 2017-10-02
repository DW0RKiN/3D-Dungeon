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
    
    
    call    SET_MAX_31                  ;dcbe cd 8c d8         . . . 
    ld      ix, INVENTORY_ITEMS         ;dcc1 dd 21 78 ce         . ! x . 
    xor     a                           ;dcc5   a = 0 
    ld      c, MAX_INVENTORY            ;dcc6 
PW_HANDS_LOOP:
    ld      B, A                        ;dcc8   "b" = cislo ruky 0..11
    ld      a,(ix+$14)                  ;dcc9   leva ruka
    call    VYKRESLI_RUKU               ;dccc 
    inc     B                           ;dccf 
    ld      a,(ix+$19)                  ;dcd0   prava ruka 
    call    VYKRESLI_RUKU               ;dcd3
    inc     B                           ;dcd6
    ld      A, B                        ;dcd7   schovame cislo ruky do akumulatoru 
    ld      B, $00                      ;dcd8
    add     ix,BC                       ;dcda   + MAX_INVENTORY = inventar dalsi postavy  
    cp      12                          ;dcdc   pocet zobrazenych ruk
    jp      nz,PW_HANDS_LOOP            ;dcde
    
    di                                  ;dce1        
    ld      a, $18                      ;dce2   a = citac ulozenych obrazku na zasobniku ( vzdy po 2 word ) 
    call    VYKRESLI_ZE_ZASOBNIKU       ;dce4
    
    ld      hl,AVATARS                  ;dce7   odkud se budou cist data
    ld      B, $06                      ;dcea   citac 
PW_AVATARS:
    call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG ;dced        cd 9d d6         . . . 
    djnz    PW_AVATARS                  ;dcf1
    
    call    SET_TARGET_SCREEN           ;dcf3 
    ld      B, $02                      ;dcf6
PW_KOMPAS_A_SIPKY:
    call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG ;dcf9        cd 9d d6         . . . 
    djnz    PW_KOMPAS_A_SIPKY           ;dcfd 
    
    call    SET_TARGET_BUFFER           ;dcff cd 76 d8         . v . 
    call    ZOBRAZ_ZIVOTY               ;dd02 cd 4b df         . K . 
    ei                                  ;dd05 fb         . 
    call    SET_MAX_17                  ;dd06 cd 95 d8         . . . 
    call    AKTUALIZUJ_RUZICI           ;dd09 cd d6 de         . . . 
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
    push    DE                      ; ulozeni souradnic
    exx                 
    push    DE                      ; ulozeni pozice
    exx
IW_BEZ_MRIZKY:


    ; vykresleni prostirani 
    ld      A, B
    cp      INDEX_PROSTIRANI
    jr      nz, IW_NENI_PROSTIRANI
    ld      DE, I_prostirani
    push    DE
    exx                 
    push    DE                      ; ulozeni pozice
    exx
IW_NENI_PROSTIRANI:


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
    jr      z, IW_PRAZDNE_POLICKO
    
    push    HL
    call    DE_2DSPRITE_A
    pop     HL
    push    DE                      ; ulozeni predmetu
    exx
    push    DE                      ; ulozeni pozice
    exx    
    dec     C                       ; zrusime priznak prazdneho policka
IW_PRAZDNE_POLICKO:


    ; vykresleni ramu
    ld      de, I_ram               ; prazdny ram protoze jsme jeste (B klesa) na naznacene postave
    push    DE
    exx
    push    DE                      ; ulozeni pozice
    exx    
    
    
    ; vykresleni podkladu pod kurzorem
    ld      A, (KURZOR_V_INVENTARI)
    inc     A
    cp      B
    jr      nz, IW_NEJSME_NA_KURZORU
    ld      DE, I_bgm               ; fialovy podklad pro kurzor
    push    DE
    exx
    push    DE                      ; ulozeni pozice
    exx    
IW_NEJSME_NA_KURZORU:


    ; vykresleni mozneho podkladu
    ld      A, B
    cp      C
    jr      nz, IW_PREDMET_OBSAZEN
    cp      1+INDEX_PROSTIRANI
    jr      nc, IW_NEKRESLI_PODKLAD 
IW_PREDMET_OBSAZEN:
    ld      DE, I_bg                ; modry podklad
    push    DE
    exx
    push    DE                      ; ulozeni pozice
    exx 
IW_NEKRESLI_PODKLAD:


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

    call    FIND_LAST_ITEM
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
    
    
if (0)
; =====================================================
; VSTUP:
;   BC = XY
;   H = roh
;   L = lokace
; VYSTUP:
;
; MENI:
;   AF, BC, DE, HL
VYKRESLI_POLOZENY_PREDMET:
    push    BC
    push    HL
    ; polozeny predmet na zemi   
    ld      DE, I_bg                ; podklad pod predmet
    call    COPY_SPRITE2BUFFER

    pop     HL    
    call    FIND_LAST_ITEM
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
    pop     BC
    ret     nz

    ADD     A, A
    ret     z                       ; tohle by slo smazat

    call    DE_2DSPRITE_A
    call    COPY_SPRITE2BUFFER
    ret
endif
    
    
; =====================================================
VYKRESLI_AKTIVNI_PREDMET:
    call    TEST_OTEVRENY_INVENTAR      ;ddf7        cd a6 ca
    ret     z                           ; u zavreneho nebudem vykreslovat presah
    
if (0)
    ; polozeny predmet na zemi   
    ld      BC, $020D
    ld      HL, (LOCATION)              ; 16:3 L=LOCATION, H=VECTOR
    push    HL
    call    VYKRESLI_POLOZENY_PREDMET   ; roh vlevo vzadu
    pop     HL
    inc     H
    ld      BC, $0D0D
    call    VYKRESLI_POLOZENY_PREDMET   ; roh vpravo vzadu

    ;HL_NOVA_POZICE    
    ld      HL, (LOCATION)              ; 16:3 L=LOCATION, H=VECTOR
    ld      D, VEKTORY_POHYBU/256       ;  7:2
    ld      E, H                        ;  4:1 de = @(VECTORY_POHYBU[radek][sloupec])
    ld      A, (DE)                     ;  7:1 o kolik zmenit LOCATION pro pohyb danym smerem
    add     A, L                        ;  4:1 ZMENIT POKUD BUDE MAPA 16bit!!! ( ..a nejen to, pozice predmetu, dveri atd. )
    ld      L, A                        ;  4:1 hl = pozice na mape po presunu
    inc     H
    inc     H
    
    ; polozeny predmet na zemi   
    ld      BC, $0B0B
    push    HL
    call    VYKRESLI_POLOZENY_PREDMET   ; roh vpravo vepredu na ctverci pred nama
    pop     HL
    inc     H
    ld      BC, $040B
    call    VYKRESLI_POLOZENY_PREDMET   ; roh vlevo vepredu na ctverci pred nama
endif

if (1)
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
    
    ;HL_NOVA_POZICE    
    call    HL_VEPREDU                  ; 17:3
    dec     H                           ; roh 3 (-1)  
    call    A_NAJDI_POLOZENY_PREDMET_HL ; roh vlevo vepredu na ctverci pred nama
    ld      (IX+INDEX_ZEM_LU_M1), A
    
    dec     H                           ; roh 2 (-2)
    call    A_NAJDI_POLOZENY_PREDMET_HL ; roh vpravo vepredu na ctverci pred nama
    ld      (IX+INDEX_ZEM_RU_M1), A
endif

    xor     A
    push    AF                      ; zarazka na zasobnik
    ; init VYKRESLI_ITEM_NA_POZICI_B
    exx
    ld      HL, POZICE_V_INVENTARI_END
    exx
    ld      HL, MAX_INVENTORY  ; 10:3 
    call    DE_INVENTORY_ITEMS_AKTIVNI; nacist do DE adresu radku aktivni postavy z INVENTORY_ITEMS
    add     HL, DE
    ld      B, MAX_INVENTORY   ;  7:2
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
; VYSTUP:
;   H = natoceni
;   L = adresa na mape lokace pred nama
HL_VEPREDU:
    ld      HL, (LOCATION)              ; 16:3 L=LOCATION, H=VECTOR
    push    HL                          ; 11:1
    ld      A, L                        ;  4:1 A=LOCATION
    ld      L, H                        ;  4:1 L=VECTOR
    ld      H, VEKTORY_POHYBU/256       ;  7:2 HL = @(VECTORY_POHYBU[0][sloupec])
    add     A, (HL)                     ;  7:1 o kolik zmenit LOCATION pro pohyb danym smerem
    pop     HL                          ; 10:1
    ld      L, A                        ;  4:1 L = pozice na mape po presunu
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
    ld      H, DUNGEON_MAP / 256        ;  7:2
    bit     0,(HL)
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
; Fce kresli sprity s parametry tahajici ze zasobniku
; VSTUP: a = pocet vykresleni ( = 2x pop     )
;        na zasobniku lezi nahore pozice a pod ni lezi adresa spritu
VYKRESLI_ZE_ZASOBNIKU:
    pop     hl                  ; vytahni navratovou hodnotu
VYKRESLI_ZE_ZASOBNIKU_LOOP:
    pop     bc
    pop     de
    push    hl
    push    af                  ; ochran citac
    inc     d
    dec     d
    call    nz,COPY_SPRITE2BUFFER
    pop     af
    pop     hl
    dec     a
    jr      nz,VYKRESLI_ZE_ZASOBNIKU_LOOP
    jp      (hl)
    
    
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

if ( POZICE_RUKOU / 256 ) != ( POZICE_RUKOU_END / 256 )
    .error      'Seznam POZICE_RUKOU prekracuje 256 bajtovy segment!'
endif    
    
    ld      A, POZICE_RUKOU % 256
    add     A, B
    add     A, B                    ; 2x protoze jde o word
    ld      L, A                    ;
    ld      H, POZICE_RUKOU / 256
    ld      E, (HL)
    inc     L
    ld      D, (HL)
    push    DE                      ; XY pozice ruky
    ld      HL, I_bg                ;
    push    HL                      ; prazdny podklad
    push    DE                      ; XY pozice ruky
      
VR_SELF:
    jp      0                       ; self-modifying


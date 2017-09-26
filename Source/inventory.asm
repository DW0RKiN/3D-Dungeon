; Nastavi zero flag kdyz nejsme v inventari
; Do akumulatoru vlozi kurzor      v inventari
TEST_OTEVRENY_INVENTAR:
    ld      a, (PRIZNAKY)               ;caa6        3a 13 c6 
    and     PRIZNAK_OTEVRENY_INVENTAR   ;caa9        e6 01 
    ld      a, (KURZOR_V_INVENTARI)     ;caab        3a 66 ce 
    ret
    

; VYSTUP:
;   DE = @(INVENTORY_ITEMS[HLAVNI_POSTAVA])    
HLAVNI_RADEK_INVENTORY_ITEMS:
    ld      A, (HLAVNI_POSTAVA)     ; 13:3
    ld      E, A                    ;  4:1
; VSTUP:
;   A = E = 0..5
; VYSTUP:
;   DE = @(INVENTORY_ITEMS[A])
RADEK_INVENTORY_ITEMS:

if ( MAX_INVENTORY != 27 )
    .error 'Zmenit kod pro nasobeni 27x'
endif

    add     A, A                    ;  4:1 2x 
    add     A, E                    ;  4:1 3x = 2x + 1x
    ld      E, A                    ;  4:1 3x do E
    add     A, A                    ;  4:1 6x
    add     A, A                    ;  4:1 12x
    add     A, A                    ;  4:1 24x
    add     A, E                    ;  4:1 27x = 24x + 3x
    add     A, INVENTORY_ITEMS % 256;  7:2
    ld      E, A                    ;  4:1
    
if ( INVENTORY_ITEMS/256 != INVENTORY_ITEMS_END/256)
     .warning 'Delsi kod o 2 bajty! Pole INVENTORY_ITEMS = preleza segment!'
     
    adc     A, INVENTORY_ITEMS / 256;  7:2
    sub     E                       ;  4:1
    ld      D, A                    ;  4:1
else
    ld      D, INVENTORY_ITEMS / 256;  7:2     
endif
    ret
    

    
; ----------------------------------
SET_RIGHT_PANEL:
    ld      hl,PRIZNAKY                 ; 10:3
    ld      a,(hl)                      ; 7:1
    xor     PRIZNAK_OTEVRENY_INVENTAR   ; 7:2
    ld      (hl),a                      ; 7:1
    and     PRIZNAK_OTEVRENY_INVENTAR   ; 7:2

    jp      nz,INVENTORY_WINDOW_OPEN
    jr      PLAYERS_WINDOW
;         ret                                sem se uz nikdy nedostanu protoze volam fce pomoci jump
; POZOR OPRAVIT ZBYTECNY SKOK






; VSTUP: A = znaky '1' .. '6'
NEW_PLAYER_ACTIVE:
    sub     '1'                     ; A = 0..5
    ld      hl, SUM_POSTAV          ; 10:3
    cp      (hl)                    ;  7:1  0..5 - SUM_POSTAV
    ret     nc                      ; new >= SUM_POSTAV
                                    ; tohle muze nastat jen u 5. a 6. postavy pokud jeste nejsou v parte
    dec     hl                      ;  6:1 hl = HLAVNI_POSTAVA
    cp      (hl)                    ;  7:1
    ret     z                       ; nastavujeme uz aktivni, nebudeme vse znovu prekreslovat
    ld      (hl), A                 ;  7:1 nova HLAVNI_POSTAVA
    
    ; je nastaveny pravy panel na zobrazeni vsech hracu?
    call    TEST_OTEVRENY_INVENTAR  ;dc11
    jp      nz,INVENTORY_WINDOW_REFRESH ; uz se nevratime
    ; jinak pokracujem v PLAYER_WINDOW
;     ret
    
; ----------------------------------
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
    push    BC                          ;dcec   ochranime citac
    call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG ;dced        cd 9d d6         . . . 
    pop     BC                          ;dcf0   vratime citac
    djnz    PW_AVATARS                  ;dcf1
    
    call    SET_TARGET_SCREEN           ;dcf3 
    ld      B, $02                      ;dcf6
PW_KOMPAS_A_SIPKY:
    push    BC                          ;dcf8
    call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG ;dcf9        cd 9d d6         . . . 
    pop     BC                          ;dcfc 
    djnz    PW_KOMPAS_A_SIPKY           ;dcfd 
    
    call    SET_TARGET_BUFFER           ;dcff cd 76 d8         . v . 
    call    ZOBRAZ_ZIVOTY               ;dd02 cd 4b df         . K . 
    ei                                  ;dd05 fb         . 
    call    SET_MAX_17                  ;dd06 cd 95 d8         . . . 
    call    AKTUALIZUJ_RUZICI           ;dd09 cd d6 de         . . . 
    ret                                 ;dd0c c9         . 

    

; ----------------------------------
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



    exx
    ld      HL, POZICE_V_INVENTARI_END
    exx
    ld      HL, MAX_INVENTORY       ; 10:3 
    call    HLAVNI_RADEK_INVENTORY_ITEMS; nacist do DE adresu radku aktivni postavy z INVENTORY_ITEMS
    add     HL, DE

    ld      B, MAX_INVENTORY        ;  7:2
IW_LOOP:
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
    add     A, ITEM2SPRITE % 256
    ld      L, A
if (ITEM2SPRITE/256 != ITEM2SPRITE/256)
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
IW_ZE_ZASOBNIKU:
    pop     bc
    inc     B
    dec     B
    jr      z, IW_EXIT    
    pop     de
    call    COPY_SPRITE2BUFFER
    jr      IW_ZE_ZASOBNIKU
IW_EXIT:        

    call    VYKRESLI_AKTIVNI_PREDMET
    ei
    call    SET_MAX_17                  ; 
    
    ret



; -------------------------------------------------------
VYKRESLI_AKTIVNI_PREDMET:
    call    TEST_OTEVRENY_INVENTAR      ;ddf7        cd a6 ca
    ret     z                           ; u zavreneho nebudem vykreslovat presah
    
    ld      a, (PRESOUVANY_PREDMET)
    or      a
    ret     z                           ; nic nedrzi

    ld      ixh,ITEM2SPRITE / 256
    add     a,a                         ; 2x
    add     a,ITEM2SPRITE % 256
    ld      ixl,a
    
    
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

    ld      e,(ix)
    ld      d,(ix+1)
    push    de
    
;         ld      bc,$1806
    ld      de,I_bgm
    
    push    bc
    call    COPY_SPRITE2BUFFER
    pop     bc
    pop     de
    call    COPY_SPRITE2BUFFER
    ret

    

    
; -------------------------------------------------------
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
    dec     A                       ; 1..16 -> 0..15
    and     $F0                     ; cokoliv na mensi pozici je povoleno
    ret     z

    ld      A, C
    or      A
    ret     z
    
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
 

; ------------------------------
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
    
    
    
; VSTUP:    
;        a = PODTYP predmetu
;        b = cislo ruky od 0
; MENI:
;        a, hl, de
; VYSTUP:   vraci zero-flag pokud je prazdna
VYKRESLI_RUKU:
    pop     hl                      ; vytahni navratovou adresu
    ld      (VR_EXIT+1),hl          ; nastav "jp nn" na konci fce
    add     a,a                     ; v tabulce jsou 16 bit hodnoty
    add     a, ITEM2SPRITE % 256
    ld      (VR_SELF_ITEM + 1),a    ;
   
if ( POZICE_RUKOU / 256 ) != ( POZICE_RUKOU_END / 256 )
    .error      'Seznam POZICE_RUKOU prekracuje 256 bajtovy segment!'
endif

    ld      a,POZICE_RUKOU % 256
    add     a,b
    add     a,B                     ; protoze jde o 16 bit
    ld      (VR_SELF_POZICE + 1),a  ;
VR_SELF_ITEM:
    ld      hl,(ITEM2SPRITE)        ; hl = adresa spravneho spritu
    ld      a,h                     ; byl nulovy?
    or      a
    jr      nz,VR_DRZI
    ld      hl,I_empty              ; obrazek prazdne dlane pokud nic nedrzi
VR_DRZI:
    push    hl                      ; ulozime na zasobnik adresu spritu
VR_SELF_POZICE:
    ld      hl,(POZICE_RUKOU)       ; 
    push    hl                      ; prihodime na zasobnik i pozici
    ld      de,I_bg                 ; prazdny podklad
    push    de                      ; ulozime na zasobnik adresu podkladoveho spritu
    push    hl                      ; prihodime na zasobnik i pozici  
VR_EXIT:
    jp      0                       ; self-modifying
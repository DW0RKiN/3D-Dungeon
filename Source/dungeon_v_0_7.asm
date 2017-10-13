; volna pamet 0x5E00+
spritesStart        equ        $5F00        ; 

INCLUDE sprites.h

org spritesStart

INCBIN grafika.bin


progStart           equ        $D000        ; 53248

if ( Adr_Buf_end > progStart )
    .error 'Pretikaji sprity do kodu!'
endif

org        progStart

INCLUDE zrcadlovy.h         ; 256 bajtu
INCLUDE map.h               ; 16x16 = 256 bajtu


dopredu             equ     0
dozadu              equ     4
vlevo               equ     8
vpravo              equ     12




VEKTORY_POHYBU:                ; musi byt na adrese delitelne 256
;       N       E       S       W
defb    -sirka,     +1, +sirka,     -1  ;  0 dopredu
defb    +sirka,     -1, -sirka,     +1  ;  4 dozadu
defb        -1, -sirka,     +1, +sirka  ;  8 vlevo
defb        +1, +sirka,     -1, -sirka  ; 12 vpravo

    
if (VEKTORY_POHYBU % 256 !=  0 )
    .error      'Seznam VEKTORY_POHYBU neleze na zacatku segmentu!'
endif




PRIZNAK_OTEVRENY_INVENTAR   equ     1

PRIZNAKY:
defb        0


; =====================================================
; Pokud se da cokoliv dalsiho nad MAIN tak to zmeni adresu vstupniho bodu!!!
MAIN:                               ;
    call    PUSH_ALL

    di                              ;
    im      1                       ;
    ei                              ;
    ld      a, 12                   ;
    ld      hl, $5C09               ; HL = 23561
    ld      (hl), a                 ; POKE 23561,12 ( cas prodlevy autorepeat )
    dec     l                       ; HL = 23560 = LAST K system variable
    ld      (hl), 0                 ; put null value there
        
    ; vycisti textove okno
    ld      BC, $2004               ; velikost vyplnovaneho okna v sloupcich a radcich
    ld      HL, $5A80               ; levy horni roh textoveho okna
    call    FILL_ATTR_BLOCK

    call    HELP
    call    PLAYERS_WINDOW
    
MAIN_LOOP:
    ; vykresli okoli kompasu (musi byt pred VIEW aby bylo prekresleno zvedlym predmetem)
    ld      DE, Kompas
    ld      BC, KOMPAS_POZICE
    di
    call    COPY_SPRITE2BUFFER
    ei

    di
    call    DRAW3D
    ei

;     call    COPY_VYREZ2SCREEN
    call    TEST_OTEVRENY_INVENTAR
    jr      nz, MAIN_OTEVRENY_INVENTAR
    call    PLAYERS_WINDOW_AND_DAMAGE
MAIN_OTEVRENY_INVENTAR:

    call    AKTUALIZUJ_RUZICI           ;
    ld      DE, S_vsechny
    ld      BC, SIPKY_POZICE
    di
    call    COPY_SPRITE2BUFFER
    ei
    
    call    BUFF2SCREEN

    call    TIME_SCROLL
    call    KEYPRESSED                  ; obsahuje EXIT_PROGRAM
    jp      MAIN_LOOP
    


; =====================================================
POSTAVA_PLUS:
    ld      HL, SUM_POSTAV              ; 1..6
    ld      A, (HL)                     ;
    dec     HL                          ; 
    inc     (HL)                        ; HLAVNI_POSTAVA++
    sub     (HL)                        ;      
    ret     nz
    ld      (HL), A                     ; A = 0
    ret


; =====================================================
POSTAVA_MINUS:
    ld      HL, SUM_POSTAV              ; 1..6
    ld      A, (HL)                     ;
    dec     HL
    dec     (HL)                        ; HLAVNI_POSTAVA--
    ret     p
    dec     A                           ; SUM_POSTAV--
    ld      (HL), A                     ;
    ret
    

INCLUDE input.h    

; =====================================================
; VSTUP:
;   A = KEY_FHAND nebo KEY_SHAND
;   na zasobniku lezi adresa NEW_PLAYER_ACTIVE
BOJ:
; opravit !!!!!!! nevykreslovat kdyz jsme v inventari
    
if (  KEY_FHAND > KEY_SHAND )
    sub     KEY_FHAND                   ; carry pokud KEY_SHAND
else
    ; KEY_SHAND > KEY_FHAND
    add     256-KEY_SHAND               ; carry pokud KEY_SHAND
endif
    
    ld      A, (HLAVNI_POSTAVA)
    adc     A, A                        ; zobrazeny 2 ruce na osobu + carry spodni ruka   
    call    DE_POZICE_RUKOU_A
    ld      B, D
    ld      C, E
    ld      DE, miss
    call    SET_MAX_31
    call    SET_TARGET_SCREEN
    di
    call    COPY_SPRITE2BUFFER
    ei
    call    SET_TARGET_BUFFER
    call    SET_MAX_17    
    
    ret



; ===================================

org  progStart + $0300

INCLUDE font.h
INCLUDE typy.h
; Bacha na poukovani z basicu do promenne LOCATION
INCLUDE move.h

if (0)
;SMAZ_NA_KONCI_AZ_NEBUDES_HYBAT_STALE_S_KODEM:
REPT    0       ; nejaka hodnota co posune data mimo zlom segmentu
defb    0
ENDM
endif

INCLUDE objects.h
INCLUDE inventory.h
INCLUDE draw3D.h
INCLUDE strings.h

;SMAZ_NA_KONCI_AZ_NEBUDES_HYBAT_STALE_S_KODEM:
REPT    0       ; nejaka hodnota co posune data mimo zlom segmentu
defb    0
ENDM





CARKY:
defb    $00     ; 0000 0000
defb    $80     ; 1000 0000
defb    $C0     ; 1100 0000
defb    $E0     ; 1110 0000
defb    $F0     ; 1111 0000
defb    $F8     ; 1111 1000 
defb    $FC     ; 1111 1100
defb    $FE     ; 1111 1110
defb    $FF     ; 1111 1111
CARKY_END:


INCLUDE sprite2buffer.asm
INCLUDE input.asm
INCLUDE move.asm
INCLUDE strings.asm
INCLUDE objects.asm
INCLUDE draw3D.asm
INCLUDE inventory.asm


; =====================================================
; Vcetne hl
PUSH_ALL:
    di
    ld      (PUSH_ALL_HL+1),hl          ; ulozeni "hl" do pameti
    ex      (sp),hl                     ; push    "hl" a zaroven nacteni navratove adresy do "hl"

    push    af
    push    bc
    push    de
    push    ix
    push    iy

    ex      af,af'
    push    af
    ex      af,af'
    exx
    push    bc
    push    de
    push    hl
    exx

    ei
    push    hl                          ; ulozeni navratove hodnoty na zasobnik
PUSH_ALL_HL:        
    ld      hl,0                        ; obnoveni registru "hl"
    ret

    
; =====================================================
; Vcetne hl
POP_ALL:
    di
    pop     hl                          ; navratova adresa do "hl"

    exx
    pop     hl
    pop     de
    pop     bc
    exx
    ex      af,af'
    pop     af
    ex      af,af'

    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     af
    
    ex      (sp),hl                     ; push    "navratove adresy" a zaroven pop     "hl"

    ei
    ret




; =====================================================
; Nastal uz cas scrollovat stare zpravy?
; ver 0.1
TIME_SCROLL:
    ld      a,(TIMER_ADR+1)         ; 13:3
    and     $02                     ;  7:2
    
    ld      b,a                     ;  4:1
TIME_SCROLL_LAST:
    xor     0                       ;  7:2 self-modifying, zde ma lezet predchozi
    ret     z                       ; 11/5:1 ret z C8 / ret nz C0 
    ld      a,B                     ;  4:1
    ld      (TIME_SCROLL_LAST+1),a  ; 13:3
    call    SCROLL
    ret


    



; =====================================================
; Stisknut SPACE
; v "c" je (VECTOR)
; v "hl" je aktualni lokace
; MENI: hl pri hledani dalsich objektu co se musi prepnout
PREHOD_PREPINAC:
    call    TEST_OTEVRENY_INVENTAR  
    ; A = index kurzoru v inventari
    jp      z, PP_NEJSME_V_INVENTARI
    ; jsme v inventari

    ; ohlidani zda ukladam na povolene misto ( toulec, prsteny atd )        
    ld      B, A
    inc     B                           ; INDEX
    ld      HL, PRESOUVANY_PREDMET    
    ld      C, (HL)                     ; C = presouvany predmet
    call    TEST_NEPOVOLENE_POZICE
    
    ld      IX, VETA_NO_PUT
    jp      nz, PRINT_MESSAGE           ; misto return, nepovoleno
    
    ld      A, INDEX_PROSTIRANI
    sub     B
    push    HL                          ; PRESOUVANY_PREDMET
    ; potrebuji uchovat uz jen BC    
    ; pokud je zero flag tak do C dat nulu
    call    z, EATING                   ; C = co ji/pije -> C = 0 (bude vynulovan)

    ld      H, $00
    ld      L, B
    dec     L
    call    DE_INVENTORY_ITEMS_AKTIVNI  ; nacist do DE adresu radku aktivni postavy z INVENTORY_ITEMS
    add     HL, DE
    
    ld      A, (HL)                     ; predmet ktery vymenime za presouvany
    ld      (HL), C                     ; puvodne presouvany ulozime
    pop     HL
    ld      (HL), A                     ; nove presouvany

    push    BC                          ; ulozime puvodne presouvany
    call    ITEM_TAKEN_A
    pop     BC
    
    ld      HL, (PRESOUVANY_PREDMET)    ; L = PRESOUVANY_PREDMET, H = KURZOR_V_INVENTARI
    ld      A, H
    sub     INDEX_ZEM_LU_M1
    jp      c, INVENTORY_WINDOW_KURZOR
    ; pokladame/bereme ze zeme
    
    ; A = 0..3 = 0(LeftUp), 1(LeftDown), 2(RightUp), 3(RightDown)
    ; Up lezi na lokaci pred nama, jinak kde stojime
    ; Rohy LU=VECTOR+3, LD=VECTOR+0, RU=VECTOR+2, RD=VECTOR+1
    ; 0->3(7), 1->0(4), 2->2(6), 3->1(5)

    ld      H, PP_DATA / 256
    add     A, PP_DATA % 256
    ld      L, A
    ld      B, (HL)                     ; 0,1,2,3 -> 3,0,2,1

    ld      HL, (LOCATION)              ; 16:3 L=LOCATION, H=VECTOR
    bit     1, B
    call    nz, HL_VEPREDU              ; L=LOCATION vepredu, H=VECTOR
    
    ld      A, H
    add     A, B
    ld      H, A
    
    ld      A, C
    ; pokud C je nula tak bereme (nic jsme nedrzeli), jinak pokladame
    or      A
    push    AF
    call    nz, VLOZ_ITEM_NA_POZICI
    pop     AF
    call    z, VEZMI_ITEM_Z_POZICE
    
    jp      INVENTORY_WINDOW_KURZOR


PP_DATA:
defb    3,0,2,1
PP_DATA_END:

if (PP_DATA / 256 != PP_DATA_END / 256 )
    .error 'PP_DATA!'
endif


PP_NEJSME_V_INVENTARI:
    call    HL_VEPREDU                  ; l = hledana lokace = aktualni + vpred
    
    ld      A, TYP_PREPINAC             ;  7:2
    add     A, C                        ;  4:1
    ld      B, A                        ;  4:1 spravne natoceny prepinac ktery hledame
    
    ; L lokace pred nama
    call    DE_FIND_FIRST_OBJECT_L
    ; DE = @(TABLE_OBJECTS[?].prepinace+typ)
    ; zero nalezen, not zero nenalezen
PP_NALEZEN_OBJEKT:                      ; na lokaci lezi nejaky objekt
    ret     nz                          ;11/5:1 nenalezena

    ld      a,(de)                      ;  7:1 typ
    and     MASKA_TYP + MASKA_NATOCENI  ;  7:2
    cp      B                           ;  4:1 je to spravne natoceny prepinac?
    jr      z, PP_PROHOD_PAKU           ;12/7:2
    
    and     MASKA_TYP
    cp      TYP_DEKORACE
    call    z, PRINT_DEKORACE           ; vypisi jen pokud je to dekorace
    
    call    FFO_NEXT
    ; DE = @(TABLE_OBJECTS[?].prepinace+typ)
    ; zero nalezen, not zero nenalezen
    jr      PP_NALEZEN_OBJEKT


PP_PROHOD_PAKU:

    ; nalezen spravny prepinac pred nama!

if ( KONTROLUJ_NATOCENI_U_PREPINACU )
    ld      A, (DE)                     ;  7:1 typ
    xor     ZAM_1                       ;  7:2 prepneme paku / prohodime horni bit
    ld      (de),a                      ;  7:1 typ
else
    ld      H, ZAM_1 + TYP_PREPINAC
    call    PREPNI_OBJECT
endif
    ; zjistime co paka prehazuje a prehodime VSECHNY dalsi
    inc     de                          ;  6:1 DE = @(TABLE_OBJECTS[?].dodatecny)
    
    call    PRINT_PREPINAC              ;   
    
PP_LOOP:

    inc     de                          ;  6:1 de: "dodatecny"->"lokace"
    ld      a,(de)                      ;  7:1 lokace
    or      a                           ;  4:1 lokace nula znaci rozsirene udaje predchoziho radku
    ret        nz                       ;11/5:1

    inc     de                          ;  6:1 de: "lokace"->"typ (alias lokace prepinaneho)"
    ld      a,(de)                      ; typ (alias lokace prepinaneho)
    ld      l,a
    inc     de                          ;  6:1 de: "typ"->"dodatecny"
    ld      a,(de)                      ; dodatecny ( v tomto pripade je to typ prepinaneho predmetu )
    ld      h,a

    call    PREPNI_OBJECT
    jp      PP_LOOP
    

; =====================================================
; Vypise do textoveho pole napovedu
HELP:
    ld      ix,HELP_STRING
    ld      a,%00000010             ; cervena
    call    PRINT_MESSAGE_COLOR
    call    PRINT_MESSAGE
    call    PRINT_MESSAGE
    call    PRINT_MESSAGE
    ret

  
; =====================================================
OBAL_SPRITE2BUFFER:
    push    af
    push    hl
    push    de
    call    COPY_SPRITE2BUFFER
    pop     de
    pop     hl
    pop     af
    ret


; =====================================================
; nataci kompas
AKTUALIZUJ_RUZICI:
    ld      a,(VECTOR)                  ; 13:3 0 = N,1 = E,2 = S,3 = W
    add     a,a                         ;  4:1 2x
    add     a,a                         ;  4:1 4x
    add     a,RUZICE % 256              ;  7:2
    ld      l,a                         ;  4:1
if (RUZICE/256) != (RUZICE_END/256)
.warning 'Delsi kod o 2 bajty! RUZICE a RUZICE_END lezi na dvou segmentech!'

    adc     a,RUZICE / 256              ;  7:2 resi preteceni
    sub     l                           ;  7:2 
    ld      h,a                         ;  4:1 hl = ukazatel na ukazatel spravneho spritu

else
    ld      h,RUZICE / 256              ;  7:2 resi preteceni

endif        
    di
    call    INIT_COPY_PATTERN2BUFFER
    ei
    ret


; =====================================================
; Vykresluje sipky primo na obrazovku
; VSTUP: a = 0 dopredu, 4 dozadu , 8 vlevo, 12 vpravo, 16 otoceni doleva, 20 otoceni doprava, 24 jen sipky
AKTUALIZUJ_SIPKY:
    push    BC
    push    HL

    ld      L, A                        ; 4:1
    call    SET_TARGET_SCREEN           ; prepis INIT_COPY_PATTERN2BUFFER na SCREEN, meni jen akumulator
    ld      A, L                        ; 4:1

    ld      HL, SIPKY                   ;10:3
    di
    call    INIT_COPY_PATTERN2BUFFER    ; samotne nestisknute sipky = smaze predchozi stisk    
    add     A, L                        ; 4:1
    ld      L, A                        ; 4:1
    
if (SIPKY/256) != (SIPKY_END/256)
    .warning    'Delsi kod o 3 bajty! Pole SIPKY preleza 256 bajtovy segment!'
    
    adc     A, H                        ; 4:1
    sub     L                           ; 4:1
    ld      H, A                        ; 4:1 H + carry
endif

    call    INIT_COPY_PATTERN2BUFFER    ; konkretni stisknuta sipka
    ei
    call    SET_TARGET_BUFFER           ; vrat INIT_COPY_PATTERN2BUFFER na BUFFER
    
    pop     HL
    pop     BC
    ret


    

    
if (0)
; ---------------------------------------------
; Fce kresli plnou vodorovnou caru po znacich
; VSTUP:        HL = adresa odkud zacnem
;                b  = pocet znaku
HORIZONTAL_FULL_LINE:
    ld      a,$ff
; Fce kresli vodorovnou caru po znacich vyplnenou registrem "c"
; VSTUP:        HL = adresa odkud zacnem
;                b  = pocet znaku
;                a  = vypln
; VYSTUP: Meni l += b
HORIZONTAL_MASK_LINE:

HML_LOOP:
    ld      (hl),a
    inc     l
    djnz    HML_LOOP
    ret
    
endif
    
    

if ( 0 )
; ---------------------------------------------
; Fce vyplni dany blok hodnotou E, sirka a vyska je po znacich
; Fce kresli vodorovnou caru po znacich vyplnenou registrem "a"
; VSTUP:    HL = adresa odkud zacnem
;           ixh  = pocet znaku na sirku
;           ixl  = pocet znaku na vysku
;           d = pocet mikroradku
;           e = vzor, kterym budeme plnit
; pozor, nehlida tretiny
; NEMENI:   IX, L
; MENI:     A, BC, H pokud D>1, D = 0
FILL_BLOCK:
    ld      A, L                ;  4:1 nastavime na prvni znak a budeme postupne zvysovat o 32 => o znak nize

FB_DALSI_MICROLINE:
    push    AF                  ; 11:1 ulozime L
    ld      C, IXL              ;  8:2 nastavime citac poctu radku
FB_DALSI_RADEK:
    ld      B, IXH              ;  8:2 nastavime citac poctu sloupcu

FB_DALSI_SLOUPEC:
    ld      (HL), E             ;  7:1
    inc     L                   ;  4:1
    djnz    FB_DALSI_SLOUPEC    ;13/8:2

    add     A, $20              ;  7:2
    ld      L, A                ;  4:1 stejna mikroradka o znak/radek nize
    dec     C                   ;  4:1
    jr      nz, FB_DALSI_RADEK  ;12/7:2

    pop     AF                  ; 10:1
    ld      L, A                ;  4:1
    dec     D                   ;  4:1
    ret     z                   ;11/5:1 pokud byla vyplnena jen jedna mikroradka ( atributy ) tak hl nebylo zmeneno

    inc     H                   ;  4:1 o mikroradek nize
    jp      FB_DALSI_MICROLINE  ; 10:3
   
;  -21 + mikroradku*( 57 + radku*(30+sloupcu*24)) 
; 1,3,14 = 1134
; 8,3,14 = 9219
; 1,1,14 = 402
; 8,1,14 = 3363
        
; Vstup: B = sloupce 1..x
;        C = radky   1..y
;        HL = adresa atributu
FILL_ATTR_BLOCK:
    ld      IXH, B                  ; 8:2 push    bc + pop     ix = 11+14:1+2
    ld      IXL, C                  ; 8:2
    ld      DE, $0107               ; 10:3 jen 1 mikroradek a bila barva (vzor)
    call    FILL_BLOCK

    call    SEG_ATTR2SCREEN
    ld      DE, $0800               ; 10:3 8 mikroradku a vyplnujeme nulama
    call    FILL_BLOCK
    ret
else

; =====================================================
; VSTUP:    
;   HL = adresa kam se to bude ukladat
;   B = pocet mikroradku
;   D = pocet sloupcu
;   C = pocet radku
;   E = maska
; MENI: A, B = 0, D, H -= B, priznaky
; ZACHOVA: L, C, DE
FILL_BLOCK:
FB_PIXEL:
    push    BC                  ; 11:1
    push    HL                  ; 11:1
    ld      A, L                ;  4:1
FB_RADEK:
    ld      B, D                ;  4:1
        
FB_DALSI_SLOUPEC:
    ld      (HL), E             ;  7:1
    inc     L                   ;  4:1
    djnz    FB_DALSI_SLOUPEC    ;13/8:2
        
    add     A, $20              ;  7:2 o radek nize
    ld      L, A                ;  4:1
    dec     C                   ;  4:1
    jr      nz, FB_RADEK        ;12/7:2

    pop     HL                  ; 10:1 obnovi L      
    pop     BC                  ; 10:1 obnovi B a C
    inc     H                   ;  4:1
    djnz    FB_PIXEL            ;13/8:2

    ret                         ; 10:1
;  5 + mikroradku*( 58 + radku*(26+sloupcu*24)) 
; 1,3,14 = 1149
; 8,3,14 = 9157
; 1,1,14 = 425
; 8,1,14 = 3365


; =====================================================
; VSTUP:
;   C = PODTYP_ITEM co ji/pije
EATING:
    push    BC
        
    ld      A, (HLAVNI_POSTAVA)
    call    HL_DATA_ZIVOTY_A
    ; HL = DATA_ZIVOTY[HLAVNI_POSTAVA].nyni
    
    inc     HL                      ; DATA_ZIVOTY[HLAVNI_POSTAVA].max
    ld      DE, VETA_DRINK          ; veta bude piti

    ld      A, C
    sub     PODTYP_FOOD
    jr      nz, E_NO_FOOD
    ; food
    ld      DE, VETA_EAT            ; vymenime vetu za jezeni
E_NO_FOOD:

    dec     A
    jr      nz, E_NO_R    
    ; healing potion
    ld      B, (HL)                 ; max
    dec     HL                      ; DATA_ZIVOTY[HLAVNI_POSTAVA].nyni
    ld      (HL), B                 ; nyni = max
E_NO_R:
    
    dec     A
    jr      nz, E_NO_G
    ; antidote potion
    inc     HL                      ; DATA_ZIVOTY[HLAVNI_POSTAVA].trvale
    ld      (HL), A                 ; trvale = 0
E_NO_G:


    dec     A
    jr      nz, E_NO_B
    ; blue potion
E_NO_B:


E_PRINT
    ex      DE, HL
    ; HL veta
    ld      A, C
    ; A index predmetu
    call    ITEM_MAKE_A
    
; !!!!! DODELEJ    
    pop     BC
    ld      C, $00
    ret


; =====================================================
; Vstup: B = sloupce 1..x
;        C = radky   1..y
;        HL = adresa atributu
FILL_ATTR_BLOCK:
    ld      D, B                ;  4:1 D = sloupce, C = radky
    ld      E, $07              ;  7:2 bila
    ld      B, $01              ;  7:2 B = mikroradky
    call    FILL_BLOCK
        
    dec     H                   ;  4:1
    call    SEG_ATTR2SCREEN

    ld      E, $00              ;  7:2 jen paper
    ld      B, $08              ;  7:2 B = mikroradky
    call    FILL_BLOCK
    ret
endif
        

; =====================================================
; meni A a z HL ukazujici na atributy udela HL ukazujici na ZNAK ve screen/buffer
; Fce prevadejici segment atributu na segment obrazu
;                   10xy     10x y
;   $58 -> $40 0101 1000 -> 0100 0000
;   $59 -> $48 0101 1001 -> 0100 1000
;   $5A -> $50 0101 1010 -> 0101 0000
;                              x y 
;   $FB -> $E3 1111 1011 -> 1110 0011
;   $FC -> $EB 1111 1100 -> 1110 1011
;   $FD -> $F3 1111 1101 -> 1111 0011
; VSTUP:
; H = $58, $58, $5A nebo $FB, $FC, $FD
; VYSTUP:
; carry = 0
; H = $40, $48, $50 nebo $E3, $EB, $F3
; offset atributu = offset zacatku znaku na obrazovce
SEG_ATTR2SCREEN:
    ld      A, H                        ; do akumulatoru dame segment atributu
    ld      H, Adr_Buffer/256           ; H = $E3 = segment prvni tretiny buferu obrazovky
    sub     Adr_Attr_Buffer/256         ; A = H - $FB, odecteme od segmentu atributu segment pocatku atributu v buferu 
    jr      nc, SA_BUFF                 ; 0,1,2 => nc = dodany segment je z buferu; zaporny vysledek => dodany segment byl z obrazovky 
    ld      H, $40                      ; segment prvni tretiny obrazovky ZX
    add     A, Adr_Attr_Buffer/256-$58  ; +$A3, spletli jsme se, meli jsme odcitat -$58 a ne Adr_Attr_Buffer/256
SA_BUFF:
    add     A, A                        ; 2 x 0..2 chceme jen posledni 2 bity a ty vynasobit osmi a pricist k segmentu zacatku obrazu
    add     A, A                        ; 4 x 0..2
    add     A, A                        ; 8 x 0..2
    add     A, H                        ; $40 + 8*(H-$58) nebo $E3 +8*(H-$FB) 
    ld      H, A                        ; 
    ret                                 ;

    
; =====================================================
ZOBRAZ_ZIVOTY:
    ld      HL, DATA_ZIVOTY             ;
    ld      B, $06                      ; 6 postav 
ZZ_LOOP:
    push    BC                          ; 
    ld      C, (HL)                     ; C = akt. pocet zivotu = DATA_ZIVOTY[x].nyni
    inc     L                           ; DATA_ZIVOTY[x].max
    ld      B, (HL)                     ; B = max. pocet zivotu 
    inc     L                           ; DATA_ZIVOTY[x].trvale
    inc     L                           ; DATA_ZIVOTY[x].offset
    ld      E, (HL)                     ; E = offset
    inc     L                           ; DATA_ZIVOTY[x].segment
    ld      D, (HL)                     ; DE = adresa atr. zacatku prouzku
    
    call    VYKRESLI_ZIVOTY             ;
    
    inc     L                           ; DATA_ZIVOTY[x].konec
    ld      C, (HL)                     ; cas ukonceni
    inc     L                           ; DATA_ZIVOTY[x].zraneni 
    
    ld      A, (TIMER_ADR)              ; akt. cas
    cp      C                           ; akt. cas - cas ukonceni
    jr      c, ZZ_NEVYPRSEL    
    xor     A                           ; cas vyprsel 
    ld      (HL), A                     ; vynulovani hodnoty posledniho zraneni
ZZ_NEVYPRSEL:

    ld      A, (HL)                     ; A = posledni zraneni 
    or      A                           ; 
    jr      z, ZZ_BEZ_AKT_ZRANENI       ; 

    ld      B, A                        ; velikost zraneni
    call    VYKRESLI_KRVAVY_FLEK        ; 
    
ZZ_BEZ_AKT_ZRANENI:
    inc     L                           ; DATA_ZIVOTY[x+1].nyni
    pop     BC                          ; 
    djnz    ZZ_LOOP                     ; 
    ret                                 ; 


; =====================================================    
; VSTUP: 
; DE = adresa atr. pocatku prouzku
; B = velikost zraneni
VYKRESLI_KRVAVY_FLEK:
    push    HL

    ; prevod adresy atr. na Y = 7*segment + 4
    ld      A, D                ; segment pocatku prouzku
    add     A, A                ; 2x
    add     A, A                ; 4x
    add     A, A                ; 8x 
    sub     D                   ; 7x
Pomocny equ (Adr_Attr_Buffer/256)*7-4
    sub     Pomocny             ; usetrim bajty 7*(D-seg Attr)+4 = 7*D - 7*seg Attr + 4 = 7*D - ( 7*seg Attr - 4)
    ld      C, A                ; C = Y

    ; prevod adresy atr. na X = offset % 32 - 1
    ld      A, E                ; offset pocatku prouzku
    and     $1f                 ; offset na sloupce
    dec     A                   ; sprite zacina o znak vlevo nez prouzek
    ld      B, A                ;
    
    push    DE                  ; budem jeste vypisovat hodnotu zraneni

    ld      DE, Flek            ;
    ; DE adresa spritu
    ; BC ...B=sloupec {0..17+}, C=radek {0..13}
    call    OBAL_SPRITE2BUFFER  ;
    
    pop     HL                  ;
    inc     L                   ;
    inc     L                   ; text zraneni chceme uprostred fleku
    ld      ix, DAMAGE_BUF      ; 
    ld      A, $42              ; light red
    call    PRINT_STRING_COLOR  ;
    
    pop     HL                  ; 
    ret                         ; 
    
DAMAGE_BUF:
defb        "1",0


    
; =====================================================
; Zobrazi prouzek s zivoty
; VSTUP: 
;   C = aktulni pocet zivotu
;   B = maximalni pocet zivotu
;   DE = adresa atr. pocatku prouzku
; MENI:  B = 0, C, AF
VYKRESLI_ZIVOTY:
    push    HL                  ;    
    push    DE                  ;
    push    DE                  ; 11:1 adresa atr. pocatku prouzku
    
    xor     A                   ;  4:1 A = 0
    ld      H, A                ;  4:1
    ld      L, C                ;  4:1 HL = aktualni pocet zivotu
    ld      D, A                ;  4:1
    ld      E, B                ;  4:1 DE = maximalni pocet zivotu
    ld      B, A                ;  4:1 BC = aktualni pocet zivotu
        
    add     HL, HL              ; 11:1 2x 
    add     HL, HL              ; 11:1 4x 
    add     HL, BC              ; 11:1 5x
    ld      C, A                ;  4:1 C = 0
    scf                         ;  4:1 (= dec     HL)
VZ_ZNAKU:
    dec     C                   ;  4:1
    sbc     HL, DE              ; 15:2
    jr      nc, VZ_ZNAKU        ; 12/7:2
    adc     HL, DE              ; 15:2 HL = zbytek = 0..maximalni pocet zivotu
    
    add     HL, HL              ; 11:1 2x
    add     HL, HL              ; 11:1 4x
    add     HL, HL              ; 11:1 8x zbytek
VZ_ZBYTEK:
    inc     A                   ;  4:1
    sbc     HL, DE              ; 15:2
    jr      nc, VZ_ZBYTEK       ; 12/7:2
    
    ; C = -(znaku+1) = -1..-5
    ; A = zbytek+1 = 1..9

if ((CARKY-1) / 256) != ( CARKY_END / 256 )
    .error      'Seznam CARKY prekracuje segment!'
endif

    add     A,(CARKY-1)%256     ; offset + 1..8
    ld      L, A                ;  4:1
    ld      H, CARKY / 256      ;  7:2
    ld      D, (HL)             ;  7:1 D = maska znaku s koncem prouzku
    
    ; zjisteni barvy prouzku
    ld      A,C                 ;  4:1 zaporny pocet znaku prouzku  -5 = ..011, -4 = ..100, -3 = ..101, -2 = ..110, -1 = ..111
    inc     A                   ;  4:1  -4 = ..10., -3 = ..10., -2 = ..11., -1 = ..11.
    jr      nz, VZ_VICEZNAKOVY  ; 12/7:2
    ld      a, $42              ; light red = ..01.
VZ_VICEZNAKOVY:
    and     $46                 ; 0100 0110 = BRIGHTNES + INK GREEN + INK RED
    ld      E, A                ;  4:1 E = barva prouzku    
    
    ; zacatek smycky vykresleni prouzku
    pop     HL                  ; adresa atr. pocatku prouzku
    ld      B, $05              ; 5 znaku     
VZ_LOOP_SELF:
    ld      A, D                ;  4:1 obsahuje masku konce prouzku 
    inc     C                   ;  4:1 zmensime zaporny pocet celych znaku
    jr      z, VZ_PREDEL        ;12/7:2 posledni znak? 
    ld      A, C                ;  4:1
    rla                         ;  4:1 carry kdyz C < 0
    sbc     A, A                ;  4:1 if (carry) A = $ff else A = $00
VZ_PREDEL:

    ; A = $FF, $?? = D, $00
VZ_COL_SELF:
    ld      (HL), E             ; barva prouzku 
    push    HL                  ; uschovame adresu zacatku prouzku 
    push    BC                  ; uschovame hodnotu registru B
    ld      C, A                ; "prouzek" do C
    call    SEG_ATTR2SCREEN     ; zrusi A, z HL ukazujici na atributy udela HL ukazujici na screen/buffer
    ld      B, $06              ; 6 carek
VZ_LOOP_PX:
    inc     H                   ; prvne klesneme o pixel
    ld      (HL), C             ; ulozime "prouzek"
    djnz    VZ_LOOP_PX          ; 
    pop     BC                  ; obnovime hodnotu registru B
    pop     HL                  ; obnovime adresu zacatku prouzku
    
    inc     L                   ; o znak doprava

    djnz    VZ_LOOP_SELF        ; 5x 
    pop     DE                  ;
    pop     HL                  ;
    ret                         ; 


; =====================================================
; VSTUP:
;   E = index postavy hrace 0..5
VYHAZEJ_VSECHNO:
    push    BC
    push    DE
    
    ld      A, E
    call    DE_INVENTORY_ITEMS_A    
    ld      B, MAX_HOLD_INVENTORY

VV_LOOP:    
    push    DE
    push    BC

    ; VSTUP:
;   A = PODTYP_ITEM
;   DE = adresa ktera se bude nulovat
;   L = lokace kam vkladam
;   C = vector
    ld      HL, (LOCATION)
    ld      A, (DE)
    or      A
    call    nz, VLOZ_ITEM_NA_POZICI

    pop     BC
    pop     DE
    
    xor     A
    ld      (DE), A                     ; vymazani predmetu
    
if ( INVENTORY_ITEMS / 256 != INVENTORY_ITEMS_END / 256 )
    .warning 'Pomalejsi kod kvuli vicesegmentovemu INVENTORY_ITEMS'
    inc     DE
else
    inc     E
endif
    djnz    VV_LOOP
    
    pop     DE
    pop     BC
    ret


; +1 aby slo dat index o 1 vyssi nez je pocet postav a pak ubirat
if (DATA_ZIVOTY / 256) != ( (1+DATA_ZIVOTY_END) / 256 )
    .error      'Seznam DATA_ZIVOTY prekracuje segment!'
endif

; =====================================================
; VSTUP: 
;   A = index postavy hrace 0..5(6)
; VYSTUP:
;   HL = DATA_ZIVOTY[A]
HL_DATA_ZIVOTY_A:
    ld      L, A
    add     A, A                ; 2x
    add     A, A                ; 4x
    add     A, A                ; 8x
    sub     L                   ; 7x
    add     A, DATA_ZIVOTY % 256;
    ld      L, A
    ld      H, DATA_ZIVOTY / 256
    ret
    

; =====================================================
; VSTUP: E = index postavy hrace 0..5
;        D = zraneni
ZRAN_POSTAVU:
    push    DE                  ;

    ld      A, E                ;
    call    HL_DATA_ZIVOTY_A
    
    ld      A, (HL)             ; DATA_ZIVOTY[E].nyni 
    sub     D                   ; - zraneni 
    jr      nc, ZP_ZIJE         ; 
    xor     A                   ; zemrel, vynulujeme zaporne zivoty na nulu 
    ld      (HL), A             ; ulozime nulu
    call    VYHAZEJ_VSECHNO
    
    jr      ZP_EXIT             ;
ZP_ZIJE:
    ld      (HL), A             ; ulozime zbyvajici pocet zivotu
    
    inc     HL                  ; max
    inc     HL                  ; trvale
    inc     HL                  ; offset
    inc     HL                  ; segment
    inc     HL                  ; konec
    
    ld      A, (TIMER_ADR)      ; 
    add     A, $32              ; +50 = +1 vterina
    ld      (HL), A             ; doba zobrazovani krvaveho fleku s hodnotou zraneni 
    
    inc     HL                  ; zraneni
    ld      (HL), D             ; ulozim hodnotu posledniho zraneni 
ZP_EXIT:
    pop     DE                  ;
    ret                         ; 


; =====================================================
; VSTUP: E = index postavy hrace 0..5
;        D = zraneni
OTESTUJ_TRVALE_ZRANENI:
    push    DE
    ld      A, E
    call    HL_DATA_ZIVOTY_A
    
    inc     HL                  ; max
    inc     HL                  ; trvale
    ld      A, (HL)             ;
    or      A
    ld      D, A
    call    nz, ZRAN_POSTAVU
    pop     DE
    ret    
    
    
; =====================================================
PLAYERS_WINDOW_AND_DAMAGE:
PWAD_SELF:
    ld      a,$00               ; 
    ld      hl,TIMER_ADR        ; 1/50 vteriny citac
    xor     (hl)                ; je hornibit shodny s ulozenym 
    and     $80                 ; zajima nas jen horni bit
    jr      z,PWAD_NEZRANUJ     ; 
    
    ld      a,(hl)              ; ulozime horni bit
    ld      (PWAD_SELF+1),a     ;
    
    ld      de,$0100            ; D = 1 = zraneni, E = 0 = index postavy 
    ld      B,$06               ; citac = 6 
PWAD_LOOP:
    call    OTESTUJ_TRVALE_ZRANENI   ; 
    inc     e                   ; dalsi postava
    djnz    PWAD_LOOP           ;
PWAD_NEZRANUJ:
    call    PLAYERS_WINDOW      ; 
    ret                         ; 

    

; =====================================================
BUFF2SCREEN:

    call    PUSH_ALL
    
    xor     A                   ; cerne pozadi
    out     (254), A
    
    ; init
    ld      HL, Adr_Attr_Buffer
    ld      (B2S_SELF_SRC+1), HL

    halt
    di
    ld      HL, $0206           ; cekani na 14560+ T-states az budeme delat prvni PUSH (paprsek kresli prvni pixely)
B2S_WAIT:
    dec     HL
    ld      A, H
    or      L
    jr      nz, B2S_WAIT        ; vynulovani HL
    
    ld      C, L                ; vynulovani pocitadla radku
    add     HL, SP
    ld      (B2S_SELF+1), HL    ; ulozeni puvodni hodnoty SP

    ld      B, $08
    ld      HL, Adr_Buffer + 16 ; budeme kopirovat pravou stranu radku (znaky 16-31) a pak levou (znaky 0-15). Takze navazovat bude PUSH v SCREEN.
    jr      B2S_DIRECT
    
    
B2S_PIXEL_DOWN_LOOP:
    ld      HL, Adr_Buffer - Adr_Screen + 256 + 16    
    
B2S_CHAR_DOWN_LOOP:
    add     HL, SP                          ; 11:1

B2S_DIRECT:
    ld      SP, HL                          ;  6:1 Adresa pulky radku ( znak 16 ) v buferu
    pop     AF
    pop     DE 
    pop     HL
    exx     
    pop     IX
    pop     IY
    ex      AF, AF'
    pop     DE
    pop     BC
    ld      HL, 2 + Adr_Screen - Adr_Buffer ; 10:3 Adresa konce radku ( znak 32 ) na  obrazovce
    add     HL, SP                          ; 11:1
    pop     AF
        
    ld      SP, HL                          ;  6:1
    push    AF                              ; 14407 T-States > 14560 T-states
    push    BC
    push    DE    
    ex      AF, AF'    
    push    IY
    push    IX
    exx 
    push    HL
    push    DE
    push    AF
    
    ld      (B2S_SELF_DIRECT+1), SP         ; pro ukladani v prvni polovine radku navazeme na soucasnou adresu na obrazovce ( znak 16 )
                                            ; pomalejsi o 3 takty, ale misto IX pouzijeme rychlejsi HL, usetrime 5 taktu
    
    ld      HL, Adr_Buffer - Adr_Screen - 16; 10:3 
    add     HL, SP                          ; 11:1
    ld      SP, HL                          ;  6:1 adresa pocatku radku ( znak 0 ) v buferu
    
    pop     AF
    pop     DE 
    pop     HL
    exx     
    pop     IY
    ex      AF, AF'
    pop     HL
    pop     DE
    pop     BC
    pop     AF
B2S_SELF_DIRECT:
    ld      SP, $0000                       ; adresa poloviny radku ( znak 16 ) na obrazovce
    push    AF
    push    BC
    push    DE    
    push    HL
    ex      AF, AF'    
    push    IY
    exx 
    push    HL
    push    DE
    push    AF

    ; skoncime vzdy na adrese pocatku radku daneho pixeloveho radku ( znak 0 ) 
    djnz    B2S_PIXEL_DOWN_LOOP             ; 13/8:2
    
    ; Nastaveni atributu
    ld  (B2S_ATTR_SELF+1), SP
    ld      B, $02                          ; 32/16
B2S_ATTR_LOOP:
B2S_SELF_SRC:
    ld      SP, Adr_Attr_Buffer
    pop     AF
    pop     DE 
    pop     HL
    exx     
    pop     IX
    pop     IY
    ex      AF, AF'
    pop     DE
    pop     BC
    ld      HL, 2 + Adr_Screen - Adr_Buffer ; 10:3
    add     HL, SP                          ; 11:1
    pop     AF
    ld      (B2S_SELF_SRC+1), SP
    ld      SP, HL                          ;  6:1
    push    AF                              ; 14407 T-States > 14560 T-states
    push    BC
    push    DE    
    ex      AF, AF'    
    push    IY
    push    IX
    exx 
    push    HL
    push    DE
    push    AF    
    djnz    B2S_ATTR_LOOP    
B2S_ATTR_SELF:
    ld      SP, $0000

    
    inc     C
    ld      HL, Adr_Buffer - Adr_Screen - 7*256 + 16 + 32  
    ld      A, C
    cp      $14                             ; hledame 20 radek
    jr      z, B2S_EXIT
    
    ld      B, $08                          ; obnovime pocitadlo pixelu
    
    and     $07                             ; delitelne osmi?
    jp      nz, B2S_CHAR_DOWN_LOOP
    
    ; nova tretina
    ld      HL, Adr_Buffer - Adr_Screen + 16 + 32
    jp      B2S_CHAR_DOWN_LOOP              
    
    
B2S_EXIT:
B2S_SELF:
    ld      SP, $0000
    ei
    call    POP_ALL
    ret

  
; Musi byt posledni ( je to tabulka predmetu, bran, nepratel )
INCLUDE table.h                 ; tabulka veci roste dolu proti zasobniku


END_CODE:

if (END_CODE >= $fe00 )
    .error 'Kod preteka do zasobniku.'
endif


    

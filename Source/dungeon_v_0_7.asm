
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


; 256 bajtu
INCLUDE zrcadlovy.h
; 16x16 = 256 bajtu
INCLUDE        map.h


dopredu             equ     0
dozadu              equ     4
vlevo               equ     8
vpravo              equ     12

stisknuto_dopredu   equ     0
stisknuto_dozadu    equ     1
stisknuto_vlevo     equ     2
stisknuto_vpravo    equ     3


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
        
    ld      BC, $2005               ; velikost vyplnovaneho okna v sloupcich a radcich
    ld      HL, $5A60               ; levy horni roh textoveho okna
    call    FILL_ATTR_BLOCK

    call    HELP
    call    PLAYERS_WINDOW
MAIN_LOOP:
    di
    call    VIEW
    ei
    call    COPY_VYREZ2SCREEN
    call    TEST_OTEVRENY_INVENTAR
    jr      nz,MAIN_OTEVRENY_INVENTAR
    call    PLAYERS_WINDOW_AND_DAMAGE
MAIN_OTEVRENY_INVENTAR:

    call    COPY_INVENTORY2SCREEN
    ld      a,24
    call    AKTUALIZUJ_SIPKY            ; VSTUP: a = 0 dopredu, 4 dozadu , 8 vlevo, 12 vpravo, 16 otoceni doleva, 20 otoceni doprava, 24 jen sipky
    call    TIME_SCROLL
    call    KEYPRESSED                  ; obsahuje EXIT_PROGRAM
    jp      MAIN_LOOP

; ===================================

org  progStart + $0300

INCLUDE font.h
INCLUDE typy.h
INCLUDE objects.h
INCLUDE input.h
INCLUDE move.h
INCLUDE draw3D.h
INCLUDE strings.h

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

; Nastavi zero flag kdyz nejsme v inventari
; Do akumulatoru vlozi kurzor      v inventari
TEST_OTEVRENY_INVENTAR:
    ld      a, (PRIZNAKY)               ;caa6        3a 13 c6 
    and     PRIZNAK_OTEVRENY_INVENTAR   ;caa9        e6 01 
    ld      a, (KURZOR_V_INVENTARI)     ;caab        3a 66 ce 
    ret

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

; -----------------------

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


    



;------

; Stisknut SPACE
; v "c" je (VECTOR)
; v "hl" je aktualni lokace
; MENI: hl pri hledani dalsich objektu co se musi prepnout
PREHOD_PREPINAC:
    call    TEST_OTEVRENY_INVENTAR
    jp      z,PP_NEJSME_V_INVENTARI
    ; jsme v inventari
    ld      c,a
    ld      b,0
    ld      hl,(AKTIVNI_INVENTAR)
    add     hl,BC                       ; hl ukazuje na predmet pod kurzorem
    ld      b,(hl)                      ; "b" predmet pod kurzorem
    
    ld      de,DRZENY_PREDMET
    
    ld      a,(de)                      ; drzeny do "a"

    ld      (hl),a                      ; drzeny ulozime
    ld      a,b
    ld      (de),a                      ; puvodni pod kurzorem do drzenych

    or      a
    jp      z,INVENTORY_WINDOW_KURZOR

    call    ITEM_TAKEN
    
; POZOR!!! pozdeji ohlidat zda ukladam na povolene misto ( toulec, prsteny atd )        
    jp      INVENTORY_WINDOW_KURZOR


PP_NEJSME_V_INVENTARI:
    xor     a                           ; posun vpred
    call    DO_HL_NOVA_POZICE           ; hl = hledana lokace = aktualni + vpred
    
    ld      A, TYP_PREPINAC             ;  7:2
    add     A, C                        ;  4:1
    ld      B, A                        ;  4:1 spravne natoceny prepinac ktery hledame
    
    ; HL lokace pred nama
    call    FIND_FIRST_OBJECT
    ; DE = @(TABLE_ITEM[?].prepinace+typ)

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
    jr      PP_NALEZEN_OBJEKT


PP_PROHOD_PAKU:

; nalezen spravny prepinac pred nama!
    ld      a,(de)                      ;  7:1 typ
    add     a,$80                       ;  7:2 prepneme paku / prohodime horni bit
    ld      (de),a                      ;  7:1 typ
    
; zjistime co paka prehazuje a prehodime VSECHNY dalsi
    inc     de                          ;  6:1 DE = @(TABLE_ITEM[?].dodatecny)

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
    
    
; --------------------------------
    



; =====================================================
; VSTUP: 
;        HL adresa od ktere se budou cist data
;        zero-flag = 0, nebude se kreslit, = 1 bude
; VYSTUP: HL = HL + 4 i kdyz se nic nekreslilo
INIT_COPY_PATTERN2BUFFER_NOZEROFLAG:
    or      1                       ; reset zero flag
; VYSTUP:
;   HL = HL+4
;   not zero flag a nenulovy segment adresy spritu znamena ze bude sprite vykreslen
; NEMENI:
;   IX, A
INIT_COPY_PATTERN2BUFFER:
    ld      e,(hl)
    inc     hl
    ld      d,(hl)
    inc     hl
    ld      c,(hl)
    inc     hl
    ld      b,(hl)
    inc     hl

    ret     z                       ; je tam chodba, nekreslime

    inc     d                       ; ochranujem akumulator
    dec     d
    ret     z                       ; nekreslime

    push    af
    push    hl
    push    ix

    call    COPY_SPRITE2BUFFER

    pop     ix
    pop     hl
    pop     af
    ret

; =====================================================


; =====================================================






; =======================================================================




    
; =====================================================


; Kopirovani 18*14 znaku vcetne atributu z bufferu na screen
; Buffer ma rozmery a rozlozeni dat stejne jako SCREEN, jen jinou adresu
; Na obrazovce bude obsah zobrazen vlevo nahore
COPY_INVENTORY2SCREEN:        ; $D64D
    halt                                        ; cekame nez 50x za sekundu nezacne ULA prekreslovat obrazovku

    ld      a,COPY_LOOP_14x - COPY_END_SEGMENT
    ld      (COPY_MENITELNY_SKOK+1),a
    ld      hl,$1525                    ; dec     d, dec     h
    ld      (COPY_DEC_OR_NOP),hl
    
    ld      bc,1400                     ; 10:3
CI2S_WAIT:
    dec     bc                          ;  6:1 at zije nekonecna smycka
    bit     7,B                         ;  8:2 
    jr      z,CI2S_WAIT                 ; 12/7:2
    
; test
    ld      a,(BORDER)                  ; test se zmenou barvy pozadi
    out     (254),a

    ; 1. faze atributy 1. tretiny obrazovky
    ld      h,Adr_Attr_Buffer/256       ;  7:2
    ld      d,$58                       ;  7:2
    ld      ix,$FF01                    ; 14:4
    call    COPY_START

    ; 2. faze obraz 1. tretiny obrazovky
    ld      h,7+Adr_Buffer/256          ;  7:2
    ld      d,7+$40                     ;  7:2
    ld      ix,$FF08                    ; 14:4
    call    COPY_START

    ; 3. faze atributy 2. tretiny obrazovky
    ld      h,1+Adr_Attr_Buffer/256     ;  7:2
    ld      d,1+$58                     ;  7:2
    ld      ix,$FF01                    ; 14:4
    call    COPY_START

    ; 4. faze obraz 2. tretiny obrazovky
    ld      h,15+Adr_Buffer/256         ;  7:2
    ld      d,15+$40                    ;  7:2
    ld      ix,$FF08                    ; 14:4
    call    COPY_START

    ; 5. faze atributy 3. tretiny obrazovky
    ld      h,2+Adr_Attr_Buffer/256     ;  7:2
    ld      d,2+$58                     ;  7:2
    ld      ix,$7F01                    ; 14:4
    call    COPY_START

    ; 6. faze obraz 3. tretiny obrazovky
    ld      h,23+Adr_Buffer/256         ;  7:2
    ld      d,23+$40                    ;  7:2
    ld      ix,$7F08                    ; 14:4
    call    COPY_START

; test
    xor     a
    out     (254),a                     ; nastavi BORDER na cernou

    ret 



; Kopirovani 18*14 znaku vcetne atributu z bufferu na screen
; Buffer ma rozmery a rozlozeni dat stejne jako SCREEN, jen jinou adresu
; Na obrazovce bude obsah zobrazen vlevo nahore
COPY_VYREZ2SCREEN:        ; $D64D
    halt                                ; cekame nez 50x za sekundu nezacne ULU prekreslovat obrazovku

;        inicializace fce COPY
    ld      a,COPY_LOOP_18x - COPY_END_SEGMENT
    ld      (COPY_MENITELNY_SKOK+1),a
    ld      hl,0
    ld      (COPY_DEC_OR_NOP),hl

    ld      bc,1400                     ; 10:3
CV2S_WAIT:
;        rld                            ; 18:2 pekna instrukce, 4 bitova rotace, hmm.. kratka a trva dlouho .)
    dec     bc                          ;  6:1 at zije nekonecna smycka
    bit     7,B                         ;  8:2 
    jr      z,CV2S_WAIT                 ; 12/7:2
    
; test
    ld      a,(BORDER)                  ; test se zmenou barvy pozadi
    out     (254),a


    ; 1. faze atributy 1. tretiny obrazovky
    ld      h,Adr_Attr_Buffer/256       ;  7:2
    ld      d,$58                       ;  7:2
    ld      ix,$F101                    ; 14:4
    call    COPY_START

    ; 2. faze obraz 1. tretiny obrazovky
    ld      h,7+Adr_Buffer/256          ;  7:2
    ld      d,7+$40                     ;  7:2
    ld      ix,$F108                    ; 14:4
    call    COPY_START

    ; 3. faze atributy 2. tretiny obrazovky
    ld      h,1+Adr_Attr_Buffer/256     ;  7:2
    ld      d,1+$58                     ;  7:2
    ld      ix,$D101                    ; 14:4
    call    COPY_START

    ; 4. faze obraz 2. tretiny obrazovky
    ld      h,15+Adr_Buffer/256         ;  7:2
    ld      d,15+$40                    ;  7:2
    ld      ix,$D108                    ; 14:4
    call    COPY_START

; test
    xor     a
    out     (254),a                  ; nastavi BORDER na cernou

    ret 
    
    
; ---------------  zobecnena fce pro kopirovani z bufferu na screen ( oboje se shodnym rozlozenim pameti )
; Kopiruje vyrez v jedne tretine od urciteho radku nahoru az k pocatku
; VSTUP: ixh = levy spodni roh ( index znaku )
;        sirka se meni pres hodnotu v CV2S_SELF
;        ixl = pocet mikroradku ( melo by byt 8 u screen a 1 u atributu )
;        h = segment bufferu
;        d = segment screen
; NEMENI: ixh

COPY_LOOP_18x:
    ; max sirka je 18 znaku
    ldd                             ; 16:2 18x (de--) = (hl--), ignore bc--
    ldd                             ; 16:2
    ldd                             ; 16:2 

    ldd                             ; 16:2 15x
COPY_LOOP_14x:
    ldd                             ; 16:2
    ldd                             ; 16:2
    ldd                             ; 16:2
    ldd                             ; 16:2
    
    ldd                             ; 16:2 10x
    ldd                             ; 16:2
    ldd                             ; 16:2
    ldd                             ; 16:2 
    ldd                             ; 16:2 
    
    ldd                             ; 16:2  5x
    ldd                             ; 16:2
    ldd                             ; 16:2 
    ldd                             ; 16:2
    ldd                             ; 16:2
    
    sub     32                      ;  4:1 o radek nahoru
COPY_MICROLINE:
    ld      e,a                     ;  4:1
    ld      l,a                     ;  4:1
COPY_MENITELNY_SKOK:
    jr      nc,COPY_LOOP_18x        ; 12/7:2  $30,xx 
                                    ; xx = -42 = $D6 u COPY_LOOP_18x
                                    ; xx = -34 = $DE u COPY_LOOP_14x ( pokud se nemenil kod )
                                    ; xx = 0 pokud pokracujeme na COPY_END_SEGMENT
COPY_END_SEGMENT:
    dec     ixl                     ;  pocitadlo mikroradku {8x,1x}
    ret     z
    
COPY_DEC_OR_NOP:
;        pokud konci vyrez u leve strany obrazovky tak jsou registry "h" a "d" uz snizeny pomoci ldd
    nop                             ; 4:1 $25 = dec     h = o microline nize / $00 nop
    nop                             ; 4:1 $15 = dec     d = o microline nize / $00 nop
; hlavni vstup do fce!
COPY_START:
    ld      a,ixh                   ; 8:2 vracime se na znak lezici nalevo dole
    or      a                       ; reset carry flag
    jr      COPY_MICROLINE

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

;------------------------------------
  


COLOR_OTHER_PLAYERS     equ     %00000111        ; white ink + black paper
COLOR_ACTIVE_PLAYER     equ     %00000011        ; magenta ink + black paper

; VSTUP: A = znaky '1' .. '6'
NEW_PLAYER_ACTIVE:
    sub     49                      ; odectem hodnotu znaku "1"
    ld      hl,SUM_POSTAV           ; 10:3
    cp      (hl)                    ;  7:1  0..5 - SUM_POSTAV
    ret     nc                      ; new >= SUM_POSTAV
                                    ; tohle muze nastat jen u 5. a 6. postavy pokud jeste nejsou v parte
    dec     hl                      ;  6:1 hl = HLAVNI_POSTAVA
    cp      (hl)                    ;  7:1
    ret     z                       ; nastavujeme uz aktivni, nebudeme vse znovu prekreslovat
    ld      (hl),a                  ;  7:1 nova AKTIVNI_POSTAVA
    
    ; zmenime ukazatel ulozeny v AKTIVNI_INVENTAR
    ; potrebujeme nasobit AKTIVNI_POSTAVA {0..5} * MAX_ITEM { = 27 }
    
    ld      e,a                     ; ulozim si 1x do "e"
    add     a,a                     ; 2x 
    add     a,e                     ; 3x
    ld      d,a                     ; ulozim si 3x do "d"
    add     a,a                     ; 6x
    add     a,a                     ; 12x
    add     a,a                     ; 24x
    add     a,d                     ; 27x = MAX_ITEM * AKTIVNI_POSTAVA = 27 * AKTIVNI_POSTAVA

    add     a,INVENTORY_ITEMS % 256 ;  7:2
    ld      (AKTIVNI_INVENTAR), a   ; 13:3
    
if ( INVENTORY_ITEMS/256 != INVENTORY_ITEMS_END/256)
    .error 'Pole INVENTORY_ITEMS = preleza segment!'
endif
    
    ; je nastaveny pravy panel na zobrazeni vsech hracu?
    call    TEST_OTEVRENY_INVENTAR  ;dc11
    jp      nz,INVENTORY_WINDOW_REFRESH ; uz se nevratime
    ; jinak pokracujem v SET_PLAYER_ACTIVE


; ------------------------------------
; V panelu s nahledem vsech hracu nastavi atributy pod jmenem aktivniho hrace na COLOR_ACTIVE_PLAYER, ostatni nastavi na COLOR_OTHER_PLAYERS
; Pozor! Musi nasledovat hned za NEW_PLAYER_ACTIVE
VIEW_PLAYER_ACTIVE:

if (0)

    ld      de,(MAX_POSTAVA_PLUS_1)     ; 20:4 d = AKTIVNI_POSTAVA, e = MAX_POSTAVA_PLUS_1
    ld      a,e                         ; a = MAX_POSTAVA_PLUS_1 = citac
    dec     a
; kreslime odspodu nahoru, protoze citac zmensujeme smerem k nule
    cp      4
    jr      c,SP_4
    cp      5
    jr      c,SP_5
    ld      hl,Adr_Attr_Buffer + $1D9
    call    SET_COLOR_NAME
SP_5:
    ld      hl,Adr_Attr_Buffer + $1D2
    call    SET_COLOR_NAME
SP_4:
    ld      hl,Adr_Attr_Buffer + $F9
    call    SET_COLOR_NAME
    ld      hl,Adr_Attr_Buffer + $F2
    call    SET_COLOR_NAME
    ld      hl,Adr_Attr_Buffer + $19
    call    SET_COLOR_NAME
    ld      hl,Adr_Attr_Buffer + $12
    call    SET_COLOR_NAME
endif
    ret

; Pomocna fce pro SET_PLAYER_ACTIVE, nastavi atribut 7 znaku na COLOR_OTHER_PLAYERS nebo COLOR_ACTIVE_PLAYER podle toho zda hodnota "a" == "d"
; VSTUP:        HL adresa atributu
;                "a" = citac = testovana postava
;                "d" aktivni postava
; VYSTUP:        a--
;                 b=0
;                e podle zapsane barvy
;                HL+=7
SET_COLOR_NAME:
    ld      b,7
    ld      e,COLOR_ACTIVE_PLAYER
    cp      d                           ; aktualni-aktivni
    jr      z,SP_NEXT_CHAR
    ld      e,COLOR_OTHER_PLAYERS
SP_NEXT_CHAR:
    ld      (hl),e
    inc     l
    djnz    SP_NEXT_CHAR
    dec     a
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



; ----------------------------------
PLAYERS_WINDOW:
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

    
    call    VIEW_PLAYER_ACTIVE

    ld      IX, NAMES                   ; 14:4
    
if (1)
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
    
else

    jr      ATR_SOURADNICE_END:
ATR_SOURADNICE:
defb        Adr_Attr_Buffer/256, $12-7
defb        Adr_Attr_Buffer/256, $F2-7
defb    1+(Adr_Attr_Buffer/256), $D2-7
    
ATR_SOURADNICE_END:

    ld      BC,(MAX_POSTAVA_PLUS_1)     ; 20:4
    ld      A, C                        ;  4:1
    ld      C, B                        ;  4:1
    ld      B, A                        ;  4:1
    inc     C                           ;  4:1
    
    ld      DE, ATR_SOURADNICE          ; 10:3
    ld      DE, Adr_Attr_Buffer+$19     ; 10:3

PW_JMENA_LOOP:
    bit     0, B                        ;
    jr      z


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

endif

    
    call    SET_MAX_31                  ;dcbe cd 8c d8         . . . 
    ld      ix,INVENTORY_ITEMS          ;dcc1 dd 21 78 ce         . ! x . 
    xor     a                           ;dcc5   a = 0 
    ld      c,MAX_ITEM                  ;dcc6 
PW_HANDS_LOOP:
    ld      B,a                         ;dcc8   "b" = cislo ruky 0..11
    ld      a,(ix+014h)                 ;dcc9   leva ruka
    call    VYKRESLI_RUKU               ;dccc 
    inc     B                           ;dccf 
    ld      a,(ix+019h)                 ;dcd0   prava ruka 
    call    VYKRESLI_RUKU               ;dcd3
    inc     B                           ;dcd6
    ld      a,B                         ;dcd7   schovame cislo ruky do akumulatoru 
    ld      B,000h                      ;dcd8
    add     ix,BC                       ;dcda   + MAX_ITEM = inventar dalsi postavy  
    cp      12                          ;dcdc   pocet zobrazenych ruk
    jp      nz,PW_HANDS_LOOP            ;dcde
    
    di                                  ;dce1        
    ld      a,018h                      ;dce2   a = citac ulozenych obrazku na zasobniku ( vzdy po 2 word ) 
    call    VYKRESLI_ZE_ZASOBNIKU       ;dce4
    
    ld      hl,AVATARS                  ;dce7   odkud se budou cist data
    ld      B,006h                      ;dcea   citac 
PW_AVATARS:
    push    BC                          ;dcec   ochranime citac
    call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG ;dced        cd 9d d6         . . . 
    pop     BC                          ;dcf0   vratime citac
    djnz    PW_AVATARS                  ;dcf1
    
    call    SET_TARGET_SCREEN           ;dcf3 
    ld      B,002h                      ;dcf6
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
    jr      INVENTORY_POKRACUJ

; ---------------
; Menime jen kurzor      
; INVENTORY_WINDOW_KURZOR:
    call    SET_MAX_31              ; meni jen akumulator
    di
INVENTORY_POKRACUJ:

;--- Nastrkame spravna data (parametry dale volane fce) na zasobnik a protoze je to zasobnik, posledni kreslene napred.


; ----- obrys postavy, toulec a prostirani
    ld      hl,DODATECNE_V_INVENTARI
    ld      b,4*2
IW_NEXT_DODATECNE: 
    ld      e,(hl)
    inc     hl
    ld      d,(hl)
    inc     hl
    push    de
    djnz    IW_NEXT_DODATECNE
    
; ----- vykresli podklad pod predmety v inventari


    ld      a,(KURZOR_V_INVENTARI)  ; 13:3
    ld      c,a                     ;  4:1 index predmetu s kurzorem
    ld      b,MAX_ITEM              ;  7:2
    xor     a                       ;  4:1 akumulator      pouzijeme jako citac protoze potrebujeme hlidat 2 stavy
    ld      hl,POZICE_V_INVENTARI   ; 10:3 ukazatel na seznam pozic jednotlivych predmetu

IW_SACHOVNICE_LOOP:

    ld      de,I_bgm
    cp      c                       ; jsme na kurzoru?
    jr      z,IW_ULOZ
    
    ld      de,I_bg
    cp      17                      ; jsme v dvousloupci predmetu
    jr      c,IW_ULOZ
    
    ld      de,I_ram                ; jsme jeste na naznacene postave
IW_ULOZ:
    push    de                      ; adr. spritu
    
    ld      e,(hl)
    inc     hl
    ld      d,(hl)
    inc     hl
    push    de                      ; pozice
    
    inc     a
    djnz    IW_SACHOVNICE_LOOP

; v zasobniku mame za sebou souradnice a pod tim adresu obrazku
    
    ld      a,MAX_ITEM + 4          ; 2x postava, toulec a prostirani
    call    VYKRESLI_ZE_ZASOBNIKU

; ------- potrebujeme zrusit konturu postavy v mistech kde je predmet
    

; ------------------------------

    
if (ITEM2SPRITE/256) != (ITEM2SPRITE_END/256)
    .error      'Seznam ITEM2SPRITE prekracuje 256 bajtovy segment!'
endif
    ld      de,(AKTIVNI_INVENTAR)   ; "de" predmety inventare aktivni postavy
    ld      ixh,ITEM2SPRITE / 256
    ld      b,MAX_ITEM              ;  7:2
    ld      a,B                     ;  4:1
    ld      hl,KURZOR_V_INVENTARI   ; 10:3
    sub     (hl)                    ;  7:1 vykreslujeme odzadu kvuli citaci smycky, takze musime upravit index KURZOR_V_INVENTARI
    ld      c,a
    
    exx
    ld      hl,POZICE_V_INVENTARI   ; h'l'
    exx
IW_LOOP_INIT:

    ld      a,(de)                  ; PODTYP predmetu z inventare
    inc     de                      ; posunem ukazatel na dalsi predmet v danem inventari
    add     a,a                     ; 2x
    jr      nz,IW_OBSAZENO
    
    exx
    ld      bc,0
    push    bc
    push    bc
    push    bc
    push    bc
    inc     hl                      ; h'l' 
    inc     hl                      ; h'l' posunem ukazatel na pozici x-teho predmetu v panelu 
    exx
    
    jr      IW_NEXT_ITEM
    
IW_OBSAZENO:
    add     a,ITEM2SPRITE % 256
    ld      ixl,a
    
    ld      a,c
    cp      b                       ; zero flag = pod kurzorem
    
    exx
    
    ld      c,(ix)
    ld      b,(ix+1)
    push    bc                      ; adresa spritu

    ld      e,(hl)
    inc     hl                      ; nemeni priznaky!
    ld      d,(hl)                        ; pozice spritu
    inc     hl                      ; nemeni prizaky!
    push    de
    
    ld      bc,I_bg                 ; obsazene predmety maji zakryt konturu postavy ( bohuzel se kresli i tam kde nemusim )
    jr      nz,IW_NENI_KURZOR
    ld      bc,I_bgm                ; kurzor!!!
IW_NENI_KURZOR:
                    
    push    bc
    push    de
    
    exx
    
IW_NEXT_ITEM:
    djnz    IW_LOOP_INIT


; v zasobniku mame za sebou souradnice a pod tim adresu obrazku
    
    ld      a,2*MAX_ITEM                ; predmety postavy
    call    VYKRESLI_ZE_ZASOBNIKU
    
;        zjisti ktere pozice nejsou povolene a ty zamrizuj
    call    ZESEDNI_NEPOVOLENE_POZICE
    
    call    VYKRESLI_AKTIVNI_PREDMET
    
    ei
    call    SET_MAX_17                  ; 
    
    ret





; -------------------------------------------------------
VYKRESLI_AKTIVNI_PREDMET:
    call    TEST_OTEVRENY_INVENTAR      ;ddf7        cd a6 ca
    ret     z                           ; u zavreneho nebudem vykreslovat presah
    
    ld      a,(DRZENY_PREDMET)
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


; ----------------------
OBAL_SPRITE2BUFFER:
    push    af
    push    hl
    push    de
    call    COPY_SPRITE2BUFFER
    pop     de
    pop     hl
    pop     af
    ret


; -------------------------------------------------------
ZESEDNI_NEPOVOLENE_POZICE:
    ld      a,(DRZENY_PREDMET)
    or      a
    ret     z                           ; nic nedrzi = vse povolene
    
    ld      de,I_zakazano
    
    cp      MAX_RING_PLUS_1
    jr      c,ZNP_PRSTEN
    ld      bc,POZICE_PPRSTEN
    call    OBAL_SPRITE2BUFFER
    ld      bc,POZICE_LPRSTEN
    call    OBAL_SPRITE2BUFFER        
ZNP_PRSTEN:

    cp      MIN_FOOD
    jr      nc,ZNP_FOOD
    ld      bc,POZICE_PROSTIRANI
    call    OBAL_SPRITE2BUFFER        
ZNP_FOOD:

    cp      PODTYP_HELM
    jr      z,ZNP_HELM
    cp      PODTYP_HELM_D
    jr      z,ZNP_HELM
    ld      bc,POZICE_HLAVA
    call    OBAL_SPRITE2BUFFER        
ZNP_HELM:

    cp      PODTYP_NECKLACE
    jr      z,ZNP_NECKLACE
    ld      bc,POZICE_NAHRDELNIK
    call    OBAL_SPRITE2BUFFER        
ZNP_NECKLACE:


    cp      MIN_ARMOR
    jr      c,ZNP_NENI_ARMOR
    cp      MAX_ARMOR_PLUS_1
    jr      c,ZNP_ARMOR
ZNP_NENI_ARMOR:
    ld      bc,POZICE_BRNENI
    call    OBAL_SPRITE2BUFFER        
ZNP_ARMOR:

    cp      PODTYP_ARROW
    jr      z,ZNP_ARROW
    ld      bc,POZICE_TOULEC
    call    OBAL_SPRITE2BUFFER        
ZNP_ARROW:

    cp      PODTYP_BRACERS
    jr      z,ZNP_BRACERS
    ld      bc,POZICE_NATEPNIK
    call    OBAL_SPRITE2BUFFER        
ZNP_BRACERS:

    cp      PODTYP_BOOTS
    jr      z,ZNP_BOOTS
    ld      bc,POZICE_BOTY
    call    OBAL_SPRITE2BUFFER        
ZNP_BOOTS:

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
    jp      0                     ; self-modifying


; ----------------------------------
; nataci kompas
AKTUALIZUJ_RUZICI:
    ld      a,(VECTOR)                  ; 13:3 0 = N,1 = E,2 = S,3 = W
    add     a,a                         ;  4:1 2x
    add     a,a                         ;  4:1 4x
    add     a,RUZICE % 256              ;  7:2
    ld      l,a                         ;  4:1
if (RUZICE/256) != (RUZICE_END/256)
.warning 'O 2 bajty delsi kod, RUZICE a RUZICE_END lezi na dvou segmentech!'

    adc     a,RUZICE / 256              ;  7:2 resi preteceni
    sub     l                           ;  7:2 
    ld      h,a                         ;  4:1 hl = ukazatel na ukazatel spravneho spritu

else
    ld      h,RUZICE / 256              ;  7:2 resi preteceni
.warning 'Kratsi kod, RUZICE a RUZICE_END lezi na stejnem segmentu.'

endif        
    call    SET_TARGET_SCREEN           ; prepis COPY_PATTERN2BUFFER na SCREEN
    di
    call    INIT_COPY_PATTERN2BUFFER
    ei
    call    SET_TARGET_BUFFER           ; vrat INIT_COPY_PATTERN2BUFFER na BUFFER
    ret

; ----------------------------
; VSTUP: a = 0 dopredu, 4 dozadu , 8 vlevo, 12 vpravo, 16 otoceni doleva, 20 otoceni doprava, 24 jen sipky
AKTUALIZUJ_SIPKY:

if (SIPKY/256) != (SIPKY_END/256)
    .error      'SIPKY nemaji shodny 256 bajtovy segment!'
endif
    add     a,STISKNUTA_SIPKA % 256     ; 7:2
    ld      l,a                         ; 4:1
    ld      h,STISKNUTA_SIPKA / 256     ; 7:2
    push    hl

    ld      l,SIPKY % 256

    call    SET_TARGET_SCREEN           ; prepis INIT_COPY_PATTERN2BUFFER na SCREEN, meni jen akumulator
    di
    call    INIT_COPY_PATTERN2BUFFER    ; samotne nestisknute sipky = smaze predchozi stisk
    pop     hl
    call    INIT_COPY_PATTERN2BUFFER    ; konkretni stisknuta sipka
    ei
    call    SET_TARGET_BUFFER           ; vrat INIT_COPY_PATTERN2BUFFER na BUFFER
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



ZOBRAZ_ZIVOTY:
    ld      DE, DATA_ZIVOTY             ;
    ld      B, $06                      ; 6 postav 
ZZ_LOOP:
    push    BC                          ; 
    call    VYKRESLI_ZIVOTY             ;
    ld      A, (DE)                     ; hodnota posledniho zraneni 
    inc     DE                          ; adresa casu ukonceni krvaveho fleku
    or      A                           ; 
    call    nz,VYKRESLI_KRVAVY_FLEK     ; 
    inc     DE                          ; adresa aktualniho poctu zivotu dals postavy
    pop     BC                          ; 
    djnz    ZZ_LOOP                     ; 
    ret                                 ; 

    
; VSTUP: DE = cas ukonceni krvaveho fleku
VYKRESLI_KRVAVY_FLEK:
    push    de                          ;dfe3        d5         . 
    ld      a, (de)                     ;dfe4        1a         . 
    dec     de                          ; ukazatel na hodnotu posledniho zraneni 
    ld      hl, TIMER_ADR               ;
    cp      (hl)                        ;dfe9        be         . 
    jp      p, VKF_POKRACUJ             ;dfea        f2 f1 df         . . . 
    xor     a                           ; cas vyprsel 
    ld      (de), a                     ; vynulovani hodnoty posledniho zraneni
    pop     de                          ; dfef        d1         . 
    ret                                 ;dff0        c9         . 
    

DATA_ZIVOTY:
;       nyni    max     offset  segment pocatku prouzku posledni zraneni    cas_ukonceni krvaveho fleku
defb    132,    132,    $b4,    Adr_Attr_Buffer/256+0,  0,                  0
defb    90,     90,     $bb,    Adr_Attr_Buffer/256+0,  0,                  0
defb    64,     64,     $94,    Adr_Attr_Buffer/256+1,  0,                  0
defb    40,     40,     $9b,    Adr_Attr_Buffer/256+1,  0,                  0
defb    46,     46,     $74,    Adr_Attr_Buffer/256+2,  0,                  0
defb    40,     40,     $7b,    Adr_Attr_Buffer/256+2,  0,                  0
DATA_ZIVOTY_END:
 
; -----------------------------------------------------------
; Zobrazi prouzek s zivoty
; VSTUP: DE zacatek radku v DATA_ZIVOTY ( sloupec aktualni pocet zivotu)
; MENI:  HL, BC, A
; VYSTUP: DE = DE + 4 = adresa posledniho zraneni
VYKRESLI_ZIVOTY:
    xor     A                   ;  4:1 A = 0
    ex      DE, HL              ;  4:1
    ld      C, (HL)             ;  7:1 C = aktualni pocet zivotu
    inc     HL                  ;  6:1 ukazatel na max. pocet zivotu
    ld      E, (HL)             ;  7:1 E = maximalni pocet zivotu
    inc     HL                  ;  6:1 ukazatel na adresu pocatku prouzku
    push    HL                  ; 11:1
    
    ld      B, A                ;  4:1 BC = aktualni pocet zivotu
    ld      L, C
    ld      H, A                ;  4:1 HL = aktualni pocet zivotu
    ld      D, A                ;  4:1 DE = maximalni pocet zivotu
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
    
    pop     HL                  ; 10:1

    ; C = -(znaku+1) = -1..-5
    ; A = zbytek+1 = 1..9
    
    add     A,(CARKY-1)%256     ; offset + 1..8
    ld      (VZ_LOOP_SELF+1),A  ; 

    ; set color
    ld      E, (HL)             ; offset zacatku prouzku
    inc     HL                  ;
    ld      D, (HL)             ; segment zacatku prouzku
    inc     HL                  ;
    ex      DE,HL               ;  4:1 DE = ukazatel na hodnotu posledniho zraneni, HL = adresa zacatku prouzku (attr)
    ld      A,C                 ;  4:1 zaporny pocet znaku prouzku  -5 = ..011, -4 = ..100, -3 = ..101, -2 = ..110, -1 = ..111
    inc     A                   ;  4:1  -4 = ..10., -3 = ..10., -2 = ..11., -1 = ..11.
    jr      nz, VZ_VICEZNAKOVY  ; 12/7:2
    ld      a, $42              ; light red = ..01.
VZ_VICEZNAKOVY:
    and     $46                 ; 0100 0110 = BRIGHTNES + INK GREEN + INK RED
    ld      (VZ_COL_SELF+1), A  ;
    
    ld      B, $05              ; 5 znaku 

if ((CARKY-1) / 256) != ( CARKY_END / 256 )
    .error      'Seznam CARKY prekracuje segment!'
endif
    
VZ_LOOP_SELF:
    ld      A, (CARKY)          ; 13:3 obsahuje znak predelu konce prouzku 
    inc     C                   ;  4:1 zmensime zaporny pocet celych znaku
    jr      z, VZ_PREDEL        ;12/7:2 posledni znak? 
    ld      A, C                ;  4:1
    rla                         ;  4:1 carry kdyz C < 0
    sbc     A,A                 ;  4:1 if (carry) A = $ff else A = $00
VZ_PREDEL:

VZ_COL_SELF:
    ld      (HL), $00           ; barva prouzku 
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
    ret                         ; 


    
; VSTUP: DE = adresa posledniho zraneni
VKF_POKRACUJ:
    dec     de                  ; adresa segmentu pocatku prouzku
    ld      a,(de)              ;
    ld      H, A                ; segment pocatku prouzku
    
    add     a,a                 ;
    add     a,a                 ;
    add     a,a                 ; 8x 
    sub     H                   ; 7x
Pomocny equ (Adr_Attr_Buffer/256)*7-4
    sub     Pomocny             ; usetrim bajty 7*(H-seg Attr)+4 = 7*H - 7*seg Attr + 4 = 7*H - ( 7*seg Attr - 4)
    ld      c,a                 ;

    dec     de                  ;
    ld      a,(de)              ;
    
    ld      L, A                ;
    push    HL                  ;
    
    and     $1f                 ; offset na sloupce
    dec     A                   ;
    ld      B, A                ;
    ld      DE, Flek            ;
    ; DE adresa spritu
    ; BC ...b=sloupec {0..17+},c=radek {0..13}
    call    OBAL_SPRITE2BUFFER  ; 
    pop     HL                  ;
    inc     L
    inc     L
    ld      ix,JEDNA            ; 
    ld      A, $42              ; light red
    call    PRINT_STRING_COLOR  ;e019        cd 0d db         . . . 
    pop     de                  ;e01f        d1         . 
    ret                         ;e020        c9         . 
    
JEDNA:
defb        "1",0



; VSTUP:
;   E = index postavy hrace 0..5
VYHAZEJ_VSECHNO:
    push    BC
    push    DE

    inc     E                   ; 1..7
    ld      A, E
    add     A, A                ; 2x
    add     A, E                ; 3x
    ld      E, A
    add     A, A                ; 6x
    add     A, A                ; 12x
    add     A, A                ; 24x
    add     A, E                ; 27x
    add     A, INVENTORY_ITEMS%256
    ld      E, A
    ld      D, INVENTORY_ITEMS/256
    
if ( INVENTORY_ITEMS/256 != (INVENTORY_ITEMS_END+27)/256 )
    .error 'INVENTORY_ITEMS!!!'
endif
    
    ld      B, MAX_ITEM

VV_LOOP:    
    dec     E
    push    DE
    push    BC

    ; VSTUP:
;   A = PODTYP_ITEM
;   DE = adresa ktera se bude nulovat
;   L = lokace kam vkladam
;   C = vector
    ld      HL, (LOCATION)
    ld      C,H
    ld      A, (DE)
    or      A
    call    nz, VINP_BEZ_KONTROLY
    
    pop     BC
    pop     DE
    
    djnz    VV_LOOP
    
    pop     DE
    pop     BC
    ret



; VSTUP: E = index postavy hrace 0..5
;        D = zraneni
ZRAN_POSTAVU:
    push    hl                  ;

    ld      a,e                 ;
    add     a,a                 ; 2xE 
    add     a,e                 ; 3xE
    add     a,a                 ; 6xE 

if (DATA_ZIVOTY / 256) != ( DATA_ZIVOTY_END / 256 )
    .error      'Seznam DATA_ZIVOTY prekracuje segment!'
endif
    
    add     a,DATA_ZIVOTY % 256 ; 
    ld      l,a                 ; 
    ld      h,DATA_ZIVOTY / 256 ; 
    ld      a,(hl)              ; aktualni pocet zivotu 
    sub     d                   ; - zraneni 
    jr      nc,ZP_ZIJE          ; 
    xor     a                   ; zemrel, vynulujeme zaporne zivoty na nulu 
    ld      (hl),a              ; ulozime nulu
    call    VYHAZEJ_VSECHNO
    
    jr      ZP_EXIT             ;
ZP_ZIJE:
    ld      (hl),a              ; ulozime zbyvajici pocet zivotu
    inc     hl                  ; +1
    inc     hl                  ; +2 
    inc     hl                  ; +3 
    inc     hl                  ; +4 
    ld      (hl),d              ; ulozim hodnotu posledniho zraneni 
    inc     hl                  ; +5 
    ld      a,(TIMER_ADR)       ; 
    add     a,032h              ; +50 = +1 vterina
    ld      (hl),a              ; doba zobrazovani krvaveho fleku s hodnotou zraneni 
ZP_EXIT:
    pop     hl                  ;e044        e1         . 
    ret                         ;e045        c9         . 


; ????????????????????????????????????????
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
    call    ZRAN_POSTAVU        ; 
    inc     e                   ; dalsi postava
    djnz    PWAD_LOOP           ;
PWAD_NEZRANUJ:
    call    PLAYERS_WINDOW      ; 
    ret                         ; 

; melo by byt posledni
INCLUDE table.h                 ; tabulka veci roste dolu proti zasobniku


END_CODE:

if (END_CODE >= $fe00 )
    .error 'Kod preteka do zasobniku.'
endif


    

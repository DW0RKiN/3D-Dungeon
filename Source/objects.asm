; =====================================================
; VSTUP: 
;   L = hledana lokace
; VYSTUP:
;   DE = &(TABLE_OBJECTS[?].prepinace+typ) 
;   clear carry flag
;   zero flag       = nalezen ( A = L = offset lokace )
;   not zero flag   = nenalezen ( A > L a je roven nasledujici nebo zarazce )
; NEMENI:
;   HL, BC
DE_FIND_FIRST_OBJECT_L:
    ld      DE, TABLE_OBJECTS-2         ; 10:3 DE = &(TABLE_OBJECTS[-1].prepinace+typ)
; VSTUP:
;   DE = &(TABLE_OBJECTS[?].prepinace+typ)
FFO_NEXT:
    inc     DE                          ;  6:1 DE = &(TABLE_OBJECTS[?].dodatecny)    
; VSTUP:
;   DE = &(TABLE_OBJECTS[?].dodatecny)
FIND_NEXT_OBJECT:
    inc     DE                          ;  6:1 DE = &(TABLE_OBJECTS[?].lokace)
    ld      A, (DE)                     ;  7:1
    inc     DE                          ;  6:1 DE = &(TABLE_OBJECTS[?].prepinace+typ)
    cp      L                           ;  4:1 "lokace predmetu" - "nase hledana lokace"
    jp      c, FFO_NEXT                 ; 10:3 carry flag = zaporny = jsme pod lokaci
    ret                                 ; 10:1 zero = nasli jsme lokaci, not zero = presli jsme ji, neni tam

    
; =====================================================
; Prohleda seznam predmetu zda na dane pozici ( ulozene v registru "l" ) nelezi nepruchozi predmet ( = aspon jeden z hornich bajtu "typ" je nenulovy ) 
; VSTUP: 
;   L = hledana lokace
; VYSTUP: 
;   carry = zablokovana ( nepruchozi )
; MENI: 
;   DE, L, A
JE_POZICE_BLOKOVANA_L:
    call    DE_FIND_FIRST_OBJECT_L
    ret     nz                          ;11/5:1 nenalezena
    
JPB_NALEZEN_OBJECT:                     ; na lokaci lezi nejaky predmet
    ld      A, (DE)                     ;  7:1 typ
    add     A, MASKA_PREPINACE
    ret     c                           ; blokovany?
    
    call    FFO_NEXT                    ; hledej dalsi
    jr      z, JPB_NALEZEN_OBJECT       ; 10:1 nalezen dalsi objekt na lokaci
    ret    
    

; =====================================================
; VSTUP:      
;   H = hledany roh
;   L = hledana lokace
; VYSTUP:  
;   DE = ukazuje na TABLE_OBJECTS[x].lokace v prvnim radku se shodnym nebo vyssim natocenim (= za poslednim s nizsim natocenim) nebo prvni predmet na vyssi lokaci
;   carry = 0
;   H = TYP_ITEM + C
; MENI:
;   A, H, DE
DEH_FIND_LAST_ITEM_HL:

    ld      DE, TABLE_OBJECTS-2

    ld      A, H
    and     MASKA_NATOCENI              ; osetreni preteceni 3->0
    inc     A                           ; chceme posledni misto s danym natocenim, takze prvni s vyssim nebo pri rohu 3 dalsi lokaci
    ld      H, A                        ;  4:1 1..4
    
FLI_LOOP
    inc     DE                          ;  6:1 de: "typ"->"dodatecny"
    inc     DE                          ;  6:1 de: "dodatecny"->"lokace"
    ld      A, (DE)                     ;  7:1
    inc     DE                          ;  6:1 de: "lokace"->"typ"
    cp      L                           ;  4:1 "lokace predmetu" - "nase hledana lokace"
    jr      c, FLI_LOOP                 ; 10:3 carry flag = zaporny = jsme pod lokaci
    jr      nz, FLI_EXIT                ; jsme za polickem
    ld      A, (DE)                     ; zamky + typ + natoceni
    and     MASKA_NATOCENI              ;
    cp      H                           ; 
    jr      c,FLI_LOOP
FLI_EXIT:
    dec     DE                          ; prvni bajt radku, (de) = lokace "za" nebo zarazka, od teto pozice vcetne ulozime 3 byty a zbytek vcetne zarazky o 3 posunem.
    ld      A, TYP_ITEM-1               ; TYP_ITEM - 1
    add     A, H                        ; TYP_ITEM - 1 + natoceni + 1
    ld      H, A                        ; TYP_ITEM + natoceni

    ret                                 ; not carry

; =====================================================
; VSTUP: 
;   A = PODTYP_ITEM
;   L = lokace kam vkladam
;   H = roh
; Je to komplikovanejsi fce nez sebrani, protoze musi najit to spravne misto kam to vlozit.
; Polozky jsou razeny podle lokace a nasledne podle natoceni (prepinace jsou ignorovany).
; Pak existuji polozky ktere maji dodatecne radky zacinajici nulou.
VLOZ_ITEM_NA_POZICI:
    push    AF                          ; ukladany predmet
    
    call    DEH_FIND_LAST_ITEM_HL
    push    HL                          ; uchovame TYP + NATOCENI a lokaci
    
    ld      hl,(ADR_ZARAZKY)            ; 16:3
    push    hl
    sbc     hl,de                       ; 15:2 carry = 0 diky DEH_FIND_LAST_ITEM_HL
    ld      b,h                         ;  4:1
    ld      c,l                         ;  4:1 o kolik bajtu
    inc     bc                          ; pridame zarazku a odstranime problem kdy bc = 0
    pop     hl
    ld      d,h                         ;  4:1
    ld      e,l                         ;  4:1
    inc     hl
    inc     hl
    inc     hl
    ld      (ADR_ZARAZKY),hl            ; 16:3    
    ex      de,hl
    ; BC = velikost kopirovaneho bloku = 1 + ZARAZKA - DE ( pokud DE ukazuje na zarazku tak nepretecem )
    ; HL = zdroj = ZARAZKA
    ; DE = cil = ZARAZKA + 3
    lddr                                ; "LD (DE),(HL)", DE--, HL--, BC--
    
    pop     BC                          ; TYP + NATOCENI a lokace
    pop     AF                          ; ukladany predmet

    ex      DE, HL    
    ld      (HL), A                     ; dodatecny
    dec     HL
    ld      (HL), B                     ; TYP + NATOCENI
    dec     HL
    ld      (HL), C                     ; lokace
    
    call    ITEM_PUT_A    

    xor     A
    ld      (PRESOUVANY_PREDMET), A     ; 10:2 vyprazdnime misto kde byl drzeny predmet

    
    jp      INVENTORY_WINDOW_KURZOR


; =====================================================
; VSTUP: L = odkud beru
;        H = (vector)
VEZMI_ITEM_Z_POZICE:

    call    DEH_FIND_LAST_ITEM_HL

    ex      DE, HL
    dec     HL                          ; MASKA_PODTYP
    ld      A, (HL)                     ; presouvany predmet    
    dec     HL                          ; MASKA_TYP + MASKA_NATOCENI
    ld      B, (HL)
    dec     HL                          ; lokace
    ld      C, (HL)    
    
    ex      DE, HL    
    sbc     HL, BC                      ; spravna lokace i spravny predmet s natocenim?
    ret     nz                          ; nenalezen predmet na dane lokaci a rohu
    
    ld      (PRESOUVANY_PREDMET), A
    
    
    ld      HL, (ADR_ZARAZKY)           ; 16:3
    sbc     HL, DE                      ; carry = 0
    inc     HL                          ; presunem i zarazku a vyresime preteceni pri BC = 0
    ld      B, H
    ld      C, L
    ld      H, D
    ld      L, E
    inc     HL
    inc     HL
    inc     HL                          ; odkud brat
    ; BC = velikost kopirovaneho bloku = 1 + ZARAZKA - DE ( pokud DE ukazuje na zarazku tak nepretecem )
    ; HL = zdroj = DE + 3
    ; DE = cil
    ldir

    dec     de                          ; zrusime +1 z ldi
    ld      (ADR_ZARAZKY),de            ;     

    jp      INVENTORY_WINDOW_KURZOR
;         ret


; =====================================================
; fce hleda na lokaci L, objekt H a xoruje mu bity
; VSTUP:
;   H "bity+typ+natoceni"
;   L hledana lokace
PREPNI_OBJECT:

    push    de
    call    DE_FIND_FIRST_OBJECT_L
    ; DE = &(TABLE_OBJECTS[?].prepinace+typ) 
    jr      nz, PO_EXIT

PO_NALEZEN_OBJECT:
    ; na lokaci lezi nejaky predmet
    ld      A, (DE)                     ;  7:1 typ
    xor     H
    and     MASKA_TYP
    jr      nz, PO_NEXT_OBJECT          ;12/7:2 neshoduje se typ 
    

if ( KONTROLUJ_NATOCENI_U_PREPINACU)
    ; pokud jsou to dvere ignoruji natoceni
    ld      A, H
    and     MASKA_TYP
    cp      TYP_DVERE
    jr      z, PO_FOUND

    ; jinak musi sedet i natoceni
    ld      a,(de)                      ;  7:1 typ
    sub     h
    and     MASKA_NATOCENI
    jr      nz,PO_NEXT_OBJECT           ;12/7:2       ??? pokud je horni bit nastaven tak to bude blbnout?
  
PO_FOUND:
endif
  
; je to hledany predmet AKTUALIZOVAT
    ld      a,h
    and     MASKA_PREPINACE
    ex      de,hl                       ;  4:1
    xor     (hl)                        ;  7:1 xorujeme flagy v horni casti "typ"
    ld      (hl),a                      ;  7:1
    ex      de,hl                       ;  4:1 
            
PO_NEXT_OBJECT:
    call    FFO_NEXT
    jr      z,PO_NALEZEN_OBJECT
    
PO_EXIT:
    pop     de
    ret


; =====================================================
; VSTUP:
;   IX je zkoumana lokace
;   BC je hloubka * 12 = radek v DOOR_TABLE/RAM_TABLE/...
;   tzn B = 0
; MENI:
;   mam povoleno menit A, HL, DE, BC
FIND_OBJECT:        

    inc     ixl
    ret     z                       ; !!!!! drobny bug .) $ff lokace nesmi byt totiz ani v dohledu
    dec     ixl
    
    ld      de,TABLE_OBJECTS-2      ; 10:3 "defb lokace, typ, dodatecny"
FO_LOOP:
    inc     de                      ;  6:1 de: "typ"->"dodatecny"
FO_LOOP_DODATECNY:
    inc     de                      ;  6:1 de: "dodatecny"->"lokace"
    ld      a,(de)                  ;  7:1
    inc     de                      ;  6:1 de: "lokace"->"typ"
    sub     ixl                     ;  8:2 "lokace predmetu" - "nase hledana lokace"
    jr      c,FO_LOOP               ;12/7:2 carry flag?
    ret     nz                      ;11/5:1 lezi na lokaci "hl"?

; na lokaci lezi nejaky predmet
    ld      a,(de)                  ;  7:1 typ
    and     MASKA_TYP               ;  7:2

if ( TYP_PREPINAC != 0 )
    cp      TYP_PREPINAC            ;  7:2 
    
    .warning 'Delsi kod, protoze TYP_PREPINAC != 0'
else
    or      a                       ;  4:1
endif
    jr      z,FOUND_PREPINAC        ;12/7:2


    
    cp      TYP_ENEMY               ;  7:2
    jr      z, FOUND_ENEMY          ;12/7:2

    cp      TYP_DVERE               ;  7:2
    jp      z, FOUND_RAM           ;12/7:2

    cp      TYP_ITEM                ;  7:2
    jp      z, FOUND_ITEM           ;12/7:2
    
    cp      TYP_DEKORACE            ; musi byt posledni varianta
    jr      nz, FO_LOOP
    
    inc     de                      ; typ -> podtyp
    ld      a, (de)
    and     MASKA_PODTYP
    
    ld      hl,RUNE_TABLE
    cp      PODTYP_RUNA             ;  7:2 
    jr      z,FOUND_DEKORACE        ; 10:2
    
    ld      hl,KANAL_TABLE
    
; -----------------------------------------------------
; VSTUP:         bc = index v tabulce
;                adresa tabulky spravne dekorace
;                de = ukazuje na podtyp/dodatecny!!! proto se vracim pomoci FO_LOOP_DODATECNY
FOUND_DEKORACE:
    call    ADD_BC_INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
    jr      FO_LOOP_DODATECNY               ; return s de = dodatecny

FO_EXIT:
    ret



    
    
; =====================================================
FOUND_PREPINAC:
    push    bc

    ld      a,(de)                  ;  7:1 "typ"
    and     MASKA_NATOCENI          ;  7:2
    
    ld      hl,VECTOR               ; 10:3
    ld      l,(hl)                  ; 0 = N, 1 = E, 2 = S, 3 = W
    sub     l                       ; pohledy musi sedet
                                    
    ld      hl,PAKY_TABLE           ; L uz nebudem potrebovat
    add     hl,bc

    and     3                       ; protoze nekdy potrebujeme aby sever byl 4 tak jsou validni jen posledni 2 bity
                                    ; pak 3-0 = -1 (000000-11) a 0-3 = 1 (111111-01)
    jr      z,FD_PREPINAC_INIT      ; z oci do oci

    ld      bc,NEXT_PAKA
    add     hl,BC                   ; leve paky
    cp      3                       ; 3 = -1 ve 2 bitech
    jr      z,FD_PREPINAC_INIT      ; leva paka trci doprava ( kdybych byl natocen doleva tak se shoduji nase smery )

    add     hl,BC                   ; prave paky
    cp      1                       ; 
    jr      nz,FD_PREPINAC_EXIT     ; je tu moznost paky co je za stenou a trci ode mne a tu nevidim...
    
    ; zero flag = prava paka trci doleva ( kdybych byl natocen doprava tak se shoduji nase smery )

FD_PREPINAC_INIT:

    ld      a,(de)                  ; "typ"
    or      a
    jp      p,FD_PREPINAC_VIEW      ; kladne = paka je nahore
    
    ld      bc,PAKA_DOWN
    add     hl,bc

FD_PREPINAC_VIEW:
    call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG

FD_PREPINAC_EXIT:
    pop     bc
    jr      FO_LOOP        



; =====================================================
FOUND_ENEMY:
    push    de
    push    ix
    push    bc

    ld      a,ENEMY_ATTACK_DISTANCE     ; 7:2
    cp      c
    jr      nz,FE_FAR
; vzdalenost 1, levy predni skret...
    ld      a,(TIMER_ADR)               ; timer
    and     FLOP_BIT_ATTACK
    ld      a,2
    jp      z,FE_FAR
    ld      a,1
FE_FAR:
    ld      (FE_SELFMODIFIYNG2+1),a


    ld      a,(de)                      ;  7:1 typ
    and     MASKA_PREPINACE             ;  7:2
    rlca                                ;  4:1
    rlca                                ;  4:1
    rlca                                ;  4:1
    
    ld      ixl,a                       ; pocet nepratel
    
    rlca                                ;  4:1 pocet nepratel ve skupine * 2
    add     a,c                         ;  4:1
    add     a,c                         ;  4:1
    add     a,ENEMY_GROUP % 256         ;  7:2
    ld      l,a                         ;  4:1
    adc     a,ENEMY_GROUP / 256         ;  7:2
    sub     l                           ;  4:1
    ld      h,a                         ;  4:1 v hl je adresa kde je ulozena spravna pozice spritu s poslednim nepritelem
                                        ; [64]:[16]

    inc     de                          ; dodatecny, na zasobniku je puvodni hodnota
    ld      a,(de)                      ;  7:1 dodatecny
    ex      de,hl
    
    ld      hl,DIV_6                    ; 10:3
    add     hl,BC                       ; 11:1
    ld      c,(hl)                      ;  7:1 z bc chceme jen hloubku * 2 = bc / ( 6 * 2 )
    ld      hl,ENEMY_TABLE+1            ; 10:3
    add     hl,BC                       ; 11:1 HL je index+1 do tabulky adres spritu nepratel pro danou hloubku, nepritel je zatim jen prvni podtyp

    and     MASKA_PODTYP                ;  7:2        
    jr      z,FE_VIEW
    
    ld      bc,NEXT_TYP_ENEMY           ; uz nebudem potrebovat puvodni hodnotu, pak obnovime ze zasobniku        
FE_NEXT:
    add     hl,BC                       ; 11:1 hledame sprite spravneho nepritele
    dec     a                           ; snizime 
    jr      nz,FE_NEXT
    
FE_VIEW:
    ld      a,(hl)                      ;  7:1 segment
    or      a                           ;  4:1
    jp      z,FE_EXIT                   ; v teto hloubce nebude sprite na zadne pozici = exit

    dec     hl                          ;  6:1
    ld      l,(hl)                      ;  7:1
    ld      h,a                         ;  4:1
    ld      (FE_SELFMODIFIYNG+1),hl     ; 16:3
    ex      de,hl

FE_LOOP:

    dec     hl
    ld      b, (hl)
    dec     hl
    ld      c, (hl)
    inc     c                           ; ochranujem akumulator
    dec     c
    jp      z, FE_TEST_LOOP             ; sirka muze byt nula, ale vyska nula znamena nekreslit
    
FE_SELFMODIFIYNG:
    ld      de, $0000                   ; 10:3 adresa spritu nepritele ve spravne hloubce

FE_SELFMODIFIYNG2:
    ld      a, $00
    cp      ixl
    jp      nz, FE_CALL
    
    ld      de, ESA1
    dec     b                           ; X??-1
    ld      c, Y03                      ; Y03

FE_CALL:
    push    hl                          ; 11:1
    push    ix                          ; 15:2
    call    COPY_SPRITE2BUFFER
    pop     ix                          ; 14:2
    pop     hl                          ; 10:1
    
FE_TEST_LOOP:
    dec     ixl                         ;  8:2
    jr      nz,FE_LOOP
    
FE_EXIT:
    pop     bc
    pop     ix
    pop     de
    jp      FO_LOOP                     ; return
    

; =====================================================
; VSTUP:
;   H = (VECTOR)
; MENI:
;   A, HL
FOUND_DOOR:
    inc     C
    dec     C
    ret     z

    ; vykreslim jen jedny dvere ze dvou co jsou v tabulce
    ld      A, (DE)
    inc     A
    inc     A                       ; +2
    xor     H
    and     MASKA_NATOCENI
    ret     nz
    
    ; vykresli ram
    ld      hl,RAM_TABLE
    call    ADD_BC_INIT_COPY_PATTERN2BUFFER_NOZEROFLAG

    ld      A, (DE)
    add     A, MASKA_PREPINACE      ; nektere dvere jsou otevrene, AKTUALIZOVAT!!!
    ret     nc                      ;

    ld      hl,DOOR_TABLE
    call    ADD_BC_INIT_COPY_PATTERN2BUFFER_NOZEROFLAG

    ret                             ;
    

; =====================================================
; VSTUP:    
;   DE = @(TABLE_OBJECTS[?].prepinace+typ)
;   IXl = TABLE_OBJECTS[?].lokace
;   BC = 6*word*radek + 2*word*sloupec = offset v table, sloupec = {0..2} = {primy smer, vlevo, vpravo}, radek = hloubka 
FOUND_RAM:
    inc     DE
    ld      A, (DE)
    inc     DE
    inc     DE

    inc     C
    dec     C 
    jr      nz, FOUND_ITEM
    
    ld      H, A
    ld      A, (VECTOR)
    xor     H
    and     1
    ld      hl, RAM_TABLE
    call    INIT_COPY_PATTERN2BUFFER
    
; =====================================================
; VSTUP:    
;   DE = @(TABLE_OBJECTS[?].prepinace+typ)
;   IXl = TABLE_OBJECTS[?].lokace
;   B = 0
;   C = 6*word*radek + 2*word*sloupec = offset v table, sloupec = {0..2} = {primy smer, vlevo, vpravo}, radek = hloubka 
; VYSTUP:
;   vraci se jen pokud je predmet prilis daleko aby byl videt, ale ne tak daleko aby se nevykreslovali dekorace atd.
;   jinak vykresli predmety pokud jsou videt
FOUND_ITEM:

if (0)
    ld      a,c
    cp      MAX_VIDITELNOST_PREDMETU_PLUS_1
    jp      nc, FO_LOOP                     ; return ( bohuzel tolikrat, kolikrat je predmetu na policku )
endif
    
    bit     BIT_STENA, (IX+$00)             ; 20:4 jsme v nepruhledne stene? Nebude videt ze tam neco je ani kdyz jsme uvnitr...
    ret     nz

    push    DE                              ; ulozime adresu prvniho predmetu pro pripad preteceni na zacatek
    
    ld      A, (VECTOR)
    ld      H, A                            ;  4:1 ulozime si smer pohledu

; Roh = index rohu ctverce ve kterem lezi predmet (narusta po smeru hodinovych rucicek pri pohledu shora)
; vektor = index natoceni pri pohledu danym smerem
;
; Pohled na Rohy od     N = 0   E = 1   S = 2   W = 3
;                       0  1    1  2    2  3    3  0
;                       3  2    0  3    1  0    2  1
;
; Rohy-vektor           rohy-N  rohy-E  rohy-S  rohy-W
;                       0  1    0  1    0  1    0 -3
;                       3  2   -1  2   -1 -2   -1 -2

; Pokud by vsechny rohy obsahovaly aspon jeden predmet tak staci preskakovat dokud nenarazim rohy-smer = not carry. To je prvni predmet ktery je nejdal (NEJVZDALENEJSI).
; Pokud v levem zadnim rohu (= vektor) nic neni tak zacnu vykreslovat od nasledujiciho v seznamu, pokud ma index vyssi jak vektor.
; Pokud nema, tak pretecu na dalsi lokaci nebo zarazku a NEJVZDALENEJSI je prvni predmet na dane lokaci.

FI_HLEDANI_NEJVZDALENEJSIHO:
    ld      a,(de)                          ; 
    and     MASKA_NATOCENI                  ; roh
    cp      H                               ; roh - vektor natoceni
    jr      nc,FI_NEJVZDALENEJSI            ; roh je ten nejvzdalenejsi?
FI_DALSI_RADEK:
; prejdeme na dalsi predmet ( jsou razeny podle rohu )
    inc     de                              ; @(TABLE_OBJECTS[?].podtyp)
    inc     de                              ; @(TABLE_OBJECTS[?].lokace)
    ld      a,(de)                          ; lokace ( muzem vytect do jine lokace, pak to znamena ze musime kreslit od ITEM_ADR_POCATKU )
    inc     de                              ; @(TABLE_OBJECTS[?].prepinace+typ) 
    
    ; je to poteba? Muze byt na stejne lokaci predmet a prepinac?
    or      a
    jr      z,FI_DALSI_RADEK                ; preskakujeme dodatecne radky (lokace = 0)
    
    cp      ixl
    jr      z,FI_HLEDANI_NEJVZDALENEJSIHO   ; neopustili jsme policko?
    
    ; preteceni na zacatek ( levy zadni neni obsazen a po smeru hodinovych rucicek jsme pretekli na index 0, ktery jsem ignorovali )
    pop     DE                              ; nacteme prvni
    push    DE
    
FI_NEJVZDALENEJSI:
    ld      L, E                            ; ulozim si offset prvne vykresleneho predmetu, kvuli ukonceni az pretecem zase k nemu
                                            ; diky tomu ze polozky jsou po 3 tak bude shodny az po 256 predmetech na stejne lokaci
                                            ; pak vznikne chyba!!!
FI_VYKRESLI_ITEM_LOOP:

; Rohy-vektor           rohy-N  rohy-E  rohy-S  rohy-W
;                       0  1    0  1    0  1    0 -3
;                       3  2   -1  2   -1 -2   -1 -2
; MASKA_NATOCENI &(Roh-vektor)
;                       0  1    0  1    0  1    0  1
;                       3  2    3  2    3  2    3  2


    push    hl
    push    de
    push    ix
    push    bc
    
    ld      A, (DE)                         ; typ + roh
    and     MASKA_TYP
    cp      TYP_ITEM
    jr      z, FI_ITEM
    
    cp      TYP_DVERE
    call    z, FOUND_DOOR
    
    jr      FI_NEKRESLI

FI_ITEM:

    ; nastaveni XY do BC
    ld      A, (DE)                         ; zamky + typ + roh
    sub     H
    and     MASKA_NATOCENI
    add     A, A                            ; 0, 2, 4, 6 = 2*(roh-natoceni) & $07
    
    ; nastaveni adresy spritu do DE
    ld      HL, DIV_6                       ; 10:3
    add     HL, BC                          ; 11:1
    
    ; B uz nepotrebujeme
    ; nastaveni XY do BC
    ld      B, A                            ; 2 * index rohu 

    ; nastaveni adresy spritu do DE
    ld      A, (HL)                         ;  7:1 A = 2 * hloubka = C / 6
    cp      6                               ; hloubku 3+ vcetne ignorujeme
    jr      nc, FI_NEKRESLI

    inc     DE
    ld      A, (DE)
    add     A, A                            ; 2 * PODTYP
    add     A, A                            ; 4 * PODTYP
    add     A, A                            ; 8 * PODTYP (4 * word * PODTYP) = ofset radku
    add     A, (HL)                         ; + ofset sloupce = + 2*hloubka
    add     A, ITEM_TABLE % 256
    ld      L, A
    adc     A, ITEM_TABLE / 256
    sub     L
    ld      H, A                            ; hl = adresa, kde je ulozena adresa spritu daneho predmetu v ITEM_TABLE vcetne hloubky
    ld      E, (HL)
    inc     HL
    ld      D, (HL)                          ; de = adr. spritu
    
    inc     D
    dec     D
    jr      z,FI_NEKRESLI                   ; adresa je rovna nule, po dokonceni vsech nahledu snad nenastane... POZOR aktualizovat?

    ; nastaveni XY do BC
    ld      A, C                            ; C = 12*radek, kvuli TYP_TABLE
    add     A, A                            ; A = 24*radek, protoze ITEM_POZICE ma 24 bajtu na radek
    add     A, B                            ; pridame spravny podsloupec {0,2,4,6} = 2*(VECTOR)
    add     A, ITEM_POZICE % 256            ; 
    ld      L, A
    adc     A, ITEM_POZICE / 256
    sub     L
    ld      H, A                            ; hl = adr. v ITEM_POZICE
    ld      C, (HL)
    
    inc     C
    dec     C
    jr      z, FI_NEKRESLI                  ; sirka muze byt nula, ale vyska nula znamena nekreslit

    ; nastaveni XY do BC    
    inc     HL
    ld      B, (HL)
    
    call    COPY_SPRITE2BUFFER
    
            
FI_NEKRESLI:
    pop     bc
    pop     ix
    pop     de    
    pop     hl
    
    inc     de                              ; typ -> podtyp
    inc     de                              ; podtyp -> lokace
    ld      a,(de)
    inc     de                              ; lokace -> podtyp
    cp      ixl
    jr      z,FI_TEST_ZACATKU_SELF          ; jsme stale na spravne lokaci?
; POZOR udelat test zda je to predmet??? Kolidovat muze enemy a dvere.

    ; nejsme takze pretecem na zacatek
    pop     DE                          ; vracime se na zacatek
    push    DE
    
FI_TEST_ZACATKU_SELF:
    ld      A, L                            ;
    cp      E
    
; Jediny exit s fce!
    jr     nz, FI_VYKRESLI_ITEM_LOOP        ; ret ne jp, takze ukonci i nadrazenou fci
        
;FI_EXIT
    pop     DE
    ret
    

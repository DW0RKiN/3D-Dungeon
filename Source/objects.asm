; =============================
; VSTUP: 
;   L = hledana lokace
; VYSTUP:
;   DE = &(TABLE_ITEM[?].prepinace+typ) 
;   clear carry flag
;   zero flag       = nalezen ( A = L = offset lokace )
;   not zero flag   = nenalezen ( A > L a je roven nasledujici nebo zarazce )
; NEMENI:
;   HL, BC
FIND_FIRST_OBJECT:
    ld      DE, TABLE_ITEM-2            ; 10:3 DE = &(TABLE_ITEM[-1].prepinace+typ)
; VSTUP:
;   DE = &(TABLE_ITEM[?].prepinace+typ)
FFO_NEXT:
    inc     DE                          ;  6:1 DE = &(TABLE_ITEM[?].dodatecny)    
; VSTUP:
;   DE = &(TABLE_ITEM[?].dodatecny)
FIND_NEXT_OBJECT:
    inc     DE                          ;  6:1 DE = &(TABLE_ITEM[?].lokace)
    ld      A, (DE)                     ;  7:1
    inc     DE                          ;  6:1 DE = &(TABLE_ITEM[?].prepinace+typ)
    cp      L                           ;  4:1 "lokace predmetu" - "nase hledana lokace"
    jp      c, FFO_NEXT                 ; 10:3 carry flag = zaporny = jsme pod lokaci
    ret                                 ; 10:1 zero = nasli jsme lokaci, not zero = presli jsme ji, neni tam

;----------------------
; VSTUP:        de = TABLE_ITEM-2
;                b = hledane natoceni ( kdyz se rovna 4 tak pretika do dalsiho policka )
; VYSTUP:        de = ukazuje na typ v prvnim radku se shodnym natocenim (= za poslednim s nizsim natocenim) nebo vyssi lokaci
;                 carry = 0
FIND_LAST_OBJECT:
    inc     de                          ;  6:1 de: "typ"->"dodatecny"
    inc     de                          ;  6:1 de: "dodatecny"->"lokace"
    ld      a,(de)                      ;  7:1
    inc     de                          ;  6:1 de: "lokace"->"typ"
    cp      l                           ;  4:1 "lokace predmetu" - "nase hledana lokace"
    jp      c,FIND_LAST_OBJECT          ; 10:3 carry flag = zaporny = jsme pod lokaci
    ret     nz                          ; jsme za polickem
    ld      a,(de)                      ; typ + natoceni
    and     MASKA_NATOCENI              ; jen natoceni
    cp      b                           ; 
    jp      c,FIND_LAST_OBJECT
    
    ret
; ------------------------------------------------------
; a zbytek posun dolu
; VSTUP: 
;   L = lokace kam vkladam
;   c = (vector)
; Je to komplikovanejsi fce nez sebrani, protoze musi najit to spravne misto kam to vlozit.
; Polozky jsou razeny podle lokace a nasledne podle natoceni.
; Pak existuji polozky ktere maji dodatecne radky zacinajici nulou.
VLOZ_ITEM_NA_POZICI:
    ld      de,DRZENY_PREDMET
    ld      a,(de)
    or      a
    ld      ix,VETA_NEDRZI
    jp      z,PRINT_MESSAGE             ; nic nedrzi, fce volana pomoci "jp" misto "call" = uz se nevrati

    
VINP_BEZ_KONTROLY:
    ld      ixh,a    
    xor     a
    ld      (de),a
    
    ld      a,c
    inc     a
    and     MASKA_NATOCENI
    add     a,TYP_ITEM        
    ld      ixl,a                       ; 2 bajt v radku obsahuje TYP + NATOCENI

    ld      de,TABLE_ITEM-2
    ld      a,c
    inc     a
    and     MASKA_NATOCENI
    inc     a                           ; 0->2,1->3,2->4,3->1
    ld      b,a
    call    FIND_LAST_OBJECT
    dec     de                          ; vratime se na prvni bajt radku, (de) = lokace "za" nebo zarazka, od teto pozice vcetne ulozime 3 byty a zbytek vcetne zarazky o 3 posunem.
;..............
    push    hl                          ; uchovame offset lokace
    
    ld      hl,(ADR_ZARAZKY)            ; 16:3
    push    hl
    push    hl
    sbc     hl,de                       ; 15:2
    ld      b,h                         ;  4:1
    ld      c,l                         ;  4:1 o kolik bajtu
    inc     bc                          ; pridame zarazku a odstranime problem kdy bc = 0
    pop     hl
    inc     hl
    inc     hl
    inc     hl
    ld      (ADR_ZARAZKY),hl            ; 16:3
    pop     de
    ex      de,hl
    lddr                                ;         "LD (DE),(HL)", DE--, HL--, BC--
    
; pokud je predmet posledni tak se presune o 3 bajty jen zarazka
    ld      a,ixh
    ld      (de),a
    dec     de
    
    ld      a,ixl
    ld      (de),a
    dec     de
    
    pop     hl                          ; nacteme offset lokace
    ld      a,l
    ld      (de),a
    
    ld      B, IXh
    call    ITEM_PUT    
    
    jp      INVENTORY_WINDOW_KURZOR
;         ret

;-----------------------------------------------------------

; a zbytek posun dolu
; VSTUP: HL = lokace kam vkladam
;        c = (vector)
VEZMI_ITEM_Z_POZICE:
    ld      a,(DRZENY_PREDMET)
    or      a
    ld      ix,VETA_DRZI
    jp      nz,PRINT_MESSAGE            ; uz neco drzi, fce volana pomoci "jp" misto "call" = uz se nevrati

    ld      de,TABLE_ITEM-2
    ld      b,c
    inc     b                           ; 0->1,1->2,2->3,3->4
    call    FIND_LAST_OBJECT
    dec     de                          ; vratime se na prvni bajt radku, (de) = lokace "za" nebo zarazka, od teto pozice vcetne ulozime 3 byty a zbytek vcetne zarazky o 3 posunem.
;..............
    
    ld      a,TYP_ITEM
    add     a,c
    ld      c,a

    ld      a,l                         ; pouzito az v cp (hl)
if (0)
    ld      h,d
    ld      l,e                         ; hl = lokace za
else
    ex      DE, HL
endif

; VIZP_LOOP:
    dec     hl                          ; MASKA_PODTYP
    ld      e,(hl)
    dec     hl                          ; MASKA_TYP + MASKA_NATOCENI
    ld      d,(hl)
    dec     hl                          ; lokace
    cp      (hl)
    
    ld      ix,VETA_NIC
    jp      nz,PRINT_MESSAGE            ; nic nenasel, fce volana pomoci "jp" misto "call" = uz se nevrati
    
    ld      a,d
    cp      c                           ; je tam zvednutelny predmet?
;         ld      a,(hl)                ; vratime offset lokace do akumulatoru
    jp      nz,PRINT_MESSAGE

; hl adresa mazaneho tribajtoveho prvku
; e = podtyp
; d = TYP_ITEM + natoceni

    ld      a,e
    ld      (DRZENY_PREDMET),a
    push    af
    
    ld      d,h
    ld      e,l                         ; kam ukladat
    inc     hl
    inc     hl
    inc     hl                          ; odkud brat
VIZP_PRESUN:
    ld      a,(hl)
    ldi                                 ; (de) = (hl) lokace
    cp      TYP_ZARAZKA
    
    jr      z,VIZP_EXIT
    
    ldi                                 ; (de) = (hl) typ
    ldi                                 ; (de) = (hl) podtyp
    jp      VIZP_PRESUN
    
VIZP_EXIT:
    dec     de                          ; zrusime +1 z ldi
    ld      (ADR_ZARAZKY),de            ; 

    pop     bc                          ; b = a = (DRZENY_PREDMET)
    call    ITEM_TAKEN
; otevri inventar
    ld      hl,PRIZNAKY                 ; 10:3
    ld      a,(hl)                      ; 7:1
    or      PRIZNAK_OTEVRENY_INVENTAR   ; 7:2
    ld      (hl),a                      ; 7:1
    
    jp      INVENTORY_WINDOW_KURZOR
;         ret
;----------------------------------------------


PREPNI_OBJECT:
; fce prepne dvere nebo paku, bez ohledu na natoceni
; v "h" je "typ"
; v "l" je hledana lokace
    push    de
    call    FIND_FIRST_OBJECT
    jr      nz, PO_EXIT

PO_NALEZEN_OBJECT:
; na lokaci lezi nejaky predmet
    ld      a,(de)                      ;  7:1 typ
    sub     h
    and     MASKA_TYP + MASKA_NATOCENI
    jr      nz,PO_NEXT_OBJECT           ;12/7:2       ??? pokud je horni bit nastaven tak to bude blbnout?

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

; ====================================

; Prohleda seznam predmetu zda na dane pozici ( ulozene v registru "l" ) nelezi nepruchozi predmet ( = aspon jeden z hornich bajtu "typ" je nenulovy ) 
; VSTUP: v "hl" je hledana lokace
; VYSTUP: vraci carry priznak pokud najde
; MENI: de,l,a
JE_POZICE_BLOKOVANA:
    call    FIND_FIRST_OBJECT
    ret     nz                          ;11/5:1 nenalezena
    
JPB_NALEZEN_OBJECT:                     ; na lokaci lezi nejaky predmet
    ld      a,(de)                      ;  7:1 typ
    add     a,MASKA_PREPINACE
    ret     c                           ; blokovany?
    
    call    FFO_NEXT                    ; hledej dalsi
    jr      z,JPB_NALEZEN_OBJECT        ; 10:1 nalezen dalsi objekt na lokaci
    ret



; v IX je zkoumana lokace
; v BC je hloubka * 12 = radek v DOOR_TABLE/RAM_TABLE/...
FIND_OBJECT:        ; 0xd4b5

    inc     ixl
    ret     z                       ; !!!!! drobny bug .) $ff lokace nesmi byt totiz ani v dohledu
    dec     ixl
;         ret        z              ; $0
    
    ld      de,TABLE_ITEM-2         ; 10:3 "defb lokace, typ, dodatecny"
FI_LOOP:
    inc     de                      ;  6:1 de: "typ"->"dodatecny"
FI_LOOP2:
    inc     de                      ;  6:1 de: "dodatecny"->"lokace"
    ld      a,(de)                  ;  7:1
    inc     de                      ;  6:1 de: "lokace"->"typ"
    sub     ixl                     ;  8:2 "lokace predmetu" - "nase hledana lokace"
    jp      c,FI_LOOP               ; 10:2 carry flag?
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
    
    jr      z,FI_PREPINAC           ;12/7:2

    cp      TYP_DVERE               ;  7:2
    jr      z,FI_DOOR               ;12/7:2

    cp      TYP_ENEMY               ;  7:2
    jr      z,FI_ENEMY              ;12/7:2

    cp      TYP_ITEM                ;  7:2
    jp      z,FI_ITEM               ;12/7:2
    
    cp      TYP_DEKORACE            ; musi byt posledni varianta
    jr      nz,FI_LOOP
    
    inc     de                      ; typ -> podtyp
    ld      a,(de)
    and     MASKA_PODTYP
TEST:
;         cp      PODTYP_WALL          ;  7:2 pruchozi steny
;         jp      z,FI_WALL            ;10:3
    
    ld      hl,RUNE_TABLE
    cp      PODTYP_RUNA             ;  7:2 
    jp      z,FI_DEKORACE           ;10:2
    
    ld      hl,KANAL_TABLE
    cp      PODTYP_KANAL            ;  7:2 
    jp      z,FI_DEKORACE           ;10:2
    
    ; sem by jsem se nikdy nemel dostat...

    jp      FI_LOOP2                ; 10:3 "de" ted ukazuje na "dodatecny"
FI_EXIT:
    ret

; ------------ aktualni adresa podfce je v test.asm

FI_DOOR:
    ; vsechny dvere maji ram
    ld      a,(de)                  ;  7:1 typ

    inc     c
    dec     c
    jr      nz,FI_VIEW_RAM
    ; jsme uvnitr otevrenych dveri = nejnizsi bit u "dodatecny" je = { 0 = dvere pro pruchod N-S, 1 dvere pro pruchod W-E }
    ld      hl,VECTOR               ; 10:3
    add     a,(hl)                  ;  7:1 0 = N, 1 = E, 2 = S, 3 = W
    bit     0,a                     ; pokud je nejnizsi bit nastaven ziram kolmo na chodbu ( pruchod ) na ram
    jr      z,FI_LOOP               ; return

FI_VIEW_RAM:                        ; vykresli ram
    ld      hl,RAM_TABLE
    add     hl,bc
    push    bc
    push    de
    call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
    pop     de
    pop     bc
    
    add     a,MASKA_PREPINACE       ; nektere dvere jsou otevrene, AKTUALIZOVAT!!!
    jr      nc,FI_LOOP              ; return

    ld      hl,DOOR_TABLE
    add     hl,bc
    push    bc
    push    de
    call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
    pop     de
    pop     bc

    jr      FI_LOOP                 ; return

; ------------ aktualni adresa podfce je v test.asm

FI_PREPINAC:
    push    bc

    ld      a,(de)                  ;  7:1 "typ"
    and     MASKA_NATOCENI          ;  7:2
    
    ld      hl,VECTOR               ; 10:3
    ld      l,(hl)                  ;  "l": 0 = N, 1 = E, 2 = S, 3 = W
    sub     l                       ; pohledy musi sedet
                                    
    ld      hl,PAKY_TABLE           ; "l" uz nebudem potrebovat
    add     hl,bc

    and     3                       ; protoze nekdy potrebujeme aby sever byl 4 tak jsou validni jen posledni 2 bity
                                    ; pak 3-0 = -1 (000000-11) a 0-3 = 1 (111111-01)
    jr      z,FI_PREPINAC_INIT      ; z oci do oci

    ld      bc,NEXT_PAKA
    add     hl,BC                   ; leve paky
    cp      3                       ; 3 = -1 ve 2 bitech
    jr      z,FI_PREPINAC_INIT      ; leva paka trci doprava ( kdybych byl natocen doleva tak se shoduji nase smery )

    add     hl,BC                   ; prave paky
    cp      1                       ; 
    jr      nz,FI_PREPINAC_EXIT     ; je tu moznost paky co je za stenou a trci ode mne a tu nevidim...
    
    ; zero flag = prava paka trci doleva ( kdybych byl natocen doprava tak se shoduji nase smery )

FI_PREPINAC_INIT:

    ld      a,(de)                  ; "typ"
    or      a
    jp      p,FI_PREPINAC_VIEW      ; kladne = paka je nahore
    
    ld      bc,PAKA_DOWN
    add     hl,bc

FI_PREPINAC_VIEW:
    push    de
    call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
    pop     de

FI_PREPINAC_EXIT:
    pop     bc
    jp      FI_LOOP        



; ------------ aktualni adresa podfce je v test.asm

FI_ENEMY:
    push    de
    push    ix
    push    bc

    ld      a,ENEMY_ATTACK_DISTANCE     ; 7:2
    cp      c
    jr      nz,FI_ENEMY_FAR
; vzdalenost 1, levy predni skret...
    ld      a,(TIMER_ADR)               ; timer
    and     FLOP_BIT_ATTACK
    ld      a,2
    jp      z,FI_ENEMY_FAR
    ld      a,1
FI_ENEMY_FAR:
    ld      (FI_ENEMY_SELFMODIFIYNG2+1),a


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
    jr      z,FI_ENEMY_VIEW
    
    ld      bc,NEXT_TYP_ENEMY           ; uz nebudem potrebovat puvodni hodnotu, pak obnovime ze zasobniku        
FI_ENEMY_NEXT:
    add     hl,BC                       ; 11:1 hledame sprite spravneho nepritele
    dec     a                           ; snizime 
    jr      nz,FI_ENEMY_NEXT
    
FI_ENEMY_VIEW:
    ld      a,(hl)                      ;  7:1 segment
    or      a                           ;  4:1
    jp      z,FI_ENEMY_EXIT             ; v teto hloubce nebude sprite na zadne pozici = exit

    dec     hl                          ;  6:1
    ld      l,(hl)                      ;  7:1
    ld      h,a                         ;  4:1
    ld      (FI_ENEMY_SELFMODIFIYNG+1),hl   ; 16:3
    ex      de,hl

FI_ENEMY_LOOP:

    dec     hl
    ld      b,(hl)
    dec     hl
    ld      c,(hl)
    inc     c                           ; ochranujem akumulator
    dec     c
    jp      z,FI_ENEMY_TEST_LOOP        ; sirka muze byt nula, ale vyska nula znamena nekreslit
    
FI_ENEMY_SELFMODIFIYNG:
    ld      de,0                        ; 10:3 adresa spritu nepritele ve spravne hloubce

FI_ENEMY_SELFMODIFIYNG2:
    ld              a,0
    cp      ixl
    jp      nz,FI_ENEMY_CALL
    
    ld      de,ESA1
    ld      a,b
    add     a,-1
    ld      b,a
    ld      c,$03

FI_ENEMY_CALL:
    push    hl                          ; 11:1
    push    ix                          ; 15:2
    call    COPY_SPRITE2BUFFER
    pop     ix                          ; 14:2
    pop     hl                          ; 10:1
    
FI_ENEMY_TEST_LOOP:
    dec     ixl                         ;  8:2
    jr      nz,FI_ENEMY_LOOP
    
FI_ENEMY_EXIT:
    pop     bc
    pop     ix
    pop     de
    jp      FI_LOOP                     ; return
    
    
; ------------ aktualni adresa podfce je v test.asm

; FI_WALL:        ; pruchozi falesna zed
; 
;         ld      a,(de)                    ;  7:1 typ
; 
;         ld      hl,WALL_TABLE
;         add     hl,bc
;         add     hl,BC                     ; 2x ...        
;         push    bc
;         push    de
;         call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
;         pop     de
;         pop     bc
;         push    bc                        ; 2x kvuli blbym V4p1 a V4m1,ktere nejsou krychle
;         push    de
;         call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
;         pop     de
;         pop     bc
;         
;         jp      FI_LOOP2                  ; return
    
; ------------ aktualni adresa podfce je v test.asm

; VSTUP:         bc = index v tabulce
;                adresa tabulky spravne dekorace
;                de = ukazuje na podtyp/dodatecny!!! proto se vracim pomoci FI_LOOP2
FI_DEKORACE:
    add     hl,bc
    push    bc
    push    de
    call    INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
    pop     de
    pop     bc
    jp      FI_LOOP2                    ; return s de = dodatecny


    
    


; VSTUP:        (di-1) = ixl, (di) = typ = TYP_ITEM prvniho objektu
;                bc = offset v table ( 3 sloupce po dvou 16 bit int ( 12 bajtu ) = primy smer / vlevo / vpravo, radky = hloubka ) 

FI_ITEM:
    ld      a,c
    cp      MAX_VIDITELNOST_PREDMETU_PLUS_1
    jp      nc,FI_LOOP                      ; return ( bohuzel tolikrat, kolikrat je predmetu na policku )

    ld      (FI_ADR_PRETECENI+1),de
    
    ld      hl,VECTOR
    ld      a,TYP_ITEM
    add     a,(hl)                          ; 7:1 + vektor      natoceni
    ld      h,a
    ld      l,e                             ; l = adresa preteceni = prvni predmet

FI_HLEDANI_NEJVZDALENEJSIHO:
    ld      a,(de)                          ; typ + natoceni
    cp      h                               ; roh - vektor      natoceni
    jr      nc,FI_NEJVZDALENEJSI            ; roh je ten nejvzdalenejsi?
FI_DALSI_RADEK:
; prejdeme na dalsi predmet ( jsou razeny podle rohu )
    inc     de                              ; typ -> podtyp
    inc     de                              ; podtyp -> lokace
    ld      a,(de)                          ; lokace ( muzem vytect do jine lokace, pak to znamena ze musime kreslit od ITEM_ADR_POCATKU )
    inc     de                              ; lokace -> typ 
    or      a
    jr      z,FI_DALSI_RADEK                ; dodatecny radek ( preskocime )
    
    cp      ixl
    jr      z,FI_HLEDANI_NEJVZDALENEJSIHO   ; neopustili jsme policko?
    
    ld      e,l
FI_NEJVZDALENEJSI:
    
; mame levy zadni nebo pokud neni pozdejsi
    ld      a,e
    ld      (FI_ADR_NEJVZDALENEJSIHO+1),a
    jr      FI_ZA_TESTEM_OPAKOVANI
    
FI_VYKRESLI_ITEM:
FI_ADR_NEJVZDALENEJSIHO:
    ld      a,0                         ; self-modifying
    cp      e
    ret     z                           ; ret ne jp, takze ukonci i nadrazenou fci

FI_ZA_TESTEM_OPAKOVANI:
    
    ld      a,(VECTOR)                  ; a = (VECTOR)
    add     a,a
    add     a,a                         ; smer pohledu * 4
    ld      l,a
    ld      a,(de)                      ; typ
    and     MASKA_NATOCENI
    add     a,l
    add     a,ITEM_NATOCENI % 256
    ld      l,a
    adc     a,ITEM_NATOCENI / 256
    sub     l
    ld      h,a                         ; hl = index odkud budu cist polohu predmetu
    ld      a,(hl)
    
    push    de
    push    ix
    push    bc
    
    ld      ixh,a
    
    ld      hl,DIV_6                    ; 10:3
    add     hl,BC                       ; 11:1
    ld      a,(hl)                      ;  7:1 ziskame hloubku * 2
    cp      6                           ; hloubku 3 a 4 ignorujeme
    jr      nc,FI_ITEM_EXIT
    ld      l,a

    inc     de
    ld      a,(de)
    and     MASKA_PODTYP
    add     a,a                         ; 2x
    add     a,a                         ; 4x
    add     a,a                         ; 8x
    add     a,l                         ; pripoctem hloubku
    add     a,ITEM_TABLE % 256
    ld      l,a
    adc     a,ITEM_TABLE / 256
    sub     l
    ld      h,a                         ; hl = adresa, kde je ulozena adresa spritu daneho predmetu v ITEM_TABLE vcetne hloubky
    ld      e,(hl)
    inc     hl
    ld      d,(hl)                      ; de = adr. spritu
    
    inc     d
    dec     d
    jr      z,FI_ITEM_EXIT              ; adresa je rovna nule, po dkonceni vsech nahledu snad nenastane... POZOR aktualizovat?

    ld      a,c
    add     a,a                         ; 2*c protoze radek ma 12 word polozek
    add     a,ixh                       ; pridame spravny sloupec
    add     a,ITEM_POZICE % 256         ; 
    ld      l,a
    adc     a,ITEM_POZICE / 256
    sub     l
    ld      h,a                         ; hl = adr. v ITEM_POZICE
    ld      c,(hl)
    inc     c
    dec     c
    jr      z,FI_ITEM_EXIT              ; sirka muze byt nula, ale vyska nula znamena nekreslit
    inc     hl
    ld      b,(hl)
    call    COPY_SPRITE2BUFFER
    
            
FI_ITEM_EXIT:
    pop     bc
    pop     ix
    pop     de
    
    inc     de                          ; typ -> podtyp
    inc     de                          ; podtyp -> lokace
    ld      a,(de)
    inc     de                          ; lokace -> podtyp
    cp      ixl
    jr      z,FI_VYKRESLI_ITEM
; POZOR udelat test zda je to predmet??? Kolidovat muze jen enemy... Mel by ale byt vepredu? Ne..

FI_ADR_PRETECENI:
;        pretecem na zacatek
    ld      de,0                        ; self-modifying
    jr      FI_VYKRESLI_ITEM
    

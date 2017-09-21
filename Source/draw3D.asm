; ====================================

VIEW:        ; 0xd1f7

    ; vykresleni pozadi ( strop a podlaha )
    ld      bc,$1100                    ; 17. sloupec
POZADI:
    ld      de,H5
    ld      a,(POHYB)                   ; 13:3
    and     1
    jr      z,V_H5
    ld      c,$FF
V_H5:
    push    bc
    push    de
    call    COPY_SPRITE2BUFFER
    pop     de
    pop     bc
    djnz    POZADI
    call    COPY_SPRITE2BUFFER
    ; vykresli dno bufferu
    ld      de,dno_bufferu
    ld      bc,$000E                    ;
    call    COPY_SPRITE2BUFFER        

    ld      h,VEKTORY_POHYBU/256        ;  7:2
    ld      a,(VECTOR)                  ; 13:3 {0, 1, 2, 3}
    ld      l,a                         ;  4:1
    ld      c,(hl)                      ;  7:1 modifikator      pro posun vpred
    add     a,12                        ;  7:2                        
    ld      l,a                         ;  4:1
    ld      a,(hl)                      ;  7:1 modifikator      pro posun vpravo
    ld      e,a                         ;  4:1 "e" obsahuje "o 1 vpravo" 
    add     a,a                         ;  4:1 2 * vpravo
    add     a,a                         ;  4:1 4 * vpravo
    ld      d,a                         ;  4:1 "d" obsahuje "max vpravo"

    ld      h,DUNGEON_MAP/256           ;  7:2 
    ld      a,(LOCATION)                ; 13:3        
    ld      b,6                         ;  7:2
NULA:
    ld      l,a                         ;  4:1
    push    hl                          ; 11:1
    add     a,c                         ;  4:1 c = modifikator      pro posun vpred
    djnz    NULA                        ; 13/8:2


    pop     ix                          ; do IX nactem nejvzdalenejsi pozici co vidim pred sebou
    push    de
    ld      hl,TABLE_VIEW_9_DEPTH_4
    ld      b,-1                        ; hloubka
    call    PROHLEDEJ_PROSTOR_VPREDU    ; -40 H4
    pop     de
    ld      a,d
    sub     e
    ld      d,a

    pop     ix
    push    de
    ld      hl,TABLE_VIEW_7_DEPTH_3
    ld      b,48                        ; hloubka
    call    PROHLEDEJ_PROSTOR_VPREDU    ; -32 H3
    pop     de
    ld      a,d
    sub     e
    ld      d,a

    pop     ix
    push    de
    ld      hl,TABLE_VIEW_5_DEPTH_2
    ld      b,36                        ; hloubka
    call    PROHLEDEJ_PROSTOR_VPREDU    ; -24 H2
    pop     de
    ld      a,d
    sub     e
    ld      d,a

    pop     ix
    push    de
    ld      hl,TABLE_DEPTH_1
    ld      b,24                        ; hloubka
    call    PROHLEDEJ_PROSTOR_VPREDU    ;  -16 H1
    pop     de

    pop     ix
    push    de
    ld      hl,TABLE_DEPTH_0
    ld      b,12                        ; hloubka
    call    PROHLEDEJ_PROSTOR_VPREDU    ;  -8 H0
    pop     de

    pop     ix
    ld      hl,TABLE_DEPTH_x
    ld      b,0
    call    PROHLEDEJ_PROSTOR_VPREDU
    
    call    VYKRESLI_AKTIVNI_PREDMET

    ret
    
    
    
    
    ; -------------------------------------
; VSTUP:
;   IX obsahuje pozici na mape kterou vykresluji
;   HL obsahuje odkaz do tabulky sten
;   D obsahuje index "+max. vpravo", e obsahuje "o 1 vpravo"
;   B obsahuje hloubku/vzdalenost pro zjisteni jakou verzi spritu nakreslit v objektech
PROHLEDEJ_PROSTOR_VPREDU:
    ld      c,ixl                   ; ulozime offset pozice
    ld      a,d
PPV_LOOP:
    add     a,c
    ld      ixl,a                   ; ix = max. vpravo
; test steny
    bit     1,(ix)

    push    bc
    push    de
    call    INIT_COPY_PATTERN2BUFFER
    call    INIT_COPY_PATTERN2BUFFER        
    pop     de
    pop     bc
    
    ld      a,d
    cp      e
    jr      nz,PPV_NEKRESLI_VPRAVO
    ; jsme o 1 vpravo
    ld      a,4                     ; primy pohled, o 1 vpravo, o 1 vlevo
    call    INIT_FIND_OBJECT
PPV_NEKRESLI_VPRAVO:
    
    ld      a,c
    sub     d
    ld      ixl,a                   ; ix = max. vlevo
; test steny
    bit     1,(ix)

    push    bc
    push    de
    call    INIT_COPY_PATTERN2BUFFER        
    call    INIT_COPY_PATTERN2BUFFER
    pop     de
    pop     bc

    ld      a,d
    cp      e
    jr      nz,PPV_NEKRESLI_VLEVO
    ; jsme o 1 vlevo
    ld      a,8                     ; primy pohled, o 1 vpravo, o 1 vlevo
    call    INIT_FIND_OBJECT
PPV_NEKRESLI_VLEVO:
    

    ld      a,d
    sub     e
    ld      d,a
    jr      nz,PPV_LOOP

    ld      ixl,c
; test steny
    bit     1,(ix)

    push    bc
    call    INIT_COPY_PATTERN2BUFFER
    pop     bc
    ; divame se vpred
    xor     a                       ; primy pohled, o 1 vpravo, o 1 vlevo
    call    INIT_FIND_OBJECT
    ret
    
    
    
;
INIT_FIND_OBJECT:

    bit     7,B                     ; zaporna hloubka, nekreslim, usetrim si radek s nulama v kazde tabulce
    ret     nz

    push    hl
    push    de
    push    bc
    
    add     a,b
    ld      c,a
    ld      b,0                     ; bc ted dela index pro danou hloubku a kolmici
    
    call    FIND_OBJECT
    pop     bc
    pop     de
    pop     hl
    ret
    

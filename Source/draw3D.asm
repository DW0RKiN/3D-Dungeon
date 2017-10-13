; =====================================================
DRAW3D:     

    ; vykresleni pozadi ( strop a podlaha )
    ld      B, $12                      ; 18 prouzku ( sloupcu )
    ld      A, (POHYB)                  ; 13:3
    rrca                                ; carry?
    sbc     A, A                        ; $00 nebo $FF
    ld      C, A
    
D_POZADI_LOOP:
    ld      DE, H5
    push    BC
    dec     B                           ; 0..17
    call    COPY_SPRITE2BUFFER
    pop     BC
    djnz    D_POZADI_LOOP
    
    ; vykresli dno bufferu
    ld      de, dno_bufferu
    ld      bc, $000E                   ;
    call    COPY_SPRITE2BUFFER        

    ld      h, VEKTORY_POHYBU/256       ;  7:2
    ld      a, (VECTOR)                 ; 13:3 {0, 1, 2, 3}
    ld      l, a                        ;  4:1
    ld      c, (hl)                     ;  7:1 modifikator pro posun vpred (prvni radek)
    add     a, 12                       ;  7:2                        
    ld      l, a                        ;  4:1
    ld      a, (hl)                     ;  7:1 modifikator pro posun vpravo (posledni radek)
    ld      e, a                        ;  4:1 "e" obsahuje "o 1 vpravo" 
    add     a, a                        ;  4:1 2 * vpravo
    add     a, a                        ;  4:1 4 * vpravo
    ld      d, a                        ;  4:1 "d" obsahuje "max vpravo"

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
    

; =====================================================
; VSTUP:
;   IX obsahuje pozici na mape kterou vykresluji
;   HL obsahuje odkaz do tabulky sten
;   D obsahuje max vpravo
;   E obsahuje pozice_vpravo - pozice (o 1 vpravo)
;   B obsahuje hloubku/vzdalenost pro zjisteni jakou verzi spritu nakreslit v objektech
PROHLEDEJ_PROSTOR_VPREDU:
    ld      C, IXL                  ; ulozime offset pozice
    ld      A, D
PPV_LOOP:                           ; djnz smycka
    add     A, C
    ld      IXL, A                  ; ix = max. vpravo
    

; test steny
    bit     1, (IX)                 ; test 0000 0010
    call    INIT_COPY_PATTERN2BUFFER
    call    INIT_COPY_PATTERN2BUFFER        
    
    ld      A, D
    cp      E
    ; jsme o 1 vpravo
    ld      A, $04                  ; primy pohled, o 1 vpravo, o 1 vlevo
    call    z, INIT_FIND_OBJECT


    ld      a,c
    sub     d
    ld      ixl,a                   ; ix = max. vlevo
; test steny
    bit     1,(ix)
    call    INIT_COPY_PATTERN2BUFFER        
    call    INIT_COPY_PATTERN2BUFFER
    
    ld      a,d
    cp      e
    ; jsme o 1 vlevo
    ld      a, $08                  ; primy pohled, o 1 vpravo, o 1 vlevo
    call    z, INIT_FIND_OBJECT

    ld      a,d
    sub     e
    ld      d,a
    jr      nz,PPV_LOOP

    ld      ixl,c    
; test steny
    bit     1,(ix)
    call    INIT_COPY_PATTERN2BUFFER
    ; divame se vpred
    xor     a                       ; primy pohled, o 1 vpravo, o 1 vlevo
    call    INIT_FIND_OBJECT

    
    ret
    
    
ADD_BC_INIT_COPY_PATTERN2BUFFER_NOZEROFLAG:

    add     HL, BC
; =====================================================
; VSTUP: 
;   HL adresa od ktere se budou cist data ( adresa spritu a XY na obrazovce )
; VYSTUP: HL = HL + 4 i kdyz se nic nekreslilo
; MENI:
;   AF , HL=HL+4
INIT_COPY_PATTERN2BUFFER_NOZEROFLAG:
    or      1                       ; reset zero flag
; -----------------------------------------------------
; VSTUP: 
;   zero-flag = 0, nebude se kreslit, = 1 bude
;   HL adresa od ktere se budou cist data ( adresa spritu a XY na obrazovce )
; VYSTUP: HL = HL + 4 i kdyz se nic nekreslilo
; MENI:
;   F , HL=HL+4
INIT_COPY_PATTERN2BUFFER:
    push    DE
    push    BC

    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    inc     hl

    jr      z, ICP_EXIT             ; je tam chodba, nekreslime

    inc     d                       ; ochranujem akumulator
    dec     d                       ; D = 0? nekreslime

    push    af
    push    hl
    push    ix

    call    nz, COPY_SPRITE2BUFFER

    pop     ix
    pop     hl
    pop     af
    
ICP_EXIT:
    pop     BC
    pop     DE
    ret

    
; =====================================================
INIT_FIND_OBJECT:

    bit     7,B                     ; zaporna hloubka, nekreslim, usetrim si radek s nulama v kazde tabulce
    ret     nz

    push    hl
    push    de
    push    bc
    
    add     a,b
    ld      c,a                     ; C = 0 -> stojime primo na dane lokaci
    ld      b,0                     ; bc ted dela index pro danou hloubku a kolmici
    
    call    FIND_OBJECT
    pop     bc
    pop     de
    pop     hl
    ret
    

    

; VSTUP: b = -1 otoceni doleva, +1 otoceni doprava
OTOC_SE:
    ld      a,c                     ;  4:1 (VECTOR)
    add     a,B                     ;  4:1
    and     MASKA_NATOCENI          ;  7:2
    ld      hl,VECTOR               ; 10:3
    ld      (hl),a                  ;  7:1 ulozi novy VECTOR pohledu
    
    call    INC_POCITADLO_POHYBU_A_ZVUK     ; zvedne "pocitadlo pohybu/otoceni"
    
; PRUMER        equ        ( SIPKA_OTOCDOLEVA + SIPKA_OTOCDOPRAVA ) /2
;         ld      a,PRUMER
    ld      a,SIPKA_OTOCDOLEVA/2 + SIPKA_OTOCDOPRAVA/2
    add     a,b
    add     a,b
    call    AKTUALIZUJ_SIPKY        ; a = 16 otoceni doleva, 20 = otoceni doprava
    call    AKTUALIZUJ_RUZICI
    ret
;------

; ulozi do registru "l" novou pozici 
; VSTUP: hl = aktualni pozice, c = (VECTOR), a = { 0 dopredu, 4 dozadu, 8 vlevo, 12 vpravo }
; VYSTUP: hl = nova pozice
; MENI: de,a
DO_HL_NOVA_POZICE:
    ld      d,VEKTORY_POHYBU/256    ;  7:2
    add     a,c                     ;  4:1 (VECTOR) = {0, 1, 2, 3} = sloupec
    ld      e,a                     ;  4:1 de = @(VECTORY_POHYBU[radek][sloupec])

    ld      a,(de)                  ;  7:1 o kolik zmenit LOCATION pro pohyb danym smerem
    add     a,l                     ;  4:1 ZMENIT POKUD BUDE MAPA 16bit!!! ( ..a nejen to, pozice predmetu, dveri atd. )
    ld      l,a                     ;  4:1 hl = pozice na mape po presunu
    ret

;--------


; VSTUP:         nic
; NEMENI:        b ( protoze nesmi )
INC_POCITADLO_POHYBU_A_ZVUK:
      ld      hl,POHYB              ; 10:3
      inc     (hl)
      
      ld      hl,1000
IPPAZ_LOOP: 
      ld      a,(hl)
      and     248
      out     (254),a
      dec     hl
      ld      a,h
      or      l
      jr      nz,IPPAZ_LOOP
      ret



    
    


; =======================
POSUN:
    ; Pokud je aktivni panel s inventarem, tak sipky pohybuji s kurzorem v inventari
    call    TEST_OTEVRENY_INVENTAR      ;
    jp      z,POSUN_NEJSEM_V_INVENTARI
    ; jsme v inventari
    dec     b                           ;  4:1 "b" obsahuje hodnotu { stisknuto_dopredu = 0,stisknuto_dozadu = 1,stisknuto_vlevo = 2,stisknuto_vpravo = 3 }
    ld      c,B                         ;  4:1 (dopredu=nahoru=0 - 1) = -1
    jp      m,POSUN_PRICTI                        ; 10:3
    ld      c,1                         ;  7:2 dozadu = dolu = +1, nelze pouzit "inc     c" protoze by to zrusilo zero flag...
    jr      z,POSUN_PRICTI              ;12/7:2

    ld      hl,POSUN_VLEVO_INVENTAREM-1 ; 10:3
    dec     b                           ;  4:1 puvodni - 2        
    jr      z, POSUN_LOOP               ;12/7:2
    ld      l,POSUN_VPRAVO_INVENTAREM-1 ;  7:2

POSUN_LOOP:                             ; prochazeni pole POSUN_VLEVO_INVENTAREM nebo POSUN_VPRAVO_INVENTAREM a hledani spravneho rozsahu
    inc     l                           ;  4:1
    cp      (hl)                        ;  7:1
    inc     l                           ;  4:1 carry flag nebude zmenen
    jr      nc,POSUN_LOOP               ;12/7:2
    
    ld      c,(hl)                      ;  7:1
                                        ;   : 26+26 tabulky=52
POSUN_PRICTI:
    add     a,c                         ; 4:1
    ld      b,MAX_ITEM
    jp      p,POSUN_NEZAPORNY
    add     a,B                         ; k zapornemu kurzoru prictu MAX_ITEM
POSUN_NEZAPORNY:
    cp      b
    jr      c,POSUN_V_MEZICH
    sub     b                           ; u kurzoru co pretekl odectu MAX_ITEM
POSUN_V_MEZICH:
    ld      (KURZOR_V_INVENTARI),a      ; opraveny zmeneny ulozim
    jp      INVENTORY_WINDOW_KURZOR

    




; ==============================
POSUN_NEJSEM_V_INVENTARI:

    ld      a,b
    add     a,a                         ; 4:1 2x
    add     a,a                         ; 4:1 4x
    push    af                          ; uchovam smer kvuli sipkam

    call    DO_HL_NOVA_POZICE
; test steny
    bit     0,(hl)                      ; 12:2 self-modifying pokud meni patra
    jr      nz,POSUN_ZABLOKOVAN         ;12/7:1 Pokud tam je stena opust fci
    
    call    JE_POZICE_BLOKOVANA         ; vraci carry priznak kdyz je zablokovana
    jr      c,POSUN_ZABLOKOVAN

    ld      a,l
    ld      (LOCATION),a                ; 13:3 ulozi novou pozici

    call    INC_POCITADLO_POHYBU_A_ZVUK ;zvedne "pocitadlo pohybu/otoceni"
    jr      EXIT_POSUN
    
POSUN_ZABLOKOVAN:
    ld      ix,VETA_NO_WAY
    call    PRINT_MESSAGE
    
EXIT_POSUN:
    pop     af
    call    AKTUALIZUJ_SIPKY
    ret
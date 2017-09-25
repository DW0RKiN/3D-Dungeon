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



; ----- 2 polovicni obrys postavy, toulec a prostirani
    ld      HL, DODATECNE_V_INVENTARI
    ld      b,4*2
IW_NEXT_DODATECNE: 
    ld      e,(hl)
    inc     hl
    ld      d,(hl)
    inc     hl
    push    de
    djnz    IW_NEXT_DODATECNE
; ----- vykresli podklad pod predmety v inventari
    ; HL = POZICE_V_INVENTARI = 16 + DODATECNE_V_INVENTARI
    ld      A, (KURZOR_V_INVENTARI) ; 13:3
    ld      C, A                    ;  4:1 index predmetu s kurzorem
    xor     A                       ;  4:1 akumulator pouzijeme jako citac protoze potrebujeme hlidat 2 stavy
    ld      B, MAX_INVENTORY        ;  7:2
IW_SACHOVNICE_LOOP:

    ld      de,I_bgm                ; pozadi pro kurzor
    cp      c                       ; pozice kurzoru?
    jr      z,IW_ULOZ
    
    ld      de,I_bg                 ; normalni pozadi
    cp      17                      ; jsme v dvousloupci predmetu + prostirani?
    jr      c,IW_ULOZ
    
    ld      de,I_ram                ; prazdny ram protoze jsme jeste (B klesa) na naznacene postave
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
    ld      a,MAX_INVENTORY + 4          ; 2x postava, toulec a prostirani
    call    VYKRESLI_ZE_ZASOBNIKU

    
    
    
; ------- potrebujeme zrusit konturu postavy v mistech kde je predmet
    

; ------------------------------

    
if (ITEM2SPRITE/256) != (ITEM2SPRITE_END/256)
    .error      'Seznam ITEM2SPRITE prekracuje 256 bajtovy segment!'
endif

    call    HLAVNI_RADEK_INVENTORY_ITEMS    ; DE ukazatel na radek aktivni postavy v INVENTORY_ITEMS
    ld      ixh, ITEM2SPRITE / 256
    ld      B, MAX_INVENTORY        ;  7:2
    ld      A, B                    ;  4:1
    ld      hl, KURZOR_V_INVENTARI  ; 10:3
    sub     (hl)                    ;  7:1 vykreslujeme odzadu kvuli citaci smycky, takze musime upravit index KURZOR_V_INVENTARI
    ld      c, a
    
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
    
    ld      a,2*MAX_INVENTORY       ; predmety postavy
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
ZESEDNI_NEPOVOLENE_POZICE:
    ld      a, (PRESOUVANY_PREDMET)
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
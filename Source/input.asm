; =====================================================
; VSTUP:
;   cte porty pro KEMPSTON joystick
; VYSTUP:         
;   A = podvrzeny ascii kod stisknute klavesy 
;   zero flag kdyz nic nenacetl
TEST_KEMPSTON:
    xor     A                       ; A = novy stav joysticku
    ld      H, A                    ; H = puvodni stav joystiku
    ld      L, A                    ; HL = 0 
TK_NOVY_STAV:
    ld      B, REPEAT_READING_JOY   ; pocet opakovani cteni stavu joysticku po kazde zmene
    or      H                       ; pridame k puvodnimu stavu novy
    ld      H, A                    ; ulozime do puvodniho
TK_LOOP:
    halt                            ;
    in      A, (JOY_PORT)           ; cteme stav joysticku
    and     $1F                     ; odmazem sum v hornich bitech, krome spodnich 5
    cp      $1F                     ; je neco stisknuto? 
    ret     z                       ;
    cp      L                       ; lisi se nove cteni od predchoziho? 
    ld      L, A                    ; posledni cteni do registru "l"
    jr      nz, TK_NOVY_STAV        ; lisi se 
    djnz    TK_LOOP                 ; nelisilo se, snizime pocitadlo
    
    ld      A, H                    ; vysledny stav do akumulatoru
    ld      HL, DATA_KEMPSTON       ; 
    ld      B, DATA_KEMPSTON_SUM    ; delka tabulky    
TK_TEST_STAVU:
    cp      (HL)                    ; je to hledana kombinace
    inc     HL                      ; nemeni priznaky
    jr      z, TK_SHODNY_STAV       ;
    inc     HL                      ;
    djnz    TK_TEST_STAVU           ;
    
TK_SHODNY_STAV:
    ld      A, (HL)                 ; nahradi stav joysticku ekvivalentnim znakem klavesnice 
    or      A                       ; (not) zero flag
    ret                             ; 

    
    
; =====================================================
; VSTUP: nic
; VYSTUP:
KEYPRESSED:
    ld      DE, TIMER_ADR
    ld      A, (DE)
    and     FLOP_BIT_ATTACK/2
    ld      B, A                    ; nastav bit
    ld      HL, LAST_KEY_ADR        ; 10:3 23560 = LAST K system variable.
KEYPRESSED_NO:

    ld      A, (DE)
    and     FLOP_BIT_ATTACK/2
    xor     B                   
    ret     nz                      ; pokud bit uz neni shodny tak prekresli scenu 
    
    ld      A, (HL)                 ;  7:1 a = LAST K
    or      a                       ;  4:1 nula?
    push    hl
    push    bc
    call    z, TEST_KEMPSTON
    pop     bc
    pop     hl
    
    jr      z,KEYPRESSED_NO         ;12/7:2 v tehle smycce bude Z80 nejdelsi dobu... 

    ld      b,0                     ;  7:2 
    ld      (hl),b                  ;  7:1 smazem, LAST K = 0

    ld      HL, (LOCATION)          ; 16:3 L=LOCATION, H=VECTOR
    ld      C, H                    ;  4:1 (VECTOR)
    ld      H, DUNGEON_MAP/256      ;  7:2 HL = aktualni pozice na mape 

    ; Vstup:
    ;   HL = adresa mapy
    ;   C  = vektor natoceni
    ;   A  = stisknuty znak
    
    ;   B = 0 = stisknuto_dopredu = offset radku tabulky VEKTORY_POHYBU

    ld      DE, POSUN
    push    DE
    
if ( stisknuto_dopredu = 0 and stisknuto_dozadu = 1 and stisknuto_vlevo = 2 and stisknuto_vpravo = 3 )
    cp      KEY_DOPREDU             ;  7:2, "w" = dopredu
    ret     z

    inc     B                       ;  4:1 B = stisknuto_dozadu
    cp      KEY_DOZADU              ;  7:2, "s" = dozadu
    ret     z

    inc     B                       ;  4:1 B = stisknuto_vlevo
    cp      KEY_VLEVO               ;  7:2, "a" = vlevo
    ret     z

    inc     B                       ;  4:1 B = stisknuto_vpravo
    cp      KEY_VPRAVO              ;  7:2, "d" = vpravo
    ret     z
    
else

.warning 'Delsi kod o 4 bajty protoze stisknuto_dopredu..stisknuto_vpravo != 0..3'

    cp      KEY_DOPREDU             ;  7:2, "w" = dopredu
    ret     z

    ld      B, stisknuto_dozadu     ;  7:2, offset radku tabulky VEKTORY_POHYBU
    cp      KEY_DOZADU              ;  7:2, "s" = dozadu
    ret     z

    ld      B, stisknuto_vlevo      ;  7:2, offset radku tabulky VEKTORY_POHYBU
    cp      KEY_VLEVO               ;  7:2, "a" = vlevo
    ret     z

    ld      B, stisknuto_vpravo     ;  7:2, offset radku tabulky VEKTORY_POHYBU
    cp      KEY_VPRAVO              ;  7:2, "d" = vpravo
    ret     z
endif
    pop     DE

    ld      b,-1                    ;  7:2, pouzito pro VECTOR += b
    cp      KEY_DOLEVA              ;  7:2, "q" = otoc se vlevo
    jr      z,OTOC_SE
    
    ld      b,1                     ;  7:2, pouzito pro VECTOR += b
    cp      KEY_DOPRAVA             ;  7:2, "e" = otoc se vpravo
    jr      z, OTOC_SE

    cp      KEY_SPACE               ;  7:2, "mezernik/asi space" = prepnuti paky
    jp      z, PREHOD_PREPINAC

    cp      KEY_INVENTAR            ;  7:2 "i" = inventar / hraci
    jp      z,SET_RIGHT_PANEL

    cp      KEY_FHAND               ;  7:2 "f" first hand
    jp      z, BOJ

    cp      KEY_SHAND               ;  7:2 "g" second hand
    jp      z, BOJ
    
    cp      42                      ;  7:2 "*" = ctrl+b ( nastavi border pro test synchronizace obrazu )
    jp      z, SET_BORDER
    
    cp      96                      ; ctrl+x
    jr      nz, K_NOEXIT            ; jina klavesa?
    pop     hl                      ; zrusim ret
    call    POP_ALL
    ret                             ; return to  BASIC
K_NOEXIT:


    ld      HL, SUM_POSTAV
    ld      DE, NEW_PLAYER_ACTIVE
    push    DE
    
    cp      KEY_PLUS                ;  7:2 "k" = "+"
    jp      z, POSTAVA_PLUS
    
    cp      KEY_MINUS               ;  7:2 "j" = "-"
    jp      z, POSTAVA_MINUS
    
    sub     '1'                     ; 0..5?
    cp      (HL)                    ; 1..6
    jp      nc, HELP
    
    dec     HL                      ;  6:1 HL = HLAVNI_POSTAVA
    ld      (HL), A                 ;  7:1 nova HLAVNI_POSTAVA    
    ret                             ; jp NEW_PLAYER_ACTIVE


; =====================================================
SET_BORDER:
    ld      a, (BORDER)
    xor     $07
    ld      (BORDER), a
    ret
    

; =====================================================
; VSTUP: 
;   IX ukazatel na string zakonceny znakem mensim jak 32 a ktery neni vetsi jak 85+32
;   HL = adresa atributu prvniho znaku
;   offset PISMO_5PX = 0
; VYSTUP: 
;   IX ukazuje na zacatek dalsiho retece
;   pokud nebyl prvni znak 0, tak B = 0
; MENI:
;   DE, HL, BC, A
PRINT_STRING:                           ; ver 0.3
    ld      A, $07                      ; white

; -----------------------------------------------------
; VSTUP:
;   A = color
PRINT_STRING_COLOR:                     ;

    ld      E, L                        ;  4:1
    ld      L, A                        ;  4:1
    push    HL                          ; 11:1

    call    SEG_ATTR2SCREEN             ; 17:3
    ld      D, H                        ;  4:1
    
    ld      C, $40                      ;  7:2


PS_NEXT_CHAR:
    ; na zacatku a na konci obarvuji, takze i kdyz prekroci znak bude to spravne
    pop     HL                          ; 10:1

; -----------------------------------------------------
; IX ukazatel na aktualni znak retezce
; DE adresa znaku na obrazovce
; C  maska bitu kde ve znaku zaciname
; H segment atributu
; L color
PRINT_STRING_CONTINUE:
    ld      A, L                        ;  4:1 color
    ld      L, E                        ;  4:1
    ld      (HL), A                     ;  7:1 set color
    ld      L, A                        ;  4:1
    
    ld      A, (IX+$00)                 ; 19:3
    inc     IX                          ; 10:2 pri ukonceni ukazuje na zacatek dalsiho retezce
    sub     32                          ;  7:2 z mezery udela nulu
    ret     c                           ;11/5:1  if ( char < 32 ) return
    
    push    HL                          ; 11:1

    ; 5*char Funguje az do znaku char = (85+32), pak pretece 85*3=255
    ld      H, A                        ;  4:1 1x
    add     A, A                        ;  4:1 2x 0..128
    ld      L, A                        ;  4:1 2x
    add     A, H                        ;  4:1 3x 0..192
    add     A, L                        ;  4:1 5x 0..320 carry?
    ld      L, A                        ;  4:1
    adc     A, PISMO_5PX/256            ;  7:2
    sub     L                           ;  4:1
    ld      H, A                        ;  4:1 HL adresa prvniho sloupce znaku

    ; HL adresa sloupcu znaku, DE adresa v pameti, C bit
    ld      B, $05                      ;  7:2
PS_RIGHT_LOOP:

    ld      A, (HL)                     ; 
    or      A                           ;
    jr      z, PS_PX_RIGHT              ; same nuly
    
    push    HL                          ; 11:1
    ld      L, A                        ;  7:1
    ld      H, D                        ;  4:1
    push    BC                          ; 11:1
    ld      B, $08                      ;  7:2
    
PS_LOOP_PX_DOWN:
    rl      L                           ;  8:2
    jr      nc, PS_NEXT_PX_DOWN         ; 12/7:2
    ld      A, (DE)                     ;  7:1
    xor     C                           ;  4:1
    ld      (DE), A                     ;  7:1
PS_NEXT_PX_DOWN:
    inc     D                           ;  4:1
    djnz    PS_LOOP_PX_DOWN             ;13/8:2
    
    pop     BC                          ; 10:1
    ld      D, H                        ;  4:1    
    pop     HL                          ; 10:1 
PS_PX_RIGHT:
    inc     HL                          ;  4:1 ukazatel na dalsi mikroradek znaku

    xor     A                           ; 4:1
    rrc     C                           ; 8:2
    adc     A, E                        ; 4:1
    ld      E, A                        ; 4:1

    djnz    PS_RIGHT_LOOP              ;13/8:2

    jr      PS_NEXT_CHAR
    

; =====================================================
; VSTUP: 
;   a color
;   HL adresa atributu prvniho znaku
;   IX ukazatel na string zakonceny znakem mensim jak 32
PRINT_STRING_OBAL:
    push    HL                          ;
    push    DE
    push    BC                          ;
    call    PRINT_STRING_COLOR          ; 
    pop     BC                          ; 
    pop     DE
    pop     HL                          ; 
    ret                                 ; 
	
;------------------------------------

if (0)
PRINT2BUFFER:
    ld	a,Adr_Buffer / 256
    ld	(PS_ADRESA_SEGMENTU+1),a
    ret

PRINT2SCREEN:
    ld	a,$40
    ld	(PS_ADRESA_SEGMENTU+1),a
    ret
endif


; =====================================================
; scroll routine, o jeden radek nahoru textoveho pole 
; ver 0.1
; NEMENI: "a","IX" ( dulezite, lze pak volat pred PRINT_STRING, ktere ma IX jako parameter s adresou retezce )
; DODELAT: nakonec napravo ma byt CAMP takze se to musi cele prepsat...
SCROLL:
	ld	h,$50				;  7:2 posledni tretina obrazovky
SCROLL_LOOP:
	ld	d,h				;  4:1 "h" je inkrementovano pres ldir protoze "l" pretece na 0
	ld	e,4*32				;  7:2 na radek 4 ( od nuly)
	ld	l,5*32				;  7:2 zacneme kopirovat radek 5
	ld	bc,3*32				; 10:3 cele to zopakujeme 3 radky
	ldir					; 21/16:2 "LD (DE),(HL)", DE++, HL++, BC--
	bit	3,h				;  8:2
	
; $51-$57	0101 0???
; $58		0101 1000
; $5B		0101 1011 

	jr	z,SCROLL_LOOP			; 12/7:2
	bit	0,h				;  8:2 h = $58 = 0101 1000 / h = $5B = 0101 1011
	ld	h,$5A				; posledni tretina atributu
	jr	z,SCROLL_LOOP			; 12/7:2
	
SCROLL_LAST_LINE:				; smazani posledniho radku
	ld	b,8
	ld	h,$50
SCROLL_NEXT_MICROLINE:
	ld	l,e				; po ldir "e" = E0 = 256-32 
SCROLL_CLEAR_MICROLINE:
	ld	(hl),c				; v "c"je nula po ldir
	inc	l
	jr	nz,SCROLL_CLEAR_MICROLINE
	inc	h
	djnz	SCROLL_NEXT_MICROLINE
	ret					; atributy nemazem protoze PAPER bude cerny a INK se nastavi pri psani 



; =====================================================
; Odskroluje textove pole a zapise naspod novy retezec
; VSTUP: IX ukazatel na string zakonceny znakem mensim jak 32
; zapisuje primo na obrazovku
PRINT_MESSAGE:
    ld      a, %00000111                ; INK = 7 = bila
 
; -----------------------------------------------------
; VSTUP:
;   A = color
PRINT_MESSAGE_COLOR:
    call    SCROLL                      ; nemeni "IX" ani "a"

    ld      HL, $5AE0                   ; zacatek posledniho radku
    call    PRINT_STRING_COLOR
    ret
    
    
; =====================================================    
; VSTUP: 
;   B  = index vety
;   HL = je pocatecni veta
PRINT_MESSAGE_ARRAY:

    call    ADR_X_STRING    
    ld      a,%00000101                 ; azurova
    call    PRINT_MESSAGE_COLOR

    ret
    
    
; =====================================================
PRINT_DEKORACE:
    call    PUSH_ALL
        
    inc     DE                          ; DE = &(TABLE_OBJECTS[?].dodatecny)
    ld      A, (DE)
    and     MASKA_PODTYP
    ld      B, A                        ; index vety
    ld      HL, ARRAY_STRING_DEKORACE   ; pocatecni veta
    call    PRINT_MESSAGE_ARRAY         ; 
    
    call    POP_ALL
    ret

    
; =====================================================
PRINT_PREPINAC:
    call    PUSH_ALL

    ld      A, (DE)
    and     MASKA_PODTYP
    srl     A
    srl     A                           ; odstranime natoceni
    
    ld      B, A                        ; index vety
    ld      HL, ARRAY_STRING_PREPINACE  ; pocatecni veta
    call    PRINT_MESSAGE_ARRAY         ; 

    call    POP_ALL
    ret


; =====================================================
; Najde pocatek x-teho retezce zakonceny nulou od pocatecni adresy
; VSTUP:
;   HL pocatecni adresa
;   B kolikaty retezec hledam od nuly
; VYSTUP:
;   IX = @(strings[B])
;   A = 0
;   BC = 0
AXS_NEXT_STRING:
    cpir                        ; hl++, bc--

; VSTUPNI_BOD FCE!!!
; -----------------------------------------------------
ADR_X_STRING:
    xor     A                   ;
    ld      C, A                ; BC = $??00 -> cpir -> B--
    cp      B                   ;
    jr      nz, AXS_NEXT_STRING

    push    hl
    pop     ix
    ret

    
if (0)
; VSTUP: hl = odkud, de = kam
STRING_COPY:
	ld	a,(hl)
	inc	hl
	ld	(de),a
	inc	de
	or	a
	jr	nz,STRING_COPY
	ret
endif


; =====================================================
; VSTUP: 
;   A index predmetu
;   HL ukazatel na pokracujici vetu
; MENI:
;   AF, BC, DE, HL, IX
;   pokud neni druha tiskova veta "" tak B = 0
ITEM_MAKE_A:
    or      A
    ret     z

    push    HL                          ; ulozime na zasobnik aby to mohlo byt vybrano jako druha tisknuta veta
    
    ld      B, A
    ld      HL, ARRAY_STRING_ITEMS
    call    ADR_X_STRING

    call    SCROLL
    
    ld      HL, $5AE0                   ; zacatek posledniho radku
    call    PRINT_STRING

    pop     IX
    ; navazeme na tisknutou vetu
    call    PRINT_STRING_CONTINUE

    ret


; =====================================================
; VSTUP: 
;   A index predmetu
; VYSTUP: 
;   Vypiset NECO TAKEN na spodek obrazovky
ITEM_TAKEN_A:
    ld      HL, VETA_TAKEN
    jr      ITEM_MAKE_A                 ; diky tomu ze to neni call, nemenime zasobnik

    
; ===================================================== 
; VSTUP: 
;   A index predmetu
; VYSTUP: 
;   Vypiset NECO PUT na spodek obrazovky
ITEM_PUT_A:
    ld      HL, VETA_PUT
    jr      ITEM_MAKE_A                 ; diky tomu ze to neni call, nemenime zasobnik
 

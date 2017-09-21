
; VSTUP: 
;   IX ukazatel na string zakonceny znakem mensim jak 32 a ktery neni vetsi jak 85+32
;   HL = adresa atributu prvniho znaku
;   offset PISMO_5PX = 0
; VYSTUP: 
;   IX ukazuje na zacatek dalsiho retece
; MENI:
;   DE, HL, BC, A


PRINT_STRING:                           ; ver 0.3
    ld      A, $07                      ; white

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
    
; IX ukazatel na aktualni znak retezce
; DE adresa znaku na obrazovce
; C  maska bitu kde ve znaku zaciname
; H segment atributu
; L color
PS_COLOR:
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
    

; ------------------------------------------
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



;------------------------------------
; Odskroluje textove pole a zapise naspod novy retezec
; VSTUP: IX ukazatel na string zakonceny znakem mensim jak 32
; zapisuje primo na obrazovku
PRINT_MESSAGE:
    ld      a, %00000111                ; INK = 7 = bila
    
; VSTUP:
;   a = color
PRINT_MESSAGE_COLOR:
    call    SCROLL                      ; nemeni "IX" ani "a"

    ld      HL, $5AE0                   ; zacatek posledniho radku
    call    PRINT_STRING_COLOR
    ret
    
    
    
; VSTUP: 
; B  = index vety
; HL = je pocatecni veta
PRINT_MESSAGE_ARRAY:

    call    ADR_X_STRING    
    ld      a,%00000101                 ; azurova
    call    PRINT_MESSAGE_COLOR

    ret
    
    
PRINT_DEKORACE:
    call    PUSH_ALL
        
    inc     DE                          ; DE = &(TABLE_ITEM[?].dodatecny)
    ld      A, (DE)
    and     MASKA_PODTYP
    ld      B, A                        ; index vety
    ld      HL, ARRAY_STRING_DEKORACE   ; pocatecni veta
    call    PRINT_MESSAGE_ARRAY         ; 
    
    call    POP_ALL
    ret

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


;------------------------------------

; Najde pocatek x-teho retezce zakonceny nulou od pocatecni adresy
; VSTUP:
;   HL pocatecni adresa
;   B kolikaty retezec hledam od nuly
; VYSTUP:
;   IX = @(strings[B])
;   A = 0
;   B = 0
AXS_NEXT_STRING:
    dec     B                   ; 4:1
    ld      c,$ff               ; pokud by byl retezec delsi jak 255 znaku tak mame smulu
    cpir                        ; hl++, bc--

; VSTUPNI_BOD FCE!!!
ADR_X_STRING:
    xor     A                   ;
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




; VSTUP: 
;   b index predmetu
;   na zasobniku lezi ukazatel na pokracujici vetu
ITEM_MAKE:
    ld      hl,ARRAY_STRING_ITEMS
    call    ADR_X_STRING

    call    SCROLL
    
    ld      HL, $5AE0                   ; zacatek posledniho radku
    call    PRINT_STRING

    pop     IX
    call    PS_COLOR

    ret
ITEM_END:



; VSTUP: b index predmetu
; VYSTUP: 
;   Vypiset NECO TAKEN na spodek obrazovky
ITEM_TAKEN:
    ld      HL, VETA_TAKEN
    push    HL                          ; ulozime na zasobnik aby to mohlo byt vybrano jako druha tisknuta veta
    jr      ITEM_MAKE                   ; diky tomu ze to neni call, nemenime zasobnik

    
 
; VSTUP: b index predmetu
; VYSTUP: 
;   Vypiset NECO PUT na spodek obrazovky
ITEM_PUT:
    ld      HL, VETA_PUT
    push    HL                          ; ulozime na zasobnik aby to mohlo byt vybrano jako druha tisknuta veta
    jr      ITEM_MAKE                   ; diky tomu ze to neni call, nemenime zasobnik
 
    
END_CODE:

if (END_CODE >= pismoStart )
    .error 'Data fontu prepisuji konec kodu... Sniz hodnotu progStart a nezapomen zmenit hodnotu RANDOMIZE USR.'
endif



org pismoStart

PISMO_5PX:
defb $00,$00,$00,$00,$00	; 32 space 0-4
defb $00,$3a,$00,$00,$00	; 33 ! 0-4
defb $00,$60,$00,$60,$00	; 34 " 5-9
defb $14,$3e,$14,$3e,$14	; 35 # 10-14
defb $00,$12,$2a,$6b,$24	; 36 $ 15-19
defb $32,$34,$08,$16,$26	; 37 % 20-24
defb $00,$14,$3a,$14,$0a	; 38 & 25-29
defb $00,$00,$60,$00,$00	; 39 ' 30-34
defb $00,$00,$3c,$42,$00	; 40 ( 35-39
defb $00,$00,$42,$3c,$00	; 41 ) 40-44
defb $00,$14,$08,$14,$00	; 42 * 45-49
defb $00,$08,$1c,$08,$00	; 43 + 50-54
defb $00,$02,$04,$00,$00	; 44 , 55-59
defb $00,$08,$08,$08,$00	; 45 - 60-64
defb $00,$02,$00,$00,$00	; 46 . 65-69
defb $02,$04,$08,$10,$20	; 47 / 70-74
defb $00,$1c,$26,$2a,$1c	; 48 0 75-79
defb $00,$12,$3e,$02,$00	; 49 1 80-84
defb $00,$26,$2a,$2a,$12	; 50 2 85-89
defb $00,$22,$2a,$2a,$14	; 51 3 90-94
defb $00,$3c,$04,$0e,$04	; 52 4 95-99
defb $00,$3a,$2a,$2a,$24	; 53 5 100-104
defb $00,$1c,$2a,$2a,$04	; 54 6 105-109
defb $00,$20,$26,$28,$30	; 55 7 110-114
defb $00,$14,$2a,$2a,$14	; 56 8 115-119
defb $00,$10,$2a,$2a,$1c	; 57 9 120-124
defb $00,$00,$14,$00,$00	; 58 : 125-129
defb $00,$02,$14,$00,$00	; 59 ; 130-134
defb $00,$08,$14,$22,$00	; 60 < 135-139
defb $00,$14,$14,$14,$00	; 61 = 140-144
defb $00,$22,$14,$08,$00	; 62 > 145-149
defb $00,$10,$20,$2a,$10	; 63 ? 150-154
defb $00,$1c,$22,$3a,$1a	; 64 @ 155-159
defb $00,$1e,$28,$28,$1e	; 65 A 160-164
defb $00,$3e,$2a,$2a,$14	; 66 B 165-169
defb $00,$1c,$22,$22,$22	; 67 C 170-174
defb $00,$3e,$22,$22,$1c	; 68 D 175-179
defb $00,$3e,$2a,$2a,$22	; 69 E 180-184
defb $00,$3e,$28,$28,$20	; 70 F 185-189
defb $00,$1c,$22,$2a,$0c	; 71 G 190-194
defb $00,$3e,$08,$08,$3e	; 72 H 195-199
defb $00,$22,$3e,$22,$00	; 73 I 200-204
defb $00,$04,$02,$02,$3c	; 74 J 205-209
defb $00,$3e,$08,$14,$22	; 75 K 210-214
defb $00,$3e,$02,$02,$02	; 76 L 215-219
defb $00,$3e,$10,$10,$3e	; 77 M 220-224
defb $00,$3e,$10,$08,$3e	; 78 N 225-229
defb $00,$1c,$22,$22,$1c	; 79 O 230-234
defb $00,$3e,$28,$28,$10	; 80 P 235-239
defb $00,$1c,$22,$26,$1e	; 81 Q 240-244
defb $00,$3e,$28,$28,$16	; 82 R 245-249
defb $00,$12,$2a,$2a,$24	; 83 S 250-254
defb $00,$20,$3e,$20,$20	; 84 T 255-259
defb $00,$3c,$02,$02,$3c	; 85 U 260-264
defb $00,$3e,$02,$04,$38	; 86 V 265-269
defb $00,$3e,$04,$04,$3e	; 87 W 270-274
defb $00,$36,$08,$08,$36	; 88 X 275-279
defb $00,$38,$06,$08,$30	; 89 Y 280-284
defb $00,$26,$2a,$2a,$32	; 90 Z 285-289
defb $00,$00,$7e,$42,$00	; 91 [ 290-294
defb $20,$10,$08,$04,$02	; 92 \ 295-299
defb $00,$00,$42,$7e,$00	; 93 ] 300-304
defb $10,$20,$40,$20,$10	; 94 ^ 305-309
defb $00,$02,$02,$02,$02	; 95 _ 310-314
defb $00,$08,$3e,$4a,$22	; 96 ` 315-319

if (PISMO_5PX % 256 != 0)
    .error 'Adresa pocatku fontu PISMO_5PX nelezi na pocatku segmentu'
endif


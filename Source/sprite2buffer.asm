MEZERA		equ	$40


; Upravi fci COPY_SPRITE2BUFFER tak aby zapisovala do bufferu
; MENI: akumulator
SET_TARGET_BUFFER:
	ld	a,Adr_Buffer/256			;  
	ld	(CS2B_SELFMODIFYING_ADR_BUFF+1),a
	ld	a,Adr_Attr_Buffer/256			;  
	ld	(CS2B_SELFMODIFYING_ADR_ATTR_BUFF+1),a
	ret
	
; --------------------

; Upravi fci COPY_SPRITE2BUFFER tak aby zapisovala na SCREEN
; MENI: akumulator
SET_TARGET_SCREEN:
	ld	a,$40			;  
	ld	(CS2B_SELFMODIFYING_ADR_BUFF+1),a
	ld	a,$58			;  
	ld	(CS2B_SELFMODIFYING_ADR_ATTR_BUFF+1),a
	ret
 
; --------------------


; Upravi fci COPY_SPRITE2BUFFER tak aby nekreslila za sloupec 31
; MENI: akumulator
SET_MAX_31:
	ld	a,31					;
	ld	(CS2B_SELFMODIFYING_MAXSLOUPEC+1),a
	ld	(CS2B_17VS31+1),a
	ret
	
; --------------------

; Upravi fci COPY_SPRITE2BUFFER tak aby nekreslila za sloupec 17
; MENI: akumulator
SET_MAX_17:
	ld	a,17					;
	ld	(CS2B_SELFMODIFYING_MAXSLOUPEC+1),a
	ld	(CS2B_17VS31+1),a
	ret
 
; --------------------



; Kopirovani spritu do bufferu
; Obrazky se vykresluji po sloupcich, aby slo snadneji kreslit mimo buffer a posouvat tak sprity vlevo a vpravo, i kdyz se tak musi hlidat tretiny...
 
; Vstup:	DE ...adresa hlavicky patternu
;		BC ...b=sloupec {0..17+},c=radek {0..13} souradnice kam ukladat v bufferu, pokud je radek zaporny, tak se kresli zprava doleva

; Buffer je identicky se ZX Screen oblasti
; Sprite obrazek ma na zacatku hlavicku:

;typedef struct
;{252
;    unsigned char	Offset na Pixel data;
;    unsigned char	Pocet_sloupcu_spritu;
;    unsigned char	Pocet_radku_spritu;
;} ZXHeader;
; nasleduje Atribute data jednotlivych znaku ...
; nasleduje pixel data znaku po 8 bajtech ( pripadne 16 pokud znak obsahuje masku )... ( neda se zjistit delka, protoze nektere znaky mohou mit jen atribut )
; znaky jsou ulozeny prednostne dolu po sloupci a pak zpet nahoru a doprava na novy sloupec

; Specialni hodnoty atributu
; atribut = MEZERA:
;	znaci preskoc znak, je to dira v datech, predstavuje to celopruhledny znak
; atribut s PAPER nastaveno na 0:
;	znaci polopruhledny znak, INK je pomoci OR vlozeno na puvodni znak a prepsan INK v atributu ( PAPER hodnota zustava puvodni )
;	INK vzdy prebira BRIGHTNESS puvodni hodnoty ( nikdy neni nastaven v spritu )
; atribut s FLASH:
; 	znaci ze v datech je ulozena i maska kde v masce 1 je PRUHLEDNY ( ( puvodni AND maska ) OR novy )
; 	pokud i PAPER = 0 tak to znamena ze vetsina obrazku je pruhledna, ale ta drobna cast potrebuje zachovat PAPER i kdyby
; 	pod tim byla jednicka (INK), ale protoze je to mensi cast puvodniho znaku tak hodnota barvy zustane puvodni
; Chce to zakazat preruseni protoze SP bude pod 18
 COPY_SPRITE2BUFFER:	; ver 4
    di
    push    IY
    ld      (CS2B_EXIT+1), SP                   ; 20:4 uloz puvodni ukazatel zasobniku	

    ld      A, (DE)                             ; 7:1 Offset_Dat
    add     A, E                                ; 4:1
    ld      L, A                                ; 4:1
    adc     A, D                                ;  
    sub     L                                   ; 4:1
    ld      H, A                                ; 4:1 HL = SPRITE_DATA_ADR = Adresa hlavicky + Offset_Dat
	
	inc	de				; 6:1
	ld	a,(de)				; 7:1 
	ld	iyh,a				; 8:2 Pocet_sloupcu_spritu
	inc	de				; 6:1
	ld	a,(de)				; 7:1 
	ld	ixh,a				; 8:2 Pocet_radku_spritu ( delka sloupce )

	ld	a,c
	xor	$FF				; 7:2 = cpl + set sign flag
	jp	m,CS2B_JAKPISMO
	
; --------------- Zrcadlove vykreslovani
	ld	c,a					; ulozime kladnou verzi
	ld	a,$2D					;  7:2 dec iyl = $FD $2D
	ld	(CS2B_SELF_MIRROR_DEC+1),a		; 13:3
	push	hl					; 11:1
	ld	hl,$18 + 256*SKOK_NA_MASKA_ZRCADLOVE	; 10:3 L = $18 = JR xx
	ld	(CS2B_SELF_LD8_OR_JR_MASKA_ZRC),hl	; 16:3 na adrese bude instrukce "jr CS2B_MASKA_ZRCADLOVE"
	ld	h,SKOK_NA_PREPISOVANI_ZRCADLOVE		;  7:2
	ld	(CS2B_SELF_LD4_OR_JR_PREP_ZRC),hl	; 16:3
	ld	h,SKOK_NA_PRIPISOVANI_ZRCADLOVE		;  7:2
	ld	(CS2B_SELF_LD4_OR_JR_PRIP_ZRC),hl	; 16:3
	ld	h,SKOK_NA_VYMAZANI_ZRCADLOVE		;  7:2
	ld	(CS2B_SELF_LD4_OR_JR_VYMAZ_ZRC),hl	; 16:3
;	ld	hl,CS2B_MASKA_ZRCADLOVE			; 10:3
;	ld	(CS2B_SELF_MIRROR_MASKA+1),hl		; 16:3
;	ld	hl,CS2B_PRIPISOVANI_ZRCADLOVE		; 10:3
;	ld	(CS2B_SELF_MIRROR_PRIPISOVANI+1),hl	; 16:3
;	ld	hl,CS2B_PREPISOVANI_ZRCADLOVE		; 10:3
;	ld	(CS2B_SELF_MIRROR_PREPISOVANI+1),hl	; 16:3
	pop	hl					; 10:1
CS2B_17VS31:
	ld	a,17					;  7:2 Self-modifying
	ld	ixl,a					;  8:2 obsahuje "pocatecni" sloupec { 17,31 } kdyz kreslim zrcadlove jinak 0
	sub	b					;  4:1 Max sloupec bufferu - pocatecni sloupec
	ld	iyl,a					;  8:2 mozna zaporna hodnota poctu sloupcu ktere mam preskocit

	jp	m,CS2B_OREZ_POCATEK_SPRITU		; pokud je zaporne tak jsme vpravo od praveho ohraniceni bufferu

	jr	CS2B_ZACINAME_V_BUFFERU

; --------------- Vykreslovani jak pismo
CS2B_JAKPISMO:

	ld	a,$2C					;  7:2 inc iyl = $FD $2C
	ld	(CS2B_SELF_MIRROR_DEC+1),a		; 13:3
	push	hl					; 11:1 uchovame hl
	ld	hl,$0806				; 10:3
	ld	(CS2B_SELF_LD8_OR_JR_MASKA_ZRC),hl	; 16:3 na adrese bude instrukce "ld b,8"
	ld	h,$02					;  7:2
	ld	(CS2B_SELF_LD4_OR_JR_PREP_ZRC),hl	; 16:3 na adrese bude instrukce "ld b,2"
	ld	(CS2B_SELF_LD4_OR_JR_PRIP_ZRC),hl	; 16:3 na adrese bude instrukce "ld b,2"
	ld	h,$04					;  7:2
	ld	(CS2B_SELF_LD4_OR_JR_VYMAZ_ZRC),hl	; 16:3 na adrese bude instrukce "ld b,4"
	pop	hl					; 10:1 obnovime hl
	
if ( Adr_Attr_Buffer < $8000 )
    .error 'Adresa bufferu obrazovky nema horni bit nastaveny na jednicku!'
endif
	
	bit	7,b					;  8:2 zaporny sloupec?
	ld	iyl,b					;  8:2 vnejsi citac se zapornym sloupcem presunem do pomalejsiho a delsiho "iyl"
	ld	ixl,0					; obsahuje "pocatecni" sloupec = 0 nebo kdyz kreslim zrcadlove { 17,31 }
	jr	z,CS2B_ZACINAME_V_BUFFERU
	

; Prvni sloupec je vlevo ( nebo vpravo pri zrcadlovem zobrazeni ) mimo buffer a nebude zobrazen.  
; Protoze obrazek muze mit diry v datech, nemohu jednoduse posunout index SPRITE_DATA_ADR, jen SPRITE_ATTR_ADR
; VSTUP:
;   IYL zaporna hodnota poctu sloupcu ktere mam preskocit
;   IXL obsahuje "pocatecni" sloupec = 0 nebo kdyz kreslim zrcadlove { 17,31 }
;   IXH pocet radku spritu (vyska)
; VYSTUP:
;   HL =  SPRITE_DATA_ADR bude zvetsen a nastaven na prvni skutecne zobrazeny sloupec
;   DE = SPRITE_ATTR_ADR bude zvetsen a nastaven na prvni skutecne zobrazeny sloupec
;   B = IXL
;   IYL = 0
;   IYH = Pocet_sloupcu_spritu bude zkracen o pocet preskocenych sloupcu

CS2B_OREZ_POCATEK_SPRITU:
    ld      SP, $0008                   ; 10:3 8x microline na znak
CS2B_VYNECH_SLOUPEC:
    ld      B, IXH                      ;  8:2 do vnitrniho a rychleho citace B = vyska
CS2B_DALSI_ATRIBUT:
    inc     DE                          ;  6:1 SPRITE_ATTR_ADR++
    ld      A, (DE)                     ;  7:1 (SPRITE_ATTR_ADR)
    and     %11111000                   ;  7:2 FLASH + BRIGHTNESS + PAPER
    cp      MEZERA                      ;  7:2
    jr      z, CS2B_BEZ_DAT             ; nic tam neni
    add     A, A                        ;  4:1
    jr      nc, CS2B_BEZ_MASKY          ; kladne cislo ( bez flash )
    add     hl, sp                      ; 11:1 hl+=8
CS2B_BEZ_MASKY:
    add     hl, sp                      ; 11:1 hl+=8
CS2B_BEZ_DAT:
    djnz    CS2B_DALSI_ATRIBUT          ; b--
    
    dec     iyh                         ;  8:2 Pocet_sloupcu_spritu-- protoze spritu zbyva o sloupec mene
    jp      z, CS2B_EXIT                ; 10:3
    inc     iyl                         ;  8:2 jsme uz v nultem sloupci?
    jr      nz, CS2B_VYNECH_SLOUPEC
    ld      b, ixl                      ; b ma obsahovat pocatecni sloupec takze 0 nebo kdyz kreslim zrcadlove { 17, 31 }

; ----------- 


; kontrola zda nemame zkratit pocet sloupcu spritu
CS2B_ZACINAME_V_BUFFERU:
	ld	sp,hl			;  6:1 SP = SPRITE_DATA_ADR, DE = SPRITE_ATTR_ADR - 1

	ld	iyl,b			;  8:2 pocatecni sloupec
	ld	a,ixl			;  8:2 obsahuje "pocatecni" sloupec, tzn 0 nebo u zrcadloveho vykresleni {17,31}
	or	a			;  4:1
	jr	z,CS2B_SELFMODIFYING_MAXSLOUPEC
; kreslime vlevo	
	ld	a,b			
	or	a
	jp	m,CS2B_EXIT		; zaciname vlevo od leveho minima ( nuly ) a kreslime doleva takze...
	jr	CS2B_TEST_ZKRACENI_SIRKY; a = pocatecni sloupec, ale jdeme doleva takze i zbyvajici pocet sloupcu - 1
	
CS2B_SELFMODIFYING_MAXSLOUPEC:
	ld	a, $11			;  8:2 {17,31}
	sub	b			;  4:1 max - pocatek < 0? Nezaciname vpravo od maxima a pritom kreslime doprava?
	jp	m,CS2B_EXIT		; 10:3
CS2B_TEST_ZKRACENI_SIRKY:
	inc	a			;  4:1 zbyvajicich sloupcu pocitano od jednicky
	cp	iyh			; - kolik ma sloupcu sprite
	jr	nc,CS2B_NEZKRACUJ
	ld	iyh,a			; zkratime Pocet_sloupcu_spritu
CS2B_NEZKRACUJ:

; do HL BUF_ADR(sloupec, radek)
; http://clanky.1-2-8.net/2009_09_01_archive.html
	ld	a,c				;  4:1 radek
	rrca					;  4:1 rotace vpravo, 07654321 carry = 0
	rrca					;  4:1 rotace vpravo, 10765432 carry = 1
	rrca					;  4:1 rotace vpravo, 21076543 carry = 2
	ld	h,a				;  4:1 docasne ulozime
	and	%11100000			;  7:2
	add	a,b				;  4:1 prictem sloupec
	ld	l,a				;  4:1 priprava pro atributy
	ex	af,af'				;  4:1
	ld	a,c				;  4:1 radek
	
	exx					;  4:1	
	and	%00011000			;  7:2 Nastaveni tretiny obrazovky
CS2B_SELFMODIFYING_ADR_BUFF:
	add	a,Adr_Buffer/256		;  7:2 Horni byte Adr_Buffer 
	ld	(CS2B_SELF_H_SHADOW+1),a	;  13:3 inicializace pro "ld h,n"
	ld	h,a				;  4:1 h' = a
	ex	af,af'				;  4:1
	ld	l,a				;  4:1 HL' = BUFF_DATA_ADR
	ld	iyl,a				;  8:2 iyl = offset prvniho znaku leziciho uvnitr bufferu, potrebujeme pro zacatek dalsiho sloupce
	exx					;  4:1
	 
	ld	a,h				;  4:1 radek >> 3
	and	%00000011			;  7:2
CS2B_SELFMODIFYING_ADR_ATTR_BUFF:
	add	a,Adr_Attr_Buffer/256		;  7:2
	ld	h,a				;  4:1  HL = BUFF_ATTR_ADR
	ld	(CS2B_SELF_H+1),a		; 13:3 inicializace pro "ld h,n"


    ld      B, IYH                  ; 8:2  Pocet_sloupcu_spritu
    ld      IXL, IXH                ; 8:2  Pocet_radku_spritu ( delka sloupce )

; -------------- konec inicializaci
; aktualne
;	de = SPRITE_ATTR_ADR-1 
;	b  = Pocet_sloupcu_spritu
;	b'c' = volne, pouzito pro "pop bc"

; mapa registru

;	ixh = ixl = Pocet_radku_spritu ( delka sloupce )
;	iyl = offset prvniho znaku leziciho uvnitr bufferu

;	sp = SPRITE_DATA_ADR
;	hl' = BUFF_DATA_ADR
;	kopirujeme hl' <- sp

;	de = SPRITE_ATTR_ADR
;	hl = BUFF_ATTR_ADR
;	kopirujeme hl <- de	


	jp	CS2B_POCATEK	;

; -------------------------------
; Kopirovani znaku do bufferu pomoci masky ( nulove bity smazou puvodni ) a nasledne OR s novym
CS2B_MASKA:
    add     A, A                ; 7:2 odstranime FLASH, zbude jen 2xPAPER
    ld      A, C                ; 7:1
    jr      nz, CS2B_MASKA_NEZACHOVAT_PAPER
  
    xor     (HL)                ; 7:1 (BUF_ATTR_ADR)
    and     %00000111           ; 7:2 old FLASH + old BRIGHTNESS + old PAPER + new INK
    xor     (HL)                ; 7:1 (BUF_ATTR_ADR)
CS2B_MASKA_NEZACHOVAT_PAPER:
    and     $7f                 ; 7:2 zrusime FLASH
    ld      (HL), A             ; 7:1 (BUF_ATTR_ADR) ulozime novy atribut bez flash ( ale mozna s puvodnim PAPER ) 

    exx                         ; 4:1

CS2B_SELF_LD8_OR_JR_MASKA_ZRC:
    ld      b, $08              ; ?:2 Self-modifying, je tu bud "ld b,8" nebo "jr CS2B_MASKA_ZRCADLOVE"

CS2B_MASKA_LOOP
    pop     de                  ; 10:1
    ld      a, (hl)             ; 7:1 (BUFF_DATA_ADR)
    and     e                   ; 4:1 vynulujeme misto kam budeme kreslit novy znak
    or      d                   ; 4:1 pridame novy znak
    ld      (hl), a             ; 7:1 (BUFF_DATA_ADR)
    inc     h                   ; 4:1
    djnz    CS2B_MASKA_LOOP
    
    jr      CS2B_DOLU           ; 12:2

;------------------------------------
CS2B_MASKA_ZRCADLOVE:
    ex      de, hl              ;  4:1
    ld      b, $08              ;  7:2
CS2B_MASKA_ZRCADLOVE_LOOP:
    pop     hl                  ; 10:1
    ld      a, (de)             ;  7:1 (BUFF_DATA_ADR)
    ld      c, h                ;  4:1
    ld      h, ZRCADLOVY/256    ;  7:2    
    and     (hl)                ;  7:1 vynulujeme misto kam budeme kreslit novy znak
    ld      l, c                ;  4:1
    or      (hl)                ;  7:1 pridame novy znak
    ld      (de), a             ;  7:1 (BUFF_DATA_ADR)
    inc     d                   ;  4:1
    djnz    CS2B_MASKA_ZRCADLOVE_LOOP

    ex      de, hl              ;  4:1
    jr      CS2B_DOLU           ; 12:2

;-------------------------------

CS2B_PRVNI_RADEK:                   ; jsme ve stinovych registrech
CS2B_SELF_H_SHADOW:
    ld      h, $00                  ; 7:2 self-modifying code, navrat na prvni radek
    ld      ixl, ixh                ; 8:2 obnovime citac pro Pocet_radku_spritu ( delka sloupce )
CS2B_SELF_MIRROR_DEC:
    inc     iyl                     ; 8:2 o znak vpravo ( vlevo u zrcadloveho kresleni )
    ld      a, iyl                  ; 8:2 offset znaku na prvnim radku
    ld      l, a                    ; 4:1 l' = offset znaku na prvnim radku

    exx
CS2B_SELF_H:
    ld      h, $00                  ; self-modifying code hl = BUF_ATTR_ADR prvniho radku
    ld      l, a
    djnz    CS2B_POCATEK            ; b = zbyvajici Pocet_sloupcu_spritu

CS2B_EXIT:
    ld      sp, $0000               ; self-modifying code
    pop     iy
    ei
    ret

CS2B_TRETINA:
    exx                             ; navrat z Jeho Bozskeho Stinu
    inc     h                       ; 4:1  hl++ == BUF_ATTR_ADR += 256
    jr      CS2B_ATTR_NEXT

CS2B_CELOPRUHLEDNY:
    exx                             ; Dira v datech, cely znak je pruhledny
    ld      a, h
    add     a, $08                  ; simulace kopirovani
    ld      h, a

; ----------------------------------
CS2B_DOLU:
    dec     ixl                     ; 8:2 snizime pocitadlo znaku v sloupci
    jr      z, CS2B_PRVNI_RADEK     ; 12/7:2 
CS2B_O_ZNAK_NIZE:                   ; jsme ve stinovych registrech	

    ld      a, $20                  ; A = 32
    add     a, l
    ld      l, a                    ; 4:1 l'+=32 == BUFF_DATA_ADR+=32

    jr      c, CS2B_TRETINA         ; skok pokud jsme v dalsi tretine
    ld      a, h
    sub     $08                     ; 
    ld      h, a                    ; 4:1 h'-=8 == BUFF_DATA_ADR-=8*256
    ld      a, l
    exx

CS2B_ATTR_NEXT:
    ld      l, a                    ; l+=32 == BUF_ATTR_ADR += 32
    
; ----------------------------------
; Cast vetvici kopirovani znaku podle typu atributu na prepisovani, pripisovani, a oboji s pomoci masky
CS2B_POCATEK:

    inc     DE                      ; 6:1 DE++ = SPRITE_ATTR_ADR++
    ld      A, (DE)                 ; 7:1 (SPRITE_ATTR_ADR)
    ld      C, A                    ; 4:1
    and     %10111000               ; FLASH + PAPER
    jr      z, CS2B_PRIPISOVANI     ; PAPER = black
    jp      m, CS2B_MASKA

; ----------------------------------
; nepruhledne = prepisovani
    ld      (HL), C                 ; 7:1 (BUF_ATTR_ADR)
    exx                             ; 4:1

CS2B_SELF_LD4_OR_JR_PREP_ZRC:
    ld      B, $02                  ; ?:2 Self-modifying je tu bud "ld b,4" nebo "jr CS2B_PREPISOVANI_ZRCADLOVE"

CS2B_PREPISOVANI_LOOP:
    pop     DE                      ; 10:1
    ld      (HL), E                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      (HL), D                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    pop     DE                      ; 10:1
    ld      (HL), E                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    ld      (HL), D                 ;  7:1 (BUFF_DATA_ADR)
    inc     H                       ;  4:1
    djnz    CS2B_PREPISOVANI_LOOP
    ; kvuli zrychleni o 5 taktu duplicitni kod
    dec     ixl                     ; 8:2 snizime pocitadlo znaku v sloupci
    jp      nz, CS2B_O_ZNAK_NIZE    ; 10:3
    jp      CS2B_PRVNI_RADEK        ; 10:3 

; ----------------------------------
CS2B_PREPISOVANI_ZRCADLOVE:
    ld      B, $02                  ;  7:2

CS2B_PREPISOVANI_ZRCADLOVE_LOOP:
    pop     de                      ; 10:1
    ld      c, d                    ;  4:1
    ld      d, ZRCADLOVY/256        ;  7:2
    ld      a, (de)                 ;  7:1
    ld      (hl), a                 ;  7:1 (BUFF_DATA_ADR)
    inc     h                       ;  4:1
    ld      e, c                    ;  4:1
    ld      a, (de)                 ;  7:1
    ld      (hl), a                 ;  7:1 (BUFF_DATA_ADR)
    inc     h                       ;  4:1
    pop     de                      ; 10:1
    ld      c, d                    ;  4:1
    ld      d, ZRCADLOVY/256        ;  7:2
    ld      a, (de)                 ;  7:1
    ld      (hl), a                 ;  7:1 (BUFF_DATA_ADR)
    inc     h                       ;  4:1
    ld      e, c                    ;  4:1
    ld      a, (de)                 ;  7:1
    ld      (hl), a                 ;  7:1 (BUFF_DATA_ADR)
    inc     h                       ;  4:1
    djnz    CS2B_PREPISOVANI_ZRCADLOVE_LOOP
    ; kvuli zrychleni o 5 taktu duplicitni kod
    dec     ixl                     ; 8:2 snizime pocitadlo znaku v sloupci
    jp      nz, CS2B_O_ZNAK_NIZE    ; 10:3
    jp      CS2B_PRVNI_RADEK        ; 10:3

; -------------------------------
; Kopirovani znaku do bufferu metodou stare OR nove
; PAPER ve spritu je nulovy (cerny), je to znameni ze je pruhledny a bude ignorovan
CS2B_PRIPISOVANI:

; Test kolize novy INK == puvodni PAPER  
    ld      A, C                ;  4:1 (SPRITE_ATTR_ADR)
    add     A, A                ;  4:1
if ( MEZERA != $40 )
    .error 'Zmenit kod, MEZERA != $.1000...!'
endif
    add     A, A                ;  4:1
    jr      c, CS2B_CELOPRUHLEDNY    
    add     A, A                ;  4:1 INK -> PAPER
    xor     (HL)                ;  7:1 (BUF_ATTR_ADR)
    and     %00111000           ;  7:2 
    jr      z, CS2B_VYMAZANI    ; novy INK je shodny s puvodnim PAPER, takze jen vymazavam puvodni INK

    ld      A, (HL)             ; 7:1 (BUF_ATTR_ADR)
    and     %11111000           ; 7:2
    or      C                   ; 4:1
    ld      (HL), A             ; 7:1 (BUF_ATTR_ADR) zachovame puvodni hodnotu PAPER a BRIGHT

    exx

CS2B_SELF_LD4_OR_JR_PRIP_ZRC:
    ld      B, $02              ; ?:2 Self-modifying je zde bud "ld b,4" nebo "jr CS2B_PRIPISOVANI_ZRCADLOVE"

CS2B_PRIPISOVANI_LOOP:
    pop     DE                  ; 10:1
    ld      A, (HL)             ; 7:1 (BUFF_DATA_ADR)
    or      E                   ; 4:1
    ld      (HL), A             ; 7:1 (BUFF_DATA_ADR)
    inc     H                   ; 4:1
    ld      A, (HL)             ; 7:1 (BUFF_DATA_ADR)
    or      D                   ; 4:1
    ld      (HL), A             ; 7:1 (BUFF_DATA_ADR)
    inc     H                   ; 4:1
    pop     DE                  ; 10:1
    ld      A, (HL)             ; 7:1 (BUFF_DATA_ADR)
    or      E                   ; 4:1
    ld      (HL), A             ; 7:1 (BUFF_DATA_ADR)
    inc     H                   ; 4:1
    ld      A, (HL)             ; 7:1 (BUFF_DATA_ADR)
    or      D                   ; 4:1
    ld      (HL), A             ; 7:1 (BUFF_DATA_ADR)
    inc     H                   ; 4:1
    djnz    CS2B_PRIPISOVANI_LOOP

    ; kvuli zrychleni o 5 taktu duplicitni kod
    dec     ixl                     ; 8:2 snizime pocitadlo znaku v sloupci
    jp      nz, CS2B_O_ZNAK_NIZE    ; 10:3
    jp      CS2B_PRVNI_RADEK        ; 10:3 

; ---------------------------------
CS2B_PRIPISOVANI_ZRCADLOVE:
    ld      B, $02

CS2B_PRIPISOVANI_ZRCADLOVE_LOOP:
    pop     DE                  ; 10:1
    ld      C, D                ;  4:1
    ld      D, ZRCADLOVY/256    ;  7:2
    ld      A, (DE)             ;  7:1 zrcadleny sprite
    or      (HL)                ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A             ;  7:1 (BUFF_DATA_ADR)
    inc     H                   ;  4:1
    ld      E, C                ;  4:1 
    ld      A, (DE)             ;  7:1 zrcadleny sprite
    or      (HL)                ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A             ;  7:1 (BUFF_DATA_ADR)
    inc     H                   ;  4:1
    pop     DE                  ; 10:1
    ld      C, D                ;  4:1
    ld      D, ZRCADLOVY/256    ;  7:2
    ld      A, (DE)             ;  7:1 zrcadleny sprite
    or      (HL)                ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A             ;  7:1 (BUFF_DATA_ADR)
    inc     H                   ;  4:1
    ld      E, C                ;  4:1 
    ld      A, (DE)             ;  7:1 zrcadleny sprite
    or      (HL)                ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A             ;  7:1 (BUFF_DATA_ADR)
    inc     H                   ;  4:1
    djnz    CS2B_PRIPISOVANI_ZRCADLOVE_LOOP
    ; kvuli zrychleni o 5 taktu duplicitni kod
    dec     ixl                     ; 8:2 snizime pocitadlo znaku v sloupci
    jp      nz, CS2B_O_ZNAK_NIZE    ; 10:3
    jp      CS2B_PRVNI_RADEK        ; 10:3 

; ---------------------------------------------------------
; novy INK je shodny s puvodnim PAPER, takze jen vymazavam puvodni INK
; ld   A, E        ld   A, E
; cpl              or   (HL)
; and  (HL)        xor  E
; ld   (HL), A     ld   (HL),A

CS2B_VYMAZANI:
    exx
CS2B_SELF_LD4_OR_JR_VYMAZ_ZRC:
    ld      B, $04              ; ?:2 Self-modifying je zde bud "ld b,4" nebo "jr CS2B_VYMAZANI_ZRCADLOVE"

CS2B_VYMAZANI_LOOP:
    pop     DE                  ; 10:1
    ld      A, E                ;  4:1
    cpl                         ;  4:1 inverze bitu
    and     (HL)                ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A             ;  7:1 (BUFF_DATA_ADR)
    inc     H                   ;  4:1
    ld      A, D                ;  4:1
    cpl                         ;  4:1 inverze bitu
    and     (HL)                ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A             ;  7:1 (BUFF_DATA_ADR)
    inc     H                   ;  4:1 = 62 / 2 = 31 T/byte
    djnz    CS2B_VYMAZANI_LOOP
    
    jp      CS2B_DOLU           ; 10:3 

; ---------------------------------
CS2B_VYMAZANI_ZRCADLOVE:
    ld      B, $04              ;  7:2
CS2B_VYMAZANI_ZRCADLOVE_LOOP:
    pop     DE                  ; 10:1
    ld      C, D                ;  4:1
    ld      D, ZRCADLOVY/256    ;  7:2
    ld      A, (DE)             ;  7:1 zrcadleny sprite
    cpl                         ;  4:1
    and     (HL)                ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A             ;  7:1 (BUFF_DATA_ADR)
    inc     H                   ;  4:1
    ld      E, C                ;  4:1 
    ld      A, (DE)             ;  7:1 zrcadleny sprite
    cpl                         ;  4:1
    and     (HL)                ;  7:1 (BUFF_DATA_ADR)
    ld      (HL), A             ;  7:1 (BUFF_DATA_ADR)
    inc     H                   ;  4:1
    djnz    CS2B_VYMAZANI_ZRCADLOVE_LOOP

    jp      CS2B_DOLU           ; 10:3 

; ==========================================================================================

; zjisteni relativniho ofsetu
SKOK_NA_MASKA_ZRCADLOVE         equ     ( CS2B_MASKA_ZRCADLOVE       - CS2B_SELF_LD8_OR_JR_MASKA_ZRC - 2 )
SKOK_NA_PREPISOVANI_ZRCADLOVE   equ     ( CS2B_PREPISOVANI_ZRCADLOVE - CS2B_SELF_LD4_OR_JR_PREP_ZRC  - 2 )
SKOK_NA_PRIPISOVANI_ZRCADLOVE   equ     ( CS2B_PRIPISOVANI_ZRCADLOVE - CS2B_SELF_LD4_OR_JR_PRIP_ZRC  - 2 )
SKOK_NA_VYMAZANI_ZRCADLOVE      equ     ( CS2B_VYMAZANI_ZRCADLOVE    - CS2B_SELF_LD4_OR_JR_VYMAZ_ZRC - 2 )

if ( SKOK_NA_MASKA_ZRCADLOVE > 128 )
  .error 'Hodnota relativniho skoku na CS2B_MASKA_ZRCADLOVE mimo povoleny rozsah!'
endif
if ( SKOK_NA_PREPISOVANI_ZRCADLOVE > 128 )
  .error 'Hodnota relativniho skoku na CS2B_PREPISOVANI_ZRCADLOVE mimo povoleny rozsah!'
endif
if ( SKOK_NA_PRIPISOVANI_ZRCADLOVE > 128 )
  .error 'Hodnota relativniho skoku na CS2B_PRIPISOVANI_ZRCADLOVE mimo povoleny rozsah!'
endif
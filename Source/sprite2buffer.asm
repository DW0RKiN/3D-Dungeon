


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

MEZERA		equ	$3F

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
 
	push	iy
	ld	(CS2B_EXIT+1),sp		; 20:4 uloz puvodni ukazatel zasobniku	

	ld	a,(de)				; 7:1 Offset_Dat
	add	a,e				; 4:1
	ld	l,a				; 4:1
	ld	a,d				; 4:1
	adc	a,0				; 7:2 +1?
	ld	h,a				; 4:1 hl = SPRITE_DATA_ADR = Adresa hlavicky + Offset_Dat
	
	inc	de				; 6:1
	ld	a,(de)				; 7:1 
	ld	iyh,a				; 8:2 Pocet_sloupcu_spritu
	inc	de				; 6:1
	ld	a,(de)				; 7:1 
	ld	ixh,a				; 8:2 Pocet_radku_spritu ( delka sloupce )

	ld	a,c
	xor	$FF				; 7:2 = cpl 4:1 ale nenastavuje priznaky..
	jp	m,CS2B_JAKPISMO
	
; --------------- Zrcadlove vykreslovani
	ld	c,a					; ulozime kladnou verzi
	ld	a,$2D					;  7:2 dec iyl = $FD $2D
	ld	(CS2B_SELF_MIRROR_DEC+1),a		; 13:3
	push	hl					; 11:1
	ld	hl,$18 + 256*SKOK_NA_MASKA_ZRCADLOVE	; 10:3
	ld	(CS2B_SELF_LD8_OR_JR_MASKA_ZRC),hl	; 16:3 na adrese bude instrukce "jr CS2B_MASKA_ZRCADLOVE"
	ld	h,SKOK_NA_PREPISOVANI_ZRCADLOVE		;  7:2
	ld	(CS2B_SELF_LD4_OR_JR_PREP_ZRC),hl	; 16:3
	ld	h,SKOK_NA_PRIPISOVANI_ZRCADLOVE		;  7:2
	ld	(CS2B_SELF_LD4_OR_JR_PRIP_ZRC),hl	; 16:3
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
	ld	h,$04					;  7:2
	ld	(CS2B_SELF_LD4_OR_JR_PREP_ZRC),hl	; 16:3 na adrese bude instrukce "ld b,4"
	ld	(CS2B_SELF_LD4_OR_JR_PRIP_ZRC),hl	; 16:3 na adrese bude instrukce "ld b,4"
	pop	hl					; 10:1 obnovime hl
	
;	push	hl					; 11:1
;	ld	hl,CS2B_SELF_MIRROR_MASKA+3		; 10:3
;	ld	(CS2B_SELF_MIRROR_MASKA+1),hl		; 16:3
;	ld	hl,CS2B_SELF_MIRROR_PRIPISOVANI+3	; 10:3
;	ld	(CS2B_SELF_MIRROR_PRIPISOVANI+1),hl	; 16:3
;	ld	hl,CS2B_SELF_MIRROR_PREPISOVANI+3	; 10:3
;	ld	(CS2B_SELF_MIRROR_PREPISOVANI+1),hl	; 16:3	
;	pop	hl					; 10:1
	
	bit	7,b					;  8:2 zaporny sloupec?
	ld	iyl,b					;  8:2 vnejsi citac se zapornym sloupcem presunem do pomalejsiho a delsiho "iyl"
	ld	ixl,0					; obsahuje "pocatecni" sloupec = 0 nebo kdyz kreslim zrcadlove { 17,31 }
	jr	z,CS2B_ZACINAME_V_BUFFERU
	

; Prvni sloupec je vlevo ( nebo vpravo pri zrcadlovem zobrazeni ) mimo buffer a nebude zobrazen.  
; Protoze obrazek muze mit diry v datech, nemohu jednoduse posunout index SPRITE_DATA_ADR, jen SPRITE_ATTR_ADR
; VSTUP:	iyl zaporna hodnota poctu sloupcu ktere mam preskocit
;		ixl hodnota kterou ma obsahovat "b" na vystupu {0,17}
; VYSTUP:	"b" bude nastavena na nula nebo max. buff. {17,31}
;         	"iyh" = Pocet_sloupcu_spritu bude zkracen o pocet preskocenych sloupcu
;		hl =  SPRITE_DATA_ADR bude zvetsen a nastaven na prvni skutecne zobrazeny sloupec
;		de = SPRITE_ATTR_ADR bude zvetsen a nastaven na prvni skutecne zobrazeny sloupec

CS2B_OREZ_POCATEK_SPRITU:
	ld	sp,8			; 10:3 8x microline na znak
CS2B_VYNECH_SLOUPEC:
	ld	b,ixh			;  8:2 do vnitrniho a rychleho citace "b" = Pocet_radku_spritu ( delka sloupce )
CS2B_DALSI_ATRIBUT:
	inc	de			;  6:1 SPRITE_ATTR_ADR++
	ld	a,(de)			;  7:1 (SPRITE_ATTR_ADR)
	cp	MEZERA			;  7:2
	jr	z,CS2B_ODECTI_ZNAK	; dira v datech, cely znak je pruhledny
	or	a			;  4:1
	jp	p,CS2B_BEZ_MASKY	; kladne cislo ( bez flash )
	add	hl,sp			; 11:1 hl+=8
CS2B_BEZ_MASKY:
	add	hl,sp			; 11:1 hl+=8
CS2B_ODECTI_ZNAK
	djnz	CS2B_DALSI_ATRIBUT	; b--
	dec	iyh			;  8:2 Pocet_sloupcu_spritu-- protoze spritu zbyva o sloupec mene
 	jp	z,CS2B_EXIT		; 10:3
	inc	iyl			;  8:2 jsme uz v nultem sloupci?
	jr	nz, CS2B_VYNECH_SLOUPEC
	ld	b,ixl			; b ma obsahovat pocatecni sloupec takze 0 nebo kdyz kreslim zrcadlove { 17, 31 }
	
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
	ld	a,17			;  8:2 {17,31}
	sub	iyl			;  4:1 max - pocatek < 0? Nezaciname vpravo od maxima a pritom kreslime doprava?
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


	ld	b,iyh		; 8:2  Pocet_sloupcu_spritu
	ld	ixl,ixh		; 8:2  Pocet_radku_spritu ( delka sloupce )

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
	and	$7f		; 7:2 zrusime FLASH
	ld	c,a		; 4:1 c = Novy atribut bez FLASH
	and 	%00111000	; test bitu pro PAPER
	ld	a,c
	jr	nz, CS2B_MASKA_NEZACHOVAT_PAPER

	ld	a,(hl)		; 7:1 (BUF_ATTR_ADR)
	and	%01111000	; 7:2 smazat vse az na puvodni PAPER a BRIGHTNESS
	or	c		; 4:1
CS2B_MASKA_NEZACHOVAT_PAPER:
	ld	(hl),a		; 7:1 (BUF_ATTR_ADR) ulozime novy atribut bez flash ( ale mozna s puvodnim PAPER ) 

	exx			; 4:1
	
	
CS2B_SELF_LD8_OR_JR_MASKA_ZRC:
	ld	b,8		; ?:2 Self-modifying, je tu bud "ld b,8" nebo "jr CS2B_MASKA_ZRCADLOVE"
	
CS2B_MASKA_LOOP
	pop	de		; 10:1
	ld	a,(hl)		; 7:1 (BUFF_DATA_ADR)
	and	e		; 4:1 vynulujeme misto kam budeme kreslit novy znak
	or	d		; 4:1 pridame novy znak
	ld	(hl), a		; 7:1 (BUFF_DATA_ADR)
	inc	h		; 4:1
	djnz	CS2B_MASKA_LOOP
	
	jr	CS2B_O_ZNAK_NIZE	; 12:2

;------------------------------------
CS2B_MASKA_ZRCADLOVE:
	ex	de,hl		;  4:1
	ld	h,ZRCADLOVY/256
	ld	iyh,8
	
CS2B_MASKA_ZRCADLOVE_LOOP:
	pop	bc		; 10:1
	ld	a,(de)		;  7:1 (BUFF_DATA_ADR)
	ld	l,c		;  4:1
	and	(hl)		;  7:1 vynulujeme misto kam budeme kreslit novy znak
	ld	l,b		;  4:1
	or	(hl)		;  7:1 pridame novy znak
	ld	(de), a		;  7:1 (BUFF_DATA_ADR)
	inc	d		;  4:1
				; 50:7
	dec	iyh
	jr	nz,CS2B_MASKA_ZRCADLOVE_LOOP
	
	ex	de,hl		;  4:1
	jr	CS2B_O_ZNAK_NIZE	; 12:2

;-------------------------------
	
CS2B_PRVNI_RADEK:		; jsme ve stinovych registrech
CS2B_SELF_H_SHADOW:
	ld	h,0		; 4:1 self-modifying code,  navrat na prvni radek
	ld	ixl,ixh		; 8:2 obnovime citac pro Pocet_radku_spritu ( delka sloupce )
CS2B_SELF_MIRROR_DEC:
	inc	iyl		; 8:2 o znak vpravo ( vlevo u zrcadloveho kresleni )
	ld	a,iyl		; 8:2 offset znaku na prvnim radku
	ld	l,a		; 4:1 l' = offset znaku na prvnim radku

	exx
CS2B_SELF_H:
	ld	h,0		; self-modifying code hl = BUF_ATTR_ADR prvniho radku
	ld	l,a
	djnz	CS2B_POCATEK	; b = zbyvajici Pocet_sloupcu_spritu
	
CS2B_EXIT:
	ld	sp,0		; self-modifying code
	pop	iy
	ret

CS2B_O_ZNAK_NIZE:			; jsme ve stinovych registrech	
	dec	ixl			; 8:2	snizime pocitadlo znaku v sloupci
	jr	z,CS2B_PRVNI_RADEK	; 12/7:2 

	ld	a,32
	add	a,l
	ld	l,a		; 4:1 l'+=32 == BUFF_DATA_ADR+=32
		
	jr	c,CS2B_TRETINA	; skok pokud jsme v dalsi tretine
	ld	a,h
	sub	8		; 
	ld	h,a		; 4:1 h'-=8 == BUFF_DATA_ADR-=8*256
	ld	a,l
	exx
	jp	CS2B_ATTR_NEXT
	
CS2B_TRETINA:
	exx			; navrat z Jeho Bozskeho Stinu
	inc	h		; 4:1  hl++ == BUF_ATTR_ADR += 256
CS2B_ATTR_NEXT:
	ld	l,a		; l+=32 == BUF_ATTR_ADR += 32
CS2B_POCATEK:

	inc	de		; 6:1 de++ = SPRITE_ATTR_ADR++

; --- cast vetvici kopirovani znaku podle typu atributu na prepisovani, pripisovani, a oboji s pomoci masky

	ld	a,(de)			; 7:1 (SPRITE_ATTR_ADR)
	
	cp	MEZERA			; 4:1
	jr	nz,CS2B_NENI_DIRA	
	exx				; Dira v datech, cely znak je pruhledny
	ld	a,h
	add	a,8			; simulace kopirovani
	ld	h,a
	jr	CS2B_O_ZNAK_NIZE	; 12:2

CS2B_NENI_DIRA:

	or	a
	jp	m,CS2B_MASKA

	ld	c,a		; 4:1 c = Novy atribut
	and 	%00111000	; bity pro PAPER
	jr	z, CS2B_PRIPISOVANI


; -------------------------------
; nepruhledne = prepisovani
	ld	(hl),c		; 7:1 (BUF_ATTR_ADR)
	exx			; 4:1

; ----------------------------------

CS2B_SELF_LD4_OR_JR_PREP_ZRC:
	ld	b,4		; ?:2 Self-modifying je tu bud "ld b,4" nebo "jr CS2B_PREPISOVANI_ZRCADLOVE"
	
CS2B_PREPISOVANI_LOOP:
	pop	de		; 10:1
	ld	(hl), e		; 7:1 (BUFF_DATA_ADR)
	inc	h		; 4:1
	ld	(hl), d		; 7:1 (BUFF_DATA_ADR)
	inc	h		; 4:1 = 32 / 2 = 16T/byte
	djnz	CS2B_PREPISOVANI_LOOP
	
	jr	CS2B_O_ZNAK_NIZE	; 12:2

; ----------------------------------
CS2B_PREPISOVANI_ZRCADLOVE:
	ld	d,ZRCADLOVY/256
	ld	iyh,4

CS2B_PREPISOVANI_ZRCADLOVE_LOOP:
	pop	bc		; 10:1
	ld	e,c		; 4:1
	ld	a,(de)		; 7:1
	ld	(hl), a		; 7:1 (BUFF_DATA_ADR)
	inc	h		; 4:1
	
	ld	e,b		; 4:1
	ld	a,(de)		; 7:1
	ld	(hl), a		; 7:1 (BUFF_DATA_ADR)
	inc	h		; 4:1
				; 25T/byte:4B/byte
	dec	iyh
	jr	nz,CS2B_PREPISOVANI_ZRCADLOVE_LOOP

	jr	CS2B_O_ZNAK_NIZE	; 12:2




; ==========================================================================================

; -------------------------------
; Kopirovani znaku do bufferu metodou stare OR nove
; cerny PAPER je bran jako pruhledny
CS2B_PRIPISOVANI:
; 	ld	a,c
; 	and	%00000111	; mazani BRIGHTNESS
; 	ld	c,a		; vyreseno uz v datech

	ld	a,(hl)		; 7:1 (BUF_ATTR_ADR)
	and	%11111000	; 7:2
	or	c		; 4:1
	ld	(hl),a		; 7:1 (BUF_ATTR_ADR) zachovame puvodni hodnotu PAPER a BRIGHT

	exx

CS2B_SELF_LD4_OR_JR_PRIP_ZRC:
	ld	b,4		; ?:2 Self-modifying je zde bud "ld b,4" nebo "jr CS2B_PRIPISOVANI_ZRCADLOVE"

CS2B_PRIPISOVANI_LOOP:
	pop	de		; 10:1
	ld	a,(hl)		; 7:1 (BUFF_DATA_ADR)
	or	e		; 4:1
	ld	(hl), a		; 7:1 (BUFF_DATA_ADR)
	inc	h		; 4:1
	ld	a,(hl)		; 7:1 (BUFF_DATA_ADR)
	or	d		; 4:1
	ld	(hl), a		; 7:1 (BUFF_DATA_ADR)
	inc	h		; 4:1 = 54 / 2 = 27T/byte
  
	djnz	CS2B_PRIPISOVANI_LOOP

	jp	CS2B_O_ZNAK_NIZE	; 12:2 

; ---------------------------------
CS2B_PRIPISOVANI_ZRCADLOVE:
	ld	d,ZRCADLOVY/256
	ld	iyh,4
	
CS2B_PRIPISOVANI_ZRCADLOVE_LOOP:
	pop	bc		; 10:1
	ld	e,c		;  4:1
	ld	a,(de)		;  7:1 zrcadleny sprite
	or	(hl)		;  7:1 (BUFF_DATA_ADR)
	ld	(hl), a		;  7:1 (BUFF_DATA_ADR)
	
	inc	h		;  4:1
	ld	e,b		;  4:1 
	ld	a,(de)		;  7:1 zrcadleny sprite
	or	(hl)		;  7:1 (BUFF_DATA_ADR)
	ld	(hl), a		;  7:1 (BUFF_DATA_ADR)
	inc	h		;  4:1 = 68 / 2 = 34T/byte
	
	dec	iyh
	jr	nz,CS2B_PRIPISOVANI_ZRCADLOVE_LOOP

	jp	CS2B_O_ZNAK_NIZE	; 12:2 
	
; ==========================================================================================

SKOK_NA_MASKA_ZRCADLOVE      equ   ( CS2B_MASKA_ZRCADLOVE       - CS2B_SELF_LD8_OR_JR_MASKA_ZRC - 2 )
SKOK_NA_PREPISOVANI_ZRCADLOVE   equ   ( CS2B_PREPISOVANI_ZRCADLOVE - CS2B_SELF_LD4_OR_JR_PREP_ZRC  - 2 )
SKOK_NA_PRIPISOVANI_ZRCADLOVE   equ   ( CS2B_PRIPISOVANI_ZRCADLOVE - CS2B_SELF_LD4_OR_JR_PRIP_ZRC  - 2 )

if ( SKOK_NA_MASKA_ZRCADLOVE > 128 )
  .error 'Hodnota relativniho skoku na CS2B_MASKA_ZRCADLOVE mimo povoleny rozsah!'
endif
if ( SKOK_NA_PREPISOVANI_ZRCADLOVE > 128 )
  .error 'Hodnota relativniho skoku na CS2B_PREPISOVANI_ZRCADLOVE mimo povoleny rozsah!'
endif
if ( SKOK_NA_PRIPISOVANI_ZRCADLOVE > 128 )
  .error 'Hodnota relativniho skoku na CS2B_PRIPISOVANI_ZRCADLOVE mimo povoleny rozsah!'
endif
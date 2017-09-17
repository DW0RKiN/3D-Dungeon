progStart  	equ	$C400	; 50176
spritesStart  	equ	$5F00	; 


org spritesStart

INCBIN grafika.bin
; INCLUDE grafika_v_0_6.asm

org	progStart

; volna pamet 0x5E00+

pismoStart		equ	$E100	; za tim je hned buffer ( konec $E244 )
Adr_Buffer:		equ	$E300	; 
Adr_Attr_Buffer:	equ	$FB00	; 
; Buff_End	equ	$FEFF

; 256 bajtu
INCLUDE zrcadlovy.h
; 16x16 bajtu
INCLUDE	map.h


dopredu	equ	0
dozadu	equ	4
vlevo	equ	8
vpravo	equ	12

stisknuto_dopredu	equ	0
stisknuto_dozadu	equ	1
stisknuto_vlevo		equ	2
stisknuto_vpravo	equ	3


VEKTORY_POHYBU:		; musi byt na adrese delitelne 256
;	N	E	S	W
defb	-sirka,	+1,	+sirka,	-1	;  0 dopredu
defb	+sirka,	-1,	-sirka,	+1	;  4 dozadu
defb	-1,	-sirka,	+1,	+sirka	;  8 vlevo
defb	+1,	+sirka,	-1,	-sirka	; 12 vpravo

	
if (VEKTORY_POHYBU % 256) != ( 0 )
    .error 'Seznam VEKTORY_POHYBU nezacina na offsetu nula!'
endif


north		equ	0
east		equ	1
south		equ	2
west		equ	3



;----------- Vazane promnene kvuli optimalizacim ( ale nic zasadniho v nejake kriticke casti )
LOCATION:
defb	52	; musi byt pred VECTOR! kvuli optimalizaci ld hl,(VECTOR) ; 16:3 l=LOCATION, h=VECTOR
VECTOR:
defb	north	; 0 = N,1 = E,2 = S,3 = W 
POHYB:
defb	0	; nulty bit meni hodnotu pokazde pri otoceni nebo pohybu ( resi se to pres rychle inc(hl)  = pocitadlo pohybu/otoceni )
		; pouziva se pro zmenu podlahy, pocit zmeny pri stejnych stenach
;-----------


PRIZNAK_OTEVRENY_INVENTAR	equ	1

PRIZNAKY:
defb	0

INCLUDE sprites.h

; Pokud se da cokoliv dalsiho nad MAIN tak to zmeni adresu vstupniho bodu!!!

MAIN:			; $CA13   randomize usr 51731
	call	PUSH_ALL

	di			;c617	f3
	im	1		;c618	ed 56
	ei			;c61a	fb
	ld	a,12		;c61b	3e 0c
	ld	hl,$5c09	;c61d	21 09 5c = 23561
	ld	(hl),a		;c620	77 POKE 23561,xx ( cas prodlevy autorepeat )
	dec	l		;c621	2d = 23560 = LAST K system variable
	ld	(hl),0		;c622	36 00 put null value there
	
	call	HELP
	call	PLAYERS_WINDOW
MAIN_LOOP:
	di
	call	VIEW
	ei
	call	COPY_VYREZ2SCREEN
	call	TEST_OTEVRENY_INVENTAR
	jr	nz,MAIN_OTEVRENY_INVENTAR
	call	PLAYERS_WINDOW_AND_DAMAGE
MAIN_OTEVRENY_INVENTAR:

	call	COPY_INVENTORY2SCREEN
	ld	a,24
 	call	AKTUALIZUJ_SIPKY	; VSTUP: a = 0 dopredu, 4 dozadu , 8 vlevo, 12 vpravo, 16 otoceni doleva, 20 otoceni doprava, 24 jen sipky
	call	TIME_SCROLL
	call	KEYPRESSED
	call	PROHOD_SKRETA
	jp	MAIN_LOOP


; ===================================

INCLUDE strings.h

; Nastavi zero flag kdyz nejsme v inventari
; Do akumulatoru vlozi kurzor v inventari
TEST_OTEVRENY_INVENTAR:
	ld a,(PRIZNAKY)			;caa6	3a 13 c6 
	and PRIZNAK_OTEVRENY_INVENTAR	;caa9	e6 01 
	ld a,(KURZOR_V_INVENTARI)	;caab	3a 66 ce 
	ret

; Vcetne hl
PUSH_ALL:
	di
	ld	(PUSH_ALL_HL+1),hl	; ulozeni "hl" do pameti
	ex	(sp),hl			; push "hl" a zaroven nacteni navratove adresy do "hl"

	push	af
	push	bc
	push	de
	push	ix
	push	iy

	ex	af,af'
	push	af
	ex	af,af'
	exx
	push	bc
	push	de
	push	hl
	exx

	ei
	push	hl		; ulozeni navratove hodnoty na zasobnik
PUSH_ALL_HL:	
	ld	hl,0		; obnoveni registru "hl"
	ret

; -----------------------

; Vcetne hl
POP_ALL:
	di
	pop	hl		; navratova adresa do "hl"

	exx
	pop	hl
	pop	de
	pop	bc
	exx
	ex	af,af'
	pop	af
	ex	af,af'

	pop	iy
	pop	ix
	pop	de
	pop	bc
	pop	af
	
	ex	(sp),hl		; push "navratove adresy" a zaroven pop "hl"

	ei
	ret

; -----------------------

FLOP_BIT_ATTACK		equ	$40

KEY_DOPREDU		equ	119	; w
KEY_DOZADU		equ	115	; s
KEY_VLEVO		equ	97	; a
KEY_VPRAVO		equ	100	; d
KEY_DOLEVA		equ	113	; q
KEY_DOPRAVA		equ	101	; e
KEY_SPACE		equ	32	; mezernik
KEY_INVENTAR		equ	105	; i
KEY_VEZMI		equ	111	; o
KEY_POLOZ		equ	112	; p


KEYPRESSED:
	ld	de,TIMER_ADR
	ld	a,(de)
	and	FLOP_BIT_ATTACK/2
	ld	b,a
	ld	hl,LAST_KEY_ADR		; 10:3 23560 = LAST K system variable.
KEYPRESSED_NO:

	ld	a,(de)
	and	FLOP_BIT_ATTACK/2
	xor	b
	ret	nz
	
	ld	a,(hl)			;  7:1 a = LAST K
	or	a			;  4:1 nula?
	push	hl
	push	bc
	call z,TEST_KEMPSTON
	pop	bc
	pop	hl
	
	jr	z,KEYPRESSED_NO		;12/7:2 v tehle smycce bude Z80 nejdelsi dobu... 

	ld	b,0			;  7:2  br 0x9434
	ld	(hl),b          	;  7:1 smazem, LAST K = 0

	ld	hl,(LOCATION)		; 16:3 l=LOCATION, h=VECTOR
	ld	c,h			;  4:1 (VECTOR)
	ld	h,DUNGEON_MAP/256	;  7:2 HL = aktualni pozice na mape 

;	b = 0 = stisknuto_dopredu = offset radku tabulky VEKTORY_POHYBU
	cp	KEY_DOPREDU		;  7:2, "w" = dopredu
	jp	z,POSUN

	ld	b,stisknuto_dozadu	;  7:2, offset radku tabulky VEKTORY_POHYBU
	cp	KEY_DOZADU		;  7:2, "s" = dozadu
	jp	z,POSUN

	ld	b,stisknuto_vlevo	;  7:2, offset radku tabulky VEKTORY_POHYBU
	cp	KEY_VLEVO		;  7:2, "a" = vlevo
	jp	z,POSUN

	ld	b,stisknuto_vpravo	;  7:2, offset radku tabulky VEKTORY_POHYBU
	cp	KEY_VPRAVO		;  7:2, "d" = vpravo
	jp	z,POSUN

	ld	b,-1			;  7:2, pouzito pro VECTOR += b
	cp	KEY_DOLEVA		;  7:2, "q" = otoc se vlevo
	jr	z,OTOC_SE
	
	ld	b,1			;  7:2, pouzito pro VECTOR += b
	cp	KEY_DOPRAVA		;  7:2, "e" = otoc se vpravo
	jr	z, OTOC_SE

	cp	KEY_SPACE		;  7:2, "mezernik/asi space" = prepnuti paky
	jp	z, PREHOD_PREPINAC

	cp	KEY_INVENTAR		;  7:2 "i" = inventar / hraci
	jp	z,SET_RIGHT_PANEL

	cp	55		;  7:2 
	jr	nc,KEYPRESSED_NO_NUMBER_1_6	; vetsi nebo rovno jak hodnota znaku "7"
	cp	49		;  7:2 
	jr	c,KEYPRESSED_NO_NUMBER_1_6	; mensi jak hodnota znaku "1"
	jp	NEW_PLAYER_ACTIVE
KEYPRESSED_NO_NUMBER_1_6:

	cp	42			;  7:2 "*" = ctrl+b ( nastavi border pro test synchronizace obrazu )
	jp	z,SET_BORDER
	
	cp	KEY_POLOZ		;  7:2 "p"
	jp	z,VLOZ_ITEM_NA_POZICI

	cp	KEY_VEZMI		;  7:2 "o"
	jp	z,VEZMI_ITEM_Z_POZICE
	
	cp	96			; ctrl+x
	jp	nz,HELP			; jina klavesa? zobraz napovedu! Pozor tohle musi byt posledni test klavesy, protoze pokracovani je ukonceni programu
	
;EXIT_PROGRAM:
	pop	hl			; zrusim ret
	call	POP_ALL
	ret				; do BASICu
;------

SET_BORDER:
	ld	a,(BORDER)
	xor	$07
	ld	(BORDER),a
	ret



; Nastal uz cas scrollovat stare zpravy?
; ver 0.1
TIME_SCROLL:
	ld	a,(TIMER_ADR+1)		; 13:3
	and	$02			;  7:2
	
	ld	b,a			;  4:1
TIME_SCROLL_LAST:
	xor	0			;  7:2 self-modifying, zde ma lezet predchozi
	ret     z			; 11/5:1 ret z C8 / ret nz C0 
	ld	a,b			;  4:1
	ld	(TIME_SCROLL_LAST+1),a	; 13:3
	call	SCROLL
	ret


	

; VSTUP: b = -1 otoceni doleva, +1 otoceni doprava
OTOC_SE:
	ld	a,c		;  4:1 (VECTOR)
	add	a,b		;  4:1
	and	MASKA_NATOCENI	;  7:2
	ld	hl,VECTOR	; 10:3
	ld	(hl),a		;  7:1 ulozi novy VECTOR pohledu
	
	call	INC_POCITADLO_POHYBU_A_ZVUK	; zvedne "pocitadlo pohybu/otoceni"
	
; PRUMER	equ	( SIPKA_OTOCDOLEVA + SIPKA_OTOCDOPRAVA ) /2
; 	ld	a,PRUMER
	ld	a,SIPKA_OTOCDOLEVA/2 + SIPKA_OTOCDOPRAVA/2
	add	a,b
	add	a,b
	call	AKTUALIZUJ_SIPKY	; a = 16 otoceni doleva, 20 = otoceni doprava
	call	AKTUALIZUJ_RUZICI
	ret
;------

; ulozi do registru "l" novou pozici 
; VSTUP: hl = aktualni pozice, c = (VECTOR), a = { 0 dopredu, 4 dozadu, 8 vlevo, 12 vpravo }
; VYSTUP: hl = nova pozice
; MENI: de,a
DO_HL_NOVA_POZICE:
	ld	d,VEKTORY_POHYBU/256	;  7:2
	add	a,c			;  4:1 (VECTOR) = {0, 1, 2, 3} = sloupec
	ld	e,a			;  4:1 de = @(VECTORY_POHYBU[radek][sloupec])

	ld	a,(de)			;  7:1 o kolik zmenit LOCATION pro pohyb danym smerem
	add	a,l			;  4:1 ZMENIT POKUD BUDE MAPA 16bit!!! ( ..a nejen to, pozice predmetu, dveri atd. )
	ld	l,a			;  4:1 hl = pozice na mape po presunu
	ret

;--------


; VSTUP: 	nic
; NEMENI:	b ( protoze nesmi )
INC_POCITADLO_POHYBU_A_ZVUK:
      ld	hl,POHYB		; 10:3
      inc	(hl)
      
      ld	hl,1000
IPPAZ_LOOP: 
      ld	a,(hl)
      and	248
      out	(254),a
      dec	hl
      ld	a,h
      or	l
      jr	nz,IPPAZ_LOOP
      ret



	
	
; Cte se z portu 31
; D0- joy RIGHT
; D1- joy LEFT
; D2- joy DOWN
; D3- joy UP
; D4- joy FIRE 1
; D5- joy FIRE 2 (podporovano jen u K-MOUSE interface, kde je podpora vsech trech tlacitek joysticku)
; D6- joy FIRE 3 (podporovano jen u K-MOUSE interface, kde je podpora vsech trech tlacitek joysticku)
; D7- nepouzito, obycejne zde vraci log.0
DATA_KEMPSTON:
;	right		left		up+r		up+l		down		up		fire		down+r		down+l		up+l+f
defb	$01,		$02,		$09,		$0a,		$04,		$08,		$10,		$05,		$06,		$1a 
defb	KEY_VPRAVO,	KEY_VLEVO,	KEY_DOPRAVA,	KEY_DOLEVA,	KEY_DOZADU,	KEY_DOPREDU,	KEY_SPACE,	KEY_POLOZ,	KEY_VEZMI,	KEY_INVENTAR
; VYSTUP: 	v "a" ascii kod stisknute klavesy 
; 		vraci zero flag kdyz nic...
TEST_KEMPSTON:
	xor	a			;cbb2	a = 0 
	ld	h,a			;cbb3	h = stav joystiku
	ld	l,a			;cbb4	hl = 0 
TK_NOVY_STAV:
	ld	b,6			;cbb5	pocet opakovani cteni stavu joysticku po kazde zmene
	or	h			;cbb7	pridame k puvodnimu stavu novy
	ld	h,a			;cbb8	ulozime do puvodniho
TK_LOOP:
	halt				;cbb9
	in	a,(31)			;cbba	cteme stav joysticku
	and	31			;cbbc	odmazem sum v hornich bitech, krome spodnich 5
	cp	31			;cbbe	je neco stisknuto? 
	ret	z			;cbc0
	cp	l			;cbc1	lisi se nove cteni od predchoziho? 
	ld	l,a			;cbc2   posledni cteni do registru "l"
	jr	nz,TK_NOVY_STAV		;cbc3	lisi se 
	djnz	TK_LOOP			;cbc5	nelisilo se, snizime pocitadlo
	
	ld	a,h			;cbc7	vysledny stav do akumulatoru
	ld	hl,DATA_KEMPSTON	;cbc8	21 9e cb 	! . . 
	ld	b,00ah			;cbcb	06 0a 	. . 
	ld	c,b			;cbcd	48 	H 
TK_TEST_STAVU:
	cp	(hl)			;cbce	be 	. 
	jr	z,TK_SHODNY_STAV	;cbcf	28 27 	( ' 
	inc	hl			;cbd1	23 	# 
	djnz	TK_TEST_STAVU		;cbd2	10 fa 	. .
	
	inc	b			;cbd4	b = 1 
	cp	011h			;cbd5	fire+right
	jr	z,TK_ZMENA_AKT_POSTAVY	;cbd7 
	ld	b,0ffh			;cbd9	b = -1 
	cp	012h			;cbdb	fire+left 
	jr	z,TK_ZMENA_AKT_POSTAVY	;cbdd 
	xor	a			;cbdf	af 	. 
	ret				;cbe0	c9 	. 
	
TK_ZMENA_AKT_POSTAVY:
	ld	c,031h			;cbe1	znak "1" 
	ld	hl,AKTIVNI_POSTAVA	;cbe3	 
	ld	a,(hl)			;cbe6	
	add	a,b			;cbe7	aktivni postava +- 1 
	dec	hl			;cbe8	nemeni priznaky, hl = adresa MAX_POSTAVA_PLUS_1 
	jp	m,TK_PODTECENI		;cbe9	mozne podteceni v pripade 0-1
	cp	(hl)			;cbec	porovnani s MAX_POSTAVA_PLUS_1
	jr	z,TK_PRETECENI		;cbed	mozna shoda s MAX_POSTAVA+1 = MAX_POSTAVA_PLUS_1
	add	a,c			;cbef	+ znak "1" a nastavi priznaky ( zrusi zero-flag )
	ret				;cbf0	
	
TK_PRETECENI:
	ld	a,c			;cbf1	a = znak "1"
	or	a			;cbf2	nastavi priznaky ( zrusi zero-flag )
	ret				;cbf3	 
	
TK_PODTECENI:
	ld	a,(hl)			;cbf4	 
	dec	a			;cbf5	a = MAX_POSTAVA
	add	a,c			;cbf6	+ znak "1" a nastavi priznaky ( zrusi zero-flag )
	ret				;cbf7

TK_SHODNY_STAV:
	ld	b,0			;cbf8
	add	hl,bc			;cbfa	offset + 10 
	ld	a,(hl)			;cbfb	nahradi stav joysticku ekvivalentnim znakem klavesnice 
	or	a			;cbfc	nastavi priznaky ( zrusi zero-flag )
	ret				;cbfd 

; =======================
POSUN:
	; Pokud je aktivni panel s inventarem, tak sipky pohybuji s kurzorem v inventari
	call TEST_OTEVRENY_INVENTAR		;
	jp	z,POSUN_NEJSEM_V_INVENTARI
	; jsme v inventari
	dec	b				;  4:1 "b" obsahuje hodnotu { stisknuto_dopredu = 0,stisknuto_dozadu = 1,stisknuto_vlevo = 2,stisknuto_vpravo = 3 }
	ld	c,b				;  4:1 (dopredu=nahoru=0 - 1) = -1
	jp	m,POSUN_PRICTI			; 10:3
	ld	c,1				;  7:2 dozadu = dolu = +1, nelze pouzit "inc c" protoze by to zrusilo zero flag...
	jr	z,POSUN_PRICTI			;12/7:2

	ld	hl,POSUN_VLEVO_INVENTAREM-1	; 10:3
	dec	b				;  4:1 puvodni - 2	
	jr	z, POSUN_LOOP			;12/7:2
	ld	l,POSUN_VPRAVO_INVENTAREM-1	;  7:2

POSUN_LOOP:					; prochazeni pole POSUN_VLEVO_INVENTAREM nebo POSUN_VPRAVO_INVENTAREM a hledani spravneho rozsahu
	inc	l				;  4:1
	cp	(hl)				;  7:1
	inc	l				;  4:1 carry flag nebude zmenen
	jr	nc,POSUN_LOOP			;12/7:2
	
	ld	c,(hl)				;  7:1
						;   : 26+26 tabulky=52
POSUN_PRICTI:
	add	a,c				; 4:1
	ld	b,MAX_ITEM
	jp	p,POSUN_NEZAPORNY
	add	a,b				; k zapornemu kurzoru prictu MAX_ITEM
POSUN_NEZAPORNY:
	cp	b
	jr	c,POSUN_V_MEZICH
	sub	b				; u kurzoru co pretekl odectu MAX_ITEM
POSUN_V_MEZICH:
	ld	(KURZOR_V_INVENTARI),a		; opraveny zmeneny ulozim
	jp	INVENTORY_WINDOW_KURZOR

POSUN_VLEVO_INVENTAREM:
; rozsah do+1	posun o
defb	2,	-11
defb	5,	-6
defb	7,	-7
defb	8,	-12
defb	21,	-8
defb	23,	-7
defb	MAX_ITEM,	-5
POSUN_VPRAVO_INVENTAREM:
; rozsah do	posun o
defb	13,	8
defb	17,	7
defb	18,	6
defb	22,	5
defb	23,	4
defb	MAX_ITEM,	7
POSUN_VLEVO_INVENTAREM_END:

if (POSUN_VLEVO_INVENTAREM/256) != (POSUN_VLEVO_INVENTAREM_END/256)
    .error 'Seznam POSUN_VLEVO_INVENTAREM prekracuje 256 bajtovy segment!'
endif



; ==============================
POSUN_NEJSEM_V_INVENTARI:

	ld	a,b
	add	a,a			; 4:1 2x
	add	a,a			; 4:1 4x
	push	af			; uchovam smer kvuli sipkam

	call	DO_HL_NOVA_POZICE
; test steny
	bit	0,(hl)			; 12:2 self-modifying pokud meni patra
	jr	nz,POSUN_ZABLOKOVAN	;12/7:1 Pokud tam je stena opust fci
	
	call	JE_POZICE_BLOKOVANA	; vraci carry priznak kdyz je zablokovana
	jr	c,POSUN_ZABLOKOVAN

	ld	a,l
	ld	(LOCATION),a		; 13:3 ulozi novou pozici

	call	INC_POCITADLO_POHYBU_A_ZVUK	;zvedne "pocitadlo pohybu/otoceni"
	jr	EXIT_POSUN
	
POSUN_ZABLOKOVAN:
	ld	ix,VETA_NO_WAY
	call	PRINT_MESSAGE
	
EXIT_POSUN:
	pop	af
	call	AKTUALIZUJ_SIPKY
	ret
;------

; Stisknut SPACE
; v "c" je (VECTOR)
; v "hl" je aktualni lokace
; MENI: hl pri hledani dalsich objektu co se musi prepnout
PREHOD_PREPINAC:
	call TEST_OTEVRENY_INVENTAR
	jp	z,PP_NEJSME_V_INVENTARI
	; jsme v inventari
	ld	c,a
	ld	b,0
	ld	hl,(AKTIVNI_INVENTAR)
	add	hl,bc				; hl ukazuje na predmet pod kurzorem
	ld	b,(hl)				; "b" predmet pod kurzorem
	
	ld	de,DRZENY_PREDMET
	
	ld	a,(de)				; drzeny do "a"

	ld	(hl),a				; drzeny ulozime
	ld	a,b
	ld	(de),a				; puvodni pod kurzorem do drzenych

	or	a
	jp	z,INVENTORY_WINDOW_KURZOR

	call	ITEM_TAKEN
	
; POZOR!!! pozdeji ohlidat zda ukladam na povolene misto ( toulec, prsteny atd )	
	jp	INVENTORY_WINDOW_KURZOR


PP_NEJSME_V_INVENTARI:
	xor	a			; posun vpred
	call	DO_HL_NOVA_POZICE	; hl = hledana lokace = aktualni + vpred
	call	FIND_FIRST_OBJECT
	ret	nz			;11/5:1 nenalezena
	
PP_NALEZEN_OBJEKT:			; na lokaci lezi nejaky predmet
	ld	a,(de)			;  7:1 typ
	and	MASKA_TYP
	cp	TYP_PREPINAC		;  7:2
	jr	nz,PP_MESSAGE		;12/7:3

; je to prepinac ( paka, tlacitko, zamek, ...), ale je natocen k nam?
	ld	a,(de)			;  7:1 typ
	and	MASKA_NATOCENI		;  7:2 vynulujeme bity pro polohu paky
	cp	c			;  4:1 pohledy musi sedet
	jr	nz,PP_NEXT_OBJECT	; 12/7:2

; nalezen spravny prepinac pred nama!
	ld	a,(de)			;  7:1 typ
	add	a,$80			;  7:2 prepneme paku / prohodime horni bit
	ld	(de),a			;  7:1 typ
	
; zjistime co paka prehazuje a prehodime VSECHNY dalsi
	inc	de			;  6:1 de: "typ"->"dodatecny"
PP_LOOP:

	inc	de			;  6:1 de: "dodatecny"->"lokace"
	ld	a,(de)			;  7:1 lokace
	or	a			;  4:1 lokace nula znaci rozsirene udaje predchoziho radku
	ret	nz			;11/5:1

	inc	de			;  6:1 de: "lokace"->"typ (alias lokace prepinaneho)"
	ld	a,(de)			; typ (alias lokace prepinaneho)
	ld	l,a
	inc	de			;  6:1 de: "typ"->"dodatecny"
	ld	a,(de)			; dodatecny ( v tomto pripade je to typ prepinaneho predmetu )
	ld	h,a

	call	PREPNI_OBJECT
	jp	PP_LOOP
	
PP_MESSAGE:
	cp	TYP_DEKORACE
	call	z,MSG_DEKORACE

PP_NEXT_OBJECT:
	call	FFO_NEXT		; "de" ukazuje stale na "typ"
	jr	z,PP_NALEZEN_OBJEKT
	ret


MSG_DEKORACE:
	call	PUSH_ALL

	inc	de
	ld	a,(de)
	and	MASKA_PODTYP
	
	ld	ix,VETA_FLOOR
	cp	PODTYP_KANAL
	jr	z,MSG_DEKORACE_VIEW
	
	ld	ix,VETA_RUNE
	cp	PODTYP_RUNA
	jr	nz,MSG_DEKORACE_EXIT
	
MSG_DEKORACE_VIEW:
	ld	a,%00000101		; azurova
	call	PRINT_MESSAGE_COLOR
MSG_DEKORACE_EXIT:
	call	POP_ALL
	ret
	
; =============================

; VSTUP: hl = hledana lokace
; VYSTUP: Z = nalezen ( "a" = offset lokace = "l" ), NZ = nenalezen ( "a" > "l" a je roven nasledujici nebo zarazce ), CARRY vzdy 0
; MENI: de = ukazuje na typ, a
; tabulka predmetu je definovna jako seznam "defb lokace, typ, dodatecny"
FIND_FIRST_OBJECT:
	ld	de,TABLE_ITEM-2		; 10:3 de: "typ"
FFO_NEXT:
	inc	de			;  6:1 de: "typ"->"dodatecny"
FIND_NEXT_OBJECT:
	inc	de			;  6:1 de: "dodatecny"->"lokace"
	ld	a,(de)			;  7:1
	inc	de			;  6:1 de: "lokace"->"typ"
	cp	l			;  4:1 "lokace predmetu" - "nase hledana lokace"
	jp	c,FFO_NEXT		; 10:3 carry flag = zaporny = jsme pod lokaci
	ret				; 10:1 Z = jsme na hledane lokaci, NZ = jsme ze ni, a nenasli jsme

;----------------------
; VSTUP:	de = TABLE_ITEM-2
;		b = hledane natoceni ( kdyz se rovna 4 tak pretika do dalsiho policka )
; VYSTUP:	de = ukazuje na typ v prvnim radku se shodnym natocenim (= za poslednim s nizsim natocenim) nebo vyssi lokaci
; 		carry = 0
FIND_LAST_OBJECT:
	inc	de			;  6:1 de: "typ"->"dodatecny"
	inc	de			;  6:1 de: "dodatecny"->"lokace"
	ld	a,(de)			;  7:1
	inc	de			;  6:1 de: "lokace"->"typ"
	cp	l			;  4:1 "lokace predmetu" - "nase hledana lokace"
	jp	c,FIND_LAST_OBJECT	; 10:3 carry flag = zaporny = jsme pod lokaci
	ret	nz			; jsme za polickem
	ld	a,(de)			; typ + natoceni
	and	MASKA_NATOCENI		; jen natoceni
	cp	b			;			; 
	jp	c,FIND_LAST_OBJECT
	
	ret
; ------------------------------------------------------
; a zbytek posun dolu
; VSTUP: HL = lokace kam vkladam
;	c = (vector)
; Je to komplikovanejsi fce nez sebrani, protoze musi najit to spravne misto kam to vlozit.
; Polozky jsou razeny podle lokace a nasledne podle natoceni.
; Pak existuji polozky ktere maji dodatecne radky zacinajici nulou.
VLOZ_ITEM_NA_POZICI:
	ld 	de,DRZENY_PREDMET
	ld	a,(de)
	or	a
	ld	ix,VETA_NEDRZI
	jp 	z,PRINT_MESSAGE		; nic nedrzi, fce volana pomoci "jp" misto "call" = uz se nevrati
	
	ld	ixh,a
	xor	a
	ld	(de),a
	
	ld	a,c
	inc	a
	and	MASKA_NATOCENI
	add	a,TYP_ITEM	
	ld	ixl,a			; 2 bajt v radku obsahuje TYP + NATOCENI

	ld	de,TABLE_ITEM-2
	ld	a,c
	inc	a
	and	MASKA_NATOCENI
	inc	a			; 0->2,1->3,2->4,3->1
	ld	b,a
	call	FIND_LAST_OBJECT
	dec	de		; vratime se na prvni bajt radku, (de) = lokace "za" nebo zarazka, od teto pozice vcetne ulozime 3 byty a zbytek vcetne zarazky o 3 posunem.
;..............
	push	hl			; uchovame offset lokace
	
	ld	hl,(ADR_ZARAZKY)	; 16:3
	push	hl
	push	hl
	sbc	hl,de			; 15:2
	ld	b,h			;  4:1
	ld	c,l			;  4:1 o kolik bajtu
	inc	bc			; pridame zarazku a odstranime problem kdy bc = 0
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	ld	(ADR_ZARAZKY),hl	; 16:3
	pop	de
	ex	de,hl
	lddr				; 	"LD (DE),(HL)", DE--, HL--, BC--
	
; pokud je predmet posledni tak se presune o 3 bajty jen zarazka
	ld	a,ixh
	ld	(de),a
	dec	de
	
	ld	a,ixl
	ld	(de),a
	dec	de
	
	pop	hl			; nacteme offset lokace
	ld	a,l
	ld	(de),a
	
	jp	INVENTORY_WINDOW_KURZOR
; 	ret

;-----------------------------------------------------------

; a zbytek posun dolu
; VSTUP: HL = lokace kam vkladam
;	c = (vector)
VEZMI_ITEM_Z_POZICE:
	ld	a,(DRZENY_PREDMET)
	or	a
	ld	ix,VETA_DRZI
	jp 	nz,PRINT_MESSAGE		; uz neco drzi, fce volana pomoci "jp" misto "call" = uz se nevrati

	ld	de,TABLE_ITEM-2
	ld	b,c
	inc	b			; 0->1,1->2,2->3,3->4
	call	FIND_LAST_OBJECT
	dec	de		; vratime se na prvni bajt radku, (de) = lokace "za" nebo zarazka, od teto pozice vcetne ulozime 3 byty a zbytek vcetne zarazky o 3 posunem.
;..............
	
	ld	a,TYP_ITEM
	add	a,c
	ld	c,a
	
	ld	a,l
	ld	h,d
	ld	l,e		; hl = lokace za
	
; VIZP_LOOP:
	dec	hl		; MASKA_PODTYP
	ld	e,(hl)
	dec	hl		; MASKA_TYP + MASKA_NATOCENI
	ld	d,(hl)
	dec	hl		; lokace
	cp	(hl)
	
	ld	ix,VETA_NIC
	jp 	nz,PRINT_MESSAGE		; nic nenasel, fce volana pomoci "jp" misto "call" = uz se nevrati
; 	ret	nz
	
	ld	a,d
	cp	c		; je tam zvednutelny predmet?
; 	ld	a,(hl)		; vratime offset lokace do akumulatoru
	jp	nz,PRINT_MESSAGE

; hl adresa mazaneho tribajtoveho prvku
; e = podtyp
; d = TYP_ITEM + natoceni

	ld	a,e
	ld	(DRZENY_PREDMET),a
	push	af
	
	ld	d,h
	ld	e,l		; kam ukladat
	inc	hl
	inc	hl
	inc	hl		; odkud brat
VIZP_PRESUN:
	ld	a,(hl)
	ldi			; (de) = (hl) lokace
	cp	TYP_ZARAZKA
	
	jr	z,VIZP_EXIT
	
	ldi			; (de) = (hl) typ
	ldi			; (de) = (hl) podtyp
	jp	VIZP_PRESUN
	
VIZP_EXIT:
	dec	de			; zrusime +1 z ldi
	ld	(ADR_ZARAZKY),de	; 

	pop	bc		; b = a = (DRZENY_PREDMET)
	call	ITEM_TAKEN
; otevri inventar
	ld	hl,PRIZNAKY			; 10:3
	ld	a,(hl)				; 7:1
	or	PRIZNAK_OTEVRENY_INVENTAR	; 7:2
	ld	(hl),a				; 7:1
	
	jp	INVENTORY_WINDOW_KURZOR
; 	ret
;----------------------------------------------


PREPNI_OBJECT:
; fce prepne dvere nebo paku, bez ohledu na natoceni
; v "h" je "typ"
; v "l" je hledana lokace
	push	de
	call	FIND_FIRST_OBJECT
	jr	nz, PO_EXIT

PO_NALEZEN_OBJECT:
; na lokaci lezi nejaky predmet
	ld	a,(de)			;  7:1 typ
	sub	h
	and	MASKA_TYP + MASKA_NATOCENI
	jr	nz,PO_NEXT_OBJECT	;12/7:2       ??? pokud je horni bit nastaven tak to bude blbnout?

; je to hledany predmet AKTUALIZOVAT
	ld	a,h
	and	MASKA_PREPINACE
	ex	de,hl			;  4:1
	xor	(hl)			;  7:1 xorujeme flagy v horni casti "typ"
	ld	(hl),a			;  7:1
	ex	de,hl			;  4:1 
		
PO_NEXT_OBJECT:
	call	FFO_NEXT
	jr	z,PO_NALEZEN_OBJECT
	
PO_EXIT:
	pop	de
	ret

; ====================================

; Prohleda seznam predmetu zda na dane pozici ( ulozene v registru "l" ) nelezi nepruchozi predmet ( = aspon jeden z hornich bajtu "typ" je nenulovy ) 
; VSTUP: v "hl" je hledana lokace
; VYSTUP: vraci carry priznak pokud najde
; MENI: de,l,a
JE_POZICE_BLOKOVANA:
	call	FIND_FIRST_OBJECT
	ret	nz			;11/5:1 nenalezena
	
JPB_NALEZEN_OBJECT:			; na lokaci lezi nejaky predmet
	ld	a,(de)			;  7:1 typ
	add	a,MASKA_PREPINACE
	ret	c			; blokovany?
	
	call	FFO_NEXT		; hledej dalsi
	jr	z,JPB_NALEZEN_OBJECT	; 10:1 nalezen dalsi objekt na lokaci
	ret


; ====================================

VIEW:	; 0xd1f7

	; vykresleni pozadi ( strop a podlaha )
	ld	bc,$1100		; 17. sloupec
POZADI:
	ld	de,H5
	ld	a,(POHYB)		; 13:3
	and	1
	jr	z,V_H5
	ld	c,$FF
V_H5:
	push	bc
	push	de
	call	COPY_SPRITE2BUFFER
	pop	de
	pop	bc
	djnz	POZADI
	call	COPY_SPRITE2BUFFER
	; vykresli dno bufferu
	ld	de,dno_bufferu
	ld	bc,$000E		;
	call	COPY_SPRITE2BUFFER	

	ld	h,VEKTORY_POHYBU/256	;  7:2
	ld	a,(VECTOR)		; 13:3 {0, 1, 2, 3}
	ld	l,a			;  4:1
	ld	c,(hl)			;  7:1 modifikator pro posun vpred
	add	a,12			;  7:2			
	ld	l,a			;  4:1
	ld	a,(hl)			;  7:1 modifikator pro posun vpravo
	ld	e,a			;  4:1 "e" obsahuje "o 1 vpravo" 
	add	a,a			;  4:1 2 * vpravo
	add	a,a			;  4:1 4 * vpravo
	ld	d,a			;  4:1 "d" obsahuje "max vpravo"

	ld	h,DUNGEON_MAP/256	;  7:2 
	ld	a,(LOCATION)		; 13:3	
	ld	b,6			;  7:2
NULA:
	ld	l,a			;  4:1
	push	hl			; 11:1
	add	a,c			;  4:1 c = modifikator pro posun vpred
	djnz	NULA			; 13/8:2


	pop	ix			; do IX nactem nejvzdalenejsi pozici co vidim pred sebou
	push	de
	ld	hl,TABLE_VIEW_9_DEPTH_4
	ld	b,-1			; hloubka
	call	PROHLEDEJ_PROSTOR_VPREDU	; -40 H4
	pop	de
	ld	a,d
	sub	e
	ld	d,a

	pop	ix
	push	de
	ld	hl,TABLE_VIEW_7_DEPTH_3
	ld	b,48			; hloubka
	call	PROHLEDEJ_PROSTOR_VPREDU	; -32 H3
	pop	de
	ld	a,d
	sub	e
	ld	d,a

	pop	ix
	push	de
	ld	hl,TABLE_VIEW_5_DEPTH_2
	ld	b,36			; hloubka
	call	PROHLEDEJ_PROSTOR_VPREDU	; -24 H2
	pop	de
	ld	a,d
	sub	e
	ld	d,a

	pop	ix
	push	de
	ld	hl,TABLE_DEPTH_1
	ld	b,24			; hloubka
	call	PROHLEDEJ_PROSTOR_VPREDU	;  -16 H1
	pop	de

	pop	ix
	push	de
	ld	hl,TABLE_DEPTH_0
	ld	b,12			; hloubka
	call	PROHLEDEJ_PROSTOR_VPREDU	;  -8 H0
	pop	de

	pop	ix
	ld	hl,TABLE_DEPTH_x
	ld	b,0
	call	PROHLEDEJ_PROSTOR_VPREDU
	
	call	VYKRESLI_AKTIVNI_PREDMET

	ret

; --------------------------------

; RADOBY_TIMER:
; defb	0		; nepouzit
; SMAZ!!!
PROHOD_SKRETA:
; 	ld 	hl,(TIMER_ADR) 
; 	ld	a,l
; 	or	a
; 	jp	m,ATTACK
; 	ld	hl,ES1
; 	ld	bc,$0305
; 	jr	PREPIS
; 	
; ATTACK:
; 	ld	hl,ESA1
; 	ld	bc,$0102
; 	
; PREPIS:
; 
; 	ld	(ENEMY_GROUP+24),bc
; 	ld	(ENEMY_TABLE+2),hl
	ret
	
CARKY:
defb    $00     ; 0000 0000
defb    $80     ; 1000 0000
defb    $C0     ; 1100 0000
defb    $E0     ; 1110 0000
defb    $F0     ; 1111 0000
defb    $F8     ; 1111 1000 
defb    $FC     ; 1111 1100
defb    $FE     ; 1111 1110
defb    $FF     ; 1111 1111
CARKY_END:

INCLUDE table.h



; -------------------------------------
; ix obsahuje pozici na mape kterou vykresluji
; hl obsahuje odkaz do tabulky sten
; d obsahuje index "+max. vpravo", e obsahuje "o 1 vpravo"
; b obsahuje hloubku/vzdalenost pro zjisteni jakou verzi spritu nakreslit v objektech
PROHLEDEJ_PROSTOR_VPREDU:
	ld	c,ixl	; ulozime offset pozice
	ld	a,d
PPV_LOOP:
	add	a,c
	ld	ixl,a	; ix = max. vpravo
; test steny
	bit	1,(ix)

	push	bc
	push	de
	call	INIT_COPY_PATTERN2BUFFER
	call	INIT_COPY_PATTERN2BUFFER	
	pop	de
	pop	bc
	
	ld	a,d
	cp	e
	jr	nz,PPV_NEKRESLI_VPRAVO
	; jsme o 1 vpravo
	ld	a,4			; primy pohled, o 1 vpravo, o 1 vlevo
	call	INIT_FIND_OBJECT
PPV_NEKRESLI_VPRAVO:
	
	ld	a,c
	sub	d
	ld	ixl,a	; ix = max. vlevo
; test steny
	bit	1,(ix)

	push	bc
	push	de
	call	INIT_COPY_PATTERN2BUFFER	
	call	INIT_COPY_PATTERN2BUFFER
	pop	de
	pop	bc

	ld	a,d
	cp	e
	jr	nz,PPV_NEKRESLI_VLEVO
	; jsme o 1 vlevo
	ld	a,8			; primy pohled, o 1 vpravo, o 1 vlevo
	call	INIT_FIND_OBJECT
PPV_NEKRESLI_VLEVO:
	

	ld	a,d
	sub	e
	ld	d,a
	jr	nz,PPV_LOOP

	ld	ixl,c
; test steny
	bit	1,(ix)

	push	bc
	call	INIT_COPY_PATTERN2BUFFER
	pop	bc
	; divame se vpred
	xor	a			; primy pohled, o 1 vpravo, o 1 vlevo
	call	INIT_FIND_OBJECT
	ret

;
INIT_FIND_OBJECT:

	bit	7,b	; zaporna hloubka, nekreslim, usetrim si radek s nulama v kazde tabulce
	ret	nz

	push	hl
	push	de
	push	bc
	
	add	a,b
	ld	c,a
	ld	b,0	; bc ted dela index pro danou hloubku a kolmici
	
	call	FIND_OBJECT
	pop	bc
	pop	de
	pop	hl
	ret
	


; -----------------------------

; SMAZ!!!!!!!
; vzdy posune hl o 4, i kdyz nekresli
; ochrani "a","ix"
INIT_COPY_PATTERN2BUFFER_ver2:

	jr	nz,IC_KRESLIME		; zero flag = je tam chodba, nekreslime

	inc	hl
	inc	hl
IC_NEKRESLIME:
	inc	hl
	inc	hl
	ret

IC_KRESLIME:

	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl

	dec	d
	jr	c,IC_NEKRESLIME		; adresa obrazku je na prvni strance? nekreslime 
	inc	d

	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl

	push	af
	push	hl
	push	ix
	call	COPY_SPRITE2BUFFER
	pop	ix
	pop	hl
	pop	af

	ret


; =====================================================
; VSTUP: 
;	HL adresa od ktere se budou cist data
;	zero-flag = 0, nebude se kreslit, = 1 bude
; VYSTUP: HL = HL + 4 i kdyz se nic nekreslilo
INIT_COPY_PATTERN2BUFFER_NOZEROFLAG:
	or	1		; reset zero flag
; vzdy posune hl o 4, i kdyz nekresli
; pokud je nastaven ZERO priznak nekresli, pokud je segment obrazku nula nekresli taky
; zachova ix a akumulator
INIT_COPY_PATTERN2BUFFER:
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl

	ret	z			; je tam chodba, nekreslime

	inc	d			; ochranujem akumulator
	dec	d
	ret	z			; nekreslime

	push	af
	push	hl
	push	ix


	call	COPY_SPRITE2BUFFER

	pop	ix
	pop	hl
	pop	af
	ret

; =====================================================


; =====================================================




; v IX je zkoumana lokace
; v BC je hloubka * 12 = radek v DOOR_TABLE/RAM_TABLE/...
FIND_OBJECT:	; 0xd4b5

	inc	ixl
	ret	z			; drobny bug .) $ff lokace nesmi byt totiz ani v dohledu
	dec	ixl
; 	ret	z			; $0
	
	ld	de,TABLE_ITEM-2		; 10:3 "defb lokace, typ, dodatecny"
FI_LOOP:
	inc	de			;  6:1 de: "typ"->"dodatecny"
FI_LOOP2:
	inc	de			;  6:1 de: "dodatecny"->"lokace"
	ld	a,(de)			;  7:1
	inc	de			;  6:1 de: "lokace"->"typ"
	sub	ixl			;  8:2 "lokace predmetu" - "nase hledana lokace"
	jp	c,FI_LOOP		; 10:2 carry flag?
	ret	nz			;11/5:1 lezi na lokaci "hl"?

; na lokaci lezi nejaky predmet
	ld	a,(de)			;  7:1 typ
	and	MASKA_TYP		;  7:2

if ( TYP_PREPINAC ) != 0
	cp	TYP_PREPINAC		;  7:2 
else
	or	a			;  4:1
endif
	
	jr	z,FI_PREPINAC		;12/7:2

	cp	TYP_DVERE		;  7:2
	jr	z,FI_DOOR		;12/7:2

	cp	TYP_ENEMY		;  7:2
	jr	z,FI_ENEMY		;12/7:2

	cp	TYP_ITEM		;  7:2
	jp	z,FI_ITEM		;12/7:2
	
	cp	TYP_DEKORACE		; musi byt posledni varianta
	jr	nz,FI_LOOP
	
	inc	de			; typ -> podtyp
	ld	a,(de)
	and	MASKA_PODTYP
TEST:
; 	cp	PODTYP_WALL		;  7:2 pruchozi steny
; 	jp	z,FI_WALL		;10:3
	
	ld	hl,RUNE_TABLE
	cp	PODTYP_RUNA		;  7:2 
	jp	z,FI_DEKORACE		;10:2
	
	ld	hl,KANAL_TABLE
	cp	PODTYP_KANAL		;  7:2 
	jp	z,FI_DEKORACE		;10:2
	
	; sem by jsem se nikdy nemel dostat...

	jp	FI_LOOP2			; 10:3 "de" ted ukazuje na "dodatecny"
FI_EXIT:
	ret

; ------------ aktualni adresa podfce je v test.asm

FI_DOOR:
	; vsechny dvere maji ram
	ld	a,(de)			;  7:1 typ

	inc	c
	dec	c
	jr	nz,FI_VIEW_RAM
	; jsme uvnitr otevrenych dveri = nejnizsi bit u "dodatecny" je = { 0 = dvere pro pruchod N-S, 1 dvere pro pruchod W-E }
	ld	hl,VECTOR		; 10:3
	add	a,(hl)			;  7:1 0 = N, 1 = E, 2 = S, 3 = W
	bit	0,a			; pokud je nejnizsi bit nastaven ziram kolmo na chodbu ( pruchod ) na ram
	jr	z,FI_LOOP		; return

FI_VIEW_RAM:				; vykresli ram
	ld	hl,RAM_TABLE
	add	hl,bc
	push	bc
	push	de
	call	INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
	pop	de
	pop	bc
	
	add	a,MASKA_PREPINACE	; nektere dvere jsou otevrene, AKTUALIZOVAT!!!
	jr	nc,FI_LOOP		; return

	ld	hl,DOOR_TABLE
	add	hl,bc
	push	bc
	push	de
	call	INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
	pop	de
	pop	bc

	jr	FI_LOOP			; return

; ------------ aktualni adresa podfce je v test.asm

FI_PREPINAC:
	push	bc

	ld	a,(de)			;  7:1 "typ"
	and	MASKA_NATOCENI		;  7:2
	
	ld	hl,VECTOR		; 10:3
	ld	l,(hl)			;  "l": 0 = N, 1 = E, 2 = S, 3 = W
	sub	l			; pohledy musi sedet
					
	ld	hl,PAKY_TABLE		; "l" uz nebudem potrebovat
	add	hl,bc

 	and	3			; protoze nekdy potrebujeme aby sever byl 4 tak jsou validni jen posledni 2 bity
					; pak 3-0 = -1 (000000-11) a 0-3 = 1 (111111-01)
	jr	z,FI_PREPINAC_INIT	; z oci do oci

	ld	bc,NEXT_PAKA
	add	hl,bc			; leve paky
	cp	3			; 3 = -1 ve 2 bitech
	jr	z,FI_PREPINAC_INIT	; leva paka trci doprava ( kdybych byl natocen doleva tak se shoduji nase smery )

	add	hl,bc			; prave paky
	cp	1			; 
	jr	nz,FI_PREPINAC_EXIT	; je tu moznost paky co je za stenou a trci ode mne a tu nevidim...
	
	; zero flag = prava paka trci doleva ( kdybych byl natocen doprava tak se shoduji nase smery )

FI_PREPINAC_INIT:

	ld	a,(de)			; "typ"
	or	a
	jp	p,FI_PREPINAC_VIEW	; kladne = paka je nahore
	
	ld	bc,PAKA_DOWN
	add	hl,bc

FI_PREPINAC_VIEW:
	push	de
	call	INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
	pop	de

FI_PREPINAC_EXIT:
	pop	bc
	jp	FI_LOOP	



; ------------ aktualni adresa podfce je v test.asm

FI_ENEMY:
	push	de
	push	ix
	push	bc

	ld	a,ENEMY_ATTACK_DISTANCE	; 7:2
	cp	c
	jr	nz,FI_ENEMY_FAR
; vzdalenost 1, levy predni skret...
	ld 	a,(TIMER_ADR) 		; timer
	and	FLOP_BIT_ATTACK
	ld	a,2
	jp	z,FI_ENEMY_FAR
	ld	a,1
FI_ENEMY_FAR:
	ld	(FI_ENEMY_SELFMODIFIYNG2+1),a


	ld	a,(de)			;  7:1 typ
	and	MASKA_PREPINACE		;  7:2
	rlca				;  4:1
	rlca				;  4:1
	rlca				;  4:1
	
	ld	ixl,a			; pocet nepratel
	
	rlca				;  4:1 pocet nepratel ve skupine * 2
	add	a,c			;  4:1
	add	a,c			;  4:1
	add	a,ENEMY_GROUP % 256	;  7:2
	ld	l,a			;  4:1
	adc	a,ENEMY_GROUP / 256	;  7:2
	sub	l			;  4:1
	ld	h,a			;  4:1 v hl je adresa kde je ulozena spravna pozice spritu s poslednim nepritelem
					; [64]:[16]

	inc	de			; dodatecny, na zasobniku je puvodni hodnota
	ld	a,(de)			;  7:1 dodatecny
	ex	de,hl
	
	ld	hl,DIV_6		; 10:3
	add	hl,bc			; 11:1
	ld	c,(hl)			;  7:1 z bc chceme jen hloubku * 2 = bc / ( 6 * 2 )
	ld	hl,ENEMY_TABLE+1	; 10:3
	add	hl,bc			; 11:1 HL je index+1 do tabulky adres spritu nepratel pro danou hloubku, nepritel je zatim jen prvni podtyp

	and	MASKA_PODTYP		;  7:2	
	jr	z,FI_ENEMY_VIEW
	
	ld	bc,NEXT_TYP_ENEMY	; uz nebudem potrebovat puvodni hodnotu, pak obnovime ze zasobniku	
FI_ENEMY_NEXT:
	add	hl,bc			; 11:1 hledame sprite spravneho nepritele
	dec	a			; snizime 
	jr	nz,FI_ENEMY_NEXT
	
FI_ENEMY_VIEW:
	ld	a,(hl)				;  7:1 segment
	or	a				;  4:1
	jp	z,FI_ENEMY_EXIT			; v teto hloubce nebude sprite na zadne pozici = exit

	dec	hl				;  6:1
	ld	l,(hl)				;  7:1
	ld	h,a				;  4:1
	ld	(FI_ENEMY_SELFMODIFIYNG+1),hl	; 16:3
	ex	de,hl

FI_ENEMY_LOOP:

	dec	hl
	ld	b,(hl)
	dec	hl
	ld	c,(hl)
	inc	c			; ochranujem akumulator
	dec	c
	jp	z,FI_ENEMY_TEST_LOOP	; sirka muze byt nula, ale vyska nula znamena nekreslit
	
FI_ENEMY_SELFMODIFIYNG:
	ld	de,0			; 10:3 adresa spritu nepritele ve spravne hloubce

FI_ENEMY_SELFMODIFIYNG2:
	ld 	a,0
	cp	ixl
	jp	nz,FI_ENEMY_CALL
	
	ld	de,ESA1
	ld	a,b
	add	a,-1
	ld	b,a
	ld	c,$03

FI_ENEMY_CALL:
	push	hl			; 11:1
	push	ix			; 15:2
	call	COPY_SPRITE2BUFFER
	pop	ix			; 14:2
	pop	hl			; 10:1
	
FI_ENEMY_TEST_LOOP:
	dec	ixl			;  8:2
	jr	nz,FI_ENEMY_LOOP
	
FI_ENEMY_EXIT:
	pop	bc
	pop	ix
	pop	de
	jp	FI_LOOP			; return
	
	
; ------------ aktualni adresa podfce je v test.asm

; FI_WALL:	; pruchozi falesna zed
; 
; ;	ld	a,(de)			;  7:1 typ
; 
; 	ld	hl,WALL_TABLE
; 	add	hl,bc
; 	add	hl,bc			; 2x ...	
; 	push	bc
; 	push	de
; 	call	INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
; 	pop	de
; 	pop	bc
; 	push	bc			; 2x kvuli blbym V4p1 a V4m1,ktere nejsou krychle
; 	push	de
; 	call	INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
; 	pop	de
; 	pop	bc
; 	
; 	jp	FI_LOOP2			; return
	
; ------------ aktualni adresa podfce je v test.asm

; VSTUP: 	bc = index v tabulce
;		adresa tabulky spravne dekorace
;		de = ukazuje na podtyp/dodatecny!!! proto se vracim pomoci FI_LOOP2
FI_DEKORACE:
	add	hl,bc
	push	bc
	push	de
	call	INIT_COPY_PATTERN2BUFFER_NOZEROFLAG
	pop	de
	pop	bc
	jp	FI_LOOP2			; return s de = dodatecny


	
	
; ------------ aktualni adresa podfce je v test.asm
;Sever 	= 0	0 1
;		2 3
;Vychod	= 1	1 3 =>
;		0 2
;Jih 	= 2	3 2 => 3-Sever
;		1 0
;Zapad 	= 3	2 0 =>
;		3 1

i_nw		equ	0	; item north-west position
i_ne		equ	1	; item north-east position
i_se		equ	2	; item south-east position
i_sw		equ	3	; item south-west position


i_lz		equ	0	; predmet vidim jako levy-zadni
i_pz		equ	2	; predmet vidim jako pravy-zadni
i_lp		equ	4	; predmet vidim jako levy-predni
i_pp		equ	6	; predmet vidim jako pravy-predni


ITEM_NATOCENI:
; vlevo a vpravo dal, vlevo a vpravo bliz
defb	i_lz,	i_pz,	i_pp,	i_lp		; divam se na sever
defb	i_lp,	i_lz,	i_pz,	i_pp		; divam se na vychod
defb	i_pp,	i_lp,	i_lz,	i_pz		; divam se na jih
defb	i_pz,	i_pp,	i_lp,	i_lz		; divam se na zapad

; VSTUP:	(di-1) = ixl, (di) = typ = TYP_ITEM prvniho objektu
;		bc = offset v table ( 3 sloupce po dvou 16 bit int ( 12 bajtu ) = primy smer / vlevo / vpravo, radky = hloubka ) 

FI_ITEM:
	ld	a,c
	cp	MAX_VIDITELNOST_PREDMETU_PLUS_1
	jp	nc,FI_LOOP			; return ( bohuzel tolikrat, kolikrat je predmetu na policku )

	ld	(FI_ADR_PRETECENI+1),de
	
	ld	hl,VECTOR
	ld	a,TYP_ITEM
	add	a,(hl)				; 7:1 + vektor natoceni
	ld	h,a
	ld	l,e				; l = adresa preteceni = prvni predmet

FI_HLEDANI_NEJVZDALENEJSIHO:
	ld	a,(de)				; typ + natoceni
	cp	h				; roh - vektor natoceni
	jr	nc,FI_NEJVZDALENEJSI		; roh je ten nejvzdalenejsi?
FI_DALSI_RADEK:
; prejdeme na dalsi predmet ( jsou razeny podle rohu )
	inc	de				; typ -> podtyp
	inc	de				; podtyp -> lokace
	ld	a,(de)				; lokace ( muzem vytect do jine lokace, pak to znamena ze musime kreslit od ITEM_ADR_POCATKU )
	inc	de				; lokace -> typ 
	or	a
	jr	z,FI_DALSI_RADEK		; dodatecny radek ( preskocime )
	
	cp	ixl
	jr	z,FI_HLEDANI_NEJVZDALENEJSIHO	; neopustili jsme policko?
	
	ld	e,l
FI_NEJVZDALENEJSI:
	
; mame levy zadni nebo pokud neni pozdejsi
	ld	a,e
	ld	(FI_ADR_NEJVZDALENEJSIHO+1),a
	jr	FI_ZA_TESTEM_OPAKOVANI
	
FI_VYKRESLI_ITEM:
FI_ADR_NEJVZDALENEJSIHO:
	ld	a,0				; self-modifying
	cp	e
	ret 	z				; ret ne jp, takze ukonci i nadrazenou fci

FI_ZA_TESTEM_OPAKOVANI:
	
	ld	a,(VECTOR)			; a = (VECTOR)
	add	a,a
	add	a,a				; smer pohledu * 4
	ld	l,a
	ld	a,(de)				; typ
	and	MASKA_NATOCENI
	add	a,l
	add	a,ITEM_NATOCENI % 256
	ld	l,a
	adc	a,ITEM_NATOCENI / 256
	sub	l
	ld	h,a			; hl = index odkud budu cist polohu predmetu
	ld	a,(hl)
	
	push	de
	push	ix
	push	bc
	
	ld	ixh,a
	
	ld	hl,DIV_6		; 10:3
	add	hl,bc			; 11:1
	ld	a,(hl)			;  7:1 ziskame hloubku * 2
	cp	6			; hloubku 3 a 4 ignorujeme
	jr	nc,FI_ITEM_EXIT
	ld	l,a

	inc	de
	ld	a,(de)
	and	MASKA_PODTYP
	add	a,a			; 2x
	add	a,a			; 4x
	add	a,a			; 8x
	add	a,l			; pripoctem hloubku
	add	a,ITEM_TABLE % 256
	ld	l,a
	adc	a,ITEM_TABLE / 256
	sub	l
	ld	h,a			; hl = adresa, kde je ulozena adresa spritu daneho predmetu v ITEM_TABLE vcetne hloubky
	ld	e,(hl)
	inc	hl
	ld	d,(hl)			; de = adr. spritu
	
	inc	d
	dec	d
	jr	z,FI_ITEM_EXIT		; adresa je rovna nule, po dkonceni vsech nahledu snad nenastane... POZOR aktualizovat?

	ld	a,c
	add	a,a			; 2*c protoze radek ma 12 word polozek
	add	a,ixh			; pridame spravny sloupec
	add	a,ITEM_POZICE % 256	; 
	ld	l,a
	adc	a,ITEM_POZICE / 256
	sub	l
	ld	h,a			; hl = adr. v ITEM_POZICE
	ld	c,(hl)
	inc	c
	dec	c
	jr	z,FI_ITEM_EXIT		; sirka muze byt nula, ale vyska nula znamena nekreslit
	inc	hl
	ld	b,(hl)
	call	COPY_SPRITE2BUFFER
	
		
FI_ITEM_EXIT:
	pop	bc
	pop	ix
	pop	de
	
	inc	de			; typ -> podtyp
	inc	de			; podtyp -> lokace
	ld	a,(de)
	inc	de			; lokace -> podtyp
	cp	ixl
	jr	z,FI_VYKRESLI_ITEM
; POZOR udelat test zda je to predmet??? Kolidovat muze jen enemy... Mel by ale byt vepredu? Ne..

FI_ADR_PRETECENI:
;	pretecem na zacatek
	ld	de,0			; self-modifying
	jr	FI_VYKRESLI_ITEM
	


; =======================================================================

INCLUDE sprite2buffer.asm



	
; =====================================================


; Kopirovani 18*14 znaku vcetne atributu z bufferu na screen
; Buffer ma rozmery a rozlozeni dat stejne jako SCREEN, jen jinou adresu
; Na obrazovce bude obsah zobrazen vlevo nahore
COPY_INVENTORY2SCREEN:	; $D64D
	halt					; cekame nez 50x za sekundu nezacne ULA prekreslovat obrazovku

	ld	a,COPY_LOOP_14x - COPY_END_SEGMENT
	ld	(COPY_MENITELNY_SKOK+1),a
	ld	hl,$1525			; dec d, dec h
	ld	(COPY_DEC_OR_NOP),hl
	
	ld	bc,1400				; 10:3
CI2S_WAIT:
	dec	bc				;  6:1 at zije nekonecna smycka
	bit	7,b				;  8:2 
	jr	z,CI2S_WAIT			; 12/7:2
	
; test
	ld	a,(BORDER)			; test se zmenou barvy pozadi
	out	(254),a

	; 1. faze atributy 1. tretiny obrazovky
	ld	h,Adr_Attr_Buffer/256		;  7:2
	ld	d,$58				;  7:2
	ld	ix,$FF01			; 14:4
	call	COPY_START

	; 2. faze obraz 1. tretiny obrazovky
	ld	h,7+Adr_Buffer/256		;  7:2
	ld	d,7+$40				;  7:2
	ld	ix,$FF08			; 14:4
	call	COPY_START

	; 3. faze atributy 2. tretiny obrazovky
	ld	h,1+Adr_Attr_Buffer/256		;  7:2
	ld	d,1+$58				;  7:2
	ld	ix,$FF01			; 14:4
	call	COPY_START

	; 4. faze obraz 2. tretiny obrazovky
	ld	h,15+Adr_Buffer/256		;  7:2
	ld	d,15+$40			;  7:2
	ld	ix,$FF08			; 14:4
	call	COPY_START

	; 5. faze atributy 3. tretiny obrazovky
	ld	h,2+Adr_Attr_Buffer/256		;  7:2
	ld	d,2+$58				;  7:2
	ld	ix,$7F01			; 14:4
	call	COPY_START

	; 6. faze obraz 3. tretiny obrazovky
	ld	h,23+Adr_Buffer/256		;  7:2
	ld	d,23+$40			;  7:2
	ld	ix,$7F08			; 14:4
	call	COPY_START

; test
	xor	a
	out	(254),a				; nastavi BORDER na cernou

	ret 



; Kopirovani 18*14 znaku vcetne atributu z bufferu na screen
; Buffer ma rozmery a rozlozeni dat stejne jako SCREEN, jen jinou adresu
; Na obrazovce bude obsah zobrazen vlevo nahore
COPY_VYREZ2SCREEN:	; $D64D
	halt					; cekame nez 50x za sekundu nezacne ULU prekreslovat obrazovku

;	inicializace fce COPY
	ld	a,COPY_LOOP_18x - COPY_END_SEGMENT
	ld	(COPY_MENITELNY_SKOK+1),a
	ld	hl,0
	ld	(COPY_DEC_OR_NOP),hl

	ld	bc,1400				; 10:3
CV2S_WAIT:
;	rld					; 18:2 pekna instrukce, 4 bitova rotace, hmm.. kratka a trva dlouho .)
	dec	bc				;  6:1 at zije nekonecna smycka
	bit	7,b				;  8:2 
	jr	z,CV2S_WAIT			; 12/7:2
	
; test
	ld	a,(BORDER)			; test se zmenou barvy pozadi
	out	(254),a


	; 1. faze atributy 1. tretiny obrazovky
	ld	h,Adr_Attr_Buffer/256		;  7:2
	ld	d,$58				;  7:2
	ld	ix,$F101			; 14:4
	call	COPY_START

	; 2. faze obraz 1. tretiny obrazovky
	ld	h,7+Adr_Buffer/256		;  7:2
	ld	d,7+$40				;  7:2
	ld	ix,$F108			; 14:4
	call	COPY_START

	; 3. faze atributy 2. tretiny obrazovky
	ld	h,1+Adr_Attr_Buffer/256		;  7:2
	ld	d,1+$58				;  7:2
	ld	ix,$D101			; 14:4
	call	COPY_START

	; 4. faze obraz 2. tretiny obrazovky
	ld	h,15+Adr_Buffer/256		;  7:2
	ld	d,15+$40				;  7:2
	ld	ix,$D108			; 14:4
	call	COPY_START

; test
	xor	a
	out	(254),a				; nastavi BORDER na cernou

	ret 
	
	
; ---------------  zobecnena fce pro kopirovani z bufferu na screen ( oboje se shodnym rozlozenim pameti )
; Kopiruje vyrez v jedne tretine od urciteho radku nahoru az k pocatku
; VSTUP: ixh = levy spodni roh ( index znaku )
;        sirka se meni pres hodnotu v CV2S_SELF
;        ixl = pocet mikroradku ( melo by byt 8 u screen a 1 u atributu )
;        h = segment bufferu
;        d = segment screen
; NEMENI: ixh

COPY_LOOP_18x:
	; max sirka je 18 znaku
	ldd					; 16:2 18x (de--) = (hl--), ignore bc--
	ldd					; 16:2
	ldd					; 16:2 

	ldd					; 16:2 15x
COPY_LOOP_14x:
	ldd					; 16:2
	ldd					; 16:2
	ldd					; 16:2
	ldd					; 16:2
	
	ldd					; 16:2 10x
	ldd					; 16:2
	ldd					; 16:2
	ldd					; 16:2 
	ldd					; 16:2 
	
	ldd					; 16:2  5x
	ldd					; 16:2
	ldd					; 16:2 
	ldd					; 16:2
	ldd					; 16:2
	
	sub	32				;  4:1 o radek nahoru
COPY_MICROLINE:
	ld	e,a				;  4:1
	ld	l,a				;  4:1
COPY_MENITELNY_SKOK:
	jr	nc,COPY_LOOP_18x		; 12/7:2  $30,xx 
						; xx = -42 = $D6 u COPY_LOOP_18x
						; xx = -34 = $DE u COPY_LOOP_14x ( pokud se nemenil kod )
						; xx = 0 pokud pokracujeme na COPY_END_SEGMENT
COPY_END_SEGMENT:
	dec	ixl				;  pocitadlo mikroradku {8x,1x}
	ret	z
	
COPY_DEC_OR_NOP:
;	pokud konci vyrez u leve strany obrazovky tak jsou registry "h" a "d" uz snizeny pomoci ldd
	nop					; 4:1 $25 = dec h = o microline nize / $00 nop
	nop					; 4:1 $15 = dec d = o microline nize / $00 nop
; hlavni vstup do fce!
COPY_START:
	ld	a,ixh				; 8:2 vracime se na znak lezici nalevo dole
	or	a				; reset carry flag
	jr	COPY_MICROLINE

; =====================================================



 
PRINT2BUFFER:
    ld	a,Adr_Buffer / 256
    ld	(PS_ADRESA_SEGMENTU+1),a
    ret

PRINT2SCREEN:
    ld	a,$40
    ld	(PS_ADRESA_SEGMENTU+1),a
    ret
    

BIT_MASKA:

defb	%10000000
defb	%01000000
defb	%00100000
defb	%00010000
defb	%00001000
defb	%00000100
defb	%00000010
defb	%00000001

; VSTUP: IX ukazatel na string zakonceny znakem mensim jak 32
;	 B = radek, C = pixel sloupec
;	Adresa fontu musi byt delitelna 256
; VYSTUP: IX ukazuje na zacatek dalsiho retece
PRINT_STRING:		; ver 0.1
	
	ld	l,%11111000		; maska pro nasobky osmi

	ld	a,b
	and	l
PS_ADRESA_SEGMENTU:
	add	a,$40
	ld	h,a
	ld	a,b
	and	%00000111		; nasobime * 32
	rrca				;  4:1 rotace vpravo, 07654321 carry = 0
	rrca				;  4:1 rotace vpravo, 10765432 carry = 1
	rrca				;  4:1 rotace vpravo, 21076543 carry = 2
	ld	b,a			;  hb = adresa prvniho znaku na radku

	ld	a,c			; delime osmi
	and	l
	rrca				;  4:1 rotace vpravo, 07654321 carry = 0
	rrca				;  4:1 rotace vpravo, 10765432 carry = 1
	rrca				;  4:1 rotace vpravo, 21076543 carry = 2

	add	a,b
	ld	l,a			; hl = adresa horniho mikroradku kam zasahne psany znak
	
	ld	a,c
	and	%00000111		; do ktereho bitu znaku jsme se trefili
	ld	de,BIT_MASKA
	add	a,e	
	ld	e,a
	ld	a,(de)
	ld	c,a
	

	
	ex de,hl

; DE adresa na obrazovce, c = kterym bitem zaciname
; DE' adresa aktualniho znaku

PRINT_NEXT_CHAR:
	ld a,(ix+0)		; 19:3
	inc	ix		; 10:2	pri ukonceni ukazuje na zacatek dalsiho retezce
	sub 	32
	ret 	c		; mensi jak 32
	
	ld	h,PISMO_5PX/256
	ld	l,a
	add	a,a		; 2x
	add	a,a		; 4x	opravit preteceni
	add	a,l		; 5x
	ld	l,a		; hl adresa prvniho sloupce znaku, opravit preteceni 256
	ld	a,h
	adc	a,0
	ld	h,a

	ld	b,5
PRINT_MIKROSLOUPEC:
	ld	a,(hl)
	or	a
	jr	z,PRINT_MIKROSLOUPEC_DOPRAVA		; same nuly
; 1x
	bit	7,(hl)
	jr	z,NO_1x
	ld	a,(de)
	xor	c
	ld	(de),a
NO_1x:
	inc	d


; 2x
	bit	6,(hl)					; 12:2
	jr	z,NO_2x					; 12/7:2
	ld	a,(de)					;  7:1
	xor	c					;  4:1
	ld	(de),a					;  7:1
NO_2x:
	inc	d					;  4:1			28/41 taktu kady bit..

; 3x
	bit	5,(hl)
	jr	z,NO_3x
	ld	a,(de)
	xor	c
	ld	(de),a
NO_3x:
	inc	d

; 4x
	bit	4,(hl)
	jr	z,NO_4x
	ld	a,(de)
	xor	c
	ld	(de),a
NO_4x:
	inc	d

; 5x
	bit	3,(hl)
	jr	z,NO_5x
	ld	a,(de)
	xor	c
	ld	(de),a
NO_5x:
	inc	d

; 6x
	bit	2,(hl)
	jr	z,NO_6x
	ld	a,(de)
	xor	c
	ld	(de),a
NO_6x:
	inc	d

; 7x
	bit	1,(hl)
	jr	z,NO_7x
	ld	a,(de)
	xor	c
	ld	(de),a
NO_7x:
	inc	d

; 8x
	bit	0,(hl)
	jr	z,NO_8x
	ld	a,(de)
	xor	c
	ld	(de),a
NO_8x:

	ld	a,d
	sub	7
	ld	d,a
	
PRINT_MIKROSLOUPEC_DOPRAVA:
	
	rrc	c			; 8:2
	ld	a,e
	adc	a,0
	ld	e,a
	
	inc	hl

	djnz	PRINT_MIKROSLOUPEC
	jr	PRINT_NEXT_CHAR
	

; ??????????????????????????????????????
; VSTUP: 
;	"b" =  radek, "c" pixel sloupec
;	IX ukazatel na string zakonceny znakem mensim jak 32
PRINT_STRING_OBAL:
	push	hl			;db94
	push	af			;db95	 
	push	bc			;db96	ulozi BC, "b" =  radek, "c" pixel sloupec
	call	PRINT_STRING		;db97	 
	pop	bc			;db9a	c1 	. 
	pop	af			;db9b	f1 	. 
	pop	hl			;db9c	e1 	. 
	ret				;db9d	c9 	. 
	
;------------------------------------

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
PRINT_MESSAGE:
	ld	a,%00000111		; INK = 7 = bila
PRINT_MESSAGE_COLOR:
	call	SCROLL			; nemeni "IX" ani "a"

	ld	hl,$5AE0		; 10:3 "l" = E0 = 256-32 
PRINT_MESSAGE_SET_ATTR:
	ld	(hl),a			;  7:1
	inc	l
	jr	nz,PRINT_MESSAGE_SET_ATTR

	ld	bc,23*256
	call	PRINT_STRING
	ret
	
;------------------------------------


; Vypise do textoveho pole napovedu
HELP:
	ld	ix,HELP_STRING
	ld	a,%00000010			; cervena
	call	PRINT_MESSAGE_COLOR
	call	PRINT_MESSAGE
	call	PRINT_MESSAGE
	call	PRINT_MESSAGE
	ret

;------------------------------------
  

JMENA_POZICE:
defw	18*8+1,25*8+1,7*256+18*8+1,7*256+25*8+1,14*256+18*8+1,14*256+25*8+1



COLOR_OTHER_PLAYERS	equ	%00000111	; white ink + black paper
COLOR_ACTIVE_PLAYER	equ	%00000011	; magenta ink + black paper

; VSTUP: A = '1' .. '6'
NEW_PLAYER_ACTIVE:
	sub	49			; odectem hodnotu znaku "1"
	ld	hl,MAX_POSTAVA_PLUS_1	; 10:3
	cp	(hl)			;  7:1  0..5 - MAX_POSTAVA_PLUS_1
	ret	nc			; aktivni vetsi jak MAX_POSTAVA_PLUS_1
					; tohle muze nastat jen u 5. a 6. postavy pokud jeste nejsou v parte
	inc	hl			;  6:1 hl = adr. AKTIVNI_POSTAVA
	cp	(hl)			;  7:1
	ret	z			; nastavujeme uz aktivni, nebudeme vse znovu prekreslovat
	ld	(hl),a			;  7:1 nova AKTIVNI_POSTAVA
	
	; zmenime ukazatel ulozeny v AKTIVNI_INVENTAR
	; potrebujeme nasobit AKTIVNI_POSTAVA {0..5} * MAX_ITEM { = 27 }
	
	ld	e,a			; ulozim si 1x do "e"
	add	a,a			; 2x 
	add	a,e			; 3x
	ld	d,a			; ulozim si 3x do "d"
	add	a,a			; 6x
	add	a,a			; 12x
	add	a,a			; 24x
	add	a,d			; 27x = MAX_ITEM * AKTIVNI_POSTAVA = 27 * AKTIVNI_POSTAVA

	inc	hl			;  6:1 
	add	a,INVENTORY_ITEMS % 256	; pozor odted nesmim zrusit mozny priznak carry
	ld	(hl),a			;  7:1
	adc	a,INVENTORY_ITEMS / 256
	sub	(hl)			;
	inc	hl			;  6:1
	ld	(hl),a			;  7:1 promnena na adrese AKTIVNI_INVENTAR obsahuje ukazatel na INVENTORY_ITEMS + MAX_ITEM * AKTIVNI_POSTAVA
	
	; je nastaveny pravy panel na zobrazeni vsech hracu?
	call TEST_OTEVRENY_INVENTAR		;dc11
	jp	nz,INVENTORY_WINDOW_REFRESH	; uz se nevratime
	; jinak pokracujem v SET_PLAYER_ACTIVE


; ------------------------------------
; V panelu s nahledem vsech hracu nastavi atributy pod jmenem aktivniho hrace na COLOR_ACTIVE_PLAYER, ostatni nastavi na COLOR_OTHER_PLAYERS
; Pozor! Musi nasledovat hned za NEW_PLAYER_ACTIVE
VIEW_PLAYER_ACTIVE:
	ld	de,(MAX_POSTAVA_PLUS_1)	; 20:4 d = AKTIVNI_POSTAVA, e = MAX_POSTAVA_PLUS_1
	ld	a,e			; a = MAX_POSTAVA_PLUS_1 = citac
 	dec	a
; kreslime odspodu nahoru, protoze citac zmensujeme smerem k nule
 	cp	4
 	jr	c,SP_4
 	cp	5
 	jr	c,SP_5
	ld	hl,Adr_Attr_Buffer + $1D9
	call	SET_COLOR_NAME
SP_5:
	ld	hl,Adr_Attr_Buffer + $1D2
	call	SET_COLOR_NAME
SP_4:
	ld	hl,Adr_Attr_Buffer + $F9
	call	SET_COLOR_NAME
	ld	hl,Adr_Attr_Buffer + $F2
	call	SET_COLOR_NAME
	ld	hl,Adr_Attr_Buffer + $19
	call	SET_COLOR_NAME
	ld	hl,Adr_Attr_Buffer + $12
	call	SET_COLOR_NAME

	ret

; Pomocna fce pro SET_PLAYER_ACTIVE, nastavi atribut 7 znaku na COLOR_OTHER_PLAYERS nebo COLOR_ACTIVE_PLAYER podle toho zda hodnota "a" == "d"
; VSTUP:	HL adresa atributu
;		"a" = citac = testovana postava
;		"d" aktivni postava
; VYSTUP:	a--
; 		b=0
;		e podle zapsane barvy
;		HL+=7
SET_COLOR_NAME:
	ld	b,7
	ld	e,COLOR_ACTIVE_PLAYER
	cp	d			; aktualni-aktivni
	jr	z,SP_NEXT_CHAR
	ld	e,COLOR_OTHER_PLAYERS
SP_NEXT_CHAR:
	ld	(hl),e
	inc	l
	djnz	SP_NEXT_CHAR
	dec	a
	ret
	
; ----------------------------------
SET_RIGHT_PANEL:
	ld	hl,PRIZNAKY			; 10:3
	ld	a,(hl)				; 7:1
	xor	PRIZNAK_OTEVRENY_INVENTAR	; 7:2
	ld	(hl),a				; 7:1
	and	PRIZNAK_OTEVRENY_INVENTAR	; 7:2

	jp	nz,INVENTORY_WINDOW_OPEN
	jr	PLAYERS_WINDOW
; 	ret				sem se uz nikdy nedostanu protoze volam fce pomoci jump
; POZOR OPRAVIT ZBYTECNY SKOK



; ----------------------------------
PLAYERS_WINDOW:
	ld	bc,$0E01	; blok o 14 sloupcich a 1 radku
	ld	hl,Adr_Attr_Buffer + $12
	call	FILL_ATTR_BLOCK

	ld	bc,$0E03	; blok o 14 sloupcich a 3 radcich
	ld	hl,Adr_Attr_Buffer + $B2
	call	FILL_ATTR_BLOCK
	
	ld	bc,$0E03	; blok o 14 sloupcich a 3 radcich
	ld	hl,Adr_Attr_Buffer + $192
	call	FILL_ATTR_BLOCK

	ld	bc,$0E01	; blok o 14 sloupcich a 1 radku
	ld	hl,Adr_Attr_Buffer + $272
	call	FILL_ATTR_BLOCK

	
	call	VIEW_PLAYER_ACTIVE
	call	PRINT2BUFFER

	ld	ix,NAMES
	ld h,003h		;dc95	3x po dvou 
	xor a			;dc97	af "a" = 0
PW_JMENA_LOOP:
	ld b,a			;dc98	b = radek
	ld c,091h		;dc99	c = pixel sloupec leveho jmena
	push bc			;dc9b
	call PRINT_STRING_OBAL	;dc9c 
	ld c,0c9h		;dc9f	c = pixel sloupec praveho jmena
	push bc			;dca1 
	call PRINT_STRING_OBAL	;dca2
	add a,007h		;dca5	dalsi radek postav
	dec h			;dca7	snizime citac
	jr nz,PW_JMENA_LOOP	;dca8
		
	ld h,006h		;dcaa	inicializovat citac
PW_HP_LOOP:
	ld ix,VETA_HP		;dcac	dd 21 68 c9 	. ! h . 
	pop bc			;dcb0	vyjmeme ze zasobniku souradnice jmena 
	ld a,b			;dcb1
	add a,005h		;dcb2	pricteme k radku 5 
	ld b,a			;dcb4
	call PRINT_STRING_OBAL	;dcb5 
	dec h			;dcb8	snizime citac 
	jr nz,PW_HP_LOOP	;dcb9 
	
	call PRINT2SCREEN	;dcbb	cd ff da 	. . . 
	call SET_MAX_31		;dcbe	cd 8c d8 	. . . 
	ld ix,INVENTORY_ITEMS	;dcc1	dd 21 78 ce 	. ! x . 
	xor a			;dcc5	a = 0 
	ld c,MAX_ITEM		;dcc6 
PW_HANDS_LOOP:
	ld b,a			;dcc8	"b" = cislo ruky 0..11
	ld a,(ix+014h)		;dcc9	leva ruka
	call VYKRESLI_RUKU	;dccc 
	inc b			;dccf 
	ld a,(ix+019h)		;dcd0	prava ruka 
	call VYKRESLI_RUKU	;dcd3
	inc b			;dcd6
	ld a,b			;dcd7	schovame cislo ruky do akumulatoru 
	ld b,000h		;dcd8
	add ix,bc		;dcda	+ MAX_ITEM = inventar dalsi postavy  
	cp 12			;dcdc	pocet zobrazenych ruk
	jp nz,PW_HANDS_LOOP	;dcde
	
	di				;dce1	
	ld a,018h			;dce2	a = citac ulozenych obrazku na zasobniku ( vzdy po 2 word ) 
	call VYKRESLI_ZE_ZASOBNIKU	;dce4
	
	ld hl,AVATARS		;dce7	odkud se budou cist data
	ld b,006h		;dcea	citac 
PW_AVATARS:
	push bc			;dcec	ochranime citac
	call INIT_COPY_PATTERN2BUFFER_NOZEROFLAG	;dced	cd 9d d6 	. . . 
	pop bc			;dcf0	vratime citac
	djnz PW_AVATARS		;dcf1
	
	call SET_TARGET_SCREEN	;dcf3 
	ld b,002h		;dcf6
PW_KOMPAS_A_SIPKY:
	push bc			;dcf8
	call INIT_COPY_PATTERN2BUFFER_NOZEROFLAG	;dcf9	cd 9d d6 	. . . 
	pop bc			;dcfc 
	djnz PW_KOMPAS_A_SIPKY	;dcfd 
	
	call SET_TARGET_BUFFER	;dcff	cd 76 d8 	. v . 
	call ZOBRAZ_ZIVOTY	;dd02	cd 4b df 	. K . 
	ei			;dd05	fb 	. 
	call SET_MAX_17		;dd06	cd 95 d8 	. . . 
	call AKTUALIZUJ_RUZICI	;dd09	cd d6 de 	. . . 
	ret			;dd0c	c9 	. 

; ----------------------------------
; Tento vstup se pouzije pokud predtim byl vykreslen jiny panel
INVENTORY_WINDOW_OPEN:

INVENTORY_WINDOW_KURZOR:
INVENTORY_WINDOW_REFRESH:

	ld	bc,$0804	; blok o 8 sloupcich a 4 radcich
	ld	hl,Adr_Attr_Buffer + $98
	call	FILL_ATTR_BLOCK

	ld	bc,$0808	; blok o 8 sloupcich a 8 radcich
	ld	hl,Adr_Attr_Buffer + $118
	call	FILL_ATTR_BLOCK
	
	ld	bc,$0804	; blok o 8 sloupcich a 4 radcich
	ld	hl,Adr_Attr_Buffer + $218
	call	FILL_ATTR_BLOCK


; ---------------
; Menime jen aktivni postavu
; INVENTORY_WINDOW_REFRESH:
	; napravo od tvare, mazem jmeno predchozi postavy
	ld	bc,$0A04	; blok o 10 sloupcich a 4 radcich
	ld	hl,Adr_Attr_Buffer + $16
	call	FILL_ATTR_BLOCK

	ld	a,(AKTIVNI_POSTAVA)
	push	af			; ulozime aktivni postavu na zasobnik
	inc	a
	ld	bc,NEXT_NAME
	ld	hl,NAMES-NEXT_NAME
IW_NEXT_NAME:	
	add	hl,bc
	dec	a
	jr	nz,IW_NEXT_NAME
	push	hl
	pop	ix			; ix <- hl
	ld	bc,22*8+1
	call	PRINT2BUFFER
	call	PRINT_STRING
	call	PRINT2SCREEN
	
	pop	af			; nacteme aktivni postavu ze zasobniku
	add	a,a			; 2x
	add	a,a			; 4x
	add	a,AVATARS % 256
	ld	l,a
	adc	a,AVATARS / 256
	sub	l
	ld	h,a			; hl = index na avatar aktivniho hrace

	ld	e,(hl)
	inc	hl
	ld	d,(hl)			; de = ukazatel na sprite avatara aktivniho hrace
	
	ld	bc,$1200
	call	SET_MAX_31		; meni jen akumulator
	di
	call	COPY_SPRITE2BUFFER
	jr	INVENTORY_POKRACUJ

; ---------------
; Menime jen kurzor 
; INVENTORY_WINDOW_KURZOR:
	call	SET_MAX_31		; meni jen akumulator
	di
INVENTORY_POKRACUJ:

;--- Nastrkame spravna data (parametry dale volane fce) na zasobnik a protoze je to zasobnik, posledni kreslene napred.


; ----- obrys postavy, toulec a prostirani
	ld	hl,DODATECNE_V_INVENTARI
	ld	b,4*2
IW_NEXT_DODATECNE: 
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	push	de
	djnz	IW_NEXT_DODATECNE
	
; ----- vykresli podklad pod predmety v inventari


	ld	a,(KURZOR_V_INVENTARI)		; 13:3
	ld	c,a				;  4:1 index predmetu s kurzorem
	ld	b,MAX_ITEM			;  7:2
	xor	a				;  4:1 akumulator pouzijeme jako citac protoze potrebujeme hlidat 2 stavy
	ld	hl,POZICE_V_INVENTARI		; 10:3 ukazatel na seznam pozic jednotlivych predmetu

IW_SACHOVNICE_LOOP:

	ld	de,I_bgm
	cp	c				; jsme na kurzoru?
	jr	z,IW_ULOZ
	
	ld	de,I_bg
	cp	17				; jsme v dvousloupci predmetu
	jr	c,IW_ULOZ
	
	ld	de,I_ram			; jsme jeste na naznacene postave
IW_ULOZ:
	push	de				; adr. spritu
	
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	push	de				; pozice
	
	inc	a
	djnz	IW_SACHOVNICE_LOOP

; v zasobniku mame za sebou souradnice a pod tim adresu obrazku
	
	ld	a,MAX_ITEM + 4		; 2x postava, toulec a prostirani
	call	VYKRESLI_ZE_ZASOBNIKU

; ------- potrebujeme zrusit konturu postavy v mistech kde je predmet
	

; ------------------------------

	
if (ITEM2SPRITE/256) != (ITEM2SPRITE_END/256)
    .error 'Seznam ITEM2SPRITE prekracuje 256 bajtovy segment!'
endif
	ld	de,(AKTIVNI_INVENTAR)			; "de" predmety inventare aktivni postavy
	ld	ixh,ITEM2SPRITE / 256
	ld	b,MAX_ITEM			;  7:2
	ld	a,b				;  4:1
	ld	hl,KURZOR_V_INVENTARI		; 10:3
	sub	(hl)				;  7:1 vykreslujeme odzadu kvuli citaci smycky, takze musime upravit index KURZOR_V_INVENTARI
	ld	c,a
	
	exx
	ld	hl,POZICE_V_INVENTARI	; h'l'
	exx
IW_LOOP_INIT:

	ld	a,(de)			; PODTYP predmetu z inventare
	inc	de			; posunem ukazatel na dalsi predmet v danem inventari
	add	a,a			; 2x
	jr	nz,IW_OBSAZENO
	
	exx
	ld	bc,0
	push	bc
	push	bc
	push	bc
	push	bc
	inc	hl			; h'l' 
	inc	hl			; h'l' posunem ukazatel na pozici x-teho predmetu v panelu 
	exx
	
	jr	IW_NEXT_ITEM
	
IW_OBSAZENO:
	add	a,ITEM2SPRITE % 256
	ld	ixl,a
	
	ld	a,c
	cp	b			; zero flag = pod kurzorem
	
	exx
	
	ld	c,(ix)
	ld	b,(ix+1)
	push	bc			; adresa spritu

	ld	e,(hl)
	inc	hl			; nemeni priznaky!
	ld	d,(hl)			; pozice spritu
	inc	hl			; nemeni prizaky!
	push	de
	
	ld	bc,I_bg			; obsazene predmety maji zakryt konturu postavy ( bohuzel se kresli i tam kde nemusim )
	jr	nz,IW_NENI_KURZOR
	ld	bc,I_bgm		; kurzor!!!
IW_NENI_KURZOR:
			
	push	bc
	push	de
	
	exx
	
IW_NEXT_ITEM:
	djnz	IW_LOOP_INIT


; v zasobniku mame za sebou souradnice a pod tim adresu obrazku
	
	ld	a,2*MAX_ITEM			; predmety postavy
	call	VYKRESLI_ZE_ZASOBNIKU
	
;	zjisti ktere pozice nejsou povolene a ty zamrizuj
	call	ZESEDNI_NEPOVOLENE_POZICE
	
	call	VYKRESLI_AKTIVNI_PREDMET
	
	ei
	call	SET_MAX_17		; 
	
	ret





; -------------------------------------------------------
VYKRESLI_AKTIVNI_PREDMET:
	call TEST_OTEVRENY_INVENTAR	;ddf7	cd a6 ca
	ret	z			; u zavreneho nebudem vykreslovat presah
	
	ld	a,(DRZENY_PREDMET)
	or	a
	ret	z			; nic nedrzi

	ld	ixh,ITEM2SPRITE / 256
	add	a,a			; 2x
	add	a,ITEM2SPRITE % 256
	ld	ixl,a
	
	
 	ld	a,(KURZOR_V_INVENTARI)
 	add	a,a
 	add	a,POZICE_V_INVENTARI % 256
 	ld	l,a
 	adc	a,POZICE_V_INVENTARI / 256
 	sub	l
 	ld	h,a
 
 	ld	c,(hl)
 	inc	hl
 	ld	b,(hl)
 	dec	b			; posunem doleva
 	dec	c			; posunem nahoru

	ld	e,(ix)
	ld	d,(ix+1)
	push	de
	
; 	ld	bc,$1806
	ld	de,I_bgm
	
	push	bc
	call	COPY_SPRITE2BUFFER
	pop	bc
	pop	de
	call	COPY_SPRITE2BUFFER
	ret


; ----------------------
OBAL_SPRITE2BUFFER:
	push	af
	push	hl
	push	de
	call	COPY_SPRITE2BUFFER
	pop	de
	pop	hl
	pop	af
	ret


; -------------------------------------------------------
ZESEDNI_NEPOVOLENE_POZICE:
	ld	a,(DRZENY_PREDMET)
	or	a
	ret	z			; nic nedrzi = vse povolene
	
	ld	de,I_zakazano
	
	cp	MAX_RING_PLUS_1
	jr	c,ZNP_PRSTEN
	ld	bc,POZICE_PPRSTEN
	call	OBAL_SPRITE2BUFFER
	ld	bc,POZICE_LPRSTEN
	call	OBAL_SPRITE2BUFFER	
ZNP_PRSTEN:

	cp	MIN_FOOD
	jr	nc,ZNP_FOOD
	ld	bc,POZICE_PROSTIRANI
	call	OBAL_SPRITE2BUFFER	
ZNP_FOOD:

	cp	PODTYP_HELM
	jr	z,ZNP_HELM
	cp	PODTYP_HELM_D
	jr	z,ZNP_HELM
	ld	bc,POZICE_HLAVA
	call	OBAL_SPRITE2BUFFER	
ZNP_HELM:

	cp	PODTYP_NECKLACE
	jr	z,ZNP_NECKLACE
	ld	bc,POZICE_NAHRDELNIK
	call	OBAL_SPRITE2BUFFER	
ZNP_NECKLACE:


	cp	MIN_ARMOR
	jr	c,ZNP_NENI_ARMOR
	cp	MAX_ARMOR_PLUS_1
	jr	c,ZNP_ARMOR
ZNP_NENI_ARMOR:
	ld	bc,POZICE_BRNENI
	call	OBAL_SPRITE2BUFFER	
ZNP_ARMOR:

	cp	PODTYP_ARROW
	jr	z,ZNP_ARROW
	ld	bc,POZICE_TOULEC
	call	OBAL_SPRITE2BUFFER	
ZNP_ARROW:

	cp	PODTYP_BRACERS
	jr	z,ZNP_BRACERS
	ld	bc,POZICE_NATEPNIK
	call	OBAL_SPRITE2BUFFER	
ZNP_BRACERS:

	cp	PODTYP_BOOTS
	jr	z,ZNP_BOOTS
	ld	bc,POZICE_BOTY
	call	OBAL_SPRITE2BUFFER	
ZNP_BOOTS:

	ret





; ------------------------------
; Fce kresli sprity s parametry tahajici ze zasobniku
; VSTUP: a = pocet vykresleni ( = 2x pop )
;        na zasobniku lezi nahore pozice a pod ni lezi adresa spritu
VYKRESLI_ZE_ZASOBNIKU:
	pop	hl		; vytahni navratovou hodnotu
VYKRESLI_ZE_ZASOBNIKU_LOOP:
	pop	bc
	pop	de
	push	hl
	push	af		; ochran citac
	inc	d
	dec	d
	call	nz,COPY_SPRITE2BUFFER
	pop	af
	pop	hl
	dec	a
	jr	nz,VYKRESLI_ZE_ZASOBNIKU_LOOP
	jp	(hl)
	
	
	
; VSTUP:    
;	a = PODTYP predmetu
;	b = cislo ruky od 0
; MENI:
;	a, hl, de
; VYSTUP:   vraci zero-flag pokud je prazdna
VYKRESLI_RUKU:
	pop	hl				; vytahni navratovou adresu
	ld	(VR_EXIT+1),hl			; nastav "jp nn" na konci fce
	add	a,a				; v tabulce jsou 16 bit hodnoty
	add	a, ITEM2SPRITE % 256
	ld	(VR_SELF_ITEM + 1),a	;
   
if ( POZICE_RUKOU / 256 ) != ( POZICE_RUKOU_END / 256 )
    .error 'Seznam POZICE_RUKOU prekracuje 256 bajtovy segment!'
endif

	ld	a,POZICE_RUKOU % 256
	add	a,b
	add	a,b				; protoze jde o 16 bit
	ld	(VR_SELF_POZICE + 1),a	;
VR_SELF_ITEM:
	ld	hl,(ITEM2SPRITE)		; hl = adresa spravneho spritu
	ld	a,h				; byl nulovy?
	or	a
	jr	nz,VR_DRZI
	ld	hl,I_empty			; obrazek prazdne dlane pokud nic nedrzi
VR_DRZI:
	push	hl				; ulozime na zasobnik adresu spritu
VR_SELF_POZICE:
	ld	hl,(POZICE_RUKOU)		; 
	push	hl				; prihodime na zasobnik i pozici
	ld	de,I_bg				; prazdny podklad
	push	de				; ulozime na zasobnik adresu podkladoveho spritu
	push	hl               		; prihodime na zasobnik i pozici  
VR_EXIT:
	jp	0				; self-modifying


; ----------------------------------
; nataci kompas
AKTUALIZUJ_RUZICI:
	ld	a,(VECTOR)			; 13:3 0 = N,1 = E,2 = S,3 = W
	add	a,a				;  4:1 2x
	add	a,a				;  4:1 4x
	add	a,RUZICE % 256			;  7:2
	ld	l,a				;  4:1
if (RUZICE/256) != (RUZICE_END/256)
.warning 'O 2 bajty delsi kod, RUZICE a RUZICE_END lezi na dvou segmentech!'

	adc	a,RUZICE / 256			;  7:2 resi preteceni
	sub	l				;  7:2 
	ld	h,a				;  4:1 hl = ukazatel na ukazatel spravneho spritu

else
	ld	h,RUZICE / 256			;  7:2 resi preteceni
.warning 'Kratsi kod, RUZICE a RUZICE_END lezi na stejnem segmentu.'

endif	
	call	SET_TARGET_SCREEN		; prepis COPY_PATTERN2BUFFER na SCREEN
	di
	call	INIT_COPY_PATTERN2BUFFER
	ei
	call	SET_TARGET_BUFFER		; vrat INIT_COPY_PATTERN2BUFFER na BUFFER
	ret

; ----------------------------
; VSTUP: a = 0 dopredu, 4 dozadu , 8 vlevo, 12 vpravo, 16 otoceni doleva, 20 otoceni doprava, 24 jen sipky
AKTUALIZUJ_SIPKY:

if (SIPKY/256) != (SIPKY_END/256)
    .error 'SIPKY nemaji shodny 256 bajtovy segment!'
endif
	add	a,STISKNUTA_SIPKA % 256		; 7:2
	ld	l,a				; 4:1
	ld	h,STISKNUTA_SIPKA / 256		; 7:2
	push	hl

	ld	l,SIPKY % 256

	call	SET_TARGET_SCREEN		; prepis INIT_COPY_PATTERN2BUFFER na SCREEN, meni jen akumulator
	di
	call	INIT_COPY_PATTERN2BUFFER	; samotne nestisknute sipky = smaze predchozi stisk
	pop	hl
	call	INIT_COPY_PATTERN2BUFFER	; konkretni stisknuta sipka
	ei
	call	SET_TARGET_BUFFER		; vrat INIT_COPY_PATTERN2BUFFER na BUFFER
	ret

	
; ---------------------------------------------
; Fce kresli plnou vodorovnou caru po znacich
; VSTUP:	HL = adresa odkud zacnem
;		b  = pocet znaku
HORIZONTAL_LINE:
	ld	a,$ff
; Fce kresli vodorovnou caru po znacich vyplnenou registrem "c"
; VSTUP:	HL = adresa odkud zacnem
;		b  = pocet znaku
;		a  = vypln
; VYSTUP: Meni l += b
HORIZONTAL_LINE_LOOP:
	ld	(hl),a
	inc	l
	djnz	HORIZONTAL_LINE_LOOP
	ret

; ---------------------------------------------
; Fce vyplni dany blok hodnotou $ff, sirka a vyska je po znacich
; Fce kresli vodorovnou caru po znacich vyplnenou registrem "a"
; VSTUP:	HL = adresa odkud zacnem
;		ixh  = pocet znaku na sirku
;		ixl  = pocet znaku na vysku
;		e = vzor, kterym budeme plnit
;       	d = pocet mikroradku
; pozor, nehlida tretiny
FILL_BLOCK:
	ld	a,l		; nastavime na prvni znak a budeme postupne zvysovat o 32 => o znak nize

FB_DALSI_MICROLINE:
	push	af
	ld	c,ixl		; nastavime citac poctu radku
FB_DALSI_RADEK:
	ld	b,ixh
	
	FB_DALSI_SLOUPEC:
		ld	(hl),e
		inc	l
		djnz	FB_DALSI_SLOUPEC

	add	a,32
	ld	l,a		; stejna mikroradka o znak/radek nize
	dec	c
	jr	nz,FB_DALSI_RADEK
	
	pop	af
	ld	l,a
	dec	d
	ret 	z		; pokud byla vyplnena jen jedna mikroradka ( atributy ) tak hl nebylo zmeneno
	
	inc	h		; o mikroradek nize
	jp	FB_DALSI_MICROLINE
	
; 40 -> 58 0100 0000 -> 0101 1000, E8
; 48 -> 59 0100 1000 -> 0101 1001, EF
; 50 -> 5A 0101 0000 -> 0101 1010, F6
;----------------------

FILL_ATTR_BLOCK:
	ld	ixh,b			; 8:2 push bc + pop ix = 11+14:1+2
	ld	ixl,c			; 8:2
	ld	de,$0107		; 10:3 jen 1 mikroradek a bila barva (vzor)
	call	FILL_BLOCK

	call	SEG_ATTR2SCREEN
	ld	de,$0800		; 8 mikroradku a vyplnujeme nulama
	call	FILL_BLOCK
	ret
	

; meni A a z HL ukazujici na atributy udela HL ukazujici na ZNAK ve screen/buffer
; Fce prevadejici segment atributu na segment obrazu
;	               10xy     10xy
;	$58 -> $40 01011000 -> 01000000
;	$59 -> $48 01011001 -> 01001000
;	$5A -> $50 01011010 -> 01010000
; VSTUP:
; H = $58, $58, $5A nebo $FB, $FC, $FD
; VYSTUP:
; H = $40, $48, $50 nebo $E3, $EB, $F3
SEG_ATTR2SCREEN:
	ld a,h				;df3a	do akumulatoru dame segment atributu
	ld h,Adr_Buffer/256		;df3b	segment prvni tretiny buferu obrazovky
	sub Adr_Attr_Buffer/256		;df3d	odecteme od segmentu atributu segment pocatku atributu v buferu 
	jr nc,FILL_ATTR_BLOCK_SCREEN	;df3f	0,1,2 => nc = dodany segment je z buferu; zaporny vysledek => dodany segment byl z obrazovky 
	ld h,$40			;df41	segment prvni tretiny obrazovky ZX
	add a,Adr_Attr_Buffer/256 - $58	;df43	+$A3, spletli jsme se, meli jsme odcitat -$58 a ne Adr_Attr_Buffer/256
FILL_ATTR_BLOCK_SCREEN:
	add a,a				;df45	chceme jen posledni 2 bity a ty vynasobit osmi a pricist k segmentu zacatku obrazu
	add a,a				;df46	4x 
	add a,a				;df47	8x 
	add a,h				;df48	 
	ld h,a				;df49	 
	ret				;df4a	

	


ZOBRAZ_ZIVOTY:
    ld      DE, DATA_ZIVOTY             ;
    ld      B, $06                      ; 6 postav 
ZZ_LOOP:
    push    BC                          ; 
    call    VYKRESLI_PROUZEK            ;
    ld      A, (DE)                     ; hodnota posledniho zraneni 
    inc     DE                          ; adresa casu ukonceni krvaveho fleku
    or      A                           ; 
    call    nz,VYKRESLI_KRVAVY_FLEK     ; 
    inc     DE                          ; adresa aktualniho poctu zivotu dals postavy
    pop     BC                          ; 
    djnz    ZZ_LOOP                     ; 
    ret                                 ; 

; VSTUP: DE = cas ukonceni krvaveho fleku
VYKRESLI_KRVAVY_FLEK:
	push de			;dfe3	d5 	. 
	ld a,(de)		;dfe4	1a 	. 
	dec de			; ukazatel na hodnotu posledniho zraneni 
	ld hl,TIMER_ADR		;
	cp (hl)			;dfe9	be 	. 
	jp p,VKF_POKRACUJ	;dfea	f2 f1 df 	. . . 
	xor a			; cas vyprsel 
	ld (de),a		; vynulovani hodnoty posledniho zraneni
	pop de			;dfef	d1 	. 
	ret			;dff0	c9 	. 
	
DATA_ZIVOTY:
;       nyni    max     offset  segment pocatku prouzku posledni zraneni    cas ukonceni krvaveho fleku
defb    132,    132,    $b4,    Adr_Attr_Buffer/256+0,  0,                  0
defb    90,     90,     $bb,    Adr_Attr_Buffer/256+0,  0,                  0
defb    64,     64,     $94,    Adr_Attr_Buffer/256+1,  0,                  0
defb    40,     40,     $9b,    Adr_Attr_Buffer/256+1,  0,                  0
defb    46,     46,     $74,    Adr_Attr_Buffer/256+2,  0,                  0
defb    40,     40,     $7b,    Adr_Attr_Buffer/256+2,  0,                  0
DATA_ZIVOTY_END:


;defb	$82,$84,$b4,$fb,0,$34 
;defb	$58,$5a,$bb,$fb,0,$34
;defb	$3e,$40,$94,$fc,0,$34
;defb	$26,$28,$9b,$fc,0,$34
;defb	$2c,$2e,$74,$fd,0,$34 
;defb	$26,$28,$7b,$fd,0,$34
 
 
; -----------------------------------------------------------
; VSTUP: DE adresa na aktualni pocet zivotu
; MENI:  HL, BC, A
; VYSTUP: DE = adresa posledniho zraneni
VYKRESLI_PROUZEK:
    xor     A                   ;  4:1 A = 0
    ex      DE, HL              ;  4:1
    ld      C, (HL)             ;  7:1 C = aktualni pocet zivotu
    inc     HL                  ;  6:1 ukazatel na max. pocet zivotu
    ld      E, (HL)             ;  7:1 E = maximalni pocet zivotu
    inc     HL                  ;  6:1 ukazatel na adresu pocatku prouzku
    push    HL                  ; 11:1
    
    ld      B, A                ;  4:1 BC = aktualni pocet zivotu
    ld      L, C
    ld      H, A                ;  4:1 HL = aktualni pocet zivotu
    ld      D, A                ;  4:1 DE = maximalni pocet zivotu
    add     HL, HL              ; 11:1 2x 
    add     HL, HL              ; 11:1 4x 
    add     HL, BC              ; 11:1 5x
    ld      C, A                ;  4:1 C = 0
    scf                         ;  4:1 (= dec HL)
VP_ZNAKU:
    dec     C                   ;  4:1
    sbc     HL, DE              ; 15:2
    jr      nc, VP_ZNAKU        ; 12/7:2
    adc     HL, DE              ; 15:2 HL = zbytek = 0..maximalni pocet zivotu
    
    add     HL, HL              ; 11:1 2x
    add     HL, HL              ; 11:1 4x
    add     HL, HL              ; 11:1 8x zbytek
VP_ZBYTEK:
    inc     A                   ;  4:1
    sbc     HL, DE              ; 15:2
    jr      nc, VP_ZBYTEK       ; 12/7:2
    
    pop     HL                  ; 10:1

    ; C = -(znaku+1) = -1..-5
    ; A = zbytek+1 = 1..9
    
    add     A,(CARKY-1)%256     ; offset + 1..8
    ld      (VP_LOOP_SELF+1),A  ; 

    ; set color
    ld      E, (HL)             ; offset zacatku prouzku
    inc     HL                  ;
    ld      D, (HL)             ; segment zacatku prouzku
    inc     HL                  ;
    ex      DE,HL               ;  4:1 DE = ukazatel na hodnotu posledniho zraneni, HL = adresa zacatku prouzku (attr)
    ld      A,C                 ;  4:1 zaporny pocet znaku prouzku  -5 = ..011, -4 = ..100, -3 = ..101, -2 = ..110, -1 = ..111
    inc     A                   ;  4:1  -4 = ..10., -3 = ..10., -2 = ..11., -1 = ..11.
    jr      nz, VP_VICEZNAKOVY  ; 12/7:2
    ld      a, $42              ; light red = ..01.
VP_VICEZNAKOVY:
    and     $46                 ; 0100 0110 = BRIGHTNES + INK GREEN + INK RED
    ld      (VP_COL_SELF+1), A  ;
    
    ld      b, $05              ; 5 znaku 

if ((CARKY-1) / 256) != ( CARKY_END / 256 )
    .error 'Seznam CARKY prekracuje segment!'
endif
	
VP_LOOP_SELF:
    ld      A, (CARKY)          ; 13:3 obsahuje znak predelu konce prouzku 
    inc     C                   ;  4:1 zmensime zaporny pocet celych znaku
    jr      z, VP_PREDEL        ;12/7:2 posledni znak? 
    ld      A, C                ;  4:1
    rla                         ;  4:1 carry kdyz C < 0
    sbc      A,A                ;  4:1 if (carry) A = $ff else A = $00
VP_PREDEL:

VP_COL_SELF:
    ld      (HL), $00           ; barva prouzku 
    push    HL                  ; uschovame adresu zacatku prouzku 
    push    BC                  ; uschovame hodnotu registru B
    ld      C, A                ; "prouzek" do C
    call    SEG_ATTR2SCREEN     ; zrusi A, z HL ukazujici na atributy udela HL ukazujici na screen/buffer
    ld      B, $06              ; 6 carek
VP_LOOP_PX:
    inc     H                   ; prvne klesneme o pixel
    ld      (HL), C             ; ulozime "prouzek"
    djnz    VP_LOOP_PX          ; 
    pop     BC                  ; obnovime hodnotu registru B
    pop     HL                  ; obnovime adresu zacatku prouzku
	
    inc     L                   ; o znak doprava

    djnz    VP_LOOP_SELF        ; 5x 
    ret                         ; 


    
; VSTUP: DE = adresa posledniho zraneni
VKF_POKRACUJ:
	dec de			; adresa segmentu pocatku prouzku
	ld a,(de)		;
	ld c,a			; segment pocatku prouzku 
	add a,a			;dff4	87 	. 
	add a,a			;dff5	87 	. 
	add a,a			;dff6	87 	. 
	sub c			;dff7	91 	. 
	sub 0d9h		;dff8	d6 d9 	. . 
	ld c,a			;dffa	4f 	O 
	dec de			;dffb	1b 	. 
	ld a,(de)		;dffc	1a 	. 
	and 01fh		;dffd	e6 1f 	. . 
	dec a			;dfff	3d 	= 
	ld b,a			;e000	47 	G 
	push bc			;e001	c5 	. 
	ld de,Flek		;e002	11 1a 70 	. . p 
	call OBAL_SPRITE2BUFFER	;e005	cd 2d de 	. - . 
	pop bc			;e008	c1 	. 
	call PRINT2BUFFER	;e009	cd f9 da 	. . . 
	ld a,b			;e00c	78 	x 
	add a,003h		;e00d	c6 03 	. . 
	add a,a			;e00f	87 	. 
	add a,a			;e010	87 	. 
	add a,a			;e011	87 	. 
	ld b,c			;e012	41 	A 
	inc b			;e013	04 	. 
	ld c,a			;e014	4f 	O 
	ld ix,JEDNA		;e015	dd 21 21 e0 	. ! ! . 
	call PRINT_STRING	;e019	cd 0d db 	. . . 
	call PRINT2SCREEN	;e01c	cd ff da 	. . . 
	pop de			;e01f	d1 	. 
	ret			;e020	c9 	. 
	
JEDNA:
defb	"1",0



; VSTUP: E = index postavy hrace 0..5
;        D = zraneni
ZRAN_POSTAVU:
	push hl			;

	ld a,e			;
	add a,a			; 2xE 
	add a,e			; 3xE
	add a,a			; 6xE 

if (DATA_ZIVOTY / 256) != ( DATA_ZIVOTY_END / 256 )
    .error 'Seznam DATA_ZIVOTY prekracuje segment!'
endif
	
	add a,DATA_ZIVOTY % 256	; 
	ld l,a			; 
	ld h,DATA_ZIVOTY / 256	; 
	ld a,(hl)		; aktualni pocet zivotu 
	sub d			; - zraneni 
	jr nc,ZP_ZIJE		; 
	xor a			; zemrel, vynulujeme zaporne zivoty na nulu 
	ld (hl),a		; ulozime nulu
	jr ZP_EXIT		;
ZP_ZIJE:
	ld (hl),a		; ulozime zbyvajici pocet zivotu
	inc hl			; +1
	inc hl			; +2 
	inc hl			; +3 
	inc hl			; +4 
	ld (hl),d		; ulozim hodnotu posledniho zraneni 
	inc hl			; +5 
	ld a,(TIMER_ADR)	; 
	add a,032h		; +50 = +1 vterina
	ld (hl),a		; doba zobrazovani krvaveho fleku s hodnotou zraneni 
ZP_EXIT:
	pop hl			;e044	e1 	. 
	ret			;e045	c9 	. 


; ????????????????????????????????????????
PLAYERS_WINDOW_AND_DAMAGE:
	ld a,002h		; hmm tady mela byt asi nula
	ld hl,TIMER_ADR		; 1/50 vteriny citac
	xor (hl)		; je hornibit shodny s ulozenym 
	and 080h		; zajima nas jen horni bit
	jr z,PWAD_NEZRANUJ	; 
	
	ld a,(hl)		; ulozime horni bit
	ld (PLAYERS_WINDOW_AND_DAMAGE+1),a	;e051	32 47 e0
	
	ld de,$0100		; D = 1 = zraneni, E = 0 = index postavy 
	ld b,$06		; citac = 6 
PWAD_LOOP:
	call ZRAN_POSTAVU	; 
	inc e			; dalsi postava
	djnz PWAD_LOOP		;
PWAD_NEZRANUJ:
	call PLAYERS_WINDOW	;e05f	cd 67 dc 
	ret			;e062	c9 

; Najde pocatek x-teho retezce zakonceny nulou od pocatecni adresy
; VSTUP:    hl pocatecni adresa
;           b kolikaty retezec hledam od nuly
; VYSTUP:   IX = hl + b * delky_retezcu
ADR_X_STRING:
    xor     a
AXS_LOOP:
    ld      c,$ff           ; pokud by byl retezec delsi jak 255 znaku tak mame smulu
    cpir                    ; hl++, bc--
    djnz    AXS_LOOP
    push    hl
    pop     ix
    ret


; VSTUP: hl = odkud, de = kam
STRING_COPY:
	ld	a,(hl)
	inc	hl
	ld	(de),a
	inc	de
	or	a
	jr	nz,STRING_COPY
	ret




; VSTUP: b index predmetu
ITEM_TAKEN:
	ld	hl,STRING_ITEM
	call	ADR_X_STRING
	
	ld	de,ITEM_STRING
	push	de
	pop	ix
	
	call	STRING_COPY
	ld	hl,VETA_TAKEN
	dec	de			; zrusim nulu predchoziho retezce
	call	STRING_COPY
	
	call	PRINT_MESSAGE
	ret
ITEM_STRING:





if (ITEM_STRING + 52) > ( pismoStart )
    .error 'Data fontu prepisuji konec kodu... Sniz hodnotu progStart a nezapomen zmenit hodnotu RANDOMIZE USR.'
endif




	

org	pismoStart

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





	

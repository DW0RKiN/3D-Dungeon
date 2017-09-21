; lokace    = dolnich 8 bitu pozice na mape, pokud je nulova tak radek pridava dalsi informace k predchozimu
; typ       = bity 0,1 = dolni 2 bity natoceni v danem ctverci
; typ       = bity 2,3,4 = identifikace objektu: prepinac, enemy, dvere, wall (zrusit a pridat bit do mapy), runa... 
; typ       = bity 5,6,7 = nenulove horni 3 bity = nepruchozi ( u dveri zaroven zavreno )
; dodatecny = bity 0,1,2,3,4 podtyp objektu
; dodatecny u dveri 
; %???? ???0 ram dveri V-Z = chodba S-J, tzn vidime uvnitr dveri pri natoceni V nebo Z
; %???? ???1 ram dveri S-J = chodba V-Z, tzn vidime uvnitr dveri pri natoceni S nebo J

TYP_DVERE_SJ		equ	TYP_DVERE
TYP_DVERE_VZ		equ	(TYP_DVERE+1)

ADR_ZARAZKY
defw	ZARAZKA					; ma ukazovat adresu $ff zarazky v TABLE_ITEM, pouziva se pri brani/vkladani radku


TABLE_ITEM:	; POZOR! Predmety neustale udrzuj ve vzestupne lokaci a nasledne ve vzestupnem natoceni
;	lokace	prepinace+typ			dodatecny
defb	1,	$00 + TYP_DEKORACE		, PODTYP_KANAL

defb	6,	$00 + TYP_DEKORACE		, PODTYP_RUNA

defb	16,	TYP_ITEM			, PODTYP_SWORD
defb	16,	TYP_ITEM + i_ne			, PODTYP_DAGGER
defb	16,	TYP_ITEM + i_se			, PODTYP_SWORD
defb	16,	TYP_ITEM + i_sw			, PODTYP_SHIELD

defb	17,	TYP_ITEM			, PODTYP_BONE
defb	17,	TYP_ITEM + i_ne			, PODTYP_SHIELD
defb	17,	TYP_ITEM + i_se			, PODTYP_SHIELD
defb	17,	TYP_ITEM + i_sw			, PODTYP_SHIELD

defb	21,	4 * 32 + TYP_ENEMY + east	, $80 + PODTYP_SKRET

defb	32,	TYP_ITEM			, PODTYP_MACE
defb	32,	TYP_ITEM + i_ne			, PODTYP_BOW
defb	32,	TYP_ITEM + i_se			, PODTYP_SLING
defb	32,	TYP_ITEM + i_sw			, PODTYP_AXE

defb	33,	TYP_ITEM			, PODTYP_SHIELD
defb	33,	TYP_ITEM + i_ne			, PODTYP_SHIELD
defb	33,	TYP_ITEM + i_se			, PODTYP_SHIELD
defb	33,	TYP_ITEM + i_sw			, PODTYP_SHIELD

defb	48,	TYP_ITEM			, PODTYP_SWORD

defb	68,	4 * 32 + TYP_ENEMY + east	, $80 + PODTYP_SKRET

defb	95,	$00 + TYP_DEKORACE		, PODTYP_KANAL

defb	115,	$00 + TYP_DEKORACE		, PODTYP_KANAL

defb	119,	$80 + TYP_DVERE_VZ		, $81

defb	129,	$00 + TYP_DEKORACE		, PODTYP_RUNA

defb	132,	$00 + TYP_PREPINAC + south	, south
defb	0,	119				, $80 + TYP_DVERE_VZ	; aktivace paky prepne predmet na lokaci 119 s typem dvere

defb	142,	$80 + TYP_DVERE_SJ		, $80			; 

defb	158,	$E0 + TYP_DVERE_SJ		, $80			; $E0 = zavreno az na 3 bity!!!

defb	176,	$00 + TYP_DEKORACE		, PODTYP_KANAL

; ---------- ctverice pak na dvere 158

PAKA_A	equ	185
PAKA_B	equ	186
PAKA_C	equ	187
PAKA_D	equ	188

; Bit dveri    7 6 5
; Paka       A B C D = 185 .. 188
; zaroven s  + + + +  
; pakou      B C D B
; a zaroven  C
; a jeste    D 


;	lokace	prepinace+typ			dodatecny

defb	PAKA_A,	$00 + TYP_PREPINAC + south	, south				; paka A meni dvere 142 a paky pro dvere 158 (takze rovnou otevre dvere pokud jsou shodne nahore)
defb	0,	142				, $80 + TYP_DVERE_SJ		; meni bit $80
defb	0,	158				, $E0 + TYP_DVERE_SJ		; celkove meni bity $20 + $40 + $80
defb	0,	PAKA_B				, $80 + TYP_PREPINAC + south	; zmeni i paku B
defb	0,	PAKA_C				, $80 + TYP_PREPINAC + south	; zmeni i paku C
defb	0,	PAKA_D				, $80 + TYP_PREPINAC + south	; zmeni i paku D

defb	PAKA_B,	$00 + TYP_PREPINAC + south	, $80 + south			; paka B primarne meni bit 7 na dverich v lokaci 158
defb	0,	158				, $C0 + TYP_DVERE_SJ		; celkove meni bity $80(B) + $40(C)
defb	0,	PAKA_C				, $80 + TYP_PREPINAC + south	; zmeni i paku C

defb	PAKA_C,	$00 + TYP_PREPINAC + south	, south				; paka C primarne meni bit 6 na dverich v lokaci 158
defb	0,	158				, $60 + TYP_DVERE_SJ		; celkove meni bity $40(C) + $20(D)
defb	0,	PAKA_D				, $80 + TYP_PREPINAC + south	; zmeni i paku D

defb	PAKA_D,	$00 + TYP_PREPINAC + south	, $80 + south			; paka D primarne meni bit 5 na dverich v lokaci 158
defb	0,	158				, $A0 + TYP_DVERE_SJ		; celkove meni bity $20(D) + $80(B)
defb	0,	PAKA_B				, $80 + TYP_PREPINAC + south	; zmeni i paku B

; ----------

defb	216,	$00 + TYP_PREPINAC + east	, west
defb	0,	216				, $80 + TYP_PREPINAC + west	; prepne i paku na druhe strane
defb	0,	232				, $80 + TYP_DVERE_VZ		; aktivace paky prepne predmet na lokaci 232 s typem dvere

defb	216,	$00 + TYP_PREPINAC + west	, west
defb	0,	216				, $80 + TYP_PREPINAC + east	; prepne i paku na druhe strane
defb	0,	232				, $80 + TYP_DVERE_VZ		; aktivace paky prepne predmet na lokaci 232 s typem dvere

defb	232,	$80 + TYP_DVERE_VZ		, $81

defb	246,	$00 + TYP_DEKORACE		, PODTYP_RUNA

defb	254,	$00 + TYP_DEKORACE		, PODTYP_KANAL
ZARAZKA:
defb	TYP_ZARAZKA	; zarazka
REPT	20
defb	0,0,0
ENDM
TYP_ZARAZKA	equ	$ff



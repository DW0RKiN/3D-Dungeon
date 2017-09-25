MAX_INVENTORY	equ	27





; vvvvvvvvvvvvvvvvvvvvvvvvv zacatek souvisleho bloku vvvvvvvvvvvvvvvvvvvvvvvvv
; Tabulka prevodu jednobytove identifikace predmetu na 2D sprite
ITEM2SPRITE:
defw    0
defw    I_ring          ; PODTYP_RING		equ	1*POSUN_PODTYP
defw    I_ring_r        ; PODTYP_RING_R		equ	2*POSUN_PODTYP
defw    I_ring_g        ; PODTYP_RING_G		equ	3*POSUN_PODTYP
defw    I_ring_b        ; PODTYP_RING_B		equ	4*POSUN_PODTYP
defw    I_ring_w        ; PODTYP_RING_W		equ	5*POSUN_PODTYP
MAX_RING_PLUS_1     equ (1+PODTYP_RING_W)
;---
defw    I_helm          ; PODTYP_HELM	equ	6*POSUN_PODTYP
defw    I_helm_d        ; PODTYP_HELM_D	equ	7*POSUN_PODTYP
defw    I_necklace      ; PODTYP_NECKLACE	equ	8*POSUN_PODTYP
;--
MIN_ARMOR           equ PODTYP_ARMOR
defw    0               ; PODTYP_ARMOR	equ	9*POSUN_PODTYP
defw    I_armor_ch      ; PODTYP_ARMOR_CH	equ	10*POSUN_PODTYP
defw    I_armor_l       ; PODTYP_ARMOR_L	equ	11*POSUN_PODTYP
defw    I_armor_p       ; PODTYP_ARMOR_P	equ	12*POSUN_PODTYP
MAX_ARMOR_PLUS_1    equ (1+PODTYP_ARMOR_P)
;--
defw    0               ; PODTYP_ARROW	equ	13*POSUN_PODTYP
defw    0               ; PODTYP_BRACERS	equ	14*POSUN_PODTYP
defw    I_boots         ; PODTYP_BOOTS	equ	15*POSUN_PODTYP
;---
defw    I_ankh          ; PODTYP_ANKH		equ	16*POSUN_PODTYP
defw    I_axe           ; PODTYP_AXE		equ	17*POSUN_PODTYP
defw    I_book          ; PODTYP_BOOK		equ	18*POSUN_PODTYP
defw    I_bow           ; PODTYP_BOW		equ	19*POSUN_PODTYP
defw    I_dagger        ; PODTYP_DAGGER		equ	20*POSUN_PODTYP
defw    I_mace          ; PODTYP_MACE		equ	21*POSUN_PODTYP
defw    I_shield        ; PODTYP_SHIELD		equ	22*POSUN_PODTYP
defw    I_shield2       ; PODTYP_SHIELD2	equ	23*POSUN_PODTYP
defw    I_sling         ; PODTYP_SLING		equ	24*POSUN_PODTYP
defw    I_sword         ; PODTYP_SWORD		equ	25*POSUN_PODTYP
defw    I_bone          ; PODTYP_BONE		equ	26*POSUN_PODTYP
;---
MIN_FOOD            equ PODTYP_FOOD
defw    I_rations       ; PODTYP_FOOD	equ	27*POSUN_PODTYP
defw    I_potion_r      ; PODTYP_POTION_R	equ	28*POSUN_PODTYP
defw    I_potion_g      ; PODTYP_POTION_G	equ	29*POSUN_PODTYP
defw    I_potion_b      ; PODTYP_POTION_B	equ	30*POSUN_PODTYP
ITEM2SPRITE_END:
; ^^^^^^^^^^^^^^^^^^^^^^^^^ konec souvisleho bloku ^^^^^^^^^^^^^^^^^^^^^^^^^ 



INVENTORY_ITEMS:
;	0		1		2		3		4		5		6		7		8		9		10		11		12		13		14		15
; player 0
defb	PODTYP_ARMOR_P,	PODTYP_SHIELD,	PODTYP_FOOD,	PODTYP_FOOD,	PODTYP_ANKH,	0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0
;	prostirani	hlava		nahrdelnik	brneni		l.ruka		l.prsten	boty		toulec		chran.predlokti	p.ruka		p.prsten
defb	0,		PODTYP_HELM_D,	0,		PODTYP_ARMOR_CH,PODTYP_AXE,	0,		PODTYP_BOOTS,	0,		0,		PODTYP_SHIELD,	PODTYP_RING_B		

; player 1
defb	PODTYP_FOOD,	PODTYP_DAGGER,	0,		0, 		PODTYP_ANKH,	0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0
defb	0,		PODTYP_HELM,	PODTYP_NECKLACE,PODTYP_ARMOR_P,	PODTYP_SWORD,	PODTYP_RING_R,	0,		0,		0,		PODTYP_SHIELD,	0		

; player 2
defb	PODTYP_POTION_R,PODTYP_POTION_R,PODTYP_POTION_G,PODTYP_POTION_B,PODTYP_ANKH,	0,		0,		0,		PODTYP_DAGGER,	0,		0,		0,		0,		0,		0,		0
defb	0,		0,		PODTYP_NECKLACE,PODTYP_ARMOR_L,	PODTYP_MACE,	0,		PODTYP_BOOTS,	0,		0,		PODTYP_ANKH,	0		

; player 3
defb	PODTYP_DAGGER,	PODTYP_SHIELD2,	PODTYP_FOOD,	0,		PODTYP_SLING,	0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0
defb	0,		0,		0,		0,		PODTYP_DAGGER,	PODTYP_RING_W,	PODTYP_BOOTS,	0,		0,		PODTYP_DAGGER,	0		

; player 4
defb	PODTYP_DAGGER,	PODTYP_SHIELD,	0,		0,		PODTYP_BONE,	0,		0,		0,		0,		0,		0,		PODTYP_BOW,	0,		0,		0,		0
defb	0,		0,		0,		0,		PODTYP_BOW,	0,		0,		0,		0,		0,		0		

; player 5
defb	PODTYP_DAGGER,	PODTYP_SHIELD,	0,		0,		0,		0,		0,		PODTYP_MACE,	0,		0,		0,		0,		0,		0,		0,		0
defb	0,		0,		PODTYP_NECKLACE,0,		0,		PODTYP_RING_G,	0,		0,		0,		PODTYP_BOOK,	PODTYP_RING

INVENTORY_ITEMS_END:


PRESOUVANY_PREDMET:
defb	0
KURZOR_V_INVENTARI:
defb	0              ; 1..MAX_INVENTORY


POZICE_PROSTIRANI	equ	$1904
POZICE_HLAVA		equ	$1A07
POZICE_NAHRDELNIK	equ	$1A09
POZICE_BRNENI		equ	$1A0B
POZICE_LPRSTEN		equ	$1810
POZICE_BOTY		equ	$1A12
POZICE_TOULEC		equ	$1D09
POZICE_NATEPNIK		equ	$1D0B
POZICE_PPRSTEN		equ	$1C10

; vvvv ----------------- zacatek souvisleho bloku
DODATECNE_V_INVENTARI:
defw	Body_left,	$1907,	Body_left,	$1DF8
defw	I_prostirani,	$1904,	I_toulec,	$1D09

POZICE_V_INVENTARI:
defw	$1204, $1206, $1208, $120A, $120C, $120E, $1210, $1212
defw	$1504, $1506, $1508, $150A, $150C, $150E, $1510, $1512

defw	POZICE_PROSTIRANI	; prostirani
defw	POZICE_HLAVA		; hlava
defw	POZICE_NAHRDELNIK	; nahrdelnik
defw	POZICE_BRNENI		; brneni
defw	$180D			; l.ruka
defw	POZICE_LPRSTEN		; l.prsten
defw	POZICE_BOTY		; boty

defw	POZICE_TOULEC		; toulec
defw	POZICE_NATEPNIK		; natepnik / chranic predlokti
defw	$1C0D			; p.ruka
defw	POZICE_PPRSTEN		; p.prsten
; ^^^^ ----------------- konec souvisleho bloku

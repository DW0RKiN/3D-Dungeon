NEXT_PAKA	equ	120
PAKA_DOWN	equ	60
NEXT_ENEMY	equ	72


; ------------ aktualni adresa podfce je v test.asm

;              cisla rohu pri pohledu danym smerem
;              levy zadni ma vzdy index stejny jako smer pohledu
;Sever  = 0     0 1
;              3   2

;Vychod = 1     1 2
;              0   3

;Jih    = 2     2 3
;              1   0

;Zapad  = 3     3 0
;              2   1

;VECTOR:
;defb        north   ; 0 = N,1 = E,2 = S,3 = W 


if (0)
i_ld        equ     0       ; predmet vidim jako levy-dal
i_pd        equ     2       ; predmet vidim jako pravy-dal
i_pb        equ     4       ; predmet vidim jako pravy-bliz
i_lb        equ     6       ; predmet vidim jako levy-bliz
endif

;SMAZ_NA_KONCI_AZ_NEBUDES_HYBAT_STALE_S_KODEM:
REPT	0	; nejaka hodnota co posune sipky mimo zlom segmentu
defb	0
ENDM



; vvvv -----------------
HLAVNI_POSTAVA:
defb	0	; 0..5
SUM_POSTAV:
defb	6	; 1..6 zpozor musi navazovat s HLAVNI_POSTAVA
AKTIVNI_INVENTAR:
defw	INVENTORY_ITEMS		
; ^^^^ ----------------- musi navazovat a byt v tomto poradi


DRZENY_PREDMET:
defb	0
KURZOR_V_INVENTARI:
defb	0

BORDER:
defb	0



MAX_ITEM	equ	27


; vvvv ----------------- zacatek souvisleho bloku
POZICE_RUKOU:
	defw 01601h		;cf50	01 16 	. . postava 1. horni zbran 
	defw 01603h		;cf52	03 16 	. . postava 1. dolni zbran
	defw 01d01h		;cf54	01 1d 	. . postava 2. horni zbran
	defw 01d03h		;cf56	03 1d 	. . postava 2. dolni zbran
	defw 01608h		;cf58	08 16 	. . postava 3. horni zbran
	defw 0160ah		;cf5a	0a 16 	. . postava 3. dolni zbran
	defw 01d08h		;cf5c	08 1d 	. . postava 4. horni zbran
	defw 01d0ah		;cf5e	0a 1d 	. . postava 4. dolni zbran
	defw 0160fh		;cf60	0f 16 	. . postava 5. horni zbran
	defw 01611h		;cf62	11 16 	. . postava 5. dolni zbran
	defw 01d0fh		;cf64	0f 1d 	. . postava 6. horni zbran
	defw 01d11h		;cf66	11 1d 	. . postava 6. dolni zbran
POZICE_RUKOU_END:
; ^^^^ ----------------- konec souvisleho bloku

AVATARS:
defw	MFace02,	$1201,	FFace02,	$1901
defw	FFace03,	$1208,	FFace04,	$1908
defw	MFace01,	$120F,	FFace01,	$190F

; je label nutny? asi ne, ale musi bezprostredne navazovat za AVATARS
KOMPAS:
defw	Kompas,		$070F

; musi navazovat viz 
SIPKY:
defw	S_vsechny,	$000F		; 
STISKNUTA_SIPKA:
defw	S_dopredu,	$030F		;  0
defw	S_dozadu,	$0311		;  4
defw	S_vlevo,	$0111		;  8 ukrok
defw	S_vpravo,	$0511		; 12 ukrok
defw	S_doleva,	$010F		; 16 otoceni
defw	S_doprava,	$050F		; 20 otoceni
defw	0,		0		; 24
SIPKY_END:

if (SIPKY/256) != ((SIPKY_END-1)/256)
    .error 'Seznam s sipkami nelezi na jednom 256 bajtovem segmentu!'
endif


SIPKA_DOPREDU		equ	0
SIPKA_DOZADU		equ	4
SIPKA_VLEVO		equ	8
SIPKA_VPRAVO		equ	12
SIPKA_OTOCDOLEVA	equ	16
SIPKA_OTOCDOPRAVA	equ	20
SIPKA_NIC		equ	24

RUZICE:
defw	Komp_N,		$080F
defw	Komp_E,		$080F
defw	Komp_S,		$080F
defw	Komp_W,		$080F
RUZICE_END:


POZICE_PROSTIRANI	equ	$1904
POZICE_HLAVA		equ	$1A07
POZICE_NAHRDELNIK	equ	$1A09
POZICE_BRNENI		equ	$1A0B
POZICE_LPRSTEN		equ	$1810
POZICE_BOTY		equ	$1A12
POZICE_TOULEC		equ	$1D09
POZICE_NATEPNIK		equ	$1D0B
POZICE_PPRSTEN		equ	$1C10

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


  

; index do tabulek, ktery znaci ze je nepritel primo pred nama 
ENEMY_ATTACK_DISTANCE	equ	12

ENEMY_GROUP:
;                  3 4                               3(4)                       (3)4
;                 1   2                               1(2)                     (1)2
;                   *                   vpravo      *                   vlevo       *
;       1       2       3       4       1       2       3       4       1       2       3       4
defw    0,      $0,     0,      0,      0,      0,      0,      0,      0,      0,      0,      0
defw    $0305,  $0A05,  $0404,  $0904,  $1105,  0,      $1004,  0,      0,      $FC05,  0,      $FD04   ; 16
defw    $0505,  $0A05,  $0604,  $0904,  $0F05,  0,      $0E04,  0,      0,      $0005,  0,      $0104   ; 10
defw    $0605,  $0905,  $0705,  $0805,  $0D05,  $0F05,  $0C05,  $0E05,  $0005,  $0205,  $0105,  $0305   ; 6
defw    $08FB,  $0904,  $09FB,  $0AFB,  $0CFB,  $0EFB,  $0A04,  $0DFB,  $0304,  $0504,  $0404,  $07FB   ; 3.75? V tehle vzdalenosti to chce jeste o 2 vpravo a o 2 vlevo



DIV_6:
defw	0,	0,	0,	0,	0,	0
defw	2,	2,	2,	2,	2,	2
defw	4,	4,	4,	4,	4,	4
defw	6,	6,	6,	6,	6,	6
defw	8,	8,	8,	8,	8,	8

;	vpredu		vpravo		vlevo
; defw	0,	0,	0,	0,	1,	10
; defw	12,	14,	16,	18,	20,	22
; defw	24,	26,	28,	30,	32,	34
; defw	36,	38,	40,	42,	44,	46
; defw	48,	50,	52,	54,	56,	58
; defw	60,	62,	64,	66,	68,	70




ITEM_POZICE:
; dvoubajtove cislo oznacuje levy horni roh odkud kreslit sprite
; prvni je souradnice se znamenkem X (zleva doprava)
; druhe je kladna souradnice Y (shora dolu), pokud je zaporna, tak se ma sprite kreslit zprava doleva 
; 	primy smer			vpravo				vlevo                             sirka zadni
;	l.dal	p.dal	p.bliz	l.bliz	l.dal	p.dal	p.bliz	l.bliz	l.dal	p.dal	p.bliz	l.bliz	  steny	
defw	$000C,	$11F3,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	; 16
defw	$040A,	$0DF5,	$0EF4,	$030B,	$100A,	0,	0,	$110B,	0,	$01F5,	$00F4,	0	; 10
defw	$0608,	$0BF7,	$0CF6,	$0509,	$0D08,	$12F7,	$13F6,	$0E09,	$FF08,	$04F7,	$03F6,	$FE09	;  6
defw	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	;  4
defw	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	;



MAX_VIDITELNOST_PREDMETU_PLUS_1	equ	3*4*3	; (primy smer/vpravo/vlevo) * ( 2 * world ) * 3 radky




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
;SMAZ_NA_KONCI_AZ_NEBUDES_HYBAT_STALE_S_KODEM:
;REPT	50	; nejaka hodnota co posune sipky mimo zlom segmentu
;defb	0
;ENDM



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


INCLUDE	typy.h


MAX_ITEM	equ	27



DODATECNE_V_INVENTARI:
defw	Body_left,	$1907,	Body_left,	$1DF8
defw	I_prostirani,	$1904,	I_toulec,	$1D09



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





TIMER_ADR	equ	$5C78
LAST_KEY_ADR	equ	$5C08









;  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17
; 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
;  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F 10 11

; prvni word obsahuje adresu spritu
; treti "x" souradnici (nula vlevo, roste doprava)
; ctvrty "y" souradnici (nula nahore, roste dolu)
; pokud je "y" zaporna ( xor $ff ) tak je to vetsinou signal, ze se ma kreslit zprava doleva


; 5. krychle pred nama ( sirka 21 px blizsi strana, hloubka 5 px )
TABLE_VIEW_9_DEPTH_4:
defw	H4m4,	$11FB,	0,	0,	H4m4,	$0004,	0,	0	
defw	H4m3,	$11FB,	0,	0,	H4m3,	$0004,	0,	0
defw	H4m2,	$0FFB,	0,	0,	H4m2,	$0204,	0,	0
defw	H4m1,	$0CFB,	0,	0,	H4m1,	$0504,	0,	0,	H4,	$0704

; 4. krychle pred nama ( sirka 4 blizsi strana, hloubka 6 px )
TABLE_VIEW_7_DEPTH_3:
defw	V4m3,	$11FC,	0,	0,	V4m3,	$0003,	0,	0
defw	K4m2,	$11FC,	0,	0,	K4m2,	$0003,	0,	0	
defw	H3,	$0EFC,	V4m1,	$0BFC,	H3,	$0303,	V4m1,	$0603,	H3,	$0703

; 3. krychle pred nama ( sirka 6 blizsi strana, hloubka 1 )
TABLE_VIEW_5_DEPTH_2:
defw	V3m2,	$11FC,	0,	0,	V3m2,	$0003,	0,	0	
defw	K3m1,	$11FC,	0,	0,	K3m1,	$0003,	0,	0,	H2,	$0503

; 2. krychle pred nama ( sirka 10 blizsi strana, hloubka 2 )
TABLE_DEPTH_1:
defw	K2m1,	$11FD,	0,	0,	K2m1,	$0002,	0,	0,	H1,	$0402

; 1. krychle pred nama ( sirka 16 blizsi strana, hloubka 3 )
TABLE_DEPTH_0:
defw	K1m1,	$11FE,	0,	0,	K1m1,	$0001,	0,	0,	H0,	$0101

; uvnitr prazdne krychle ve ktere jsme ( jen leva a prava stena )
TABLE_DEPTH_x:
defw	V0m1,	$11FF,	0,	0,	V0m1,	$0000,	0,	0,	0,	0







NEXT_PAKA	equ	120
PAKA_DOWN	equ	60
  
PAKY_TABLE:

;  front view
; PAKA_UP_TABLE:
; 	primy smer	vpravo		vlevo
defw	0,	0,	0,	0,	0,	0
defw	Pu0,	$0702,	0,	0,	0,	0
defw	Pu1,	$0703,	0,	0,	0,	0
defw	Pu2,	$0803,	Pu2,	$0FFC,	Pu2,	$0203	; 6
defw	Pu3,	$0803,	Pu3,	$0DFC,	Pu3,	$0403	; 4

; PAKA_DOWN_TABLE:
; 	primy smer	vpravo		vlevo
defw	0,	0,	0,	0,	0,	0
defw	Pd0,	$0704,	0,	0,	0,	0
defw	Pd1,	$0704,	0,	0,	0,	0
defw	Pd2,	$0804,	Pd2,	$0FFB,	Pd2,	$0204
defw	Pd3,	$0804,	Pd3,	$0DFB,	Pd3,	$0404

; pohled vlevo
; 	primy smer	vpravo		vlevo
; PAKA_UP_LEVA_TABLE:
defw	0,	0,	0,	0,	0,	0
defw	0,	0,	0,	0,	Pul1,	$0203
defw	0,	0,	0,	0,	Pul2,	$0403
defw	0,	0,	0,	0,	Pul3,	$0604
defw	0,	0,	0,	0,	0,	$0704

; 	primy smer	vpravo		vlevo
; PAKA_DOWN_LEVA_TABLE:
defw	0,	0,	0,	0,	0,	$0
defw	0,	0,	0,	0,	Pdl1,	$0204
defw	0,	0,	0,	0,	Pdl2,	$0404
defw	0,	0,	0,	0,	Pdl3,	$0604
defw	0,	0,	0,	0,	0,	0


; pohled vpravo
; 	primy smer	vpravo		vlevo
; PAKA_UP_PRAVA_TABLE:
defw	0,	0,	0,	$0,	0,	0
defw	0,	0,	Pul1,	$0FFC,	0,	0
defw	0,	0,	Pul2,	$0DFC,	0,	0
defw	0,	0,	Pul3,	$0BFB,	0,	0
defw	0,	0,	0,	0,	0,	0

; 	primy smer	vpravo		vlevo
; PAKA_DOWN_PRAVA_TABLE:
defw	0,	0,	0,	$0,	0,	0
defw	0,	0,	Pdl1,	$0FFB,	0,	0
defw	0,	0,	Pdl2,	$0DFB,	0,	0
defw	0,	0,	Pdl3,	$0BFB,	0,	0
defw	0,	0,	0,	$0A04,	0,	0

  
TYP_DVERE		equ	1*POSUN_TYP

; 	primy smer	vpravo		vlevo
DOOR_TABLE:
defw	0,	0,	0,	0,	0,	0
defw	D0,	$0302,	0,	0,	0,	0
defw	D1,	$0503,	D1,	$0F03,	D1,	$FB03
defw	D2,	$0603,	D2,	$0C03,	D2,	$0003
defw	D3,	$0704,	D3,	$0B04,	D3,	$0304

; 	primy smer	vpravo		vlevo
RAM_TABLE:		
defw	R0,	$0400,	0,	0,	0,	0	; bocni pohled zevnitr dveri
defw	R1,	$0101,	R1m1,	$11FE,	R1m1,	$0001	; 16
defw	R2,	$0402,	R2m1,	$11FD,	R2m1,	$0002	; 10
defw	R3,	$0603,	R3,	$0C03,	R3m1,	$0003	; 6
defw	R4,	$0703,	R4,	$0B03,	R4,	$0303	; 4




  
NEXT_ENEMY		equ	72

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




; vvvvvvvvvvvvvvvvvvvvvvvvv zacatek souvisleho bloku vvvvvvvvvvvvvvvvvvvvvvvvv
NEXT_TYP_ENEMY	equ	10

ENEMY_TABLE:
; 	primy smer	vpravo		vlevo
;PODTYP_SKRET
defw	0
defw	ES1	; 16
defw	ES2	; 10
defw	ES3	; 6
defw	ES4

;PODTYP_PAVOUK
defw	0
defw	ESA1
defw	0
defw	0
defw	0
; ^^^^^^^^^^^^^^^^^^^^^^^^^ konec souvisleho bloku ^^^^^^^^^^^^^^^^^^^^^^^^^ 

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






; 	primy smer	vpravo		vlevo
KANAL_TABLE:		
defw	0,	0,	0,	0,	0,	0	; 
defw	Kanal0,	$0508,	0,	0,	0,	0	; 16
defw	Kanal1,	$0607,	Kanal1,	$1007,	Kanal1,	$FC07	; 10
defw	Kanal2,	$0706,	Kanal2,	$0D06,	Kanal2,	$0106	; 6
defw	Kanal3,	$0805,	Kanal3,	$0C05,	Kanal3,	$0405	; 4

; 	primy smer	vpravo		vlevo
RUNE_TABLE:		
defw	0,	0,	0,	0,	0,	0	; 
defw	H0rune,	$0704,	0,	$1704,	0,	$F704	; 16
defw	H1rune,	$0704,	H1rune,	$1104,	H1rune,	$FD04	; 10
defw	H2rune,	$0804,	H2rune,	$0E04,	H2rune,	$0204	; 6
defw	H3rune,	$0804,	H3rune,	$0C04,	H3rune,	$0404	; 4

; 	primy smer			vpravo				vlevo
;WALL_TABLE:
;defw	0,	$0,	0,	0,	V0m1,	$11FF,	0,	0,	V0m1,	$0000,	0,	0
;defw	H0,	$0101,	0,	0,	K1m1,	$0EFE,	0,	0,	K1m1,	$0001,	0,	0	; 16
;defw	H1,	$0402,	0,	0,	K2m1,	$0CFD,	0,	0,	K2m1,	$0002,	0,	0	; 10
;defw	H2,	$0503,	0,	0,	K3m1,	$0BFC,	0,	0,	K3m1,	$0003,	0,	0	; 6
;defw	H3,	$0703,	0,	0,	V4m1,	$0AFC,	H3,	$0B03,	V4m1,	$0603,	H3,	$0303	; 4






  
; vvvvvvvvvvvvvvvvvvvvvvvvv zacatek souvisleho bloku vvvvvvvvvvvvvvvvvvvvvvvvv
; Tabulka prevodu jednobytove identifikace predmetu na jeho obrazek
ITEM2SPRITE:
defw	0
defw	I_ring	; PODTYP_RING		equ	1*POSUN_PODTYP
defw	I_ring_r; PODTYP_RING_R		equ	2*POSUN_PODTYP
defw	I_ring_g; PODTYP_RING_G		equ	3*POSUN_PODTYP
defw	I_ring_b; PODTYP_RING_B		equ	4*POSUN_PODTYP
defw	I_ring_w; PODTYP_RING_W		equ	5*POSUN_PODTYP
MAX_RING_PLUS_1		equ	(1+PODTYP_RING_W)
;---
defw	I_helm     ; PODTYP_HELM	equ	6*POSUN_PODTYP
defw	I_helm_d   ; PODTYP_HELM_D	equ	7*POSUN_PODTYP
defw	I_necklace ; PODTYP_NECKLACE	equ	8*POSUN_PODTYP
;--
MIN_ARMOR	equ	PODTYP_ARMOR
defw	0 ; PODTYP_ARMOR	equ	9*POSUN_PODTYP
defw	I_armor_ch ; PODTYP_ARMOR_CH	equ	10*POSUN_PODTYP
defw	I_armor_l  ; PODTYP_ARMOR_L	equ	11*POSUN_PODTYP
defw	I_armor_p  ; PODTYP_ARMOR_P	equ	12*POSUN_PODTYP
MAX_ARMOR_PLUS_1	equ	(1+PODTYP_ARMOR_P)
;--
defw	0 ; PODTYP_ARROW	equ	13*POSUN_PODTYP
defw	0 ; PODTYP_BRACERS	equ	14*POSUN_PODTYP
defw	I_boots ; PODTYP_BOOTS	equ	15*POSUN_PODTYP
;---
defw	I_ankh	; PODTYP_ANKH		equ	16*POSUN_PODTYP
defw	I_axe	; PODTYP_AXE		equ	17*POSUN_PODTYP
defw	I_book	; PODTYP_BOOK		equ	18*POSUN_PODTYP
defw	I_bow	; PODTYP_BOW		equ	19*POSUN_PODTYP
defw	I_dagger; PODTYP_DAGGER		equ	20*POSUN_PODTYP
defw	I_mace	; PODTYP_MACE		equ	21*POSUN_PODTYP
defw	I_shield; PODTYP_SHIELD		equ	22*POSUN_PODTYP
defw	I_shield2; PODTYP_SHIELD2	equ	23*POSUN_PODTYP
defw	I_sling	; PODTYP_SLING		equ	24*POSUN_PODTYP
defw	I_sword	; PODTYP_SWORD		equ	25*POSUN_PODTYP
defw	I_bone	; PODTYP_BONE		equ	26*POSUN_PODTYP
;---
MIN_FOOD		equ	PODTYP_FOOD
defw	I_rations  ; PODTYP_FOOD	equ	27*POSUN_PODTYP
defw	I_potion_r ; PODTYP_POTION_R	equ	28*POSUN_PODTYP
defw	I_potion_g ; PODTYP_POTION_G	equ	29*POSUN_PODTYP
defw	I_potion_b ; PODTYP_POTION_B	equ	30*POSUN_PODTYP
ITEM2SPRITE_END:
; ^^^^^^^^^^^^^^^^^^^^^^^^^ konec souvisleho bloku ^^^^^^^^^^^^^^^^^^^^^^^^^ 

  
ITEM_POZICE:
; dvoubajtove cislo oznacuje levy horni roh odkud kreslit sprite
; prvni je souradnice se znamenkem X (zleva doprava)
; druhe je kladna souradnice Y (shora dolu), pokud je zaporna, tak se ma sprite kreslit zprava doleva 
; 	primy smer			vpravo				vlevo                             sirka zadni
;	l.dal	pr.dal	l.bliz	pr.bliz	l.dal	pr.dal	l.bliz	pr.bliz	l.dal	pr.dal	l.bliz	pr.bliz	  steny	
defw	$000C,	$11F3,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	; 16
defw	$040A,	$0DF5,	$030B,	$0EF4,	$100A,	0,	$110B,	0,	0,	$01F5,	0,	$00F4	; 10
defw	$0608,	$0BF7,	$0509,	$0CF6,	$0D08,	$12F7,	$0E09,	$13F6,	$FF08,	$04F7,	$FE09,	$03F6	;  6
defw	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	;  4
defw	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	;


MAX_VIDITELNOST_PREDMETU_PLUS_1	equ	3*4*3	; (primy smer/vpravo/vlevo) * ( 2 * world ) * 3 radky


ITEM_TABLE:
; 	16		10		6

defw	0,		0,		0,		0	; PODTYP_EMPTY
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_RING
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_RING_R
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_RING_G
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_RING_B
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_RING_W
;--
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_HELM		equ	6*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_HELM_D		equ	7*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_NECKLACE	equ	8*POSUN_PODTYP
;--
defw	0,		I1_unknwn,	I2_unknwn,	0	; PODTYP_ARMOR		equ	9*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_ARMOR_CH	equ	10*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_ARMOR_L	equ	11*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_ARMOR_P	equ	12*POSUN_PODTYP
;--
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_ARROW		equ	13*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_BRACERS	equ	14*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_BOOTS		equ	15*POSUN_PODTYP
;---
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_ANKH		equ	16*POSUN_PODTYP
defw	I0_weapon,	I1_weapon,	I2_weapon,	0	; PODTYP_AXE		equ	17*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_BOOK		equ	18*POSUN_PODTYP
defw	I0_weapon,	I1_weapon,	I2_weapon,	0	; PODTYP_BOW		equ	19*POSUN_PODTYP
defw	I0_weapon,	I1_weapon,	I2_weapon,	0	; PODTYP_DAGGER		equ	20*POSUN_PODTYP
defw	I0_weapon,	I1_weapon,	I2_weapon,	0	; PODTYP_MACE		equ	21*POSUN_PODTYP
defw	I0_shield,	I1_shield,	I2_shield,	0	; PODTYP_SHIELD		equ	22*POSUN_PODTYP
defw	I0_shield,	I1_shield,	I2_shield,	0	; PODTYP_SHIELD		equ	23*POSUN_PODTYP
defw	I0_weapon,	I1_weapon,	I2_weapon,	0	; PODTYP_SLING		equ	24*POSUN_PODTYP
defw	I0_weapon,	I1_weapon,	I2_weapon,	0	; PODTYP_SWORD		equ	25*POSUN_PODTYP
defw	I0_bone,	I1_bone,	I2_bone,	0	; PODTYP_BONE		equ	26*POSUN_PODTYP
;---
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_FOOD		equ	27*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_POTION_R	equ	28*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_POTION_G	equ	29*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_POTION_B	equ	30*POSUN_PODTYP




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


; TABLE_TYP:				; nepouzito
; ; 0 dvere
; ;
; ; 	@sprity		@jmeno
; defw	DOOR_TABLE,	0		; 0 dvere
; defw	DOOR_TABLE,	0		; 0 dvere
; defw	DOOR_TABLE,	0		; 0 dvere
; defw	DOOR_TABLE,	0		; 0 dvere
; defw	DOOR_TABLE,	0		; 0 dvere
; defw	DOOR_TABLE,	0		; 0 dvere
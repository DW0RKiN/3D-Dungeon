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






NEXT_TYP_ENEMY	equ	10

; vvvvvvvvvvvvvvvvvvvvvvvvv zacatek souvisleho bloku vvvvvvvvvvvvvvvvvvvvvvvvv

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


; Tabulka prevadejici predmet na 3D sprite
ITEM_TABLE:
; 	16		10		6

defw	0,		0,		0,		0	; PODTYP_EMPTY
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_RING
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_RING_R
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_RING_G
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_RING_B
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_RING_W
;--
defw	I0_armor,	I1_armor,	I2_armor,	0	; PODTYP_HELM		equ	6*POSUN_PODTYP
defw	I0_armor,	I1_armor,	I2_armor,	0	; PODTYP_HELM_D		equ	7*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_NECKLACE	equ	8*POSUN_PODTYP
;--
defw	0,		I1_armor,	I2_armor,	0	; PODTYP_ARMOR		equ	9*POSUN_PODTYP  (neni nakreslen)
defw	I0_armor,	I1_armor,	I2_armor,	0	; PODTYP_ARMOR_CH	equ	10*POSUN_PODTYP
defw	I0_armor,	I1_armor,	I2_armor,	0	; PODTYP_ARMOR_L	equ	11*POSUN_PODTYP
defw	I0_armor,	I1_armor,	I2_armor,	0	; PODTYP_ARMOR_P	equ	12*POSUN_PODTYP
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
defw	I0_armor,	I1_armor,	I2_armor,	0	; PODTYP_SHIELD		equ	22*POSUN_PODTYP
defw	I0_armor,	I1_armor,	I2_armor,	0	; PODTYP_SHIELD2	equ	23*POSUN_PODTYP
defw	I0_weapon,	I1_weapon,	I2_weapon,	0	; PODTYP_SLING		equ	24*POSUN_PODTYP
defw	I0_weapon,	I1_weapon,	I2_weapon,	0	; PODTYP_SWORD		equ	25*POSUN_PODTYP
defw	I0_bone,	I1_bone,	I2_bone,	0	; PODTYP_BONE		equ	26*POSUN_PODTYP
;---
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_FOOD		equ	27*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_POTION_R	equ	28*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_POTION_G	equ	29*POSUN_PODTYP
defw	I0_unknwn,	I1_unknwn,	I2_unknwn,	0	; PODTYP_POTION_B	equ	30*POSUN_PODTYP




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




  


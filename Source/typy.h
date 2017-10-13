MASKA_PREPINACE         equ     %11100000
ZAM_1                   equ     $80             ; zamek c. 1 (bit 7)
ZAM_2                   equ     $40             ; zamek c. 2 (bit 6)
ZAM_3                   equ     $20             ; zamek c. 3 (bit 5)
ZAM_12                  equ     $C0             ; (bity 7 a 6)
ZAM_13                  equ     $A0             ; (bity 7 a 5)
ZAM_23                  equ     $60             ; (bity 6 a 5)
ZAM_123                 equ     $E0             ; (bity 7, 6 a 5)


MASKA_TYP               equ     %00011100
MASKA_NATOCENI          equ     %00000011
MASKA_PODTYP            equ     %00011111



ODEMCENO                equ     $00

POSUN_TYP		equ	4
POSUN_PODTYP		equ	1                 ; dokud je to jedna tak to pri nasobeni nic nedela


TYP_PREPINAC 		equ	0*POSUN_TYP	; pozor, nemenit hodnotu, pouziva se "dec ? a zero flag" v PREHOD_PAKU
  PODTYP_PAKA		equ	0*POSUN_PODTYP
  PODTYP_TLACITKO	equ	1*POSUN_PODTYP
  PODTYP_TAJNE_TLACITKO	equ	2*POSUN_PODTYP
  PODTYP_ZAMEK		equ	3*POSUN_PODTYP
  
TYP_DVERE		equ	1*POSUN_TYP

TYP_ENEMY		equ	2*POSUN_TYP
  PODTYP_SKRET		equ	0*POSUN_PODTYP
  PODTYP_PAVOUK		equ	1*POSUN_PODTYP
  PODTYP_TRPASLIK	equ	2*POSUN_PODTYP
  PODTYP_NEMRTVY	equ	3*POSUN_PODTYP

TYP_DEKORACE		equ	3*POSUN_TYP

  PODTYP_KANAL		equ	0*POSUN_PODTYP
  PODTYP_RUNA		equ	1*POSUN_PODTYP
  PODTYP_RAM		equ	2*POSUN_PODTYP
  
  
; mel by byt posledni, kvuli fci FIND_LAST_OBJECT
TYP_ITEM		equ	4*POSUN_TYP
  PODTYP_EMPTY		equ	0
;-----
  PODTYP_RING		equ	1*POSUN_PODTYP
  PODTYP_RING_R		equ	2*POSUN_PODTYP
  PODTYP_RING_G		equ	3*POSUN_PODTYP
  PODTYP_RING_B		equ	4*POSUN_PODTYP
  PODTYP_RING_W		equ	5*POSUN_PODTYP
;----- serazeno tak, aby se co nejlepe zjistovaly zakazane pozice pro dane predmety
  PODTYP_HELM		equ	6*POSUN_PODTYP
  PODTYP_HELM_D		equ	7*POSUN_PODTYP
  PODTYP_NECKLACE	equ	8*POSUN_PODTYP
;--
  PODTYP_ARMOR		equ	9*POSUN_PODTYP
  PODTYP_ARMOR_CH	equ	10*POSUN_PODTYP
  PODTYP_ARMOR_L	equ	11*POSUN_PODTYP
  PODTYP_ARMOR_P	equ	12*POSUN_PODTYP
  ;--
  PODTYP_ARROW		equ	13*POSUN_PODTYP
  PODTYP_BRACERS	equ	14*POSUN_PODTYP
  PODTYP_BOOTS		equ	15*POSUN_PODTYP
;-----
  PODTYP_ANKH		equ	16*POSUN_PODTYP
  PODTYP_AXE		equ	17*POSUN_PODTYP
  PODTYP_BOOK		equ	18*POSUN_PODTYP
  PODTYP_BOW		equ	19*POSUN_PODTYP
  PODTYP_DAGGER		equ	20*POSUN_PODTYP
  PODTYP_MACE		equ	21*POSUN_PODTYP
  PODTYP_SHIELD		equ	22*POSUN_PODTYP
  PODTYP_SHIELD2	equ	23*POSUN_PODTYP
  PODTYP_SLING		equ	24*POSUN_PODTYP
  PODTYP_SWORD		equ	25*POSUN_PODTYP
  PODTYP_BONE		equ	26*POSUN_PODTYP

;----- veci s hodnotou MIN_FOOD vcetne musi byt jedle
  PODTYP_FOOD		equ	27*POSUN_PODTYP
  PODTYP_POTION_R	equ	28*POSUN_PODTYP
  PODTYP_POTION_G	equ	29*POSUN_PODTYP
  PODTYP_POTION_B	equ	30*POSUN_PODTYP
  
  ; kolik vyleci snezeni jidla
  FOOD_HEALING          equ     20
;  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17
; 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
;  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F 10 11

; prvni word obsahuje adresu spritu
; treti bajt "x" souradnici (nula vlevo, roste doprava)
; ctvrty bajt "y" souradnici (nula nahore, roste dolu)
; pokud je "y" zaporna ( xor $ff ) tak je to vetsinou signal, ze se ma kreslit zprava doleva

BIT_ZRCADLOVE   equ 2
MASKA_ZRCADLOVE equ $04


; 5. krychle pred nama ( sirka 21 px blizsi strana, hloubka 5 px )
TABLE_VIEW_9_DEPTH_4:
;            x   y           x   y           x   y           x   y           x   y
defw   H4m4, X17+Z03,     0,       0,  H4m4, X00+Y03,     0,       0                    ; 
defw   H4m3, X17+Z03,     0,       0,  H4m3, X00+Y03,     0,       0                    ;
defw   H4m2, X15+Z03,     0,       0,  H4m2, X02+Y03,     0,       0                    ;
defw   H4m1, X12+Z03,     0,       0,  H4m1, X05+Y03,     0,       0,    H4, X07+Y03    ;

; 4. krychle pred nama ( sirka 4 blizsi strana, hloubka 6 px )
TABLE_VIEW_7_DEPTH_3:
defw   V4m3, X17+Z03,     0,       0,  V4m3, X00+Y03,     0,       0
defw   K4m2, X17+Z03,     0,       0,  K4m2, X00+Y03,     0,       0    
defw     H3, X14+Z03,  V4m1, X11+Z03,    H3, X03+Y03,  V4m1, X06+Y03,    H3, X07+Y03

; 3. krychle pred nama ( sirka 6 blizsi strana, hloubka 1 )
TABLE_VIEW_5_DEPTH_2:
defw   V3m2, X17+Z03,     0,       0,  V3m2, X00+Y03,     0,       0    
defw   K3m1, X17+Z03,     0,       0,  K3m1, X00+Y03,     0,       0,    H2, X05+Y03

; 2. krychle pred nama ( sirka 10 blizsi strana, hloubka 2 )
TABLE_DEPTH_1:
defw   K2m1, X17+Z02,     0,       0,  K2m1, X00+Y02,     0,       0,    H1, X04+Y02

; 1. krychle pred nama ( sirka 16 blizsi strana, hloubka 3 )
TABLE_DEPTH_0:
defw   K1m1, X17+Z01,     0,       0,  K1m1, X00+Y01,     0,       0,    H0, X01+Y01

; uvnitr prazdne krychle ve ktere jsme ( jen leva a prava stena )
TABLE_DEPTH_x:
defw   V0m1, X17+Z00,     0,       0,  V0m1, X00+Y00,     0,       0,     0,       0



PAKY_TABLE:

;  front view
; PAKA_UP_TABLE:
;     primy smer     vpravo         vlevo
defw      0,       0,     0,       0,     0,       0
defw    Pu0, X07+Y02,     0,       0,     0,       0
defw    Pu1, X07+Y03,     0,       0,     0,       0
defw    Pu2, X08+Y03,   Pu2, X15+Z03,   Pu2, X02+Y03  ; 6
defw    Pu3, X08+Y03,   Pu3, X13+Z03,   Pu3, X04+Y03  ; 4

; PAKA_DOWN_TABLE:
;     primy smer     vpravo         vlevo
defw      0,       0,     0,       0,     0,       0
defw    Pd0, X07+Y04,     0,       0,     0,       0
defw    Pd1, X07+Y04,     0,       0,     0,       0
defw    Pd2, X08+Y04,   Pd2, X15+Z04,   Pd2, X02+Y04
defw    Pd3, X08+Y04,   Pd3, X13+Z04,   Pd3, X04+Y04

; pohled vlevo
;     primy smer      vpravo          vlevo
; PAKA_UP_LEVA_TABLE:
defw      0,       0,     0,       0,     0,       0
defw      0,       0,     0,       0,  Pul1, X02+Y03
defw      0,       0,     0,       0,  Pul2, X04+Y03
defw      0,       0,     0,       0,  Pul3, X06+Y04
defw      0,       0,     0,       0,     0, X07+Y04

;     primy smer     vpravo         vlevo
; PAKA_DOWN_LEVA_TABLE:
defw      0,       0,     0,       0,     0,       0
defw      0,       0,     0,       0,  Pdl1, X02+Y04
defw      0,       0,     0,       0,  Pdl2, X04+Y04
defw      0,       0,     0,       0,  Pdl3, X06+Y04
defw      0,       0,     0,       0,     0,       0


; pohled vpravo
;     primy smer     vpravo         vlevo
; PAKA_UP_PRAVA_TABLE:
defw      0,       0,     0,       0,     0,       0
defw      0,       0,  Pul1, X15+Z03,     0,       0
defw      0,       0,  Pul2, X13+Z03,     0,       0
defw      0,       0,  Pul3, X11+Z04,     0,       0
defw      0,       0,     0,       0,     0,       0

;     primy smer     vpravo         vlevo
; PAKA_DOWN_PRAVA_TABLE:
defw      0,       0,     0,       0,     0,       0
defw      0,       0,  Pdl1, X15+Z04,     0,       0
defw      0,       0,  Pdl2, X13+Z04,     0,       0
defw      0,       0,  Pdl3, X11+Z04,     0,       0
defw      0,       0,     0, X10+Y04,     0,       0


;     primy smer     vpravo         vlevo
DOOR_TABLE:
defw      0,       0,     0,       0,     0,       0
defw     D0, X03+Y02,     0,       0,     0,       0
defw     D1, X05+Y03,    D1, X15+Y03,    D1, Xm5+Y03  ;
defw     D2, X06+Y03,    D2, X12+Y03,    D2, X00+Y03
defw     D3, X07+Y04,    D3, X11+Y04,    D3, X03+Y04

;     primy smer     vpravo         vlevo
RAM_TABLE:        
defw    R0, X04+Y00,      0,       0,     0,       0  ; bocni pohled zevnitr dveri
defw    R1, X01+Y01,   R1m1, X17+Z01,  R1m1, X00+Y01  ; 16
defw    R2, X04+Y02,   R2m1, X17+Z02,  R2m1, X00+Y02  ; 10
defw    R3, X06+Y03,     R3, X12+Y03,  R3m1, X00+Y03  ; 6
defw    R4, X07+Y03,     R4, X11+Y03,    R4, X03+Y03  ; 4




NEXT_TYP_ENEMY    equ    10

; vvvvvvvvvvvvvvvvvvvvvvvvv zacatek souvisleho bloku vvvvvvvvvvvvvvvvvvvvvvvvv

ENEMY_TABLE:
;     primy smer     vpravo         vlevo
;PODTYP_SKRET
defw    0
defw    ES1    ; 16
defw    ES2    ; 10
defw    ES3    ; 6
defw    ES4

;PODTYP_PAVOUK
defw    0
defw    ESA1
defw    0
defw    0
defw    0
; ^^^^^^^^^^^^^^^^^^^^^^^^^ konec souvisleho bloku ^^^^^^^^^^^^^^^^^^^^^^^^^ 


; Tabulka prevadejici predmet na 3D sprite
ITEM_TABLE:
;              16        10        6

defw            0,           0,           0,    0    ; PODTYP_EMPTY
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_RING
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_RING_R
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_RING_G
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_RING_B
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_RING_W
;--
defw     I0_armor,    I1_armor,    I2_armor,    0    ; PODTYP_HELM       equ    6*POSUN_PODTYP
defw     I0_armor,    I1_armor,    I2_armor,    0    ; PODTYP_HELM_D     equ    7*POSUN_PODTYP
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_NECKLACE   equ    8*POSUN_PODTYP
;--
defw            0,    I1_armor,    I2_armor,    0    ; PODTYP_ARMOR      equ    9*POSUN_PODTYP  (neni nakreslen)
defw     I0_armor,    I1_armor,    I2_armor,    0    ; PODTYP_ARMOR_CH   equ    10*POSUN_PODTYP
defw     I0_armor,    I1_armor,    I2_armor,    0    ; PODTYP_ARMOR_L    equ    11*POSUN_PODTYP
defw     I0_armor,    I1_armor,    I2_armor,    0    ; PODTYP_ARMOR_P    equ    12*POSUN_PODTYP
;--
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_ARROW      equ    13*POSUN_PODTYP
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_BRACERS    equ    14*POSUN_PODTYP
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_BOOTS      equ    15*POSUN_PODTYP
;---
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_ANKH       equ    16*POSUN_PODTYP
defw    I0_weapon,   I1_weapon,   I2_weapon,    0    ; PODTYP_AXE        equ    17*POSUN_PODTYP
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_BOOK       equ    18*POSUN_PODTYP
defw    I0_weapon,   I1_weapon,   I2_weapon,    0    ; PODTYP_BOW        equ    19*POSUN_PODTYP
defw    I0_weapon,   I1_weapon,   I2_weapon,    0    ; PODTYP_DAGGER     equ    20*POSUN_PODTYP
defw    I0_weapon,   I1_weapon,   I2_weapon,    0    ; PODTYP_MACE       equ    21*POSUN_PODTYP
defw     I0_armor,    I1_armor,    I2_armor,    0    ; PODTYP_SHIELD     equ    22*POSUN_PODTYP
defw     I0_armor,    I1_armor,    I2_armor,    0    ; PODTYP_SHIELD2    equ    23*POSUN_PODTYP
defw    I0_weapon,   I1_weapon,   I2_weapon,    0    ; PODTYP_SLING      equ    24*POSUN_PODTYP
defw    I0_weapon,   I1_weapon,   I2_weapon,    0    ; PODTYP_SWORD      equ    25*POSUN_PODTYP
defw      I0_bone,     I1_bone,     I2_bone,    0    ; PODTYP_BONE       equ    26*POSUN_PODTYP
;---
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_FOOD       equ    27*POSUN_PODTYP
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_POTION_R   equ    28*POSUN_PODTYP
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_POTION_G   equ    29*POSUN_PODTYP
defw    I0_unknwn,   I1_unknwn,   I2_unknwn,    0    ; PODTYP_POTION_B   equ    30*POSUN_PODTYP




;       primy smer       vpravo            vlevo
KANAL_TABLE:        
defw         0,        0,      0,        0,      0,        0  ; 
defw    Kanal0,  X05+Y08,      0,        0,      0,        0  ; 16
defw    Kanal1,  X06+Y07, Kanal1,  X16+Y07, Kanal1,  Xm4+Y07  ; 10
defw    Kanal2,  X07+Y06, Kanal2,  X13+Y06, Kanal2,  X01+Y06  ; 6
defw    Kanal3,  X08+Y05, Kanal3,  X12+Y05, Kanal3,  X04+Y05  ; 4

;       primy smer       vpravo            vlevo
RUNE_TABLE:        
defw         0,        0,      0,        0,      0,        0  ; 
defw    H0rune,  X07+Y04,      0,        0,      0,        0  ; 16
defw    H1rune,  X07+Y04, H1rune,  X17+Y04,      0,        0  ; 10
defw    H2rune,  X08+Y04, H2rune,  X14+Y04, H2rune,  X02+Y04  ; 6
defw    H3rune,  X08+Y04, H3rune,  X12+Y04, H3rune,  X04+Y04  ; 4

;       primy smer                            vpravo                               vlevo
;WALL_TABLE:
;defw        0,        0,      0,        0,   V0m1,  X17+Z00,      0,        0,    V0m1,  X00+Y00,      0,        0
;defw       H0,  X01+Y01,      0,        0,   K1m1,  X14+Z01,      0,        0,    K1m1,  X00+Y01,      0,        0  ; 16
;defw       H1,  X04+Y02,      0,        0,   K2m1,  X12+Z02,      0,        0,    K2m1,  X00+Y02,      0,        0  ; 10
;defw       H2,  X05+Y03,      0,        0,   K3m1,  X11+Z03,      0,        0,    K3m1,  X00+Y03,      0,        0  ; 6
;defw       H3,  X07+Y03,      0,        0,   V4m1,  X10+Z03,     H3,  X11+Y03,    V4m1,  X06+Y03,     H3,  X03+Y03  ; 4




  


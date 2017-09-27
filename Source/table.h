i_nw        equ     0       ; item north-west position
i_ne        equ     1       ; item north-east position
i_se        equ     2       ; item south-east position
i_sw        equ     3       ; item south-west position


; lokace    = dolnich 8 bitu pozice na mape, pokud je nulova tak radek pridava dalsi informace k predchozimu

; typ       = bity 7 6 5 ?  ? ? ? ? =   aspon jeden nenulovy bit znamena nepruchozi objekt ( u dveri zaroven zavreno ), u paky 0=nahore, 1=dole
; typ       = bity ? ? ? 4  3 2 ? ? =   identifikace typu objektu: prepinac, enemy, dvere, dekorace (runa, kanal)... 
; typ       = bity ? ? ? ?  ? ? 0 1 =   natoceni v danem ctverci, 
;                                       u ramu dveri 0=chodba severojizni/svisla, 1=chodba vychodozapadni/vodorovna
;                                       protoze objektu muze byt vic tak teprve s natocenim jednoznacne identifikuji co to je (u dekoraci nepouzito)

; dodatecny = bity ? ? ? 4  3 2 1 0 =   podtyp objektu

; pokud lokace zacina nulou tak jsou to pomocne radky prepinace nad tim (prvni nenulove lokace)
; pomocne radky urcuji co vsechno to prepne, pricemz je to diky te prvni nule posunuty,
; takze druha polozka znaci lokaci a posledni identifikaci objektu, kde horni 3 bity jsou ty co maji byt xorovany


TYP_DVERE_SJ    equ     TYP_DVERE
TYP_DVERE_VZ    equ     (TYP_DVERE+1)
TYP_ZARAZKA     equ     $ff

ADR_ZARAZKY:
defw    ZARAZKA                    ; ma ukazovat adresu $ff zarazky v TABLE_OBJECTS, pouziva se pri brani/vkladani radku


TABLE_OBJECTS:    
; POZOR! Predmety neustale udrzuj ve vzestupne lokaci a nasledne vzestupne podle prepinace+typ (horni 3 bity na prepinace se berou jako vynulovane)
;    lokace                  prepinace+typ                         dodatecny
defb      1,                  TYP_DEKORACE,                     PODTYP_KANAL

defb      6,                  TYP_DEKORACE,                      PODTYP_RUNA

defb     16,                      TYP_ITEM,                     PODTYP_SWORD
defb     16,               TYP_ITEM + i_ne,                    PODTYP_DAGGER
defb     16,               TYP_ITEM + i_se,                     PODTYP_SWORD
defb     16,               TYP_ITEM + i_sw,                    PODTYP_SHIELD

defb     17,                      TYP_ITEM,                      PODTYP_BONE
defb     17,               TYP_ITEM + i_ne,                   PODTYP_SHIELD2
defb     17,               TYP_ITEM + i_se,                  PODTYP_ARMOR_CH
defb     17,               TYP_ITEM + i_sw,                   PODTYP_ARMOR_L

defb     21,     4 * 32 + TYP_ENEMY + east,               $80 + PODTYP_SKRET

defb     32,                      TYP_ITEM,                      PODTYP_MACE
defb     32,               TYP_ITEM + i_ne,                       PODTYP_BOW
defb     32,               TYP_ITEM + i_se,                     PODTYP_SLING
defb     32,               TYP_ITEM + i_sw,                       PODTYP_AXE

defb     33,                      TYP_ITEM,                   PODTYP_ARMOR_P
defb     33,               TYP_ITEM + i_ne,                      PODTYP_HELM
defb     33,               TYP_ITEM + i_se,                    PODTYP_HELM_D
defb     33,               TYP_ITEM + i_sw,                   PODTYP_SHIELD2

defb     48,                      TYP_ITEM,                     PODTYP_SWORD

defb     50,               TYP_ITEM + i_se,                    PODTYP_RING_B
defb     50,               TYP_ITEM + i_sw,                    PODTYP_RING_R

defb     64,                      TYP_ITEM,                      PODTYP_BONE
defb     64,               TYP_ITEM + i_ne,                      PODTYP_BONE
defb     64,               TYP_ITEM + i_se,                      PODTYP_BONE
defb     64,               TYP_ITEM + i_sw,                      PODTYP_BONE


defb     66,                      TYP_ITEM,                      PODTYP_ANKH
defb     66,               TYP_ITEM + i_ne,                  PODTYP_POTION_R
defb     66,               TYP_ITEM + i_se,                  PODTYP_POTION_G
defb     66,               TYP_ITEM + i_sw,                  PODTYP_POTION_B

defb     68,     4 * 32 + TYP_ENEMY + east,               $80 + PODTYP_SKRET

defb     80,                      TYP_ITEM,                      PODTYP_BONE
defb     80,               TYP_ITEM + i_ne,                      PODTYP_BONE
defb     80,               TYP_ITEM + i_se,                      PODTYP_BONE
defb     80,               TYP_ITEM + i_sw,                      PODTYP_BONE

defb     82,                      TYP_ITEM,                      PODTYP_BOOK
defb     82,               TYP_ITEM + i_ne,                  PODTYP_NECKLACE
defb     82,               TYP_ITEM + i_se,                      PODTYP_FOOD
defb     82,               TYP_ITEM + i_sw,                  PODTYP_POTION_G


defb     95,                  TYP_DEKORACE,                     PODTYP_KANAL

defb    115,                  TYP_DEKORACE,                     PODTYP_KANAL

defb    119,          ZAM_1 + TYP_DVERE_VZ,                                0

defb    129,                  TYP_DEKORACE,                      PODTYP_RUNA

defb    132,          TYP_PREPINAC + south,                      PODTYP_PAKA    ; dodatecne jeste neni pouzit, vzdy je to paka
defb      0,                           119,             ZAM_1 + TYP_DVERE_VZ    ; aktivace paky prepne bit ZAM_1 vychodozapadnim dverim na lokaci 119

defb    142,          ZAM_1 + TYP_DVERE_SJ,                                0    ; 

defb    158,        ZAM_123 + TYP_DVERE_SJ,                                0    ; zavreno az na 3 bity!!!

defb    176,                  TYP_DEKORACE,                     PODTYP_KANAL

; ---------- ctverice pak na dvere 158

PAKA_A      equ     185
PAKA_B      equ     186
PAKA_C      equ     187
PAKA_D      equ     188

; Bit dveri    7 6 5
; Paka       A B C D = 185 .. 188
; zaroven s  + + + +  
; pakou      B C D B
; a zaroven  C
; a jeste    D 


;    lokace                  prepinace+typ                         dodatecny

defb PAKA_A,          TYP_PREPINAC + south,                      PODTYP_PAKA    ; paka A meni dvere 142 a paky pro dvere 158 (takze rovnou otevre dvere pokud jsou shodne nahore)
defb      0,                           142,             ZAM_1 + TYP_DVERE_SJ    ; meni bit ZAM_1
defb      0,                           158,           ZAM_123 + TYP_DVERE_SJ    ; celkove meni bity ZAM_1 + ZAM_2 + ZAM_3
defb      0,                        PAKA_B,     ZAM_1 + TYP_PREPINAC + south    ; zmeni i paku B
defb      0,                        PAKA_C,     ZAM_1 + TYP_PREPINAC + south    ; zmeni i paku C
defb      0,                        PAKA_D,     ZAM_1 + TYP_PREPINAC + south    ; zmeni i paku D

defb PAKA_B,          TYP_PREPINAC + south,                      PODTYP_PAKA    ; paka B primarne meni bit ZAM_1 na dverich v lokaci 158
defb      0,                           158,            ZAM_12 + TYP_DVERE_SJ    ; celkove meni bity ZAM_1 + ZAM_2 s pakou C
defb      0,                        PAKA_C,     ZAM_1 + TYP_PREPINAC + south    ; zmeni i paku C

defb PAKA_C,          TYP_PREPINAC + south,                      PODTYP_PAKA    ; paka C primarne meni bit ZAM_2 na dverich v lokaci 158
defb      0,                           158,            ZAM_23 + TYP_DVERE_SJ    ; celkove meni bity ZAM_2 + ZAM_3 s pakou D
defb      0,                        PAKA_D,     ZAM_1 + TYP_PREPINAC + south    ; zmeni i paku D

defb PAKA_D,          TYP_PREPINAC + south,                      PODTYP_PAKA    ; paka D primarne meni bit ZAM_3 na dverich v lokaci 158
defb      0,                           158,            ZAM_13 + TYP_DVERE_SJ    ; celkove meni bity ZAM_1 + ZAM_3 s pakou B
defb      0,                        PAKA_B,     ZAM_1 + TYP_PREPINAC + south    ; zmeni i paku B

; ----------

defb    216,           TYP_PREPINAC + east,                      PODTYP_PAKA
defb      0,                           216,      ZAM_1 + TYP_PREPINAC + west    ; prepne i paku na druhe strane
defb      0,                           232,             ZAM_1 + TYP_DVERE_VZ    ; aktivace paky prepne predmet na lokaci 232 s typem dvere

defb    216,           TYP_PREPINAC + west,                      PODTYP_PAKA
defb      0,                           216,      ZAM_1 + TYP_PREPINAC + east    ; prepne i paku na druhe strane
defb      0,                           232,             ZAM_1 + TYP_DVERE_VZ    ; aktivace paky prepne predmet na lokaci 232 s typem dvere

defb    232,          ZAM_1 + TYP_DVERE_VZ,                                0

defb    246,                  TYP_DEKORACE,                      PODTYP_RUNA

defb    246,                      TYP_ITEM,                  PODTYP_POTION_G
defb    246,               TYP_ITEM + i_ne,                  PODTYP_POTION_R
defb    246,               TYP_ITEM + i_se,                  PODTYP_POTION_G
defb    246,               TYP_ITEM + i_sw,                  PODTYP_POTION_G

defb    254,                  TYP_DEKORACE,                     PODTYP_KANAL

ZARAZKA:
defb    TYP_ZARAZKA

; za touhle casti roste heap az k zasobniku ( nic sem uz nedavat )

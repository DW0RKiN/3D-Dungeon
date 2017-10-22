MAX_INVENTORY           equ     31
MAX_HOLD_INVENTORY      equ     (MAX_INVENTORY-4)

COLOR_OTHER_PLAYERS     equ     %00000111        ; white ink + black paper
COLOR_ACTIVE_PLAYER     equ     %00000011        ; magenta ink + black paper


INVENTORY_ITEMS:
;	0		1		2		3		4		5		6		7		8		9		10		11		12		13		14		15
; player 0
defb	PODTYP_ARMOR_P,	PODTYP_SHIELD,	PODTYP_FOOD,	PODTYP_FOOD,	PODTYP_ANKH,	0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0
;	prostirani	hlava		nahrdelnik	brneni		l.ruka		l.prsten	boty		toulec		chran.predlokti	p.ruka		p.prsten	na zemi		na zemi		na zemi		na zemi	
defb	0,		PODTYP_HELM_D,	0,		PODTYP_ARMOR_CH,PODTYP_AXE,	0,		PODTYP_BOOTS,	0,		0,		PODTYP_SHIELD,	PODTYP_RING_B,	5,		4,		3,		2	

; player 1
defb	PODTYP_FOOD,	PODTYP_DAGGER,	0,		0, 		PODTYP_ANKH,	0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0
defb	0,		PODTYP_HELM,	PODTYP_NECKLACE,PODTYP_ARMOR_P,	PODTYP_SWORD,	PODTYP_RING_R,	0,		0,		PODTYP_BRACERS,	PODTYP_SHIELD,	0,		0,		0,		0,		0

; player 2
defb	PODTYP_POTION_R,PODTYP_POTION_R,PODTYP_POTION_G,PODTYP_POTION_B,PODTYP_ANKH,	0,		0,		0,		PODTYP_DAGGER,	0,		0,		0,		0,		0,		0,		0
defb	0,		0,		PODTYP_NECKLACE,PODTYP_ARMOR_L,	PODTYP_MACE,	0,		PODTYP_BOOTS,	0,		0,		PODTYP_ANKH,	0,		0,		0,		0,		0

; player 3
defb	PODTYP_DAGGER,	PODTYP_SHIELD2,	PODTYP_FOOD,	0,		PODTYP_SLING,	0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0
defb	0,		0,		0,		0,		PODTYP_DAGGER,	PODTYP_RING_W,	PODTYP_BOOTS,	0,		0,		PODTYP_DAGGER,	0,		0,		0,		0,		0

; player 4
defb	PODTYP_DAGGER,	PODTYP_SHIELD,	0,		0,		PODTYP_BONE,	0,		0,		0,		0,		0,		0,		PODTYP_BOW,	0,		0,		0,		0
defb	0,		0,		0,		0,		PODTYP_BOW,	0,		0,		0,		0,		0,		0,		0,		0,		0,		0

; player 5
defb	PODTYP_DAGGER,	PODTYP_SHIELD,	0,		0,		0,		0,		0,		PODTYP_MACE,	0,		0,		0,		0,		0,		0,		0,		0
defb	0,		0,		PODTYP_NECKLACE,0,		0,		PODTYP_RING_G,	0,		0,		0,		PODTYP_BOOK,	PODTYP_RING,	0,		0,		0,		0

INVENTORY_ITEMS_END:




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
defw    I_bracers       ; PODTYP_BRACERS	equ	14*POSUN_PODTYP
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



; vvvv ----------------- zacatek souvisleho bloku
PRESOUVANY_PREDMET:
defb	0
KURZOR_V_INVENTARI:
defb	0              ; 1..MAX_INVENTORY
; ^^^^^^^^^^^^^^^^^^^^^^^^^ konec souvisleho bloku ^^^^^^^^^^^^^^^^^^^^^^^^^ 

POZICE_PROSTIRANI   equ X25+Y04
POZICE_HLAVA        equ X26+Y07
POZICE_NAHRDELNIK   equ X26+Y09
POZICE_BRNENI       equ X26+Y11
POZICE_LPRSTEN      equ X24+Y16
POZICE_BOTY         equ X26+Y18
POZICE_TOULEC       equ X29+Y09
POZICE_NATEPNIK     equ X29+Y11
POZICE_PPRSTEN      equ X28+Y16

; vvvv ----------------- zacatek souvisleho bloku
POZICE_V_INVENTARI:
defw    X18+Y04, X18+Y06, X18+Y08, X18+Y10, X18+Y12, X18+Y14, X18+Y16, X18+Y18
defw    X21+Y04, X21+Y06, X21+Y08, X21+Y10, X21+Y12, X21+Y14, X21+Y16, X21+Y18
PROSTIRANI:
defw    POZICE_PROSTIRANI       ; prostirani
defw    POZICE_HLAVA            ; hlava
defw    POZICE_NAHRDELNIK       ; nahrdelnik
defw    POZICE_BRNENI           ; brneni
defw    X24+Y13                 ; l.ruka
defw    POZICE_LPRSTEN          ; l.prsten
defw    POZICE_BOTY             ; boty
defw    POZICE_TOULEC           ; toulec
defw    POZICE_NATEPNIK         ; natepnik / chranic predlokti
defw    X28+Y13                 ; p.ruka
defw    POZICE_PPRSTEN          ; p.prsten
POZICE_V_INVENTARI_HOLD_END:
defw    X04+Y11                 ; na zemi vlevo nahore
defw    X02+Y13                 ; na zemi vlevo dole
defw    X11+Y11                 ; na zemi vpravo nahore
defw    X13+Y13                 ; na zemi vpravo dole
POZICE_V_INVENTARI_END:
; ^^^^ ----------------- konec souvisleho bloku


; INDEXY pocitane od 1 do MAX_INVENTORY
INDEX_PROSTIRANI    equ     17
INDEX_HLAVA         equ     18
INDEX_NAHRDELNIK    equ     19
INDEX_BRNENI        equ     20
INDEX_LRUKA         equ     21
INDEX_LPRSTEN       equ     22
INDEX_BOTY          equ     23
INDEX_TOULEC        equ     24
INDEX_NATEPNIK      equ     25
INDEX_PRUKA         equ     26
INDEX_PPRSTEN       equ     27

INDEX_ZEM_LU_M1     equ     27
INDEX_ZEM_LD_M1     equ     28
INDEX_ZEM_RU_M1     equ     29
INDEX_ZEM_RD_M1     equ     30

; vvvvvvvvvvvvvvvvvvvvvvvvv zacatek souvisleho bloku vvvvvvvvvvvvvvvvvvvvvvvvv
; Tabulka pro zjistni zda muze byt predmet ulozen na dane pozici
POVOLENE_POZICE:
defb    INDEX_LPRSTEN   ; PODTYP_RING       equ 1*POSUN_PODTYP
defb    INDEX_LPRSTEN   ; PODTYP_RING_R     equ 2*POSUN_PODTYP
defb    INDEX_LPRSTEN   ; PODTYP_RING_G     equ 3*POSUN_PODTYP
defb    INDEX_LPRSTEN   ; PODTYP_RING_B     equ 4*POSUN_PODTYP
defb    INDEX_LPRSTEN   ; PODTYP_RING_W     equ 5*POSUN_PODTYP
;---
defb    INDEX_HLAVA     ; PODTYP_HELM       equ 6*POSUN_PODTYP
defb    INDEX_HLAVA     ; PODTYP_HELM_D     equ 7*POSUN_PODTYP
defb    INDEX_NAHRDELNIK; PODTYP_NECKLACE   equ 8*POSUN_PODTYP
;--
defb    INDEX_BRNENI    ; PODTYP_ARMOR      equ 9*POSUN_PODTYP
defb    INDEX_BRNENI    ; PODTYP_ARMOR_CH   equ 10*POSUN_PODTYP
defb    INDEX_BRNENI    ; PODTYP_ARMOR_L    equ 11*POSUN_PODTYP
defb    INDEX_BRNENI    ; PODTYP_ARMOR_P    equ 12*POSUN_PODTYP
;--
defb    INDEX_TOULEC    ; PODTYP_ARROW      equ 13*POSUN_PODTYP
defb    INDEX_NATEPNIK  ; PODTYP_BRACERS    equ 14*POSUN_PODTYP
defb    INDEX_BOTY      ; PODTYP_BOOTS      equ 15*POSUN_PODTYP
;---
defb    INDEX_LRUKA     ; PODTYP_ANKH       equ 16*POSUN_PODTYP
defb    INDEX_LRUKA     ; PODTYP_AXE        equ 17*POSUN_PODTYP
defb    INDEX_LRUKA     ; PODTYP_BOOK       equ 18*POSUN_PODTYP
defb    INDEX_LRUKA     ; PODTYP_BOW        equ 19*POSUN_PODTYP
defb    INDEX_LRUKA     ; PODTYP_DAGGER     equ 20*POSUN_PODTYP
defb    INDEX_LRUKA     ; PODTYP_MACE       equ 21*POSUN_PODTYP
defb    INDEX_LRUKA     ; PODTYP_SHIELD     equ 22*POSUN_PODTYP
defb    INDEX_LRUKA     ; PODTYP_SHIELD2    equ 23*POSUN_PODTYP
defb    INDEX_LRUKA     ; PODTYP_SLING      equ 24*POSUN_PODTYP
defb    INDEX_LRUKA     ; PODTYP_SWORD      equ 25*POSUN_PODTYP
defb    INDEX_LRUKA     ; PODTYP_BONE       equ 26*POSUN_PODTYP
;---
defb    INDEX_PROSTIRANI; PODTYP_FOOD       equ 27*POSUN_PODTYP
defb    INDEX_PROSTIRANI; PODTYP_POTION_R   equ 28*POSUN_PODTYP
defb    INDEX_PROSTIRANI; PODTYP_POTION_G   equ 29*POSUN_PODTYP
defb    INDEX_PROSTIRANI; PODTYP_POTION_B   equ 30*POSUN_PODTYP
POVOLENE_POZICE_END:
; ^^^^^^^^^^^^^^^^^^^^^^^^^ konec souvisleho bloku ^^^^^^^^^^^^^^^^^^^^^^^^^ 


DATA_ZIVOTY:
; aktualni pocet zivotu, 
; maximalni pocet zivotu, 
; trvale zraneni, 
; offset atributu prouzku, 
; segment atributu prouzku, 
; velikost posledniho zraneni, 
; cas ukonceni zobrazeni krvaveho fleku

;       nyni    max     trvale  offset  segment                 konec   zraneni
defb    132,    132,    1,      $b4,    Adr_Attr_Buffer/256+0,  0,      0
defb    90,     90,     1,      $bb,    Adr_Attr_Buffer/256+0,  0,      0
defb    64,     64,     1,      $94,    Adr_Attr_Buffer/256+1,  0,      0
defb    40,     40,     1,      $9b,    Adr_Attr_Buffer/256+1,  0,      0
defb    46,     46,     1,      $74,    Adr_Attr_Buffer/256+2,  0,      0
defb    40,     40,     1,      $7b,    Adr_Attr_Buffer/256+2,  0,      0
DATA_ZIVOTY_END:


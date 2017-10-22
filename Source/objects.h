; pokud chceme prepinat vsechno daneho typu na dane lokaci tak nechat 0
; pokud chceme rozlisit i natoceni, dat 1
KONTROLUJ_NATOCENI_U_PREPINACU    equ 0

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


; vvvv -----------------
HLAVNI_POSTAVA:
defb	0	; 0..5
SUM_POSTAV:
defb	6	; 1..6 zpozor musi navazovat s HLAVNI_POSTAVA
; ^^^^ ----------------- musi navazovat a byt v tomto poradi


BORDER:
defb	0



; vvvv ----------------- zacatek souvisleho bloku
POZICE_RUKOU:
    defw X22+Y01        ; postava 1. horni zbran 
    defw X22+Y03        ; postava 1. dolni zbran
    defw X29+Y01        ; postava 2. horni zbran
    defw X29+Y03        ; postava 2. dolni zbran
    defw X22+Y08        ; postava 3. horni zbran
    defw X22+Y10        ; postava 3. dolni zbran
    defw X29+Y08        ; postava 4. horni zbran
    defw X29+Y10        ; postava 4. dolni zbran
    defw X22+Y15        ; postava 5. horni zbran
    defw X22+Y17        ; postava 5. dolni zbran
    defw X29+Y15        ; postava 6. horni zbran
    defw X29+Y17        ; postava 6. dolni zbran
POZICE_RUKOU_END:
; ^^^^ ----------------- konec souvisleho bloku


SIPKY_POZICE    equ X00+Y15
KOMPAS_POZICE   equ X07+Y15

AVATARS:
defw	MFace02,	X18+Y01,	FFace02,	X25+Y01
defw	FFace03,	X18+Y08,	FFace04,	X25+Y08
defw	MFace01,	X18+Y15,	FFace01,	X25+Y15

; je label nutny? asi ne, ale musi bezprostredne navazovat za AVATARS
KOMPAS:
defw	Kompas,		KOMPAS_POZICE

; vvvv ----------------- zacatek souvisleho bloku
SIPKY:
defw	S_vsechny,	SIPKY_POZICE	; 
STISKNUTA_SIPKA:
defw	S_dopredu,	X03+Y15		;  0
defw	S_dozadu,	X03+Y17		;  4
defw	S_vlevo,	X01+Y17		;  8 ukrok
defw	S_vpravo,	X05+Y17		; 12 ukrok
defw	S_doleva,	X01+Y15		; 16 otoceni
defw	S_doprava,	X05+Y15		; 20 otoceni
defw	0,		0		; 24
SIPKY_END:
; ^^^^ ----------------- konec souvisleho bloku


SIPKA_DOPREDU		equ	0
SIPKA_DOZADU		equ	4
SIPKA_VLEVO		equ	8
SIPKA_VPRAVO		equ	12
SIPKA_OTOCDOLEVA	equ	16
SIPKA_OTOCDOPRAVA	equ	20
SIPKA_NIC		equ	24

RUZICE:
defw	Komp_N,		X08+Y15
defw	Komp_E,		X08+Y15
defw	Komp_S,		X08+Y15
defw	Komp_W,		X08+Y15
RUZICE_END:

  

; index do tabulek, ktery znaci ze je nepritel primo pred nama 
ENEMY_ATTACK_DISTANCE	equ	12

ENEMY_GROUP:
;                  3 4                               3(4)                       (3)4
;                 1   2                               1(2)                     (1)2
;                   *                   vpravo      *                   vlevo       *
;             1         2         3         4         1         2         3         4         1         2         3         4
defw          0,        0,        0,        0,        0,        0,        0,        0,        0,        0,        0,        0
defw    X03+Y05,  X10+Y05,  X04+Y04,  X09+Y04,  X17+Y05,        0,  X16+Y04,        0,        0,  Xm4+Y05,        0,  Xm3+Y04   ; 16
defw    X05+Y05,  X10+Y05,  X06+Y04,  X09+Y04,  X15+Y05,        0,  X14+Y04,        0,        0,  X00+Y05,        0,  X01+Y04   ; 10
defw    X06+Y05,  X09+Y05,  X07+Y05,  X08+Y05,  X13+Y05,  X15+Y05,  X12+Y05,  X14+Y05,  X00+Y05,  X02+Y05,  X01+Y05,  X03+Y05   ; 6
defw    X08+Z04,  X09+Y04,  X09+Z04,  X10+Z04,  X12+Z04,  X14+Z04,  X10+Y04,  X13+Z04,  X03+Y04,  X05+Y04,  X04+Y04,  X07+Z04   ; 3.75? V tehle vzdalenosti to chce jeste o 2 vpravo a o 2 vlevo



DIV_6:
defw	0,	0,	0,	0,	0,	0
defw	2,	2,	2,	2,	2,	2
defw	4,	4,	4,	4,	4,	4
defw	6,	6,	6,	6,	6,	6
defw	8,	8,	8,	8,	8,	8



ITEM_POZICE:
; dvoubajtove cislo oznacuje levy horni roh odkud kreslit sprite
; prvni je souradnice se znamenkem X (zleva doprava)
; druhe je kladna souradnice Y (shora dolu), pokud je zaporna, tak se ma sprite kreslit zprava doleva 
;       primy smer                          vpravo                              vlevo                                 sirka zadni
;       l.dal    p.dal    p.bliz   l.bliz   l.dal    p.dal    p.bliz   l.bliz   l.dal    p.dal    p.bliz   l.bliz     steny
defw    X00+Y12, X17+Z12,       0,       0,       0,       0,       0,       0,       0,       0,       0,       0  ; 16
defw    X04+Y10, X13+Z10, X14+Z11, X03+Y11, X16+Y10,       0,       0, X17+Y11,       0, X01+Z10, X00+Z11,       0  ; 10
defw    X06+Y08, X11+Z08, X12+Z09, X05+Y09, X13+Y08, X18+Z08, X19+Z09, X14+Y09, Xm1+Y08, X04+Z08, X03+Z09, Xm2+Y09  ;  6
defw          0,       0,       0,       0,       0,       0,       0,       0,       0,       0,       0,       0  ;  4
defw          0,       0,       0,       0,       0,       0,       0,       0,       0,       0,       0,       0  ;


MAX_VIDITELNOST_PREDMETU_PLUS_1	equ	3*4*5   ; (primy smer/vpravo/vlevo) * ( 2 * world ) * 5 radek


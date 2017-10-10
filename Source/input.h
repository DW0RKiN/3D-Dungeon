TIMER_ADR	equ	$5C78
LAST_KEY_ADR	equ	$5C08


REPEAT_READING_JOY  equ $06
JOY_PORT            equ $1F

; -----------------------

FLOP_BIT_ATTACK     equ     $40

KEY_DOPREDU         equ     119     ; w
KEY_DOZADU          equ     115     ; s
KEY_VLEVO           equ     97      ; a
KEY_VPRAVO          equ     100     ; d
KEY_DOLEVA          equ     113     ; q
KEY_DOPRAVA         equ     101     ; e
KEY_SPACE           equ     32      ; mezernik
KEY_INVENTAR        equ     105     ; i
KEY_FHAND           equ     102     ; f
KEY_SHAND           equ     103     ; g
KEY_PLUS            equ     107     ; k
KEY_MINUS           equ     106     ; j

stisknuto_dopredu   equ     0
stisknuto_dozadu    equ     1
stisknuto_vlevo     equ     2
stisknuto_vpravo    equ     3

; Cte se z portu 31
; D0- joy RIGHT
; D1- joy LEFT
; D2- joy DOWN
; D3- joy UP
; D4- joy FIRE 1
; D5- joy FIRE 2 (podporovano jen u K-MOUSE interface, kde je podpora vsech trech tlacitek joysticku)
; D6- joy FIRE 3 (podporovano jen u K-MOUSE interface, kde je podpora vsech trech tlacitek joysticku)
; D7- nepouzito, obycejne zde vraci log.0

; vvvv ----------------- zacatek souvisleho bloku
DATA_KEMPSTON:
defb    $01,    KEY_VPRAVO      ; right
defb    $02,    KEY_VLEVO       ; left
defb    $09,    KEY_DOPRAVA     ; up+r
defb    $0a,    KEY_DOLEVA      ; up+l
defb    $04,    KEY_DOZADU      ; down
defb    $08,    KEY_DOPREDU     ; up
defb    $10,    KEY_SPACE       ; fire
defb    $05,    KEY_INVENTAR    ; down+r
defb    $06,    KEY_INVENTAR    ; down+l
defb    $11,    KEY_PLUS        ; fire+r
defb    $12,    KEY_MINUS       ; fire+l
defb    $18,    KEY_FHAND       ; fire+up
defb    $14,    KEY_SHAND       ; fire+down
DATA_KEMPSTON_END:
defb    $00
; ^^^^ ----------------- konec souvisleho bloku

DATA_KEMPSTON_SUM   equ (DATA_KEMPSTON_END-DATA_KEMPSTON)/2



TIMER_ADR	equ	$5C78
LAST_KEY_ADR	equ	$5C08

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
KEY_VEZMI           equ     111     ; o
KEY_POLOZ           equ     112     ; p


; Cte se z portu 31
; D0- joy RIGHT
; D1- joy LEFT
; D2- joy DOWN
; D3- joy UP
; D4- joy FIRE 1
; D5- joy FIRE 2 (podporovano jen u K-MOUSE interface, kde je podpora vsech trech tlacitek joysticku)
; D6- joy FIRE 3 (podporovano jen u K-MOUSE interface, kde je podpora vsech trech tlacitek joysticku)
; D7- nepouzito, obycejne zde vraci log.0
DATA_KEMPSTON:
;       right       left        up+r        up+l        down        up          fire        down+r      down+l      up+l+f
defb    $01,        $02,        $09,        $0a,        $04,        $08,        $10,        $05,        $06,        $1a 
defb    KEY_VPRAVO, KEY_VLEVO,  KEY_DOPRAVA,KEY_DOLEVA, KEY_DOZADU, KEY_DOPREDU,KEY_SPACE,  KEY_POLOZ,  KEY_VEZMI,  KEY_INVENTAR
north               equ     0
east                equ     1
south               equ     2
west                equ     3


;----------- Vazane promnene kvuli optimalizacim ( ale nic zasadniho v nejake kriticke casti )
LOCATION:
defb        52      ; musi byt pred VECTOR! kvuli optimalizaci ld hl,(LOCATION) ; 16:3 L=LOCATION, H=VECTOR
VECTOR:
defb        north   ; 0 = N,1 = E,2 = S,3 = W 
POHYB:
defb        0       ; nulty bit meni hodnotu pokazde pri otoceni nebo pohybu ( resi se to pres rychle inc(hl)  = pocitadlo pohybu/otoceni )
                    ; pouziva se pro zmenu podlahy, pocit zmeny pri stejnych stenach
;-----------



POSUN_VLEVO_INVENTAREM:
; rozsah do+1        posun o
defb        2,          16-MAX_INVENTORY
defb        3,          23-2-MAX_INVENTORY

defb        5,          29-3-MAX_INVENTORY
defb        6,          30-5-MAX_INVENTORY
defb        7,          26-6-MAX_INVENTORY  ; 6->26(p.prsten)
defb        8,          22-7-MAX_INVENTORY  ; 7->22(boty)
defb        21,         -8
defb        23,         -7
defb        27,         -5
defb        29,         -3
defb        MAX_INVENTORY,  -2

POSUN_VPRAVO_INVENTAREM:
; rozsah do        posun o
defb        13,         8
defb        17,         7
defb        18,         6           ; 17(hlava)->23(toulec)
defb        22,         5
defb        23,         16          ; 22(boty)->7
defb        24,         10          ; 23(toulec)->2
defb        26,         3
defb        27,         11          ; 26(p.prsten)->6
defb        29,         2           ; leva zem->prava zem
defb        MAX_INVENTORY,   5
POSUN_VLEVO_INVENTAREM_END:


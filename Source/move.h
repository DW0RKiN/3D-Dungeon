north               equ     0
east                equ     1
south               equ     2
west                equ     3


;----------- Vazane promnene kvuli optimalizacim ( ale nic zasadniho v nejake kriticke casti )
LOCATION:
defb        52      ; musi byt pred VECTOR! kvuli optimalizaci ld      hl,(VECTOR) ; 16:3 l=LOCATION, h=VECTOR
VECTOR:
defb        north   ; 0 = N,1 = E,2 = S,3 = W 
POHYB:
defb        0       ; nulty bit meni hodnotu pokazde pri otoceni nebo pohybu ( resi se to pres rychle inc(hl)  = pocitadlo pohybu/otoceni )
                    ; pouziva se pro zmenu podlahy, pocit zmeny pri stejnych stenach
;-----------



POSUN_VLEVO_INVENTAREM:
; rozsah do+1        posun o
defb        2,          -11
defb        5,          -6
defb        7,          -7
defb        8,          -12
defb        21,         -8
defb        23,         -7
defb        MAX_ITEM,   -5
POSUN_VPRAVO_INVENTAREM:
; rozsah do        posun o
defb        13,         8
defb        17,         7
defb        18,         6
defb        22,         5
defb        23,         4
defb        MAX_ITEM,   7
POSUN_VLEVO_INVENTAREM_END:

if (POSUN_VLEVO_INVENTAREM/256) != (POSUN_VLEVO_INVENTAREM_END/256)
    .error      'Seznam POSUN_VLEVO_INVENTAREM prekracuje 256 bajtovy segment!'
endif
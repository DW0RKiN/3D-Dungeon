; ------------ aktualni adresa podfce je v test.asm
;Sever  = 0     0 1
;               2 3
;Vychod = 1     1 3 =>
;               0 2
;Jih    = 2     3 2 => 3-Sever
;               1 0
;Zapad  = 3     2 0 =>
;               3 1

i_nw        equ     0       ; item north-west position
i_ne        equ     1       ; item north-east position
i_se        equ     2       ; item south-east position
i_sw        equ     3       ; item south-west position


i_lz        equ     0       ; predmet vidim jako levy-zadni
i_pz        equ     2       ; predmet vidim jako pravy-zadni
i_lp        equ     4       ; predmet vidim jako levy-predni
i_pp        equ     6       ; predmet vidim jako pravy-predni


ITEM_NATOCENI:
;       vlevo   a vpravo dal,   vlevo   a vpravo bliz
defb    i_lz,   i_pz,           i_pp,   i_lp        ; divam se na sever
defb    i_lp,   i_lz,           i_pz,   i_pp        ; divam se na vychod
defb    i_pp,   i_lp,           i_lz,   i_pz        ; divam se na jih
defb    i_pz,   i_pp,           i_lp,   i_lz        ; divam se na zapad
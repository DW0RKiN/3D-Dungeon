DUNGEON_MAP:
;	0 1 2 3 4 5 6 7 8 9 A B C D E F
defb	3,3,3,3,3,3,2,3,3,3,3,3,3,3,3,3   ; 00 0 ( na pozici 0 musi byt stena ( = zadny predmet, paka, dvere ), znaci rozsirene udaje u TABLE_OBJECTS )
defb	0,0,3,0,0,0,0,3,0,0,0,3,0,0,0,3   ; 10 16 
defb	0,0,3,0,0,3,0,0,0,3,0,3,0,3,0,3   ; 20 32 
defb	0,0,0,0,0,0,3,3,3,0,0,0,0,3,0,3   ; 30 48 
defb	0,0,0,0,0,0,3,3,0,0,3,3,0,3,0,3   ; 40 64 
defb	0,0,0,0,0,0,3,0,0,3,0,0,0,3,0,3   ; 50 80
defb	0,0,0,0,0,3,3,3,3,0,0,3,0,3,0,3   ; 60 96 
defb	3,0,0,3,0,0,0,0,0,0,0,0,0,3,0,3   ; 70 112 119 dvere
defb	3,2,3,3,3,3,3,3,3,3,0,3,3,3,0,3   ; 80 128 132-S paka,142 dvere
defb	3,0,0,0,0,0,0,0,3,0,0,0,0,3,0,3   ; 90 144 158 zavrene dvere otevirane kombinaci pak
defb	3,0,3,0,3,0,0,0,3,0,0,0,0,3,0,3   ; A0 160 
defb	3,0,0,0,0,0,0,0,3,3,3,3,3,3,0,3   ; B0 176 185..188-S paky
defb	3,0,3,0,3,0,0,0,3,0,0,0,3,3,0,0   ; C0 192
defb	3,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0   ; D0 208 216-W Paka 216-E Paka
defb	3,0,0,0,0,0,0,0,0,0,0,0,3,3,0,0   ; E0 224 232 dvere
defb	3,3,3,3,3,3,2,3,3,3,3,3,3,3,3,3   ; F0 240 ( na pozici 255 musi byt stena ( = zadny predmet, paka, dvere ), znaci zarazku u TABLE_OBJECTS )
;	0 1 2 3 4 5 6 7 8 9 A B C D E F
sirka	equ	16

; drobny bug .) $ff lokace nesmi byt totiz ani v dohledu
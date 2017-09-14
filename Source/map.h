DUNGEON_MAP:
;	0 1 2 3 4 5 6 7 8 9 A B C D E F
defb	3,3,3,3,3,3,2,3,3,3,3,3,3,3,3,3   ; 0 ( na pozici 0 musi byt stena ( = zadny predmet, paka, dvere ), znaci rozsirene udaje u TABLE_ITEM )
defb	0,0,3,0,0,0,0,3,0,0,0,3,0,0,0,3   ; 16 
defb	0,0,3,0,0,3,0,0,0,3,0,3,0,3,0,3   ; 32 
defb	0,0,0,0,0,0,3,3,3,0,0,0,0,3,0,3   ; 48 
defb	0,0,0,0,0,0,3,3,0,0,3,3,0,3,0,3   ; 64 
defb	0,0,0,0,0,0,3,0,0,3,0,0,0,3,0,3   ; 80
defb	0,0,0,0,0,3,3,3,3,0,0,3,0,3,0,3   ; 96 
defb	3,0,0,3,0,0,0,0,0,0,0,0,0,3,0,3   ; 112 119 dvere
defb	3,3,2,3,3,3,3,3,3,3,0,3,3,3,0,3   ; 128 132-S paka
defb	3,0,0,0,0,0,0,0,3,0,0,0,0,3,0,3   ; 144 158 zavrene dvere otevirane kombinaci pak
defb	3,0,3,0,3,0,0,0,3,0,0,0,0,3,0,3   ; 160 
defb	3,0,0,0,0,0,0,0,3,3,3,3,3,3,0,3   ; 176 185..188-S paky
defb	3,0,3,0,3,0,0,0,3,0,0,0,3,3,0,0   ; 192
defb	3,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0   ; 208 216-W Paka 216-E Paka
defb	3,0,0,0,0,0,0,0,0,0,0,0,3,3,0,0   ; 224 232 dvere
defb	3,3,3,3,3,3,2,3,3,3,3,3,3,3,3,3   ; 240 ( na pozici 255 musi byt stena ( = zadny predmet, paka, dvere ), znaci zarazku u TABLE_ITEM )
;	0 1 2 3 4 5 6 7 8 9 A B C D E F
sirka	equ	16

PISMO_5PX:
defb $00,$00,$00,$00,$00	; 32 space 0-4
defb $00,$3a,$00,$00,$00	; 33 ! 0-4
defb $00,$60,$00,$60,$00	; 34 " 5-9
defb $14,$3e,$14,$3e,$14	; 35 # 10-14
defb $00,$12,$2a,$6b,$24	; 36 $ 15-19
defb $32,$34,$08,$16,$26	; 37 % 20-24
defb $00,$14,$3a,$14,$0a	; 38 & 25-29
defb $00,$00,$60,$00,$00	; 39 ' 30-34
defb $00,$00,$3c,$42,$00	; 40 ( 35-39
defb $00,$00,$42,$3c,$00	; 41 ) 40-44
defb $00,$14,$08,$14,$00	; 42 * 45-49
defb $00,$08,$1c,$08,$00	; 43 + 50-54
defb $00,$02,$04,$00,$00	; 44 , 55-59
defb $00,$08,$08,$08,$00	; 45 - 60-64
defb $00,$02,$00,$00,$00	; 46 . 65-69
defb $02,$04,$08,$10,$20	; 47 / 70-74
defb $00,$1c,$26,$2a,$1c	; 48 0 75-79
defb $00,$12,$3e,$02,$00	; 49 1 80-84
defb $00,$26,$2a,$2a,$12	; 50 2 85-89
defb $00,$22,$2a,$2a,$14	; 51 3 90-94
defb $00,$3c,$04,$0e,$04	; 52 4 95-99
defb $00,$3a,$2a,$2a,$24	; 53 5 100-104
defb $00,$1c,$2a,$2a,$04	; 54 6 105-109
defb $00,$20,$26,$28,$30	; 55 7 110-114
defb $00,$14,$2a,$2a,$14	; 56 8 115-119
defb $00,$10,$2a,$2a,$1c	; 57 9 120-124
defb $00,$00,$14,$00,$00	; 58 : 125-129
defb $00,$02,$14,$00,$00	; 59 ; 130-134
defb $00,$08,$14,$22,$00	; 60 < 135-139
defb $00,$14,$14,$14,$00	; 61 = 140-144
defb $00,$22,$14,$08,$00	; 62 > 145-149
defb $00,$10,$20,$2a,$10	; 63 ? 150-154
defb $00,$1c,$22,$3a,$1a	; 64 @ 155-159
defb $00,$1e,$28,$28,$1e	; 65 A 160-164
defb $00,$3e,$2a,$2a,$14	; 66 B 165-169
defb $00,$1c,$22,$22,$22	; 67 C 170-174
defb $00,$3e,$22,$22,$1c	; 68 D 175-179
defb $00,$3e,$2a,$2a,$22	; 69 E 180-184
defb $00,$3e,$28,$28,$20	; 70 F 185-189
defb $00,$1c,$22,$2a,$0c	; 71 G 190-194
defb $00,$3e,$08,$08,$3e	; 72 H 195-199
defb $00,$22,$3e,$22,$00	; 73 I 200-204
defb $00,$04,$02,$02,$3c	; 74 J 205-209
defb $00,$3e,$08,$14,$22	; 75 K 210-214
defb $00,$3e,$02,$02,$02	; 76 L 215-219
defb $00,$3e,$10,$10,$3e	; 77 M 220-224
defb $00,$3e,$10,$08,$3e	; 78 N 225-229
defb $00,$1c,$22,$22,$1c	; 79 O 230-234
defb $00,$3e,$28,$28,$10	; 80 P 235-239
defb $00,$1c,$22,$26,$1e	; 81 Q 240-244
defb $00,$3e,$28,$28,$16	; 82 R 245-249
defb $00,$12,$2a,$2a,$24	; 83 S 250-254
defb $00,$20,$3e,$20,$20	; 84 T 255-259
defb $00,$3c,$02,$02,$3c	; 85 U 260-264
defb $00,$3e,$02,$04,$38	; 86 V 265-269
defb $00,$3e,$04,$04,$3e	; 87 W 270-274
defb $00,$36,$08,$08,$36	; 88 X 275-279
defb $00,$38,$06,$08,$30	; 89 Y 280-284
defb $00,$26,$2a,$2a,$32	; 90 Z 285-289
defb $00,$00,$7e,$42,$00	; 91 [ 290-294
defb $20,$10,$08,$04,$02	; 92 \ 295-299
defb $00,$00,$42,$7e,$00	; 93 ] 300-304
defb $10,$20,$40,$20,$10	; 94 ^ 305-309
defb $00,$02,$02,$02,$02	; 95 _ 310-314
defb $00,$08,$3e,$4a,$22	; 96 ` 315-319

if (PISMO_5PX % 256 != 0)
    .error 'Adresa pocatku fontu PISMO_5PX nelezi na pocatku segmentu'
endif
; SPRITY      od adresy $5F00   = 24320
       Body_left    equ $5F00   ; 24320   1. =   234, +0
     dno_bufferu    equ $5FEA   ; 24554   2. =   165, +234
              D0    equ $608F   ; 24719   3. =  1083, +399
              D1    equ $64CA   ; 25802   4. =   507, +1482
              D2    equ $66C5   ; 26309   5. =   273, +1989
              D3    equ $67D6   ; 26582   6. =   127, +2262
            ESA1    equ $6855   ; 26709   7. =   537, +2389
             ES1    equ $6A6E   ; 27246   8. =   419, +2926
             ES2    equ $6C11   ; 27665   9. =   253, +3345
             ES3    equ $6D0E   ; 27918  10. =   108, +3598
             ES4    equ $6D7A   ; 28026  11. =    81, +3706
         FFace01    equ $6DCB   ; 28107  12. =   147, +3787
         FFace02    equ $6E5E   ; 28254  13. =   147, +3934
         FFace03    equ $6EF1   ; 28401  14. =   147, +4081
         FFace04    equ $6F84   ; 28548  15. =   147, +4228
            Flek    equ $7017   ; 28695  16. =   117, +4375
              H0    equ $708C   ; 28812  17. =  1731, +4492
          H0rune    equ $774F   ; 30543  18. =    87, +6223
              H1    equ $77A6   ; 30630  19. =   723, +6310
          H1rune    equ $7A79   ; 31353  20. =    51, +7033
              H2    equ $7AAC   ; 31404  21. =   355, +7084
          H2rune    equ $7C0F   ; 31759  22. =    31, +7439
              H3    equ $7C2E   ; 31790  23. =   183, +7470
          H3rune    equ $7CE5   ; 31973  24. =    31, +7653
              H4    equ $7D04   ; 32004  25. =   143, +7684
            H4m1    equ $7D93   ; 32147  26. =   103, +7827
            H4m2    equ $7DFA   ; 32250  27. =   146, +7930
            H4m3    equ $7E8C   ; 32396  28. =   111, +8076
            H4m4    equ $7EFB   ; 32507  29. =    49, +8187
              H5    equ $7F2C   ; 32556  30. =   129, +8236
          I_ankh    equ $7FAD   ; 32685  31. =    57, +8365
      I_armor_ch    equ $7FE6   ; 32742  32. =    57, +8422
       I_armor_l    equ $801F   ; 32799  33. =    57, +8479
       I_armor_p    equ $8058   ; 32856  34. =    57, +8536
           I_axe    equ $8091   ; 32913  35. =    49, +8593
            I_bg    equ $80C2   ; 32962  36. =    57, +8642
           I_bgm    equ $80FB   ; 33019  37. =    57, +8699
          I_bone    equ $8134   ; 33076  38. =    57, +8756
          I_book    equ $816D   ; 33133  39. =    57, +8813
         I_boots    equ $81A6   ; 33190  40. =    57, +8870
           I_bow    equ $81DF   ; 33247  41. =    49, +8927
        I_dagger    equ $8210   ; 33296  42. =    41, +8976
         I_empty    equ $8239   ; 33337  43. =    49, +9017
          I_helm    equ $826A   ; 33386  44. =    57, +9066
        I_helm_d    equ $82A3   ; 33443  45. =    57, +9123
          I_mace    equ $82DC   ; 33500  46. =    51, +9180
      I_necklace    equ $830F   ; 33551  47. =    41, +9231
      I_potion_b    equ $8338   ; 33592  48. =    41, +9272
      I_potion_g    equ $8361   ; 33633  49. =    41, +9313
      I_potion_r    equ $838A   ; 33674  50. =    41, +9354
    I_prostirani    equ $83B3   ; 33715  51. =    57, +9395
           I_ram    equ $83EC   ; 33772  52. =    25, +9452
       I_rations    equ $8405   ; 33797  53. =    57, +9477
          I_ring    equ $843E   ; 33854  54. =    41, +9534
        I_ring_b    equ $8467   ; 33895  55. =    57, +9575
        I_ring_g    equ $84A0   ; 33952  56. =    57, +9632
        I_ring_r    equ $84D9   ; 34009  57. =    57, +9689
        I_ring_w    equ $8512   ; 34066  58. =    57, +9746
        I_shield    equ $854B   ; 34123  59. =    57, +9803
       I_shield2    equ $8584   ; 34180  60. =    57, +9860
         I_sling    equ $85BD   ; 34237  61. =    49, +9917
         I_sword    equ $85EE   ; 34286  62. =    49, +9966
        I_toulec    equ $861F   ; 34335  63. =    41, +10015
      I_zakazano    equ $8648   ; 34376  64. =    57, +10056
         I0_bone    equ $8681   ; 34433  65. =   243, +10113
       I0_shield    equ $8774   ; 34676  66. =   245, +10356
       I0_unknwn    equ $8869   ; 34921  67. =   154, +10601
       I0_weapon    equ $8903   ; 35075  68. =   162, +10755
         I1_bone    equ $89A5   ; 35237  69. =   109, +10917
       I1_shield    equ $8A12   ; 35346  70. =   123, +11026
       I1_unknwn    equ $8A8D   ; 35469  71. =    97, +11149
       I1_weapon    equ $8AEE   ; 35566  72. =    97, +11246
         I2_bone    equ $8B4F   ; 35663  73. =    46, +11343
       I2_shield    equ $8B7D   ; 35709  74. =    46, +11389
       I2_unknwn    equ $8BAB   ; 35755  75. =    37, +11435
       I2_weapon    equ $8BD0   ; 35792  76. =    37, +11472
          Kanal0    equ $8BF5   ; 35829  77. =   363, +11509
          Kanal1    equ $8D60   ; 36192  78. =   165, +11872
          Kanal2    equ $8E05   ; 36357  79. =    75, +12037
          Kanal3    equ $8E50   ; 36432  80. =    39, +12112
          Kompas    equ $8E77   ; 36471  81. =   386, +12151
          Komp_E    equ $8FF9   ; 36857  82. =   160, +12537
          Komp_N    equ $9099   ; 37017  83. =   160, +12697
          Komp_S    equ $9139   ; 37177  84. =   160, +12857
          Komp_W    equ $91D9   ; 37337  85. =   160, +13017
            K1m1    equ $9279   ; 37497  86. =   411, +13177
            K2m1    equ $9414   ; 37908  87. =   427, +13588
            K3m1    equ $95BF   ; 38335  88. =   381, +14015
            K4m2    equ $973C   ; 38716  89. =   220, +14396
         MFace01    equ $9818   ; 38936  90. =   147, +14616
         MFace02    equ $98AB   ; 39083  91. =   147, +14763
         MFace03    equ $993E   ; 39230  92. =   147, +14910
         MFace04    equ $99D1   ; 39377  93. =   147, +15057
            Pdl1    equ $9A64   ; 39524  94. =    49, +15204
            Pdl2    equ $9A95   ; 39573  95. =    39, +15253
            Pdl3    equ $9ABC   ; 39612  96. =    21, +15292
             Pd0    equ $9AD1   ; 39633  97. =   115, +15313
             Pd1    equ $9B44   ; 39748  98. =    95, +15428
             Pd2    equ $9BA3   ; 39843  99. =    39, +15523
             Pd3    equ $9BCA   ; 39882 100. =    39, +15562
            Pul1    equ $9BF1   ; 39921 101. =    57, +15601
            Pul2    equ $9C2A   ; 39978 102. =    49, +15658
            Pul3    equ $9C5B   ; 40027 103. =    21, +15707
             Pu0    equ $9C70   ; 40048 104. =   115, +15728
             Pu1    equ $9CE3   ; 40163 105. =    95, +15843
             Pu2    equ $9D42   ; 40258 106. =    57, +15938
             Pu3    equ $9D7B   ; 40315 107. =    31, +15995
              R0    equ $9D9A   ; 40346 108. =  1055, +16026
              R1    equ $A1B9   ; 41401 109. =  1011, +17081
            R1m1    equ $A5AC   ; 42412 110. =   111, +18092
              R2    equ $A61B   ; 42523 111. =   499, +18203
            R2m1    equ $A80E   ; 43022 112. =   227, +18702
              R3    equ $A8F1   ; 43249 113. =   225, +18929
            R3m1    equ $A9D2   ; 43474 114. =   207, +19154
              R4    equ $AAA1   ; 43681 115. =   131, +19361
        S_doleva    equ $AB24   ; 43812 116. =    39, +19492
       S_doprava    equ $AB4B   ; 43851 117. =    39, +19531
       S_dopredu    equ $AB72   ; 43890 118. =    39, +19570
        S_dozadu    equ $AB99   ; 43929 119. =    39, +19609
         S_vlevo    equ $ABC0   ; 43968 120. =    39, +19648
        S_vpravo    equ $ABE7   ; 44007 121. =    39, +19687
       S_vsechny    equ $AC0E   ; 44046 122. =   318, +19726
            V0m1    equ $AD4C   ; 44364 123. =   129, +20044
            V3m2    equ $ADCD   ; 44493 124. =   149, +20173
            V4m1    equ $AE62   ; 44642 125. =    91, +20322
            V4m3    equ $AEBD   ; 44733 126. =   127, +20413
; first address after   $AF3C   = 44860

Adr_Buffer equ $B000
Adr_Attr_Buffer equ $C800
Adr_Buf_end equ $CB00
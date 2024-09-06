sprite
;********************************************************
;*           Sprite name: square.00
;*           Sprite size: 16x32 (512 bytes)
;*          Compile date: 11/7/2024 11:40:44 AM
;*          Compile time: 0.12900 seconds
;* ---------------------- 
;*  Compiled Cycle count: 1996
;*       Raw Cycle count: 4972
;*           Cycle ratio: .401 (149.1% faster)
;* ---------------------- 
;*   Compiled Byte count: 876
;*        Raw Byte count: 512
;*            Byte ratio: 1.711 (71.1% larger)
;* ---------------------- 
;*      CoCo render time: 0.001786193 seconds
;*
;********************************************************
square.00
                ldd     #$2222
                std     7,x
                std     9,x
                std     11,x
                std     13,x
                stb     15,x
                ldd     #$0000
                std     ,x
                std     2,x
                std     4,x
                stb     6,x

                ldb     #128            ;row01
                abx
                ldd     #$2222
                std     ,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x
                stb     2,x
                stb     5,x
                ldd     #$0002
                std     3,x

                ldb     #128            ;row02
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x

                ldb     #128            ;row03
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x

                ldb     #128            ;row04
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                std     14,x
                stb     6,x
                ldd     #$1111
                std     8,x
                std     10,x
                std     12,x
                lda     #$21
                sta     7,x

                ldb     #128            ;row05
                abx
                ldd     #$1111
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                std     4,x
                sta     2,x
                sta     3,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row06
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row07
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row08
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row09
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row10
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row11
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row12
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row13
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row14
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row15
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row16
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row17
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row18
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$2222
                std     ,x
                std     14,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row19
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     14,x
                stb     15,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row20
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     14,x
                stb     15,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row21
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     14,x
                stb     15,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row22
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     14,x
                stb     15,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row23
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     14,x
                stb     15,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row24
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     14,x
                stb     15,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row25
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     14,x
                stb     15,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row26
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     14,x
                stb     15,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row27
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                ldd     #$2222
                std     ,x
                std     14,x
                stb     13,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row28
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     12,x
                std     14,x
                ldd     #$1111
                std     7,x
                std     9,x
                lda     #$21
                sta     6,x
                lda     #$12
                sta     11,x

                ldb     #128            ;row29
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x

                ldb     #128            ;row30
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                stb     14,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row31
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$0000
                std     14,x
		rts


;********************************************************
;*           Sprite name: square.01
;*           Sprite size: 16x32 (512 bytes)
;*          Compile date: 11/7/2024 11:40:44 AM
;*          Compile time: 0.15500 seconds
;* ---------------------- 
;*  Compiled Cycle count: 2021
;*       Raw Cycle count: 4972
;*           Cycle ratio: .406 (146% faster)
;* ---------------------- 
;*   Compiled Byte count: 895
;*        Raw Byte count: 512
;*            Byte ratio: 1.748 (74.8% larger)
;* ---------------------- 
;*      CoCo render time: 0.001808565 seconds
;*
;********************************************************

square.01
                ldd     #$2222
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     ,x
                ldd     #$0000
                std     2,x
                std     14,x
                stb     13,x
                lda     #$20
                sta     1,x
                lda     #$02
                sta     4,x

                ldb     #128            ;row01
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                stb     14,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row02
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x

                ldb     #128            ;row03
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                std     10,x
                std     12,x
                std     14,x
                stb     6,x
                stb     9,x
                ldd     #$2111
                std     7,x

                ldb     #128            ;row04
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     14,x
                stb     4,x
                stb     13,x
                ldd     #$1111
                std     6,x
                std     8,x
                std     10,x
                lda     #$21
                sta     5,x
                lda     #$12
                sta     12,x

                ldb     #128            ;row05
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     15,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row06
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                stb     15,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row07
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$2222
                std     ,x
                stb     15,x
                lda     #$21
                sta     2,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row08
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$2222
                std     ,x
                stb     15,x
                lda     #$21
                sta     2,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row09
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$2222
                std     ,x
                stb     15,x
                lda     #$21
                sta     2,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row10
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                stb     15,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row11
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                stb     15,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row12
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row13
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row14
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row15
                abx
                ldd     #$1111
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$2222
                std     14,x
                stb     ,x

                ldb     #128            ;row16
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row17
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row18
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row19
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     15,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row20
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     15,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row21
                abx
                ldd     #$1111
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$1222
                std     14,x
                stb     ,x

                ldb     #128            ;row22
                abx
                ldd     #$1111
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$1222
                std     14,x
                stb     ,x

                ldb     #128            ;row23
                abx
                ldd     #$1111
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$1222
                std     14,x
                stb     ,x

                ldb     #128            ;row24
                abx
                ldd     #$1111
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$1222
                std     14,x
                stb     ,x

                ldb     #128            ;row25
                abx
                ldd     #$1111
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$1222
                std     14,x
                stb     ,x

                ldb     #128            ;row26
                abx
                ldd     #$1111
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$2222
                std     14,x
                stb     ,x

                ldb     #128            ;row27
                abx
                ldd     #$1111
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                stb     9,x
                ldd     #$2222
                std     11,x
                std     13,x
                stb     15,x
                lda     #$21
                sta     ,x
                lda     #$12
                sta     10,x

                ldb     #128            ;row28
                abx
                ldd     #$2222
                std     7,x
                std     9,x
                std     11,x
                std     13,x
                stb     ,x
                stb     15,x
                ldd     #$1111
                std     1,x
                std     3,x
                std     5,x

                ldb     #128            ;row29
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x

                ldb     #128            ;row30
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                stb     14,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row31
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                stb     10,x
                stb     14,x
                ldd     #$0000
                std     11,x
                stb     13,x
                stb     15,x
		rts


;********************************************************
;*           Sprite name: square.02
;*           Sprite size: 16x32 (512 bytes)
;*          Compile date: 11/7/2024 11:40:44 AM
;*          Compile time: 0.15400 seconds
;* ---------------------- 
;*  Compiled Cycle count: 2056
;*       Raw Cycle count: 4972
;*           Cycle ratio: .414 (141.8% faster)
;* ---------------------- 
;*   Compiled Byte count: 926
;*        Raw Byte count: 512
;*            Byte ratio: 1.809 (80.9% larger)
;* ---------------------- 
;*      CoCo render time: 0.001839886 seconds
;*
;********************************************************

square.02
                ldd     #$0000
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                ldd     #$2222
                std     ,x
                std     12,x
                stb     14,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row01
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x

                ldb     #128            ;row02
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x

                ldb     #128            ;row03
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                stb     14,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row04
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     14,x
                ldd     #$2112
                std     12,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row05
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row06
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row07
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row08
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row09
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row10
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row11
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row12
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row13
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row14
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row15
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x
                lda     #$12
                sta     13,x

                ldb     #128            ;row16
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row17
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row18
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row19
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row20
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row21
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row22
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row23
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row24
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$2222
                std     ,x
                std     14,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row25
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     14,x
                stb     15,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row26
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     15,x
                lda     #$21
                sta     2,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row27
                abx
                ldd     #$1111
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     1,x
                std     3,x
                stb     15,x
                lda     #$02
                sta     ,x
                lda     #$21
                sta     5,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row28
                abx
                ldd     #$2222
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                stb     11,x
                stb     15,x
                ldd     #$2111
                std     12,x
                lda     #$02
                sta     ,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row29
                abx
                ldd     #$2222
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                std     13,x
                stb     15,x
                lda     #$02
                sta     ,x

                ldb     #128            ;row30
                abx
                ldd     #$2222
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                std     13,x
                stb     15,x
                lda     #$02
                sta     ,x

                ldb     #128            ;row31
                abx
                ldd     #$2222
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                std     13,x
                stb     1,x
                stb     15,x
                ldd     #$2000
                std     2,x
                stb     ,x
                stb     4,x
		rts
		

;********************************************************
;*           Sprite name: square.03
;*           Sprite size: 16x32 (512 bytes)
;*          Compile date: 11/7/2024 11:40:45 AM
;*          Compile time: 0.14100 seconds
;* ---------------------- 
;*  Compiled Cycle count: 2074
;*       Raw Cycle count: 4972
;*           Cycle ratio: .417 (139.7% faster)
;* ---------------------- 
;*   Compiled Byte count: 938
;*        Raw Byte count: 512
;*            Byte ratio: 1.832 (83.2% larger)
;* ---------------------- 
;*      CoCo render time: 0.001855994 seconds
;*
;********************************************************

square.03
                ldd     #$0000
                std     ,x
                std     12,x
                std     14,x
                stb     2,x
                stb     11,x
                ldd     #$2222
                std     4,x
                std     6,x
                std     8,x
                lda     #$02
                sta     3,x
                lda     #$20
                sta     10,x

                ldb     #128            ;row01
                abx
                ldd     #$2222
                std     1,x
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                std     13,x
                lda     #$02
                sta     ,x
                lda     #$00
                sta     15,x

                ldb     #128            ;row02
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                stb     14,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row03
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x

                ldb     #128            ;row04
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     10,x
                std     12,x
                std     14,x
                ldd     #$1111
                std     5,x
                std     7,x
                lda     #$21
                sta     4,x
                lda     #$12
                sta     9,x

                ldb     #128            ;row05
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     14,x
                lda     #$21
                sta     2,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row06
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                ldd     #$0222
                std     ,x
                stb     14,x
                lda     #$21
                sta     2,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row07
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                ldd     #$2222
                std     ,x
                stb     14,x
                lda     #$21
                sta     2,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row08
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2222
                std     ,x
                stb     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row09
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2222
                std     ,x
                stb     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row10
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2222
                std     ,x
                stb     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row11
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                lda     #$12
                sta     13,x
                lda     #$20
                sta     15,x

                ldb     #128            ;row12
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                stb     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x
                lda     #$12
                sta     13,x

                ldb     #128            ;row13
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row14
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row15
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row16
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row17
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2221
                std     ,x
                sta     14,x
                sta     15,x

                ldb     #128            ;row18
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row19
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row20
                abx
                ldd     #$1111
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                ldd     #$2222
                std     ,x
                std     14,x

                ldb     #128            ;row21
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$2222
                std     ,x
                std     14,x
                lda     #$21
                sta     2,x

                ldb     #128            ;row22
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$2222
                std     ,x
                stb     15,x
                lda     #$21
                sta     2,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row23
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     15,x
                lda     #$21
                sta     2,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row24
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     15,x
                lda     #$21
                sta     2,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row25
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     15,x
                lda     #$21
                sta     2,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row26
                abx
                ldd     #$1111
                std     3,x
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                stb     13,x
                ldd     #$0222
                std     ,x
                stb     2,x
                stb     15,x
                lda     #$12
                sta     14,x

                ldb     #128            ;row27
                abx
                ldd     #$1111
                std     5,x
                std     7,x
                std     9,x
                std     11,x
                ldd     #$2222
                std     ,x
                std     2,x
                std     14,x
                lda     #$21
                sta     4,x
                lda     #$12
                sta     13,x

                ldb     #128            ;row28
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     10,x
                std     12,x
                std     14,x
                ldd     #$2111
                std     6,x
                stb     8,x
                stb     9,x

                ldb     #128            ;row29
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x

                ldb     #128            ;row30
                abx
                ldb     #$22
                std     ,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x
                stb     3,x
                lda     #$02
                sta     2,x

                ldb     #128            ;row31
                abx
                ldd     #$2222
                std     4,x
                std     6,x
                std     8,x
                std     10,x
                std     12,x
                std     14,x
                ldd     #$0220
                std     ,x
                sta     3,x
                lda     #$00
                sta     2,x
                rts

erasesp
                ldx     #$0000
                ldy     #$0000
                ldd     #$0000

                ldu     #$97C8

                pshu    y,x,d      ; row31
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row30
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row29
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row28
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row27
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row26
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row25
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row24
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row23
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row22
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row21
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row20
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row19
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row18
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row17
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row16
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row15
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row14
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row13
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row12
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row11
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row10
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row09
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row08
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row07
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row06
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row05
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row04
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row03
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row02
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row01
                pshu    y,x,d
                pshu    y,x
                leau    -112,u

                pshu    y,x,d      ; row00
                pshu    y,x,d
                pshu    y,x
                leau    -112,u
                rts


bbidle.00
                ldd     #$0000
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                stb     10,x

                ldb     #128            ;row01
                abx
                ldb     #$00
                std     ,x
                std     8,x
                stb     2,x
                stb     10,x
                lda     7,x
                anda    #$f0
                sta     7,x
                lda     3,x
                anda    #$0f
                sta     3,x

                ldb     #128            ;row02
                abx
                ldd     #$0000
                std     ,x
                stb     9,x
                stb     10,x
                lda     8,x
                anda    #$f0
                sta     8,x
                lda     2,x
                anda    #$0f
                sta     2,x

                ldb     #128            ;row03
                abx
                ldb     ,x
                andb    #$0f
                orb     #$00
                lda     #$00
                std     ,x
                sta     10,x
                lda     9,x
                anda    #$f0
                sta     9,x

                ldb     #128            ;row04
                abx
                lda     #$00
                sta     ,x
                sta     10,x

                ldb     #128            ;row05
                abx
                lda     4,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     4,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x
                lda     6,x
                anda    #$0f
                ora     #$20
                sta     6,x

                ldb     #131            ;row06
                abx
                lda     ,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     ,x
                stb     2,x
                stb     3,x
                lda     4,x
                anda    #$0f
                ora     #$20
                sta     4,x

                ldb     #127            ;row07
                abx
                ldd     #$2222
                std     1,x
                std     3,x
                stb     5,x
                lda     ,x
                anda    #$f0
                ora     #$02
                sta     ,x
                lda     6,x
                anda    #$0f
                ora     #$20
                sta     6,x

                ldb     #128            ;row08
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                stb     6,x

                ldb     #128            ;row09
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                stb     6,x

                ldb     #128            ;row10
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                stb     6,x

                ldb     #128            ;row11
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                stb     6,x

                ldb     #128            ;row12
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                stb     6,x

                ldb     #128            ;row13
                abx
                ldb     #$22
                std     1,x
                std     3,x
                stb     5,x
                lda     ,x
                anda    #$f0
                ora     #$02
                sta     ,x
                lda     6,x
                anda    #$0f
                ora     #$20
                sta     6,x

                ldb     #129            ;row14
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                stb     4,x

                ldb     #125            ;row15
                abx
                ldb     #$22
                std     4,x
                stb     6,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x

                ldb     #128            ;row16
                abx
                lda     4,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     4,x
                lda     #$00
                sta     ,x
                lda     6,x
                anda    #$0f
                ora     #$20
                sta     6,x
                lda     #$00
                sta     10,x

                ldb     #128            ;row17
                abx
                ldb     ,x
                andb    #$0f
                orb     #$00
                std     ,x
                sta     10,x
                lda     9,x
                anda    #$f0
                sta     9,x

                ldb     #128            ;row18
                abx
                ldd     #$0000
                std     ,x
                stb     9,x
                stb     10,x

                ldb     #128            ;row19
                abx
                ldb     #$00
                std     ,x
                std     8,x
                stb     2,x
                stb     10,x


                rts

bbidle.01
                ldd     #$0000
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                stb     10,x

                ldb     #128            ;row01
                abx
                ldb     #$00
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                stb     10,x

                ldb     #128            ;row02
                abx
                ldb     #$00
                std     ,x
                std     8,x
                stb     2,x
                stb     10,x

                ldb     #128            ;row03
                abx
                ldb     #$00
                std     ,x
                stb     9,x
                stb     10,x

                ldb     #128            ;row04
                abx
                ldb     ,x
                andb    #$0f
                orb     #$00
                std     ,x
                sta     10,x
                lda     9,x
                anda    #$f0
                sta     9,x

                ldb     #128            ;row05
                abx
                lda     #$00
                sta     ,x
                sta     10,x

                ldb     #128            ;row06
                abx
                ldd     #$2222
                std     4,x
                stb     6,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x

                ldb     #128            ;row07
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x

                ldb     #128            ;row08
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x
                lda     2,x
                anda    #$f0
                ora     #$02
                sta     2,x
                lda     8,x
                anda    #$0f
                ora     #$20
                sta     8,x

                ldb     #130            ;row09
                abx
                ldd     #$2222
                std     1,x
                std     3,x
                stb     5,x
                lda     ,x
                anda    #$f0
                ora     #$02
                sta     ,x
                lda     6,x
                anda    #$0f
                ora     #$20
                sta     6,x

                ldb     #128            ;row10
                abx
                ldd     #$2222
                std     1,x
                std     3,x
                stb     5,x
                lda     ,x
                anda    #$f0
                ora     #$02
                sta     ,x
                lda     6,x
                anda    #$0f
                ora     #$20
                sta     6,x

                ldb     #128            ;row11
                abx
                ldd     #$2222
                std     ,x
                std     2,x
                std     4,x
                stb     6,x

                ldb     #128            ;row12
                abx
                ldb     #$22
                std     ,x
                std     2,x
                std     4,x
                stb     6,x

                ldb     #129            ;row13
                abx
                ldb     #$22
                std     ,x
                std     2,x
                stb     4,x

                ldb     #125            ;row14
                abx
                lda     4,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     4,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x
                lda     6,x
                anda    #$0f
                ora     #$20
                sta     6,x

                ldb     #128            ;row15
                abx
                lda     #$00
                sta     ,x
                sta     10,x

                ldb     #128            ;row16
                abx
                ldb     ,x
                andb    #$0f
                orb     #$00
                std     ,x
                sta     10,x
                lda     9,x
                anda    #$f0
                sta     9,x

                ldb     #128            ;row17
                abx
                ldd     #$0000
                std     ,x
                stb     9,x
                stb     10,x
                lda     8,x
                anda    #$f0
                sta     8,x
                lda     2,x
                anda    #$0f
                sta     2,x

                ldb     #128            ;row18
                abx
                ldd     #$0000
                std     ,x
                std     8,x
                stb     2,x
                stb     10,x
                lda     7,x
                anda    #$f0
                sta     7,x
                lda     3,x
                anda    #$0f
                sta     3,x

                ldb     #128            ;row19
                abx
                ldd     #$0000
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                stb     10,x


                rts

bbidle.02
                ldd     #$0000
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                stb     10,x

                ldb     #128            ;row01
                abx
                ldb     #$00
                std     ,x
                std     8,x
                stb     2,x
                stb     10,x

                ldb     #128            ;row02
                abx
                ldb     #$00
                std     ,x
                stb     9,x
                stb     10,x
                lda     8,x
                anda    #$f0
                sta     8,x
                lda     2,x
                anda    #$0f
                sta     2,x

                ldb     #128            ;row03
                abx
                ldd     #$0000
                std     ,x
                stb     9,x
                stb     10,x

                ldb     #128            ;row04
                abx
                ldb     ,x
                andb    #$0f
                orb     #$00
                std     ,x
                sta     10,x
                lda     9,x
                anda    #$f0
                sta     9,x

                ldb     #128            ;row05
                abx
                ldb     ,x
                andb    #$0f
                orb     #$00
                lda     #$00
                std     ,x
                sta     10,x
                ldd     #$2222
                std     4,x
                stb     6,x
                lda     9,x
                anda    #$f0
                sta     9,x

                ldb     #128            ;row06
                abx
                lda     3,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     3,x
                stb     5,x
                stb     6,x
                lda     #$00
                sta     ,x
                lda     7,x
                anda    #$0f
                ora     #$20
                sta     7,x
                lda     #$00
                sta     10,x

                ldb     #128            ;row07
                abx
                lda     3,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     3,x
                stb     5,x
                stb     6,x
                lda     #$00
                sta     ,x
                lda     7,x
                anda    #$0f
                ora     #$20
                sta     7,x
                lda     #$00
                sta     10,x

                ldb     #128            ;row08
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     #$00
                sta     ,x
                sta     10,x

                ldb     #128            ;row09
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     #$00
                sta     ,x
                sta     10,x

                ldb     #128            ;row10
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     #$00
                sta     ,x
                sta     10,x

                ldb     #128            ;row11
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     #$00
                sta     ,x
                sta     10,x

                ldb     #128            ;row12
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     #$00
                sta     ,x
                sta     10,x

                ldb     #128            ;row13
                abx
                lda     3,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     3,x
                stb     5,x
                stb     6,x
                lda     #$00
                sta     ,x
                lda     7,x
                anda    #$0f
                ora     #$20
                sta     7,x
                lda     #$00
                sta     10,x

                ldb     #128            ;row14
                abx
                lda     4,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     4,x
                lda     #$00
                sta     ,x
                lda     6,x
                anda    #$0f
                ora     #$20
                sta     6,x
                lda     #$00
                sta     10,x

                ldb     #128            ;row15
                abx
                ldb     ,x
                andb    #$0f
                orb     #$00
                std     ,x
                sta     10,x
                lda     9,x
                anda    #$f0
                sta     9,x
                lda     #$22
                sta     5,x

                ldb     #128            ;row16
                abx
                ldd     #$0000
                std     ,x
                stb     9,x
                stb     10,x

                ldb     #128            ;row17
                abx
                ldb     #$00
                std     ,x
                stb     9,x
                stb     10,x
                lda     8,x
                anda    #$f0
                sta     8,x
                lda     2,x
                anda    #$0f
                sta     2,x

                ldb     #128            ;row18
                abx
                ldd     #$0000
                std     ,x
                std     8,x
                stb     2,x
                stb     10,x
                lda     7,x
                anda    #$f0
                sta     7,x
                lda     3,x
                anda    #$0f
                sta     3,x

                ldb     #128            ;row19
                abx
                ldd     #$0000
                std     ,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                stb     10,x


                rts

bbidle.03
                ldd     #$0000
                std     ,x
                std     8,x
                stb     2,x
                stb     10,x
                lda     7,x
                anda    #$f0
                sta     7,x
                lda     3,x
                anda    #$0f
                sta     3,x

                ldb     #128            ;row01
                abx
                ldd     #$0000
                std     ,x
                stb     9,x
                stb     10,x
                lda     8,x
                anda    #$f0
                sta     8,x
                lda     2,x
                anda    #$0f
                sta     2,x

                ldb     #128            ;row02
                abx
                ldd     #$0000
                std     ,x
                stb     9,x
                stb     10,x

                ldb     #128            ;row03
                abx
                ldb     ,x
                andb    #$0f
                orb     #$00
                std     ,x
                sta     10,x
                lda     9,x
                anda    #$f0
                sta     9,x

                ldb     #128            ;row04
                abx
                ldb     ,x
                andb    #$0f
                orb     #$00
                lda     #$00
                std     ,x
                sta     10,x
                lda     4,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     4,x
                lda     9,x
                anda    #$f0
                sta     9,x
                lda     6,x
                anda    #$0f
                ora     #$20
                sta     6,x

                ldb     #128            ;row05
                abx
                lda     3,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     3,x
                stb     5,x
                stb     6,x
                lda     #$00
                sta     ,x
                lda     7,x
                anda    #$0f
                ora     #$20
                sta     7,x
                lda     #$00
                sta     10,x

                ldb     #128            ;row06
                abx
                lda     3,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     3,x
                stb     5,x
                stb     6,x
                lda     #$00
                sta     ,x
                lda     7,x
                anda    #$0f
                ora     #$20
                sta     7,x
                lda     #$00
                sta     10,x

                ldb     #128            ;row07
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x

                ldb     #128            ;row08
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x

                ldb     #128            ;row09
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x
                lda     2,x
                anda    #$f0
                ora     #$02
                sta     2,x
                lda     8,x
                anda    #$0f
                ora     #$20
                sta     8,x

                ldb     #128            ;row10
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x
                lda     2,x
                anda    #$f0
                ora     #$02
                sta     2,x
                lda     8,x
                anda    #$0f
                ora     #$20
                sta     8,x

                ldb     #128            ;row11
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x
                lda     2,x
                anda    #$f0
                ora     #$02
                sta     2,x
                lda     8,x
                anda    #$0f
                ora     #$20
                sta     8,x

                ldb     #128            ;row12
                abx
                ldd     #$2222
                std     3,x
                std     5,x
                stb     7,x
                lda     10,x
                anda    #$f0
                sta     10,x
                lda     ,x
                anda    #$0f
                sta     ,x

                ldb     #128            ;row13
                abx
                lda     3,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     3,x
                stb     5,x
                stb     6,x
                lda     #$00
                sta     ,x
                lda     7,x
                anda    #$0f
                ora     #$20
                sta     7,x
                lda     #$00
                sta     10,x

                ldb     #128            ;row14
                abx
                lda     3,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     3,x
                stb     5,x
                stb     6,x
                lda     #$00
                sta     ,x
                lda     7,x
                anda    #$0f
                ora     #$20
                sta     7,x
                lda     #$00
                sta     10,x

                ldb     #128            ;row15
                abx
                ldb     ,x
                andb    #$0f
                orb     #$00
                std     ,x
                sta     10,x
                ldd     #$2222
                std     4,x
                stb     6,x
                lda     9,x
                anda    #$f0
                sta     9,x

                ldb     #128            ;row16
                abx
                ldd     #$0000
                std     ,x
                stb     9,x
                stb     10,x
                lda     4,x
                anda    #$f0
                ora     #$02
                ldb     #$22
                std     4,x
                lda     6,x
                anda    #$0f
                ora     #$20
                sta     6,x

                ldb     #128            ;row17
                abx
                ldd     #$0000
                std     ,x
                stb     9,x
                stb     10,x

                ldb     #128            ;row18
                abx
                ldb     #$00
                std     ,x
                stb     9,x
                stb     10,x
                lda     8,x
                anda    #$f0
                sta     8,x
                lda     2,x
                anda    #$0f
                sta     2,x

                ldb     #128            ;row19
                abx
                ldd     #$0000
                std     ,x
                std     8,x
                stb     2,x
                stb     10,x


                rts


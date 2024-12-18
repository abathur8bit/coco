initgfx		import
;page0		import
;page1		import
;show0		import
;show1		import
palettergb	import
wvs		import
c2x		import
clearscreen	import
infinite	import
show0		import
show1		import
set0		import
set1		import

clsc            macro
                ldd	#$\1\1\1\1
                jsr     clearscreen
                endm
*setpage0	macro
*		lda	#0
*		sta	$ff91
*		endm
*setpage1	macro
*		lda	#1
*		sta	$ff91
*		endm
*showpage0	macro
*		ldd     #$60000/8	; $60000/8 = $C000
*                std     $ff9d		; points video memory to $60000
*		endm
*showpage1	macro
*		ldd     #$66000/8	; $60000/8 = $C000
*                std     $ff9d		; points video memory to $60000
*		endm
border		macro
		lda	\1
		sta	$ff9a
		endm
setpal		macro
		ldu	\1
		jsr	palettergb
		endm

VID_START       equ     $6000
VID_END         equ     VID_START+VID_SIZE
VID_SIZE        equ     $6000


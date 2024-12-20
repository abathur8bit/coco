pmode1  	import
pcls		import
setpage		import			* set page in reg A
showpage 	import			* show page in reg A
page		import
c2x		import
draw_corners	import

WIDTH		equ	32		* width in bytes
HEIGHT		equ	96		* number of lines
PGSIZE		equ	WIDTH*HEIGHT
PAGE0		equ	$400		* start address of page 0
PAGE1		equ	$1000		* start address of page 1

set0		macro
		lda	#0
		jsr	setpage
		endm
set1		macro
		lda	#1
		jsr	setpage
		endm
show0		macro
		lda	#0
		jsr	showpage
		endm
show1		macro
		lda	#1
		jsr	showpage
		endm

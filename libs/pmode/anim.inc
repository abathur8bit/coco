draw_anim_list	import 
add_anim	import
setup_anim	import
draw_anim	import
animfr		import
move_anim	import

ANIM_SIZE	equ	$00
ANIM_POSXY	equ	$02
ANIM_DIRXY	equ	$04
ANIM_TIMER	equ	$06     ; 32-bit timer high word
ANIM_TIMER_MSW	equ	$06     ; just a ref to ANIM_TIMER
ANIM_TIMER_LSW  equ     $08     ; 32-bit timer low word
ANIM_DELAY	equ	$0b     ; we skip the high part of word
ANIM_FRAME	equ	$0c
ANIM_FRCNT	equ	$0e
ANIM_DATA	equ	$10

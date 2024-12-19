draw_anim_list	import 
add_anim	import
setup_anim	import
draw_anim	import
animfr		import
move_anim	import

ANIM_MAX	equ	20      ; max animated objects at one time

ANIM_SIZE	equ	$00
ANIM_POSXY	equ	$02
ANIM_DIRXY	equ	$04
ANIM_TIMERAU	equ	$06     ; 32-bit animation timer high word
ANIM_TIMERAL    equ     $08     ; 32-bit animation timer low word
ANIM_TIMERMU	equ	$0a     ; 32-bit movement timer high word
ANIM_TIMERML    equ	$0c     ; 32-bit movement timer low word
ANIM_DELAYA	equ	$0e     ; 8-bit animation timer delay
ANIM_DELAYM	equ	$0f     ; 8-bit movement timer delay
ANIM_FN 	equ	$10     ; frame number to display
ANIM_FC 	equ	$11     ; frame count, how many frames animation has
ANIM_DATA	equ	$12     ; one or more frame sprite data pointers

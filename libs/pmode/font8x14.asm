;************************************************
; 8x14 font routine for outputting a padded score
; and letters.
; Note, font is 8 pixels, or 2 bytes wide and
; 14 pixels high
; You can fit 16 chars across and 6 down
;***

                include "pmode1.inc"
                include "blit1.inc"


;************************************************
font_line	macro
		ldd	,y++
		std	,x++
                ldb	#32-FONT_WIDTH
                abx
                endm


;************************************************
FONT_WIDTH	equ	2	; byte, not coordinate
FONT_HEIGHT	equ	14


;************************************************
bn2dec		import		; found in liblee
show_score	export
blitstr		export


;************************************************
		section code

;*************************************************
; BLITSTR - Show the string in video mode
; Buffer is null terminated. ie: "HELLO\0"
;
; IN:	Stack: (top is higher addr)
;	Lower byte of ascii buffer 5,s
;	Upper byte of ascii buffer 4,s
;	Y coordinate of where to blit score 3,s
;	X coordinate of where to blit score 2,s (in bytes)
; OUT: 	none
; MOD: 	D,X,Y
;
; Example:
;	ldx	#msg
;	ldd	#$000f			; x&y byte pos
;	pshs	x,d
;	jsr	blitstr
;	leas	4,s			; pull coords and msg ptr off stack
;
; Or using a macro
;
; blitstring    macro
;               ldx     \1
;               ldd     \2
;               pshs    x,d
;               jsr     blitstr
;               leas    4,s             ; pop data
;               endm
;
;               blitstring #msg_fps,#$1a00
;
;               ldd     fps_curr        ; last calced fps
;               ldx     #buffer         ; buffer for ascii
;               jsr     bn2dec          ; convert D to ascii, result in buffer
;               blitstring #buffer+1,#$1a0f
;
; msg           fcn     /HELLO WORLD/   ; fcn will null terminate the string
; buffer        zmb     10              ; zmb initializes 10 bytes to 0
;***
blitstr		ldd	2,s		; grab coords from stack
		std	score_pos	; store in temp
		ldd	4,s		; load score from stack
		std	bufptr
		bra	char_loop


;*************************************************
; Blit the score to the screen, padded to 4 chars.
; ie: score=5 output=0005
; ie: score=1234 output=1234
;
; IN:	Stack: (top is higher addr)
;	Lower byte of score 5,s
;	Upper byte of score 4,s
;	Y coordinate of where to blit score 3,s
;	X coordinate of where to blit score 2,s (in bytes)
; OUT: 	none
; MOD: 	D,X,Y
;***
show_score
		ldd	2,s		; grab coords from stack
		std	score_pos	; store in temp
		ldd	4,s		; load score from stack
		ldx	#buffer
		jsr	bn2dec		; buffer contains score in ascii
		jsr 	pad		; pad with zeros if needed
		ldd	#buffer+1	; start of buffer index
		std	bufptr
		bra	char_loop

;*************************************************
; Blits each character in the buffer to the screen.
; IN:	bufptr points to the ascii buffer that is
;	null terminated.
; MOD:	D,X,Y
;***
char_loop	ldy	bufptr 		; points to ascii buffer
		ldb	,y		; b contains ascii of score digit
		beq	done@		; if null (0) loaded, we are at end of score string
		subb	#32		; b is number for offset
		aslb			; convert to word offset
		ldx	#characters	; start of font ptr array
		ldy	b,x		; y points to correct font data
		ldd	score_pos	; current x,y coords
		jsr	c2x		; calculate video address from D into X
		jsr	dofont		; blit font
		ldd	score_pos	; current x,y coords
		adda	#FONT_WIDTH	; inc x pos
		std	score_pos	; store new pos
		ldd	bufptr		; point to next digit in score string
		addd	#1
		std	bufptr
		jmp	char_loop	; show next character
done@		rts

;************************************************
; IN : 	X = video address to blit to
; 	Y = points to sprite data
; MOD:	X,Y,D
;***
dofont
		font_line
		font_line
		font_line
		font_line
		font_line
		font_line
		font_line
		font_line
		font_line
		font_line
		font_line
		font_line
		font_line
		font_line
		rts

;************************************************
; Pad the score string. Remember that the first
; byte of the buffer contains the length of the
; string. Padding doesn't have a length.
;***
pad		ldd	6,s		* score (stack moved because of jsr)
		cmpd	#999		* can we skip padding?
		bhi	padx		* if > 999 we can
		ldd	#$3030		*"00"
		std	padding
		std	padding+2
		ldd	6,s		* score (stack moved because of jsr)
		cmpd	#9
		bhi	pad0
		lda	buffer+1	* 1 digit
		sta	padding+3	* padded with 3 zeros
		bra	padd
pad0		cmpd	#99
		bhi	pad1
		ldd	buffer+1	* 2 digits
		std	padding+2	* padded 2 zeros
		bra	padd
pad1		ldd	buffer+1	* pad 1 zero
		std	padding+1
		lda	buffer+3
		std	padding+3
padd		ldd	padding		* put padded value into string buffer
		std	buffer+1
		ldd	padding+2
		std	buffer+3
		lda	#0		* null terminate the string
		sta	buffer+5
		lda	#4		* set the string length
		sta	buffer
padx		rts



;************************************************
buffer		rmb	8
padding		rmb	8
bufptr		fdb	$0000


;************************************************
score_pos	fdb	$0000
characters	fdb	font8x14.1,font8x14.2,font8x14.0,font8x14.0,font8x14.0,font8x14.0,font8x14.0,font8x14.0,font8x14.0,font8x14.0,font8x14.0,font8x14.0,font8x14.0,font8x14.15,font8x14.16,font8x14.17
numbers		fdb	font8x14.18,font8x14.19,font8x14.20,font8x14.21,font8x14.22,font8x14.23,font8x14.24,font8x14.25,font8x14.26,font8x14.27
chars1		fdb	font8x14.0,font8x14.0,font8x14.0,font8x14.0,font8x14.0,font8x14.0,font8x14.0
letters		fdb	font8x14.34,font8x14.35,font8x14.36,font8x14.37,font8x14.38,font8x14.39,font8x14.40,font8x14.41,font8x14.42,font8x14.43,font8x14.44,font8x14.45,font8x14.46,font8x14.47,font8x14.48,font8x14.49,font8x14.50,font8x14.51,font8x14.52,font8x14.53,font8x14.54,font8x14.55,font8x14.56,font8x14.57,font8x14.58,font8x14.59
;************************************************

		include "font8x14.inc"

		endsection


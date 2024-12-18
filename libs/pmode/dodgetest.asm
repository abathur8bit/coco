;************************************************
; Test scrolling box from right to left to see
; if things will be playable.

                include "pmode1.inc"
                include "timer.inc"
                include "anim.inc"
                include "blit1.inc"

start           export
blitstr         import
bn2dec          import
rnd             import
inkey           import

ANIM_SPEED      equ     1
BOX_DELAY       equ     15              ; TODO want to tune so we can get about 4 boxes on the screen at once
;PLAYER_DELAY    equ     0

BOX_IMG         equ     0
BOX_POSX        equ     2
BOX_POSY        equ     3
BOX_DIRX        equ     4
BOX_DIRY        equ     5

BOX_MAX         equ     10              ; max number of active boxes
BOX_STARTX      equ     $20             ; 32 just off screen
BOX_ENDX        equ     $fa             ; -6

PLAYER_TOP      equ     $20
PLAYER_BOTTOM   equ     $50
PLAYER_SPEED_UP equ     $f8
PLAYER_SPEED_DN equ     8

;************************************************

                section main

start
                ;sta     $ffd9           ; coco3 speed-up
                jsr     setup_timer_irq
                jsr     pmode1
                jsr     pcls
                set1
                jsr     pcls

                jsr     box_add         ; get first box going
                jsr     player_init
draw
                jsr     pcls
                jsr     draw_corners
                jsr     box_showall
                jsr     process_player
                jsr     show_rnd        ; show what rnd number came up

                jsr     pageflip
                jsr     box_moveall
                jsr     box_add_logic   ; should we add more boxes
                jsr     wait
                jmp     draw


;************************************************
; Show the player, read the keyboard and
; update his location
process_player
                jsr     player_draw
                jsr     process_input
                jsr     player_update
                rts

; draw the player sprite
player_draw
                ldx     #playerxy
                ldd     ,x
                ldu     #dodgeball     ; point to box info
                ldx     ,u++            ; w,h and U points to image data
                pshs    u,x,d           ; data,wh,xy
                jsr     blitclipped
                leas    6,s             ; pop data
                rts

; move player if they need moving, stop movement when they
; reach destination
player_update   lda     jump_pressed
                beq     player_move             ; jump not pressed
                lda     playerxy+1              ; load posy
                cmpa    player_destxy+1         ; is player at destination?
                bne     player_move             ; no, so skip jump logic. Player must be stopped vertically.
                ldd     #$00fc                  ; -4
                std     player_dirxy            ; set new direction
                lda     #PLAYER_TOP             ; set new destination
                sta     player_destxy

player_move     lda     playerxy                ; load posx
                cmpa    player_destxy           ; at destination?
                beq     checky@                 ; yes
                adda    player_dirxy            ; no, move player x
                sta     playerxy                ; store
checky@         lda     playerxy+1              ; load posy
                cmpa    player_destxy+1         ; at destination?
                beq     done@                   ; yes
                adda    player_dirxy+1          ; no, move player y
                sta     playerxy+1              ; store
done@           rts

process_input
                jsr     inkey
                cmpa    #9
                bne     not9@
                sta     jump_pressed
                lda     #PLAYER_TOP
                sta     player_destxy+1
                lda     #PLAYER_SPEED_UP
                sta     player_dirxy+1
                rts
not9@           cmpa    #8
                bne     key_done@
                sta     jump_pressed
                lda     #PLAYER_BOTTOM
                sta     player_destxy+1
                lda     #PLAYER_SPEED_DN
                sta     player_dirxy+1
                rts
key_done@       clr     jump_pressed
                rts

;***
; Set player initial values
player_init
                rts

;************************************************
; Check if we need to add another box
box_add_logic
                inc     counter
                lda     counter
                cmpa    #BOX_DELAY
                bne     done@
                clra
                sta     counter
                jsr     box_add
done@           rts

;************************************************
box_add
                jsr     find_empty
                ldx     #box_list       ; point to box list
                ldb     index           ; byte index
                aslb                    ; to word index
                abx                     ; X now points to correct offset
                jsr     box_loc_rnd     ; get location
                tfr     a,b             ; returned in A, put into B
                lda     #BOX_STARTX
                std     ,x
                rts

*************************************************
; Find an empty slot, store slot in INDEX
; If no empty slots C flag is set, cleared otherwise.
; MOD:  X,D
find_empty
	        clra
	        sta	index
loop@	        lda	index		; load slot are we looking at
	        cmpa	#BOX_MAX	; and end of list?
	        beq	none@		; branch if so
	        asla			; to word index
	        ldx	#box_list	; start of the list
	        ldd	a,x		; grab the box posxy
	        cmpb    #0              ; check if box is active
	        beq	done@           ; we found an empty slot
	        inc	index
	        bra	loop@
done@	        clra
                rts
none@           coma
                rts

;************************************************
box_showall
	        clra
	        sta	index
loop@	        lda	index		; load slot are we looking at
	        cmpa	#BOX_MAX	; and end of list?
	        beq	done@		; branch if so
	        asla			; to word index
	        ldx	#box_list	; start of the list
	        ldd	a,x		; grab the box posxy
	        cmpb    #0              ; check if box is active
	        beq	zero@		; skip if zero
	        jsr	box_draw
zero@	        inc	index
	        bra	loop@
done@	        rts


;************************************************
; Draw single box
; IN:   D - Points to the box x,y pos
; MOD:  U,X
box_draw
                ldu     #dodgeblock     ; point to box info
                ldx     ,u++            ; w,h and U points to image data
                pshs    u,x,d           ; data,wh,xy
                jsr     blitclipped
                leas    6,s             ; pop data
                rts

;************************************************
; Moves boxes left, and if it reaches the box_endx,
; disables that box list slot.
box_moveall
	        clra
	        sta	index           ; reset loop
loop@	        ldb	index		; load slot are we looking at
	        cmpb	#BOX_MAX	; and end of list?
	        beq	done@		; branch if so
	        aslb			; to word index
	        ldx	#box_list	; start of the list
	        abx                     ; point X to correct location
	        ldd	,x		; grab the box posxy
	        cmpb    #0              ; posy == 0 means not active
	        beq	zero@		; skip if zero
	        suba    #1              ; move left
	        cmpa    #BOX_ENDX       ; reach end?
	        bne     notatend@
	        clrb                    ; disable box
notatend@	std     ,x              ; store back
zero@	        inc	index
	        bra	loop@
done@	        rts

;************************************************
; OUT:  A - random posy
; MOD:  D
box_loc_rnd     lda     #$FF            ; choose new location
                jsr     rnd
                sta     rnd_val         ; remember it so we can display it
                cmpa    #$aa            ; AA-FF bottom (170)
                bhi     third@
                cmpa    #$55            ; 55-AA middle  (85)
                bhi     second@
first@          lda     #32             ; 00-55 top
                bra     done@
second@         lda     #54
                bra     done@
third@          lda     #75
done@           rts

;************************************************
show_rnd        clra
                ldb     rnd_val
                ldx     #buffer
                jsr     bn2dec          ; convert to string
                ldx     #buffer+1       ; string (less # bytes)
                ldd     #$0000          ; x,y pos
                pshs    x,d
                jsr     blitstr
                leas    4,s             ; pop data

                ; show timer
                jsr     timer_val       ; timer to D
                ldx     #buffer
                jsr     bn2dec
                ldx     #buffer+1       ; string (less # bytes)
                ldd     #$3100          ; x,y pos
                pshs    x,d
                jsr     blitstr
                leas    4,s
                rts

;************************************************
; Copies page1 to page0
pageflip
                ldd	page
                cmpd	#PAGE0
                bne	page1@
                ; we are on page0 and showing 1, show page0, set page1
                show0
                set1
                bra     done@
page1@          ; we are on page1 and showing 0, show page1, set page0
                show1
                set0
done@           rts



;pageflip        ldx     #PAGE1
;                ldu     #PAGE0
;l@              ldd     ,x++
;                std     ,u++
;                cmpx    #PAGE1+PGSIZE
;                bne     l@
;                rts
;
;************************************************

wait		jsr     timer_val       ; timer to D
		cmpd	#ANIM_SPEED
		ble	wait
		ldd	#0
		jsr	set_timer_val
		rts

;************************************************
; Wait for VSyncs (FPS timing)
; MOD:	A,B
;***
wvs
                ldb     #6

vs              lda     $ff03
                bpl     vs
                lda     $ff02
                decb
                bne     vs
                rts

;************************************************

buffer		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
rnd_val         fcb     0
index           fcb     0
temp            fcb     0
posxy           fdb     0
counter         fcb     0
playerxy        fdb     $0020
player_dirxy    fdb     $0004
player_destxy   fdb     $0050
;player_timer    fcb     0
jump_pressed    fcb     0

box             fdb     dodgeblock,$2510  ; image (w,y,data),posxy
; List of box posxy. If the Y is zero (0) then the box is not active
box_list        zmd     10              ; list of x,y coords

;************************************************

                include "dodgeblock.inc"
                include "dodgeball.inc"

;************************************************
                endsection
;************************************************
; Test scrolling box from right to left to see
; if things will be playable.

                ;include "lee.inc"
                include "pmode1.inc"
                include "timer.inc"
                include "anim.inc"
                include "blit1.inc"
                include "math.inc"
                include "font.inc"

start           export
bn2dec          import
rnd             import
inkey           import

ANIM_SPEED      equ     1
BOX_DELAY       equ     15              ; TODO want to tune so we can get about 4 boxes on the screen at once

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
                jsr     show_timer      ; show what rnd number came up
                jsr     show_fps        ; fps last, so it's on top

                jsr     pageflip
                jsr     box_moveall
                jsr     box_add_logic   ; should we add more boxes
                ;jsr     wait

                inc     fps_counter+1
                bne     >
                inc     fps_counter
!
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
; Show the current FPS
show_fps        blitstring #msg_fps,#$1a00
                ldd     fps_curr        ; last calced fps
                ldx     #buffer         ; buffer for ascii
                jsr     bn2dec          ; convert D to ascii, result in buffer
                blitstring #buffer+1,#$1a0f

                ; check if a second has gone by
                ldx     #fps_timer_now
                jsr     timer_val       ; get current timer into fps_timer_now
                cmp32   fps_timer_now,fps_timer_delta
                bge     timer_elapsed   ; branch if now > delta
                rts

timer_elapsed   ldd     fps_counter
                std     fps_curr
                ldd     #0
                std     fps_counter
                std     $7800           ; TODO mame debug

                ; calculate next delta
                copy32  fps_timer_delta,fps_timer_now   ; copy now to delta
                ldx     #fps_timer_delta
                lda     #60             ; 60 ticks at 60Hz is one second
                jsr     add832          ; fps_timer_delta += 60
show_fps_done   rts

;************************************************
show_timer      blitstring #msg_timer,#$0000
                ldx     #fps_timer_now
                jsr     timer_val       ; get current timer into fps_timer_now
                ldd     fps_timer_now+2 ; just grab the last 2 bytes and use that value
                ldx     #buffer
                jsr     bn2dec          ; convert to ascii
                blitstring #buffer+1,#$000f
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



pageflip1        ldx     #PAGE1
                ldu     #PAGE0
l@              ldd     ,x++
                std     ,u++
                cmpx    #PAGE1+PGSIZE
                bne     l@
                rts

;************************************************

;wait		jsr     timer_val       ; timer to D
;		cmpd	#ANIM_SPEED
;		ble	wait
;		ldd	#0
;		jsr	set_timer_val
;		rts

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
jump_pressed    fcb     0
player_score    fcb     0
fps_counter     fdb     0               ; 16-bit how many times through our main loop
fps_curr        fdb     0               ; 16-bit current frames per second we are running at
fps_timer_delta fcb     0,0,0,0         ; 32-bit What we are waiting for time to be
fps_timer_now   fcb     0,0,0,0         ; 32-bit What the timer currently is

box             fdb     dodgeblock,$2510  ; image (w,y,data),posxy
; List of box posxy. If the Y is zero (0) then the box is not active
box_list        zmd     10              ; list of x,y coords

msg_fps         fcn     /FPS/
msg_timer       fcn     /TIMER/

;************************************************

                include "dodgeblock.inc"
                include "dodgeball.inc"

;************************************************
                endsection
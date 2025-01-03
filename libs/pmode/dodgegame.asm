;************************************************
; Test scrolling box from right to left to see
; if things will be playable.

                include "lee.inc"
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

WAIT_DELAY      equ     2
BOX_DELAY       equ     15              ; TODO want to tune so we can get about 4 boxes on the screen at once

BOX_IMG         equ     0
BOX_POSX        equ     2
BOX_POSY        equ     3
BOX_DIRX        equ     4
BOX_DIRY        equ     5

BOX_MAX         equ     10              ; max number of active boxes
BOX_STARTX      equ     $20             ; 32 just off screen
BOX_ENDX        equ     $fa             ; -6

BOX_YTOP        equ     32
BOX_YMID        equ     54
BOX_YBTM        equ     75

PLAYER_TOP      equ     $20
PLAYER_BOTTOM   equ     $54
PLAYER_SPEED_UP equ     $f8
PLAYER_SPEED_DN equ     8

MODE_ATTRACT    equ     0               ; game has not started yet
MODE_PLAYING    equ     1               ; game is underway
MODE_STARTING   equ     2               ; game is about to start
MODE_DEAD       equ     3               ; when player hits a block

;************************************************

                section main

start
                lds     #$3f00
                sta     $ffd9           ; coco3 speed-up
                jsr     setup_timer_irq
                jsr     pmode1
                jsr     pcls
                set1
                jsr     pcls

                jsr     box_add         ; get first box going
                jsr     player_init

;main loop
main_loop
                lda     game_mode
                cmpa    #MODE_ATTRACT
                beq     attract

                cmpa    #MODE_PLAYING
                lbeq     playing

                cmpa    #MODE_STARTING
                beq     starting

                jmp     main_loop


;************************************************
attract
                jsr     inkey
                cmpa    #32                             ; space bar
                bne     show_attract                    ; continue showing attract mode if no space bar pressed
                lda     #MODE_STARTING
                sta     game_mode
                jmp     main_loop

show_attract
                jsr     pcls
                blitstring #msg_start,#$01*$100+BOX_YMID+2

                jsr     show_scores
                jsr     box_showall

                jsr     pageflip
                jsr     box_moveall             ; move boxes left
                jsr     box_add_logic           ; should we add more boxes
                jsr     wait                    ; twiddle thumbs, this should be gone, and everything run off timer

                inc     fps_counter+1
                bne     >
                inc     fps_counter
!
                jmp     main_loop

;************************************************
starting        jsr     count_active_boxes
                beq     starting_done
                ; let boxes continue scrolling off the screen
                jsr     pcls
                jsr     show_scores
                jsr     box_showall

                jsr     pageflip
                jsr     box_moveall             ; move boxes left
                jsr     wait                    ; TODO wait should be handled in the main loop, as we might switch to vsync
                jmp     main_loop

starting_done   lda     #MODE_PLAYING
                sta     game_mode
                ; wait a short time
                ldx     #time_now			; point to our temp
                jsr     timer_val			; put current time into time_now
                lda     #30
                jsr     add832
                copy32  time_wait,time_now
waitloop@       jsr     timer_val
                cmp32   time_now,time_wait		; 32-bit compare
                blo     waitloop@       	        ; branch if now<wait
                jmp     main_loop

;************************************************
; count_active_boxes - Counts boxes that have a
;       y coord > 0 which means it is active.
; OUT:  A - Contains the number of active boxes
;***
count_active_boxes
                clra
                sta     index
                sta     temp
loop@           ldb     index
	        cmpb	#BOX_MAX	; and end of list?
	        beq	done@		; branch if so
	        aslb			; to word index
	        ldx	#box_list	; start of the list
	        abx                     ; point X to correct location
	        ldd	,x		; grab the box posxy
	        cmpb    #0              ; posy == 0 means not active
	        beq	zero@		; skip if zero
	        inc     temp            ; active box
zero@	        inc	index
	        bra	loop@
done@	        lda     temp
                rts

;************************************************
playing
                jsr     check_collision
                jsr     pcls
                jsr     show_scores
                jsr     process_player
                jsr     box_showall
                ;jsr     show_timer
                ;jsr     show_fps        ; fps last, so it is drawn on top of everything else

                jsr     pageflip
                jsr     check_collision
                ;bcs                    ; todo do something about player hitting block
                jsr     box_moveall     ; move boxes left
                jsr     box_add_logic   ; should we add more boxes
                jsr     wait            ; twiddle thumbs, this should be gone, and everything run off timer

                inc     fps_counter+1
                bne     >
                inc     fps_counter
!
                jmp     main_loop

;************************************************
; check if any box is colliding with player
px0             fcb     0               ; player posx
py0             fcb     0               ; player posy
px1             fcb     0               ; player posx+w
py1             fcb     0               ; player posy+h
bx0             fcb     0               ; box posx
by0             fcb     0               ; box posy
bx1             fcb     0               ; box posx+w
by1             fcb     0               ; box posy+h
collided        fcb     0
check_collision
                clra                    ; todo debug showing a pixel to show the collided state
                sta     collided        ; todo debug showing a pixel to show the collided state

                ldd     playerxy
                std     px0
                std     px1
                ldx     #dodgeball      ; point to player info
                ldd     ,x              ; w,h
                adda    px1
                sta     px1
                addb    py1
                stb     py1

; run through all boxes
                clra
                sta     index
loop@           lda     index           ; load slot are we looking at
                cmpa    #BOX_MAX        ; at end of list?
                beq     done@
                asla                    ; to word index
                ldx     #box_list       ; start of the list
                ldd     a,x             ; grab box posxy
                cmpb    #0              ; check if box is active
                beq     zero@           ; skip if zero
                jsr     check_box
                bcc     zero@           ; not colliding if carry clear
                ; collision detected
                lda     #%01010101
                sta     collided
                bra     done@
zero@           inc     index
                bra     loop@
done@
                lda     collided
                sta     $400
                rts

; Check each corner of the player to see if it is contained in the box
; set carry flag if it is. Width is in dodgeblock sprite info
; IN:   D - box x,y
; OUT:  Carry flag set if player collides, cleared otherwise.
check_box
                ; load temp vars with corner coordinates
                std     bx0             ; x,y
                std     bx1             ; x,y plus w,h
                ldx     #dodgeblock     ; point to box info
                ldd     ,x              ; w,h
                adda    bx1
                sta     bx1
                addb    by1
                stb     by1

                lda     px1             ; check top right
                ldb     py0
                jsr     check_corner
                bcs     check_hit

                lda     px1             ; check bottom right
                ldb     py1
                jsr     check_corner
                bcs     check_hit

                lda     px0             ; check top left
                ldb     py0
                jsr     check_corner
                bcs     check_hit

                lda     px1             ; check bottom left
                ldb     py1
                jsr     check_corner
                bcs     check_hit

                ; getting here means box isn't colliding
                clc
                rts

check_hit       sec                     ; set carry, we hit
                rts



; IN:   D player x,y corner to check. bx0,by0,bx1,by1 should all be set
; OUT:  Carry set if hit, cleared otherwise.
check_corner    cmpa    bx0             ; px>=bx0?
                bge     yes1@
                bra     nothit@
yes1@           cmpa    bx1             ; px<=bx1?
                ble     yes2@
                bra     nothit@
yes2@           cmpb    by0             ; py>=by0?
                bge     yes3@
                bra     nothit@
yes3@           cmpb    by1             ; py<=by1
                ble     yes4@
                bra     nothit@
yes4@           sec                     ; set carry
                rts
nothit@         clc                     ; clear carry
                rts

;************************************************
; Copies page1 to page0
pageflip        ldx     #PAGE1          ; source
                ldu     #PAGE0          ; dest
l@              ldd     ,x++
                std     ,u++
                cmpx    #PAGE1+PGSIZE
                bne     l@
                rts

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
                ; check player hasn't moved too far, and move back if so
                lda     playerxy+1
                cmpa    #PLAYER_TOP
                bge     topokay@
                lda     #PLAYER_TOP
                sta     playerxy+1
topokay@        cmpa    #PLAYER_BOTTOM
                bls     done@
                lda     #PLAYER_BOTTOM
                sta     playerxy+1
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
	        cmpa	#BOX_MAX	; at end of list?
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
first@          lda     #BOX_YTOP       ; 00-55 top
                bra     done@
second@         lda     #BOX_YMID
                bra     done@
third@          lda     #BOX_YBTM
done@           rts

;************************************************
; Show the current FPS and timer
;
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
; Routines for showing the player score and high score
;
show_scores     jsr     show_player_score
                jsr     show_high_score
                rts

show_player_score
                blitstring #msg_1up,#$0000
                ldx	score_player		; score to display
                ldd	#$000f			; x&y in bytes
                pshs	x,d
                jsr	show_score
                leas	4,s			; pull score and coords off stack
                rts

show_high_score
                blitstring #msg_high,#$1800
                ldx	score_high		; score to display
                ldd	#$180f			; x&y in bytes
                pshs	x,d
                jsr	show_score
                leas	4,s			; pull score and coords off stack
                rts

;************************************************
show_timer      blitstring #msg_timer,#$0000
                ldx     #fps_timer_now
                jsr     timer_val               ; get current timer into fps_timer_now
                ldd     fps_timer_now+2         ; just grab the last 2 bytes and use that value
                ldx     #buffer
                jsr     bn2dec                  ; convert to ascii
                blitstring #buffer+1,#$000f
                rts

;************************************************
; If time_now >= time_wait, the timer has elapsed.
; Once elapsed, we reset the wait time to now+delay.
wait            ldx     #time_now			; point to our temp
                jsr     timer_val			; put current time into time_now
                cmp32   time_now,time_wait		; 32-bit compare
                blo     wait				; branch if now<wait
                lda     #WAIT_DELAY			; wait time
                jsr     add832				; add to time_now
                copy32  time_wait,time_now		; time_wait=time_now+delay
done@           rts

;************************************************

buffer		        zmb	21
rnd_val                 fcb     0
index                   fcb     0
temp                    fcb     0
game_mode               fcb     MODE_ATTRACT            ; what mode the game is in
posxy                   fdb     0
counter                 fcb     0
playerxy                fdb     $0020
player_dirxy            fdb     $0004
player_destxy           fdb     $0054
jump_pressed            fcb     0
score_player            fdb     0
score_high              fdb     0
fps_counter             fdb     0               ; 16-bit how many times through our main loop
fps_curr                fdb     0               ; 16-bit current frames per second we are running at
fps_timer_delta         fcb     0,0,0,0         ; 32-bit What we are waiting for time to be
fps_timer_now           fcb     0,0,0,0         ; 32-bit What the timer currently is
; 32-bit timer data
time_now                fcb     0,0,0,0		; Temp to hold current time
time_wait               fcb     0,0,0,0		; holds time_now+WAIT_DELAY

box                     fdb     dodgeblock,$2510 ; image (w,y,data),posxy
; List of box posxy. If the Y is zero (0) then the box is not active
box_list                zmd     10              ; list of x,y coords
;box_list                fcb     $fc,$20,$0a,$36,0,0   ; hex 2,32 10,54 w,h=$18x15
msg_fps                 fcn     /FPS/
msg_timer               fcn     /TIMER/
msg_1up                 fcn     /1UP/
msg_high                fcn     /HIGH/
msg_start               fcn     /SPACE TO START/

;************************************************

                include "dodgeblock.inc"
                include "dodgeball.inc"

;************************************************
                endsection
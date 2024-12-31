;************************************************
; Compile & run: lwasm -o merry.bin merry.asm && vcc merry.bin
; 8 char spaces only pls
;
; Make a change, or an optimization of your choice. Save and post 
; to discord and mention someone else.

                org     $3f00

;************************************************
FIRQ            equ     %01000000
IRQ             equ     %00010000
WAIT_DELAY      equ     6
IRQ_VECTOR      equ     $fef7
ADDR_SCORE      equ     $400
ADDR_START      equ     $400+32         ; skip first line
ADDR_END        equ     ADDR_START+32*14-1
ADDR_PLAYER     equ     ADDR_END+1
POLCAT          equ     $a000
VDGREG          equ     $ff22
DAC             equ     $ff20

;************************************************
start           jsr     setup_timer_irq
                jsr     cls
                jsr     show_msg        ; seed the message
                clr     missile_flag    ; clear the missile flag (a non-zero value means a missile has been fired)

mainloop        jsr     draw
                jsr     draw_score
                jsr     wait
                jsr     keypress        ; go check for input
                bra     mainloop

endless_loop    bra     endless_loop    ; used for debugging

;************************************************
draw_score
                ldx     #ADDR_SCORE     ; plot address
                lda     score           ; get 1st score byte
                lsra			; shift to lower nybble
                lsra                    ; (1st digit)	 
                lsra
                lsra
                ora     #$30            ; apply ascii transform
                sta     ,x              ; store
                lda     score           ; get 2nd digit		
                anda    #$0f            ; mask off upper nybble
                ora     #$30            ; convert to ascii
                sta	1,x             ; store 

                lda     score+1         ; get 2nd score byte
                lsra			; shift to lower nybble
                lsra	
                lsra
                lsra
                ora     #$30            ; apply ascii transform
                sta     2,x             ; store
                lda     score+1         ; get 2nd digit		
                anda    #$0f            ; mask off upper nybble
                ora     #$30            ; convert to ascii
                sta	3,x             ; store 
                rts


;************************************************
draw            ldd     message_pos     ; Increment the message postion so it moves
                addd    #1
                cmpd    #481            ; 480 is the lowest we want to go
                bne     draw_1
                lda     #6              ; (re)set the wait time to 6
                sta     wait+6
                ldd     #$0000          ; if we've hit 481, then reset message postion back to the top
draw_1          std     message_pos     ; Store the updated message position
                jsr     show_msg        ; Show the message, man!
move_loop       ldx     #ADDR_PLAYER
;************************************************
; delete ship at old posit and plot at new posit
;************************************************
                lda     oldposit
                ldb     #$60            ; blank char
                stb     a,x             ; clear ship byte 1
                adda    #2              ; we don't need to clear byte 2 because it will be overwritten when the ship is placed
                stb     a,x             ; clear ship byte 3
                lda     position
                ldb     ship
                stb     a,x             ; put ship byte 1
                ldb     ship+1
                inca
                tst     missile_flag    ; check the missile flag to see if we're shooting
                beq     move_loop_1     ; if the flag is zero, then we're not
                ldb     #$60            ; but if the flag is non-zero, then we are, so replace the middle byte of the ship with a blank
move_loop_1     stb     a,x             ; put ship byte 2
                ldb     ship+2
                inca
                stb     a,x             ; put ship byte 3

;************************************************
; plot missile if firing and collision check
;*************************************************
                tst     missile_flag    ; is a missile flying?
                beq     draw_exit       ; if flag is clear then no missile is flying, so branch to exit
                ldx     #ADDR_START     ; reload register X with the top of the text screen
                ldd     missile_pos     ; load D with the missile position (0-480)
                leax    d,x             ; adjust
                bpl     move_loop_2     ; is the value still positive?  If so, branch ahead to collision check
                com     missile_flag    ; value is negative, we're passed the top of the screen, so flip the missile flag back to clear
                bra     move_loop_5
; collision check
move_loop_2     lda     ,x              ; check if the missile is over a byte that is not a background value ($60)
                cmpa    #$60
                beq     move_loop_4     ; if it's a background value, that means the missile hasn't hit anything, so skip ahead
                lda     #$60            ; If we're here, then we've hit a letter!  Load accA with a blank to clear the missile
                sta     32,x            ; clear the missile which is one row down


add10           clra			; serves to clear CARRY
                lda     #$10		; Number to add (BCD)
                adca    score+1		; add to lower score byte
                daa                     ; convert to BCD
                sta     score+1         ; store back
                lda     #$00            ; 0 becuse we want to add any carry from prev.
                adca    score           ; add carry from last
                daa                     ; convert to BCD
                sta     score           ; store


done_score      lda     ,x              ; load the letter from the screen
                anda    #%10111111      ; invert it
                sta     ,x              ; write it back
                jsr     wait            ; wait a tick
                lda     #159            ; load an explosion byte (a colored rectangle)
                sta     ,x              ; store it to the screen
                jsr     wait            ; wait a tick
                lda     #$60            ; clear the explosion byte
                sta     ,x
                com     missile_flag    ; flip the missile flag
                ldd     missile_pos     ; Load missile position
                subd    message_pos     ; subtract the message position to get the letter location (b now contains the offset value)
                lda     #$60            ; load a background byte into accumulator a
                ldy     #msg
                sta     b,y             ; replace that letter with a background character
                                        ; ***  needs some code to check if the entire message has been basted away! ***
                lda     wait+6          ; let's go a little faster now
                cmpa    #2              ; but not too fast
                beq     draw_exit
                deca
                sta     wait+6          ; store the decremented wait value
                bra     draw_exit       ; and exit
; plot missile
move_loop_4     ldb     missile         ; load b with the missile byte `!`
                stb     ,x              ; and write it to the screen
move_loop_5     leax    32,x            ; clear the byte one row below the missile
                ldb     #$60
                stb     ,x
                ldd     missile_pos     ; move the missile position up one row for the next frame
                subd    #32
                std     missile_pos
draw_exit       rts

;************************************************
; check for input (left/right arrows/space)
;************************************************
keypress        jsr     [POLCAT]
                cmpa    #9              ; right arrow
                beq     right
                cmpa    #8              ; left arrow
                beq     left
                cmpa    #32             ; space
                bne     keydone
                tst     missile_flag    ; is there already a missile flying?
                bne     keypress_1      ; if missile flag is not clear, then a missile is already flying
                com     missile_flag    ; flip the flag, missile away!
                clra                    ; we need a to be clear because it is the first byte of D
                ldb     position        ; load b with ship position (0-31)
                addd    #480-31         ; move up a row and over one since we want the missile to be in the center relative to the ship
                std     missile_pos     ; and store this value
keypress_1      lda     VDGREG          ; flip css bit on vdg
                eora    #8
                sta     VDGREG
                jsr     wait            ; wait a tick
                lda     VDGREG          ; flip it back
                eora    #8
                sta     VDGREG
keydone         rts

right           lda     position
                sta     oldposit
                cmpa    #31-2           ; allow for ship width 
                beq     atright
                inc     position
atright         rts

left            lda     position
                sta     oldposit
                beq     atleft
                dec     position
atleft          rts

;************************************************
; Show the message
;***
show_msg        ldx     #ADDR_START     ; Load register X with the address for the top of the screen
                ldd     message_pos     ; Load D with the message position (0-480)
                leax    d,x             ; Adjust X accordingly
                ldy     #msg
msg_loop        lda     ,y+
                beq     msg_done        ; null character?
                sta     ,x+
                cmpx    #ADDR_END+1     ; are we at the bottom of the message area?
                blo     msg_loop        ; if not, keep looping
                ldx     #ADDR_START     ; we have reached the bottom, so reset X back to the top
                bra     msg_loop        ; and keep looping until the message is done
msg_done        rts

cls             lda     #$20            ; score line will be black
                ldx     #$400
cls2            sta     ,x+
                cmpx    #$400+32
                bne     cls2
                lda     #$60
                ldx     #ADDR_START
cls1            sta     ,x+
                cmpx    #ADDR_END
                bne     cls1
                rts

;************************************************
wait            ldd     timer
                cmpd    #WAIT_DELAY
                blo     wait
                ldd     #0
                std     timer
                rts

;************************************************
; Set the timer IRQ
;***
setup_timer_irq
                orcc   #FIRQ|IRQ        ; disable interrupts
                lda    #$7e
                sta    IRQ_VECTOR
                ldd    #timerirq        ; address of our new timer routine
                std    IRQ_VECTOR+1     ; install new irq address
                andcc  #~(IRQ|FIRQ)     ; enable interrupts
                rts

;************************************************
; timer irq handler
;***
timerirq        ldd     timer
                addd    #1
                std     timer
                lda     $ff02           ; ack interrupt by reading the PIA data register
                rti


;************************************************
timer           fdb     0               ; irq timer
msg             fcb     $60,$48,$41,$50,$50,$59,$60,$48,$4F,$4C,$49,$44,$41,$59,$53,$00  ; preceeding blank erases the left over character as it moves
new_msg         fcb     $60,$48,$41,$50,$50,$59,$60,$48,$4F,$4C,$49,$44,$41,$59,$53,$00
ship            fcb     $6F,$5E,$5C     ; /^\
missile         fcb     $61             ; !
missile_pos     rmb     2               ; 2 bytes reserved to store the missile location
missile_flag    fcb     0
position        fcb     16
oldposit        fcb     16
message_pos     fdb     $0000
score           fdb     $0000
                end     start
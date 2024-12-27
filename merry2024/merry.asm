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
ADDR_START      equ     $400
ADDR_END        equ     $400+32*15-1
ADDR_PLAYER     equ     ADDR_END+1
POLCAT          equ     $a000
VDGREG          equ     $ff22
DAC             equ     $ff20
;************************************************
start           jsr     setup_timer_irq
                jsr     cls
                jsr     show_msg        ; seed the message

mainloop        jsr     draw
                jsr     wait
                jsr     keypress        ; go check for input
                bra     mainloop

;************************************************
;
;************************************************
draw            ldx     #ADDR_END-1     ; source
                ldy     #ADDR_END       ; destination
                ldb     ADDR_END        ; remember top letter
move_loop       lda     ,x
                sta     ,y
                leax    -1,x
                leay    -1,y
                cmpy    #ADDR_START     ; at top of screen?
                bne     move_loop
                stb     ADDR_START      ; put top letter at bottom
                ldx     #ADDR_PLAYER

;************************************************
; delete ship at old posit and plot at new posit
;************************************************
                lda     oldposit
                ldb     #$60            ; blank char
                stb     a,x  
                lda     position
                ldb     ship
                stb     a,x
                rts

;************************************************
; check for input (left/right arrows/space)
;************************************************
keypress        jsr     [POLCAT]
                cmpa    #9              ;right arrow 
                beq     right
                cmpa    #8              ;left arrow  
                beq     left
                cmpa    #32             ;space
                bne     keydone
                lda     VDGREG          ;flip css bit on vdg
                eora    #8
                sta     VDGREG  
keydone         rts

right           lda     position
                sta     oldposit
                cmpa    #31
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
show_msg        ldx     #ADDR_START
                ldy     #msg
msg_loop        lda     ,y+
                beq     msg_done        ; null character?
                sta     ,x+
                bra     msg_loop
msg_done        rts

cls             lda     #$60
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
timerirq        ldd     timer
                addd    #1
                std     timer
                lda     $ff02           ; ack interrupt by reading the PIA data register
                rti

;************************************************
timer           fdb     0               ; irq timer
msg             fcb     $48,$41,$50,$50,$59,$60,$48,$4F,$4C,$49,$44,$41,$59,$53,$00
ship            fcb     '^'
position        fcb     16
oldposit        fcb     16
fire            fcb     0
                end     start
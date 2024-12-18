;************************************************
; Test program to fiddle around
;

	        include "lee.inc"
	        include "math.inc"
	        include "timer.inc"

start 	        export
strout          import
bn2dec          import

	        section main

;************************************************
start
                jsr     setup_timer_irq
                ;sta     $ffd9
;                ldx     #num0

loop
                ldx     #timer_now
                jsr     timer_val       ; current timer to timer_now
                cmp32   timer_now,timer_delta   ; is now > delta?
                bge     elapsed         ; branch if >=
                bra     loop

; reset wait time, and display current time
elapsed         copy32  timer_delta,timer_now   ; copy now to delta
                ldx     #timer_delta
                lda     #30
                jsr     add832          ; timer_delta += 60

                ldd     timer_delta+2
                ldx     #buffer
                jsr     bn2dec
                ldx     #buffer+1
                jsr     strout
                ldx     #msg
                jsr     strout

                bra     loop





                cmp32   num0,num1
                bge     yes@    ; no
no@             lda     #0
yes@            lda     #1

                cmp32   num1,num0
                bge     yes@    ; yes
no@             lda     #0
yes@            lda     #1

                cmp32   num1,num2
                bge     yes@    ; yes
no@             lda     #0
yes@            lda     #1

                cmp32   num1,num2
                beq     yes@    ; yes
no@             lda     #0
yes@            lda     #1

                cmp32   num0,num3
                bge     yes@    ; no
no@             lda     #0
yes@            lda     #1



                ldd     #$eeff
                std     num0+2
                ldx     #num0
                jsr     set_timer_val

                ldd     #$1234
                cmpd    #$1234
                bge     bge_yes@
                lda     #0
bge_yes@        lda     #1

                ldd     #$1234
                cmpd    #$12ff
                bge     bge_yes@
                lda     #0
bge_yes@        lda     #1

                ldd     #$0000
                cmpd    #$1234
                bgt     bgt_yes@
                lda     #0
bgt_yes@        lda     #1

                ldd     #$FFFF
                cmpd    #$aaaa
                bgt     bgt_yes@
                lda     #0
bgt_yes@        lda     #1

                ldd     #$1234
                cmpd    #$1234
                bgt     bgt_yes@
                lda     #0
bgt_yes@        lda     #1

infinate
                jmp     infinate

num0            fcb     1,$ff,$ff,$ff-4
num1            fcb     5,6,7,8
num2            fcb     5,6,7,8
num3            fcb     9,9,9,9
timer_delta     fcb     $00,$00,$00,$00 ; 32-bit What we are waiting for time to be (1 seconds)
timer_now       fcb     0,0,0,0         ; 32-bit What the timer currently is

buffer          zmb     10
msg             fcc     /=DELTA/
                fcb     13,0

             	endsection

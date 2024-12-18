                include "lee.inc"
                include "math.inc"

setup_timer_irq	export
timer_val	export
set_timer_val	export

IRQ_VECTOR      equ             $fef7

		section code

*************************************************
* Set the timer IRQ
***
setup_timer_irq
                orcc   #FIRQ|IRQ        ; disable interrupts
                lda    #$7e
                sta    IRQ_VECTOR
                ldd    #timerirq        ; address of our new timer routine
                std    IRQ_VECTOR+1     ; install new irq address
                andcc  #~(IRQ|FIRQ)     ; enable interrupts
                rts

*************************************************
* timer irq handler
***
timerirq        ldx     #timer32
                jsr     inc32
                lda     $ff02           ; ack interrupt by reading the PIA data register
                rti


;************************************************
; Copy the current 32-bit timer to the memory pointed to by reg X
; IN:   X - Points to the memory to copy the current timer value to
; OUT:	X - Memory X points to is updated to current time value.
; MOD:  D
;**
timer_val       orcc    #FIRQ|IRQ       ; disable interrupts
       		ldd     timer32
       		std     ,x
       		ldd     timer32+2
       		std     2,x
                andcc   #~(IRQ|FIRQ)    ; enable interrupts
                rts

*************************************************
* Set the timer
; IN:   X - Points to the memory to get new timer from.
* OUT: 	none
* MOD:	none
***
set_timer_val   orcc    #FIRQ|IRQ        ; disable interrupts
                pshs    d
		ldd     ,x
		std     timer32
		ldd     2,x
		std     timer32+2
                puls    d
                andcc   #~(IRQ|FIRQ)     ; enable interrupts
                rts

timer32         fcb     0,0,0,0         ; 32-bit value

				
		endsection
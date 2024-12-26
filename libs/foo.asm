start           export

	        section main

; Compile & run: lwasm -o merry.bin merry.asm && vcc merry.bin
; 8 char tabs only pls

FIRQ		equ	%01000000
IRQ		equ	%00010000
WAIT_DELAY	equ	6
IRQ_VECTOR	equ	$fef7
ADDR_START	equ	$400
ADDR_END	equ	$400+32*16-1

start
		jsr	setup_timer_irq
		jsr	cls
		jsr	show_msg	; seed the message

loop		ldx	#ADDR_START
		ldy	#ADDR_START+1
		ldb	,x		; remember top letter
move_loop	lda	,y+
		sta	,x+
		cmpx	#ADDR_END
		bne	move_loop
		stb	,x		; put top letter at bottom
		jsr	wait
		bra	loop

; Show the message, replace
show_msg	ldx	#ADDR_START
		ldy	#msg
msg_loop	lda	,y+
		beq	msg_done	; null character?
		sta	,x+
		bra	msg_loop
msg_done	rts

cls		lda	#$60
		ldx	#$400
cls1		sta	,x+
		cmpx	#$400+32*16
		bne	cls1
		rts

wait		ldd	timer
		cmpd	#WAIT_DELAY
		blo	wait
		ldd	#0
		std	timer
		rts

; Set the timer IRQ
setup_timer_irq
		orcc   #FIRQ|IRQ	; disable interrupts
		lda    #$7e
		sta    IRQ_VECTOR
		ldd    #timerirq	; address of our new timer routine
		std    IRQ_VECTOR+1	; install new irq address
		andcc  #~(IRQ|FIRQ)	; enable interrupts
		rts

; timer irq handler
timerirq	ldd	timer
		addd	#1
		std	timer
		lda	$ff02		; ack interrupt by reading the PIA data register
		rti

timer		fdb	0		; irq timer
msg		fcb	$48,$41,$50,$50,$59,$60,$48,$4F,$4C,$49,$44,$41,$59,$53,$00


             	endsection

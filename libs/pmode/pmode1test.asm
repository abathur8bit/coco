* compile with pmode1test.bat

*************************************************
* Test pmode1 operations
* Set pmode 1, clear screen on page 0 then put a small rect in top left.
* Then do the same on page 1.
* Then page flip between the 2.
***

        include "pmode1.inc"

start   export  

        section main

start
	sta	$ffd9
        jsr     pmode1

	lda	#0
	jsr	setpage
	jsr	pcls
	ldx	page
	jsr	boxred
	
	lda	#1
	jsr	setpage
	jsr	pcls
	ldx	page
	jsr	boxblue
	ldx	page
	ldb	#10
	abx
	jsr	boxblue
	
loop
	lda	#0
	jsr	showpage
	lda	#1
	jsr	showpage
	bra     loop

***
* 4 pixel x 4 pixel hollow box
***
boxred  
        lda     #%01010101      * top of box
        ldb     #32-1
        sta     ,x+
        abx     
        lda     #%01000001      * mid of box x2
        sta     ,x+
        abx     
        sta     ,x+
        abx     
        lda     #%01010101      * btm of box
        sta     ,x+
        abx     
        rts

boxblue 
        lda     #%10101010      * top of box
        ldb     #32-1
        sta     ,x+
        abx     
        lda     #%10000010      * mid of box x2
        sta     ,x+
        abx     
        sta     ,x+
        abx     
        lda     #%10101010      * btm of box
        sta     ,x+
        abx     
        rts


        
        endsection



************************************************
* change video mode to pmode 3 128x192 4 color
* and activate page 1 at address $e00
*
setpmode4
* setup VDG for pmode 1 by writing 100 to VDG regs
	sta	$ffc5	* v2=1
	sta 	$ffc3	* v1=1
	sta 	$ffc0	* v0=0
* setup PIA by setting the top 5 bits, leaving bottom 3 alone
	lda	$ff22	* read so we can get the bottom 3 bits
	anda	#7	* clear all but bottom 3 bits
	ora	#$F0	* set our pmode value PM=3 : (PM+3)*16+128
	sta 	$ff22	* set pia
	jsr 	page1	
pmode4_done	rts

************************************************
* point to page offset 7, address $e00 (512*7)
*
setpage1	sta	$ffd2	* 0
	sta 	$ffd0	* 0
	sta 	$ffce	* 0
	sta 	$ffcc	* 0
	sta 	$ffcb	* 1
	sta 	$ffc9	* 1
	sta 	$ffc7	* 1
	rts

************************************************
* point to page offset 19, address to be $2600 (512*19)
*
setpage2	sta	$ffd2	* 0
	sta 	$ffd0	* 0
	sta 	$ffcf	* 1
	sta 	$ffcc	* 0
	sta 	$ffca	* 0
	sta 	$ffc9	* 1
	sta 	$ffc7	* 1
	rts

************************************************
* clear 4 pages and set to value of A reg
*
pcls	ldx	pageaddr

pcls4_1	sta	,x+
	cmpx	pageaddr+pagebytes
	bne	pcls4_1
	rts

pageaddr	fdb	$0E00
page1addr	equ	$0E00
page2addr	equ	$2600
pagebytes	equ	$1800	* 4 pages

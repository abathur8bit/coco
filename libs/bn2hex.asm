bn2hex 	export
bn2hexb export
bn2hex2	export
	section code
	
*************************************************
* BN2HEX - Binary to Hex ASCII
* Converts one byte of binary data to two ascii
* characters.
*
* SOURCE : 6809 Assembly Language Subroutines
* 
* IN:	A - Number to convert
* OUT:	A - ASCII most significant digit
*	B - ASCII least significant digit
* MOD:	A,B,CC
* TIME:	37 cycles

bn2hex
        * convert more significant digit to ascii
        tfr     a,b     * save original binary value
        lsra            * move high digit to low digit
        lsra
        lsra
        lsra
        cmpa    #9
        bls     ad30    * branch if high digit is decimal
        adda    #7      * else add 7 so after adding '0'
                        * to character will be an 'a'..'f'
ad30    adda    #'0     * add ascii 0 to make a character

        * convert less significat digit to ascii
        andb    #$0f    * mask off low digit
        cmpb    #9
        bls     ad30ld  * branch if low digit is decimal
        addb    #7      * else add7 so after adding '0'
                        * to the character will be in 'a'..'f'
ad30ld  addb    #'0     * add ascii 0 to make a character
        rts

*************************************************
* bn2hexb - Convert 1 byte to hex ascii and store into buffer.
* This is a modified bn2hex so it can store the ascii into a buffer.
*
* IN:	X - output buffer, gets null terminated
*	A - 1 byte HEX value to convert
* OUT:	Buffer is populated with 2 ascii characters and null terminated
* MOD: 	Everything is preserved

bn2hexb
	pshs	d,x
	jsr	bn2hex	* convert A to 2 ascii chars
	std	,x++	* store the 2 ascii chars to buffer
	clra
	sta	,x	* null terminate
	puls	d,x
	rts
	
*************************************************
* bn2hex2 - Convert 2 byte to hex ascii and store into buffer.
* This is the 2 byte version of bn2hex.
*
* IN:	X - output buffer, gets null terminated
*	D - 2 byte HEX value to convert
* OUT:	Buffer is populated with 4 ascii characters and null terminated
* MOD: 	Everything is preserved

bn2hex2
	pshs	x,d	* save
	jsr	bn2hex
	std	,x++
	lda	1,s	* grab B from stack
	jsr	bn2hex
	std	,x++
	clra
	sta	,x
	puls	x,d	* restore
	rts
	
	endsection
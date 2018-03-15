*******************************************************************************
* pseudo-random number generator. Range is 0 max-1. You can then add a min to A 
* after this call.
*
* A - Range
* Return:
* A - Random number from 0 to range-1
************
rnd		sta	random_max	;keep min and max for later
		jsr	GetRandom
		lda	random_max
		mul
		clrb
		rts
		
*******************************************************************************

* Based on a 16-bit Galois Linear-feedback shift register
* for generating random numbers from 1 to 65535
* Adapted from Steve Bjork

random_min 	fcb	0
random_max	fcb	0

Random_MSB fcb    1
Random_LSB fcb    0

Random_Word equ    Random_MSB

*This code Inits the random number generator...
*Input - None
*Output - None
*Used - A, B

InitRandom

    ldd Random_Word        ;is the 16 bit random word zero?
    bne ExitInitRandom        ;No, then exit the inti code
    inc Random_MSB            ;Yes, than change state to something else that zero

ExitInitRandom
    rts

*GetRandom
*Input - None
*Output - a, b (D) as the new random 16-bit word
*Used - A, B - Use to return new random word
*Note - New random word in Rndom_Word

GetRandom

    clr    ,-s                ;Clear holder of LFSB
    lda    Random_MSB        ;get high byte of 16-bit Random word
    anda    #%10110100        ;Get the bits check in shifting
    ldb    #6                ;Use the top 6 bits for xoring

GetRandom1

    lsla                    ;move top bit into the carry flag
    bcc    GetRandom2        ;skip incing the LFSB if no carry
    inc    ,s                ;add one to the LFSB test holder

GetRandom2

    decb                    ;remove one from loop counter
    bne    GetRandom1        ;loop if all bits are not done

    lda    ,s+                ;get LFSB off of stack
    inca                    ;invert lower bit by adding one
    rora                    ;move bit 0 into carry
    rol    Random_LSB        ;shift carry in to the bit 0 of Random_LSB
    rol    Random_MSB        ;one for shift to complete the 16 shifting
    ldd    Random_Word        ;Load up a and b with the new Random word
    rts
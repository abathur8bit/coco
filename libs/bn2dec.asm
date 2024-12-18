bn2dec	export
	section 	code

*************************************************
* TITLE  : BINARY TO DECIMAL ASCII
* NAME   : BN2DEC
* SOURCE : 6809 ASSEMBLY LANGUAGE SUBROUTINES
*
* PURPOSE: CONVERTS A 16-BIT SIGNED BINARY NUMBER
*          TO ASCII DATA
*
* IN :  D = VALUE TO CONVERT
*       X = OUTPUT BUFFER ADDRESS
* OUT:  THE FIRST BYTE OF THE BUFFER IS THE LENGTH
*       FOLLOWED BY THE CHARACTERS AND A 0 TO NULL
*       TERMINATE THE STRING.
* MOD:  D,X,Y,CC
* TIME: APPROXIMATELY 1000 CYCLES
* SIZE: 99 PROGRAM BYTES, 5 BYTES ON THE STACK

bn2dec
        std     1,x     * save data in buffer
        bpl     cnvert  * branch if data is positive
        ldd     #0      * else take absolute value
        subd    1,x

cnvert  clr     ,x      * string length = zero

* divid binary data by 10 by subtracting power so ten
div10
        ldy     #-1000  * start quotient at -1000

        * find number of thousands in quotient
thousd
        leay    1000,y  * add 1000 to quotient
        subd    #10000
        bcc     thousd  * branch if difference still positive
        addd    #10000  * else add back last 10000

        * find number of hundreds in quotient
        leay    -100,y
hundd   leay    100,y
        subd    #1000
        bcc     hundd
        addd    #1000

        * find number of tens in quotient
        leay    -10,y
tensd   leay    10,y
        subd    #100
        bcc     tensd
        addd    #100

        * find number of ones on quotient
        leay    -1,y
onesd   leay    1,y
        subd    #10
        bcc     onesd
        addd    #10
        * save remainder in stack
        * this is next digit, moving left
        * least significant digit goes into stack
        * first
        stb     ,-s

        inc     ,x      * add 1 to length
        tfr     y,d     * make quotient into new dividend
        cmpd    #0      * check if dividend zero
        bne     div10   * branch of not - divid by 10 again

        * check if original binary data was negative
        * and if so put ascii '-' at front of buffer
        lda     ,x+     * get length byte (not including sign)
        ldb     ,x      * get high byte of data
        bpl     bufld * branch if positive
        ldb     #'-     * otherwise get ascii minus sign
        stb     ,x+     * store minus sign in buffer
        inc     -2,x    * add 1 to length for sign

        * move string of digits from stack to buffer
        * most significant digit is at top of stack
        * convert digits to ascii by adding ascii '0'
bufld
        ldb     ,s+     * get next digit from stack, moving right
        addb    #'0     * convert digit to ascii
        stb     ,x+
        deca
        bne     bufld
        ldb     #0      * null terminate string...
        stb     ,x+     * ...in buffer
        rts

        endsection

*******************************************************************************
* www.8BitCoder.com
*
* Example of reading from the joystick. Displays a graphic block to indicate
* the joystick position, and joystick button status. Output is a little crude,
* but makes the point.
*
* Reference: http://www.cocopedia.com/wiki/index.php/Sampling
*
* Build:     lwasm -9 -b -o joystick.bin joystick.asm && writecocofile --verbose ~/Public/CocoEmulators/gfx.dsk joystick.bin 
*

	org     $3f00

start	lda	#65	Just to see things are working
	sta	$400	Display something to the top left of the screen
	
	jsr	readjoystick

	* display a value to the screen
	
        ORB  #$80    Set bit 7 to turn it into a VDG graphic character
        STB  $500-32
        STA  $500    Put value into middle of the 32 collum screen.
        
	jmp	start
	rts

*******************************************************************************
* Reads the joystick and button values into A&B and outputs
* OUT: 	A Button status
* 	B Joystick position 0-63

readjoystick
* During this process you are writing to the sound register. You must mute the CoCo so none of this is audible. The CoCo's mute switch is controlled by line CB2 of PIA 2. CB2 (like the other 19 lines) is a bidirectional line. This means the line can either output data or input data. For this excersize we need to setup CB2 to output data. We do this by setting bits 4 and 5 of control register B.
        LDA  $FF23  Get current Control Register B value of PIA 2
        ORA  #$30   Set CB2 to be an output. (Set bits 4 and 5.)

* Now the status of bit 3 of Control Register B will control the CB2 line. If bit 3 is low the line will be low. If bit 3 is high the line will be high. Setting CB2 low will mute the CoCo.
        
	ANDA  #$F7   Clear bit 3 - Mute CoCo
        STA   $FF23  Write value back to Control Register B        
        
        LDA  $FF01  Get current Control Register A value of PIA 1
        LDB  $FF03  Get current Control Register B value of PIA 1
        ORA  #$30   Set CA2 to be an output. (Set bits 4 and 5 of CRA.)
        ORB  #$30   Set CB2 to be an output. (Set bits 4 and 5 of CRB.)
        ANDA #$F7   Set CA2 low. (Clear bit 3.)
        ORB  #$08   Set CB2 high. (Set bit 3.)
        STA  $FF01  Store value back in CRA.
        STB  $FF03  Store value back in CRA.

* The CoCo's sound register is 6 bits of side A of PIA 2. Specifically bits 2 thru 7 of the Data Register A. This corresponds to lines PA2 thru PA7. These lines need to be configured as outputs so their signals will go to the digital to analog converter.
        
        LDA  $FF21   Load Control Register A of PIA 2
        ANDA #$FB    Engage Data Direction Register A. (Clear bit 2.)
        STA  $FF21   Store value back in CRA.
        LDA  $FF20   Load Data Direction Register A of PIA 2.
        ORA  #$FC    Set lines PA2 thru PA7 as output. (Set bits 2 thru 7.)
        STA  $FF20   Store value back in DDRA.

* Address $FF20 is both the Data Register A and the Data Direction Register A. It's function is controller by bit 2 of the Control Register A. So in order to actually write data to the CoCo's sound register we need to modify the control register so we can access the data register.

        LDA  $FF21   Load Control Register A of PIA 2
        ORA  #$04    Engage Data Register A. (Set bit 2.)
        STA  $FF21   Store value back in CRA.                        

* Clearing bits 2 thru 7 of the Data Register A of PIA 2 will write a zero to the sound register.

        LDB  $FF20   Load Data Register A of PIA 2.
        ANDB #$03    Write a zero to the sound register. (Clear bits 2 thru 7.)

* Compare the sound register to the value from the joystick

        LDA  $FF01   Load Control Register A of PIA 1
        ANDA #$FB    Engage Data Direction Register A. (Clear bit 2.)
        STA  $FF01   Store value back in CRA.
        LDA  $FF00   Load Data Direction Register A of PIA 1.
        ANDA #$7F    Set line PA7 to be an input. (Clear bit 7.)
        STA  $FF00   Store value back in DDRA.
        
* Modify the Control Register A to engage the Data Register A at $FF00.

        LDA  $FF01   Load Control Register A of PIA 1
        ORA  #$04    Engage Data Register A. (Set bit 2.)
        STA  $FF01   Store value back in CRA.

* Read the output from the comparator.

LOOP    STB  $FF20   Store value in Sound Register
        LDA  $FF00   Bit 7 of register A contains the output information from the comparator.

* If bit 7 is high, then we have found the current value.

       BPL DONE   Branch if negative condition is set to label DONE.
       
* Increment Sound register value by one.

        ADDB #$04   Increment Sound register by one value

* Check for a carry. The sound register will overflow after 64 tries.

        BCS  DONE    Branch to label DONE if carry bit set.
        BRA  LOOP    Branch back to the label LOOP

* We're done. The value of the joystick is in the sound register. We need to shift the data over two bits to normalize it to 1 thru 64.

DONE    LSRB         Logical shift right
        LSRB         Logical shift right               

* Now subtract one to bring it to 0 thru 63.

        DECB

	rts
	
	end	    start

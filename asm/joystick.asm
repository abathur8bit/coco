*******************************************************************************
* www.8BitCoder.com
*
* tabs=8
*
* Joystick routine. After calling, A is the button status (all 4) and B is left xpos. 
* Also left joy xpos is joy_left_xpos, and all 4 buttons are in buttons
*
* Original source from <http://www.cocopedia.com/wiki/index.php/Sampling>
*
* If button value in A:
* ANDA JOY_B0 ;Z=1 if button is pressed 
* BEQ branch if Z=1 
* BNE branch if Z=0
*

JOY_LEFT_B0	equ	%00000010
JOY_LEFT_B1	equ	%00001000
JOY_RIGHT_B0	equ	%00000001
JOY_RIGHT_B1	equ	%00000100

JOY_B0		equ	%00000001
JOY_B1		equ	%00000010
JOY_B2		equ	%00000100
JOY_B3		equ	%00001000

*******************************************************************************
* Reads the joystick and button values into A&B and outputs
* OUT: 	A Button status
* 	B Joystick position 0-63

button          fcb     $00
joy_left_xpos   fcb     $00

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

LOOP    	STB  $FF20   Store value in Sound Register
        	LDA  $FF00   Bit 7 of register A contains the output information from the comparator.

* If bit 7 is high, then we have found the current value.

	       BPL DONE   Branch if negative condition is set to label DONE.

* Increment Sound register value by one.

	        ADDB #$04   Increment Sound register by one value

* Check for a carry. The sound register will overflow after 64 tries.

	        BCS  DONE    Branch to label DONE if carry bit set.
	        BRA  LOOP    Branch back to the label LOOP

* We're done. The value of the joystick is in the sound register. We need to shift the data over two bits to normalize it to 1 thru 64.

DONE    	LSRB         Logical shift right
	        LSRB         Logical shift right

* Now subtract one to bring it to 0 thru 63.

	        DECB
	
		anda	#%00111111
	        sta     button
	        andb	#%00111111
	        stb     joy_left_xpos
	
	        ;lda     $ff92       ;enable the IRQ
	        ;ora     #%00100000
	        ;sta     $ff92

	        rts

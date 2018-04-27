Exmaples for calling an assembly module (function) from C, as well as calling the same routine from another assembly module. 

# Resources

See *Assembly Language Modules*, *Calling convention* and *Creating libraries*
http://perso.b2b2c.ca/~sarrazip/dev/cmoc-manual.html#t19

See *Object Files and Sections* in LWASM manual. 



# Multiple C files
**greet1.c** calls a function in **cnumber.c**. Generates greet1.bin. 

cmoc greet1.c cnumber.c
writecocofile -b casm.dsk greet1.bin && coco3 casm.dsk greet1

# C file and ASM
cmoc greet1.c number.asm

# C greeting calls _greet from library
lwasm -9 -b -f obj -o number.o number.asm 
lwar -c libnumber.a number.o
cmoc greet1.c -L. -lnumber
writecocofile -b casm.dsk greet1.bin && coco3 casm.dsk greet1

# Use assembly calls assembly:
Creates greet2.bin

lwasm -9 -b -f obj -o number.o number.asm 
lwasm -9 -b -f obj -o greet2.o greet2.asm
lwlink -o greet2.bin -b -f decb greet2.o number.o

## Create a C library

cmoc -c cnumber.c
lwar -c libcnumber.a cnumber.o

## Create an assembly library

lwasm -9 -b -f obj -o number.o number.asm 
lwar -c libnumber.a number.o

## Link to the library and run
Note I haven't got the syntax write when linking assembly to a library.

**Compile and link to C lib and assembly lib.**

cmoc -o greet1c.bin greet1.c -L. -lcnumber
cmoc -o greet1.bin greet1.c -L. -lnumber

**Compile assembly calling assembly.**

lwasm -9 -b -f obj -o number.o number.asm 
lwasm -9 -b -f obj -o greet2.o greet2.asm
lwlink -o greet2.bin -b -f decb greet2.o number.o

**Toss bin files onto a disk image.**

writecocofile -b casm.dsk greet1.bin 
writecocofile -b casm.dsk greet1c.bin 
writecocofile -b casm.dsk greet2.bin 


# Calling convention

You push parameters to the function onto the stack, then call the routine, then pop them back off. **Must preserve the U register**.

Caller pops the params off the stack using LEAS <N>,s where **N** is the number of bytes that was pushed. Remember that **X, Y** are 2 bytes, and **A, B** are one byte, and if you are passing in **D** it's 2 bytes as well.

The caller:

```
		ldd	#$3456		* color to clear to
		pshs	d		* push on stack for call
		clra			* clear 
		clrb			* clear
		lda	#$FA		* second param
		pshs	a		* put on stack
		jsr	_clearScreen		* call the routine
		leas	3,s		* pop params (2 bytes for D and 1 for A) off stack
```


The routine that is called. You use the params in reverse order. So the last param that is pushed is at **2,s**. The next will be at **3,s**. Note that the first param is at **2,s** because the stack has the caller return address stored as well.

```
_clearScreen	ldd	3,s		* D=$3456
	lda	2,s		* A=$FA
```

You can return from the routine with **RTS** or if you are popping registers, you can also **puls <regs>,pc** where **regs** is the list of other regs. Like **puls u,pc**.


# Memory Map Notes

All values are in HEX unless otherwise noted. 

C and ML programs should be loaded at 3F00-7FFF, $40FF (16639 dec) bytes or just over 16K.

## BASIC Programs

BASIC programs start at 2600, which is in the middle of graphics memory. PCLEAR is suppose to free up memory, but didn't seem to. 

By default, CMOC org's to 2800

0600	1FFF 	User's BASIC program (4K RAM)
0600	3FFF 	User's BASIC program (16K RAM)
0600	7FFF	User's BASIC program (32K or 64K RAM)

## Quick Reference
0400	05FF	Standard text screen memory
0600	0DFF	DOS - workspace area 
0E00	3DFF	Graphic Video Pages 0-7 
3F00	7FFF	BASIC Programs (just over 16K available)
8000	bfff	BASIC ROM
C000	DFFF	Cartridge ROM Space
E000	FEFF	Unused

### Graphic Video Pages
BASIC programs start at 2600 unless you have done a PCLEAR 8.

0E00	13FF	0
1400	19FF	1
1A00	1FFF	2
2000	25FF	3
2600	2BFF	4 (BASIC programs without PCLEAR 8)
2C00	31FF	5
3200	37FF	6
3800	3DFF	7

### Hires graphics

Using 256x192 16 color. 
Select MMU Page 1: Map GIME $60000-65FFF to 64K address space of $8000-$DFFF
Select MMU Page 2: Map GIME $66000-6BFFF to 64K address space of $8000-$DFFF		


8000	9FFF	60000-61FFF
A000	BFFF	62000-63FFF
C000	DFFF	66000-67FFF

00-2f	00000-5ffff	512K upgrade RAM, unused by BASIC; not present in 128K or smaller systems
30	60000-61FFF	Hi-Res page #1
31	62000-63FFF	Hi-Res page #2
32	66000-67FFF	Hi-Res page #3
33	66000-67fff	Hi-Res page #4
34	68000-69fff	HGET/HPUT buffer
35	6a000-6bfff	Secondary Stack
36	6c000-6dfff	Hi-Res text screen RAM

			; VMODE $FF98
			; 76543210 
			; AxxxxBBB A sets graphics B sets # lines per row
			; A 1=Graphics 0=Text
			; xxxx just leave as 0000
			; BBB Lines per row
			;   00x=one line per row
			;   010=two lines per row
			;   011=eight lines per row
			;   100=nine lines per row
			;   101=ten lines per row
			;   110=eleven lines per row
			;   111=*infinite lines per row
			
			; VRES $FF99
			; 76543210 
			; xAABBBCC
			; x Unused
			; AA scan lines 
			;   00=192 
			;   01=200 
			;   10=undefined 
			;   11=225
			; BBB HRES bytes per row
			;   000=16 bytes per row 
			;   001=20 bytes per row 
			;   010=32 bytes per row 
			;   011=40 bytes per row
			;   100=64 bytes per row
			;   101=80 bytes per row
			;   110=128 bytes per row
			;   111=160 bytes per row
			; CC CRES # colors in graphics mode
			;   00=2 colors (8 pixels per byte)
			;   01=4 colors (4 pixels per byte)
			;   10=16 colors (2 pixels per byte)
			;   11=Undefined (would have been 256 colors)		 

### CC Register
EFHI NZVC
7654 3210
0101 0000

E All registers on stack
-
During interrupt, if 1, indicated all registers on stack, else only PC and CC. Needed for RTI (Return From Interrupt) opcode.

F FIRQ Disabled if 1
-
Set to 1 on power up and during interrupt processing.

H Half Carry
-
Half Carry from low nibble to high nibble, used for DAA (Decimal Addition Adjust) opcode.

I IRQ Disabled if 1
-
IRQ Disabled if 1. Set to 1 on power up and during interrupt processing.

N Last operation resulted in Negative.
-

Z Last operation resulted in Zero.
-

V Signed arithmetic overflow.
-

C Carry generated.
-

### GIME INIT0
See INIT0 tab in **coco graph paper** spreadsheet.

Eg column 
The value I have been setting. 68 $44 %0100 0100. 
Default is 126 $7E %0111 1110

Eg | Bit | Name  | Description
0  | 7   | COCO  | 1=CoCo 1/2 compatible mode
1  | 6   | MMUEN | 1=MMU enabled
0  | 5   | IEN   | 1=GIME chip IRQ enabled
0  | 4   | FEN   | 1=GIME chip FIRQ enabled
   |     |       |
0  | 3   | MC3   | 1=RAM at FExx is constant (secondary vectors)
   |     |       | 
1  | 2   | MC2   | 1=standard SCS (spare chip select)
0  | 1   | MC1   | MC1 & MC0 = ROM map control
0  | 0   | MC0   | 0x=16K internal, 16K external
   |     |       | 10=32K internal
   |     |       | 11=32K external (except interrupt vectors)
	


# Calling printf from assembly, and using U when also pushing regs
In this sample code, the C caller will call the assembly routine line(1,2,3,4) and the assembly will read the params, while at the same time pushing values onto the stack to call printf. We need to use U instead of S because we are pushing onto the stack while still reading from it. If we don't use U, the stack will move, and out offsets into the stack will be wrong.

C:

```
line(1,2,3,4);
```

Assembly:

```
_line	export

color	import
xpos	import
ypos	import
page	import
_printf	import

ARGx1	equ	4
ARGy1	equ	6
ARGx2	equ	8
ARGy2	equ	10

	section 	code
_line	pshs	u	* hold U
	leau	,s	* point U to S
	ldd	ARGy2,u	*D=4
	pshs	b,a
	ldd	ARGx2,u	*D=3
	pshs	b,a
	ldd	ARGy1,u	*D=2
	pshs	b,a
	ldd	ARGx1,u	*D=1
	pshs	b,a
	leax    	msgArgs,pcr	*X points to "X1=%u Y1=%u X2=%u Y2=%u"
	pshs    	x
	LBSR    	_printf 	*make the call
	leas	10,s
	
	leas	,u	* restore the stack pointer
	puls	u,pc	* pop U and return
	
	rts
	
	endsection
	
	section 	rodata
msgArgs	fcc	"X1=%u Y1=%u X2=%u Y2=%u"
	fcb	$0a
	fcb	0
	
	endsection
```
	
# Experimenting

lwasm -9 -b -f obj -o greet.o greet.asm 
lwar -c libgreet.a greet.o

Generating **assembly (.s)** file. Creates **year.s**:
cmoc -S year.c

cmoc hello.c -L. -lgreet
cmoc -c hello.c

lwlink -o hello.bin -b -f decb hello.o greet.o



0&F=0
1&f=1
0	00
1	01
2	10
3	11

3	11
2	10
1	01
0	00

0	0
100	4
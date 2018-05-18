_initGraphics	IMPORT
_clearScreen	IMPORT 
_setPixel	IMPORT
_hline	IMPORT
pixadr	import
bltadr	import

setpixel	macro
	ldd	\3
	pshs	d
	ldd	\2
	pshs	d
	ldd	\1
	pshs	d
	lbsr	_setPixel
	endm

hline	macro
	ldd	\4
	pshs	d
	ldd	\3
	pshs	d
	ldd	\2
	pshs	d
	ldd	\1
	pshs	d
	lbsr	_hline
	endm

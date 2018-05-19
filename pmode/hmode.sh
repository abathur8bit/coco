#!/bin/bash
set -e
echo Compiling asm library code
lwasm -9 -b -f obj -o hmode256.o hmode256.asm 
lwasm -9 -b -f obj -o setpixel256.o setpixel256.asm 
lwasm -9 -b -f obj -o line256.o line256.asm 
lwasm -9 -b -f obj -o textout256.o textout256.asm 
lwasm -9 -b -f obj -o blit256.o blit256.asm 

echo Compiling C library code
cmoc -c cline256.c
cmoc -c gfx.c
#cmoc -c textout.c

echo Making library libgfx256.a from C and ASM
lwar -c libgfx256.a hmode256.o setpixel256.o line256.o cline256.o textout256.o blit256.o gfx.o
#cp libgfx256.a ~/workspace/coco/bb2/BouncyBall2/BouncyBall2
#cp gfx.h ~/workspace/coco/bb2/BouncyBall2/BouncyBall2

echo Building tests
cmoc --org=3F00 hmode.c   -L. -lgfx256
cmoc --org=3F00 testfont.c   -L. -lgfx256
cmoc --org=E00 -i testblit.c   -L. -lgfx256

echo Writing to disk image pmode.dsk
writecocofile -b pmode.dsk hmode.bin 
writecocofile -b pmode.dsk testfont.bin 
writecocofile -b pmode.dsk testblit.bin 

echo Copy disk image
cp pmode.dsk ~/Desktop/vcc-works/pmode.dsk
#mame64 $1 -window -waitvsync -natural -cfg_directory ~/coco -biospath ~/roms coco3 -flop1 pmode.dsk -autoboot_delay 1 -autoboot_command "LOADM\"HMODE\":EXEC\n"
#coco3 pmode.dsk pmode $1

if [ "$1" ==  "mame" ]; then
    echo Launching emulator
    echo coco3 ~/Desktop/vcc-works/pmode.dsk 
    coco3 ~/Desktop/vcc-works/pmode.dsk 
fi

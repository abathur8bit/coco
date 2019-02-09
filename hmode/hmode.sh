#!/bin/bash
set -e
echo Compiling asm library code
lwasm -3 -b -f obj -o hmode256.o hmode256.asm 
lwasm -3 -b -f obj -o setpixel256.o setpixel256.asm 
#lwasm -3 -b -f obj -o line256.o line256.asm
#lwasm -3 -b -f obj -o textout256.o textout256.asm
#lwasm -3 -b -f obj -o blit256.o blit256.asm
#lwasm -3 -b -f obj -o hd6309.o hd6309.asm
lwasm -3 -b -f obj -o hmodeasm.o hmodeasm.asm

echo Compiling C library code
#cmoc -c cline256.c
cmoc -c gfx.c
#cmoc -c textout.c

echo Making library libgfx256.a from C and ASM
lwar -c libgfx256.a hmode256.o setpixel256.o gfx.o 
#cp libgfx256.a ~/workspace/coco/bb2/BouncyBall2/BouncyBall2
#cp gfx.h ~/workspace/coco/bb2/BouncyBall2/BouncyBall2

echo Building tests
cmoc --org=3F00 main.c   -L. -lgfx256
#cmoc --org=3F00 testfont.c   -L. -lgfx256
#cmoc --org=E00 -i testblit.c   -L. -lgfx256
lwlink -o hmodeasm.bin -b -f decb hmodeasm.o hmode256.o setpixel256.o

echo Writing to disk image hmode.dsk
writecocofile -b hmode.dsk main.bin
writecocofile -b hmode.dsk hmodeasm.bin
#writecocofile -b hmode.dsk testfont.bin
#writecocofile -b hmode.dsk testblit.bin

echo Copy disk image
#cp hmode.dsk ~/Desktop/vcc-works/hmode.dsk
#mame64 $1 -window -waitvsync -natural -cfg_directory ~/coco -biospath ~/roms coco3 -flop1 hmode.dsk -autoboot_delay 1 -autoboot_command "LOADM\"HMODE\":EXEC\n"
coco3 hmode.dsk $1 $2

#if [ "$1" ==  "mame" ]; then
#    echo Launching emulator
#    echo coco3 ~/Desktop/vcc-works/hmode.dsk
#    coco3 ~/Desktop/vcc-works/hmode.dsk
#fi

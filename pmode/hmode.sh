#!/bin/bash
set -e
lwasm -9 -b -f obj -o hmode256.o hmode256.asm 
lwasm -9 -b -f obj -o setpixel256.o setpixel256.asm 
lwasm -9 -b -f obj -o line256.o line256.asm 
#lwasm -9 -b -f obj -o line.o line.asm 
lwar -c libgfx256.a hmode256.o setpixel256.o line256.o
cmoc --org=3F00 hmode.c -L. -lgfx256
writecocofile -b pmode.dsk hmode.bin 
mame64 $1 -window -waitvsync -natural -cfg_directory ~/coco -biospath ~/roms coco3 -flop1 pmode.dsk -autoboot_delay 1 -autoboot_command "LOADM\"HMODE\":EXEC\n"
#coco3 pmode.dsk pmode $1


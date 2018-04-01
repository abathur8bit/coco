#!/bin/bash
set -e
lwasm -9 -b -f obj -o pmode4.o pmode4.asm 
lwar -c libpmode4.a pmode4.o
cmoc --org=3F00 pmode.c -L. -lpmode4
writecocofile -b pmode.dsk pmode.bin 
mame64 -window -waitvsync -natural -cfg_directory ~/coco -biospath ~/roms coco3 -flop1 pmode.dsk -autoboot_delay 1 -autoboot_command "LOADM\"PMODE\":EXEC\n"
#coco3 pmode.dsk pmode $1


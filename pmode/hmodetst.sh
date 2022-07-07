#!/bin/bash
set -e
lwasm -9 -b -f obj -o hmode256.o hmode256.asm 
lwasm -9 -b -f obj -o setpixel256.o setpixel256.asm 
lwasm -9 -b -f obj -o hmodetst.o hmodetst.asm 
lwlink -o hmodetst.bin -b -f decb hmodetst.o hmode256.o setpixel256.o
writecocofile -b pmode.dsk hmodetst.bin 
mame64 $1 -window -waitvsync -natural -cfg_directory ~/coco -biospath ~/roms coco3 -flop1 pmode.dsk -autoboot_delay 1 -autoboot_command "LOADM\"HMODETST\":EXEC\n"
#coco3 pmode.dsk pmode $1


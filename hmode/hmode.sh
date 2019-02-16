#!/bin/bash
set -e
echo Compiling asm library code
lwasm -3 -b -f obj -o hmode256.o hmode256.asm 
lwasm -3 -b -f obj -o setpixel256.o setpixel256.asm
lwasm -3 -b -f obj -o line256.o line256.asm

echo Compiling C library code
cmoc -c gfx.c

echo Making library libgfx256.a from C and ASM
lwar -c libgfx256.a hmode256.o setpixel256.o line256.o gfx.o


echo Building tests
cmoc --org=3F00 main.c   -L. -lgfx256
cmoc --org=3F00 pixpagec.c   -L. -lgfx256

lwasm -3 -b -f obj -o mainml.o mainml.asm
lwlink -o mainml.bin -b -f decb mainml.o hmode256.o setpixel256.o

lwasm -3 -b -f obj -o pixpagea.o pixpagea.asm
lwlink -o pixpagea.bin -b -f decb pixpagea.o hmode256.o setpixel256.o


echo Writing to disk image hmode.dsk
./makedecbdisk hmode
writecocofile -b hmode.dsk main.bin
writecocofile -b hmode.dsk mainml.bin
writecocofile -b hmode.dsk pixpagec.bin
writecocofile -b hmode.dsk pixpagea.bin


echo Running
# You can pass in the program to auto run, like "./coco3 hmode.dsk main" to run the main test.
./coco3 hmode.dsk $1 $2

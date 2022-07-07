#!/bin/bash
set -e 
lwasm -9 -b -f obj -o greet.o greet.asm 
lwasm -9 -b -f obj -o usegreet.o usegreet.asm
lwlink -o usegreet.bin -b -f decb usegreet.o greet.o
writecocofile -b casm.dsk usegreet.bin && coco3 casm.dsk usegreet

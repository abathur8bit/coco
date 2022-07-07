#!/bin/bash
set -e
lwasm -9 -b -f obj -o greet.o greet.asm 
lwar -c libgreet.a greet.o
cmoc greeting.c -L. -lgreet
writecocofile -b casm.dsk greeting.bin && coco3 casm.dsk greeting

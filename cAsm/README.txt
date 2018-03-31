See Assembly Language Modules
http://perso.b2b2c.ca/~sarrazip/dev/cmoc-manual.html#t19

Calling convention" and "Creating libraries


# Multiple C files
Generate hello.bin. main calls year() in year.c.
cmoc hello.c year.c
writecocofile -b casm.dsk hello.bin && coco3 casm.dsk hello

# C file and ASM
cmoc greeting.c greet.asm

# C greeting calls _greet from library
lwasm -9 -b -f obj -o greet.o greet.asm 
lwar -c libgreet.a greet.o
cmoc greeting.c -L. -lgreet
writecocofile -b casm.dsk greeting.bin && coco3 casm.dsk greeting

# Use assembly to call assembly _greet:
lwasm -9 -b -f obj -o greet.o greet.asm 
lwasm -9 -b -f obj -o usegreet.o usegreet.asm
lwlink -o usegreet.bin -b -f decb usegreet.o greet.o
writecocofile -b casm.dsk usegreet.bin && coco3 casm.dsk usegreet


# Experimenting

lwasm -9 -b -f obj -o greet.o greet.asm 
lwar -c libgreet.a greet.o

Generating **assembly (.s)** file. Creates **year.s**:
cmoc -S year.c

cmoc hello.c -L. -lgreet
cmoc -c hello.c

lwlink -o hello.bin -b -f decb hello.o greet.o

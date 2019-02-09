# Overview
HMode256 is a 256x192 16 color graphics library written in C and assembly, for the Color Computer 3. 

The goal is to have one library that can be called from both C and Assembly programs. 

# Calling convention
All routines use C calling convention. This means you push parameters being passed to the function onto the stack, call the routine, then pop them back off once the routine returns. **Must preserve the U register**.

The caller can pop the params off the stack using in one call using **LEAS <N>,S** where **N** is the number of bytes that was pushed. Remember that **X, Y** are 2 bytes each, **A, B** are one byte, and if you are passing in **D** it's 2 bytes.

Example caller. We pass $3456 and $FA to the _clearScreen routine:

```
        ldd     #$3456          * color to clear to
        pshs    d               * push on stack for call
        lda     #   $FA             * second param
        pshs    a               * put on stack
        jsr     _clearScreen    * call the routine
        leas    3,s             * pop params (2 bytes for D and 1 for A) off stack
```


The routine that is called. You use the params in reverse order. So the last param that is pushed is at **2,s**. The next will be at **3,s**. Note that the first param is at **2,s** because the stack has the caller return address stored as well.

```
_clearScreen    ldd 3,s     * D=$3456
                lda 2,s     * A=$FA
```

# Running
Assuming you have mame64 in your path, as well as [cmoc] and [lwtools] you can run **hmode.sh**. This will compile and build the graphics library **libgfx256.a** as well as compile and link any samples.  

Run hmode.sh 

# Files


| File            | Purpose                                                     |
|-----------------|---------------                                              |
| hmode.sh        | Build script to build both main test and hmodeasm test.     |
| main.c          | C test                                                      |
| hmodeasm.asm    | Assembly test                                               |
| gfx.c           | Graphics library entry point for C                          |
| gfx.h           |                                                             |
| cline256.c      | Temporary line routines in C.                               |
| hmode256.asm    | Setup routines in Assembly                                  |
| hmode256.inc    | Include file for Assembly                                   |
| line256.asm     | Start of assembly line routines                             |
| setpixel256.asm | Set pixel in assembly, callable from C.                     |



[cmoc]: http://sarrazip.com/dev/cmoc.html
[lwtools]: http://lwtools.projects.l-w.ca/
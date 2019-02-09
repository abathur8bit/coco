hmode is a 256x192x16 color graphics library 
written in C and assembly. You can all the assembly routines
from C, just like you would any C function. Assembly 
programs can also make use of the assembly graphics
routines, although you will need to follow a C calling
convension. This means pushing values onto the stack, then 
removing after the call.


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


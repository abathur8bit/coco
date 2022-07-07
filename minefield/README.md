# Minefield

A text based game that compiles for Color Computer, Linux, macOS, and Windows. Your goal is to make your way from the left of the screen to the right. You are the number, and it changes to indicate the number of mines you are close to. Much like the game *Minesweeper*. Converted and enhanced from BASIC to C from Tim Hartnell's Second Giant Book of Computer Games.


Controls:

```
ESCAPE TO QUIT

MOVEMENT:

                UP

                W
       LEFT   A + D   RIGHT
                S

             DOWN

```



# Compiling
This compiles on Windows using [pdcurses], Linux and macOS using [curses], and for the [Color Computer][colorcomputer] using cmoc. [pdcurses] is included as a precompiled lib file. 

## Windows

**Building** using Visual Studio, **File > Open > CMake**, then select the **CMakeLists.txt** file. **Build > Build All** should build it. You should be able to run and debug it like you would a console app. 

**Running** on the command prompt, navigate to the project folder, then run **minefield.exe**:

```
cd c:\workspace\minefield
out\build\x86-Debug\minefield.exe
```


## Linux & macOS
**Building** on Linux and macOS requires cmake to be installed. On macOS I actually use CLion which comes with cmake embedded. Linux (Ubuntu) you can can install it via **sudo apt install cmake**, then run the following:

```
cmake -f CMakeLists.txt
make
```

Once built, run with:

```
./minefield
```


## Color Computer
You will use [cmoc] to compile to a BIN file that the Color Computer can understand. Once compiled, it will need to be put onto a disk image, then lastly you can run an emulator and mount the disk image. I have used Mame in this example.


### Disk image
Create the disk image using perl. Note that you only have to create the disk image once. You can just copy the BIN file to it without creating it again. 

```
perl -e 'print chr(255) x (35*18*256)' > minefield.dsk
```

### Compile and copy to disk image
I rename the bin file before putting it on the disk image, as the coco only understands 8.3 character filenames. 

```
cmoc minefield.c
mv minefield.bin minef.bin
writecocofile minefield.dsk minef.bin
```

### Running
Last but not least, running it. This will start Mame with the disk image mounted, then automatically load and run the program. The first form is used on Linux, the second on Windows. 

```
.\mame64.exe -window coco3 -flop1 minefield.dsk -autoboot_delay 1 -autoboot_command "LOADM\"minef\":EXEC\n"
.\mame64.exe -window coco3 -flop1 minefield.dsk -autoboot_delay 1 -autoboot_command 'LOADM\"minef\":EXEC\n'
```


[pdcurses]: https://pdcurses.org/
[curses]: https://en.wikipedia.org/wiki/Curses_%28programming_library%29
[colorbasic]: https://en.wikipedia.org/wiki/Color_BASIC
[colorcomputer]: https://en.wikipedia.org/wiki/TRS-80_Color_Computer
[coco3]: https://en.wikipedia.org/wiki/TRS-80_Color_Computer#Color_Computer_3_(1986–1991)
[cmoc]: http://perso.b2b2c.ca/~sarrazip/dev/cmoc.html

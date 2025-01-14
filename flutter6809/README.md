# Flutter 6809

Emulator and debugger for 6809/6309 CPUs.

## About
The 68B09E is a Motorola microprocessor that can run at up to 2MHz. On the [Color Computer 3](https://www.cocopedia.com/wiki/index.php/Color_Computer_3), it was running at 1.79MHz, which was twice the speed of a Color Computer 2.

Hitachi’s HD63B09E microprocessor is a drop-in replacement for the Motorola MC68B09E. It  features a x10 reduction in power consumption. While it was marketed as a drop in replacement, the CPU actually has some hidden features that make the processor considerably faster and and more powerful than a 6809. It has additional registers, can copy memory at up to four times the speed, and most instructions take less cycles to run. For example, every LD instruction runs 1 cycle faster then a 6809.

This project emulates the CPU and RAM of a the 6809 first, and allows a user to single step through source while running code on the CPU. The goal is to be able to debug both Assembly and C programs. Not thought at this point is given to running under OS-9 Level 2.

Initially only 64KB of RAM will be supported, but 512K will be emulated once the GIME is at least partially emulated.

The 6309 support will be added after 512K is supported.

## Status
Currently only runs CPU tests.

## Build and run
`flutter test` will run all tests.

`flutter run` will launch the GUI, which at this point is only a hello world.

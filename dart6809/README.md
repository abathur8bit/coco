# Emulator
6809 emulator. Emulates the CPU and memory. Provides a console view of a memory area. 
This isn't meant to be a Color Computer emulator. Instead it provides a foundation
for a debugger; either console based or GUI. I might go console just for a retro
feel. I haven't built a decent console app before so this might be a good project for 
it.

# Goals
First goal is to get the CPU, memory, and unit tests working with a handful of instructions.
Next would be to get a text view of 0x400-0x5FF, the default 32x16 text display of a Coco.

Finish all instructions.

Start working on the debugger part of the project.

# Running 
## Tests
[Dart tests](https://dart.dev/tools/dart-test) can be run with 


```
C:> dart test
```

which will run all tests in the `test` directory. Tests must be named `something_test.dart`
with the "_test" or it won't be found. Run an individual test with 

```
C:> dart test test\ccreg_test.dart
```

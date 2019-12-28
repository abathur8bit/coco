@echo off 
copy *.c  l:\workspace\coco\memory
copy *.h l:\workspace\coco\memory
copy CMakeLists.txt l:\workspace\coco\memory
echo Compiling macOS...
plink -batch lee@titan "cd workspace/coco/memory && make"
echo.
echo Compiling with cmoc:
plink -batch lee@titan "cd workspace/coco/memory && cmoc memory.c htext.c && writecocofile memory.dsk memory.bin"
pscp lee@titan:workspace/coco/memory/memory.dsk .
copy out\build\x86-Release\memory.exe .
echo.
@echo off 
copy *.c  l:\workspace\coco\rogues
copy *.h l:\workspace\coco\rogues
copy CMakeLists.txt l:\workspace\coco\rogues
echo Compiling macOS...
rem plink -batch lee@titan "cd workspace/coco/rogues && make"
echo.
echo Compiling with cmoc:
plink -batch lee@titan "cd workspace/coco/rogues && cmoc rogues.c htext.c && writecocofile ../memory/memory.dsk rogues.bin"
plink -batch lee@titan "cd workspace/coco/rogues && cmoc text.c && writecocofile ../memory/memory.dsk text.bin"
rem pscp lee@titan:workspace/coco/memory/memory.dsk .
rem copy out\build\x86-Release\rogues.exe .
echo.
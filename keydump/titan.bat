@echo off 
copy *.c  l:\workspace\coco\keydump
copy *.h l:\workspace\coco\keydump
copy CMakeLists.txt l:\workspace\coco\keydump
rem plink -batch lee@titan "cd workspace/coco/keydump && make"
echo Compiling with cmoc:
plink -batch lee@titan "cd workspace/coco/keydump && cmoc keydump.c && writecocofile ../memory/memory.dsk keydump.bin"
rem pscp lee@titan:workspace/coco/keydump/keydump.dsk .
echo.
Putting all common libraries here. Non graphics routines should be in this directory, while specific graphics modes will be in their own directory.

# Build
Running `makea.bat` will build all libs. Specific tests are run via batch files. All routines will be put into `liblee.a`, which you can link to. 


For example, to compile and link a test program that uses liblee:

```
lwasm -9 -f obj -o chrout.o chrout.asm || exit /b  
lwlink -m chrout.map --section-base=main=3f00 --entry=start -L. -llee -o chrout.bin -b chrout.o || exit /b
```

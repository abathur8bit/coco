@echo off
echo Building liblee.a
lwasm -9 -f obj -p c -lstrout.lst -o strout.o strout.asm || exit /b
lwasm -9 -f obj -p c -lbn2dec.lst -o bn2dec.o bn2dec.asm || exit /b
lwasm -9 -f obj -p c -lbn2hex.lst -o bn2hex.o bn2hex.asm || exit /b
lwasm -9 -f obj -p c -lrandom.lst -o random.o random.asm || exit /b
lwasm -9 -f obj -p c -ltimer.lst -o timer.o timer.asm   || exit /b
lwasm -9 -f obj -p c -ldump.lst -o dump.o dump.asm || exit /b
lwasm -9 -f obj -p c -lkeys.lst -o keys.o keys.asm || exit /b
lwasm -9 -f obj -p c -ldiv16.lst -o div16.o div16.asm || exit /b
lwasm -9 -f obj -p c -lmath.lst -o math.o math.asm || exit /b
lwasm -9 -f obj -p c -lmemset.lst -o memset.o memset.asm || exit /b
lwar -c liblee.a strout.o bn2dec.o bn2hex.o dump.o random.o timer.o keys.o div16.o math.o memset.o || exit /b

echo Building foo
lwasm -9 -f obj -lfoo.lst -p c -o foo.o foo.asm || exit /b
lwlink -m foo.map --section-base=main=3f00 --entry=start -L. -llee -o foo.bin -b foo.o || exit /b

echo Building chrout
lwasm -9 -f obj -lchrout.lst -p c -o chrout.o chrout.asm || exit /b
lwlink -m chrout.map --section-base=main=3f00 --entry=start -L. -llee -o chrout.bin -b chrout.o || exit /b

echo Building div16t
lwasm -9 -ldiv16t.lst -f obj -o div16t.o div16t.asm || exit /b
lwlink -m div16t.map --section-base=main=3f00 --entry=start -L. -llee -o div16t.bin -b div16t.o || exit /b

echo Building memsett
lwasm -9 -lmemsett.lst -f obj -o memsett.o memsett.asm || exit /b
lwlink -m memsett.map --section-base=main=3f00 --entry=start -L. -llee -o memsett.bin -b memsett.o || exit /b

php pmode\map2lst.php -m memsett.map > memsettall.lst
php pmode\map2lst.php -m div16t.map > div16tall.lst
php pmode\map2lst.php -m foo.map  > fooall.lst
php pmode\map2lst.php -m chrout.map  > chroutall.lst

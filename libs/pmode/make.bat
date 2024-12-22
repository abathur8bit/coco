@echo off
cd ..
call make.bat || exit /b
cd pmode
cp ..\*.lst .

echo Building libpmode1.a
lwasm -9 -p c -f obj -lpmode1.lst -o pmode1.o pmode1.asm || exit /b
lwasm -9 -p c -f obj -lblit1.lst -o blit1.o blit1.asm || exit /b
lwasm -9 -p c -f obj -lfont8x14.lst -o font8x14.o font8x14.asm || exit /b
lwasm -9 -p c -f obj -lanim.lst -I.. -I. -o anim.o anim.asm || exit /b
lwar -c libpmode1.a pmode1.o blit1.o font8x14.o anim.o || exit /b

echo Building blittest
lwasm -9 -f obj -lblittest.lst -s -p c -I.. -I. -o blittest.o blittest.asm || exit /b
lwlink -m blittest.map --section-base=main=3f00 --entry=start -L.. -L. -llee -lpmode1 -o blittest.bin -b blittest.o || exit /b

echo Building animtest
lwasm -9 -f obj -lanimtest.lst -s -p c -I.. -I. -o animtest.o animtest.asm || exit /b
lwlink -m animtest.map --script=linkscript.txt --entry=start -L.. -L. -llee -lpmode1 -o animtest.bin -b animtest.o || exit /b

echo Building fonttest
lwasm -9 -f obj -lfonttest.lst -s -p c -I.. -I. -o fonttest.o fonttest.asm || exit /b
lwlink -m fonttest.map --script=linkscript.txt --entry=start -L.. -L. -llee -lpmode1 -o fonttest.bin -b fonttest.o || exit /b

echo Building cliptest
lwasm -9 -f obj -lcliptest.lst -s -p c -I.. -I. -o cliptest.o cliptest.asm || exit /b
lwlink -m cliptest.map --script=linkscript.txt --entry=start -L.. -L. -llee -lpmode1 -o cliptest.bin -b cliptest.o || exit /b

echo Building dodgetest (dodget)
lwasm -9 -f obj -ldodgetest.lst -s -p c -I.. -I. -o dodgetest.o dodgetest.asm || exit /b
lwlink -m dodgetest.map --script=linkscript.txt --entry=start -L.. -L. -llee -lpmode1 -o dodget.bin -b dodgetest.o || exit /b

echo Building Dodge Game (dodge)
lwasm -9 -f obj -ldodgegame.lst -s -p c -I.. -I. -o dodgegame.o dodgegame.asm || exit /b
lwlink -m dodgegame.map --script=linkscript.txt --entry=start -L.. -L. -llee -lpmode1 -o dodge.bin -b dodgegame.o || exit /b

echo Building pmode1test (pmt)
lwasm -3 -f obj -lpmode1test.lst -s -p c -I.. -I. -o pmode1test.o pmode1test.asm || exit /b
lwlink -m pmode1test.map --script=linkscript.txt  --entry=start -L.. -L. -llee -lpmode1 -o pmt.bin -b pmode1test.o || exit /b


call php map2lst.php -m fonttest.map > fonttestall.lst
call php map2lst.php -m pmode1test.map > pmode1testall.lst
call php map2lst.php -m dodgegame.map > dodgeall.lst
call php map2lst.php -m animtest.map  > animtestall.lst
call php map2lst.php -m cliptest.map  > cliptestall.lst
rem C:\Users\patte\Downloads\lst2cmt.exe /SYSTEM coco3 /NOLINENUMBERS /OVERWRITE dodgeall.lst coco3.cmt
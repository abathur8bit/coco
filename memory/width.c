#include "coco.h"
#include "stdarg.h"
#include "htext.h"

#pragma org 0xE00

extern byte colorAttr;

void showmem() {
    cls(1);
    for(int i=0; i<80*23; ++i) {
        printf("A");
    }

    mapmmu();

    byte* addr = PAGE_ADDR;
    byte values[80 * 5];
    for (int i = 0; i < sizeof(values); ++i) {
        values[i] = *(addr + i);
    }

    unmapmmu();

    for (int i = 0; i < sizeof(values); ++i) {
        printf("%02X ", values[i]);
    }
    waitforkey();
}

void mmutest() {
    mapmmu();

    byte* addr = PAGE_ADDR;
    byte color = 0;
    for (int i = 0; i < 80 * 24; ++i) {
        *addr = 'B';
        *(addr + 1) = color++;
        addr += 2;
    }

    unmapmmu();
    waitforkey();
}

void speedA() {
    mapmmu();

    for (byte color = 0; color < 8; ++color) {
        byte* addr = PAGE_ADDR;
        for (int i = 0; i < 80 * 24; ++i) {
            *addr = 'B';
            *(addr + 1) = color;
            addr += 2;
        }
    }

    unmapmmu();
    waitforkey();
}

void speedB() {
    cls(1);
    for (int i = 0; i < 80 * 24; ++i) {
        printf("A");
    }
    waitforkey();
}

void textouttest() {
    cls(1);
    gotoxy(5, 5);
    textout("Hello");
    waitforkey();
}

void colorTest() {
    cls(1);
    locate(1, 1);
    printf("X");
    locate(79, 23);
    gotoxy(1, 2);
    const char* ch[8] = { "A","B","C","D","E","F","G","H" };
    for (byte i = 0; i < 8; ++i) {
        setColor(i, 1);
        textout(ch[i]);
    }
    waitforkey();
}
int main() {
    initSystem();
    locate(79, 23);

    //mmutest();
    //showmem();
    //speedB();
    //speedA();
    //textouttest();
    colorTest();

    deinitSystem();
    printf("Done\n");
    int i = 1<<2;
    printf("i=%d\n", i);
    setColor(0, 1);
    printf("colorAttr=%02X\n", colorAttr);
    setColor(3, 1);
    printf("colorAttr=%02X\n", colorAttr);

    return 0;
}
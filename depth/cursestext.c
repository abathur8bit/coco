#include <curses.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#include "cursestext.h"

int screenWidth = SCREEN_WIDTH;
int screenHeight = SCREEN_HEIGHT;

/**
 * Waits for the user to type a key and returns it.
 */
int waitforkey() {
    return wgetch(stdscr);
}

/**
 * Returns a keystroke or 0 of there hasn't been one.
 */
int getkey() {
    nodelay(stdscr, TRUE);
    int ch = getch();
    nodelay(stdscr, FALSE);
    return ch;
}

void initColor() {
    //if(has_colors())
    {
        start_color();
    }
}

void initCurses() {
    initscr();
    cbreak();
    noecho();
    initColor();
    keypad(stdscr, TRUE);
    getmaxyx(stdscr, screenHeight, screenWidth);

    //adjust the mine fields size
    if (screenWidth < SCREEN_WIDTH || screenHeight < SCREEN_HEIGHT) {
        endwin();
        printf("Screen must be at least %dx%d\n", SCREEN_WIDTH, SCREEN_HEIGHT);
        exit(1);
    }
}

void initSystem() {
    initCurses();
    srand(time(NULL));
}

void deinitSystem() {
    endwin();
}

void gotoxy(byte x, byte y) {
    move(y, x);
}

void textout(const char* s) {
    printw("%s", s);
}

void textoutxy(byte x, byte y, const char* s) {
    move(y, x);
    printw("%s", s);
}

void setColor(byte fg, byte bg) {

}

void centertext(byte y, const char* s) {
    int w, h;
    getmaxyx(stdscr, h, w);
    move(y, w / 2 - strlen(s) / 2);
    textout(s);
}

byte getTextWidth() {
    int w, h;
    getmaxyx(stdscr, h, w);
    return w;
}

byte getTextHeight() {
    int w, h;
    getmaxyx(stdscr, h, w);
    return h;
}

long systemStartTime=0;
unsigned short getTimer() {
    struct timeval t;
    gettimeofday(&t,NULL);
    //tv_usec is int32
    long n=(t.tv_sec*1000+t.tv_usec/1000);
    if(!systemStartTime) {
        systemStartTime=n;
    }
//    printf("n=%ld start=%ld start-n=%ld ticks=%ld\n",n,systemStartTime,n-systemStartTime,(n-systemStartTime)/16);
    double ms=(n-systemStartTime)/16.667;
    return (int)(ms)&0xFFFF;   //convert to 60Hz (16.6 but close enough without using floating point)
}
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
    srand((unsigned int)time(0));
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

void charout(const char ch) {
    printw("%c", ch);
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
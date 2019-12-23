#include <curses.h>
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
}

void initColor() {
    //if(has_colors())
    {
        start_color();
        init_pair(COLOR_NORMAL, COLOR_WHITE, COLOR_BLACK);
        init_pair(COLOR_INVERSE, COLOR_BLACK, COLOR_WHITE);
    }
}

void setNormalText() {
    attron(COLOR_PAIR(COLOR_NORMAL));
}

void setInverseText() {
    attron(COLOR_PAIR(COLOR_INVERSE));
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

void setColor(byte fg, byte bg) {

}

void centertexty(int y, const char* s) {
    int w, h;
    getmaxyx(stdscr, h, w);
    move(y, w / 2 - strlen(s) / 2);
    textout(s);
}

/* *****************************************************************************
 * Created by Lee Patterson 12/3/19
 *
 * Copyright 2019 Lee Patterson <https://github.com/abathur8bit>
 *
 * You may use and modify at will. Please credit me in the source.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ******************************************************************************/

#include <curses.h>
#include "memory.h"

#define SCREEN_WIDTH        32
#define SCREEN_HEIGHT       16

int screenWidth = SCREEN_WIDTH;
int screenHeight = SCREEN_HEIGHT;

#ifdef _COCO_BASIC_

#include "coco.h"
#include "stdarg.h"

#define ESCAPE              3   //key code for escape key
#define ENTER               13  //key code for enter key

#define printw printf
#define move(y,x) locate(x,y)
#define clear() cls(1)

#else

#include <curses.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>

#define ESCAPE              27  //key code for escape key
#define ENTER               10  //key code for enter key
#define SCREEN_WIDTH        32
#define SCREEN_HEIGHT       16

//C doesn't a boolean, make life easier for ourselves
typedef unsigned char byte;
typedef char BOOL;
#define TRUE                1
#define FALSE               0

#define COL_NORMAL          1
#define COL_INVERSE         2
WINDOW* win;
#endif

/**
 * Waits for the user to type a key and returns it.  
 */
int waitkey() {
    return wgetch(win);
}

/** 
 * Returns a keystroke or 0 of there hasn't been one. 
 */
int getkey() {
    nodelay(win, TRUE);
    int ch = wgetch(win);
    nodelay(win, FALSE);
}

#ifdef _COCO_BASIC_
int getch() {
    int ch = 0;
    do {
        ch = inkey();
    } while (!ch);
    return ch;
}
#else
void initColor() {
    //if(has_colors())
    {
        start_color();
        init_pair(COL_NORMAL, COLOR_BLACK, COLOR_GREEN);
        init_pair(COL_INVERSE, COLOR_GREEN, COLOR_BLUE);
    }
}

void initCurses() {
    initscr();
    raw();
    noecho();
    initColor();
    getmaxyx(stdscr, screenHeight, screenWidth);

    //adjust the mine fields size
    if (screenWidth < SCREEN_WIDTH || screenHeight < SCREEN_HEIGHT) {
        endwin();
        printf("Screen must be at least %dx%d\n", SCREEN_WIDTH, SCREEN_HEIGHT);
        exit(1);
    }
    win = newwin(SCREEN_HEIGHT, SCREEN_WIDTH, screenHeight / 2 - SCREEN_HEIGHT / 2, screenWidth / 2 - SCREEN_WIDTH / 2);
    if (win == NULL) {
        endwin();
        printf("Unable to make window\n");
        exit(1);
    }
}
#endif

void initSystem() {
#ifdef _COCO_BASIC_
    initCoCoSupport();
    if (isCoCo3) {
        //        width(80);
        setHighSpeed(TRUE);
    }
#else
    initCurses();
    srand(time(NULL));
#endif
}

void deinitSystem() {
#ifdef _COCO_BASIC_
    if (isCoCo3) {
        setHighSpeed(FALSE);
    }
    cls(1);
#else
    endwin();
#endif
}


/**
 * Returns a number between min and max inclusive.
 * If min=1 and max=10 numbers returned would be 1 through
 * 10.
 **/
int rnd(int min, int max) {
    int n = rand() % (max + 1 - min) + min;
    return n;
}

void textout(const char* s) {
#ifdef _COCO_BASIC_
    printf(s);
#else
    wattron(win,COLOR_PAIR(COL_NORMAL));
    const int len = strlen(s);
    //for(int i=0; i<len; ++i) {
    //    if()
    wprintw(win,s);
    wattroff(win,COLOR_PAIR(COL_NORMAL));
    wrefresh(win);
#endif // _COCO_BASIC_

}

void textoutxy(int x, int y, const char* s) {
    wmove(win, y, x);
    wprintf(win, s);
}

void centertexty(int y, const char* s) {
#ifndef _COCO_BASIC_
    int w, h;
    getmaxyx(win, h, w);
    wmove(win, y, w / 2 - strlen(s) / 2);
#else
    locate(SCREEN_WIDTH / 2 - strlen(s) / 2);
#endif

    textout(s);
}
//void textout(const char* fmt, ...) {
//    char buffer[80*25];
//    va_list marker;
//    va_start(marker, fmt);
//    vsnprintf(buffer, sizeof buffer, fmt, marker);
//#ifndef _COCO_BASIC_
//    wattron(win,COLOR_PAIR(COL_NORMAL));
//    wprintw(win,buffer);
//    wattroff(win,COLOR_PAIR(COL_NORMAL));
//    wrefresh(win);
//#endif
//}

void drawField() {
    byte width = 15;
    byte height = 13;
    byte offsety = 0;
    byte offsetx = SCREEN_WIDTH / 2 - width/2;
    for (byte y = 0; y < height; y++) {
        for (byte x = 0; x < width; x++) {
            //wmove(win,offsety + y, offsetx + x);
            textout(".");
        }
    }
}

void cls() {
    wclear(win);
    wattron(win,COLOR_PAIR(COL_NORMAL));
    int offsetx = 0;
    int offsety = 0;
    for (byte y = 0; y < SCREEN_HEIGHT; y++) {
        wmove(win,offsety + y, offsetx);
        for (byte x = 0; x < SCREEN_WIDTH; x++) {
            waddch(win,' ');
            wrefresh(win);
        }
    }
}

void update() {
    wrefresh(win);
}

void locate(int x, int y) {
    wmove(win, y, x);
}

int main()
{
    initSystem();
    cls();
    locate(0, 0);
    textout("Hello world\n");
    textout("Hello world");
    textout("Hello world");
    textout("Hello world");

    waitkey();
    deinitSystem();
	return 0;
}

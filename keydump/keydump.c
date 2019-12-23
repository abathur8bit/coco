/* *****************************************************************************
 * Created by Lee Patterson 12/22/19
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

#define SCREEN_WIDTH        32
#define SCREEN_HEIGHT       16

int screenWidth = SCREEN_WIDTH;
int screenHeight = SCREEN_HEIGHT;

#ifdef _COCO_BASIC_

#include "coco.h"
#include "stdarg.h"

#define ESCAPE              3   //key code for escape key
#define ENTER               13  //key code for enter key
#define LEFT_ARROW          8
#define RIGHT_ARROW         9
#define UP_ARROW            94
#define DOWN_ARROW          10

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
#define LEFT_ARROW          0x104
#define RIGHT_ARROW         0x105
#define UP_ARROW            0x103
#define DOWN_ARROW          0x102

#define SCREEN_WIDTH        32
#define SCREEN_HEIGHT       16

//C doesn't a boolean, make life easier for ourselves
typedef char BOOL;
#define TRUE                1
#define FALSE               0

#endif

#define MINE                '@'
#define EMPTY               ' '
#define MASKED              '.'

#define COL_MASK          1
#define COL_PLAYER        2
#define COL_MINE          3

int level = 0;
int score = 0;
int moves = 0;
int playerX, playerY;
BOOL playing = TRUE;
BOOL maskMines = TRUE;

char field[11][17];

#ifdef _COCO_BASIC_
int getch() {
    int ch = 0;
    do {
        ch = inkey();
    } while (!ch);
    return ch;
}
#else
void initCurses() {
    initscr();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);   //so you can use arrows and function keys
    getmaxyx(stdscr, screenHeight, screenWidth);

    //adjust the mine fields size
    if (screenWidth < SCREEN_WIDTH || screenHeight < SCREEN_HEIGHT) {
        endwin();
        printf("Screen must be at least %dx%d\n", SCREEN_WIDTH, SCREEN_HEIGHT);
        exit(1);
    }
}
#endif

void initSystem() {
#ifdef _COCO_BASIC_
    initCoCoSupport();
    if (isCoCo3) {
        width(80);
        setHighSpeed(TRUE);
    }
#else
    initCurses();
    srand(time(NULL));
#endif
}

void deinitSystemSupport() {
#ifdef _COCO_BASIC_
    if (isCoCo3) {
        //        setHighSpeed(FALSE);
    }
    cls(1);
#else
    endwin();
#endif
}



void waitForKey(int key) {
    int ch;
    while ((ch = getch()) != key && playing) {
        if (ch == ESCAPE) {
            playing = FALSE;
            break;
        }
    }
}

int main() {
    initSystem();

    printw("Keep pressing keys...\n");
    while (playing) {
        int ch = getch();
        printw("key %02X (%d)\n", ch,ch);
        if (ch == LEFT_ARROW) {
            printw("Left!!!\n");
        }
    }

    deinitSystemSupport();
    printf("THANKS FOR PLAYING!\n");
    printf("HTTPS://8BITCODER.COM\n");
    return 0;
}

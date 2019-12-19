/* *****************************************************************************
 * Created by Lee Patterson 12/3/19
 * 
 * Derived from BASIC source in Tim Hartnell's Second Giant Book of Computer Games.
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
void initColor() {
    //  if(has_colors())
    {
        start_color();
        init_pair(COL_MASK, COLOR_GREEN, COLOR_BLUE);
        init_pair(COL_PLAYER, COLOR_WHITE, COLOR_BLUE);
        init_pair(COL_MINE, COLOR_RED, COLOR_BLUE);
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


/**
 * Returns a number between min and max inclusive.
 * If min=1 and max=10 numbers returned would be 1 through
 * 10.
 **/
int rnd(int min, int max) {
    int n = rand() % (max + 1 - min) + min;
    return n;
}

void initGame() {
    playerX = 0;
    playerY = 4;

    //lay mines
    for (int y = 0; y < 10; ++y) {
        for (int x = 0; x < 15; ++x) {
            if (1 == rnd(1, 25) - level && x > 0) {
                field[y][x] = MINE;
            }
            else {
                field[y][x] = MASKED;
            }
        }
    }
}

void countMines() {
    char count = 0;
    for (int y = -1; y <= 1; ++y) {
        for (int x = -1; x <= 1; ++x) {
            if (field[playerY + y][playerX + x] == MINE) {
                ++count;
            }
        }
    }
    field[playerY][playerX] = '0' + count;    //sets the ascii character for the number
}

void drawField(BOOL masked) {
    move(0, 0);
    printw("        M I N E F I E L D\n"
        "LEVEL %02d  MOVES %03d  SCORE %05d\n\n", level + 1, moves, score);
    move(3, 0);
    for (int y = 0; y < 10; ++y) {
        printw("       >");
        for (int x = 0; x < 15; ++x) {
            char ch = (masked && field[y][x] == MINE) ? MASKED : field[y][x];
#ifndef _COCO_BASIC_
            int colorPair = 0;
            if (ch >= '0' && ch <= '9') {
                colorPair = COLOR_PAIR(COL_PLAYER);
            }
            else {
                switch (ch) {
                case MINE:
                    colorPair = COLOR_PAIR(COL_MINE);
                    break;
                case MASKED:
                    colorPair = COLOR_PAIR(COL_MASK);
                    break;
                case EMPTY:
                    colorPair = COLOR_PAIR(COL_PLAYER);
                    break;
                default:
                    colorPair = 0;
                    break;
                }
            }
            if (colorPair) {
                attron(colorPair);
                printw("%c", ch);
                attroff(colorPair);
            }
            else {
                printw("%c", ch);
            }
#else
            printw("%c", ch);
#endif

        }
        printw("#\n");
    }
}

void title() {
    clear();
    printw("        M I N E F I E L D\n\n");
    //      12345678901234567890123456789012
    printw("AVOID MINES WHILE MOVING TOWARD\n"
           "THE SAFTY OF THE BUFFERS (#) ON\n"
           "THE RIGHT SIDE OF THE GRID.\n\n");
    printw("ESCAPE TO QUIT\n\n");
    /*
     *  y w u
     *   \!/
     * a -+- d
     *   /!\
     *  z s c
     */
    printw("MOVEMENT:\n\n"
        "                UP\n\n"
        "                W\n"
        "       LEFT   A + D   RIGHT\n"
        "                S\n\n"
        "             DOWN\n");
    printw("\nPRESS A KEY TO START");
    int ch = getch();
    if (ch == ESCAPE)
        playing = FALSE;
    clear();
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
    title();
    initGame();

    while (playing) {
        countMines();
        drawField(maskMines);
        char ch = (char)tolower(getch());
        int moveX = 0;
        int moveY = 0;

        switch (ch) {
        case ESCAPE:
            playing = FALSE;
            break;
        case 'm':   //cheat key to show/hide the mines while playing
            maskMines = !maskMines;
            break;
        case 'w': //up
        case 'k': //up
            moveY = -1;
            break;
        case 's':   //down
        case 'j':   //down
            moveY = 1;
            break;
        case 'a': //left
        case 'h': //left
            moveX = -1;
            break;
        case 'd': //right
        case 'l': //right
            moveX = 1;
            break;
        }

        if (playing) {
            if ((moveX || moveY) && playerY + moveY >= 0 &&
                playerY + moveY < 10 &&
                playerX + moveX >= 0) {
                field[playerY][playerX] = EMPTY;
                ++moves;

                if (playerY + moveY >= 0 &&
                    playerY + moveY < 10) {
                    playerY += moveY;
                }

                if (playerX + moveX < 0)
                    continue;

                if (playerX + moveX > 14) {
                    score += 100 - moves;

                    clear();

                    drawField(FALSE);
                    printw("\nCOMPLETED IN %d MOVES.\n",
                        moves);
                    printw("PRESS <SPACE> FOR NEXT LEVEL");
                    waitForKey(' ');
                    clear();
                    moves = 0;
                    ++level;
                    initGame();
                }
                else {
                    playerX += moveX;
                    if (field[playerY][playerX] == MINE) {
                        field[playerY][playerX] = 'X';
                        clear();
                        drawField(FALSE);
                        printw("\nYOU HIT A MINE\n");
                        printw("PRESS <SPACE> TO TRY AGAIN");
                        waitForKey(' ');
                        clear();
                        moves = 0;
                        score = 0;
                        level = 0;
                        initGame();
                    }
                }
            }
        }
    }

    deinitSystemSupport();
    printf("THANKS FOR PLAYING!\n");
    printf("HTTPS://8BITCODER.COM\n");
    return 0;
}

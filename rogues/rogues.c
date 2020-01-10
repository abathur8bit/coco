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

#ifdef _COCO_BASIC_

#include "coco.h"
#include "stdarg.h"
#include "htext.h"

//#pragma org 0xE00

#else //curses

#include <curses.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include "cursestext.h"
#include <string.h>

#endif //_COCO_BASIC_

#define TITLE           "R O G U E S"
#define CLR_WALL        1
#define CLR_OPEN        2
#define CLR_NORMAL      5
#define CLR_MESSAGE     6

#define WALL            '-'
#define OPEN            '.'
#define ATHING           'X'
#define ONE '1'
#define TWO '2'
#define THREE '3'

#define OFFSET_TOP      2   //where to start drawing text

#define MAX_ROWS 24
#define MAX_COLS 80
char map[MAX_ROWS][MAX_COLS];
char buffer[80*25];
BOOL playing = TRUE;
byte rows = 3;
byte cols = 3;
int gameKey = 1;

/**
 * Returns a number between min and max inclusive.
 * If min=1 and max=10 numbers returned would be 1 through
 * 10.
 **/
int rnd(int min, int max) {
    int n = rand() % (max + 1 - min) + min;
    return n;
}

void setupColorPairs() {
#ifndef _COCO_BASIC_
    init_pair(CLR_WALL, COLOR_YELLOW, COLOR_RED);
    init_pair(CLR_OPEN, COLOR_BLACK, COLOR_YELLOW);
    init_pair(CLR_NORMAL, COLOR_WHITE, COLOR_BLACK);
    init_pair(CLR_MESSAGE, COLOR_BLACK, COLOR_CYAN);
#endif // !_COCO_BASIC_

}

void colorPair(byte pair) {
#ifdef _COCO_BASIC_
    switch (pair) {
    case CLR_WALL:
        setColor(COLOR_YELLOW, COLOR_RED);
        break;
    case CLR_OPEN:
        setColor(COLOR_BLACK, COLOR_YELLOW);
        break;
    case CLR_NORMAL:
        setColor(COLOR_WHITE, COLOR_BLACK);
        break;
    case CLR_MESSAGE:
        setColor(COLOR_BLACK, COLOR_CYAN);
        break;
}
#else 
    attron(COLOR_PAIR(pair));
#endif // _COCO_BASIC_
}

void resetMap() {
    int w = MAX_COLS;
    int h = MAX_ROWS;
    for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
            map[y][x] = WALL;
        }
    }
}

void initGame() {
    srand(gameKey);
    resetMap();
}

void fillRoomWith(int sx, int sy, int maxw, int maxh, char c) {
    for (int y = 0; y < maxh; ++y) {
        for (int x = 0; x < maxw; ++x) {
            map[sy + y][sx + x] = c;
        }
    }
}

void createMap3x3() {
    fillRoomWith(0, 0, 26, 8, '1');
    fillRoomWith(27, 0, 26, 8, '2');
    fillRoomWith(54, 0, 26, 8, '3');

    fillRoomWith(0, 8, 26, 8, '3');
    fillRoomWith(27, 8, 26, 8, '1');
    fillRoomWith(54, 8, 26, 8, '2');

    fillRoomWith(0, 16, 26, 8, '1');
    fillRoomWith(27, 16, 26, 8, '2');
    fillRoomWith(54, 16, 26, 8, '3');
}

void createMap2x2() {
    fillRoomWith( 0, 0, 40, 12, '1');
    fillRoomWith(40, 0, 40, 12, '2');
    fillRoomWith( 0,12, 40, 12, '2');
    fillRoomWith(40,12, 40, 12, '1');
}

void createRoom(int sx, int sy, int maxw, int maxh, char c) {
    float widthScale[] = { 50,50,50,50,50,50,40,40,40,30,30,10,10,0,0,0,0 };
    int scale = rnd(0, sizeof(widthScale) / sizeof(widthScale[0]) - 1);
    int minw = (int)(((float)maxw) * (widthScale[scale] / 100));
    int minh = (int)(((float)maxh) * (widthScale[scale] / 100));

    if (minw && minh) {
        int w = rnd(minw, maxw - 1);
        int h = rnd(minh, maxh - 1);

        if (w == 1) w = 2;
        if (h == 1) h = 2;

        int xpos = rnd(0, maxw - w - 1);
        int ypos = rnd(0, maxh - h - 1);

        if (w && h) {

            xpos += sx;
            ypos += sy;
            for (int y = 0; y < h; ++y) {
                for (int x = 0; x < w; ++x) {
                    map[ypos + y][xpos + x] = c;
                }
            }
        }
        sprintf(buffer, "p%d,%d d%dx%d m%dx%d s%d", xpos - sx, ypos - sy, w, h, minw, minh, scale);
        for (byte i = 0; i < strlen(buffer); ++i) {
            map[sy][sx + i] = buffer[i];
        }
    }
}

void createMap() {
    resetMap();
    int colSizeScale[] = {3,3,3,3,3,3,3,3,3,2,2,2,2,2,4,4};
    int rowSizeScale[] = {3,3,3,3,3,2,2,2,2,2};
    cols = colSizeScale[rnd(0, sizeof(colSizeScale) / sizeof(colSizeScale[0])-1)];
    rows = rowSizeScale[rnd(0, sizeof(rowSizeScale) / sizeof(rowSizeScale[0])-1)];
    //cols = (byte)rnd(2,4);
    //rows = (byte)rnd(2,3);
    int w = getTextWidth() / cols;
    int h = getTextHeight() / rows;
    for (int y = 0; y < rows; ++y) {
        for (int x = 0; x < cols; ++x) {
            createRoom(x * w, y * h, w-1, h-1, OPEN);
        }
    }
}

void drawField() {
    byte w = MAX_COLS;
    byte h = MAX_ROWS;
    for (byte y = 0; y < h; ++y) {
        for (byte x = 0; x < w; ++x) {
            switch (map[y][x]) {
                case WALL: 
                    colorPair(CLR_WALL);
                    charoutxy(x, y, ' ');
                    break;
                case OPEN:
                    colorPair(CLR_OPEN);
                    charoutxy(x, y, ' ');
                    break;
                case ATHING:
                    colorPair(CLR_MESSAGE);
                    charoutxy(x, y, ' ');
                    break;
                case '1':
                    colorPair(CLR_NORMAL);
                    charoutxy(x, y, '1');
                    break;
                case '2':
                    colorPair(CLR_NORMAL);
                    charoutxy(x, y, '2');
                    break;
                case '3':
                    colorPair(CLR_NORMAL);
                    charoutxy(x, y, '3');
                    break;
                default:
                    colorPair(CLR_NORMAL);
                    charoutxy(x, y, map[y][x]);
                    break;
            }
        }
    }
}

void showMessage(const char* s) {
    colorPair(CLR_MESSAGE);
    textoutxy(0, 23, "                                                                                ");
    centertext(23, s);
    if (waitforkey() == ESCAPE) playing = FALSE;
    colorPair(CLR_NORMAL);
    textoutxy(0, 23,"                                                                                ");
}

void playGame() {
    int level[5][2] = { {2,2},{2,2},{3,2},{3,3},{4,3} };
    clear();
    initGame();
    int selectx = 0;
    int selecty = 0;
    while (playing) {
        clear();
        createMap();
        drawField();

        colorPair(CLR_NORMAL);
        sprintf(buffer, "cols=%d rows=%d", cols, rows);
        textoutxy(0, 23, buffer);

        int ch = waitforkey();
        switch (ch) {
        case ESCAPE:
            playing = FALSE;
            break;
        case 'a':
        case LEFT_ARROW: 
            selectx--;
            break;
        case 'd':
        case RIGHT_ARROW:
            selectx++;
            break;
        case 'w':
        case UP_ARROW:
            selecty -= 1;
            break;
        case 's':
        case DOWN_ARROW:
            selecty += 1;
            break;
        }
    }
    deinitSystem();
}

void title() {
    clear();
#ifdef _COCO_BASIC_
    locate(0, 1);   //position the cursor out of sight
#endif
    byte y = getTextHeight()/2;
    byte offsetx = getTextWidth() / 2 - 40;
    colorPair(CLR_NORMAL);
    centertext(y++, TITLE);

    sprintf(buffer, "wxh=%dx%d", getTextWidth(), getTextHeight());
    centertext(0, buffer);
    y = 22;
    centertext(y++, "A game by Lee Patterson");
    centertext(y++, "https://8BitCoder.com");

    //calculate a new random seed while waiting
    int n = 0;
    while (getkey() == -1)
        n++;
    gameKey = n;
}

void showWidthHeight() {
    initSystem();
    int w = getTextWidth();
    int h = getTextHeight();
    deinitSystem();

    printf("w=%d h=%d\n", w, h);
}

#ifndef _COCO_BASIC_
int main(int argc,char* argv[]) {
#else
int main() {
#endif
    initSystem();
    setupColorPairs();

    title();
#ifndef _COCO_BASIC_
    if (argc > 1) {
        gameKey = atoi(argv[1]);
        srand(gameKey);
    }
#endif

    playGame();
    printf("Thanks for playing!\n");
    printf("https://8BitCoder.com\n\n");
    printf("Screen size was %dx%d\n", getTextWidth(), getTextHeight());
    printf("Game key: %d\n", gameKey);
    return 0;
}

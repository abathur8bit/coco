/* *****************************************************************************
 * Created by Lee Patterson Friday July 8, 2022
 *
 * Copyright 2022, Lee Patterson <https://github.com/abathur8bit>
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
#include <string.h>
#include "cursestext.h"

#endif //_COCO_BASIC_

#define COLOR_TITLE                      1
#define COLOR_DIE                2
#define COLOR_SCORE               3
#define COLOR_YELLOW_BLACK         4
#define COLOR_NORMAL                        5
#define COLOR_MESSAGE                       6
#define COLOR_CARD_UNDERSIDE_NOCURSOR       7

#define OFFSET_TOP                          2   //where to start drawing text

#define MAX_PLAYERS         2
#define COMPUTER            0
#define PLAYER              1
#define MAX_DICE            3
#define MAX_SCORE_NAMES     8
#define SCORE_START         50
#define MAX_ROUNDS          5

#define DRAW_PLAYER                 1
#define DRAW_PLAYER_TOTAL           2
#define DRAW_PLAYER_SCORENAMES      4
#define DRAW_COMPUTER               8
#define DRAW_COMPUTER_TOTAL         16
#define DRAW_COMPUTER_SCORENAMES    32

BOOL playing=TRUE;

/**
 * Returns a number between min and max inclusive.
 * If min=1 and max=10 numbers returned would be 1 through
 * 10.
 **/
int rnd(int min, int max) {
    int n = rand() % (max + 1 - min) + min;
    return n;
}

/** Sleep the given number of ticks, with 60 equal 1 second. */
unsigned short snooze(int ticks) {
    int start=getTimer();
    int n;
    while((n=getTimer())-start < ticks) {}
    return n;
}

void setupColorPairs() {
#ifndef _COCO_BASIC_
    init_pair(COLOR_TITLE, COLOR_YELLOW, COLOR_RED);
    init_pair(COLOR_DIE, COLOR_BLACK, COLOR_YELLOW);
    init_pair(COLOR_SCORE, COLOR_WHITE, COLOR_CYAN);
    init_pair(COLOR_YELLOW_BLACK, COLOR_YELLOW, COLOR_BLACK);
    init_pair(COLOR_CARD_UNDERSIDE_NOCURSOR, COLOR_BLACK, COLOR_CYAN);
    init_pair(COLOR_NORMAL, COLOR_WHITE, COLOR_BLACK);
    init_pair(COLOR_MESSAGE, COLOR_BLACK, COLOR_CYAN);
#endif // !_COCO_BASIC_

}

void colorPair(byte pair) {
#ifdef _COCO_BASIC_
    switch (pair) {
    case COLOR_TITLE:
        setColor(COLOR_YELLOW, COLOR_RED);
        break;
    case COLOR_DIE:
        setColor(COLOR_BLACK, COLOR_YELLOW);
        break;
    case COLOR_SCORE:
        setColor(COLOR_WHITE, COLOR_CYAN);
        break;
    case COLOR_YELLOW_BLACK:
        setColor(COLOR_YELLOW, COLOR_BLACK);
        break;
    case COLOR_CARD_UNDERSIDE_NOCURSOR:
        setColor(COLOR_BLACK, COLOR_CYAN);
        break;
    case COLOR_NORMAL:
        setColor(COLOR_WHITE, COLOR_BLACK);
        break;
    case COLOR_MESSAGE:
        setColor(COLOR_BLACK, COLOR_CYAN);
        break;
}
#else 
    attron(COLOR_PAIR(pair));
#endif // _COCO_BASIC_
}

void clearMessage() {
    byte offsetx = getTextWidth() / 2 - 40;
    colorPair(COLOR_NORMAL);
    textoutxy(offsetx, 23,"                                                                                ");
}

void showMessage(BOOL wait,const char* s) {
    byte offsetx = getTextWidth() / 2 - 40;
    colorPair(COLOR_MESSAGE);
    textoutxy(offsetx, 23, "                                                                                ");
    centertext(23, s);
    if(wait) {
        if(waitforkey()==ESCAPE) playing=FALSE;
        clearMessage();
    }
}

void initGame() {
    playing=TRUE;
    colorPair(COLOR_NORMAL);
}

void playGame() {
    clear();
    while (playing) {
        initGame();
        textout("DEPTH\n");
        textout("DEPTH");
        //        1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
        //                 1         2         3         4         5         6         7         8         9         0
        waitforkey();
        playing=FALSE;
    }
    deinitSystem();
}

void title() {
    clear();
#ifdef _COCO_BASIC_
    locate(0, 1);   //position the cursor out of sight
#endif
    byte y = 0;
    byte offsetx = getTextWidth() / 2 - 40;
    colorPair(COLOR_MESSAGE);
    textoutxy(offsetx, y++, "                                     DEPTH                                    ");
    colorPair(COLOR_NORMAL);
    //                                 1         2         3         4         5         6         7         8
    //                        12345678901234567890123456789012345678901234567890123456789012345678901234567890
    textout( "You are the captain of a destroyer and you must use depth charges to stop a");
    textout( "submarien that is trying to sink you! You will enter an ");
    textoutxy(offsetx, y++,  "");
    colorPair(COLOR_TITLE);
    y+=2;
    centertext(y++, "PRESS ANY KEY TO CONTINUE");
    textoutxy(offsetx, y++, "");
    textoutxy(offsetx, y++, "");
    colorPair(COLOR_MESSAGE);
    textoutxy(offsetx, 22, "                           A game by Lee Patterson                              ");
    textoutxy(offsetx, 23, "                            https://8BitCoder.com                               ");

    //calculate a new random seed while waiting
    int n = 0;
    while (getkey() == -1)
        n++;
    srand(n);
}

void showWidthHeight() {
    initSystem();
    int w = getTextWidth();
    int h = getTextHeight();
    deinitSystem();

    printf("w=%d h=%d\n", w, h);
}

int main() {
    initSystem();
    setupColorPairs();
    title();
    playGame();
    printf("\n\n\n\n");
    printf("---------------------------------------------------------\n");
    printf("- Thanks for playing!                                   -\n");
    printf("- A game by Lee Patterson https://8BitCoder.com         -\n");
    printf("---------------------------------------------------------\n");

	return 0;
}

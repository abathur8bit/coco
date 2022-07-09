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
#include "cursestext.h"

#endif //_COCO_BASIC_

#define TITLE                               "CMALIBU"
#define COLOR_CARD_TOP                      1
#define COLOR_CARD_UNDERSIDE                2
#define COLOR_CARD_TOP_CURSOR               3
#define COLOR_CARD_UNDERSIDE_CURSOR         4
#define COLOR_NORMAL                        5
#define COLOR_MESSAGE                       6
#define COLOR_CARD_UNDERSIDE_NOCURSOR       7

#define OFFSET_TOP                          0   //where to start drawing text

#define ROW_CARDS 13
int score[2];
char buffer[80*25];
BOOL playing = TRUE;

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
    init_pair(COLOR_CARD_TOP, COLOR_YELLOW, COLOR_RED);
    init_pair(COLOR_CARD_UNDERSIDE, COLOR_BLACK, COLOR_YELLOW);
    init_pair(COLOR_CARD_TOP_CURSOR, COLOR_WHITE, COLOR_CYAN);
    init_pair(COLOR_CARD_UNDERSIDE_CURSOR, COLOR_WHITE, COLOR_CYAN);
    init_pair(COLOR_CARD_UNDERSIDE_NOCURSOR, COLOR_BLACK, COLOR_CYAN);
    init_pair(COLOR_NORMAL, COLOR_WHITE, COLOR_BLACK);
    init_pair(COLOR_MESSAGE, COLOR_BLACK, COLOR_CYAN);
#endif // !_COCO_BASIC_

}

void colorPair(byte pair) {
#ifdef _COCO_BASIC_
    switch (pair) {
    case COLOR_CARD_TOP:
        setColor(COLOR_YELLOW, COLOR_RED);
        break;
    case COLOR_CARD_UNDERSIDE:
        setColor(COLOR_BLACK, COLOR_YELLOW);
        break;
    case COLOR_CARD_TOP_CURSOR:
        setColor(COLOR_WHITE, COLOR_CYAN);
        break;
    case COLOR_CARD_UNDERSIDE_CURSOR:
        setColor(COLOR_WHITE, COLOR_CYAN);
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

void showMessage(const char* s) {
    colorPair(COLOR_MESSAGE);
    textoutxy(0, 23, "                                                                                ");
    centertext(23, s);
    if (waitforkey() == ESCAPE) playing = FALSE;
    colorPair(COLOR_NORMAL);
    textoutxy(0, 23,"                                                                                ");
}

void drawScore() {
    colorPair(COLOR_NORMAL);
    //                                       1         2         3         4         5         6         7         8
    //                              12345678901234567890123456789012345678901234567890123456789012345678901234567890
    snprintf(buffer,sizeof(buffer),"SCORE: PLAYER 1: %02d                                                 COMPUTER: %02d",score[0],score[1]);
    textoutxy(0,1,buffer);
//    textoutxy(0,1,"         1         2         3         4         5         6         7         8");
//    textoutxy(0,2,"12345678901234567890123456789012345678901234567890123456789012345678901234567890");
//    textoutxy(0,3,buffer);
}



void drawHeader() {
    colorPair(COLOR_NORMAL);
    centertext(OFFSET_TOP, TITLE);
    drawScore();
}

void rollComputer() {

}

void rollPlayer() {
    
}
void playGame() {
    clear();
    while (playing) {
        drawHeader();
        rollComputer();
        rollPlayer();
        totalComputer();
        totalPlayer();
        int ch = waitforkey();
        switch (ch) {
        case ESCAPE:
            playing = FALSE;
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
    byte y = 0;
    byte offsetx = getTextWidth() / 2 - 40;
    colorPair(COLOR_MESSAGE);
    textoutxy(offsetx, y++, "                                     CMALIBU                                    ");
    colorPair(COLOR_NORMAL);
    textoutxy(offsetx, y++, "");
    colorPair(COLOR_CARD_TOP);
    centertext(y++, "PRESS ANY KEY TO CONTINUE");
    textoutxy(offsetx, y++, "");
    textoutxy(offsetx, y++, "");
    colorPair(COLOR_MESSAGE);
    textoutxy(offsetx, y++, "                           A game by Lee Patterson                              ");
    textoutxy(offsetx, y++, "                            https://8BitCoder.com                               ");

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

int main()
{
    //showWidthHeight(); return 0;

    initSystem();
    setupColorPairs();
    title();
    playGame();
    printf("Thanks for playing!\n");
    printf("https://8BitCoder.com\n\n");
	return 0;
}

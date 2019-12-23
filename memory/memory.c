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

#pragma org 0xE00

#else //curses

#include <curses.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include "cursestext.h"

#endif //_COCO_BASIC_

#define COLOR_CARD_TOP          1
#define COLOR_CARD_UNDERSIDE    2
#define COLOR_CARD_SELECTED     3

typedef struct {
    char value;
    char suite;
    BOOL flipped;
} CARD;

CARD cards[56];
CARD* selectedCard = NULL;  //NULL non selected
char buffer[80*25];
BOOL playing = TRUE;

void initCards() {
    char suites[] = "CSDH";
    char cardValues[] = "123456789TJQKA";

    int cardIndex = 0;
    for (int s = 0; s < sizeof(suites)-1; ++s) {
        for (int c = 0; c < sizeof(cardValues)-1; ++c) {
            cards[cardIndex].value = cardValues[c];
            cards[cardIndex].suite = suites[s];
            cards[cardIndex].flipped = FALSE;
            ++cardIndex;
        }
    }
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

void setupColorPairs() {
#ifndef _COCO_BASIC_
    init_pair(COLOR_CARD_TOP, COLOR_YELLOW, COLOR_RED);
    init_pair(COLOR_CARD_UNDERSIDE, COLOR_BLACK, COLOR_YELLOW);
    init_pair(COLOR_CARD_SELECTED, COLOR_BLACK, COLOR_CYAN);
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
    case COLOR_CARD_SELECTED:
        setColor(COLOR_BLACK, COLOR_CYAN);
        break;
}
#else 
    attron(COLOR_PAIR(pair));
#endif // _COCO_BASIC_
}

void drawCard(byte x,byte y,CARD* c) {
    char spaces[] = "    ";
    char buff[]   = " <> ";
    if (c == selectedCard) {
        colorPair(COLOR_CARD_SELECTED);
    } else if (c->flipped) {
        buff[1] = c->value;
        buff[2] = c->suite;
        colorPair(COLOR_CARD_UNDERSIDE);
    }
    else {
        colorPair(COLOR_CARD_TOP);
    }
    //setInverseText();
    gotoxy(x, y);
    textout(spaces);
    gotoxy(x, y+1);
    textout(buff);
    gotoxy(x, y+2);
    textout(spaces);
    //setNormalText();
}

void drawDeck() {
    int cardIndex = 0;
    byte offsetx = 5;
    byte y = 3;
    while (cardIndex < 52) {
        for (int x = 0; x < 14; ++x) {
            //gotoxy((byte)(offsetx + x * 3), y);
            //char buffer[] = "  ";
            //buffer[0] = cards[cardIndex].value;
            //buffer[1] = cards[cardIndex].suite;
            //textout(buffer);
            drawCard((byte)(offsetx + x*5), y, &cards[cardIndex]);
            ++cardIndex;
        }
        y += 4;
    }
}
void drawField() {
    byte width = 80;
    byte height = 20;
    byte offsety = 1;
    byte offsetx = SCREEN_WIDTH / 2 - width/2;
    for (byte y = 0; y < height; y++) {
        for (byte x = 0; x < width; x++) {
            gotoxy(offsetx + x, offsety + y);
            textout(".");
        }
    }
}

void playGame() {
    initSystem();
    setupColorPairs();
    selectedCard = &cards[0];

    clear();
    initCards();
    int selectx = 0;
    int selecty = 0;
    while (playing) {
        centertext(0, "M E M O R Y");
        drawDeck();
        int ch = waitforkey();
        sprintf(buffer, "key=%d   ", ch);
        textoutxy(10,0,buffer);
        switch (ch) {
        case ESCAPE:
            playing = FALSE;
            break;
        case LEFT_ARROW: 
            selectx--;
            break;
        case RIGHT_ARROW:
            selectx++;
            break;
        case UP_ARROW:
            selecty -= 1;
            break;
        case DOWN_ARROW:
            selecty += 1;
            break;
        }
        if (selectx < 0) selectx = 13;
        if (selectx > 13) selectx = 0;
        if (selecty < 0) selecty = 3;
        if (selecty > 3) selecty = 0;

        selectedCard = &cards[selecty*14+selectx];
    }
    deinitSystem();
}

void showCards() {
    initCards();
    for (int i = 0; i < 56; i++) {
        printf("%c%c ", cards[i].value, cards[i].suite);
    }
}
int main()
{
    //showCards();
    playGame();
    printf("Thanks for playing!\n");
    printf("https://8BitCoder.com\n");
	return 0;
}

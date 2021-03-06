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

#endif //_COCO_BASIC_

#define TITLE                               "M E M O R Y"
#define COLOR_CARD_TOP                      1
#define COLOR_CARD_UNDERSIDE                2
#define COLOR_CARD_TOP_CURSOR               3
#define COLOR_CARD_UNDERSIDE_CURSOR         4
#define COLOR_NORMAL                        5
#define COLOR_MESSAGE                       6
#define COLOR_CARD_UNDERSIDE_NOCURSOR       7

#define OFFSET_TOP                          2   //where to start drawing text

typedef struct {
    char value;
    char suite;
    BOOL flipped;
} CARD;

#define ROW_CARDS 13
CARD cards[52];
CARD* selectedCard = NULL;  //NULL non selected
CARD* firstCard = NULL;  //NULL non selected
CARD* secondCard = NULL;  //NULL non selected
char buffer[80*25];
BOOL playing = TRUE;
BOOL forceFlipped = FALSE;      //debug flag to always show underside of card
int score = 0;
int best = -1;

/**
 * Returns a number between min and max inclusive.
 * If min=1 and max=10 numbers returned would be 1 through
 * 10.
 **/
int rnd(int min, int max) {
    int n = rand() % (max + 1 - min) + min;
    return n;
}

void shuffleCards() {
    CARD temp;
    int a, b;
    for (int i = 0; i < 100; i++) {
        a = rnd(0, 51);
        b = rnd(0, 51);
        temp = cards[a];
        cards[a] = cards[b];
        cards[b] = temp;
    }
}

void initCards() {
    char suites[] = "CSDH";
    char cardValues[] = "23456789TJQKA";

    int cardIndex = 0;
    for (int s = 0; s < sizeof(suites)-1; ++s) {
        for (int c = 0; c < sizeof(cardValues)-1; ++c) {
            if (cardIndex > sizeof(cards) / sizeof(cards[0])) {
                deinitSystem();
                printf("Too many cards created in initCards\n");
                exit(1);
            }
            cards[cardIndex].value = cardValues[c];
            cards[cardIndex].suite = suites[s];
            cards[cardIndex].flipped = FALSE;
            ++cardIndex;
        }
    }

    shuffleCards();
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

void drawCard(byte x,byte y,CARD* c) {
    char spaces[] = "    ";
    char buff[]   = " <> ";
    //not flipped                       COLOR_CARD_TOP
    //flipped                           COLOR_CARD_UNDERSIDE
    //flipped current turn              COLOR_CARD_UNDERSIDE_NOCURSOR
    //not flipped and cursor on it      COLOR_CARD_TOP_CURSOR
    //flipped and cursor on it          COLOR_CARD_UNDERSIDE_CURSOR

    if (forceFlipped) {
        buff[1] = c->value;
        buff[2] = c->suite;
    }

    if (c == selectedCard) {
        if (c->flipped) {
            buff[1] = c->value;
            buff[2] = c->suite;
            colorPair(COLOR_CARD_UNDERSIDE_CURSOR);
        }
        else {
            colorPair(COLOR_CARD_TOP_CURSOR);
        }
    }
    else {
        if (c->flipped) {
            buff[1] = c->value;
            buff[2] = c->suite;
            if (c == firstCard || c == secondCard) {
                colorPair(COLOR_CARD_UNDERSIDE_NOCURSOR);
            }
            else {
                colorPair(COLOR_CARD_UNDERSIDE);
            }
        }
        else {
            colorPair(COLOR_CARD_TOP);
        }
    }

    gotoxy(x, y);
    textout(spaces);
    gotoxy(x, y+1);
    textout(buff);
    gotoxy(x, y+2);
    textout(spaces);
}

void drawDeck() {
    int cardIndex = 0;
    byte offsetx = getTextWidth()/2-(ROW_CARDS*5/2);
    byte y = OFFSET_TOP+4;
    while (cardIndex < 52) {
        for (int x = 0; x < ROW_CARDS; ++x) {
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
    //                        1         2         3         4         5         6         7         8
    //               12345678901234567890123456789012345678901234567890123456789012345678901234567890
    char bestShown[] = "----";
    if (best != -1) {
        sprintf(bestShown, "%04d", best);
    }
    sprintf(buffer, "TURNS: %04d                                           BEST: %4s", score, bestShown);
    centertext(OFFSET_TOP+2, buffer);
}

void fakeWin() {
    for (int i = 0; i < 52; ++i) {
        cards[i].flipped = TRUE;
    }
}

BOOL checkWin() {
    int flipped = 0;
    for (int i = 0; i < 52; ++i) {
        if(cards[i].flipped)
            flipped++;
    }
    return 52 == flipped;
}

void showWin() {
    if (score < best || best == -1) {
        best = score;
        drawScore();
        sprintf(buffer, "You won in %d turns. New best!", score);
    }
    else {
        sprintf(buffer, "You won in %d turns.", score);
    }
    showMessage(buffer);
    score = 0;
    initCards();
}



void drawTable() {
    colorPair(COLOR_NORMAL);
    centertext(OFFSET_TOP, TITLE);
    drawScore();
    drawDeck();
}

void playGame() {
    selectedCard = &cards[0];

    clear();
    initCards();
    int selectx = 0;
    int selecty = 0;
    BOOL isCardChosen = FALSE;
    while (playing) {
        drawTable();
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
        case ' ':
        case ENTER:
            isCardChosen = TRUE;
            break;
        //case 'F':
        //    forceFlipped = !forceFlipped;
        //    break;
        }

        if (selectx < 0) selectx = ROW_CARDS-1;
        if (selectx > ROW_CARDS-1) selectx = 0;
        if (selecty < 0) selecty = 3;
        if (selecty > 3) selecty = 0;

        selectedCard = &cards[selecty * ROW_CARDS + selectx];
        if (selectedCard->flipped)
            isCardChosen = FALSE;

        if (isCardChosen) {
            isCardChosen = FALSE;   //reset
            if (!firstCard) {
                firstCard = selectedCard;
                firstCard->flipped = TRUE;
            }
            else if(firstCard != selectedCard) {
                secondCard = selectedCard;
                secondCard->flipped = TRUE;
                drawDeck();
            }

            if (firstCard && secondCard) {
                ++score;
                drawScore();
                BOOL match = FALSE;
                char* msg[2] = { "Cards don't match","Match!" };
                if (firstCard->value == secondCard->value) {
                    match = TRUE;
                }
                else {
                    match = FALSE;
                }

                if (!match) {
                    firstCard->flipped = FALSE;
                    secondCard->flipped = FALSE;
                }
                if (checkWin()) {
                    showWin();
                }
                else {
                    showMessage(msg[match]);
                }
                firstCard = secondCard = NULL;
            }
        }

        //if (ch == 'W') {
        //    fakeWin();
        //    drawDeck();
        //    showWin();
        //}
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
    textoutxy(offsetx, y++, "                                   M E M O R Y                                  ");
    colorPair(COLOR_NORMAL);
    textoutxy(offsetx, y++, "");
    textoutxy(offsetx, y++, "Memory, also known by the name Concentration, is a card game played with a ");
    textoutxy(offsetx, y++, "standard deck of 52 cards. Cards include thirteen ranks numbered 2-10 (T for 10)");
    textoutxy(offsetx, y++, "jack (J), queen (Q), king (K) and ace (A), in each of the four suites: ");
    textoutxy(offsetx, y++, "");
    textoutxy(offsetx, y++, "    clubs (C), diamonds (D), hearts (H), and spades (S).");
    textoutxy(offsetx, y++, "");
    textoutxy(offsetx, y++, "You flip cards over two at a time. If the rank matches (the suite does not need");
    textoutxy(offsetx, y++, "to) you leave the cards face up and chose another two. If they do no match you");
    textoutxy(offsetx, y++, "turn them over so they are face down again.");
    textoutxy(offsetx, y++, "");
    textoutxy(offsetx, y++, "You continue flipping cards two at a time, leaving matches face up, and flipping");
    textoutxy(offsetx, y++, "ones that do not match back over until all cards have been matched.");
    textoutxy(offsetx, y++, "");
    textoutxy(offsetx, y++, "Your score is the number of turns you have made. The lower the score the better.");
    textoutxy(offsetx, y++, "");
    textoutxy(offsetx, y++, "Use the arrow keys, ENTER to select a card, ESCAPE to quit the game.");
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

void showCards() {
    initCards();
    int x = 0;
    for (int i = 0; i < 52; i++) {
        printf("%c%c ", cards[i].value, cards[i].suite);
        if (++x >= 13)
        {
            printf("\n");
            x = 0;
        }
    }
    printf("\n");
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

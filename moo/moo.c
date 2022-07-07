#ifdef _COCO_BASIC_

#include <coco.h>
#include "htext.h"

#else

#include <curses.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include <string.h>
#include "cursestext.h"

#endif

#define GAME_TITLE		"M O O"
#define MAX_GUESSES		14
#define MAX_DIGITS		4

#define COLOR_NORMAL	1
#define COLOR_BOARD		2

char buffer[256];
char guesses[MAX_GUESSES][MAX_DIGITS];
char answer[MAX_GUESSES][MAX_DIGITS];
char code[5];
int guessNumber=0;
byte guessLinePos = 0;
BOOL playing = TRUE;
byte offsetx = 0;
byte offsety = 0;


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
	init_pair(COLOR_NORMAL, COLOR_WHITE, COLOR_BLACK);
	init_pair(COLOR_BOARD, COLOR_WHITE, COLOR_BLUE);
#endif // !_COCO_BASIC_
}

void colorPair(byte pair) {
#ifdef _COCO_BASIC_
	switch (pair) {
	case COLOR_NORMAL:
		setColor(COLOR_WHITE, COLOR_BLACK);
		break;
	case COLOR_BOARD:
		setColor(COLOR_YELLOW, COLOR_BLUE);
		break;
	}
#else 
	attron(COLOR_PAIR(pair));
#endif // _COCO_BASIC_
}

BOOL codeContains(char n) {
	for (int i = 0; i < MAX_DIGITS; ++i) {
		if (code[i] == n)
			return TRUE;
	}
	return FALSE;
}

void initGame() {
	memset(guesses, 0, sizeof(guesses));
	memset(answer, 0, sizeof(answer));
	memset(code, 0, sizeof(code));
	guessNumber = 0;

	for (int i = 0; i < MAX_DIGITS; ++i) {
		char n = 0;
		do {
			n = (char)('0' + rnd(1, 9));
		} while (codeContains(n));
		code[i] = n;
	}
}

void centerbar(byte y, const char* s) {
	byte x = getTextWidth() / 2 - 40;
	textoutxy(x, y, "                                                                                ");  //erase any old message
	centertext(y, s);                                                                                     //display string centered 
}

void statusMessage(const char* msg) {
	centerbar(SCREEN_HEIGHT - 1, msg);
}

void drawBoard(BOOL showCode) {
	const char* bar = "+ - - - - - - - - - +";
	//const char* empty      = "|                   |";
	const char* codeHidden = "| * * * *           |";
	const char* guessLine = "| ? ? ? ?           |";
	offsety = 2;
	offsetx = getTextWidth() / 2 - (byte)strlen(bar) / 2;
	colorPair(COLOR_BOARD);
	centerbar(0, GAME_TITLE);
	centertext(0, GAME_TITLE);

	centertext(offsety++, bar);
	if (showCode) {
		gotoxy(offsetx, offsety++);
		textout("| ");
		for (byte x = 0; x < MAX_DIGITS; ++x) {
			charout(code[x]);
			charout(' ');
		}
		textout("          |");
	}
	else {
		centertext(offsety++, codeHidden);
	}
	centertext(offsety++, bar);

	for (byte y = 0; y < MAX_GUESSES; ++y)
	{
		gotoxy(offsetx, offsety++);
		textout("| ");
		for (byte x = 0; x < MAX_DIGITS; ++x)
		{
			if (guesses[y][x]) {
				charout((char)(guesses[y][x]));
			}
			else {
				charout('0');
			}
			charout(' ');
		}
		textout("  ");
		for (byte x = 0; x < 4; ++x) {
			if (!answer[y][x]) {
				charout('.');
			}
			else {
				charout(answer[y][x]);
			}
			charout(' ');
		}
		textout("|");
	}
	centertext(offsety++, bar);
	guessLinePos = offsety;
	
	int num = guessNumber < MAX_GUESSES ? guessNumber : MAX_GUESSES - 1;
	gotoxy(offsetx, offsety++);
	textout("| ");
	for (byte x = 0; x < MAX_DIGITS; ++x) {
		char ch = guesses[num][x];
		if (ch) {
			charout(ch);
		}
		else {
			charout('?');
		}
		charout(' ');
	}
	textout("          |");


	centertext(offsety++, bar);
	gotoxy(offsetx + 2, guessLinePos);
}

BOOL isCow(int digit, int pos) {
	for (int i = 0; i < MAX_DIGITS; ++i) {
		if(digit == code[i] && i != pos) {
			return TRUE;
		}
	}
	return FALSE;
}
void calculateAnswer(int move) {
	int bulls = 0;
	int cows = 0;
	//check for bulls
	for (int i = 0; i < MAX_DIGITS; ++i) {
		if (guesses[move][i] == code[i]) 
			bulls++;
	}
	//check for cows
	for (int i = 0; i < MAX_DIGITS; ++i) {
		if (isCow(guesses[move][i], i))
			cows++;
	}
	for (int i = 0; i < MAX_DIGITS; ++i) {
		if (bulls) {
			answer[move][i] = 'B';
			bulls--;
		}
		else if (cows) {
			answer[move][i] = 'C';
			cows--;
		}
	}
}

void getPlayerMove() {
    char ch;
	byte startx = offsetx + 2;
    byte x = startx;
    byte y = guessLinePos;
	int digit = 0;
	BOOL gettingMove = TRUE;
    while(digit < MAX_DIGITS && playing && gettingMove) {
        gotoxy(x,y);
        ch = (char)waitforkey();
        if(ESCAPE == ch) {
            playing = FALSE;
		}
		else if (ch == '?') {
			drawBoard(TRUE);
			waitforkey();
			drawBoard(FALSE);
		}
		else if (BACKSPACE == ch) {
            if (digit > 0) {
                --digit;    //previous number
                guesses[guessNumber][digit] = 0;
                x -= 2;
                gotoxy(x, y);
                charout('?');
			}
			else {
				guesses[guessNumber][digit] = 0;
				gotoxy(x, y);
				charout('?');
				gotoxy(x, y);
			}
        } else if(ENTER == ch) {
			int counter = 0;
			for (int i = 0; i < MAX_DIGITS; ++i) {
				if (guesses[guessNumber][i]) {
					++counter;
				}
			}
			if (counter == MAX_DIGITS) {
				sprintf(buffer, "Your guess %c %c %c %c", guesses[guessNumber][0], guesses[guessNumber][1], guesses[guessNumber][2], guesses[guessNumber][3]);
				statusMessage(buffer);
				calculateAnswer(guessNumber);
				drawBoard(FALSE);
				gettingMove = FALSE;	//done waiting for move
			}
			else {
				statusMessage("You need 4 digits");
			}
        } else if(ch >= '1' && ch <= '9') {
            //guessing a digit
			if (digit < MAX_DIGITS) {
				guesses[guessNumber][digit] = ch;
				charout(ch);
				x += 2;
				++digit;
				if (digit == MAX_DIGITS) {
					digit = 0;
					x = startx;
				}
			} else {
				digit = 0;
				x = startx;
			}
        }
    }
}

BOOL playerDidWin() {
	int bulls = 0;
	//check for bulls
	for (int i = 0; i < MAX_DIGITS; ++i) {
		if (guesses[guessNumber][i] == code[i])
			bulls++;
	}
	
    return bulls == MAX_DIGITS;
}

void showGuessNumber() {
	sprintf(buffer, "Guess %d", guessNumber + 1);
	statusMessage(buffer);
}

void title() {
	clear();
	byte x = getTextWidth() / 2 - 40;
	byte y = 2;

	colorPair(COLOR_BOARD);
	centerbar(0, GAME_TITLE);
	colorPair(COLOR_NORMAL);
	textoutxy(x,y++,"The computer creates a 4 digit code consisting of numbers 1 thru 9. You get 14");
	textoutxy(x,y++,"guesses to figure out the code. After each guess you will be given hints in the");
	textoutxy(x,y++,"form of bulls and cows. A bull means you guessed the right number, in the right");
	textoutxy(x,y++,"place. A cow is the right number in the wrong place. The placement of the bulls");
	textoutxy(x,y++,"and cows has no relation to the placement of the digits.");
	textoutxy(x,y++,"");
	textoutxy(x,y++,"To enter your guess, type in your code, and press ENTER.Note that you can");
	textoutxy(x,y++,"keep typing numbers, but your guess won't register until you hit that ENTER key.");
	textoutxy(x,y++,"");
	textoutxy(x,y++,"EXAMPLE");
	textoutxy(x,y++,"The computer creates the code 4135, and you guess 1234. You would get 1 bull for");
	textoutxy(x,y++,"the 3, and 2 cows for the 4 and 1.");
	textoutxy(x, y++, "");
	textoutxy(x, y++, "");
	textoutxy(x, y++, "");
	textoutxy(x, y++, "");

	colorPair(COLOR_BOARD);
	centerbar(getTextHeight() - 2, "A game by Lee Patterson");
	centerbar(getTextHeight() - 1, "https://8BitCoder.com");
	colorPair(COLOR_NORMAL);

	centertext(y++, "Press any key to continue");
	waitforkey();
	clear();
}

void game() {
	initSystem();
	setupColorPairs();
	title();
	initGame();
	while(playing) {
        drawBoard(FALSE);
		showGuessNumber();
        getPlayerMove();
        if(playerDidWin()) {
			sprintf(buffer,"YOU WON IN %d MOVES",guessNumber+1);
			statusMessage(buffer);
			drawBoard(TRUE);
			waitforkey();
			initGame();
		} else {
			guessNumber++;
			if (guessNumber < MAX_GUESSES) {
				showGuessNumber();
			}
			else {
				sprintf(buffer, "You lost. Code was %s",code);
				statusMessage(buffer);
				drawBoard(TRUE);
				waitforkey();
				initGame();
			}
        }
    }
	deinitSystem();
}

int main() {
	game();
	return 0;
}

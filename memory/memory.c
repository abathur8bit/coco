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

/**
 * Returns a number between min and max inclusive.
 * If min=1 and max=10 numbers returned would be 1 through
 * 10.
 **/
int rnd(int min, int max) {
    int n = rand() % (max + 1 - min) + min;
    return n;
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

int main()
{
    initSystem();

    clear();
    drawField();
    gotoxy(0, 20);
    textout("Done");
    gotoxy(0, 21);
    setInverseText();
    textout("Finished");
    waitforkey();
    deinitSystem();
	return 0;
}

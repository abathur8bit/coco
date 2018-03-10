// cmoc fourc.c && writecocofile --verbose ../emulators/mame/messwork.dsk fourc.bin && ../emulators/mame/gomess.sh messwork.dsk -autoboot_delay 1 -autoboot_command 'LOADM"fourc":EXEC\n'
/*
 * I can see why I initially had trouble switching from BASIC to C. The blocks of logic
 * are structured so differently. It is a bit tricky to convert from BASIC to C. But once
 * you dive into C, and think in terms of C logic blocks, it becomes eaiser.
 */
#ifndef _COCO_BASIC_
#error This program must be compiled for a CoCo Disk Basic environment.
#endif

#define NDEBUG  /* disable the asserts */

#include "coco.h"
#include "stdarg.h"

byte playing = 1;
byte a[110];    //109+1 as basic includes the last array element
byte m[31];
byte p[7];
byte empty = '.';
byte human = 'H';
byte cpu = 'C';

void showWinner(byte winner);
byte checkColor(byte x);

void init()
{
    memset(a,0,sizeof(a));
    memset(m,0,sizeof(m));
    memset(p,0,sizeof(p));
    for(int b=1; b<=109; b++)
    {
        a[b]=empty;
        int d=b-10*(b/10);
        if(d==0 || d>7 || b<11 || b>77)
            a[b]=-9;
    }
}

byte winCheck()
{
    byte winner = checkColor(human);

    if(!winner)
        checkColor(cpu);

    if(winner)
        showWinner(winner);

    return winner;

// 680 REM WIN CHECK
// 690 X=H
// 700 B=10
// 710 B=B+1
// 720 IF A(B)<>X THEN 770
// 730 IF A(B+1)=X AND A(B+2)=X AND A(B+3)=X THEN 800
// 740 IF B>30 THEN IF A(B-10)=X AND A(B-20)=X AND A(B-30)=X THEN 800
// 750 IF B>33 THEN IF A(B-11)=X AND A(B-22)=X AND A(B-33)=X THEN 800
// 760 IF B>27 THEN IF A(B-9)=X AND A(B-18)=X AND A(B-27)=X  THEN 800
// 770 IF B<77 THEN 710
// 780 IF X=H THEN X=C : GOTO 700
// 790 RETURN
// 800 REM WIN FOUND
// 810 REM PRINT : PRINT
// 820 IF X=H THEN PRINT "YOU'VE BETTEN ME, HUMAN!"
// 830 IF X=C THEN PRINT "I'VE DEFEATED YOU, HUMAN!"
// 840 PRINT : PRINT : END

}

byte checkColor(byte x)
{
    byte b=10;
    byte winner=0;

    do
    {
        ++b;        //710 B=B+1
        if(a[b]==x) //720 IF A(B)<>X THEN 770
        {
            if(a[b+1]==x && a[b+2]==x  && a[b+3]==x)
                winner=x;
            else if(b>30 && a[b-10]==x && a[b-20]==x && a[b-30]==x)
                winner=x;
            else if(b>33 && a[b-11]==x && a[b-22]==x && a[b-33]==x)
                winner=x;
            else if(b>27 && a[b-9]==x && a[b-18]==x && a[b-27]==x)
                winner=x;
        }
    }
    while(b<77 && !winner);

    return winner;
}

void humanMove()
{
    unsigned move=0;
    while(move<1 || move>7)
    {
        printf("WHICH COLUMN? ");
        move = readword();
        byte z=(byte)move;
        z+=10;
        while(a[z+10]==empty)
            z+=10;

        if(a[z]==empty)
        {
            a[z]=human;
        }
        else
        {
            printf("YOU CAN'T MOVE THERE\n");
            move=0; //invalidate player move
        }
    }
}

void computerMove()
{
    printf("STAND BY FOR MY MOVE...");
    byte b=10;
    byte move=0;
    do
    {
        ++b;
        if(a[b]!= -9)
        {
            if(a[b]==cpu || a[b]==human)
            {
                x=a[b];
            }
        }
    } while(b<77 && !move);
    b=(byte)(rand()%7+1);
    a[m[b]] = cpu;
}

byte across(byte b,byte x)
{
            //across
            if(a[b+1]==x && a[b+2]==x && a[b+3]==e && a[b+13]!=e)
                move=b+3;
            else if(a[b-1]==x && a[b-2]==x && a[b-3]==e && a[b+7]!=e)
                move=b-3;
            else if(a[b+1]==x && a[b+2]==x && a[b-1]==e && a[b+9]!=e)
                move=b-1 ;
            else if(a[b-1]==x && a[b+2]==x && a[b+1]==e && a[b+11]!=e)
                move=b+1;
            else if(a[b+1]==x && a[b-1]==x && a[b+2]==e && a[b+12]!=e)
                move=b+2;
            else if(a[b+1]==x && a[b-1]==x && a[b-2]==e && a[b+8]!=e)
                move=b-2;
            else if(a[b-1]==x && a[b-2]==x && a[b+1]==e && a[b+11]!=e)
                move=b+1;
}

void showWinner(byte winner)
{
    if(winner == human)
        printf("YOU'VE BEATEN ME, HUMAN!\n");
    else
        printf("I'VE DEFEATED YOU, HUMAN!\n");
}

void printBoard()
{
    cls(1);
    printf("FOUR C\n\n");
    for(int k=10; k<=70; k+=10)
    {
        printf("        ");
        for(int j=1; j<=7; j++)
        {
            printf("%c ",a[k+j]);
        }
        printf("\n");
    }
    printf("        - - - - - - -\n");
    printf("        1 2 3 4 5 6 7\n");
    printf("\n");
}

int main()
{
    init();
    while(1)
    {
        printBoard();
        if(winCheck()) break;
        humanMove();
        printBoard();
        if(winCheck()) break;
        computerMove();
    }
//     cls(1);
    printf("THANKS FOR PLAYING\n");
    return 0;
}

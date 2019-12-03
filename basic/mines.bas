10  REM MINESWEEPER
20  REM NEAL CAVALIER-SMITH
30  CLS
50  DIM A(11,17)
60  L=1:S=0:M=0
70  REM ***
80  REM LAY MINES
90  FOR Y=1 TO 10
100  FOR X=1 TO 15
110   K=RND(25)-L
120   A(Y,X)=46 : REM "."
130   IF K=1 THEN A(Y,X)=64 : REM "@"
140  NEXT X
150  A(Y,1)=46 : REM "."
160 NEXT Y
170 B=5:C=1
180 A(B,C)=33 : REM "!"
190 GOTO 500
200 REM ***
210 REM PRINT MINEFIELD
220 CLS
230 PRINT "MINES"
240 FOR X=1 TO 10
250  PRINT TAB(6);">";
260  FOR Y=1 TO 15
270   IF A(X,Y)<>64 THEN PRINT CHR$(A(X,Y));
280   IF A(X,Y)=64 THEN PRINT ".";
290  NEXT Y
300 PRINT "#"
310 NEXT X
320 PRINT
330 A(B,C)=32
340 REM ***
350 REM MOVE SWEEPER
360 PRINT "ENTER YOUR MOVE"
370 PRINT "U(P), D(OWN), L(EFT), R(IGHT)";
380 INPUT B$
390 C1=0:B1=0
400 IF B$="U" THEN B1=-1
410 IF B$="D" THEN B1=1
420 IF B$="R" THEN C1=1
430 IF B$="L" THEN C1=-1
440 IF B+B1>10 OR B+B1<1 THEN 380
450 IF C+C1>15 THEN 600
460 B=B+B1:C=C+C1
470 IF A(B,C)=64 THEN 800
480 REM ***
490 REM COUNT ADJACENT MINES
500 N=0
510 FOR K=-1 TO 1
520  FOR D=-1 TO 1
530   IF A(B+K,C+D)=64 THEN N=N+1
540  NEXT D
550 NEXT K
560 A(B,C)=48+N
570 M=M+1
580 GOTO 210
590 REM ***
600 REM NEXT LEVEL ROUTINE
610 CLS
620 L=L+1
630 PRINT "CONGRATULATIONS..."
640 PRINT "YOU HAVE CLEARED A PATH THROUGH":PRINT
650 GOSUB 900
710 PRINT
720 PRINT "IT TOOK YOU";M;"MOVES"
730 S=S+100-M
740 PRINT "YOUR SCORE IS";S
750 PRINT "YOU CAN NOW PROGRESS TO LEVEL";L
760 M=0
770 INPUT "PRESS <ENTER> TO CONTINUE";Q$
780 GOTO 80
790 REM ***
800 REM SPLAT
810 PRINT "SPLAT!!!!"
820 PRINT:PRINT "YOU'VE HIT A MINE."
825 PRINT "SCORE:";S+L*10-M
826 GOSUB 900
830 PRINT "GAME OVER"
840 END
900 FOR Y=1 TO 10
910  FOR X=1 TO 15
920   PRINT CHR$(A(Y,X));
930  NEXT X
940  PRINT "#"
950 NEXT Y
960 RETURN

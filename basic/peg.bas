10 REM MUMBLE MARBLE
20 GOSUB 400
30 GOSUB 250
40 REM ACCEPT MOVE
50 PRINT "WHICH MARBLE TO MOVE";
60 INPUT A
70 IF A = 99 THEN GOTO 240
80 IF A<11 OR A>77 THEN GOTO 50
90 IF A(A) <> 79 THEN GOTO 50
100 PRINT A;"TO WHERE";
110 INPUT B
120 IF B<11 OR B>77 THEN GOTO 110
130 IF A(B) <> EMPTY THEN GOTO 110
140 A((A+B)/2)=EMPTY : A(A)=EMPTY : A(B)=79
150 MOVE=MOVE+1
160 COUNT=0
170 FOR F=11 TO 75
180  IF A(F)=79 THEN COUNT=COUNT+1
190 NEXT F
200 GOSUB 250
210 PRINT "MARBLES:";COUNT
220 IF COUNT<>1 THEN GOTO 40
230 IF A(44)=79 THEN PRINT "YOU DID IT, IN JUST";MOVE;"MOVES!":END
240 PRINT "THE GAME IS OVER, AND YOU'VE FAILED!":END
250 REM PRINT OUT
260 CLS
270  PRINT "ENTER SIDE COORDINATE FIRST"
280  PRINT "ENTER 99 TO CONCEDE" : PRINT
290  PRINT "     1 2 3 4 5 6 7"
300  PRINT TAB(5);
310  FOR D=11 TO 75
320   T=10*(INT(D/10))
330   IF D-T=8 THEN D=D+2 : PRINT T/10 : PRINT TAB(5); : GOTO 350
340   PRINT CHR$(A(D));" ";
350  NEXT D : PRINT "     7"
360  PRINT 
370  PRINT "MOVES:";MOVE
390 RETURN 
400 REM INITIALISE
410 CLS
420 DIM A(87)
430 EMPTY=42
440 FOR D=11 TO 75
450  T=10*(INT(D/10))
460  IF D-T=8 THEN D=D+3
470  READ A(D)
480 NEXT D
490 MOVE=0
500 RETURN
510 REM 42 IS ASCII CODE FOR SYMBOL "*"
520 REM 79 IS ASCII CODE FOR LETTER "O"
525 REM 32 IS ASCII CODE FOR SPACE  " "
530 DATA 32,32,79,79,79,32,32
540 DATA 32,32,79,79,79,32,32
550 DATA 79,79,79,79,79,79,79
560 DATA 79,79,79,42,79,79,79
570 DATA 79,79,79,79,79,79,79
580 DATA 32,32,79,79,79,32,32
590 DATA 32,32,79,79,79

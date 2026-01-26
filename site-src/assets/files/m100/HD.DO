10 CLS
20 INPUT "Starting HEX address: ";S$
30 GOSUB 1000
40 IF V = -1 THEN 20
50 HS = V
60 INPUT "Ending HEX address: ";S$
70 GOSUB 1000
80 IF V = -1 THEN 60
90 HE = V
100 IF HS < 0 OR HE > 65535 THEN 110 ELSE GOTO 120
110 BEEP: PRINT "INVALID RANGE ";HS;" to ";HE : GOTO 20
120 IF HS > HE THEN GOTO 110
130 REM print "Screenful at a time?"
140 REM a$ = inkey$ : if a$ = "" then 140
150 REM if a$ = "Y" or a$ = "y" then s1 = 1 else s1 = 0
160 REM
170 REM
180 HL$ = "" : AL$ = ""
190 B = 1 : P = 0
200 FOR I = HS TO HE
210   IF P <> 0 THEN 270
220   D = (HS+B)-1 : PL = 4 : PC$ = "0"
230   GOSUB 3000
240   GOSUB 4000
250   LA$ = S$
260   P = 1
270   HB=PEEK(I)
290   IF HB >= 32 AND HB <= 122 THEN HA$ = CHR$(HB) ELSE HA$ = "."
300   ' hb = peek(i)
310   D = HB : PL = 2 : PC$ = "0"
320   GOSUB 3000
330   GOSUB 4000
340   IF B MOD 8 = 0 THEN 370 ' last byte
350   HL$ = HL$+S$+" " : AL$ = AL$+HA$
360   GOTO 450
370   HL$ = HL$+S$ : AL$ = AL$+HA$
380   P = 0
390   PL = 23 : PC$ = " " : S$ = HL$
400   GOSUB 4000 : HL$ = S$
410   PL = 8 : PC$ = " " : S$ = AL$
420   GOSUB 4000 : AL$ = S$
430   PRINT LA$;": ";HL$;"  ";AL$
440   HL$ = "" : AL$ = ""
450   B = B+1
460 NEXT I
470   PL = 23 : PC$ = " " : S$ = HL$
480   GOSUB 4000 : HL$ = S$
490   PL = 8 : PC$ = " " : S$ = AL$
500   GOSUB 4000 : AL$ = S$
510 PRINT LA$;": ";HL$;"  ";AL$
520 HL$ = "" : AL$ = ""
530 END
540 REM
550 REM
1000 REM CONVERT HEX ADDRESS TO DECIMAL
1010 V = 0 : C = 0
1020 IF LEN(S$) <> 4 THEN 1130
1030 FOR I = 4 TO 1 STEP -1
1040   A$ = MID$(S$,I,1)
1050   A = ASC(A$)
1060   IF A > 70 THEN A = A-32
1070   IF A < 58 THEN A = A-48
1080   IF A > 64 THEN A = A-55
1090   IF A < 0 OR A > 15 THEN 1130
1100   M = 16^C : V = V+(A*M) : C = C+1
1110 NEXT I
1120 GOTO 1140
1130 BEEP: V = -1 : GOTO 1140
1140 RETURN
2000 REM GENERATE A RANDOM between 0 and 255
2010 C = INT(RND(1)*256)
2020 RETURN
3000 REM CONVERT DECIMAL ADDRESS TO HEX
3010 REM d = decimal number
3020 S$ = ""
3030 D0 = D/16 : D1 = INT(D0) : D2 = (D0-D1)*16
3040 IF D2 > 9 THEN D2 = D2+55 : A$ = CHR$(D2) : GOTO 3070
3050 A$ = STR$(D2) : IF LEFT$(A$,1) = " " THEN A$ = RIGHT$(A$,(LEN(A$)-1))
3060 IF SGN(D0) = 0 THEN 3090
3070 S$ = A$+S$
3080 D = D1 : GOTO 3030
3090 RETURN
4000 REM PSTR S$ - str, PL=padlength
4010 REM PC$=padchar
4015 X = PL-LEN(S$) : IF X < 1 THEN 4060
4020 FOR WI = 1 TO X
4030    S$ = PC$+S$
4040 NEXT WI
4060 RETURN

---
layout:	post
title:	Notoriously S.L.O.W BASIC
date:	2022-10-26 00:00:00 -0600
categories:	retro-computing m100 BASIC
---
This week, I spent some time writing code for my m100. On my list of things to do with the little machine, was to write a disassembler. In order to disassemble memory, it helps to know what's there, so I decided to write a memory dump utility first.

<!--more-->

After a bit of thought and planning, I figured I would take a starting location and ending location, in hex, and display those locations line by line, in the form:

`HHHH: HH HH HH HH HH HH HH HH  AAAAAAAA`

Where H is a hex digit, HHHH is a location, HH are hex bytes, and A are ASCII characters. When run, this looks like:

```
0000: 36 B6 21 17 46 00 6A 06  6.!.F.j.
0008: B5 F0 3D 2E 51 E3 A6 26  ..=.Q..&
```

The plan was to loop through the addresses from the start address to the end address, peeking into each memory location and displaying the hex bytes and ascii characters along the way, 8 bytes at a time. Pretty simple, right? Well, not so fast, it turns out PEEK takes a decimal argument, so I needed to write a HEX to DECIMAL converter... and, PEEK returns a decimal value, so I needed to write a DECIMAL to HEX converter... and, old school BASIC lacks a formatted print statement for strings, so I needed a way to format the output, so I decided to write a padding function.
 
After thinking through it a bit more, the strategy for this little app became:

* Ask the user for the start address in HEX
* Convert the HEX to DECIMAL and check bounds
* Ask the user for the end address in HEX
* Convert the HEX to DECIMAL and check bounds
* Check the range
* Loop through memory getting bytes using PEEK
* On each 8th byte or end of the range or memory, display a line with the location and as many bytes as have been collected in HEX and ASCII

Where, we have three subroutines:

* **HEX2DEC** - convert a string of hex digits to decimal in the range 0 to 65535
* **DEC2HEX** - convert a decimal number to hex in the range 0 to FFFF
* **PADSTR** - pad a string of a given length, with a given padding character

Here's the minimally annotated code, with the full file attached below:

## Main Program

### Get Starting Address
Get the starting address and see if it's valid, set HS to the start address

```
10 CLS
20 INPUT "Starting HEX address: ";S$
30 GOSUB 1000
40 IF V = -1 THEN 20
50 HS = V
```

### Get Ending Address

Get the ending address and see if it's valid, set HE to the end address

```
60 INPUT "Ending HEX address: ";S$
70 GOSUB 1000
80 IF V = -1 THEN 60
90 HE = V
```

### Validations

Validate the bounds and range

```
100 IF HS < 0 OR HE > 65535 THEN 110 ELSE GOTO 120
110 BEEP: PRINT "INVALID RANGE ";HS;" to ";HE : GOTO 20
120 IF HS > HE THEN GOTO 110
```

### Implement MORE

I thought I would need a *more* type functionality, but it's so slow, the pause button is sufficient

```
130 REM print "Screenful at a time?"
140 REM a$ = inkey$ : if a$ = "" then 140
150 REM if a$ = "Y" or a$ = "y" then s1 = 1 else s1 = 0
160 REM
170 REM
```

### Loop through the memory

```
180 HL$ = "" : AL$ = ""
190 B = 1 : P = 0
200 FOR I = HS TO HE
```

### Handle Start of Line

If this is the beginning of a line, set the line address to a 4 digit HEX address, padded with 0's

```
210   IF P <> 0 THEN 270
220   D = (HS+B)-1 : PL = 4 : PC$ = "0"
230   GOSUB 3000
240   GOSUB 4000
250   LA$ = S$
260   P = 1
```

### Get the contents of memory at a location (PEEK)

`270   HB=PEEK(I)`

### Handle non-printable characters

Is it a printable character? If so, keep it, otherwise, change it to a "."

```
290   IF HB >= 32 AND HB <= 122 THEN HA$ = CHR$(HB) ELSE HA$ = "."
```

### Cruft

Leftover cruft from when I was using random chars, need to clean up

`300   ' hb = peek(i)`

### Padding

Pad each hex byte to 2 digits with 0's

```
310   D = HB : PL = 2 : PC$ = "0"
320   GOSUB 3000
330   GOSUB 4000
```

### Compose Line

Is this the 8th byte of a line? If so jump ahead, otherwise compose the line where each byte is separated with a space

```
340   IF B MOD 8 = 0 THEN 370 ' last byte
350   HL$ = HL$+S$+" " : AL$ = AL$+HA$
360   GOTO 450
```

### Handle End of Line
Don't add the space while composing

`370   HL$ = HL$+S$ : AL$ = AL$+HA$`

#### reset start of line

`380   P = 0`

### Format the line for display

```
390   PL = 23 : PC$ = " " : S$ = HL$
400   GOSUB 4000 : HL$ = S$
410   PL = 8 : PC$ = " " : S$ = AL$
420   GOSUB 4000 : AL$ = S$
```

### Print the line

```
430   PRINT LA$;": ";HL$;"  ";AL$
440   HL$ = "" : AL$ = ""
450   B = B+1
460 NEXT I
```

### Print the last line

```
470 PL = 23 : PC$ = " " : S$ = HL$
480 GOSUB 4000 : HL$ = S$
490 PL = 8 : PC$ = " " : S$ = AL$
500 GOSUB 4000 : AL$ = S$
510 PRINT LA$;": ";HL$;"  ";AL$
520 HL$ = "" : AL$ = ""
530 END
540 REM
550 REM
```

## HEX2DEC Function

```
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
```

## RANDOM cruft

```
2000 REM GENERATE A RANDOM between 0 and 255
2010 C = INT(RND(1)*256)
2020 RETURN
```

## DEC2HEX Function

```
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
```

## PADSTR Function

```
4000 REM PSTR S$ - str, PL=padlength
4010 REM PC$=padchar
4015 X = PL-LEN(S$) : IF X < 1 THEN 4060
4020 FOR WI = 1 TO X
4030    S$ = PC$+S$
4040 NEXT WI
4060 RETURN
```

It works! What's sad is that this is very, very slow - on the order of 3 seconds per line. So, I'm off to figuring out how to speed it up.

After much discussion and back and forth, here is a fast and efficient best of breed solution that takes advantage of many intricacies of BASIC and the M100 implementation. It was provided by MikeS over on the m100 mailing list at [http://lists.bitchin100.com/listinfo.cgi/m100-bitchin100.com](http://lists.bitchin100.com/listinfo.cgi/m100-bitchin100.com)

```
1 REM Memory Dump 11/2022 Mike Stein V5
10 DEFINTJ-Z:DIMH$(15):FORI=0TO15
15 H$(I)=CHR$(48+I-(7*(I>9))):NEXT:CLS
20 GOSUB200:INPUT"From";A:INPUT"to";B
25 T$=TIME$: FORI=ATOBSTEPW+1
30 IFDTHENPRINT#1,USING"#####";I;:PRINT#1,": ";:GOTO50
35 K=I/4096:PRINT#1,H$(K);
40 L=(I-K*4096):PRINT#1,H$(L\256);
45 PRINT#1,H$((LMOD256)\16)H$(LMOD16)" ";
50 L$="":FORJ=0TOW:X=PEEK(I+J)
55 PRINT#1,H$(X\16);H$(XMOD16)" ";
60 Y$=".":IFX>31ANDX<127THENY$=CHR$(X)
65 L$=L$+Y$:NEXT:PRINT#1,L$:NEXT
70 E$=TIME$:PRINT#1," "T$+" to "+E$
100 T=VAL(MID$(TIME$,4,2))*60+VAL(RIGHT$(TIME$,2))
110 R=VAL(MID$(T$,4,2))*60+VAL(RIGHT$(T$,2))
120 PRINT#1," "T-R" seconds":END
200 D$="H":INPUT"(H)EX or (D)ec address";D$
210 W=7:D=INSTR("dD",D$)>0:B$="88n1e":C$="L"
220 INPUT"(L)CD or (C)om output ";C$
230 IF INSTR("cC",C$)=0THENOPEN"LCD:"FOR OUTPUT AS 1:GOTO260
240 W=15:INPUT"Stat (88N1E)";B$
250 F$="COM:"+B$:OPENF$FOR OUTPUT AS 1
260 RETURN
```

Here is a link to my SLOW DO file:

* Hex Dump - [HD.DO](/assets/files/m100/HD.DO)

*post added 2022-12-08 12:12:00 -0600*

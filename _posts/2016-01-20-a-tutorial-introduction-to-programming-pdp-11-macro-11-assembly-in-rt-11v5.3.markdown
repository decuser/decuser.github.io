---
layout:	post
title:	a-tutorial-introduction-to-programming-pdp-11-macro-11-assembly-in-rt-11v5.3
date:	2016-01-20 10:19:00 -0600
categories:	pdp-11 rt-11 macro-11
---

# A tutorial introduction to programming PDP-11 Macro-11 Assembly in RT-11 v5.3

## Prerequisites

In order to work through this walkthrough, it is necessary to have a working installation of RT-11 v5.3. see [Tutorial - Setting up RT-11 v5.3 on SimH PDP-11 (Dec 30, 2015)]({% post_url 2015-12-30-tutorial-setting-up-rt-11-v5.3-on-simh-pdp-11 %})
 for a tutorial on setting up a working environment.

A quick start version of the setup is available at [Quick Setup RT-11v5.3 (Jan 20, 2016)]({% post_url 2016-01-20-quick-setup-rt-11v5.3-mac-linux %}) Look toward the bottom of the note for a minimalist rendering.


## Sources

This tutorial is derived directly from [AA-5281C-TC Introduction to RT-11 v5.1 1983](http://bitsavers.org/www.computer.museum.uq.edu.au/RT-11/AA-5281C-TC%20Introduction%20to%20RT-11.pdf) and adapted to suit modern readers working in a simulated environment. The narrative follows the introduction to a large extent, but synthesizes an understanding of material contained in the broader set of RT-11 documentation as well.

In particular, the following documents are relevant:

* AA-5281C-TC Introduction to RT-11 v5.1 1983: [http://bitsavers.org/www.computer.museum.uq.edu.au/RT-11/AA-5281C-TC%20Introduction%20to%20RT-11.pdf](http://bitsavers.org/www.computer.museum.uq.edu.au/RT-11/AA-5281C-TC%20Introduction%20to%20RT-11.pdf)
* AA-5279C-TC-RT-11-5.1 System Users Guide 1983: [http://bitsavers.org/www.computer.museum.uq.edu.au/RT-11/AA-5279C-TC%20RT-11%20System%20User's%20Guide.pdf](http://bitsavers.org/www.computer.museum.uq.edu.au/RT-11/AA-5279C-TC%20RT-11%20System%20User's%20Guide.pdf)
* AA-M239B-TC-RT-11-5.1 System Utilities Manual 1984: [http://bitsavers.org/pdf/dec/pdp11/rt11/v5.1_Jul84/AA-M239B-TC_RT-11_System_Utilities_Manual_Jul84.pdf](http://bitsavers.org/pdf/dec/pdp11/rt11/v5.1_Jul84/AA-M239B-TC_RT-11_System_Utilities_Manual_Jul84.pdf)
* AA-V027A-TC-PDP11 MACRO-11 Language Reference Manual 1983: [http://bitsavers.org/pdf/dec/pdp11/rsx11m_s/RSX11M_V4.1_Apr83/4_ProgramDevelopment/AA-V027A-TC_macro11_Mar83.pdf](http://bitsavers.org/pdf/dec/pdp11/rsx11m_s/RSX11M_V4.1_Apr83/4_ProgramDevelopment/AA-V027A-TC_macro11_Mar83.pdf)


## A note on key mapping

The tutorial described will work using either ED or KED as editors. KED is preferred, but requires a key be mapped to the escape sequence [ESC]OP (Escape key followed by the upper case letter O followed by the upper case letter P), as the DEC VT100 Gold Key, and another to the escape sequence [ESC]Ow (Escape followed by upper case O followed by lower case w) as the DEC VT100 Command Key. These escapes can be entered by hand, but mapping them to function keys makes them much easier to manage and remember.

## Overview

The tutorial will consist of a number of discrete steps intended to acquaint the reader with the RT-11 programming environment as well as complete a development workflow using PDP-11 MACRO-11 Assembly language as the language of choice.

Here are the steps:

* Start RT-11
* Create and edit a PDP-11 MACRO Assembly language text file
* Save the edited file to the file system
* Compare the file to a demo file
* Edit the file to closely match the demo file
* Assemble the file
* Fix any assembler errors
* Link the object file
* Fix any linker errors
* Run the program
* Debug the program
* Fix any logic errors
* Repeat steps 6-12 until the program works as desired
* Celebrate a successfully running program by saving the source code for posterity

### Step 1. Start RT-11

If you followed the steps in my tutorial on setting up 5.3, you should be able to change into the rt-11 directory on your disk and start simh by typing:

```
pdp11 boot.ini

RT-11 will boot and something similar to the following will be displayed:

RT-11FB  V05.03

.TYPE V5USER.TXT

                              RT-11 V5.3

       Installation of RT-11 Version 5.3 is complete and you are now
    executing from the working volume    (provided you have used the
    automatic installation procedure). DIGITAL recommends you verify
    the correct  operation  of  your  system's  software  using  the
    verification procedure.  To do this, enter the command:

                             IND VERIFY

        Note that VERIFY should be performed  only after the distri-
    bution media have been backed up.  This was accomplished as part
    of automatic installation on  all  RL02,  RX02,  TK50, and  RX50
    based systems,   including the  MicroPDP-11 and the Professional
    300.  If you have not completed automatic installation, you must
    perform a manual backup before using VERIFY.  Note also,  VERIFY
    is NOT supported on RX01 diskettes,    DECtape I or II,   or the
    Professional 325.

    DIGITAL also  recommends  you  read  the  file V5NOTE.TXT, which
    contains information  formalized too late to be included  in the
    Release Notes.  V5NOTE.TXT can be TYPED or PRINTED.

.
```

This is the dot prompt and is where commands for RT-11 are given. Type `dir/brief` to see a list of your files

```
.dir/brief

SWAP  .SYS    RT11AI.SYS    RT11PI.SYS    RT11BL.SYS    RT11SJ.SYS
RT11FB.SYS    RT11XM.SYS    CR    .SYS    CT    .SYS    DD    .SYS
DL    .SYS    DM    .SYS    DP    .SYS    DS    .SYS    DT    .SYS
...
```

### Step 2. Create and edit a PDP-11 MACRO Assembly language text file


This part of the tutorial depends on how you elected to set up your key mapping. If you assigned keystrokes for the GOLD and COMMAND escape sequences as described in the setup tutorial and referenced above or you are willing to type them in manually as required, you will be able to use KED as the editor (it is the default editor in RT-11 v5.3). Otherwise, read the section of the setup tutorial describing the use of ED as an editor and modify the following instructions accordingly.

The tutorial will revolve around an assembly language program that calculates and prints a mathematical quantity referred to by mathematicians as e (the sum of the reciprocals of the factorials to quote the program's author) to 70 digits of accuracy. The tutorial requires no real math skills although the program is mathematical in nature. The programming workflow will provide needed context as the tutorial develops.

To edit a file in RT-11, type `edit` followed by the name of a file to edit. In this case:

`edit sum.mac`

KED will respond with a file not found prompt, type `Y` and press `enter` to create the file

`?KED-W-File not found - Create it (Y,N)? Y`

Below is the exact text of the SUM.MAC file. It contains a number of intentional errors. It should be typed exactly as shown.

```
 .TITLE SUM.MAC VERSION 1
 .MCALL .TTYOUT, .EXIT, .PRINT

 N = 70.  ;NO. OF DIGITS OF 'E' TO CALCULATE

; 'E' = THE SUM OF THE RECIPROCALS OF THE FACTORIALS
; 1/0! + 1/1! + 1/2! + 1/3! + 1/4! + 1/5! + ...

EXP: .PRINT #MESSAG  ;PRINT INTRODUCTORY TEXT
 MOV #N,R5  ;NO. OF CHARS OF 'E' TO PRINT
FIRST: MOV #N+1,R0  ;NO. OF DIGITS OF ACCURACY
 MOV #A,R1  ;ADDRESS OF DIGIT VECTOR
SECOND: ASL @R1  ;DO MULTIPLY BY 10 (DECIMAL)
 MOV @R1,-(SP) ;SAVE *2
 ASL @R1  ;*4
 ASL @R1  ;*8
 ADD (SP)+,(R1)+ ;NOW *10, POINT TO NEXT DIGIT
 DEC R0  ;AT END OF DIGITS?
 BNE 2ND  ;BRANCH IF NOT
 MOV #N,R0  ;GO THRU ALL PLACES, DIVIDING
THIRD: MOV -(R1),R3 ;BY THE PLACES INDEX
 MOV #-1,R2  ;INIT QUOTIENT REGISTER
FOURTH: INC R2  ;BUMP QUOTIENT
 SUB R0,R3  ;SUBTRACT LOOP ISN'T BAD
 BCC FOURTH  ;NUMERATOR IS ALWAYS < 10*N
 ADD R0,R3  ;FIX REMAINDER
 MOV R3,@R1  ;SAVE REMAINDER AS BASIS
    ;FOR NEXT DIGIT
 ADD R2-2(R1) ;GREATEST INTEGER CARRIES
    ;TO GIVE DIGIT
 DEC R0  ;AT END OF DIGIT VECTOR?
 BNE THIRD  ;BRANCH IF NOT
 MOV -(R1),R0 ;GET DIGIT TO OUTPUT
FIFTH: SUB #10.,R0  ;FIX THE 2.7 TO .7 SO
    ;THAT IT IS ONLY 1 DIGIT
 BCC FIFTH  ;(REALLY DIVIDE BY 10)
 ADD #10+'0,R0 ;MAKE DIGIT ASC II
 .TTYON   ;OUTPUT THE DIGIT
 CLR @R1  ;CLEAR NEXT DIGIT LOCATION
 DEC R5  ;MORE DIGITS TO PRINT?
 BNE FIRST  ;BRANCH IF YES
 .EXIT   ;WE ARE DONE

EXP: .REPT N+1
 .WORD 1  ;INIT VECTOR TO ALL ONES
 .ENDR

MESSAG: .ASCII /THE VALUE OF E IS:/ <15><12> /2./ <200>
 .EVEN

 .ENDEXP
```

### Step 3. Save the edited file to the file system

When you are finished editing the file, save and exit the editor. This is accomplished by pressing `GOLD-COMMAND` and typing `EXIT` followed py pressing `ENTER`. If you mapped GOLD to F1 and COMMAND to say, F5, then press `F1` then `F5` and the prompt Command: will appear as the top line of the edit window. Type `EXIT` and press `ENTER` to exit. If you want to quit without saving the contents, press `GOLD-COMMAND` and type `QUIT` followed by `ENTER` at the Command: prompt. KED will respond with the message:

`?KED-W-Output files purged`

If you are using a Mac, the function keys are accessed by pressing the Fn key while also pressing the desired function key. So, if mapped, GOLD is Fn-F1 and COMMAND is Fn-F5. ENTER is Fn-RETURN.

If you have a numeric keypad, it is probably not necessary to map any additional keys. Gold is the top-left key on the keypad, Command is the number 7, and ENTER is the enter key on the keypad.

### Step 4. Compare the file to a demo file

RT-11 comes with a file named DEMOX1.MAC that contains a nearly identical version of the SUM.MAC file. In order to match the demo file as closely as possible, you will need to compare your file with the demo file. The command in RT-11 that compares two files is differences. For the purposes of this demo, you will supply differences with the argument match:1 which informs the differences utility to only require 1 line to agree as a match.

Type `differences/match:1 demox1.mac sum.mac` to compare the demo file to your file:

```
.diff/match:1 demox1.mac sum.mac
1) DK:DEMOX1.MAC
2) DK:SUM.MAC
**********
1)1  .TITLE EXAMP.MAC (VERSION PROVIDED)
1)
1)  .MCALL .TTYOUT, .EXIT, .PRINT
****
2)1  .TITLE SUM.MAC VERSION 1
2)  .MCALL .TTYOUT, .EXIT, .PRINT
**********
1)1  BNE SECOND  ;BRANCH IF NOT
1)  MOV #N,R0  ;GO THRU ALL PLACES, DIVIDING
****
2)1  BNE 2ND  ;BRANCH IF NOT
2)  MOV #N,R0  ;GO THRU ALL PLACES, DIVIDING
**********
1)1  ADD #10+'0,R0 ;MAKE DIGIT ASCII
1)  .TTYON   ;OUTPUT THE DIGIT
****
2)1  ADD #10+'0,R0 ;MAKE DIGIT ASC II
2)  .TTYON   ;OUTPUT THE DIGIT
**********
1)1  .END EXP
****
2)1  .ENDEXP
**********
?SRCCOM-W-Files are different

.
```

There are 4 differences between the demo file provided by the rt-11 distribution and the typed in version shown in the output from the differences command:

1. EXAMP.MAC (VERSION PROVIDED) <> SUM.MAC VERSION 1
2. SECOND <> 2ND
3. ASCII <> ASC II
4. END EXP <> ENDEXP

### Step 5. Edit the file to closely match the demo file

Edit the source to match the contents of the demo file with the exception of the .TITLE line. After your edits run the differences/match:1 command and check that no significant differences remain.

```
.differences/match:1 demox1.mac sum.mac
1) DK:DEMOX1.MAC
2) DK:SUM.MAC
**********
1)1  .TITLE EXAMP.MAC (VERSION PROVIDED)
1)
1)  .MCALL .TTYOUT, .EXIT, .PRINT
****
2)1  .TITLE SUM.MAC VERSION 1
2)  .MCALL .TTYOUT, .EXIT, .PRINT
**********
?SRCCOM-W-Files are different
```

If the title was also edited and no differences were found the results would appear as follows:

```
.differences/match:1 demox1.mac sum.mac
?SRCCOM-I-No differences found
```

### Step 6. Assemble the file

The command to assemble the assembly language file is MACRO. Use the form shown below to ensure that all errors are marked including undefine symbols that may be externally defined but not specified with the .MCALL directive. This command also includes options to create a listing file and a cross reference.

```
macro/disable:gbl sum/list/cross
?MACRO-E-Errors detected:  6
DK:SUM,DK:SUM/C=DK:SUM/D:GBL
```

### Step 7. Fix any assembler errors

The output shows that there were 6 errors. To see what the errors are, look at the listing file produced by the macro command:

```
.type sum.lst
SUM.MAC VERSION 1 MACRO V05.03b  02:00  Page 1

      1      .TITLE SUM.MAC VERSION 1
      2      .MCALL .TTYOUT, .EXIT, .PRINT
      3
      4  000106     N = 70.  ;NO. OF DIGITS OF 'E' TO CALCULATE
      5
      6     ; 'E' = THE SUM OF THE RECIPROCALS OF THE FACTORIALS
      7     ; 1/0! + 1/1! + 1/2! + 1/3! + 1/4! + 1/5! + ...
      8
M     9 000000    EXP: .PRINT #MESSAG  ;PRINT INTRODUCTORY TEXT
     10 000006 012705  000106    MOV #N,R5  ;NO. OF CHARS OF 'E' TO PRINT
     11 000012 012700  000107   FIRST: MOV #N+1,R0  ;NO. OF DIGITS OF ACCURACY
U    12 000016 012701  000000    MOV #A,R1  ;ADDRESS OF DIGIT VECTOR
     13 000022 006311    SECOND: ASL @R1  ;DO MULTIPLY BY 10 (DECIMAL)
     14 000024 011146     MOV @R1,-(SP) ;SAVE *2
     15 000026 006311     ASL @R1  ;*4
     16 000030 006311     ASL @R1  ;*8
     17 000032 062621     ADD (SP)+,(R1)+ ;NOW *10, POINT TO NEXT DIGIT
     18 000034 005300     DEC R0  ;AT END OF DIGITS?
     19 000036 001371     BNE SECOND  ;BRANCH IF NOT
     20 000040 012700  000106    MOV #N,R0  ;GO THRU ALL PLACES, DIVIDING
     21 000044 014103    THIRD: MOV -(R1),R3 ;BY THE PLACES INDEX
     22 000046 012702  177777    MOV #-1,R2  ;INIT QUOTIENT REGISTER
     23 000052 005202    FOURTH: INC R2  ;BUMP QUOTIENT
     24 000054 160003     SUB R0,R3  ;SUBTRACT LOOP ISN'T BAD
     25 000056 103375     BCC FOURTH  ;NUMERATOR IS ALWAYS < 10*N
     26 000060 060003     ADD R0,R3  ;FIX REMAINDER
     27 000062 010311     MOV R3,@R1  ;SAVE REMAINDER AS BASIS
     28         ;FOR NEXT DIGIT
AR   29 000064 066167  000000  000000'  ADD R2-2(R1) ;GREATEST INTEGER CARRIES
     30         ;TO GIVE DIGIT
     31 000072 005300     DEC R0  ;AT END OF DIGIT VECTOR?
     32 000074 001363     BNE THIRD  ;BRANCH IF NOT
     33 000076 014100     MOV -(R1),R0 ;GET DIGIT TO OUTPUT
     34 000100 162700  000012   FIFTH: SUB #10.,R0  ;FIX THE 2.7 TO .7 SO
     35         ;THAT IT IS ONLY 1 DIGIT
     36 000104 103375     BCC FIFTH  ;(REALLY DIVIDE BY 10)
     37 000106 062700  000070    ADD #10+'0,R0 ;MAKE DIGIT ASCII
U    38 000112 000000     .TTYON   ;OUTPUT THE DIGIT
     39 000114 005011     CLR @R1  ;CLEAR NEXT DIGIT LOCATION
     40 000116 005305     DEC R5  ;MORE DIGITS TO PRINT?
     41 000120 001334     BNE FIRST  ;BRANCH IF YES
     42 000122     .EXIT   ;WE ARE DONE
     43
M    44 000124 000107    EXP: .REPT N+1
     45      .WORD 1  ;INIT VECTOR TO ALL ONES
     46      .ENDR
     47
     48 000342    124     110     105  MESSAG: .ASCII /THE VALUE OF E IS:/ <15><12> /2./ <200>
 000345    040     126     101
 000350    114     125     105
 000353    040     117     106
 000356    040     105     040
 000361    111     123     072
 000364    015     012     062
 000367    056     200
     49      .EVEN
     50

SUM.MAC VERSION 1 MACRO V05.03b  02:00  Page 1-1

D    51  000000'    .END EXP

SUM.MAC VERSION 1 MACRO V05.03b  02:00  Page 1-2
Symbol table

A     = ******    FIRST   000012R   MESSAG  000342R   SECOND  000022R   .TTYON= ******
EXP     000000R   FOURTH  000052R   N     = 000106    THIRD   000044R   ...V1 = 000003
FIFTH   000100R

. ABS. 000000    000 (RW,I,GBL,ABS,OVR)
       000372    001 (RW,I,LCL,REL,CON)
Errors detected:  6

*** Assembler statistics

Work  file  reads: 0
Work  file writes: 0
Size of work file: 9363 Words  ( 37 Pages)
Size of core pool: 12800 Words  ( 50 Pages)
Operating  system: RT-11

Elapsed time: 00:00:00.02
DK:SUM,DK:SUM/C=DK:SUM/D:GBL

SUM.MAC VERSION 1 MACRO V05.03b  02:00 Page S-1
Cross reference table (CREF V05.03)

...V1    1-9
.TTYON   1-38
A        1-12
EXP      1-9#     1-44#    1-51
FIFTH    1-34#    1-36
FIRST    1-11#    1-41
FOURTH   1-23#    1-25
MESSAG   1-9      1-48#
N        1-4#     1-10     1-11     1-20     1-44
SECOND   1-13#    1-19
THIRD    1-21#    1-32

SUM.MAC VERSION 1 MACRO V05.03b  02:00 Page M-1
Cross reference table (CREF V05.03)

...CM5   1-9
.EXIT    1-2#     1-42
.PRINT   1-2#     1-9
.TTYOU   1-2#

SUM.MAC VERSION 1 MACRO V05.03b  02:00 Page E-1
Cross reference table (CREF V05.03)

A        1-29
D        1-51
M        1-9      1-44
R        1-29
U        1-12     1-38

.
```

Because you asked for a listing and a crossreference, a listing file was generated that includes a listing of your program and a set of cross reference tables in the file SUM.LST. The file is composed of five sections:

1. Machine code listing (Page 1-1) with assembly error codes, line numbers, relative memory addresses, machine code, source code and comments
2. Symbol table list of user defined symbols (Page 1-2), their locations and whether or not they are relocatable, and assembly statistics
3. Cross reference table of user defined symbols (Page S-1) showing the locations where each symbol is defined or used
4. Cross reference table of macro symbols (Page M-1) showing the location where each symbol is defined or used
5. Cross reference table of assembly errors (Page E-1) showing the error code and location of each error type

The cross reference on Page E-1 of the listing is an alphabetized list of the errors by type. It is useful as a summary, but it is easier to refer back to the source code listing (Page 1-1) to see the errors in context. The error code for each error appears at the left hand margin.

Here are the six offending lines:

```
M     9 000000    EXP: .PRINT #MESSAG  ;PRINT INTRODUCTORY TEXT
U    12 000016 012701  000000    MOV #A,R1  ;ADDRESS OF DIGIT VECTOR
AR   29 000064 066167  000000  000000'  ADD R2-2(R1) ;GREATEST INTEGER CARRIES
U    38 000112 000000     .TTYON   ;OUTPUT THE DIGIT
M    44 000124 000107    EXP: .REPT N+1
D    51  000000'    .END EXP
```


See Table 12-6, pp 12-12 - 12-13. [AA-M239B-TC-RT-11-5.1-System Utilities Manual-1984](http://bitsavers.org/pdf/dec/pdp11/rt11/v5.1_Jul84/AA-M239B-TC_RT-11_System_Utilities_Manual_Jul84.pdf) or Appendix D of [AA-V027A-TC-PDP11 MACRO-11 Language Reference Manual](http://bitsavers.org/pdf/dec/pdp11/rsx11m_s/RSX11M_V4.1_Apr83/4_ProgramDevelopment/AA-V027A-TC_macro11_Mar83.pdf) for the complete listing of error codes. These are the codes occurring above:

* **A** - General assembly error
* **D** - Doubly defined symbol referenced. Reference was made to a symbol which is defined more than once.
* **M** - Multiple definition of a label. A label was encountered which was equivalent (in the first six characters) to a label previously encountered.
* **R** - Register-type error. An invalid use of or reference to a register has been made, or an attempt has been made to redefine a standard register symbol without first issuing the .DSABL REG directive.
* **U** - Undefined symbol. The assembler assigns the undefined symbol a constant zero value.

#### First Error

The first error, on line 9, is a multiply defined label. To determine where else it may be defined and if there are more than one label multiply defined, look at the cross reference on page E-1. Any lines listed after M are multiply defined. By this, it is apparent that there are only two definitions that overlap, line 9 and line 44.

```
M     9 000000    EXP: .PRINT #MESSAG  ;PRINT INTRODUCTORY TEXT
M    44 000124 000107    EXP: .REPT N+1
```

Sure enough EXP is defined twice.

#### Second Error

The second error, on line 12, is an undefined symbol.

`U    12 000016 012701  000000    MOV #A,R1  ;ADDRESS OF DIGIT VECTOR`

The undefined symbol is A and the comment suggests that it is the address of the digit vector.

#### Third Error

The third error, on line 29, is both a general assembly error and register-type error.

`AR   29 000064 066167  000000  000000'  ADD R2-2(R1) ;GREATEST INTEGER CARRIES`

This appears to be a syntax error related to the use of registers. There are two ways to know this, first the source and destination are all zeros, and second, the registers are incorrectly referenced in the assembly. ADD is a two operand instruction and R2-2(R1) appears to be a single operand.

#### Fourth Error

The fourth error, on line 38, is an undefined symbol.

`U    38 000112 000000     .TTYON   ;OUTPUT THE DIGIT`

The undefined symbol is .TTYON, the comment suggests that it is a macro to output a digit, and if you look in table M-1 of the listing file, you will see a macro named TTYOU referenced.

`.TTYOU   1-2#`

Looking at the .MCALL directive on line 2, it is apparent that .TTYON is a typo and that the correct macro should be .TTYOUT.

#### Fifth Error

The fifth error, on line 44, is related to the first error and is discussed above.

#### Sixth Error

The sixth and final error, on line 51, is a doubly defined symbol referenced error and is related to the first and fifth errors. Whereas those lines both defined the label EXP. This line references EXP.

`D    51  000000'    .END EXP`

#### Summary of the edits

In summary, the 6 errors appear to require three edits:

1. EXP is multiply defined. The first definition appears to be the correct definition as it marks the start of the program and is the correct argument to the .END directive on line 51. The second definition, on line 44, needs to be changed from EXP. Recall that the second error concerns an undefined symbol A, that is the address of a digit vector, and looking at line 44 it appears to be a vector of digits. Therefore, it makes sense to change the second definition to A.

	Line 44 becomes:

	`A: .REPT N+1`


	This one edit should fix four of the errors - lines 9, 12, 44, and 51 (first, second, fifth and sixth of the list above).

2. The next edit concerns the register syntax error. The correct syntax requires a comma to separate the source and destination operands:

	`ADD R2,-2(R1)`


3. The last edit concerns the MACRO typo, .TTYON, which should be .TTYOUT. Note, that without /disable:gbl, this typo would go unnoticed until a link was attempted because the assembler would assume that any undefined symbol was defined outside of the current file. See the note at the bottom of this text to see what would happen.

	Make the three corrections and retry the assembler.

	`.macro/disable:gbl sum/list/crossreference`

### Step 8. Link the object file

Since there were no errors reported during the compilation, it is time to link the file. Linking the file converts the OBJ file created by the assembler into an executable file. The executable SAV file that the linker generates contains information about where in memory to load the file. The link command you will use includes an argument to generate a MAP file that shows the memory locations of your program as they will be when the program runs. To link the file, type link sum/map.

`.link sum/map`

### Step 9. Fix any linker errors

All of the errors should be fixed unless you made a mistake typing, comparing, and fixing the assembly language presented above, or if you did not specify the /disable:gbl argument to the MACRO command. If you receive an error, go back and compare your results to those above. Proceed when you no longer have any errors.

### Step 10. Run the program

Run the resulting .sav file:

```
.r sum
THE VALUE OF E IS:
2.5/606/606237.2301314.06525/130440275535025.71477737352744745405502.544
.
```

The result looks funky, slashes and multiple decimal points in the output do not appear to be correct. The problem, at this point, is a logic bug. In order to track it down will require the services of a debugger, or further analysis of the source code.

The value should be:

`2.7182818284590452353602874713526624977572470936999595749669676277240766`

### Step 11. Debug the program

Here is an updated listing based on the edits you have made:

```
.type sum.lst
SUM.MAC VERSION 1 MACRO V05.03b  02:08  Page 1

      1      .TITLE SUM.MAC VERSION 1
      2      .MCALL .TTYOUT, .EXIT, .PRINT
      3
      4  000106     N = 70.  ;NO. OF DIGITS OF 'E' TO CALCULATE
      5
      6     ; 'E' = THE SUM OF THE RECIPROCALS OF THE FACTORIALS
      7     ; 1/0! + 1/1! + 1/2! + 1/3! + 1/4! + 1/5! + ...
      8
      9 000000    EXP: .PRINT #MESSAG  ;PRINT INTRODUCTORY TEXT
     10 000006 012705  000106    MOV #N,R5  ;NO. OF CHARS OF 'E' TO PRINT
     11 000012 012700  000107   FIRST: MOV #N+1,R0  ;NO. OF DIGITS OF ACCURACY
     12 000016 012701  000124'   MOV #A,R1  ;ADDRESS OF DIGIT VECTOR
     13 000022 006311    SECOND: ASL @R1  ;DO MULTIPLY BY 10 (DECIMAL)
     14 000024 011146     MOV @R1,-(SP) ;SAVE *2
     15 000026 006311     ASL @R1  ;*4
     16 000030 006311     ASL @R1  ;*8
     17 000032 062621     ADD (SP)+,(R1)+ ;NOW *10, POINT TO NEXT DIGIT
     18 000034 005300     DEC R0  ;AT END OF DIGITS?
     19 000036 001371     BNE SECOND  ;BRANCH IF NOT
     20 000040 012700  000106    MOV #N,R0  ;GO THRU ALL PLACES, DIVIDING
     21 000044 014103    THIRD: MOV -(R1),R3 ;BY THE PLACES INDEX
     22 000046 012702  177777    MOV #-1,R2  ;INIT QUOTIENT REGISTER
     23 000052 005202    FOURTH: INC R2  ;BUMP QUOTIENT
     24 000054 160003     SUB R0,R3  ;SUBTRACT LOOP ISN'T BAD
     25 000056 103375     BCC FOURTH  ;NUMERATOR IS ALWAYS < 10*N
     26 000060 060003     ADD R0,R3  ;FIX REMAINDER
     27 000062 010311     MOV R3,@R1  ;SAVE REMAINDER AS BASIS
     28         ;FOR NEXT DIGIT
     29 000064 060261  177776    ADD R2,-2(R1) ;GREATEST INTEGER CARRIES
     30         ;TO GIVE DIGIT
     31 000070 005300     DEC R0  ;AT END OF DIGIT VECTOR?
     32 000072 001364     BNE THIRD  ;BRANCH IF NOT
     33 000074 014100     MOV -(R1),R0 ;GET DIGIT TO OUTPUT
     34 000076 162700  000012   FIFTH: SUB #10.,R0  ;FIX THE 2.7 TO .7 SO
     35         ;THAT IT IS ONLY 1 DIGIT
     36 000102 103375     BCC FIFTH  ;(REALLY DIVIDE BY 10)
     37 000104 062700  000070    ADD #10+'0,R0 ;MAKE DIGIT ASCII
     38 000110     .TTYOUT   ;OUTPUT THE DIGIT
     39 000114 005011     CLR @R1  ;CLEAR NEXT DIGIT LOCATION
     40 000116 005305     DEC R5  ;MORE DIGITS TO PRINT?
     41 000120 001334     BNE FIRST  ;BRANCH IF YES
     42 000122     .EXIT   ;WE ARE DONE
     43
     44 000124 000107    A: .REPT N+1
     45      .WORD 1  ;INIT VECTOR TO ALL ONES
     46      .ENDR
     47
     48 000342    124     110     105  MESSAG: .ASCII /THE VALUE OF E IS:/ <15><12> /2./ <200>
 000345    040     126     101
 000350    114     125     105
 000353    040     117     106
 000356    040     105     040
 000361    111     123     072
 000364    015     012     062
 000367    056     200
     49      .EVEN
     50

SUM.MAC VERSION 1 MACRO V05.03b  02:08  Page 1-1

     51  000000'    .END EXP

SUM.MAC VERSION 1 MACRO V05.03b  02:08  Page 1-2
Symbol table

A       000124R   FIFTH   000076R   FOURTH  000052R   N     = 000106    THIRD   000044R
EXP     000000R   FIRST   000012R   MESSAG  000342R   SECOND  000022R   ...V1 = 000003

. ABS. 000000    000 (RW,I,GBL,ABS,OVR)
       000372    001 (RW,I,LCL,REL,CON)
Errors detected:  0

*** Assembler statistics

Work  file  reads: 0
Work  file writes: 0
Size of work file: 9363 Words  ( 37 Pages)
Size of core pool: 12800 Words  ( 50 Pages)
Operating  system: RT-11

Elapsed time: 00:00:00.02
DK:SUM,DK:SUM/C=DK:SUM/D:GBL

SUM.MAC VERSION 1 MACRO V05.03b  02:08 Page S-1
Cross reference table (CREF V05.03)

...V1    1-9      1-38
A        1-12     1-44#
EXP      1-9#     1-51
FIFTH    1-34#    1-36
FIRST    1-11#    1-41
FOURTH   1-23#    1-25
MESSAG   1-9      1-48#
N        1-4#     1-10     1-11     1-20     1-44
SECOND   1-13#    1-19
THIRD    1-21#    1-32

SUM.MAC VERSION 1 MACRO V05.03b  02:08 Page M-1
Cross reference table (CREF V05.03)

...CM5   1-9      1-38
.EXIT    1-2#     1-42
.PRINT   1-2#     1-9
.TTYOU   1-2#     1-38

.
```

Before jumping into the debugger. Here is a cheat sheet for the debugger

ODT - Online Debugging Technique Cheat Sheet

* **CTRL-J** - linefeed - Close the currently open location and open the next sequential location for examination and possible modification.  
* **RET** - return - Close the currently open location.  
* **addr/** - address followed by a slash - Open the location indicated (addr) for examination and possible modification.  
* **addr;G** - address semicolon G - Begin program execution at the indicated address (addr).  
* **;P** - semicolon P - Continue program execution from a previous breakpoint.  
* **addr;nB** - address semicolon number B - Set one of the eight available breakpoints (n) at the indicated address (addr).  
* **;nB** - semicolon number B - Cancel the indicated breakpoint (n).  
* **;B** - semicolon B - Cancel all breakpoints. 
* **addr;nR** - address semicolon number R - Set one of eight available relocation registers (n) to the relocation constant value indicated by addr.  
* **$n** - dollar sign number - Open one of the eight general registers (n) for examination and possible modification.  
* **@** - at sign - Use the contents of the currently open location as an address; close the currently open location; if possible, convert the value to an ASCII code and print the corresponding character on the terminal.  
* **;nS** - semicolon number S - Enables single instruction mode (n can be any digit and serves only to distinguish this form from the form ;S which disables single step mode). Breakpoints are disabled.  
* **n;P** - Proceeds with program run for next n instructions before reentering ODT.  

#### Preparing for debugging

To use the debugger, it is necessary to link the OBJ file produced by the assembler with ODT (Online Debugging Technique, or debugger for short). The LINK command has a debug argument that accomplishes this:

`.link sum/map/debug`

Since assembly in RT-11 produces relocatable code, you need to look at the map before running the program in the debugger. The map is located in the file SUM.MAP:

```
.type sum.map
RT-11 LINK  V08.10  Load Map    Page 1
SUM   .SAV    Title: ODT    Ident: V05.08 

Section  Addr Size Global Value Global Value Global Value

 . ABS.  000000 001000 = 256.   words  (RW,I,GBL,ABS,OVR)
   .ODT   000010 
   001000 000372 = 125.   words  (RW,I,LCL,REL,CON)
 $ODT$   001372 006172 = 1597.  words  (RW,I,LCL,REL,CON)
   O.ODT  001624 ..GVAL 002074 

Transfer address = 001624, High limit = 007562 = 1977.  words


.
```

This map shows the sizes of the program and odt. It also shows that the program will load into memory address 1000 and the debugger will load into memory location 1624. If the program is run, ODT will start. This is by design (link with debug), but the program can be run and ODT bypassed with:

```
get sum
start 1000
```

otherwise, to run with ODT, just run the program:

`run sum`


#### Start the debugger

As noted previously, ODT is linked with the program and will start automatically if the program is simply run.

```
.run sum

 ODT V05.08
*
```

The asterisk is the ODT prompt and it is waiting for commands. To exit, type `CTRL-C`.

```
* ^C

.
```

The terminal prints ^C and returns to the dot prompt. Restart the program:

```
.run sum

 ODT V05.08
*
```

#### View the machine code of a program

The file SUM.MAP shows that the program will be relocated to address 001000. SUM.LST contains the machine code instructions for the program beginning at relative address 000000. Here are a few of the instructions from the listing:

```
      9 000000    EXP: .PRINT #MESSAG  ;PRINT INTRODUCTORY TEXT
     10 000006 012705  000106    MOV #N,R5  ;NO. OF CHARS OF 'E' TO PRINT
     11 000012 012700  000107   FIRST: MOV #N+1,R0  ;NO. OF DIGITS OF ACCURACY
     12 000016 012701  000124'   MOV #A,R1  ;ADDRESS OF DIGIT VECTOR
     13 000022 006311    SECOND: ASL @R1  ;DO MULTIPLY BY 10 (DECIMAL)
```

In ODT, it is possible to view any location in memory. To view the contents of memory, just type the memory location followed by a forward slash:

`000000/`


ODT will open the memory location and display its current value immediately after the forward slash followed by a space and the cursor will blink waiting for a command. It is possible to respond in several different ways to this prompt. For now, a carriage return will close the memory location. Location 000000 is not part of the program, so it will be of limited interest at this point.

The program begins at offset 001000. The first instruction is at 001000, but it is a macro and its disassembly isn't shown by default in the listing. The first line of the program that is not a macro, is loaded into memory at location 001006:

At the asterisk prompt type:

`001006/`


ODT responds with the contents of that location:

`/012705`

This is the same machine code that appears in the listing above and corresponds to the assembly two operand MOV opcode. ODT simply prints the contents of memory and waits for input. To continue listing consecutive memory locations, type `CTRL-j` (the linefeed character) as many times as you like.

```
001012 /012700
001014 /000107
001016 /012701
001020 /001124
001022 /006311
*
```

These bits match exactly with those in the listing:

```
     10 000006 012705  000106    MOV #N,R5  ;NO. OF CHARS OF 'E' TO PRINT
     11 000012 012700  000107   FIRST: MOV #N+1,R0  ;NO. OF DIGITS OF ACCURACY
     12 000016 012701  000124'   MOV #A,R1  ;ADDRESS OF DIGIT VECTOR
     13 000022 006311    SECOND: ASL @R1  ;DO MULTIPLY BY 10 (DECIMAL)
```

Any location within the program can be viewed in this manner. Take this line of the listing:

 `40 000116 005305     DEC R5  ;MORE DIGITS TO PRINT?`

To view this location, add the starting offset 001000 to the absolute address of the instruction as listed:

`001116/`


ODT repsonds with the contents:

`005305`

#### Initialize the relocation register

Adding the start of program offset each time a memory location is desired is tedious. ODT allows the user to set up to eight different offsets. This is done by using the `addr;nR` command:

`001000;0R`

will set the first relocation register to the address 001000.

To use the relocation register, prefix an address with the index of the register followed by a comma, as follows:

`*0,000006`


or more succinctly

`*0,6`


ODT will respond as before and using `CTRL-J` to view sequential addresses will produce similar results:

```
/012705
0,000010 /000106
0,000012 /012700
0,000014 /000107
0,000016 /012701
0,000020 /001124
0,000022 /006311
*
```

#### Execute your program

The command to execute the program is addr;G and can be specified using absolute addressing:

```
*1000;G
THE VALUE OF E IS:
2.5/606/606237.2301314.06525/130440275535025.71477737352744745405502.544
```

This runs the program from beginning to end and exits ODT.

To return to ODT, rerun the program (whenever control is returned to the dot prompt during debugging, simply rerun the program to reenter ODT and remember to set the relocation register appropriately).

`run sum`

Alternatively, the program can be executed using relocation register based addressing if the relocation register has been set:

```
*1000;0R
*0,0;G
THE VALUE OF E IS:
2.5/606/606237.2301314.06525/130440275535025.71477737352744745405502.544
```

#### Setting breakpoints

In order to get under the covers of the SUM program and find the logic error, it is necessary to stop the program during its execution and to observe the execution environment. Breakpoints are the mechanism for stopping program execution and can be set using the addr;nB command. For example to set a breakpoint at the first non-macro program line (remember to set the relocation register - 1000;0R):

`0,6;0B`

This tells ODT to set a breakpoint at location 10006 so that execution will stop when the program counter contains the value 001006, the address of the first non-macro line.

To begin executing the program use the addr;G command:

```
*0,0;G
THE VALB0;0,000006
```

ODT runs the program until it hits the breakpoint. It then displays the address and offset of the current instruction (B0;0,000006). The characters that are displayed before the address are part of MESSAG "THE VALUE OF E IS:". The output is printed with lower priority than ODT and will be interrupted and interspersed with ODT output as a result.

To confirm that the breakpoint is the value in the program counter, simply display the value of the program counter (PC, or register 7 on the PDP):

`*$7/`

ODT will display the value of the register:

`001006`

Hit `return` to close the PC (a memory location) and return to the asterisk prompt.

This breakpoint is fairly uninteresting as the program hasn't done anything other than printed a message. Looking at the source code, address 000022 looks like a good place to put a breakpoint. At that point, R5 should contain the number of chars of e to print, R0 should have the accuracy, R1 should contain the address of A:

`*0,22;1B`

In order to continue executing the program, the `n;P` command is given, the n is optional. Leaving it off is similar to the G command:

`*;P`

Execution continues until the end of the program, or until a breakpoint is hit. In this case, the breakpoint at 0,22 is hit:

```
UEB1;0,000022
*
```

Some more of the print message is displayed, followed by B1;0,000022. The PC contains 1022:

`* $7/`


ODT responds:

`001022`


Register 5 contains 106 octal, which is 70 decimal, as specified in the listing:

`4  000106     N = 70.  ;NO. OF DIGITS OF 'E' TO CALCULATE`


To see what register 5 contains, type $5/ - dollar sign 5 forward slash:

`*$5/`


ODT responds with the value contained in register 5:

`000106`


This is as expected. Register 0 should contain 107 octal, 71 decimal, also as specified in the listing:

`11 000012 012700  000107   FIRST: MOV #N+1,R0  ;NO. OF DIGITS OF ACCURACY`


From this point onward, the memory display command will be shown on the same line as the output from ODT to conserve space and to more accurately reflect what is displayed onscreen. To see what is in register 0 type $0/:

`*$0/000107`


Register 1 contains 001124 which is the location in memory where A resides. Here is the source and the results of viewing the contents of the register:

```
12 000016 012701  000124'   MOV #A,R1  ;ADDRESS OF DIGIT VECTOR

*$1/001124
```

To view the contents of the memory location that is currently being displayed (before pressing any other keys after forward slash), type an @ sign. This will display the contents of the memory at location 1124, which is the vector of words that A refers to:

```
*$1/001124 @
0,000124 /000001
```

The value 000001 is exactly what is expected given the source lines:

```
44 000124 000107    A: .REPT N+1
     45      .WORD 1  ;INIT VECTOR TO ALL ONES
     46      .ENDR
```

which initialize the 107 (octal) or 71 (decimal) words beginning at location A (1124). Pressing `CTRL-J` several more times will reveal that, indeed, the memory is initialized to all 1's:

```
*$1/001124 @
0,000124 /000001
0,000126 /000001
0,000130 /000001
0,000132 /000001
*
```

Adding (107 * 2) to A's address of 1124 results in the address of the next word of memory following the vector of digits (1342 octal, or the address of MESSAG).

`48 000342    124     110     105  MESSAG: .ASCII /THE VALUE OF E IS:/ <15><12> /2./ <200>`

To see that memory location, begin by looking a few words prior and use CTRL-J to see the contents:

```
*0,000336 /000001
0,000340 /000001
0,000342 /044124
0,000344 /020105
*
```

So, it would seem that indeed, the memory starting at A is initialized to 1's up until the memory starting at MESSAG.

#### View memory location as ASCII

The value displayed for memory location 342 onward is in octal digits on a word boundary. The PDP stores 2 characters of ASCII data per word of memory.

Octal numbers can be converted to binary by converting each octal digit to three binary bits representing the quantities 0-7 as follows:

>0 - 000  
>1 - 001  
>2 - 010  
>3 - 011  
>4 - 100  
>5 - 101  
>6 - 110  
>7 - 111  

It is important to note that word boundaries and byte boundaries are not the same thing. Word boundaries are located at bits 0 and 15. A word consists of two bytes, a low byte and a high byte. The low byte boundaries are located at bits 0 and 7, and the high byte boundaries are located at bits 8 and 15.

Visually, this looks like this:

```
15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
^^                     |                     ^^ Word boundaries
^^                   ^^|^^                   ^^ Byte boundaries
  \----High Byte-----/   \------Low Byte------/
```

So, the value at 342, 044124 can be converted to a 16 bit binary number as follows:

```
0   4   4   1   2   4
0 100 100 001 010 100
```

If the conversion is word based, this is all that is required. However, this is a byte based conversion, so an additional step is required and that is to divide the bits on byte boundaries:

`0 100 100 001 010 100`


is divided into byte boundaries of eight bits each:

`0 100 100 0 | 01 010 100`


and regrouped to make the conversion back to octal easier:

```
01 001 000 | 01 010 100
 1   1   0 |  1   2   4
```

This indicates that the first two characters of MESSAG are octal 124, 'T' and 110, 'H' (bytes are displayed in least significant byte first order (little endian).

An easier method to find these values is to use the ODT command, \ - backslash when prompted after using the / - forward slash to open a memory location. Once the backslash is in effect, it will remain in effect until all memory locations are closed.

Open the MESSAG memory location:

`*0,342/044124`


Type `\` rather than `return` or `CTRL-J`:

`\`

ODT will respond with the converted byte of the open location as well as the ASCII character corresponding to the octal value:

`124 =T`


Press `CTRL-J` several times to see the characters following T:

```
0,000343 \110 =H
0,000344 \105 =E
0,000345 \040 =
0,000346 \126 =V
0,000347 \101 =A
0,000350 \114 =L
0,000351 \125 =U
0,000352 \105 =E
0,000353 \040 =
0,000354 \117 =O
0,000355 \106 =F
0,000356 \040 =
0,000357 \105 =E
0,000360 \040 =
0,000361 \111 =I
0,000362 \123 =S
0,000363 \072 =:
*
```

Nifty, eh?

#### Working with breakpoints

To see what instruction would be executed next, simply display the contents of PC, register 7:

`* $7/1022`


This is right where we broke before looking at the environment. To see what breakpoints are active, look at the breakpoint list in memory, accessible as $B - dollar sign B:

`* $B/001022`


Pressing `CTRL-J` a few times shows that the rest of the breakpoints are not set to locations within the program and are effectively unset:

```
0,000540 /007562
0,000542 /007562
0,000544 /007562
0,000546 /007562
0,000550 /007562
0,000552 /007562
```

If the program were to proceed at this point, it would continue execution until it ended or hit the one active breakpoint at 1022 again.

Allow the program to proceed a few times:

```
*;P
UEB0;0,000022
*;P
 OB0;0,000022
*;P
F B0;0,000022
*;P
E B0;0,000022
*
```

Look at the A vector contents again:

```
*0,124/000012
0,000126 /000012
0,000130 /000012
0,000132 /000012
0,000134 /000001
*
```

Hmmm. What is going on here? Let's look at the code to see what is happening:

```
     13 000022 006311     SECOND: ASL @R1  ;DO MULTIPLY BY 10 (DECIMAL)
     14 000024 011146     MOV @R1,-(SP) ;SAVE *2
     15 000026 006311     ASL @R1  ;*4
     16 000030 006311     ASL @R1  ;*8
     17 000032 062621     ADD (SP)+,(R1)+ ;NOW *10, POINT TO NEXT DIGIT
     18 000034 005300     DEC R0  ;AT END OF DIGITS?
     19 000036 001371     BNE SECOND  ;BRANCH IF NOT
```

It would appear that 22-36 is a loop that multiplies the vector pointed to by R1 (starts at A). After looping several times as above, 1134 is the next memory location to be multiplied by 10 (decimal) and should be in R1:

`*$1/001134`

Sure enough, the vector starting at memory location 1124 (A) is being multiplied by 10 decimal.

Instead of continuing to repeat this loop until it is done. Delete the existing breakpoint at 1022:

`* ;0B`


and set a new one further on in the program and continue. Say, just following this loop, 1040:

```
* 0,40;0B
*;P
IS:
2.B0;0,000040
```

Confirm that the entire A vector has been multiplied by 10 decimal by looking at the last few words prior to MESSAG:

```
*0,336/000012
0,000340 /000012
0,000342 /044124
*
```

All breakpoints can be cleared using ;B without a number:

```
*;B
*
```

To single in ODT, use the `;1S` command to enter single step mode and `;P` to proceed a step:

```
*;1S
*;P
B8;0,000044
```

Confirm that the source line:

`20 000040 012700  000106    MOV #N,R0  ;GO THRU ALL PLACES, DIVIDING`

was properly executed by examining R0:

`*$0/000106`

Looks good. Rather than single stepping through the entire program, exit single step mode:

`*;S`

Set a breakpoint at the TTYOUT statement where the result will be printed and proceed:

```
38 000110     .TTYOUT   ;OUTPUT THE DIGIT
*0,112;0B
*;P
5B0;0,000112
```

At this point in the program's execution, register 0, should contain, the next digit of the result (the first digit following the decimal). Since E is approximately, 2.71828, register 0 should contain 7:

`* $0/000065`

oh, it should contain the ASCII code for 7, which is 000067. Obviously, it's wrong, but go ahead and use the `\` command to see for yourself:

`*$0/000065 \065 =5`


5 is not 7, so where to look to find out why? Interestingly, this result is in line with what was displayed when the program was run to completion earlier:

`2.5/606/606237.2301314.06525/130440275535025.71477737352744745405502.544`


So, the problem does not appear to be an issue of display. It is displaying what it is given. So the error must have occurred somewhere after the vector multiplication and before the call to `.TTYOUT`. In order to debug code that has been executed previously and ensure that the environment is set up properly requires exiting ODT with `CTRL-C`:

```
*^C

.
```

and restarting the program:

```
.run sum

 ODT V05.08
*
```

resetting the relocation register:

```
*1000;0R
*
```

and establishing the new breakpoint. In this case backing up to where the results of the division is 'fixed up' for outputting a single digit and setting a breakpoint at memory location 1076:

```
*0,76;0B

*0,0;G
THE VALUE OF E IS:
2.B0;0,000076
```

R0 should now contain the value 27, 2.7 previously multiplied by 10:

`*$0/000033`


Sure enough, 33 octal is 27 decimal. Logically, the problem is between 76 and 112. Look at the code and see if a logical error can be seen, or set another breakpoint:

```
34 000076 162700  000012   FIFTH: SUB #10.,R0  ;FIX THE 2.7 TO .7 SO
     35         ;THAT IT IS ONLY 1 DIGIT
     36 000102 103375     BCC FIFTH  ;(REALLY DIVIDE BY 10)
     37 000104 062700  000070    ADD #10+'0,R0 ;MAKE DIGIT ASCII
     38 000110     .TTYOUT   ;OUTPUT THE DIGIT
```

After the FIFTH loop, memory location 1104 looks like a good candidate:

```
*0,104;0B
*;P
B0;0,000104
```

Look at R0:

`*$0/177775`

That seems remarkably uninformative, but actually, it's a negative number in 2's complement (It's negative 3). If -3 is added to 10, it should yield 7 which is the correct answer. But wait, the code says add 10 (octal) to -3, 10 octal is 8 decimal, which yields 5. **There is the bug**!

Single step to see the math done:

```
*;1S
*;P
B8;0,000110
*$0/000065 \065 =5
```

That's the bug in action. Looking at the source:

`ADD #10+'0,R0`

It is clear that the code should read:

`ADD #10.+'0,R0`

or

`ADD #12+'0,R0`

to achieve the desired result. However, it is possible to test the hypothesis above, by changing the contents of R0, before calling .TTYOUT. This is accomplished by opening the memory location, in this case, R0, and typing a new value for it before closing it by pressing return:

`*$0/000065 000067`

exit single step mode and proceed:

```
*;S
*;P
7B0;0,000104
```

There is the 7 we expected. This bug is **almost dead**!

Let's try something *ill advised*, changing the memory location that contains our program itself. Here is the offending line of code again:

`37 000104 062700  000070    ADD #10+'0,R0 ;MAKE DIGIT ASCII`

The byte at 000106 should be 000072, not 000070. Let's change it and run the program to completion. This should fix the bug for this run of the program. Go ahead and exit ODT, restart, make the edit and rerun:

```
* ^C

.

.run sum

 ODT V05.08
*1000;0R
*0,106/000070 000072
*0,0;G
THE VALUE OF E IS:
2.7182818284590452353602874713526624977572470936999595749669676277240766
.
```

Success!

## Step 12. Fix any logic errors aka Making permanent change

In order to make the change **permanent** requires that the source code be edited, the change made, the program reassembled and relinked:

`edit SUM.MAC`

change the line to read:

`ADD     #10.+'0,R0`

Assemble the corrected file:

```
.macro/disable:gbl sum/list/cross

.link sum/map

.run sum
THE VALUE OF E IS:
2.7182818284590452353602874713526624977572470936999595749669676277240766
.
```

**Woohoo!** E is indeed approximately (to seventy digits anyway) equal to `2.7182818284590452353602874713526624977572470936999595749669676277240766`.

### Step 13. Repeat steps 6-12 until the program works as desired

Just keep cycling through the steps above until your code is working.

### Step 14. Celebrate a successfully running program by saving the source code for posterity

Any time you get a piece of code to work, or maybe even mostly work, you should copy it to a safe location or better yet check it into a source code repository like git.

My approach for this simulated environment is two pronged:

1. Copy SUM.MAC to another volume (if you followed the setup tutorial, you will have a second disk image loaded).
2. Copy SUM.MAC to the host system and check it into git.

To add another disk to the simulation, in your boot.ini, add:

```
set rl1 rl02
attach rl1 storage.dsk
```

To initialize the disk (don't do this if you have files on the disk already) and to assign a shortcut name for the device:

```
.initialize dl1:
DL1:/Initialize; Are you sure? Y

.assign dl1: vol:

.dir vol:


 0 Files, 0 Blocks
 20382 Free blocks

.
```

Note, the assignment only lasts as long as you are logged in. To make it permanent, add it to the start up command file. If you are running the default monitor - RT-11FB V05.03, the startup file is STARTF.COM.

#### Copying the file to another volume is accomplished by the following:

```
.copy SUM.MAC VOL:
 Files copied:
DK:SUM.MAC     to VOL:SUM.MAC

.dir vol:

SUM   .MAC     3
 1 Files, 3 Blocks
 20379 Free blocks

.
```

Directories are different in RT-11. The current directory always seems to be the system volume, where the commands reside. It does not appear to be possible to change directory. However another directory can be the target for various commands including COPY. So the volume can be used for storage and retrieval of files.

If you do not have or want to have an additional storage volume, simply copy the file to a file with another name on the same volume:

`copy SUM.MAC SUM.ORI`


Note: you are limited to 6 characters for the file name and 3 characters for the extension. Be wise!

#### Copy and paste - terminal window method

To copy the file to the host system, there are many approaches. I will present some in order of simplicity. If you are using a version of SimH newer than November, 2015, you can use the simplest method, copy and paste:

```
.type SUM.MAC
...
the contents of the file
...
```

Simply copy the contents of the terminal window with your host system's copy functionality, open a text file in a non-translating editor (textwrangler or notepad or somesuch), and paste the contents into the editor. Save the file locally.

The LPT device - line printer method

If your boot.ini file contains the line:

`attach LPT lpt.txt`

Then you can simply print the file from RT-11 and it will become magically available in the file lpt.txt (after pausing the simulator using `CTRL-E`, restart by typing `c` at the `sim>` prompt).

This is done using the PRINT commmand:

`print SUM.MAC`


Note: The resulting file will contain formfeed characters appropriate for printing the file to a line printer (or laser printer for that matter). If you print the file, the file will print as it would have ages ago in RT-11 (if you print listing files, choose landscape mode before you print). This method is good for printing files from RT-11, but it is not an exact copy method.

#### The PC device - paper tape punch method

Printing files introduces print formatting to the files. It is also a one-way transport, from RT-11 to the host. The simplest method of two-way transfer is to use copy and paste as previously described. This works well for text files, but is not ideal for binary files. Another method of file transfer that is simple, yet capable of supporting other formats is the Paper Tape Reader and Punch method described below.

In your boot.ini, you will need the two lines:

```
attach PTR ptr.txt
attach PTP ptp.txt
```

RT-11 supports the paper tape reader and paper tape punch devices as PC:.

To copy a file from RT-11 to the host, just copy it:

```
copy SUM.MAC PC:
 Files copied:
DK:SUM.MAC     to PC:

.
```

Then pause the simulator using `CTRL-E` and viewing the file ptp.txt in an editor (or typing `sim>! cat ptp.txt` at the `sim>` prompt

To copy a file from the host to RT-11 (say you edited SUMFIX.MAC on your host and wanted to copy it into RT-11), just copy the file SUMFIX.MAC over ptr.txt, pause the simulation using CTRL-E and attaching the ptr.txt file again:

```
. ^E
Simulation stopped, PC: 152650 (BEQ 152636)
sim> att PTR ptr.txt
sim> c

.copy PC: SUMFIX.MAC
 Files copied:
PC:            to DK:SUMFIX.MAC

.
```

Note: watch out for tab-space conversions - ugh!

### Bonus section - linker errors?

If the demo compared program is assembled without the argument /disable:gbl, it will assemble with .TTYON as an undefined global, but when you try to link, you will get an error:

```
link sum/map
?LINK-W-Undefined globals:
.TTYON

.type sum.lst
SUM.MAC VERSION 1 MACRO V05.03b  02:24  Page 1

      1      .TITLE SUM.MAC VERSION 1
      2      .MCALL .TTYOUT, .EXIT, .PRINT
      3
      4  000106     N = 70.  ;NO. OF DIGITS OF 'E' TO CALCULATE
      5
      6     ; 'E' = THE SUM OF THE RECIPROCALS OF THE FACTORIALS
      7     ; 1/0! + 1/1! + 1/2! + 1/3! + 1/4! + 1/5! + ...
      8
      9 000000    EXP: .PRINT #MESSAG  ;PRINT INTRODUCTORY TEXT
     10 000006 012705  000106    MOV #N,R5  ;NO. OF CHARS OF 'E' TO PRINT
     11 000012 012700  000107   FIRST: MOV #N+1,R0  ;NO. OF DIGITS OF ACCURACY
     12 000016 012701  000122'   MOV #A,R1  ;ADDRESS OF DIGIT VECTOR
     13 000022 006311    SECOND: ASL @R1  ;DO MULTIPLY BY 10 (DECIMAL)
     14 000024 011146     MOV @R1,-(SP) ;SAVE *2
     15 000026 006311     ASL @R1  ;*4
     16 000030 006311     ASL @R1  ;*8
     17 000032 062621     ADD (SP)+,(R1)+ ;NOW *10, POINT TO NEXT DIGIT
     18 000034 005300     DEC R0  ;AT END OF DIGITS?
     19 000036 001371     BNE SECOND  ;BRANCH IF NOT
     20 000040 012700  000106    MOV #N,R0  ;GO THRU ALL PLACES, DIVIDING
     21 000044 014103    THIRD: MOV -(R1),R3 ;BY THE PLACES INDEX
     22 000046 012702  177777    MOV #-1,R2  ;INIT QUOTIENT REGISTER
     23 000052 005202    FOURTH: INC R2  ;BUMP QUOTIENT
     24 000054 160003     SUB R0,R3  ;SUBTRACT LOOP ISN'T BAD
     25 000056 103375     BCC FOURTH  ;NUMERATOR IS ALWAYS < 10*N
     26 000060 060003     ADD R0,R3  ;FIX REMAINDER
     27 000062 010311     MOV R3,@R1  ;SAVE REMAINDER AS BASIS
     28         ;FOR NEXT DIGIT
     29 000064 060261  177776    ADD R2,-2(R1) ;GREATEST INTEGER CARRIES
     30         ;TO GIVE DIGIT
     31 000070 005300     DEC R0  ;AT END OF DIGIT VECTOR?
     32 000072 001364     BNE THIRD  ;BRANCH IF NOT
     33 000074 014100     MOV -(R1),R0 ;GET DIGIT TO OUTPUT
     34 000076 162700  000012   FIFTH: SUB #10.,R0  ;FIX THE 2.7 TO .7 SO
     35         ;THAT IT IS ONLY 1 DIGIT
     36 000102 103375     BCC FIFTH  ;(REALLY DIVIDE BY 10)
     37 000104 062700  000070    ADD #10+'0,R0 ;MAKE DIGIT ASCII
     38 000110 000000G    .TTYON   ;OUTPUT THE DIGIT
     39 000112 005011     CLR @R1  ;CLEAR NEXT DIGIT LOCATION
     40 000114 005305     DEC R5  ;MORE DIGITS TO PRINT?
     41 000116 001335     BNE FIRST  ;BRANCH IF YES
     42 000120     .EXIT   ;WE ARE DONE
     43
     44 000122 000107    A: .REPT N+1
     45      .WORD 1  ;INIT VECTOR TO ALL ONES
     46      .ENDR
     47
     48 000340    124     110     105  MESSAG: .ASCII /THE VALUE OF E IS:/ <15><12> /2./ <200>
 000343    040     126     101
 000346    114     125     105
 000351    040     117     106
 000354    040     105     040
 000357    111     123     072
 000362    015     012     062
 000365    056     200
     49      .EVEN
     50

SUM.MAC VERSION 1 MACRO V05.03b  02:24  Page 1-1

     51  000000'    .END EXP

SUM.MAC VERSION 1 MACRO V05.03b  02:24  Page 1-2
Symbol table

A       000122R   FIRST   000012R   MESSAG  000340R   SECOND  000022R   .TTYON= ****** GX
EXP     000000R   FOURTH  000052R   N     = 000106    THIRD   000044R   ...V1 = 000003
FIFTH   000076R

. ABS. 000000    000 (RW,I,GBL,ABS,OVR)
       000370    001 (RW,I,LCL,REL,CON)
Errors detected:  0

*** Assembler statistics

Work  file  reads: 0
Work  file writes: 0
Size of work file: 9363 Words  ( 37 Pages)
Size of core pool: 12800 Words  ( 50 Pages)
Operating  system: RT-11

Elapsed time: 00:00:00.02
DK:SUM,DK:SUM/C=DK:SUM

SUM.MAC VERSION 1 MACRO V05.03b  02:24 Page S-1
Cross reference table (CREF V05.03)

...V1    1-9
.TTYON   1-38
A        1-12     1-44#
EXP      1-9#     1-51
FIFTH    1-34#    1-36
FIRST    1-11#    1-41
FOURTH   1-23#    1-25
MESSAG   1-9      1-48#
N        1-4#     1-10     1-11     1-20     1-44
SECOND   1-13#    1-19
THIRD    1-21#    1-32

SUM.MAC VERSION 1 MACRO V05.03b  02:24 Page M-1
Cross reference table (CREF V05.03)

...CM5   1-9
.EXIT    1-2#     1-42
.PRINT   1-2#     1-9
.TTYOU   1-2#

.
```

Stuff to consider:

```
      2      .MCALL .TTYOUT, .EXIT, .PRINT
     38 000110 000000G    .TTYON   ;OUTPUT
```

Page S-1 lists user defined symbols and where they appear.

`.TTYON   1-38`


Page M-1 lists macro defined symbols and where they apper.

`.TTYOU   1-2#`


It appears that .TTYON should be .TTYOUT, as the comment ";OUTPUT THE DIGIT" suggests.

Edit and retry assembly and linkage.

This is the end of the tutorial. I hope you have learned a lot about the developer workflow for assembly language programming in the almost-ancient PDP-11 MACRO-11 assembly language of the RT-11 v5.3 world. It is remarkably similar to modern assembly, with a few little quirks thrown in to make it interesting.

*post added 2022-12-01 10:27:00 -0600*

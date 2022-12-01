---
layout:	post
title:	analysis-of-the-pdp-11-bootstrap-loader-code
date:	2015-12-21 16:34:00 -0600
categories:	pdp-11 analysis
---

# Analysis of the PDP-11 bootstrap loader code

This note describes, in detail, how the bootstrap loader code operates. While it is only 14 words, it is not trivial to understand. The bootstrap loader is self-modifying code

The note is a work in progress. It begins by describing the first iteration where the loader loads a single byte from the tape reader. In this case the byte is octal 351, which is the first byte of the absolute loader and is the tape leader byte. Octal 351, when read by the bootstrap loader has the effect of causing the boot strap loader to overwrite a portion of itself that results in no change to its memory contents. Any other value, when read will cause the bootstrap loader to begin copying bytes into a memory location prior to the bootstrap loader itself and continuing to copy bytes until the bootstrap loader overwrites itself with the contents of the loaded program. Programs that are bootstrap loader programs contain a footer that restores they original bytes of the bootstrap loader except for the starting location.

The language I use below needs further refinement, but it should adequately explain what's going on to the reader.
 
Numbers are in octal unless otherwise specified. That is, 6 + 2 = 10. The program counter is normally incremented by 2 after the CPU reads each word. When an instruction has an operand or when both of its operands refer to register 7, the PC register, the PC itself is incremented for each operand that refers to it. This means that if the source operand uses the PC, PC is incremented 2 as the next word is decoded, and if the destination uses the PC, PC is incremented another 2 as the next word is decoded.

To get started, this how the analysis will proceed, using a nonsense bit of code:

```
 1  10000  012703          MOV 201,R3
 2  10002  000201
 3  10004  012767          MOV (PC)+,PLACE
 4  10006  000033
 5  10010  000002
 6  10012  000000          HALT 
 7  10014  000000  PLACE:  .WORD 000000
```

Lines 1-2

The PC starts at 10000 and the CPU reads in the instruction at location 10000.

012703 decodes into:

> 01 is the double operand MOV instruction
> 
> 27 specifies that the source operand is located immediately following the current PC.
> 03 is the destination register, R3
> 
> 000201 is the immediate source operand

Therefore, lines 1-2 move the value 201 into R3.

I will not describe the rest of the program above at this time. However, I will describe how the PC is incremented in additional detail using the above code. As the CPU reads the program from memory, it automatically increments the PC. When it reads a word, it increments the PC by 2, when it reads a byte, it increments it by 1. In the program above the process looks like this:

> PC->10000 - The CPU starts with the PC set to 10000, the beginning of the program. It reads 012703 and decodes the instruction. The PC is incremented by 2.
>
> PC->10002 - The CPU reads the source operand 000201 and puts it into the destination. The PC is incremented by 2.
>
>PC->10004 - The CPU reads 012767 and decodes the instruction MOV (PC)+, PLACE. The PC is incremented by 2.
>
>PC->10006 - The CPU reads the source operand 000033. The PC is incremented by 2.
>
>PC->10010 - The CPU reads the PC relative offset 000002. The PC is incremented. The CPU adds the offset to the updated PC, and puts the source into the memory location that is found (10012 + 4 = 10014 aka PLACE:).
>
>PC->10012 - The CPU reads 000000 and decodes the instruction HALT. The PC is incremented by 2. The CPU halts.
>
>PC->10014

In the following discussion, the PC is mentioned, but not described in this level of detail. Keep in mind that anytime an operand is relative to the PC, that the value of the PC will have already been incremented as the operand is read. So, any math will need to be performed against the new value.

Let's begin the analysis of the bootstrap loader.

Here is the raw source of the bootstrap loader configured for an 8K word machine:

``
016701
000026
012702
000352
005211
105711
100376
116162
000002
037400
005267
177756
000765
177550
```

Here are the bytes of the Absolute Loader, a very useful program that comes on paper tape that is useful for loading programs that are punched to tape in absolute loader format. This is the program that will serve as the source for the following analysis. It is the file being read from paper tape by the bootstrap loader:

```
od -b DEC-11-L2PC-PO.ptap
0000000   351 351 351 075 000 000 306 021 246 051 305 021 305 145 112 000
0000020   001 012 316 027 170 377 016 014 002 207 016 012 003 001 316 014
0000040   001 002 116 020 000 012 315 011 303 212 374 002 315 011 367 011
0000060   074 000 002 021 302 345 004 000 302 045 002 000 041 003 367 011
0000100   054 000 204 143 001 021 315 011 004 004 300 213 353 003 000 000
0000120   351 001 321 220 370 001 303 035 152 000 213 212 313 213 376 200
0000140   303 234 002 000 300 140 303 105 000 377 302 012 207 000 267 025
0000160   046 000 315 011 304 020 315 011 303 000 304 120 307 035 030 000
0000200   367 011 352 377 315 011 300 213 342 002 204 014 002 206 000 000
0000220   300 001 304 014 204 143 114 000 000 000 367 025 352 000 020 000
0000240   367 025 365 001 034 000 167 000 132 377 301 035 026 000 302 025
0000260   373 353 000 000 000 000 000
0000267
```

Here is the source of the bootstrap loader configured for an 8K word machine, as it might appear in memory along with some helpful line numbers, labels, and assembly instructions:

```
 1  037744  016701  START:       MOV CSR,R1
 2  037746  000026
 3  037750  012702  LOOP:        MOV (PC)+,R2
 4  037752  000352  PTR:         .WORD 352
 5  037754  005211               INC (R1)
 6  037756  105711  WAIT:        TSTB (R1)
 7  037760  100376               BPL WAIT
 8  037762  116162               MOVB 2(R1),37400(R2)
 9  037764  000002
10  037766  037400
11  037770  005267               INC PTR
12  037772  177756
13  037774  000765  BRNCH:       BR LOOP
14  037776  177550  CSR:         .WORD 177550
```

This section of the analysis will iterate once through the main program loop, reading a single byte from the source tape, a 351, which is a leader byte, from the tape device.

Lines 1-2

Memory location 037744 is labeled START: and is where the bootstrap program is loaded into memory (in this example)
016701 disassembles as follows:
> 01 is a double operand MOV instruction
> 
> 67 specifies that the source is given relative to the updated PC
>
> 01 is the destination register, R1
> 
> 000026 is the octal offset added to the PC to obtain the source address.
> 
> 037750 = 037776, which is the memory location labeled CSR: Memory location CSR: contains 177550, which is the location of the Paper Tape Reader(PTR) status register

Therefore, lines 1-2 move the address of the PTR status register into R1

Lines 3-4

Memory location 037750 is labeled LOOP: and is the top of the program loop

Memory location 037752 is labeled PTR: and contains the offset to the location where read bytes are to be loaded

012702 disassembles as follows:

> 01 is a double operand MOV instruction
>
> 27 specifies that the source is given immediately following the current instruction
> 
> 02 is the destination register, R2
> 
> 000352 is the immediate operand being stored in R2

Therefore, lines 3-4 move octal 000352 into R2

Line 5

005211 disassembles as follows:

> 0052 is the single operand INC instruction
> 
> 11 specifies the destination is located at the address contained in R1
> 
> R1 contains the address of the PTR status register

Therefore, line 5 increments the PTR status register. This causes the PTR to begin reading bytes.

Line 6

Memory location 037756 is labeled WAIT: and is the top of a wait for data from the PTR loop

105711 disassembles as follows:

> 1057 is the single operand TSTB instruction
>
> 11 specifies the destination is located at the address contained in R1
> 
> R1 contains the address of the PTR status register
> 
> TSTB tests the PTR status register low byte and sets the N(egative) or Z(ero) flags based on the contents of the PTR status register, it also clears V and C (overflow and carry) flags.
> 
> The PTR status register bit 0 is the read bit, already set by the previous operation.
> 
> The PTR status register bit 7 is the done bit, it will be set by the reader when it has transferred a byte from tape into the data register.

Therefore, line 6 tests the contents of the PTR status register and sets the N flag when done is detected and data is ready to be transferred from the PTR data register.

Line 7

100376 disassembles as follows:

> 1000 specifies the BPL instruction
> 
> 376 specifies the offset to branch to

This instruction requires additional explanation... The high 8 bits are the OP code, the low 8 bits are an offset. In this case, 376 is 11111110 in binary. This is a negative number. To convert it into a useable number, take the one's compliment and add one to the result. The one's complement can be obtained by switching all 1's for 0's and all 0's for 1's. The process is:

```
  3   7   6 - original octal offset
 11 111 110 - binary equivalent
 00 000 001 - one's complement
          1 - add one
-----------
 00 000 010 - binary result
         -2 - negative offset in octal

```
The BPL instruction causes a branch to offset + new PC (PC+2) if the N flag's cleared.

Therefore, line 7 branches to location 037760 - 2 = 037756 (which is memory location WAIT:, Line 6) if the N flag is cleared, otherwise, it continues to Line 8. The N flag is cleared when a byte has been read from the PTR into the PTR data register.

Line 8-10

116162 disassembles as follows:

> 11 is the double operand MOVB instruction
>
> 61 specifies that the address of the operand is obtained by adding the next word as an offset to  R1
> 
> 62 specifies that the address of the operand is obtained by adding the next word after the source word as an offset to R2
> 
> R1 contains the address of the PTR status register
> 
> R2 contains 000352
> 
> 000002 is the R1 offset, the source is located at 177550 + 2, which is the PTR data register
> 
> 037400 is the R2 offset, the destination is located at 037400+000352 = 037752, which is PTR:

Therefore, lines 8-10 move a byte from the PTR data register into the memory location PTR:. In the case of the absolute loader, the first byte is 351. This is a byte representing the tape leader.

Lines 11-12

005267 disassembles as follows

> 0052 is the single operand INC instruction
> 
> 67 specifies The address of the destination operand is relative to the updated PC
> 177756 is the destination operand. It happens to be a negative number in two's complement representation. Adding it to the PC is accomplished as follows:

```
   1 111 111 111 101 110 177756 (Offset)
+  0 011 111 111 111 100 037774 (Updated PC)
   ----------------------------
   0 011 111 111 101 010 037752
```

> 037752 is the memory location labeled PTR:

Therefore, lines 11-12 increment PTR, which in the case of the first iteration, contains the tape leader byte, 351, which after incrementation becomes 352 (the original contents of memory location PTR).

Line 13

000765 disassembles as follows

> 0001 is the unconditional BR instruction (high eight bits of the word)
> 
> 365 is the offset, actually (2 * Offset), to branch to relative to the updated PC (low eight bits). That is, the high 8 bits are the OP code, the low 8 bits are an offset. In this case, the offset 365 is a negative offset represented in two's complement. To add the offset to the updated PC, the offset byte is sign extended to 16 bits and multiplied by 2, shifting it left once, then it is added directly to the updated PC:

```
  3   6   5 - original octal offset
 11 110 101 - binary equivalent
 00 001 010 - one's complement
          1 - add one
-----------
 00 001 011 - binary result
     -1   3 - negative offset in octal

 1 111 111 111 101 010 - 365 sign extended and shifted left 
 0 011 111 111 111 110 - 037776, the updated PC
 ---------------------
 0 011 111 111 101 000 - 037750
```

> 037750 is the memory location labeled LOOP:

Therefore line 13 branches unconditionally to the top of the loop, LOOP:.

Line 14

Line 14 is not executed. It contains the address of the PTR status register.


After a single pass through the program, reading octal 351, the program has modified itself, but only to its original state (moved 351 into PTR and incremented back to 352). However, as soon as the program reads a byte other than 351, everything changes.

The next byte read from the absolute boot loader tape is 351, then 351, then 075! When the PTR becomes 075 and is incremented after line 11, the code in memory, looks like this and branches to line 3 the top of the loop:

```
 1  037744  016701  START:       MOV CSR,R1
 2  037746  000026
 3  037750  012702  LOOP:        MOV (PC)+,R2
 4  037752  000076  PTR:         .WORD 76
 5  037754  005211               INC (R1)
 6  037756  105711  WAIT:        TSTB (R1)
 7  037760  100376               BPL WAIT
 8  037762  116162               MOVB 2(R1),37400(R2)
 9  037764  000002
10  037766  037400
11  037770  005267               INC PTR
12  037772  177756
13  037774  000765  BRNCH:       BR LOOP
14  037776  177550  CSR:         .WORD 177550
```

The following is a condensed analysis of the process that unfolds once a value other than 351 is read from the paper tape:

> lines 3-4: the new displacement, 000076, is stored in R2
> 
> lines 5-7: wait loop until another data byte is read and available in the PTR data register
> 
> lines 8-10: store the read byte into the memory location referenced by 037400 + the new displacement, 000076
> 
> lines 11-12: increment the displacement to 000077, etc.
> 
> line 13: branch to line 3

The program continues to load consecutive bytes into memory beginning with the incremented displacement (076) read from tape. The absolute loader consists of 166(10) or 246(8) bytes of data following the 075 byte. This is followed by an 8 byte footer that overlays the bootstrap loader and provides a new jump offset . Doing the math, this means that memory locations 037476-037744 are filled byte by byte from the bytes read from tape.

The footer is read and processed in a rather interesting way. The first two instructions overlay the bootstrap loader:

```
016701
000026
012702
```

But then the lower byte of the displacement is modified to become 373, is incremented and added to 037400, giving 037474, and becomes the target of the next byte, 353. This results in the bootstrap loader at this point appearing as follows:

```
 1  037744  016701  START:       MOV CSR,R1
 2  037746  000026
 3  037750  012702  LOOP:        MOV (PC)+,R2
 4  037752  000373  PTR:         .WORD 373
 5  037754  005211               INC (R1)
 6  037756  105711  WAIT:        TSTB (R1)
 7  037760  100376               BPL WAIT
 8  037762  116162               MOVB 2(R1),37400(R2)
 9  037764  000002
10  037766  037400
11  037770  005267               INC PTR
12  037772  177756
13  037774  000753  BRNCH:       BR LOOP
14  037776  177550  CSR:         .WORD 177550
```

Line 13 is executed resulting in an unconditional branch to PC+2 + (2*Offset, 353):

```
  1 111 111 111 010 110 - 353 sign extended and shifted left
+ 0 011 111 111 111 110 - 037776 the updated PC
 -----------------------
  0 011 111 111 010 100 - 037724
```
The memory locations 037724-037742 (instruction just prior to the bootstrap loader contains the following, I've added line numbers and assembly to suit:

```
 1  037724  012767  MOV 352,20(PC)
 2  037726  000352
 3  037730  000020
 4  037732  012767  MOV 765,34(PC)
 5  037734  000765
 6  037736  000034
 7  037740  000167  JMP 177532
 8  037742  177532
```

> Lines 1-3 move 352 into memory location 037732 + 20, 037752, which is labeled PTR: This restores PTR to its original value of 352.
>
>Lines 4-6 move 765 into memory location 037740 + 34, 037774, which is the byte containing the BR offset. This restores the BR offset to its original value of 765.

At this point, the bootstrap loader code has been fully restored.

> Lines 7-8 jump the CPU to the location obtained by adding the updated PC to 177532. 177532 is a negative offset that will be added to 37744

```
   1 111 111 101 011 010 - 177532
 + 0 011 111 111 100 100 - 37744
 -----------------------
   0 011 111 100 111 110 - 37476
```

The contents of 37476 are:

```
ex 37476
 1  37476:    000000  HALT
```

The bootstrap loader stops and is ready to execute the instruction loaded at 37500, which is the first instrurction of the absolute loader.

The analysis of the operation of the absolute loader is left for another day.

*post added 2022-11-30 12:29:00 -0600*
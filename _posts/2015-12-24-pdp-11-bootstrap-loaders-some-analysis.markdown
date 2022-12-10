---
layout:	post
title:	PDP-11 Bootstrap loaders - some analysis
date:	2015-12-24 17:20:00 -0600
categories:	pdp-11
---
This note provides some short analyses of several of the PDP-11 bootstrap loaders used to install the Research Unix Sixth edition. It is a work in progress...

<!--more-->

Each bootstrap loader described below is presented without much explanation in Setting Up Unix - Sixth edition, in Unix Programmer's Manual Sixth Edition Volume II, by K. Thompson and D.M. Ritchie, 1975.
 
## Resources
The following are resources that are available on bitsavers or elsewhere. The documents are extremely well written and are invaluable sources of technical information. However, they do require multiple readings to truly appreciate. The helpful folks on the SimH and TUHS mailing lists are also great resources and I appreciate their willingness to help poor retrocomputing hobbyists. Without their help, this sort of exploration would be much more painful.

* Setting Up Unix - Sixth edition, in Unix Programmer's Manual Sixth Edition Volume II, by K. Thompson and D.M. Ritchie, 1975 - This little document is critical for installing Unix Sixth Edition and is the source of the following loaders, but it does not describe the programs or their function in any detail.
 
* PDP-11 Programming Card for the Family of PDP-11 Computers, 1975 - This is a most terse reference, but very handy once you understand it. It provides a quick reference for the PDP-11 addressing modes, instruction set, memory layout, and bootstrap loaders.


* PDP-11/40 Processor Handbook, 1972 - This is a pretty terse reference too, but indispensable once you get it.
> Chapter 3, Addressing Modes, Section 3.7 Summary of Addressing Modes
> 
> Chapter 4, Instruction Set, Section 4.3 List of Instructions

* PDP-11 Peripherals Handbook, 1976 - This is a pretty straightforward book.
> Chapter 2 Programming
>
>Chapter 3 Categories of Peripherals, Section 3.7 and 3.8 Magnetic Tape and Disks
>
>Chapter 4 Descriptions of Peripherals, Section 4.3
>
>List of Peripherals, PC11/PR11 High Speed Paper Tape Reader/Punch PC11, RK11/RK05 Decpack Disk Cartridge RK11-D, RP11 Disk Pack RP11-C, TM11/TU10 Magnetic Tape, TM11

* PDP-11 Paper Tape Software Handbook DEC-11-XPTSA-B-D, 1976 - This is a great reference for introductory PDP-11 Assembly Language and for understanding the paper tape bootstrap loader (not discussed, below, see prior note)
> Chapter 6, Loading and Dumping Memory, Section 6.1.6.3 Bootstrap Loader Operation
> 
> Appendix F Loading and Dumping Core Memory

* PDP-11 Bootstrap Loaders [https://web.archive.org/web/20170329153036/http://psych.usyd.edu.au/pdp-11/bootstraps.html](https://web.archive.org/web/20170329153036/http://psych.usyd.edu.au/pdp-11/bootstraps.html) - I wish I had seen this sooner. The author has done similar, but more condensed, analyses of many different bootstraps.

## Bootstraps
With illustrative decoded instructions and comments

### TU10

#### TU10 Analysis
```
012700  MOV 175226,R0   ; Move MTCMA into R0
172526                  ; MTCMA address
010040  MOV R0,-(R0)    ; Move -5202(8) into the MTBRC address
012740  MOV 60003,-(R0) ; Move 60003 into the MTC address
060003                  ; Specify density, function, and go
000777  BPL .           ; Loop. NPR won't take place if we HALT
```

Here are the memory addresses of the TU10 that are being used:

* 175222 MTC   Magnetic Tape Command Register
* 175224 MTBRC Magnetic Tape Byte Record Counter Register
* 175226 MTCMA Magnetic Tape Current Memory Address Register

##### MTC Magnetic Tape Command Register

The command register is used to control the tape device. The code above puts 60003 into this register to set the density, tell the tape device to perform a read operation, and to go do its thing.

```
 0  1  1  0  0  0  0  0  0  0  0  0  0  0  1  1 - 060003
15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
```

bits 13-14 specify density, 11 indicates 800 bpi 9 channel

bits 1-3 specifies the tape function, 001 indicates read

bit 0 specifies go which begins the operation specified by the function bits

MTBRC Magnetic Tape Byte Record Counter Register
The byte record counter register holds the count of bytes to be read (in this case) from the tape device into memory. The number is a two's complement representation of the number, meaning that the value stored in this location is negative. The bootstrap above stores the MTCMA 1775226 in the counter. This number is simply a convenience number in this case, it is big enough to cause the device to completely read a block. It is not the actual number of bytes contained in the block. The reason for using it is to keep the program as short as possible and by referencing it using autodecrement mode, it conveniently provides the MTBRC address followed by the MTC, which is exactly how we use the device. Nifty for sure.

If you're curious to know what the actual value of the register is:

```
 1 111 111 101 010 010 110 - 1775226
 0 000 000 010 101 101 001 - one's complement
                         1 - add one to get the two's complement
--------------------------
 0 000 000 010 101 101 010 - 2552 (1386 base 10)
```

##### MTCMA Magnetic Tape Current Memory Address Register

This address is only used by the bootstrap to initialize R0. It is used by the device to determine where in memory to write the bytes it reads. When the device is initialized, this register contains all zeros 000000. The code does not change this. The bytes read from the tape are loaded into consecutive addresses starting at memory location 000000.

#### TU10 Summary

MTCMA is placed in R0 so that it can be decremented to obtain the MTBRC and provide the initial value for the MTBRC. R0 is decremented again to obtain the MTC, and the value 060003 is placed into the MTC and the device requests a direct memory access (DMA) read (aka non-processor request or NPR). Then the code loops on the same instruction which allows the pending NPR to take place.  Bytes are read from the tape, up to the two's complement of the number in the MTBR, into consecutive bytes of memory beginning at location 000000.

 
### RK05

#### RK05 Analysis

```
01 012700       MOV 177414,R0 ; Move RKDB into R0
02 177414                     ; RKDB Address
03 005040       CLR -(R0)     ; Decrement R0, clear contents RKDA
04 005040       CLR -(R0)     ; Decrement R0, clear contents RKBA
05 010040       MOV R0,-(R0)  ; Move contents of R0(RKBA) into RKWC
06 012740       MOV 5,-(R0)   ; Decrement R0 and move 5 into RKCS
07 000005                     ; Read and go
08 105710 WAIT: TSTB (R0)     ; Test the lower byte of RKCS
09 002376       BGE WAIT      ; When bit 7 becomes 1, read is done
10 005007       CLR PC        ; Set PC 000000, start of bytes read
```

##### RKDB - RK data buffer register (177414)

This register is RKDA+2 and is only used by the code above to initialize R0 so that subsequent RK addresses can be found by simply decrementing R0.

##### RKDA - RK disk address register (177412)

This register determines the starting disk address of the read operation and is cleared by the code.

##### RKBA - RK current bus address register (177410)

This register contains the bus address to or from which data will be transferred. Is this the same as memory address?

##### RKWC - RK word count register (177406)

Two's complement of the number of words to be transferred.

##### RKCS - RK control status register (177404)

This is the register that controls the device and provides the device status to the program

##### Lines 1-2

The execution of the boot loader code moves the address of RKDB into R0 to initialize the register so that it can be used to obtain the other RK buffer addresses as they are needed.

##### Line 3

The RKDA buffer is cleared, setting the disk address to 0.

Line 4The RKBA buffer is cleared, setting the bus address to 0.

##### Line 5

The value in R0 is transferred into the RKWC buffer. RKBA or 177410, the value in R0, is a convenient number to use for the read operation because it is big enough to cause the program to read in a block of data. The number is in two's complement and represents -370. This tells the disk controller that 370 words (540 bytes) will be transferred.

##### Lines 6-7

The value 5 is placed into RKCS, this value represents a read operation and go.

##### Lines 8-9

The lower byte of RKCS is tested and when it is greater than or equal to zero (not negative), it loops, waiting until the value is negative, that is until bit 7 becomes 1, which indicates Control Ready (RDY) and done.

##### Line 10

PC is set to 00000 and execution of the bytes read from the disk begins at location 00000.

#### RK05 Summary

RKDB is placed in R0 so that it can be decremented to obtain the addresses of RKDA, RKBA, RKWC, and RKCS. RKDA and RKBA are cleared and the address of RKBA representing -370 is placed into RKWC. The value 5 is placed into RKCS and the device is commanded to perform a read operation. Then the code loops until RKCS bit 7, RDY is detected. Finally, the PC is cleared and the program that is copied from the RK05 into memory location 0 is run.

### RP03

#### RP03 Analysis

```
01 012700       MOV 176726,R0 ; Move RPM1 into R0
02 176726                     ; RPM1 Address
03 005040       CLR -(R0)     ; Decrement R0, clear contents RPDA
04 005040       CLR -(R0)     ; Decrement R0, clear contents RPCA
05 005040       CLR -(R0)     ; Decrement R0, clear contents RPBA
06 010040       MOV R0,-(R0)  ; Move contents of R0(RPBA) into RPWC
07 012740       MOV 5,-(R0)   ; Decrement R0 and move 5 into RPCS
08 000005                     ; Read and go
09 105710 WAIT: TSTB (R0)     ; Test the lower byte of RPCS
10 002376       BGE WAIT      ; When bit 7 becomes 1, read is done
11 005007       CLR PC        ; Set PC 000000, start of bytes read
```

##### RPM1 - RP Maintenance 1 Register (176726)

This register is a maintenance mode register and it is only used by the code above to initialize R0 so that subsequent RP addresses can be found by simply decrementing R0.


##### RPDA - RP disk address register (176724)

This register determines the starting disk track and sector of the read operation and is cleared by the code.

##### RPCA - RP cylinder address register (176722)

This register determines the starting cylinder of the read operation and is cleared by the code.

##### RPBA - RP bus address register (176720)

This register contains the bus address to or from which data will be transferred. It is equivalent to the memory address of the PDP-11.

##### RPWC - RP word count register (176716)

Two's complement of the number of words to be transferred.

##### RPCS - RP control status register (176714)

This is the register that controls the device and provides the device status to the program

##### Lines 1-2

The execution of the boot loader code moves the address of RPM1 into R0 to initialize the register so that it can be used to obtain the other RP buffer address registers as they are needed.

##### Line 3

The RPDA buffer is cleared, setting the disk sector and track addresses to 0.

##### Line 4

The RPCA buffer is cleared, setting the cylinder address to 0.

##### Line 5

The RPBA buffer is cleared, setting the bus address to 0.

##### Line 6

The value in R0 is transferred into the RPWC buffer. RPBA or 176720, the value in R0, is a convenient number to use for the read operation because it is big enough to cause the program to read in a block of data. The number is in two's complement and represents -1060. This tells the disk controller that 1060 words (2120 bytes) will be transferred.

##### Lines 7-8

The value 5 is placed into RPCS, this value represents a read operation and go.

##### Lines 9-10

The lower byte of RPCS is tested and when it is greater than or equal to zero (not negative), it loops, waiting until the value is negative, that is until bit 7 becomes 1, which indicates Control Ready (RDY) and done.

##### Line 11

PC is set to 00000 and execution of the bytes read from the disk begins at location 00000.

#### RP03 Summary

RPM1 is placed in R0 so that it can be decremented to obtain the addresses of RPDA, RPCA, RPBA, RPWC, and RPCS. RPDA, RPCA, and RPBA are cleared and the address of RPBA representing -1060 is placed into RPWC. The value 5 is placed into RPCS and the device is commanded to perform a read operation. Then the code loops until RPCS bit 7, RDY is detected. Finally, the PC is cleared and the program that is copied from the RP03 into memory location 0 and is run.

*post added 2022-11-30 12:29:00 -0600*
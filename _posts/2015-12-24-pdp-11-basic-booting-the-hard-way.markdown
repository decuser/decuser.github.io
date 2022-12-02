---
layout:	post
title:	PDP-11 BASIC, booting the hard way
date:	2015-12-24 09:47:00 -0600
categories:	pdp-11 analysis
---
This note describes the process of running PDP-11 Basic from the PDP-11 Basic Paper Tape System. It is informed and inspired by Malcolm Macleod's webpage entitled, "PDP-11 Paper Tape BASIC" located at http://www.avitech.com.au/ptb/ptb.html. It describes the process, step by step, of keying in the bootstrap loader, running it to load the absolute loader from paper tape stored in bootstrap loader format, and then running the absolute loader to load the PDP-11 BASIC program from paper tape stored in absolute loader format.

To learn more about how the bootstrap loader works, see my [prior note ]({% post_url 2015-12-21-analysis-of-the-pdp-11-bootstrap-loader-code %})

<!--more-->

## Prerequisites

* Mac OS X or other unix-like environment
* SimH PDP-11 Simulator [https://github.com/simh/simh](https://github.com/simh/simh)
* Absolute Loader paper tape image DEC-11-L2PC-PO.ptap [http://www.vaxhaven.com/images/b/bf/DEC-11-L2PC-PO.ptap](http://www.vaxhaven.com/images/b/bf/DEC-11-L2PC-PO.ptap)

A Paper tape image with PDP-11 BASIC Single User DEC-11-AJPB-PB.ptap
[http://www.vaxhaven.com/images/c/c2/DEC-11-AJPB-PB.ptap](http://www.vaxhaven.com/images/c/c2/DEC-11-AJPB-PB.ptap)

### Nice to have

* PDP11-05 Handbook PDP11-05-10-35-40-processor handbook-1973.pdf [http://bitsavers.org/pdf/dec/pdp11/handbooks/PDP1145_Handbook_1973.pdf](http://bitsavers.org/pdf/dec/pdp11/handbooks/PDP1145_Handbook_1973.pdf)
* BASIC Programming Manual DEC-11-AJPB-D_PDP-11_BASIC_Programming_Manual_Dec70.pdf [https://archive.org/details/bitsavers_decpdp11baASICProgrammingManualDec70_5936477](https://archive.org/details/bitsavers_decpdp11baASICProgrammingManualDec70_5936477)

## The "hard" way

The hard way means typing a bit and not relying on SimH for much help. I will conclude with a script that can be run that automates the process that can be considered the easy way :).

In order to boot the PDP-11, we will start the simulator and tell it what kind of PDP-11, we want to run. In this case, we don't need anything more powerful than a PDP-11/05 with 8K words of memory. In SimH, memory is specified in bytes, not words, so the correct amount to specify an 8K word machine is 16K bytes.

```
pdp11
sim>

set cpu 11/05
set cpu 16k
set cpu idle
```

In order to load the basic program from its tape, a loader program is needed. That loader is the "absolute loader." The absolute loader is capable of loading programs from tape and potentially relocating them as well. The absolute loader is on its own paper tape, so it needs to be loaded first. The program that loads the absolute loader is the bootstrap loader.

At the very back of the handbook, or on the PDP-11 Programming Card, the bootstrap loader is provided in text form. The text is slightly cryptic, so I will explain the book entry and then describe how it works. Here is how it appears on page E-7 (line numbers added for discussion):

```
1                            ABSOLUTE LOADER
2
3                Starting Address: ___ 500
4                                  ^^^
5              Memory Size:             4K 017
6                                       8K 037
7                                      12K 057
8                                      16K 077
9                                      20K 117
10                                     24K 137
11                                     28K 157
12                                   (or larger)
13
14
15                           BOOTSTRAP LOADER
16     Address       Contents            Address       Contents
17     ___ 744        016 701            ___ 764        000 002
18     ___ 746        000 026            ___ 766        ___ 400
19     ___ 750        012 702            ___ 770        005 267
20     ___ 752        000 352            ___ 772        177 756
21     ___ 754        005 211            ___ 774        000 765
22     ___ 756        105 711            ___ 776        177 560 (KB)
23     ___ 760        100 376                     or    177 550 (PR)
24     ___ 762        116 162
```

Line 3 refers to the starting address of the absolute loader. It is comprised of 3 leading octal digits that depend on how much memory the system has (lines 5-12). In the simulated system, we specified 8K words of memory, so line 6 applies and the starting address for the absolute loader will be 037 500.

Line 6 also supplies the prefix for lines 17-24. Wherever ___ appears, 037 will be used. This ensures that the bootstrap is loaded into the highest physical memory location.

Lines 22-23 on the right hand side refers to KB or PR. KB is an LT 33 Teletype Keyboard, whereas PR is a PC11 Paper Tape Reader. The Reader is a faster device in the real world and will be the simulated device we will use (I don't know if the simulated KB or PR is faster).

Using the above information, the addresses and contents of the bootstrap loader program is represented as follows:

```
037744 016701
037746 000026
037750 012702
037752 000352
037754 005211
037756 105711
037760 100376
037762 116162
037764 000002
037766 037400
037770 005267
037772 177756
037774 000765
037776 177550
```

In order to put this program in memory, we need to toggle in each instruction. Since this is a simulator, we will do it virtually using the SimH deposit instruction:

```
dep 037744 016701
dep 037746 000026
dep 037750 012702
dep 037752 000352
dep 037754 005211
dep 037756 105711
dep 037760 100376
dep 037762 116162
dep 037764 000002
dep 037766 037400
dep 037770 005267
dep 037772 177756
dep 037774 000765
dep 037776 177550
```

We can verify the program by examining it with the SimH examine command:

```
ex 037744-037776
37744:    016701
37746:    000026
37750:    012702
37752:    000352
37754:    005211
37756:    105711
37760:    100376
37762:    116162
37764:    000002
37766:    037400
37770:    005267
37772:    177756
37774:    000765
37776:    177550
```

This program requires that the absolute loader paper tape be loaded into the paper tape reader and that it be ready to read. So, we will virtually load the tape and get it ready to read. At the sim> prompt:

`attach ptr DEC-11-L2PC-PO.ptap`

To execute the bootstrap loader from memory and load the absolute loader from tape, we tell the CPU (SimH) to begin executing the program loaded at 037744, the start of the bootstrap loader.

```
go 037744

The CPU will HALT
HALT instruction, PC: 037500 (MOV PC,SP)
```

The program counter (PC) is not pointing at 037500, the first instruction of the absolute loader. To enable us to use SimH while executing the BASIC program, we will enable telnet to the simulated environment:

`set console telnet=5000`

Open another terminal window and start a telnet session:

`telnet localhost 5000`

Next we virtually load the BASIC paper tape: And execute the absolute loader program to load the tape into memory and run it:

```
attach ptr DEC-11-AJPB-PB.ptap
dep sr 0
go
```

At this point BASIC is operational. To access it, open another terminal window and telnet to localhost on port 5000:

```
telnet localhost 5000

Trying ::1...
Connected to localhost.
Escape character is '^]'.


Connected to the PDP-11 simulator CON-TEL device


PDP-11 BASIC, VERSION 007A
*O
```

The `*O` is a prompt, just press enter and READY will appear

```
READY
```

NOTE: Only use upper case with the BASIC program or you will get unexplained errors.

Test it out by writing a little program

```
10 PRINT "HELLO, WORLD!"
List the program contents:

LIST

10 PRINT "HELLO, WORLD!"
READY
Run the program:

RUN
HELLO, WORLD!

STOP AT LINE   10
READY
```

Celebrate.


## The "easy" way

The easy way is to create a SimH ini file:

```
cat > basic.ini <<"EOF"
set cpu 11/05
set cpu 16k
set cpu idle

dep 037744 016701
dep 037746 000026
dep 037750 012702
dep 037752 000352
dep 037754 005211
dep 037756 105711
dep 037760 100376
dep 037762 116162
dep 037764 000002
dep 037766 037400
dep 037770 005267
dep 037772 177756
dep 037774 000765
dep 037776 177550

attach ptr DEC-11-L2PC-PO.ptap

go 037744

set console telnet=5000

attach ptr DEC-11-AJPB-PB.ptap
dep sr 0
go
EOF
```

Now to start the simulator pass it the ini file:

`pdp11 basic.ini`

And fire up another terminal window to telnet into the instance:

`telnet localhost 5000`

and you are up and running with PDP-11 BASIC in all of its glory, revel.


Mattis Lind on January 10, 2016 at 2:45 AM pointed out:

If you are interested more in the Absolute Loader the source code is provided here : [https://groups.google.com/forum/#!topic/alt.sys.pdp11/vTOG9_tEVMI](https://groups.google.com/forum/#!topic/alt.sys.pdp11/vTOG9_tEVMI)

In my post on my PDP-11/04 [https://web.archive.org/web/20160129154952/http://www.datormuseum.se/computers/digital-equipment-corporation/pdp-11-04](https://web.archive.org/web/20160129154952/http://www.datormuseum.se/computers/digital-equipment-corporation/pdp-11-04) restoration I did a quick hack to decode a file in absolute binary format into a binary image. Jörg Hoppe later included this feature in the PDP11GUI.

AlecV on August 15, 2017 at 8:30 AM pointed out:

LINK-11 may produce Absolute Loader format with /L CSI option or /LDA

xref: [http://bitsavers.trailing-edge.com/pdf/dec/pdp11/rt11/v5.6_Aug91/AA-PDU0A-TC_RT-11_Commands_Manual_Aug91.pdf](http://bitsavers.trailing-edge.com/pdf/dec/pdp11/rt11/v5.6_Aug91/AA-PDU0A-TC_RT-11_Commands_Manual_Aug91.pdf)

Page 171

xref: [http://bitsavers.trailing-edge.com/pdf/dec/pdp11/rt11/v5.6_Aug91/AA-M239D-TC_RT-11_System_Utilities_Manual_Part_I_Aug91.pdf](http://bitsavers.trailing-edge.com/pdf/dec/pdp11/rt11/v5.6_Aug91/AA-M239D-TC_RT-11_System_Utilities_Manual_Part_I_Aug91.pdf)

Section 15-28

*post added 2022-11-30 12:29:00 -0600*
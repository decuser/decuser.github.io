---
title: Getting DOS-11 V004A Running on a PDP-11/40
tags: unix research-unix v6 dec
---

# Getting DOS-11 V004A Running on a PDP-11/40

I did not set out to install DOS-11.

I have been working with Sixth Edition UNIX on a simulated PDP-11/40, partly to understand the system itself and partly to get closer to the environment described by Lions. That inevitably led downward. Reading the V6 source means reading PDP-11 assembly, and reading PDP-11 assembly means spending some time with the tools and conventions that existed around the machine before and alongside UNIX.

That led me to PAL-11R, DEC's relocatable assembler for the PDP-11, and from there to DOS-11.

<!--more-->

Last Updated August 7, 2026

The comparison turned out to be more interesting than I expected. It is easy, from a UNIX perspective, to dismiss something called the "DOS Monitor" as little more than a program loader. That isn't really fair. DOS-11 provides a recognizable operating environment: a monitor, filesystem, device-independent I/O, program loading, an assembler, linker, editor, debugger, librarian, and file utility. An assembly-language application written for DOS-11 can use operating-system services in much the same conceptual sense that a V6 assembly program uses UNIX system calls.

The systems are very different, but they are solving many of the same problems.

So I decided to get an early DOS-11 system running.

## The system

The target is deliberately modest:

```text
CPU:     PDP-11/40
Memory:  32 KB
Disk:    RK05
DECtape: TC0 / DT0
```

I am using OpenSIMH and the DEC distribution image:

```text
DOS002 DEC-11-MW2C-UC
11/15/71
DOS SYSTEM TAPE V004A
RK11/RK03 HIGH DENSITY
ORIGINAL DEC DISTRIBUTION TAPE
```

The image is available in the Bitsavers PDP-11 DECtape collection as `dos002.dta`.

Its directory is:

```text
DIRECTORY DT0: [1,1]

27-JAN-73

SYSLOD.SYS    31C 09-JUL-71 <377>
MONLIB.SYS    83  09-JUL-71 <377>
MODS  .OBJ    10  09-JUL-71 <233>
PIP   .OBJ    59  03-NOV-71 <233>
PIP   .LDA    19  03-NOV-71 <233>
EDIT11.OBJ    21  09-JUL-71 <233>
ODT11R.OBJ    13  09-JUL-71 <233>
LIBR11.OBJ    13  09-JUL-71 <233>
LINKOB.OBJ    38  13-DEC-71 <233>
LINK11.OBJ    23  13-DEC-71 <233>
LINKOB.LDA    27  13-DEC-71 <233>
LINK11.LDA    16  13-DEC-71 <233>
PALOB .OBJ    34  09-JUL-71 <233>
PALSYM.OBJ     4  09-JUL-71 <233>
PAL11R.OBJ    19  09-JUL-71 <233>
PALSYM.PAL    21  09-JUL-71 <233>

FREE BLKS:   131
FREE FILES:   40
```

There is enough here to bootstrap a useful development system onto an RK05, but getting there is wonderfully unlike installing a modern operating system.

## Booting the distribution tape

I begin with a fresh RK05 image and the DOS002 DECtape mounted as `TC0`, which DOS sees as `DT0:`.

The complete OpenSIMH initialization file is included at the end of this post.

Boot the DECtape:

```text
$ pdp11 tboot.ini
```

The bootstrap stops:

```text
HALT instruction, PC: 030464 (BIT #1,@#177570)
sim> dep sr 100001
sim> co

HALT instruction, PC: 030122 (BIT #1,@#177570)
sim> co
```

DOS then comes up:

```text
MONITOR  V004A

$LO 1,1
DATE:- 00-XXX-70
TIME:- 00:00:37
```

Set the date and time:

```text
$DATE 12-DEC-72
$TIME 22:23
```

We now have a running V004A Monitor.

## Populate the RK05

DOS002 already contains a runnable PIP, so use it directly:

```text
$RUN DT0:PIP.LDA
```

Copy the object modules, load modules, and PAL source to `DK0:`:

```text
#DK0:<DT0:*.OBJ
#DK0:<DT0:*.LDA
#DK0:<DT0:*.PAL
```

A directory listing should now show the system files on the RK05:

```text
#DK0:/DI
```

My resulting disk contained:

```text
DIRECTORY DK0: [1,1]

MONLIB       188C 00-XXX-70 <377>
MODS  .OBJ    10
PIP   .OBJ    59
EDIT11.OBJ    21
ODT11R.OBJ    13
LIBR11.OBJ    13
LINKOB.OBJ    38
LINK11.OBJ    23
PALOB .OBJ    34
PALSYM.OBJ     4
PAL11R.OBJ    19
PIP   .LDA    19
LINKOB.LDA    27
LINK11.LDA    16
PALSYM.PAL    21

TOTL BLKS:   505
TOTL FILES:   15
```

Kill the running program and leave the simulator:

```text
#^C
.KI
```

Then `Ctrl-E` and `q`.

The RK05 can now be booted directly.

## Relink LINK-11 first

This was the step that caused me the most trouble.

DOS supplies both `LINKOB.LDA` and `LINK11.LDA`, but LINK-11 is intended to be relinked for the memory configuration of the machine on which it will run. The LINK-11 manual explicitly describes this process and gives its assumed top-of-memory values for various configurations.

Boot the RK05:

```text
$ pdp11 boot.ini
```

Log in and set the date:

```text
$LO 1,1
$DATE 07-AUG-81
$TIME 19:00
```

Run the supplied linker:

```text
$RUN LINKOB.LDA
$RUN LINK11.LDA
```

Then rebuild both portions of LINK:

```text
#LINKOB.LDA<LINKOB.OBJ/E
#LINK11.LDA<LINK11.OBJ/E
```

On this 32 KB machine the newly linked programs report a high limit of:

```text
077460
```

which is exactly the default documented by LINK-11 for a 16K-word machine.

Exit:

```text
#^C
.KI
```

and, importantly, run the **newly linked** LINK:

```text
$RUN LINKOB.LDA
$RUN LINK11.LDA
```

That distinction matters.

Before relinking LINK itself, I repeatedly encountered:

```text
F001
```

while attempting to link the larger PIP from DOS002. Moving PIP around in memory did not solve it. Once LINK itself had been rebuilt for the machine configuration, PIP linked normally.

## Link the system programs

The *Getting DOS on the Air* instructions reserve `0304` octal bytes from the top of memory when determining the `/T:` value for PIP.

For a 24 KB machine:

```text
24 KB = 060000 octal

060000
- 0304
------
057474
```

This machine has 32 KB:

```text
32 KB = 100000 octal

100000
-  0304
-------
077474
```

Therefore:

```text
#PIP.LDA<PIP.OBJ/CC/T:77474/E
```

The `/CC` switch tells LINK that `PIP.OBJ` contains concatenated object modules.

Now link the remaining utilities:

```text
#EDIT11.LDA<EDIT11.OBJ/E
#ODT11R.LDA<ODT11R.OBJ/E
#LIBR11.LDA<LIBR11.OBJ/E
#PALOB.LDA<PALOB.OBJ/E
#PAL.LDA<PALSYM.OBJ,PAL11R.OBJ/E
#MODS.LDA<MODS.OBJ/E
```

Exit LINK:

```text
#^C
.KI
```

Finally, rebuild the PAL-11R symbol table:

```text
$RUN PALOB.LDA
$RUN PAL

#PALSYM.OBJ<PALSYM.PAL
```

and exit:

```text
#^C
.KI
```

At this point the RK05 contains a working DOS-11 development environment:

```text
DOS Monitor V004A
PIP-11      V005A
LINK-11     V007A
EDIT-11     V004A
ODT-11R     V002A
LIBR-11     V002A
PAL-11R     V005A
MODS-11     V003A
```

## Hello, world

Now we can actually use it.

Start EDIT-11:

```text
$RUN EDIT11
```

Create `HELLO.PAL`:

```text
#HELLO.PAL
*I
```

Enter:

```asm
.TITLE  HELLO

SP=%6

START:  MOV     #TTY,-(SP)
        EMT     6

        MOV     #MSGHDR,-(SP)
        MOV     #TTY,-(SP)
        EMT     2

        MOV     #TTY,-(SP)
        EMT     1

        MOV     #TTY,-(SP)
        EMT     7

        EMT     60

        .WORD   0

TTY:    .WORD   0
        .WORD   0
        .BYTE   1,0
        .RAD50  /KB/

MSGHDR:
        .WORD   MSGEND-MSG
        .BYTE   0,0
        .WORD   MSGEND-MSG

MSG:    .ASCII  /HELLO, WORLD!/
        .BYTE   15,12
MSGEND:
        .EVEN

        .END    START
```

Finish insertion with line feed (CTL-J) and exit EDIT-11:

```text
*EX
```

Assemble it:

```text
$RUN PAL

#DK0:HELLO.OBJ<DK0:HELLO.PAL
```

Exit PAL and run LINK:

```text
#^C
.KI

$RUN LINK11

#DK0:HELLO.LDA<DK0:HELLO.OBJ/E
```

Then:

```text
#^C
.KI

$RUN HELLO
HELLO, WORLD!
```

We have a working assembly-language program running under DOS-11.

## And in Sixth Edition UNIX?

This entire excursion started with V6, so the obvious question is what the equivalent looks like there.

Not surprisingly, it is considerably shorter.

Create `hello.s`:

```text
# cat >hello.s
```

```asm
        mov     $1,r0
        sys     write; message; message_end-message
        sys     exit

message:
        <hello, world\n>
message_end:
```

Then:

```text
# as hello.s
# mv a.out hello
# chmod 755 hello
# ./hello
hello, world
```

The interesting comparison isn't simply that UNIX takes fewer lines.

Both programs are assembly-language applications running **under an operating system**. Neither is merely banging characters directly into a PDP-11 console register. The DOS program invokes Monitor services through `EMT`; the UNIX program invokes kernel services through `sys`.

That distinction was useful for me. I had initially thought of the DOS Monitor as something substantially less than an operating system, and of assembly programming as somehow closer to "the metal" than programming in C. Neither intuition survives very long once you actually use these systems.

The assembler does not remove the operating system.

DOS-11 and UNIX provide very different abstractions, interfaces, and development environments, but our two little programs ultimately ask their respective operating systems to perform the same mundane task:

```text
write these characters
```

And that was worth the detour.

## OpenSIMH configuration

### `tboot.ini`

```text
ECHO ==================
ECHO Install DOS
ECHO ==================

ECHO ...set the CPU parameters
SET CPU 11/40
SET CPU 32K

ECHO ...disable undesired devices
SET HK DISABLE
SET RHA DISABLE
SET PTR DISABLE
SET PTP DISABLE
SET DZ DISABLE
SET RL DISABLE
SET RX DISABLE
SET RP DISABLE
SET RQ DISABLE
SET TM DISABLE
SET TQ DISABLE

ECHO ...attach disk
SET RK ENABLE
ATTACH RK0 RK05.DSK

ECHO ...attach tape
SET TC ENABLE

ATTACH TC0 dos002.dta
SET TC0 LOCKED

;ECHO ...attach line printer
;ATTACH LPT lineprinter.txt

ECHO ...booting TC0 aka DT0:
BOOT TC0
```

### `boot.ini`

```text
ECHO ==================
ECHO Boot DOS
ECHO ==================

ECHO ...set the CPU parameters
SET CPU 11/40
SET CPU 32K

ECHO ...disable undesired devices
SET HK DISABLE
SET RHA DISABLE
SET PTR DISABLE
SET PTP DISABLE
SET DZ DISABLE
SET RL DISABLE
SET RX DISABLE
SET RP DISABLE
SET RQ DISABLE
SET TM DISABLE
SET TQ DISABLE

ECHO ...attach disk
SET RK ENABLE
ATTACH RK0 RK05.DSK

ECHO ...attach tape
SET TC ENABLE

ATTACH TC0 dos002.dta
SET TC0 LOCKED

;ECHO ...attach line printer
;ATTACH LPT lineprinter.txt

ECHO ...booting RK0 aka DK0:
BOOT RK0
```

## Documentation

The contemporary DEC documentation is essential here. I used:

* *Getting DOS on the Air*, DEC-11-SYDC-D, August 1971.
* *DOS Monitor Programmer's Handbook*, DEC-11-SERA-D, February 1971.
* *PDP-11 EDIT-11 Text Editor*, DEC-11-EEDA-D, May 1971.
* *PDP-11 LINK-11 Linker and LIBR-11 Librarian*, DEC-11-ZLDA-D, May 1971.
* *Disk Operating System Monitor Programmer's Manual*, DEC-11-MWDC-D, February 1972.
* *PDP-11 ODT-11R*, DEC-11-OODA-D, May 1971.
* *PAL-11R Assembler Programmer's Manual*, DEC-11-ASDB-D, May 1971.
* *PDP-11 File Utility Package (PIP)*, DEC-11-PIDA-D, May 1971.

The DOS002 image and its catalog information are in the Bitsavers PDP-11 DECtape collection.

For DOS errors and warnings, see Appendix F, **Summary of DOS Error Messages**, in the February 1972 *Disk Operating System Monitor Programmer's Manual*.

One lesson from this exercise is worth emphasizing: with software this old, the manuals aren't supplementary documentation. They are part of the system.

*post added 2026-08-07 20:06:00 -0500*

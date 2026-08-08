---
title: Getting DOS-11 V004A Running on a PDP-11/40
tags: unix research-unix v6 dec
---

# Getting DOS-11 V004A Running on a PDP-11/40

I did not set out to install DOS-11.

I have been working with Sixth Edition UNIX on a simulated PDP-11/40, partly to understand the system itself and partly to get closer to the environment described by Lions. That inevitably led downward. Reading the V6 source means reading PDP-11 assembly, and reading PDP-11 assembly means spending some time with the tools and conventions that existed around the machine before and alongside UNIX.

That led me to PAL-11R, DEC's relocatable assembler for the PDP-11, and from there to DOS-11.

<!--more-->

Last Updated August 7, 2026 at 4:15pm

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

Start SIMH with the tape-boot configuration:

```text
$ pdp11 tboot.ini
```

The important part of `tboot.ini` is that it attaches the fresh RK05 as `RK0`, mounts `dos002.dta` on `TC0`, and then boots the DECtape:

```text
ATTACH RK0 RK05.DSK

ATTACH TC0 dos002.dta
SET TC0 LOCKED

BOOT TC0
```

The startup sequence follows Section 1.2.5, *Loading MONLIB from DECtape*, in DEC's *Getting DOS on the Air*.

For a fresh disk, DEC specifies:

* Switch Register bit 0 = 1
* Switch Register bit 15 = 1

Together, those bits give the octal switch-register value:

```text
100001
```

On a physical PDP-11 these would be set on the front panel. In SIMH:

```text
HALT instruction, PC: 030464 (BIT #1,@#177570)
sim> dep sr 100001
sim> co
```

With bit 15 set, SYSLOD clears the fresh disk, loads `MONLIB.SYS` from DECtape onto it, and then halts at the documented location `30120`:

```text
HALT instruction, PC: 030122 (BIT #1,@#177570)
```

SIMH reports the PC just beyond the halt instruction, hence `030122`.

DEC's next instruction is simply to press CONTINUE again:

```text
sim> co
```

The Monitor is then booted into core:

```text
MONITOR  V004A

$
```

At this point the Monitor has been installed onto the RK05. The next step is to quit SIMH and restart with `boot.ini`, this time booting directly from `RK0`.

The DECtape has now done its job: SYSLOD has initialized the fresh RK05 and written the Monitor to disk.

Pause SIMH and exit - `Ctrl-E` and `q`.

## Booting from the RK05

Restart using `boot.ini`, which attaches the same `RK05.DSK` image but boots from `RK0` instead of `TC0`:

```text
$ pdp11 boot.ini
```

The relevant difference is simply:

```text
ECHO ...booting RK0 aka DK0:
BOOT RK0
```

DOS boots from the RK05 and presents the Monitor prompt:

```text
MONITOR  V004A

$
```

Log in to the system account:

```text
$LO 1,1
DATE:- 00-XXX-70
TIME:- 00:00:37
```

Then set the date and time:

```text
$DATE 08-AUG-81
$TIME 09:23
```

We are now running the V004A Monitor from `DK0:`. The DOS002 DECtape remains mounted as `DT0:`, so we can use the runnable utilities on the distribution tape to populate the disk with the distributed utilities.

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

or more briefly, since the DK0: is already selected:

```text
#/DI
```

The resulting disk will contain:

```text
DIRECTORY DK0: [1,1]

28-JAN-73

MONLIB       188C 00-XXX-70 <377>
MODS  .OBJ    10  28-JAN-73 <233>
PIP   .OBJ    59  28-JAN-73 <233>
EDIT11.OBJ    21  28-JAN-73 <233>
ODT11R.OBJ    13  28-JAN-73 <233>
LIBR11.OBJ    13  28-JAN-73 <233>
LINKOB.OBJ    38  28-JAN-73 <233>
LINK11.OBJ    23  28-JAN-73 <233>
PALOB .OBJ    34  28-JAN-73 <233>
PALSYM.OBJ     4  28-JAN-73 <233>
PAL11R.OBJ    19  28-JAN-73 <233>
PIP   .LDA    19  28-JAN-73 <233>
LINKOB.LDA    27  28-JAN-73 <233>
LINK11.LDA    16  28-JAN-73 <233>
PALSYM.PAL    21  28-JAN-73 <233>

TOTL BLKS:   505
TOTL FILES:   15
```

Stop PIP and kill it's process:

```text
#^C
.KI
$
```

## Relink LINK-11 first

This was the step that caused me the most trouble.

DOS supplies both `LINKOB.LDA` and `LINK11.LDA`, but LINK-11 is intended to be relinked for the memory configuration of the machine on which it will run. The LINK-11 manual explicitly describes this process and gives its assumed top-of-memory values for various configurations.

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

and, importantly, run the **newly linked** LINK11:

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

The `/T:77474` switch tells LINK to use `077474` as the top address for relocating the program. LINK places the relocatable sections downward from that point.

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

Finally, rebuild the PAL-11R symbol table using the newly available PAL assembler (this is the documented test that it's working):

```text
$RUN PALOB.LDA
$RUN PAL

#PALSYM.OBJ<PALSYM.PAL
```
You should see:

```text
 END

000000 ERRORS
```

Exit PAL:

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

## Assemble Hello, world

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
#^C
.KI
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

## When things go wrong

DOS-11 is terse when something fails. Most of the time you get an error code and not much else. Appendix F of the *Disk Operating System Monitor Programmer's Manual* is therefore worth keeping close at hand.

One especially common error during this procedure is:

```text
F012
```

`F012` is associated with opening or creating files. In practice, the first things to check are whether you are logged in, whether your UIC exists on the device, whether the input file exists, and whether you are trying to create an output file that already exists. The DOS manual even provides a recovery checklist for `F012` and `F024`.

The last case is particularly common while experimenting. LINK-11 enters the output filename in the directory before it completes the link, so a failed link can leave the filename behind. DEC's *Getting DOS on the Air* explicitly recommends removing the old file with PIP before trying again.

For example, if `PIP.LDA` already exists:

```text
$RUN PIP
#PIP.LDA/DE
```

Then leave PIP and rerun LINK:

```text
#^C
.KI

$RUN LINK11
#PIP.LDA<PIP.OBJ/CC/T:77474/E
```

PIP's delete syntax is simply:

```text
dev:file.ext/DE
```

so, for example:

```text
#DK0:HELLO.LDA/DE
```

deletes `HELLO.LDA` from `DK0:`. Wildcards are also supported:

```text
#DK0:*.OBJ/DE
```

but use them carefully.

If the file is locked, delete will fail. The DOS recovery instructions say to UNlock it with PIP first, then DElete it. Likewise, a protection code can prevent access or deletion.

A useful habit while rebuilding system programs is therefore:

```text
$RUN PIP
#DK0:/DI
```

Check whether the output file from the failed operation already exists before rerunning the assembler or linker.

For LINK-11 errors, remember that a failed link may already have created the directory entry. DEC specifically notes this in *Getting DOS on the Air*: if linking is interrupted, remove the incomplete filename and link again.

One caution from the PIP manual is worth preserving: if a file is known to have a damaged disk link structure, do **not** simply delete it. DEC warns that deleting such a file can damage other portions of the disk. That is a different situation from the ordinary incomplete output file left by a failed LINK operation.

In short, when an operation unexpectedly fails:

```text
check login/UIC
check that input exists
check whether output already exists
check whether the file is locked or protected
delete the stale output if appropriate
retry the operation
```

The error messages are primitive, but once you know that DOS does not automatically replace existing files, many of the mysterious failures become much less mysterious.

### Re-editing a source file

EDIT-11 can edit an existing file in place. Specify the same file as both output and input:

```text
$RUN EDIT11
#HELLO.PAL<HELLO.PAL
```

EDIT-11 uses a temporary file while editing and preserves the original as `HELLO.BAK` when the edit is completed normally.

Read the source into the Page Buffer:

```text
*R
```

For a small source file such as `HELLO.PAL`, this reads the entire file. To display the buffer, move Dot to the beginning with `B` and list from there through the end with `/L`:

```text
*B/L
```

To append text at the end, move Dot to the end of the Page Buffer with `/J` and enter insert mode:

```text
*/J I
```

Type the new text, then press LINE FEED to leave text mode and return to the `*` prompt.

You can use `B/L` again to review the edited buffer:

```text
*B/L
```

When finished, exit normally:

```text
*EX
```

`EX` writes the edited file, copies any remaining input to the output, and closes the files. The result is the new `HELLO.PAL`, with the previous version retained as `HELLO.BAK`.

If you make a mess of the edit, don't use `EX`. `KI` aborts the edit without replacing the original file:

```text
*KI
```

That distinction is useful: `EX` commits the edit; `KI` abandons it.

### Using the manuals with AI

One useful approach when working with software this old is to give an AI system the documentation that actually belongs to the system.

Rather than asking general-purpose questions about DOS-11 and hoping that AI figures it out, Add the full text of the relevant DEC manuals to the AI project files. For this installation that includes the manuals for the DOS Monitor, LINK-11, PIP, EDIT-11, PAL-11R, ODT-11R, and *Getting DOS on the Air*.

Then questions can be asked against those sources:

```text
How do I edit an existing file with EDIT-11?

What does F012 mean?

How does /T: work in LINK-11?

How do I delete an existing file with PIP?

What does Getting DOS on the Air say to do after this halt?
```

This is particularly useful with early DEC software because the commands and conventions are unfamiliar, terse, and sometimes quite different from later DEC systems. An AI system may otherwise confidently supply an RT-11, RSX-11, or modern UNIX answer that sounds plausible but is simply wrong for DOS-11.

The manuals remain the authority. The AI is useful as an interface to them: finding the relevant passage, connecting information spread across several manuals, and translating a 1971 front-panel procedure into the equivalent SIMH operations.

It is still worth asking for the manual and section supporting an answer. With a system this old, a plausible answer and the correct answer can be separated by fifty years of accumulated conventions.


## And in Sixth Edition UNIX?

This entire excursion started with V6, so the obvious question is what the equivalent looks like there.

Not surprisingly, it is considerably shorter.

```text
~/retro-workarea/v6 $ pdp11 boot.ini 

PDP-11 simulator Open SIMH V4.1-0 Current        git commit id: a1f57fa3
Disabling XQ
@unix

login: root
# 
```

Create `hello.s`:

```text
cat >hello.s
        mov     $1,r0
        sys     write; message; message_end-message
        sys     exit

message:
        <hello, world\n>
message_end:
^D
```
Where `^D` is end of file (you type it holding down `control` and the `d` key).

Then:

```text
# as hello.s
# mv a.out hello
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

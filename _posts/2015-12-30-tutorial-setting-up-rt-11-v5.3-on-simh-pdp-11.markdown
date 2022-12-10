---
layout:	post
title:	Tutorial - Setting up RT-11 v5.3 on SimH PDP-11
date:	2015-12-30 12:17:00 -0600
categories:	pdp-11 rt-11
---
A tutorial about how to set up an RT-11 v5.3 in a SimH PDP-11 instance in Support of MACRO-11 Assembly Development and Experimentation.

The RT-11 is a small, single-user, real-time operating system for the PDP-11, 16-bit family of computers. It is simple to install and it works fine with SimH, it just takes some getting used to. If you have ever used DOS, it will seem mildly familiar. This tutorial is enough to get you started with RT-11, but it is by no means a complete introduction. Once you have the environment up and running, I recommend that you read Introduction to RT-11 referenced below. That document will take the reader through a number of exercises to get more familiar with the operating system.
<!--more-->

Please message me after you work through the tutorial and let me know if there are any needed corrections or changes that would be helpful to add.

## What you will (hopefully) learn through this tutorial

* How to install RT-11 v5.3 on a SimH PDP-11 simulator
* How to interact with RT-11 from a host system productively
* How to back up the RT-11 operating system on the host
* How to develop, edit, assemble, link, and run a simple MACRO-11 Hello world application in RT-11's operating environment.

## Prerequisites

* A developer friendly host environment - Linux with base developer tools, or Mac with XCode and Homebrew installed should work well, on Windows, try Cygwin.
* A working SimH PDP-11 Simulator [https://github.com/simh/simh](https://github.com/simh/simh)
* The RT-11 v5.3 Distribution [http://www.bitsavers.org/simh.trailing-edge.com/kits/rtv53swre.tar.Z](http://www.bitsavers.org/simh.trailing-edge.com/kits/rtv53swre.tar.Z)
* An empty RL02 Disk Image [http://www.dbit.com/pub/pdp11/empty/rl02.dsk.gz](http://www.dbit.com/pub/pdp11/empty/rl02.dsk.gz)
* The Introduction to RT-11 document [http://bitsavers.trailing-edge.com/pdf/dec/pdp11/rt11/v5.1_Jul84/AA-5281C-TC-T1_Introduction_To_RT-11_Jul84.pdf](http://bitsavers.trailing-edge.com/pdf/dec/pdp11/rt11/v5.1_Jul84/AA-5281C-TC-T1_Introduction_To_RT-11_Jul84.pdf)

## Resources

* RT-11 v5.1 Documentation [http://bitsavers.trailing-edge.com/pdf/dec/pdp11/rt11/v5.1_Jul84](http://bitsavers.trailing-edge.com/pdf/dec/pdp11/rt11/v5.1_Jul84)
* Useful RT-11 Related Information  [http://www.mrp3.com/PDP11.html](http://www.mrp3.com/PDP11.html) 
* The document that helped me get up and running [http://gunkies.org/wiki/Installing_RT-11_5.3_on_SIMH](http://gunkies.org/wiki/Installing_RT-11_5.3_on_SIMH)

## Getting Started

Create a working directory and change into it. I use a sandboxes area:

```
mkdir ~/sandboxes/rt-11-explorations
cd  ~/sandboxes/rt-11-explorations
```

## Prepare SimH pdp11

Git is by far the best method of obtaining SimH - snag it:

```
git clone https://github.com/simh/simh.git
cd simh
make pdp11
```

Optionally, copy it into an accessible location:
`sudo cp BIN/pdp11 /usr/local/bin/pdp11`

Test it:

```
pdp11

PDP-11 simulator V4.0-0 Beta        git commit id: ac837e5b
sim> q
Goodbye

cd ..
```

## Prepare the RT-11 v5.3 distribution disk image and the empty rl02 disk image

Get the images using curl or wget or just visit the site directly:

```
curl -O http://www.bitsavers.org/simh.trailing-edge.com/kits/rtv53swre.tar.Z
curl -O http://www.dbit.com/pub/pdp11/empty/rl02.dsk.gz
```

Unzip them and clean up by moving the empty disk image into Disks and cleaning up unnecessary files:

```
tar xvf rtv53swre.tar.Z Disks/rtv53_rl.dsk
mv rl02.dsk Disks/empty-rl02.dsk
rm rtv53swre.tar.Z
```

Make copies of the disk images for use in the simulator:

```
cp Disks/empty-rl02.dsk distribution-backup.dsk
cp Disks/rtv53_rl.dsk distribution.dsk
```

To later restore these files in the event of an error, it is as simple as:

```
cp Disks/empty-rl02.dsk distribution-backup.dsk
cp Disks/rtv53_rl.dsk distribution.dsk
```

However, these are the raw disks, another backup will take care of the prepared disks, later.

## Create SimH PDP-11 Configuration Files

Two configuration files will be used in this tutorial. The first will be used to initialize the system and to execute the RT-11 Automatic Installation Process. The second will be used for normal, subsequent boots.

### Create Initial Configuration File

```
cat >initial.ini <<"EOF"
set cpu 11/23+ 256K
set tto 8b
attach LPT lpt.txt
set rl0 writeenabled
set rl0 rl02
attach rl0 distribution.dsk
set rl1 writeenabled
set rl1 rl02
attach rl1 distribution-backup.dsk
set rl1 badblock
boot rl0
EOF
```

The ini file describes a PDP-11/23+ with 256K of RAM. This is sufficient for the installation. It also tells the simulator to use an 8bit terminal setting, ASCII support will handle arrow keys, colors, etc. The LPT device points to lpt.txt on the host and is one method for obtaining printouts from the RT-11 environment. rl0 and rl1 are both set to be write enabled, are rl02 devices, and are attached to files on the host. The simulator or RT-11 doesn't do well with empty disk device files without the badblock being set, so it is set. The file then explicitly calls boot on the distribution disk image, rl0.

### Create Regular Boot Configuration File

```
cat >boot.ini <<"EOF"
set cpu 11/23+ 256K
set tto 8b
attach LPT lpt.txt
set rl0 writeenabled
set rl0 rl02
attach rl0 working.dsk
set rl1 writeenabled
set rl1 rl02
attach rl1 storage.dsk
set rl1 badblock
boot rl0
EOF
```

This file is basically the same as the initial file, but instead of the two disks being attached to the distribution and backup disks, they are attached to working and storage. These will be the files to backup whenever a backup is desired. The CPU is the same 11/23+ with 256K of RAM. This can be changed to a more powerful system at anytime without breaking anything, but it is not required for most simple work in RT-11.

## RT-11 Automatic Installation Process

Everything is ready for the installation at this point. Confirm that you have the files and folders below:

```
$ ls -1
Disks
boot.ini
distribution-backup.dsk
distribution.dsk
initial.ini
```

### Start the Simulation

In order to power on the PDP-11, the command pdp11 is invoked with the name of the appropriate ini file:

```
pdp11 initial.ini

PDP-11 simulator V4.0-0 Beta        git commit id: ac837e5b
LPT: creating new file
Overwrite last track? [N]

Answer Y and press enter to begin the process.

If everything is as it should be you will be greeted with a lime green background and the heading - RT-11 Automatic Installation Process.

Screen 1 - Automatic Installation Process
RT-11 Automatic Installation Process

        Welcome to RT-11 V5.3

        You have bootstrapped the RT-11 Distribution Disk.  Use this disk to
        install your RT-11 system, then store it in a safe place.

        RT-11  V5.3  provides an automatic installation procedure which will
        back up your distribution disk and build a working system disk which
        should  be  used for your work with RT-11.
        This  working  system disk will only  contain  the  RT-11  operating
        system.  After  the  RT-11  installation  is  complete,  follow  the
        installation instructions  packaged  with  any optional languages or
        utility software which you will be using.


        Press the "RETURN" key when ready to continue.
```

Do as instructed and press the return key to progress to the next screen.

```
Screen 2 - Automatic Installation Process
RT-11 Automatic Installation Process

        You  can  choose  to  install  RT-11  manually.  This  procedure  is
        described in the RT-11 Installation Guide.

        If  you  are a new user of RT-11, DIGITAL highly recommends that you
        use the automatic installation procedure.

        Do you want to use the automatic installation procedure?
        (Type YES or NO and press the "RETURN" key):
```

Unless you are expert, just type YES and press return to continue the process. If you make a mistake typing, press delete and the letter you want to delete will be printed with a preceding backslash, make your correction and all will be well with the world. For example if you type `YEP` and then press `delete` followed by the correct, S, it will appear as follows: `YEP\P\S`

```
Screen 3 - Automatic Installation Process
RT-11 Automatic Installation Process

        You  will  be guided through the installation process by a series of
        instructions  and questions; you have an interactive dialog with the
        RT-11  installation  program.   All  you  need  to  do is follow the
        instructions  carefully.  When  the  instructions ask you to mount a
        disk in a specified drive, find the disk with the correct label  and
        mount it in the drive, as shown in your installation booklet.

        Do  not  remove  any  disk until specifically instructed to do so.
        Once  a  disk  is  mounted in a drive, it must remain in the drive
        until a message appears asking you to remove the disk.

        Press the "RETURN" key when ready to continue.
```

Just follow the instructions and press return to proceed.

```
Screen 4 - Date Screen
Enter Today's Date

        Please enter today's date in the following format:

        DD-MMM-YY
          where DD is the day of the month
                MMM is the first 3 letters in the name of the month
        YY is the last two numbers of the year

        For example:   January 19, 1988 is 19-JAN-88

        Type in the date, then press the "RETURN" key.
```

Note: Modern years don't really work well in RT-11, if this bothers you, find the fixes and apply them. Otherwise, just type a date like `19-JAN-88` and press `return` to proceed. Thanks Peter on blogger for pointing out that month-days occur on the same weekdays 28 years ago. So, if you select 2016-28=1988, days will continually match up and all that will be off is the year. As a retro-hobbyist, it should be fun to revisit 1988 :) when RT-11 5 was very much still in use.

```
Screen 5 - Backup Disk Screen
Backing Up Distribution Disk

        A backup copy of the distribution disk will now be built.
        Mount a blank disk in DL1 (Drive 1).
        See the Automatic Installation Booklet for mounting instructions.
        (Remember that the disk is not mounted until you have pressed the LOAD
        button and the READY indicator light is on).

        Press the "RETURN" key when you have mounted the disk.
```

At this point, the backup disk is mounted in RL1, which is being referred to here as DL1. So simply press return to have the backup written to the host disk image file distribution-backup.dsk and to proceed.

```
Screen 6 - Backup Disk Completed Screen
Backing Up Distribution Disk

        Your backup copy of the distribution disk is in DL1 (Drive 1).

        Please remove this disk from DL1 and label it
        "RT-11 V5.3 BIN RL02 BACKUP".
        Refer to Appendix B of your installation booklet for instructions
        for dismounting a disk.

        Press the "RETURN" key when you have removed the disk.
```

In order to unattach the disk and make the backup copy, the simulator must be temporarily halted. This is accomplished by pressing `CTRL-E`, that is press and hold the control key, while pressing the lowercase e key once.

```
Simulation stopped, PC: 146644 (ASR R5) ; the instruction may vary from this one
sim> detach rl1
sim> ! cp distribution-backup.dsk RT-11_V5.3_BIN_RL02_BACKUP
sim> ! cp Disks/empty-rl02.dsk  working.dsk
sim> attach rl1 working.dsk
sim> c
```

These commands detach the disk rl1, `distribution-backup.dsk`, then copy that file to `RT-11_V5.3_BIN_RL02_BACKUP`, copy the empty rl02 disk image to working.dsk, and attach it to the simulator. c tells the simulator to return control to RT-11. There won't be a prompt. Simply press return as previously instructed to proceed.

```
Screen 7 - Building Working System Screen
Building Working System

        Your working system disk will now be built automatically. This  disk
        will contain the RT-11 Operating System.
        Select a blank disk and label it: "RT-11 V5.3 BIN RL02 WORKING"
        and mount it in DL1 (Drive 1).

        Press the "RETURN" key when you have mounted the disk.
```

The rl1 working.dsk image is attached and loaded. Press return to build the system and proceed.

```
Screen 8 - Installation Complete Screen
RT-11 V5.3 Installation Complete

        Your working system disk will now be bootstrapped.

        Press the "RETURN" key when ready to continue.
```

The working system has been built. Press return to proceed into the newly built system.

```
Post Installation Screen - Bootstrapped for the first time
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

The dot prompt is ready for commands. At this point, it is important to make one final backup so that if something happens, you can always return the operating system to its pristine installed state.

Stop the simulation, unmount the working disk, make backups, and quit the simulation
Press `CTRL-E`

```
Simulation stopped, PC: 152632 (ADD #163430,R4)

sim> detach rl1
sim> ! cp working.dsk RT-11_V5.3_BIN_RL02_WORKING
sim> quit
Goodbye
```

## Post Installation Cleanup

At this point, you have a working copy and a backup distribution file saved. You can remove the two copies of the blank disk and distribution disk from the working directory and move the backups into the Disks directory.

```
rm distribution.dsk distribution-backup.dsk
mv RT-11_V5.3_BIN_RL02_BACKUP Disks/
mv RT-11_V5.3_BIN_RL02_WORKING Disks/
```

remove the initial.ini file
`rm initial.ini`

Copy in a new blank for use as a storage volume
`cp Disks/empty-rl02.dsk storage.dsk`

The cleaned up area should contain the following folders and files:

```
$ ls -1
Disks
boot.ini
lpt.txt
storage.dsk
working.dsk
```

## Booting into RT-11 for the first time

The boot.ini file is used to configure pdp11 for use with the storage and working disks. Start pdp11:

```
pdp11 boot.ini

PDP-11 simulator V4.0-0 Beta        git commit id: ac837e5b
Overwrite last track? [N]

Choose Y and press return to continue.

The V5USER.TXT file is displayed and a dot prompt presented to the user:
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

## Command Overview

Here are a list of simple commands to get started. Each is typed at the dot prompt. There are two main forms of commands in RT-11, the long form and the short form. The long form is usually entered by typing in a command without arguments. RT-11 then prompts for rational options. The short form is entered by typing a command with its options. Some commands will be very familiar, but their construction may be a little alien.

Most commands can be shortened to the shortest possible unique root. DIRECTORY, for example, can be shortened to DIR.

Just use **upper-case** for everything in RT-11, save yourself some pain.

Here are the commands that I will perform and document below:

#### DIRECTORY aka DIR

Show all of the files in the default directory

#### DIRECTORY/BRIEF aka DIR/BR

A brief form of directory listing

#### DIRECTORY/PRINT aka DIR/PRI

#### DIRECTORY/BRIEF/PRINT aka DIR/BR/PRI

Print the directory listing to the host lpt.txt file (in order to ensure flushed buffers, the simulator needs to be suspended after anything is printed before looking at the text file)

#### SHOW

Display the active configuration of RT-11

#### TYPE FILE

Show the contents of a file to screen

#### PRINT FILE

Print the contents of the file to the host lpt.txt file (suspend the simulator before looking at the file)

#### EDIT FILE

This is the command to execute the editor on RT-11 and it defaults to a visual mode editor KED that requires setup to use. The line editor ED can be used without configuration. Later in the tutorial, I will describe how to configure KED. DO NOT TRY TO USE EDIT BEFORE YOU CONFIGURE IT. It is nearly impossible to exit the editor until it is configured and you will need to stop the simulator to exit. If the file doesn't exist, the program will prompt the user to create it.

OK, in full disclosure you can probably exit by typing F1 (on a Macbook, this is Fn-F1) which is teh KED GOLD key followed by ESC then O then w and at the KED COMMAND: prompt typing QUIT or EXIT depending on whether you want to abort or save respectively and pressing enter (on the Macbook this is Fn-Return). If you have a numeric keypad, you can probably skip all this and press the key at the top left of the keypad then numeric keypad 7, type QUIT or EXIT, and press the numeric keypad enter.

#### EDIT/CREATE FILE

This command will create a file for editing without prompting, unless the file exists, in which case the user will be prompted to overwrite the existing file.

#### MACRO FILE/LIST/CROSSREFERENCE aka MAC FILE/LIST/CROSS

Assemble a MACRO-11 Source file into an object file with machine code

#### LINK FILE/MAP

Link in dependent files and determine where in memory the file will be located.

#### RUN FILE aka R FILE

Execute the file.

## Commands and their output/effect

#### DIRECTORY aka DIR

```
.DIRECTORY

SWAP  .SYS    27  20-Dec-85      RT11AI.SYS    80  20-Dec-85
RT11PI.SYS    95  20-Dec-85      RT11BL.SYS    78  20-Dec-85
RT11SJ.SYS    79  20-Dec-85      RT11FB.SYS    93  20-Dec-85
RT11XM.SYS   106  20-Dec-85      CR    .SYS     3  20-Dec-85
CT    .SYS     6  20-Dec-85      DD    .SYS     5  20-Dec-85
DL    .SYS     4  20-Dec-85      DM    .SYS     5  20-Dec-85
DP    .SYS     3  20-Dec-85      DS    .SYS     3  20-Dec-85
DT    .SYS     3  20-Dec-85      DU    .SYS     8  20-Dec-85
DW    .SYS     5  20-Dec-85      DX    .SYS     4  20-Dec-85
DY    .SYS     4  20-Dec-85      DZ    .SYS     4  20-Dec-85
PD    .SYS     3  20-Dec-85      RF    .SYS     3  20-Dec-85
RK    .SYS     3  20-Dec-85      LD    .SYS     8  20-Dec-85
LP    .SYS     2  20-Dec-85      LS    .SYS     5  20-Dec-85
MM    .SYS     9  20-Dec-85      MS    .SYS    10  20-Dec-85
MT    .SYS     9  20-Dec-85      NL    .SYS     2  20-Dec-85
PC    .SYS     2  20-Dec-85      PI    .SYS    60  20-Dec-85
SL    .SYS    14  20-Dec-85      SLMIN .SYS    12  20-Dec-85
SP    .SYS     6  20-Dec-85      TT    .SYS     2  20-Dec-85
VM    .SYS     3  20-Dec-85      XC    .SYS     4  20-Dec-85
XL    .SYS     4  20-Dec-85      DDX   .SYS     5  20-Dec-85
DLX   .SYS     5  20-Dec-85      DMX   .SYS     5  20-Dec-85
DUX   .SYS     9  20-Dec-85      DWX   .SYS     5  20-Dec-85
DXX   .SYS     4  20-Dec-85      DYX   .SYS     4  20-Dec-85
DZX   .SYS     4  20-Dec-85      LDX   .SYS     8  20-Dec-85
LPX   .SYS     2  20-Dec-85      LSX   .SYS     5  20-Dec-85
MMX   .SYS    10  20-Dec-85      MSX   .SYS    11  20-Dec-85
MTX   .SYS     9  20-Dec-85      NCX   .SYS     9  20-Dec-85
NLX   .SYS     2  20-Dec-85      NQX   .SYS     7  20-Dec-85
PIX   .SYS    68  20-Dec-85      RKX   .SYS     3  20-Dec-85
SLX   .SYS    16  20-Dec-85      SPX   .SYS     6  20-Dec-85
VMX   .SYS     3  20-Dec-85      XCX   .SYS     4  20-Dec-85
XLX   .SYS     4  20-Dec-85      STARTA.COM    61  20-Dec-85
STARTF.COM     5  20-Dec-85      STARTS.COM     1  20-Dec-85
STARTX.COM     8  20-Dec-85      PIP   .SAV    30  20-Dec-85
DUP   .SAV    47  20-Dec-85      DIR   .SAV    19  20-Dec-85
IND   .SAV    56  20-Dec-85      RESORC.SAV    25  20-Dec-85
EDIT  .SAV    19  20-Dec-85      K52   .SAV    54  20-Dec-85
KED   .SAV    58  20-Dec-85      KEX   .SAV    53  20-Dec-85
MACRO .SAV    61  20-Dec-85      CREF  .SAV     6  20-Dec-85
LINK  .SAV    49  20-Dec-85      LIBR  .SAV    24  20-Dec-85
FILEX .SAV    22  20-Dec-85      SRCCOM.SAV    26  20-Dec-85
BINCOM.SAV    24  20-Dec-85      SLP   .SAV    13  20-Dec-85
DUMP  .SAV     9  20-Dec-85      SIPP  .SAV    21  20-Dec-85
BUP   .SAV    50  20-Dec-85      PAT   .SAV    10  20-Dec-85
HELP  .SAV   132  20-Dec-85      SYSMAC.SML    60  20-Dec-85
BATCH .SAV    26  20-Dec-85      ERROUT.SAV    18  20-Dec-85
QUEMAN.SAV    15  20-Dec-85      FORMAT.SAV    24  20-Dec-85
SETUP .SAV    41  20-Dec-85      VTCOM .SAV    24  20-Dec-85
SPEED .SAV     4  20-Dec-85      DATIME.SAV     4  20-Dec-85
DATIME.COM     3  20-Dec-85      LET   .SAV     5  20-Dec-85
SPLIT .SAV     3  20-Dec-85      UCL   .SAV    15  20-Dec-85
VBGEXE.SAV    16  20-Dec-85      TERMID.SAV     3  20-Dec-85
QUEUE .REL    14  20-Dec-85      RTMON .REL     8  20-Dec-85
SPOOL .REL    11  20-Dec-85      VTCOM .REL    27  20-Dec-85
TRANSF.SAV    16  20-Dec-85      TRANSF.TSK    76  20-Dec-85
TRANSF.EXE    45  20-Dec-85      GIDIS .SAV    72  20-Dec-85
ALPH00.FNT     9  20-Dec-85      ODT   .OBJ     8  20-Dec-85
VDT   .OBJ     8  20-Dec-85      VTMAC .MAC     7  20-Dec-85
VTHDLR.OBJ     8  20-Dec-85      SYSLIB.OBJ    54  20-Dec-85
PUTSTR.FOR     2  20-Dec-85      GETSTR.FOR     2  20-Dec-85
MDUP  .SAV    20  20-Dec-85      MBOOT .BOT     1  20-Dec-85
MBOT16.BOT     1  20-Dec-85      MSBOOT.BOT     3  20-Dec-85
MDUP  .MM     56  20-Dec-85      MDUP  .MS     56  20-Dec-85
MDUP  .MT     56  20-Dec-85      DEMOBG.MAC     2  20-Dec-85
DEMOFG.MAC     3  20-Dec-85      DEMOX1.MAC     3  20-Dec-85
DEMOF1.FOR     2  20-Dec-85      DEMOED.TXT     1  20-Dec-85
SAMPLE.KED     4  20-Dec-85      VERIFY.COM     3  20-Dec-85
IVP   .COM    16  20-Dec-85      IVP   .MAC    25  20-Dec-85
MTB   .COM    14  20-Dec-85      FB    .MAC     1  20-Dec-85
SJ    .MAC     1  20-Dec-85      XM    .MAC     1  20-Dec-85
BSTRAP.MAC    70  20-Dec-85      EDTGBL.MAC    33  20-Dec-85
KMON  .MAC   122  20-Dec-85      KMOVLY.MAC   216  20-Dec-85
MTTEMT.MAC    18  20-Dec-85      MTTINT.MAC    46  20-Dec-85
RMONFB.MAC   149  20-Dec-85      RMONSJ.MAC    70  20-Dec-85
TRMTBL.MAC    19  20-Dec-85      USR   .MAC    74  20-Dec-85
XMSUBS.MAC    40  20-Dec-85      BA    .MAC    21  20-Dec-85
CR    .MAC    15  20-Dec-85      CT    .MAC    33  20-Dec-85
DD    .MAC    27  20-Dec-85      DL    .MAC    37  20-Dec-85
DM    .MAC    27  20-Dec-85      DP    .MAC    11  20-Dec-85
DS    .MAC    10  20-Dec-85      DT    .MAC     9  20-Dec-85
DU    .MAC    94  20-Dec-85      DW    .MAC    43  20-Dec-85
DX    .MAC    21  20-Dec-85      DY    .MAC    23  20-Dec-85
DZ    .MAC    18  20-Dec-85      EL    .MAC    17  20-Dec-85
LD    .MAC    47  20-Dec-85      LP    .MAC    14  20-Dec-85
LS    .MAC    35  20-Dec-85      NC    .MAC    43  20-Dec-85
NI    .MAC    22  20-Dec-85      NL    .MAC     3  20-Dec-85
NQ    .MAC    26  20-Dec-85      PC    .MAC     5  20-Dec-85
PD    .MAC    12  20-Dec-85      RF    .MAC     7  20-Dec-85
RK    .MAC    12  20-Dec-85      SP    .MAC    43  20-Dec-85
TJ    .MAC    32  20-Dec-85      TM    .MAC    27  20-Dec-85
TS    .MAC    39  20-Dec-85      TT    .MAC     7  20-Dec-85
VM    .MAC    21  20-Dec-85      XC    .MAC     1  20-Dec-85
XL    .MAC    28  20-Dec-85      FSM   .MAC    32  20-Dec-85
ELCOPY.MAC    15  20-Dec-85      ELINIT.MAC    16  20-Dec-85
ELTASK.MAC     9  20-Dec-85      ERRTXT.MAC     6  20-Dec-85
ERROUT.OBJ    15  20-Dec-85      RTBL  .MAP    22  20-Dec-85
RTSJ  .MAP    22  20-Dec-85      RTFB  .MAP    30  20-Dec-85
RTXM  .MAP    33  20-Dec-85      SYSGEN.COM   230  20-Dec-85
BL    .ANS     9  20-Dec-85      SJFB  .ANS     9  20-Dec-85
XM    .ANS     9  20-Dec-85      CONFIG.COM    27  20-Dec-85
CONFIG.SAV     7  20-Dec-85      V5USER.TXT     3  20-Dec-85
V5NOTE.TXT    41  20-Dec-85      CUSTOM.TXT     9  20-Dec-85
CONSOL.MAC     6  20-Dec-85      NITEST.MAC    22  20-Dec-85
 206 Files, 5023 Blocks
 15359 Free blocks
.
```

#### DIRECTORY/BRIEF aka DIR/BR

```
.DIR/BR

SWAP  .SYS    RT11AI.SYS    RT11PI.SYS    RT11BL.SYS    RT11SJ.SYS
RT11FB.SYS    RT11XM.SYS    CR    .SYS    CT    .SYS    DD    .SYS
DL    .SYS    DM    .SYS    DP    .SYS    DS    .SYS    DT    .SYS
DU    .SYS    DW    .SYS    DX    .SYS    DY    .SYS    DZ    .SYS
PD    .SYS    RF    .SYS    RK    .SYS    LD    .SYS    LP    .SYS
LS    .SYS    MM    .SYS    MS    .SYS    MT    .SYS    NL    .SYS
PC    .SYS    PI    .SYS    SL    .SYS    SLMIN .SYS    SP    .SYS
TT    .SYS    VM    .SYS    XC    .SYS    XL    .SYS    DDX   .SYS
DLX   .SYS    DMX   .SYS    DUX   .SYS    DWX   .SYS    DXX   .SYS
DYX   .SYS    DZX   .SYS    LDX   .SYS    LPX   .SYS    LSX   .SYS
MMX   .SYS    MSX   .SYS    MTX   .SYS    NCX   .SYS    NLX   .SYS
NQX   .SYS    PIX   .SYS    RKX   .SYS    SLX   .SYS    SPX   .SYS
VMX   .SYS    XCX   .SYS    XLX   .SYS    STARTA.COM    STARTF.COM
STARTS.COM    STARTX.COM    PIP   .SAV    DUP   .SAV    DIR   .SAV
IND   .SAV    RESORC.SAV    EDIT  .SAV    K52   .SAV    KED   .SAV
KEX   .SAV    MACRO .SAV    CREF  .SAV    LINK  .SAV    LIBR  .SAV
FILEX .SAV    SRCCOM.SAV    BINCOM.SAV    SLP   .SAV    DUMP  .SAV
SIPP  .SAV    BUP   .SAV    PAT   .SAV    HELP  .SAV    SYSMAC.SML
BATCH .SAV    ERROUT.SAV    QUEMAN.SAV    FORMAT.SAV    SETUP .SAV
VTCOM .SAV    SPEED .SAV    DATIME.SAV    DATIME.COM    LET   .SAV
SPLIT .SAV    UCL   .SAV    VBGEXE.SAV    TERMID.SAV    QUEUE .REL
RTMON .REL    SPOOL .REL    VTCOM .REL    TRANSF.SAV    TRANSF.TSK
TRANSF.EXE    GIDIS .SAV    ALPH00.FNT    ODT   .OBJ    VDT   .OBJ
VTMAC .MAC    VTHDLR.OBJ    SYSLIB.OBJ    PUTSTR.FOR    GETSTR.FOR
MDUP  .SAV    MBOOT .BOT    MBOT16.BOT    MSBOOT.BOT    MDUP  .MM
MDUP  .MS     MDUP  .MT     DEMOBG.MAC    DEMOFG.MAC    DEMOX1.MAC
DEMOF1.FOR    DEMOED.TXT    SAMPLE.KED    VERIFY.COM    IVP   .COM
IVP   .MAC    MTB   .COM    FB    .MAC    SJ    .MAC    XM    .MAC
BSTRAP.MAC    EDTGBL.MAC    KMON  .MAC    KMOVLY.MAC    MTTEMT.MAC
MTTINT.MAC    RMONFB.MAC    RMONSJ.MAC    TRMTBL.MAC    USR   .MAC
XMSUBS.MAC    BA    .MAC    CR    .MAC    CT    .MAC    DD    .MAC
DL    .MAC    DM    .MAC    DP    .MAC    DS    .MAC    DT    .MAC
DU    .MAC    DW    .MAC    DX    .MAC    DY    .MAC    DZ    .MAC
EL    .MAC    LD    .MAC    LP    .MAC    LS    .MAC    NC    .MAC
NI    .MAC    NL    .MAC    NQ    .MAC    PC    .MAC    PD    .MAC
RF    .MAC    RK    .MAC    SP    .MAC    TJ    .MAC    TM    .MAC
TS    .MAC    TT    .MAC    VM    .MAC    XC    .MAC    XL    .MAC
FSM   .MAC    ELCOPY.MAC    ELINIT.MAC    ELTASK.MAC    ERRTXT.MAC
ERROUT.OBJ    RTBL  .MAP    RTSJ  .MAP    RTFB  .MAP    RTXM  .MAP
SYSGEN.COM    BL    .ANS    SJFB  .ANS    XM    .ANS    CONFIG.COM
CONFIG.SAV    V5USER.TXT    V5NOTE.TXT    CUSTOM.TXT    CONSOL.MAC
NITEST.MAC   
 206 Files, 5023 Blocks
 15359 Free blocks

.
```

#### DIRECTORY/PRINT aka DIR/PRI
#### DIRECTORY/BRIEF/PRINT aka DIR/BR/PRI

Both of these commands go to the lpt.txt file on the host. If you want to see the output, press `CTRL-E` to halt the simulation

```
.DIR/PRINT
CTRL-E
Simulation stopped, PC: 152646 (MOV -(R4),R5)
sim> ! cat lpt.txt
```

lots of output, with Form Feed Characters, just like a real printer. The lpt.txt file can later be opened in Textwrangler and printed. The form feeds will be honored.
To return to RT-11, enter `c` a the `sim>` prompt and press `return` - a dot prompt will appear

```
sim> c
.
```

#### SHOW

```
.
SHOW
.show
TT  (Resident)
DL  (Resident)
    DL0 = DK , SY
MQ  (Resident)
LD  
RK  
SL  
DU  
DM  
DP  
DX  
VM  
SP  
MT  
MS  
CT  
LP  
PC  
CR  
NL  
12 free slots
```

The show command tells the user about what devices are active and known to RT-11. At this point, the OS only knows about the SY disk, SY is aliased as DK, DL, and DL0. All of these can serve as volume locators for the files.

That is DIR SY:*.* will have the same effect as DIR as will DIR DK:*.*, DIR DL:*.*, and DL0:*.*. Later in the tutorial, the storage drive will be given an alias VOL: and will be initialized for use as a storage location for files.


#### TYPE FILE

There is a file named CONSOL.MAC in the SY directory. Print its content to the screen.

```
.TYPE CONSOL.MAC  
.MCALL .MODULE
.MODULE CONSOL,VERSION=03,COMMENT=<Change Boot-time Console>

;                       COPYRIGHT (c) 1986 BY
;             DIGITAL EQUIPMENT CORPORATION, MAYNARD, MASS.
;             ALL RIGHTS RESERVED.
;
; THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND  COPIED
; ONLY  IN  ACCORDANCE  WITH  THE  TERMS  OF  SUCH  LICENSE AND WITH THE
; INCLUSION OF THE ABOVE COPYRIGHT NOTICE.  THIS SOFTWARE OR  ANY  OTHER
; COPIES  THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY
; OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE  IS  HEREBY
; TRANSFERRED.
;
; THE INFORMATION IN THIS SOFTWARE IS SUBJECT TO CHANGE  WITHOUT  NOTICE
; AND  SHOULD  NOT  BE  CONSTRUED  AS  A COMMITMENT BY DIGITAL EQUIPMENT
; CORPORATION.
;
; DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE OR  RELIABILITY  OF  ITS
; SOFTWARE ON EQUIPMENT THAT IS NOT SUPPLIED BY DIGITAL.

    .ENABL    LC
    .NLIST    BEX
    .ENABL    GBL

;+
;    PROGRAM TO CHANGE CONSOLE TO ONE OTHER THAN BOOT CONSOLE
;-

    .MCALL    .MTPS,.PRINT,.EXIT

    CSRAD    =: 176500        ;*** NEW CONSOLE INPUT CSR ***
    VEC    =: 300            ;*** NEW CONSOLE VECTOR ***

    SYSPTR    =: 54            ;SYSCOM POINTER TO RMON
        TTKS    =: 304        ;CONSOLE KEYBOARD CSR
        TTKB    =: 306        ;CONSOLE KEYBOARD BUFFER
        TTPS    =: 310        ;CONSOLE PRINTER CSR
        TTPB    =: 312        ;CONSOLE PRINTER BUFFER
        SYSGEN    =: 372        ;OFFSET TO SYSGEN WORD
            MTTY$    =: 20000 ;MULTI-TERMINAL BIT IN SYSGEN WORD

    OLDVEC    =: 60            ;STANDARD CONSOLE VECTOR

    IENABL    =: 100            ;INTERRUPT ENABLE
    PR7    =: 340            ;PRIORITY SEVEN
    PR0    =: 0             ;PRIORITY ZERO

    BMASK    =: 360/<<15.*<VEC-<20*<VEC/20>>>/8.>+1>
    BITMAP    =: 326+<VEC/20>

CONSOL:    MOV    @#SYSPTR,R0        ;R0 => RMON
    BIT    #MTTY$,SYSGEN(R0)    ;MULTI-TERMINAL SYSTEM?
    BNE    2$            ;YES - CAN'T USE THIS TECHNIQUE!
    .MTPS    #PR7            ;GO TO PRIORITY 7 !!!
    BISB    #BMASK,BITMAP(R0)    ;PROTECT NEW CONSOLE VECTORS
    ADD    #TTKS,R0        ;R0 => CONSOLE REGISTER LIST IN RMON
    MOV    #CSR,R1            ;R1 => NEW CSR/DATA REG LIST
    BIC    #IENABL,@(R0)        ;DISABLE OLD INPUT CSR INTERRUPTS
    MOV    (R1)+,(R0)+        ;MOVE IN NEW CSR ADDR
    MOV    (R1)+,(R0)+        ;MOVE IN NEW BUFFER ADDRESS
    BIC    #IENABL,@(R0)        ;DISABLE OLD OUTPUT CSR INTERRUPTS
    MOV    (R1)+,(R0)+        ;MOVE IN NEW CSR ADDR
    MOV    (R1)+,(R0)+        ;MOVE IN NEW BUFFER ADDR
    MOV    #OLDVEC,R0        ;R0 = PRESENT CONSOLE VECTOR
    MOV    @R1,R1            ;R1 = NEW VECTOR
    .REPT    4
    MOV    (R0)+,(R1)+        ;LOAD NEW CONSOLE VECTORS
    .ENDR
    .MTPS    #PR0            ;BACK TO PRIORITY 0
    .EXIT                ;TERMINATE PROGRAM

2$:    .PRINT    #NOMT            ;PRINT ERROR MESSAGE
    .EXIT                ; AND LEAVE

    .NLIST    BEX
NOMT:    .ASCIZ    /?CONSOL-F-Multi-terminal system ... use SET TT CONSOL command/
    .EVEN

CSR:    .WORD    CSRAD            ;CSR/DATA BUFFER/VECTOR LIST
    .WORD    CSRAD+2   
    .WORD    CSRAD+4   
    .WORD    CSRAD+6   
    .WORD    VEC
    .END    CONSOL


.
```

The contents of CONSOL.MAC are sent to the console.

#### PRINT FILE

Print the contents of a file.

```
.PRINT CONSOL.MAC
```

The contents of CONSOL.MAC are sent to the lpt.txt file of the host.

#### EDIT FILE

In order to demonstrate editing. The ED editor must be selected (remember that the KED editor is unusable until it is configured).

`SET EDIT EDIT`

This command will allow the user to edit pages of a file in a buffer. In this tutorial, the EDIT/CREATE command will be used before EDIT. See the EDIT/CREATE command below.
EDIT/CREATE FILE

Be sure that you first ran SET EDIT EDIT or you won't be able to exit KED.

```
.EDIT/CREATE HELLO.MAC
*
```

The edit command has two modes, command mode and edit mode. The asterisk is the command mode prompt. Check the Introduction to RT-11 document for more detailed instructions. For most purposes, the host file editor is far superior to either ED or KED, but these commands are necessary to grasp well enough to get into insert mode and insert text most likely copied into the host's copy/paste buffer. To enter insert mode type I and immediately start entering your text. The following can be copied and pasted at that point of the text:

```
*I    .TITLE HELLO
.MCALL .PRINT,.EXIT   ; tell assembler I want these two from SYSMAC.SML

START:  .PRINT #HELLO ; call OS function to print string, address HELLO
        .EXIT         ; call OS function to terminate the program

HELLO: .ASCIZ /HELLO, WORLD/ ; an ASCII string ending with a zero byte

.END START
Leave a blank line after your text and press the ESC key twice to return to command mode.
[ESC][ESC]
*
```

At the ED command prompt, either type EX followed by the ESC key twice to save your work or CTRL-C twice to abort your work.
`*EX[ESC][ESC]`

Confirm that the file was created:

```
.DIR HELLO.MAC

HELLO .MAC     1                
 1 Files, 1 Blocks
 15358 Free blocks
```

And that it contains the content you entered:

```
.TYPE HELLO.MAC
    .TITLE HELLO
.MCALL .PRINT,.EXIT   ; TELL ASSEMBLER I WANT THESE TWO FROM SYSMAC.SML

START:  .PRINT #HELLO ; CALL OS FUNCTION TO PRINT STRING, ADDRESS HELLO
        .EXIT         ; CALL OS FUNCTION TO TERMINATE THE PROGRAM

HELLO: .ASCIZ /HELLO, WORLD/ ; AN ASCII STRING ENDING WITH A ZERO BYTE

.END START
```

#### MACRO FILE/LIST/CROSSREFERENCE aka MAC FILE/LIST/CROSS 

In order to assemble the file created by the editor into machine code, it is necessary to call upon the assistance of the MACRO-11 assembler included in the RT-11 distribution.

The following command will generate an OBJ file and a LST file containing an assembly listing and useful cross-references.

`.MACRO HELLO/LIST/CROSSREFERENCE`

If there were no errors, there will be no screen output. To see what was generated, display the listing file. The file is printer friendly (landscape mode) output:

```
.TYPE HELLO.LST
HELLO    MACRO V05.03b  00:53  Page 1


      1                        .TITLE HELLO
      2                    .MCALL .PRINT,.EXIT   ; TELL ASSEMBLER I WANT THESE TWO FROM SYSMAC.SML
      3
      4    000000                START:  .PRINT #HELLO ; CALL OS FUNCTION TO PRINT STRING, ADDRESS HELLO
      5    000006                        .EXIT         ; CALL OS FUNCTION TO TERMINATE THE PROGRAM
      6
      7    000010       110        105        114     HELLO: .ASCIZ /HELLO, WORLD/ ; AN ASCII STRING ENDING WITH A ZERO BYTE
    000013       114        117        054
    000016       040        127        117
    000021       122        114        104
    000024       000
      8
      9        000000'            .END START


HELLO    MACRO V05.03b  00:53  Page 1-1
Symbol table

HELLO   000010R      START   000000R      ...V1 = 000003

. ABS.    000000    000    (RW,I,GBL,ABS,OVR)
          000025    001    (RW,I,LCL,REL,CON)
Errors detected:  0

*** Assembler statistics


Work  file  reads: 0
Work  file writes: 0
Size of work file: 9260 Words  ( 37 Pages)
Size of core pool: 12800 Words  ( 50 Pages)
Operating  system: RT-11

Elapsed time: 00:00:00.01
DK:HELLO,DK:HELLO/C=DK:HELLO


HELLO    MACRO V05.03b  00:53 Page S-1
Cross reference table (CREF V05.03)


...V1    1-4  
HELLO    1-4      1-7# 
START    1-4#     1-9  

 
HELLO    MACRO V05.03b  00:53 Page M-1
Cross reference table (CREF V05.03)


...CM5   1-4  
.EXIT    1-2#     1-5  
.PRINT   1-2#     1-4  


.
```

There are 4-5 pages of output. The first page contains line numbers, relative zero addresses, machine code, assembly code, comments and such. The rest of the pages contain a symbol table along with size information and a cross reference of user defined symbols, macro symbols, and if there are errors in the assembly, error codes and line numbers of those errors.

#### LINK FILE/MAP

In order to run a file in RT-11, it must first be linked. The linker will include all of the programs dependencies and will build a map of locations where the file will be loaded into memory.

`.LINK HELLO/MAP`

If there were no errors, there will be no screen output. To see what was generated, display the map file. 

```
.TYPE HELLO.MAP
RT-11 LINK  V08.10     Load Map       Page 1
HELLO .SAV       Title:    HELLO     Ident:             

Section  Addr    Size    Global    Value    Global    Value    Global    Value

 . ABS.     000000    001000 = 256.   words  (RW,I,GBL,ABS,OVR)
      001000    000026 = 11.    words  (RW,I,LCL,REL,CON)

Transfer address = 001000, High limit = 001024 = 266.   words
```

The map file tells the user where their machine code will be loaded into memory. In this case, starting at location 001000.

#### RUN FILE aka R FILE

If there were no errors during assembly or linkage, the program can be run.

```
.RUN HELLO
HELLO, WORLD
```

Note if you link HELLO.MAC and then try to run the executable, you will get an error

```
.MAC HELLO.MAC
.LINK HELLO.MAC
.RUN HELLO.SAV

?MON-F-Trap to 4 000001
```

Otherwise, Celebrate!!!


This is the end of the tutorial perse, what follows are some general notes to make the experience better.

## General Notes

### RT-11FB vs RT-11XM

The distribution is initially set up as RT-11FB. The FB indicates that the system runs in Foreground and Background. Meaning that you can run a single foreground job along with a number of background jobs. Read about it in the docs.

To change over to RT-11XM, with extended memory support beyond 64K, simply copy the correct sys file into the boot area of the boot disk:

```
copy/boot dk0:rt11xm.sys dk0:

.boot dk0:

RT-11XM  V05.03

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

#### Copying and Pasting between the host and RT-11

This is the preferred approach in my view.

Edit text files on the host, using your favorite text editor. Do not let the editor mess with tabs (tabs should be tab characters that are set every 8 characters, basically).

When text is ready to be transferred to RT-11, open a text file using ED or KED and enter insert mode. When the editor is ready, paste the contents of the file into the editor present in the Terminal window. The paste will scroll and perhaps wrap over itself, but the file should paste succesfully. don't do any editing after you paste, exit the editor and save your changes. To see if the file transferred successfully, display it in the console window using TYPE.


To copy files created in RT-11 to the host, you have two options. TYPE the file and copy the text from the Terminal window into your text editor. Or PRINT the file and suspend the simulation to view the lpt.txt file on the host. It will contain a formatted version of the file ready for printing to a printer.

#### KED Preparation and Use

KED is easier in some ways to use than ED. However, it is not without its quirks and requires some host configuration.

On a Mac, in the Terminal Preferences, set the following options:

> Profiles-Keyboard
> 
> F5 - change the action to send text and enter:
\033Ow. This will set the F5 key to send the Terminal the escape code for Keypad Mode COMMAND key. F1 already sends \033OP which is Keypad Mode GOLD Key
>
> Check Use Option as Meta Key
>
> Profiles-Advanced
> 
> Under Input
> 
> Uncheck delete sends Control-H
>
> Check Paste newlines as carriage returns
>
> Check Allow VT100 application keypad mode
>
> Check Scroll to bottom on input

Alternatively download and build xterm (the one that is distributed with the Mac lacks a significant number of features). See below:

Fire up KED and edit away, it should look like other screen oriented text editors.

Press PF1 (Fn-F1) then PF5 (Fn-F5) then type QUIT to exit without saving, or EXIT to save, then press Fn-Enter

Use CTRL-C if presented with * or $ prompts

I am uncertain as to how well the editor works as an editor, it doesn't appear to handle the scroll offscreen very well in terminal. But, you can paste pretty much anything in and ignore how it looks when you exit and it should come out right when you type or print it.

#### Real xterm

xterm is definitely a more faithful vt100 emulation than Terminal. KED works flawlessly in an xterm session, even when pasting large amounts of text.

Any use of X11 on Mac requires that X windows support is enabled on the Mac. This is accomplished by installing XQuartz, available at http://www.xquartz.org/

xterm is supported and actively maintained by Thomas Dickey at http://invisible-island.net/xterm/

Create a working directory to hold the xterm source and change into it.

```
mkdir xterm-src
cd xterm-src
Download, unzip the source, and change into the source directory
curl -O http://invisible-island.net/datafiles/release/xterm.tar.gz
tar xvf xterm.tar.gz

cd xterm-320/
```

##### configure using Thomas Dickey's settings for OSX

```
./configure --enable-256-color \
--enable-builtin-xpms \
--enable-dabbrev \
--enable-dec-locator \
--enable-exec-xterm \
--enable-hp-fkeys \
--enable-load-vt-fonts \
--enable-logfile-exec \
--enable-logging \
--enable-mini-luit \
--enable-paste64 \
--enable-readline-mouse \
--enable-rectangles \
--enable-regis-graphics \
--enable-sco-fkeys \
--enable-sixel-graphics \
--enable-tcap-fkeys \
--enable-tcap-query \
--enable-toolbar \
--enable-wide-chars \
--enable-xmc-glitch \
--with-app-defaults=auto \
--with-icondir=auto \
--with-pixmapdir=auto \
--with-terminal-type=xterm-new \
--with-utempter \
--with-xpm \
--with-setuid
```

Create and edit the `~/.Xresources` file to suit, this one works. If you already a .Xwhatever file, incorporate the appropriate lines from this one into existing one, after you back it up first.

```
vi ~/.Xresources
~/.Xresources
## XTERM SETTINGS
## see /usr/X11R6/lib/X11/doc/html/xterm.1.html
## or man xterm
*XTerm*deleteIsDEL:              true
    xterm*faceName: DejaVu Sans Mono Book
    xterm*faceSize: 11
    xterm*saveLines:             10000
    xterm*scrollBar:             true
    xterm*rightScrollBar:        true
    xterm*jumpScroll:            true
    xterm*cursorColor:           #676767
    xterm*pointerColor:         #676767
    xterm*colorBD:               darkblue
    xterm*colorBDMode:           true
    xterm*highlightColor:        #676767
    xterm*activeIcon:            false
    xterm*scrollTtyOutput:       false
    xterm*scrollKey:             true

    xterm*Background:            #040701
    xterm*Foreground:            #00FF00

## TERMINAL KEY SETTINGS
## Adjust to OSX Terminal.app behaviour
*VT100.translations: #override\
    <Key>BackSpace:             string(0x7F)\n\
    <Key>Prior:                 scroll-back(1,pages) \n\
    <Key>Next:                  scroll-forw(1,pages)\n\
    <Key>F5: string(\033Ow)\n\
    Meta <Key> K:               send-signal(int) clear-saved-lines() \n\
    Meta <Key> P:               print() \n\
    Meta <Key> minus:           smaller-vt-font() \n\
    Meta <Key> KP_Subtract:     smaller-vt-font() \n\
    Meta <Key> plus:            larger-vt-font() \n\
    Meta <Key> KP_Add:          larger-vt-font() \n\
    Meta <Key> C:               select-cursor-start() \
                                select-cursor-end(PRIMARY, CUT_BUFFER0) \n\
    Meta <Key> V:               insert-selection(PRIMARY, CUT_BUFFER0) \n\
    Meta <Key> M:               iconify() \n\


## EXTRA SETTINGS FOR XAW SCROLLBAR
## see /usr/X11R6/include/X11/Xaw/Scrollbar.h
## for full reference of available recources
*Scrollbar.background:          gray50
*Scrollbar.foreground:          gray50
*Scrollbar.borderWidth:         0
*Scrollbar.shadowWidth:         0
*Scrollbar.thickness:           14
*Scrollbar.minimumThumb:        20
*Scrollbar.backgroundPixmap: gradient:horizontal?dimension=14&start=gray80&end=white
*Scrollbar.borderPixmap: gradient:horizontal?dimension=14&start=white&end=grey80

*Scrollbar.translations: #override\
     <Btn2Down>:   StartScroll(Forward) \n\
     <Btn1Down>:   StartScroll(Continuous) MoveThumb() NotifyThumb() \n\
     <Btn3Down>:   StartScroll(Backward) \n\
     <Btn1Motion>: MoveThumb() NotifyThumb() \n\
     <BtnUp>:      NotifyScroll(Proportional) EndScroll()


Make xterm
make
```

Test the xterm

`./xterm`

> Applicable XQuartz Preferences
> 
> Input
> 
> Check Emulate three button mouse
> 
> Pasteboard
> 
> Enable syncing
> 
> Update Pasteboard when CLIPBOARD Changes
> 
> Update CLIPBOARD when Pasteboard Changes
> 
> Update PRIMARY (middle-click) when Pasteboard Changes
> 
> Uncheck Update Pasteboard immediately when new text is selected

This xterm has a mouse accessible menu bar. If you don't like it, use xterm +tb instead. Menus in xterm are available even with the menu bar. To access them with the settings as above. CTRL-Click with the mouse button to activate the Main menu. CTRL-ALT-Click to activate the VT Options Menu, and CTRL-COMMAND-Click to activate the VT Fonts menu. To paste the contents of the Pasteboard, fn-Alt to paste. To copy, simply select text and use XQuart's menu item, Edit->Copy.

In RT-11, using KED, xterm enables the use of GOLD and COMMAND keys by mapping their escape codes to F1 and F5, respectively. So, after editing a file in KED the following keypresses will allow the user to exit or quit KED:

Press `GOLD - fn-F1` then `COMMAND fn-F5` then at the COMMAND: prompt type `QUIT` or `EXIT` and press `ENTER` - `fn-return` to exit.

If you like xterm well enough, install it:

```
sudo make install
sudo make install-ti
```

If you want a pdf of the man page make one:

```
groff -t -mandoc /opt/X11/share/man/man1/xterm.1 > xterm.ps
ps2pdf xterm.ps
rm xterm.ps
mv xterm.ps whereever
```

Alternatively, download macwise terminal and set it to:

> emulate VT100
> 
> open keyboard and remap PF5
> 
> PF1 - {ESOP
> 
> PF5 - {ESOw

### Initializing the Storage Volume

This takes two commands:

assign and initialize

```
assign DL1: VOL:
initialize VOL:
DL1:/Initialize; Are you sure? Y

.dir VOL:


 0 Files, 0 Blocks
 20382 Free blocks
```

Then you can copy files to VOL:...

*post added 2022-11-30 12:29:00 -0600*
---
layout:	post
title:	"Franz LISP Opus 32 in 3BSD running on an emulated VAX 780"
date:	2023-07-31 07:03:00 -0600
categories:	LISP
---
## Overview
This note describes how to set up and run Franz LISP Opus 32 running on 3BSD running on an emulated VAX 780. This version of Franz LISP is Opus 32 and it is a LISP 1.5 derived LISP from 1979.

![one](/assets/img/lisp/Terminal_004.png)

<!--more-->
Wikipedia notes:

> In computer programming, Franz Lisp is a discontinued Lisp programming language system written at the University of California, Berkeley (UC Berkeley, UCB) by Professor Richard Fateman and several students, based largely on Maclisp and distributed with the Berkeley Software Distribution (BSD) for the Digital Equipment Corporation (DEC) VAX minicomputer. Piggybacking on the popularity of the BSD package, Franz Lisp was probably the most widely distributed and used Lisp system of the 1970s and 1980s.

> The name is a pun on the composer and pianist Franz Liszt.

## Resources 

* **3BSD Tape File** [https://sourceforge.net/projects/bsd42/files/Install%20tapes/3%20BSD/](https://sourceforge.net/projects/bsd42/files/Install%20tapes/3%20BSD/)

* **Franz Lisp Manual - Opus 38.69 from 1982** [https://www.softwarepreservation.org/projects/LISP/franz/Franz_Lisp_July_1983.pdf](https://www.softwarepreservation.org/projects/LISP/franz/Franz_Lisp_July_1983.pdf)

This is the earliest manual I could find. When you're online in 3BSD, there is documentation for the Franz LISP Opus 32, in `/usr/doc/lisp`.

* **Gunkies 3BSD Page** [https://gunkies.org/wiki/3BSD](https://gunkies.org/wiki/3BSD)

An invaluable resource for getting things up an running with a minimum of fuss.

* **OpenSIMH** [https://opensimh.org/](https://opensimh.org/)

The simulator I'm using.

## Prerequisites

* Linux - I'm running Debian 12 (bookworm)
* A build environement (make, cc, and ld) - build-essential package on debian systems
* OpenSIMH - any reasonably recent version should work

## Overview

Much of this note is based on the Gunkies 3BSD page. Specifically, tboot.ini, dboot.ini, uudecode, and the 3BSD boot block are from that page [https://gunkies.org/wiki/3BSD](https://gunkies.org/wiki/3BSD). This note is just organized differently and getting 3BSD running here, is specifically for running Franz LISP.

## Getting Started

* Create a workarea

```
mkdir -p ~/workarea/retro/franz/{dist,work}
cd ~/workarea/retro/franz/dist
```

* Download 3BSD and a bootblock

```
wget https://decuser.github.io/assets/files/lisp/3bsd.tap.bz2
wget https://decuser.github.io/assets/files/lisp/boot3bsd
```

* Verify you have the right files

```
shasum *
f8b59d933896678f04e9a0b0284466563d650c24  3bsd.tap.bz2
482464bbd3ceb8ec9f02036ad06dbe5a181572e2  boot3bsd
```

* Unpack the tape file and copy the bootblock into work

```
cd ../work
bzcat ../dist/3bsd.tap.bz2 > 3bsd.tap
cp ../dist/boot3bsd .
```

* Create an ini file for booting from tape

```
cat <<EOF >tboot.ini
set tto 7b
set rq dis
set lpt dis
set rl dis
set hk dis
set rq dis
set rqb dis
set rqc dis
set rqd dis
set ry dis
set ts dis
set tq dis
set dz lines=8
set rp0 rp06
at rp0 rp06.disk
set tu0 te16
at tu0 3bsd.tap
D 50000 20009FDE
D 50004 D0512001
D 50008 3204A101
D 5000C C113C08F
D 50010 A1D40424
D 50014 008FD00C
D 50018 C1800000
D 5001C 8F320800
D 50020 10A1FE00
D 50024 00C139D0
D 50028 04c1d004
D 5002C 07e15004
D 50030 0000f750
go 50000
go 0
EOF
```

## Build the system

* Boot to tape

```
vax780 tboot.ini
/home/wsenn/workarea/retro/franz/work/tboot.ini-15> at rp0 rp06.disk
%SIM-INFO: RP0: Creating new file: rp06.disk
/home/wsenn/workarea/retro/franz/work/tboot.ini-17> at tu0 3bsd.tap
%SIM-INFO: TU0: Tape Image '3bsd.tap' scanned as SIMH format

HALT instruction, PC: 00050033 (HALT)
=
```

* Restore Unix

`=` is the tape's minimal OS prompt. From here we will make a new filesystem on the rp06 and restor unix from the tape to the disk.
```
=mkfs
file sys size: 7942
file system: hp(0,0)
isize = 5072
m/n = 3 500
=restor
Tape? ht(1,1)
Disk? hp(0,0)
Last chance before scribbling on disk. 
End of tape
=
```

Press enter after `Last chance before scribbling on disk.` to continue.

* Restore `/usr`

Boot Unix, make a new fileystem for /usr, and restore it from tape.

```
=boot

Boot
: hp(0,0)vmunix
61856+61008+70120 start 0x4B4
VM/UNIX (Berkeley Version 2.7) 2/10/80 
real mem  = 8323072
avail mem = 8062976
ERASE IS CONTROL-H!!!
# /etc/mkfs /dev/rrp0g 145673
isize = 65488
m/n = 3 500
# /etc/mount /dev/rp0g /usr
# cd /usr
# cp /dev/rmt5 /dev/null
# cp /dev/rmt5 /dev/null
# tar xbf 20 /dev/rmt1
# 
```

The restore can take a couple of minutes, be patient. The two lines:

```
# cp /dev/rmt5 /dev/null
# cp /dev/rmt5 /dev/null
```

Are just a way to get the tape device to fast forward to the tape file we want.

* Cleanly shut unix down

First we will sync and unmount any mounted devices, then we will sync our system. This is the "normal" way to shut down the unix environment in simh

```
# sync
# sync
# sync
# cd /
# /etc/umount /dev/rp0g
# sync
# sync
# sync
# ^E
Simulation stopped, PC: 8000085F (BLBC 80010FA0,8000085F)
sim> q
Goodbye
$
```

* Backup the baseline system

`tar cvzf rp06-baseline.tar.gz rp06.disk`

## Boot the system and run Franz LISP

* Create a disk boot ini

```
cat <<EOF >dboot.ini
set tto 7b
set rq dis
set lpt dis
set rl dis
set hk dis
set rq dis
set rqb dis
set rqc dis
set rqd dis
set ry dis
set ts dis
set tq dis
set dz lines=8
set rp0 rp06
at rp0 rp06.disk
set tu0 te16
load -o boot3bsd 0
go 2
EOF
```

* Boot to disk

```
$ vax780 dboot.ini

VAX 11/780 simulator Open SIMH V4.1-0 Current        simh git commit id: cf47a20f

Boot
: 
```

At the `:` prompt, provide the location of the kernel, `hp(0,0)vmunix`

```
: hp(0,0)vmunix
61856+61008+70120 start 0x4B4
VM/UNIX (Berkeley Version 2.7) 2/10/80 
real mem  = 8323072
avail mem = 8062976
ERASE IS CONTROL-H!!!
# 
```

Change the root password. It needs to be at least 6 characters long.

```
# passwd root
New password:
Retype new password:
# 
```

To go into multi-user mode, press `^d`. this will allow you to login. Login as root with the new password.

```
#^D
Sat Aug 30 06:40:18 PDT 1980
entering rc
clearing mtab
mounting /usr on /dev/rp0g
preserving Ex temps and clearing /tmp
starting update
starting cron
leaving rc


Virtual VAX/UNIX (Ernie Co-vax)

login: root
Password:

Welcome to Virtual Vax/UNIX.
ERASE IS CONTROL-H!!!
#
```

* Run Franz LISP Opus 32

Run Franz in all of its 1979 glory! Type `(exit)` at the `->` prompt when you are ready to leave the lisp environment.

```
# lisp
Franz Lisp, Opus 32
-> (+ 4 4)
8
-> (car (cdr '(Hi there)))
there
->(exit)
#
```

* Celebrate by backing up the working instance

```
# sync
# sync
# sync
# ^E
Simulation stopped, PC: 8000085F (BLBC 80010FA0,8000085F)
sim> q
Goodbye
$ tar cvzf rp06-working.tar.gz rp06.disk
rp06.disk
$ 
```

Now, anytime you want to run franz lisp, just reenter the directory with your dboot.ini and rp06.disk and type `vax780 dboot.ini`, boot the unix kernel, hit ^d at the prompt, and login as root with your new password!

Here's a typical session:

![one](/assets/img/lisp/Terminal_004.png)

## Creating the bootblock from uuencoded sources

boot3bsd, the bootblock was created from Gunkies uuencoded source [http://gunkies.org/wiki/3BSD_bootsector](http://gunkies.org/wiki/3BSD_bootsector), using Gunkies uudecode program [http://gunkies.org/wiki/Uudecode](http://gunkies.org/wiki/Uudecode). Here is the process I followed to create the bootblock:

* Download uudecode source from above and save it as `uudecode.c``.

* Download uuencoded bootblock from above and save it as `boot3bsd.uu`

* Compile uudecode and use it to unencode the bootblock.

```
cc -o uudecode uudecode.c
./uudecode boot3bsd.uu
```
Ignore the warnings, they're irrevant to this process.


* Confirm the result

```
shasum boot3bsd
482464bbd3ceb8ec9f02036ad06dbe5a181572e2  boot3bsd
```

That's it.

Later - Will

*post added 2023-07-31 11:55:00 -0600*

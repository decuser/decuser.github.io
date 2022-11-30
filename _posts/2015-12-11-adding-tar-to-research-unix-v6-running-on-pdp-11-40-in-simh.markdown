---
layout:	post
title:	adding-tar-to-research-unix-v6-running-on-pdp-11-40-in-simh
date:	2015-12-11 20:14:00 -0600
categories:	general unix research-unix v6
---

# Adding tar to Research Unix Version 6 Running on a PDP 11/40 in SimH

This note explains an approach to getting a working version of tar running on Research Unix Version 6 (v6) running in a SimH PDP-11/40 Simulator.

NOTE: After working at this for a bit, it is clear to me that while this is workable as a solution to move files from v6 to v7, it is not workable as a true tar for v6. The program has difficulty with directories, timestamps and such when working natively on v6. The issues are not with the instructions outlined below, but rather with limitations of the original program as delivered with v7. More investigation is required to understand its limitations.

## Prerequisites

You need to have a working v6 and v7 instance. If that is not the case, get them running by follow the instructions located at:

* [Version 6]({% post_url 2015-11-23-installing-and-using-research-unix-v6-in-simh-pdp-11-40-emulator %})
* [Version 7]({% post_url 2015-12-07-installing-and-using-research-unix-v7-in-simh-pdp-11-45-and-70-emulators-rev-1.0 %})

You will need to have the document [https://www.tuhs.org/Archive/Documentation/PUPS/Setup/v7_setup.html](https://www.tuhs.org/Archive/Documentation/PUPS/Setup/v7_setup.html) by Charles Haley and Dennis Ritchie close at hand.

## Getting Started, a bit of background

Locate the section entitled, Converting Sixth Edition Filesystems, at the bottom of the document, and read it. It is brief. This section describes the basic approach we will use to get tar running on v6. According to Haley and Ritchie, tar is the best method for converting a file system from v6 to v7, but fortunately it is also a great method for moving multiple files between the two systems, as well as the host, and it gives v6 the tar command, which is the intent of this note.

In order to transfer files from v7 to v6 or v6 to v7, will require shared media. There are several different media that can be shared between the two systems, but the easiest is probably virtual magnetic tape attached to the simulated TU10 of the simulator. In order to share a tape will require making appropriate modifications to the ini files for both instances.

## Create ini files for v6 and v7 with tape sharing

While it may be possible to share a tape device between two concurrently running systems, it is safer/simpler to only connect the shared media to one system at a time.

DO NOT bring up both v6 and v7 at the same time with the same tape file attached!

This v7 ini file makes the following assumptions:

1. You used the instructions previously referenced to create the instance. Therefore:
2. You are running a PDP-11/70 with 2M of memory
3. One rp06 image containing the root filesystem and swap.
4. One rp06 image contains the /usr filesystem.

The tape is created by adding the attach tm0 command to our ini file and associating the tm0 to the file we intend to share as the tape drive.

In the directory containing the v7 instance files:

```
cat > v7-boot.ini <<"EOF"
echo
echo After Disabling XQ is displayed type in boot
echo and at the : prompt type in hp(0,0)unix
echo
set cpu 11/70
set cpu 2M
set cpu idle
set rp0 rp06
att rp0 rp06-0.disk
set rp1 rp06
att rp1 rp06-1.disk
att tm0 shared.tape
boot rp0
EOF
```

Similarly, the v6 ini file makes some assumptions:

1. You used the instructions previously referenced to create the instance. Therefore:
2. You are running a PDP-11/40 without separate I+D
3. One rk05 image contains the root filesystem
4. One rk05 image contains the /usr/source filesystem
5. One rk05 image contains the /usr/doc filesystem
6. Various devices may be attached.

The tape is created by adding the attach tm0 command to our ini file and associating the tm0 to the file we intend to share as the tape drive.

In the directory containing the v6 instance files:

```
cat > v6-boot.ini <<"EOF"
set cpu 11/40
set cpu idle
set tto 7b
attach rk0 rk0
attach rk1 rk1
attach rk2 rk2
attach rk3 rk3
attach ptr ptr.txt
attach ptp ptp.txt
attach lpt lpt.txt
set dci en
set dci lines=8
set dco 7b
att dci 5555
att tm0 shared.tape
boot rk0
EOF
```

## Compiling a version of tar that can run on v6

v7 contains sources for v6tar that can be compiled into executable form in v7. It does not appear possible to build the v6tar binary on a native v6 system without significant work, if at all. Since we have both, we will use v7 to build v6tar and move the binary over to v6, where it will happily execute.

It is worth noting that v7 is capable of building this binary in a couple of ways, one of which is as a binary intended for an 11/45 or 11/70 with separate I+D spaces, and the other of which is as a binary intended for the 11/40 without separate I+D spaces. This second method is required for the PDP-11/40 as configured above.

Start the v7 simulation

```
pdp11 v7-boot.ini

PDP-11 simulator V4.0-0 Beta        git commit id: 0f43551d

After Disabling XQ is displayed type in boot
and at the : prompt type in hp(0,0)unix

Disabling XQ
TM: creating new file
```

Type boot to start the boot loader

```
boot
Boot
:
```

Type hp(0,0)unix to boot the kernel from the first partition of the first disk device.

```
: hp(0,0)unix
mem = 2020544
#

Type CTRL-D to enter multi-user mode
RESTRICTED RIGHTS: USE, DUPLICATION, OR DISCLOSURE
IS SUBJECT TO RESTRICTIONS STATED IN YOUR CONTRACT WITH
WESTERN ELECTRIC COMPANY, INC.
WED DEC 31 21:32:38 EST 1969

login:
```

Go ahead and login as root and cd /usr/src/cmd/tar as per Haley and Ritchie. Then, rather than type make as suggested in the instructions, let's view the makefile

```
login: root
Password:
You have mail.
# cd /usr/src/cmd/tar
# cat makefile
...
v6tar:  tar.o access.o chown.o execl.o ftime.o gtty.o lseek.o stat.o syscall.o time.o
        cc -i -s -O *.o -o v6tar
...
```

The relevant line is `v6tar`, and the compile command, `cc -i -s -O *.o -o v6tar`. `man 1 cc` explains the arguments `-O` (compile time optimization), `*.o` (file glob representing the `.o` files in the directory) and `-o` (create the named output file) and tells the reader than any arguments `cc` doesn't know about are linker arguments. `man 1 ld` tells the reader that `-i` refers to building a binary capable of separate I+D and that `-s` strips the symbol table.

Use ed to edit the makefile and remove the -i parameter. Note that even back in the day, make was sensitive to tabs versus spaces. The line below contains a leading tab.

```
# ed makefile
633
18p
        cc -i -s -O *.o -o v6tar
18c
        cc -s -O *.o -o v6tar
.
w
q
```

check that the change was correct

```
# cat makefile|grep v6tar
v6tar:  tar.o access.o chown.o execl.o ftime.o gtty.o lseek.o stat.o syscall.o time.o
        cc -s -O *.o -o v6tar
```

run make

```
# make v6tar
cc -O -c tar.c
cc -c -O /usr/src/libc/v6/access.c
cc -c -O /usr/src/libc/v6/chown.c
cc -c -O /usr/src/libc/v6/execl.c
cc -c -O /usr/src/libc/v6/ftime.c
cc -c -O /usr/src/libc/v6/gtty.c
cc -c -O /usr/src/libc/v6/lseek.c
cc -c -O /usr/src/libc/v6/stat.c
cc -c -O /usr/src/libc/v6/syscall.s
cc -c -O /usr/src/libc/v6/time.s
cc -s -O *.o -o v6tar
```

Check it to make sure out magic number is 407 (indicating a binary without I+D):

```
# dd if=v6tar bs=128 count=1|od
1+0 records in
1+0 records out
0000000 000407 037040 004224 027466 000000 000000 000000 000001
0000020 170011 016600 000002 005060 177776 010600 162706 000004
0000040 016616 000004 005720 010066 000002 005720 001376 020076
0000060 000002 103401 005740 010066 000004 010067 072364 004767
0000100 001356 022626 010016 004737 026732 104401 004567 036706
0000120 162706 000036 010516 062716 177734 016546 000004 004737
0000140 000674 005726 000167 036672 004567 036652 005016 016500
0000160 000010 072027 000010 016501 000006 042701 177400 050100
0000200
```

Test the binary and create a test tarball from the tar directory

```
# v6tar
tar: usage  tar -{txru}[cvfblm] [tapefile] [blocksize] file1 file2...
tar cvf tar.tar ./*
```

Calculate a v7 16 bit checksum and block count for the binary and tarball

```
# sum v6tar tar.tar
16686    36 v6tar
16929   138 tar.tar
```

## Copy v6tar and tarball to tape for v6

use tp to put the v6tar binary and tarball on tape

```
# tp rm v6tar tar.tar
   2 entries
 174 used
 236 last
End
```

Check that the files were written to tape

```
# tp tm
v6tar
tar.tar
   2 entries
 174 used
 236 last
End
```

Exit v7 by suspending Unix and powering down the simulator
press `CTRL-E`, and type `q` at the `simh>` prompt

## Load v6tar into v6 from v7 tape

On the host, copy the shared.tape file from the v7 directory into the v6 directory

```
Start the pdp-11/40 simulation and login
pdp11 v6-boot.ini

PDP-11 simulator V4.0-0 Beta        git commit id: 0f43551d
Disabling XQ
Listening on port 5555
@unix

login: root
#
```

Set tty settings that make sense
`# stty nl0 cr0`

List the (tape) files on tape

```
# tp tm
v6tar
tar.tar
   2 entries
 174 used
 236 last
END
```

Create a temporary folder to test and cd into it

```
mkdir t
cd t
```

Extract the binary and test tarball

```
# tp xm v6tar tar.tar
END
```

Calculate v6 checksums and block counts for the binary and tarball (they are different than v7)

```
# sum v6tar tar.tar
39535 36
42836 138
```

Test the binary

```
# v6tar
tar: usage  tar -{txru}[cvfblm] [tapefile] [blocksize] file1 file2...
```

Unpack the tarball and confirm that the files transferred ok

```
# v6tar xvf tar.tar
Tar: blocksize = 20
x ./access.o, 168 bytes, 1 tape blocks
x ./chown.o, 212 bytes, 1 tape blocks
x ./execl.o, 328 bytes, 1 tape blocks
x ./ftime.o, 164 bytes, 1 tape blocks
x ./gtty.o, 216 bytes, 1 tape blocks
x ./lseek.o, 468 bytes, 1 tape blocks
x ./makefile, 630 bytes, 2 tape blocks
x ./stat.o, 860 bytes, 2 tape blocks
x ./syscall.o, 196 bytes, 1 tape blocks
x ./tar.c, 16424 bytes, 33 tape blocks
x ./tar.o, 20556 bytes, 41 tape blocks
x ./time.o, 88 bytes, 1 tape blocks
x ./v6tar, 18116 bytes, 36 tape blocks

# sum makefile
44887 2
```

Move v6tar bin directory
`# mv v6tar /bin/tar`

Cleanup the temporary folder

```
cd /
rm -f /t/*
rmdir t
```

## Create a tar archive in v6 and write it to tape for v7 to read

```
cd /usr/sys/ken
tar cv0 ./*
a ./alloc.c 12 blocks
a ./clock.c 6 blocks
a ./fio.c 9 blocks
a ./iget.c 9 blocks
a ./main.c 9 blocks
a ./malloc.c 4 blocks
a ./nami.c 7 blocks
a ./pipe.c 7 blocks
a ./prf.c 5 blocks
a ./rdwri.c 8 blocks
a ./sig.c 13 blocks
a ./slp.c 19 blocks
a ./subr.c 7 blocks
a ./sys1.c 14 blocks
a ./sys2.c 9 blocks
a ./sys3.c 6 blocks
a ./sys4.c 8 blocks
a ./sysent.c 5 blocks
a ./text.c 7 blocks
a ./trap.c 9 blocks
```

Suspend and exit v6
Copy the v6/shared.tape into the v7 directory and start v7

Create a temporary folder and cd into it

```
mkdir t
cd t

# tar xv0
x ./alloc.c, 6082 bytes, 12 tape blocks
x ./clock.c, 2866 bytes, 6 tape blocks
x ./fio.c, 4218 bytes, 9 tape blocks
x ./iget.c, 4399 bytes, 9 tape blocks
x ./main.c, 4559 bytes, 9 tape blocks
x ./malloc.c, 1649 bytes, 4 tape blocks
x ./nami.c, 3432 bytes, 7 tape blocks
x ./pipe.c, 3218 bytes, 7 tape blocks
x ./prf.c, 2301 bytes, 5 tape blocks
x ./rdwri.c, 3726 bytes, 8 tape blocks
x ./sig.c, 6191 bytes, 13 tape blocks
x ./slp.c, 9354 bytes, 19 tape blocks
x ./subr.c, 3445 bytes, 7 tape blocks
x ./sys1.c, 6926 bytes, 14 tape blocks
x ./sys2.c, 4130 bytes, 9 tape blocks
x ./sys3.c, 3048 bytes, 6 tape blocks
x ./sys4.c, 3645 bytes, 8 tape blocks
x ./sysent.c, 2131 bytes, 5 tape blocks
x ./text.c, 3204 bytes, 7 tape blocks
x ./trap.c, 4548 bytes, 9 tape blocks

# sum malloc.c
45621     4
```

*post added 2022-11-30 12:29:00 -0600*

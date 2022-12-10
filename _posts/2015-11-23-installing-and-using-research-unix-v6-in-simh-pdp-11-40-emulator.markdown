---
layout:	post
title:	Installing and Using Research Unix Version 6 in SimH PDP-11/40 Emulator
date:	2015-11-23 13:41:00 -0600
categories:	unix research-unix v6 
---
This note is intended to document the process of running v6 in a PDP-11/40 emulated environment. A subsequent note covers [v7]({% post_url 2015-12-07-installing-and-using-research-unix-v7-in-simh-pdp-11-45-and-70-emulators-rev-1.0 %})
<!--more-->

Minor updates on November 30, 2022.

Helpful Reference Sites:

* Setting up Unix - Sixth Edition: [https://minnie.tuhs.org/PUPS/Setup/v6_setup.html](https://minnie.tuhs.org/PUPS/Setup/v6_setup.html)
* The Unix Heritage Society: [http://www.tuhs.org](http://www.tuhs.org)
* The PDP Unix Preservation Society: [http://minnie.tuhs.org/PUPS](http://minnie.tuhs.org/PUPS)
* The Computer History Simulation Project: [http://simh.trailing-edge.com](http://simh.trailing-edge.com)
* Wolfgang Helbig's notes, tape image, scripts, etc: [http://doc.cat-v.org/unix/v6/operating-systems-lecture-notes/v6](http://doc.cat-v.org/unix/v6/operating-systems-lecture-notes/v6)
* Lion's Commentary on Unix 6th Edition: [http://www.lemis.com/grog/Documentation/Lions/book.pdf](http://www.lemis.com/grog/Documentation/Lions/book.pdf)
* Warren Toomey's work on restoration and archiving: [http://minnie.tuhs.org/](http://minnie.tuhs.org/)

This note details the process of building a working v6 instance from a copy of the original tape distribution. It is worth noting that calling them original bits, as would be obtained from the original tape could be misleading. There are a number of different versions extant, but the Unix Heritage Society, hereafter referred to as tuhs, has provided the public access to all of the versions they believe to most closely match what was on the original tape.

Prerequisites:

* The license - I am using the Caldera Unix Enthusiasts license available at [http://www.tuhs.org/Archive/Caldera-license.pdf](http://www.tuhs.org/Archive/Caldera-license.pdf)
* A working Host - I have used Mac OS X Mavericks, Yosemite, and El Capitan, 10.9-10.11, as well as FreeBSD 10.2. I feel confident that it would work with Linux as well, but I haven't tested it. Basically, any host capable of running SimH should work.
* SimH PDP-11 Emulator - I have used versions 3+, this note is based on using the latest code as of 20151123 available at [https://github.com/simh/simh](https://github.com/simh/simh)
* A distribution tape image - I am using the Ken Wellsch tape because it boots and is stated to be identical to Dennis Ritchie's tape other than being bootable and having a different timestamp on root. Available at [http://www.tuhs.org/Archive/Distributions/Research/Ken_Wellsch_v6/v6.tape.gz](http://www.tuhs.org/Archive/Distributions/Research/Ken_Wellsch_v6/v6.tape.gz)
* The man command and sundry from Wolfgang's work - I will be using enblock and deblock from Wolfgang's work and if you want the man command to work, and you do, you will want to apply Wolfgang's fix for man. The en/deblock utilities and man and other fixes are available in the tarball available at [http://www.tuhs.org/Archive/Distributions/Research/Bug_Fixes/V6enb/v6enb.tar.gz](http://www.tuhs.org/Archive/Distributions/Research/Bug_Fixes/V6enb/v6enb.tar.gz)


## Getting Started

This section describes creating a workspace, downloading the images, and building the enblock and deblock utilities.

Create a working directory (I use retro-workarea in my sandboxes folder):

```
mkdir ~/sandboxes/retro-workarea
cd ~/sandboxes/retro-workarea
```

Get a copy of the distribution tape image:
`curl -O http://www.tuhs.org/Archive/PDP-11/Distributions/research/Ken_Wellsch_v6/v6.tape.gz`

Get a copy of Wolfgang's fixes and the enblock and deblock program source code:
`curl -O http://www.tuhs.org/Archive/PDP-11/Bug_Fixes/V6enb/v6enb.tar.gz`

Unpack the two archives:

```
gunzip v6.tape.gz
tar xvf v6enb.tar.gz
```

Build the enblock and deblock utilities, warnings are non-fatal and are related to the dialect of C that Wolfgang is using:

```
cd v6enb
cc enblock.c -o enblock
cc deblock.c -o deblock
```

Copy the utilities into the working directory and change into that directory:

```
cp enblock ..
cp deblock ..
cd ..
```
## Tape Preparation

This section describes preparing the raw v6 tape image for use with the SimH emulator using the enblock utility program. enblock converts a raw tape image into a format that SimH expects (512 byte blocks, file size markers, and eof marker):

Use enblock to read v6.tape and convert it into dist.tap:
`./enblock < v6.tape > dist.tap`

## Boot from the converted distribution tape - The ini method
Create a tape boot ini file for SimH that will initialize the tape and give us access to the tmrk utility for copying from tape directly to disk without the need for much of an os:

```
cat > tboot.ini << "EOF"
set cpu 11/40
set tm0 locked
attach tm0 dist.tap
attach rk0 rk0
attach rk1 rk1
attach rk2 rk2
attach rk3 rk3
d cpu 100000 012700
d cpu 100002 172526
d cpu 100004 010040
d cpu 100006 012740
d cpu 100010 060003
d cpu 100012 000777
g 100000
EOF
```

I will explain the contents of the ini file in the next section on the manual method.

Start the SimH PDP-11 emulator using the tboot.ini file to control it:
`pdp11 tboot.ini`

What you will see is:

```
PDP-11 simulator V4.0-0 Beta        git commit id: 4a1cf358
Disabling XQ
RK: creating new file
RK: creating new file
RK: creating new file
```

Halt the CPU by typing **CTRL+E** - the machine will break at 100012 and will display:
`Simulation stopped, PC: 100012 (BR 100012)`

## Boot from distribution tape - the manual method
Start the simulator without specifying an ini file:
`pdp11`

Tell SimH that the model we want is PDP-11/40:

```
simh> set cpu 11/40
Disabling XQ
```

Create a magnetic tape device on drive 0, set it locked for write:
`sim> set tm0 locked`

Attach the converted distribution tape to the magnetic tape device:
`sim> attach tm0 dist.tap`

Create three empty formatted disk packs on drives 0, 1, and 2 and attach them as RK05 devices:

```
sim> attach rk0 rk0
RK: creating new file
sim> attach rk1 rk1
RK: creating new file
sim> attach rk2 rk2
RK: creating new file
```

Key in and execute a program at memory location 100000 that loads the tape at address 0. After telling SimH that we intend to insert data into memory, the emulator will display successive word locations. We are providing octal bytes 2, at a time, to match the word size of the PDP-11:

```
sim> id 100000-100012
100000: 012700
100002: 172526
100004: 010040
100006: 012740
100010: 060003
100012: 000777

```

Execute the loaded program:
`simh> g 100000`

Halt the CPU by typing **CTRL+E** - the machine will break at 100012 and will display:
`Simulation stopped, PC: 100012 (BR 100012)`

## Notes up to this point
The tape has virtually moved and the CPU looped (according to Setting up Unix). Halting and restarting the CPU will cause the tape to rewind. The next step will start the program now residing at CPU 0. At this point, I believe that we have loaded the minimal OS from the tape. The tape is composed of 512-byte blocks:

- Blocks 0 - 100 are the tape bootstrap stuff
- Blocks 101 - 4100 are the RK05 root image
- Blocks 4101 - 8100 are the /usr RK05 image
- Blocks 8101 - 12100 are the /doc RK05 image.

Boot blocks for various types of device are stored at different locations:

- Block 100 is the RK05 boot block
- Block 99 is the RP03 boot block
- Block 98 is the RP04 boot block

If you want to use a different source device than the default TU10 (which is what we configured as tm0 attached to dist.tap), or target than RK05 (which is what we configured as rk0), you will need to modify the commands below to use the correct utility and offset for the correct boot block. Here are the rules from Setting Up Unix - Sixth Edition:

If you have TU16 tape say **htrk** instead of **tmrk** in the above example. If you have an RP03 disk, say **tmrp** or **htrp**, and use a **99** instead of **100** tape offset. If you have an RP04 disk, use **tmhp** or **hthp** instead or *tmrk*, and use a **98** instead of **100** tape offset. The different offsets load bootstrap programs appropriate to the disk they will live on.

At this point, all we are interested in are getting the bootstrap program and the root image in order to be able to boot from disk.

## Copy tape objects to disk

Assumes TU10 and RK05 devices, which we selected in tboot.ini)

Run the minimal os loaded at address 0:

```
g 0
=
```

Use the tmrk utility to copy the disk bootstrap program from tape to the disk block 0:

```
=tmrk
disk offset
0
tape offset
100
count
1

```

Use tmrk to copy the root filesystem (tape position 101-4100) to disk

```
=tmrk
disk offset
1
tape offset
101
count 3999
=
```

**CTRL+E** to break the emulation
`Simulation stopped, PC: 137300 (BGE 137274)`

```
sim> q
Goodbye
```

## Boot from disk

simh has a built in boot rom for bootstrapping the disk and loading it's bootblock

```
cat > dboot.ini << "EOF"
set cpu 11/40
set tto 7b
set tm0 locked
attach tm0 dist.tap
attach rk0 rk0
attach rk1 rk1
attach rk2 rk2
attach rk3 rk3
attach ptr ptr.txt
attach ptp ptp.txt
attach lpt lpt.txt
dep system sr 173030
boot rk0
EOF
```

Notes:

* `set tto 7b` - set the terminal output to 7 bits, which is compatible with Unix v6.
* `attach rk3 rk3` - added an extra disk that we can use later... or not...
* `attach ptr ptr.txt` - added a paper tape reader virtual device which will come in handy to transfer files from the host to v6.
* `attach ptp ptp.txt` - added a paper tape punch virtual device which will be useful for transferring files from v6 to the host.
* `attach lpt lpt.txt` - added a virtual line printer that will allow us to print things to the host from v6
* `dep system sr 173030` - Unix will boot the system in single user mode (xref, man 8 boot procedures in v6)
* `boot rk0` - boot using the disk that we installed a boot loader and root filesystem to

Start the Simulator:

```
pdp11 dboot.ini
PDP-11 simulator V4.0-0 Beta        git commit id: 9b7c614b
Disabling XQ
@
```

The **@** symbol is the boot loader prompt. We tell it where the kernel is in relation to our filesystem:

```
@rkunix
mem = 1035
RESTRICTED RIGHTS
Use, duplication or disclosure is subject to
restrictions stated in Contract with Western
Electric Company, Inc.
#
```

If you stop here an look around there will be a number of really interesting, but annoying things happening. Feel free to stop at this point and just get a feel for how alien, but familiar the OS is...

The first annoyance is that uppercase nonsense. To fix:

`#STTY -LCASE`

The second annoyance is the complete lack of a cd command. To fix, you will need to read on.

## Configuration and Installation of a new kernel

Note that even in 1975, a rebuild of the kernel only took 50 seconds.


Build mkconf:
mkconf is what configures the system to support various device types

```
chdir /usr/sys/conf
cc mkconf.c
mv a.out mkconf
```

Run `mkconf` and tell it about our attached devices - rk05's, tape reader and tape punch, magtape, DECtape, serial terminals, and line printer:

```
./mkconf
rk
pc
tm
tc
8dc
lp
done
```

Compile and install the kernel which we will call unix:

* `m40.s` is the machine language assist file
* `c.c` is the configuration table containing the major device switches for each device class, block or character
* `l.s` is the trap vectors for the devices

```
as m40.s
mv a.out m40.o
cc -c c.c
as l.s
ld -x a.out m40.o c.o ../lib1 ../lib2
mv a.out /unix
```

Confirm that the resulting kernel is 30k:

```
ls -l /
-rwxrwxrwx  1 root    30942 Oct 10 13:04 unix
```

Prior to making dev mods, the directory contains:

```
ls /dev
kmem
mem
null
tty8
```

Each of these files is described in section IV of the manual on v6.

Take a look at c.c to understand the device numbers:

```
cat c.c
/*
*/
int     (*bdevsw[])()
{
&nulldev,       &nulldev,       &rkstrategy,    &rktab, /* rk */
&nodev,         &nodev,         &nodev,         0,      /* rp */
&nodev,         &nodev,         &nodev,         0,      /* rf */
&tmopen,        &tmclose,       &tmstrategy,    &tmtab, /* tm */
&nulldev,       &tcclose,       &tcstrategy,    &tctab, /* tc */
&nodev,         &nodev,         &nodev,         0,      /* hs */
&nodev,         &nodev,         &nodev,         0,      /* hp */
&nodev,         &nodev,         &nodev,         0,      /* ht */
0
};
int     (*cdevsw[])()
{
&klopen,   &klclose,  &klread,   &klwrite,  &klsgtty,   /* console */
&pcopen,   &pcclose,  &pcread,   &pcwrite,  &nodev,     /* pc */
&lpopen,   &lpclose,  &nodev,    &lpwrite,  &nodev,     /* lp */
&dcopen,   &dcclose,  &dcread,   &dcwrite,  &dcsgtty,   /* dc */
&nodev,    &nodev,    &nodev,    &nodev,    &nodev,     /* dh */
&nodev,    &nodev,    &nodev,    &nodev,    &nodev,     /* dp */
&nodev,    &nodev,    &nodev,    &nodev,    &nodev,     /* dj */
&nodev,    &nodev,    &nodev,    &nodev,    &nodev,     /* dn */
&nulldev,  &nulldev,  &mmread,   &mmwrite,  &nodev,     /* mem */
&nulldev,  &nulldev,  &rkread,   &rkwrite,  &nodev,     /* rk */
&nodev,    &nodev,    &nodev,    &nodev,    &nodev,     /* rf */
&nodev,    &nodev,    &nodev,    &nodev,    &nodev,     /* rp */
&tmopen,   &tmclose,  &tmread,   &tmwrite,  &nodev,     /* tm */
&nodev,    &nodev,    &nodev,    &nodev,    &nodev,     /* hs */
&nodev,    &nodev,    &nodev,    &nodev,    &nodev,     /* hp */
&nodev,    &nodev,    &nodev,    &nodev,    &nodev,     /* ht */
0
};
int     rootdev {(0<<8)|0};
int     swapdev {(0<<8)|0};
int     swplo   4000;   /* cannot be zero */
int     nswap   872;
```

Note that rk is block device major 0 (the first entry in the array) and that rrk is character device major 9, and so on.

Create special files for each installed device that isn't already there:

```
/etc/mknod /dev/rk0 b 0 0
/etc/mknod /dev/rk1 b 0 1
/etc/mknod /dev/rk2 b 0 2
/etc/mknod /dev/rk3 b 0 3
/etc/mknod /dev/mt0 b 3 0
/etc/mknod /dev/tap0 b 4 0
/etc/mknod /dev/rrk0 c 9 0
/etc/mknod /dev/rrk1 c 9 1
/etc/mknod /dev/rrk2 c 9 2
/etc/mknod /dev/rrk3 c 9 3
/etc/mknod /dev/rmt0 c 12 0
/etc/mknod /dev/ppt c 1 0
/etc/mknod /dev/lp0 c 2 0
/etc/mknod /dev/tty0 c 3 0
/etc/mknod /dev/tty1 c 3 1
/etc/mknod /dev/tty2 c 3 2
/etc/mknod /dev/tty3 c 3 3
/etc/mknod /dev/tty4 c 3 4
/etc/mknod /dev/tty5 c 3 5
/etc/mknod /dev/tty6 c 3 6
/etc/mknod /dev/tty7 c 3 7
```

Secure the special files:

```
chmod 640 /dev/*rk*
chmod 640 /dev/*pp*
chmod 640 /dev/*lp*
chmod 640 /dev/*mt*
chmod 640 /dev/*tap*
chmod 640 /dev/*tty*
```

In order to have a usable system, we will still need to install the sources, the docs, mount them, and edit the rc, and ttys file, and modify and rebuild the df command (I may revisit this note later as Ritchie's notes refer to some other files that need to change).

Restore doc and source from rk05s:

```
dd if=/dev/rmt0 of=/dev/rrk1 count=4000 skip=4100
dd if=/dev/rmt0 of=/dev/rrk2 count=4000 skip=8100
```

Update the superblock (ensures that all output gets written to disk):

```
sync
sync
```

Create mount point for doc and mount both doc and source (source mountpoint already exists):

```
mkdir /usr/doc
/etc/mount /dev/rk1 /usr/source
/etc/mount /dev/rk2 /usr/doc
```

Test that both now have files:

```
ls /usr/source
...

ls /usr/doc
...
```

Add mounts to rc using cat CTRL+D will tell cat that it has hit EOF:

```
cat >> /etc/rc
/etc/mount /dev/rk1 /usr/source
/etc/mount /dev/rk2 /usr/doc
CTRL+D
```


Modify df to show disk free on all devices using ed, the only delivered editor, see below for an ed cheatsheet. I have added rk3, even though, technically it doesn't have a filesystem to check... yet:

```
chdir /usr/source/s1
ed df.c
5p
5d
4
i
"/dev/rk0",
"/dev/rk1",
.
7
i
"/dev/rk3",
.
w
q
```

Compile df and install it if no errors occurred

```
cc df.c
cp a.out /bin/df
```

Test the new df:

```
df
/dev/rk0 989
/dev/rk1 935
/dev/rk2 1691
/dev/rk3 bad free count
```

rk3 doesn't have a file system on it... yet.

Check the drives that have filesystems:

```
icheck /dev/rrk0
dcheck /dev/rrk0
icheck /dev/rrk1
dcheck /dev/rrk1
icheck /dev/rrk2
dcheck /dev/rrk2
```

Modify `/etc/ttys` to enable devices 1-8, these are serial consoles, which we will enable in the final version of our SimH ini file:

```
ed /etc/ttys
1,8s/^0/1/p
w
q
```

Update the superblock and power off:

```
sync
sync
CTRL-E
sim> q
```

The system is functional at this point, but some post installation configuration is helpful/advisable.

## Post Install Notes
The system is ready for a normal multiuser boot with all of the devices attached

### create the normal boot ini file

```
cat > nboot.ini << "EOF"
set cpu 11/40
set cpu idle
set tto 7b
set tm0 locked
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
boot rk0
EOF
```

### boot for the first time
`pdp11 nboot.ini`

The PDP-11 running Unix is now available via telnet:
`telnet localhost 5555`

login as root, with no password

See command notes at bottom for command help

### speed up the terminal cr and lf
set the stty to be a bit faster
`stty cr0 nl0`

### test "printing" from the simulation
if you set up the lp device correctly, lp0 is a character device where text can be redirected, and picked up by simh.
`cat /etc/rc > /dev/lp0`

then on the host, open the lpt.txt file

### add man command

suspend the simulation and mount wolfgang's man.enb tape in the simulator

```
CTRL-E
simh> attach tm0 v6enb/man.enb
co
```

### list the files on the tape

```
tp tm

sav
res
man0/naa.df
man0/tocrc.df
man3/pow.3.df
man3/printf.3.df
man3/rand.3.df
man5/fs.5.df
man5/a.out.5.df
man6/factor.6.df
man6/primes.6.df
/usr/bin/man
/usr/source/s7/nroff1.s

13 entries
45 used
107 last
```

the tape contains a save and restore script, a number fo diff files, the man script, and an nroff1.s assembly file

### restore the files from the tape into /usr/doc/man

```
chdir /usr/doc/man
tp xm res
cat res
```

### restore the files (modify some files)

`sh res`

The error '/usr/source/s7/nroff1.s.df: cannot open` is not fatal and the man command will work fine.


### test man
`man man`

### test that a telnet session from the host works

open a terminal
`telnet localhost 5555`
note the escape character is ^]
press enter if the word login doesn't immediately appear

```
login
stty nl0 cr0
ls
```

Press `CTRL-D` to log out of unix. Press `CTRL-]` to close the telnet session and `q` to quit telnet altogether. Press `CTRL-D` again to close the terminal

### test copying text files to and from the simulator

Because we set up rk03 and ppt above, we can either read and write from /dev/rk03 or /dev/ppt

This test is for the paper tape device, see the longer note on Copying Files for more information


#### on the host, put some text in the ptr.txt file

--snip

```
Hello, v6 from
the HOST!!!

```

--snip

#### in v6, read the file from the ppt device

```
cat > myfile < /dev/ppt
cat myfile
Hello, v6 from
the HOST!!!#
```

----
in v6, write the file to the ppt device
----
cat myfile > /dev/ppt
sync

Press `CTRL-E` to suspend the simulation and type `co` to resume v6

on the host, read the ptp file

Note: as of 20151120.0642pm, it appears to be necessary to suspend the simulator to get anything written to the device. This can be done multiple times, as needed.

### Set up users in v6
Fire up pdp-11

```
@unix
cat >> /etc/passwd
wsenn::10:1::/usr/wsenn:
CTRL+D

mkdir /usr/wsenn
chown wsenn /usr/wsenn
login wsenn
pwd
/usr/wsenn

sync
sync
sync

CTRL+E
sim> q
```

### Back up the working instance (baseline)
On the host:

```
mkdir baseline-v6
cp nboot.ini baseline-v6/
cp rk? baseline-v6/
tar cvzf baseline-v6.tar.gz baseline-v6
cp baseline-v6.tar.gz ../
rm -fr baseline-v6*
```

### test the backup
On the host:

```
cd ..
tar xvf baseline-v6.tar.gz
cd baseline-v6
pdp11 nboot.ini

PDP-11 simulator V4.0-0 Beta        git commit id: 0f43551d
Disabling XQ
PTR: creating new file
PTP: creating new file
LPT: creating new file
Listening on port 5555

@unix

login: wsenn
%

CTRL-E
simh>q

cd ..
rm -fr ./baseline-v6
cd v6-20151121
```

### add cd command using host editor and reading and writing from ppt

Note: `sh` is critically important, **don't muck it up** :).  The issue is that if you do, there really isn't an easy way to recover. Just be careful and don't replace the original shell until you have tested the build. The idea of this fix is simply to add a cd command handler to the existing code. I chose to exactly mimic chdir and use the chdir command itself for simplicity and less chance of error.

```
pdp11 nboot.ini

@unix
root
stty cr0 nl0
```

#### cat to the paper tape punch

`cat /usr/source/s2/sh.c > /dev/ppt`

Press `CTRL-E` to suspend the sim (ensure that the device complete's its write)
and type `co` to continue

open ptp.txt in your favorite editor that doesn't muck with the invisible characters

copy it's contents except for the header and footer lines, but be sure to get every non-header or footer character

edit it
by changing:

```
if(equal(cp1, "chdir")) {
if(t[DCOM+1] != 0) {
if(chdir(t[DCOM+1]) < 0)
err("chdir: bad directory");
} else
err("chdir: arg count");
return;
}
```

to:

```
if(equal(cp1, "chdir")) {
if(t[DCOM+1] != 0) {
if(chdir(t[DCOM+1]) < 0)
err("chdir: bad directory");
} else
err("chdir: arg count");
return;
}
if(equal(cp1, "cd")) {
if(t[DCOM+1] != 0) {
if(chdir(t[DCOM+1]) < 0)
err("cd: bad directory");
} else
err("cd: arg count");
return;
}
```

paste it into `ptr.txt`, be sure to end with an empty line

#### in v6, read from ppt into a new file

`CTRL-E` to suspend

```
detach ptr
attach ptr ptr.txt
co

cat > sh.c.new < /dev/ppt
```
#### compare the new file to the old file

```
diff sh.c.new /usr/source/s2/sh.c
569,576d568
*               if(equal(cp1, "cd")) {
*                       if(t[DCOM+1] != 0) {
*                               if(chdir(t[DCOM+1]) < 0)
*                                       err("cd: bad directory");
*                       } else
*                               err("cd: arg count");
*                       return;
*               }
```

#### figure out how to build and install sh

```
chdir /usr/source/s2
cp sh.c sh.c.original
cp /sh.c.new sh.c

grep sh run
cc -s -n -O sh.c
cmp a.out /bin/sh
cp a.out /bin/sh
```
#### build and install sh

```
cc -s -n -O sh.c
cmp a.out /bin/sh
a.out /bin/sh differ: char 4, line 1
./a.out
```

test that it works - should display a shell prompt and act in every way identically to the previous shell, with the exception that cd  should now work. If it doesn't you will likely need to halt the simulation and reboot. Only if it works, copy it over the original after backing the original up.

```
mv /bin/sh /bin/sh.original
cp a.out /bin/sh
chown bin /bin/sh

CTRL-D
```

relogin

`cd /usr`

Woohoo!

#### backup baseline-v6-withcd

```
mkdir baseline-v6-withcd
cp nboot.ini baseline-v6-withcd/
cp rk? baseline-v6-withcd/
tar cvzf baseline-v6-withcd.tar.gz baseline-v6-withcd
cp baseline-v6-withcd.tar.gz ../
rm -fr baseline-v6-withcd*
```

### Copying Files

From Unix v6 on PDP-11/40 SimH to Host:

#### create and attach an additional rk device

```
simh> attach rk3 rk3
co
```

#### get a file of interest and note it's size in bytes

```
ls -l /etc/rc
-rw-rw-r--  1 bin        90 Oct 10 12:32 /etc/rc
```

#### look at the od dump of the file for comparison later

```
od -c /etc/rc
0000000  r  m     -  f     /  e  t  c  /  m  t  a  b \n
0000020  /  e  t  c  /  u  p  d  a  t  e \n  /  e  t  c
0000040  /  m  o  u  n  t     /  d  e  v  /  r  k  1
0000060  /  u  s  r  /  s  o  u  r  c  e \n  /  e  t  c
0000100  /  m  o  u  n  t     /  d  e  v  /  r  k  2
0000120  /  u  s  r  /  d  o  c \n \n
0000132
```

#### write the file to the rk device
(the sync may not be needed, but the result looks cleaner, also it doesn't apper that you can specify bs=1, device errors out)

```
dd if=/etc/rc of=/dev/rrk03 conv=sync
0+1 records in
1+0 records out
```

#### read it on the host

exit the sim and then on the host, read from the rk image using bs=1 and count from the ls output

```
$ dd if=rk3 of=rc bs=1 count=90
90+0 records in
90+0 records out
```

#### look at the od dump
```
$ od -c rc
0000000    r   m       -   f       /   e   t   c   /   m   t   a b  \n
0000020    /   e   t   c   /   u   p   d   a   t   e  \n   /   e t   c
0000040    /   m   o   u   n   t       /   d   e   v   /   r   k 1
0000060    /   u   s   r   /   s   o   u   r   c   e  \n   /   e t   c
0000100    /   m   o   u   n   t       /   d   e   v   /   r   k 2
0000120    /   u   s   r   /   d   o   c  \n \n
0000132
```

A match!

From Host to Unix v6 on PDP11/40 SimH Host:


#### edit the rc file
make a minor edit to the rc file (change m to n in the word mtab) and note it's size in bytes

```
$ ls -l rc
-rw-r--r--  1 wsenn  staff  90 Nov 20 16:15 rc
```

it better be 90, unless I did something other than changing a letter

#### write rc to a new rk3 file

```
dd if=rc of=rk3 conv=sync
0+1 records in
1+0 records out
512 bytes transferred in 0.000037 secs (13854733 bytes/sec)
```

note the count of blocks

#### read from rk
with the number of blocks on hand, fire up the simulation and read from the rk to disk

`dd if=/dev/rrk3 of=rc.dd count=1`

because of the fact that I can't specify bs=1, the result is padded

```
od -c rc.dd
0000000  r  m     -  f     /  e  t  c  /  n  t  a  b \n
0000020  /  e  t  c  /  u  p  d  a  t  e \n  /  e  t  c
0000040  /  m  o  u  n  t     /  d  e  v  /  r  k  1
0000060  /  u  s  r  /  s  o  u  r  c  e \n  /  e  t  c
0000100  /  m  o  u  n  t     /  d  e  v  /  r  k  2
0000120  /  u  s  r  /  d  o  c \n \n \0 \0 \0 \0 \0 \0
0001000
```

#### read the dd file
read from the dd file with the number of bytes still in hand

```
dd if=rc.dd of=rc bs=1 count=90
90+0 records in
90+0 records out
```

#### then diff the file against the original

```
diff rc /etc/rc
1c1
* rm -f /etc/ntab
---
. rm -f /etc/mtab
```

Success!

## Some confusing, but special points to remember

* there is no vi, use ed (see below)
* there is no cd, use chdir
* characters are not good for pasting, they require an escape \#
* `ctime.README` points the way to successfully compiling stuff:
sometimes you need to be bin, login as bin with no password
the correct command to add an object to a lib is:
ar r ../lib2 myfile.o
* to learn how to compile stuff, the run script in the source directories
are good skeletons. to see how to compile login.c in /usr/source/s1:

    ```
    chdir /usr/source/s1
    ed login.c and make any changes you desire (such as fixing the login:
    prompt which shows Name: on subsequent retries)
    ```
    
* if you can't remember the right commands to compile and install this
program, do the following:

    ```
    grep login run
    cc -s -O login.c
    cmp a.out /bin/login
    cp a.out /bin/login
    ```

* to see who needs to do the compiling

    ```
    ls -l /bin/login
    -rwsr-xr-x  1 root     2606 Oct 10 14:19 /bin/login
    ```

* looks like root in this case, whereas for getty.c:

    ```
    grep getty run
    cc -s -n -O getty.c
    cmp a.out /etc/getty
    cp a.out /etc/getty
    ls -l /etc/getty
    -rwxrwxr--  1 bin      1002 Oct 10 14:09 /etc/getty
    ```

looks like bin.

* As noted in ctime.README, run in /usr/sys does not actually update the libraries

* Before you update libraries, ls -l to see the mode and ownership of the files

    ```
    ls -l /usr/sys/lib?
    -rw-rw-r--  1 bin     59342 Oct 10 13:17 lib1
    -rw-rw-r--  1 bin     48630 Oct 10 13:18 lib2
    ```

* if you try to remove a special file (whatever that is), it will display a mode that is six digits long

    ```
    rm /usr/sys/lib1
    /usr/sys/lib1: 110664 mode

    man 2 stat

    The flags are as follows:
    100000 i-node is allocated
    060000 2-bit file type:
    000000 plain file
    040000 directory
    020000 character-type special file
    060000 block-type special file.
    010000 large file
    004000 set user-ID on execution
    002000 set group-ID on execution
    001000 save text image after execution
    000400 read (owner)
    000200 write (owner)
    000100 execute (owner)
    000070 read, write, execute (group)
    000007 read, write, execute (others)
'''

that makes 110664 read:
the i-node is allocated, it's a large file, it's a plain file, and it is rw-rw-r--.

### ed cheatsheet

* ed is the editor, there is no vi
* ed is ok, here's a quick cheat sheet

`m,nC` - `m` is a starting line number, `n` is an ending line number, `C` is command

The current line is the default target for a command

```
a - append
c - change
d - delete
i - insert
p - print

e - edit file
f - file being edited
r - read file
w - write file
. ends input

s/this/that
```

### Command Help

* find - find files

this command is tricky, but once you get the hang of it, works great!

to find a file use the following syntax -a means "and" and is absolutely required:

```
find / -name tty.h -a -print
/usr/sys/tty.h
```

to find a pattern is straightforward:
`find / -name "tty*" -a -print`

*post added 2022-11-30 12:29:00 -0600*
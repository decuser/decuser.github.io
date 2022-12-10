---
layout:	post
title:	Installing and Using Research Unix Version 7 in SimH PDP-11/45 Emulator
date:	2015-12-07 00:47:00 -0600
categories:	unix research-unix v7
---
This note is intended to document the process of running v7 in a PDP-11/45 emulated environment. A previous note covers [v6]({% post_url 2015-11-23-installing-and-using-research-unix-v6-in-simh-pdp-11-40-emulator %}) originally posted November 23, 2015 and there is a more recent note covering [v7]({% post_url 2017-10-11-installing-and-using-research-unix-v7-in-simh-pdp-11-45-and-70-emulators-rev-1.6 %}).

<!--more-->

Minor updates on November 30, 2022.

Helpful Reference Sites:

* Setting up Unix - Seventh Edition: [https://www.tuhs.org/Archive/Documentation/PUPS/Setup/v7_setup.html](https://www.tuhs.org/Archive/Documentation/PUPS/Setup/v7_setup.html)
* The Unix Heritage Society: [http://www.tuhs.org](http://www.tuhs.org)
* The PDP Unix Preservation Society: [http://minnie.tuhs.org/PUPS](http://minnie.tuhs.org/PUPS)
* The Computer History Simulation Project: [http://simh.trailing-edge.com](http://simh.trailing-edge.com)
* Hellwig Geisse's package, notes, and utilities (mktape and exfs): [https://homepages.thm.de/~hg53/pdp11-unix](https://homepages.thm.de/~hg53/pdp11-unix)
* Warren Toomey's work on restoration and archiving: [http://minnie.tuhs.org/](http://minnie.tuhs.org/)


This note follows the approach laid out in the previous blog entry, [Installing and Using Research Unix Version 6 in SimH PDP-11/40 Emulator]({% post_url 2015-11-23-installing-and-using-research-unix-v6-in-simh-pdp-11-40-emulator %}). It is written for anyone wishing to bring a v7 instance into life on modern hardware. It does not delve deeply into administrative details or installing additional software. At the end of the exercise, the reader will have enough knowledge at hand to bring a working system up and to explore it.

As alluded to in the previous entry, the so-called original bits that will be used are binary copies of original tapes that folks have donated to The Unix Heritage Society, TUHS. They are available to the public.

Prerequisites:

* The license - I am using the Caldera Unix Enthusiasts license available at [http://www.tuhs.org/Archive/Caldera-license.pdf](http://www.tuhs.org/Archive/Caldera-license.pdf)
* A working Host - I have used Mac OS X Mavericks, Yosemite, and El Capitan, 10.9-10.11, as well as FreeBSD 10.2. I feel confident that it would work with Linux as well, but I haven't tested it. Basically, any host capable of running SimH should work.
* SimH PDP-11 Emulator - I have used versions 3+, this note is based on using the latest code as of 20151123 available at [https://github.com/simh/simh](https://github.com/simh/simh)
* A distribution tape image - I am using a tape constructed from Keith Bostic's tape records that appears to be the original distribution. Available at [https://www.tuhs.org/Archive/Distributions/Research/Keith_Bostic_v7](https://www.tuhs.org/Archive/Distributions/Research/Keith_Bostic_v7)


Environment:

These notes are based on having a working SimH environment and a C-compiler installed, such as gcc. 

The configurations that have been tested directly are:

Mac OS X 10.11.1 El Capitan running on a MacBook Pro i7 Quad Core with 16GB RAM and XCode and Homebrew (for gcc) installed
FreeBSD 10.2 running on a Dell Optiplex 755 Core 2 Quad with 8GB RAM with gcc48 installed

## Getting Started

This section describes creating a workspace, downloading the tape records, and constructing a bootable tape image.

Create a working directory (I use `retro-workarea/v7` in my `sandboxes` folder):

```
mkdir ~/sandboxes/retro-workarea/v7
cd ~/sandboxes/retro-workarea/v7
```

Get a copy of Keith Bostic's tape records:

```
curl -O http://www.tuhs.org/Archive/PDP-11/Distributions/research/Keith_Bostic_v7/f0.gz
curl -O http://www.tuhs.org/Archive/PDP-11/Distributions/research/Keith_Bostic_v7/f1.gz
curl -O http://www.tuhs.org/Archive/PDP-11/Distributions/research/Keith_Bostic_v7/f2.gz
curl -O http://www.tuhs.org/Archive/PDP-11/Distributions/research/Keith_Bostic_v7/f3.gz
curl -O http://www.tuhs.org/Archive/PDP-11/Distributions/research/Keith_Bostic_v7/f4.gz
curl -O http://www.tuhs.org/Archive/PDP-11/Distributions/research/Keith_Bostic_v7/f5.gz
curl -O http://www.tuhs.org/Archive/PDP-11/Distributions/research/Keith_Bostic_v7/f6.gz
curl -O http://www.tuhs.org/Archive/PDP-11/Distributions/research/Keith_Bostic_v7/filelist
```

Unpack the tape sections:
`gunzip f?.gz`

The SimH simulator will emulate a TU10 MagTape controller. We need to create a suitable tape image to load into the simulated TU10. We do this by adding each of the tape records along with their lengths and appropriate tape marks into a single file, named v7.tap.

We use the cat command to create a perl script by cutting and pasting the following (up through the line that only contains the text EOF:

```
cat > mktape.pl <<"EOF"
#!/usr/bin/env perl -w
use strict;
# inspired by various perl scripts and based on Hellwig Geisse's mktape.c

my @files = ("f0", "f1", "f2", "f3", "f4", "f5", "f6");
my @blkszs = (512, 512, 512, 512, 512, 10240, 10240);

my $outfile = "v7.tap";

my $EOF = "\x00\x00\x00\x00";
my $EOT = "\xFF\xFF\xFF\xFF";

open(OUTFILE, ">$outfile") || die("Unable to open $outfile: $!\n");
for(my $i = 0; $i <= $#files; $i++) {
my ($bytes, $blocksize, $buffer, $packedlen, $blockswritten, $file) = 0;

$file = $files[$i];
$blocksize = $blkszs[$i];
$packedlen = pack("V", $blocksize);

open(INFILE, $file) || die("Unable to open $file: $!\n");

while($bytes = read(INFILE, $buffer, $blocksize)) {
$buffer .= $bytes < $blocksize ? "\x00" x ($blocksize - $bytes) : "";
print OUTFILE $packedlen, $buffer, $packedlen;
$blockswritten++;
}
close(INFILE);
print OUTFILE $EOF;
printf "%s: %d bytes = %d records (blocksize %d bytes)\n", $file, $blockswritten * $blocksize, $blockswritten, $blocksize;
}
print OUTFILE $EOT
EOF
```

Then we make the perl script runnable and run it

```
chmod u+x mktape.pl
./mktape.pl
f0: 8192 bytes = 16 records (blocksize 512 bytes)
f1: 7168 bytes = 14 records (blocksize 512 bytes)
f2: 512 bytes = 1 records (blocksize 512 bytes)
f3: 11264 bytes = 22 records (blocksize 512 bytes)
f4: 11264 bytes = 22 records (blocksize 512 bytes)
f5: 2068480 bytes = 202 records (blocksize 10240 bytes)
f6: 9594880 bytes = 937 records (blocksize 10240 bytes)
```

To confirm that the correct number of records and block sizes were used, take a look at the filelist file we obtained with the tape sections:

```
cat filelist
file 0: block size 512: 16 records
file 0: eof after 16 records: 8192 bytes
file 1: block size 512: 14 records
file 1: eof after 14 records: 7168 bytes
file 2: block size 512: 1 records
file 2: eof after 1 records: 512 bytes
file 3: block size 512: 22 records
file 3: eof after 22 records: 11264 bytes
file 4: block size 512: 22 records
file 4: eof after 22 records: 11264 bytes
file 5: block size 10240: 202 records
file 5: eof after 202 records: 2068480 bytes
file 6: block size 10240: 937 records
file 6: eof after 937 records: 9594880 bytes
file 7: block size 63:
```

To confirm that this tape is actually byte identical to the author's version,
use openssl to check the sha1 digest:

```
openssl sha1 v7.tap
SHA1(v7.tap)= e6188335c0c9a3e3fbdc9c29615f940233722432
```

With a working distribution tape image, we are ready to fire up a simulator.

## create the initial instance boot file

In the prior entry, I showed both a manual and and ini file method of booting the simulation. In this note, I only show  the ini method. However, I will describe the contents of the file. Just be aware that any commands in the ini file can be entered into the simulator interactively, if desired.

Below is the ini file that will be used during the installation of v7. After the system is installed, a modified version of the ini file will be used for subsequent boots.

The file sets the cpu and allows it to idle. A virtual rp06 moving head disk pack is attached to the simulator and associated with a file on the host as rp0, another is added as rp1, then a virtual TU10 magtape is added and associated with the distribution file we compiled on the host as tm0.

This ini file gives us the following initial configuration:
A PDP-11/45 with two identical, empty, rp06 disk packs, and a TU10 magtape with our v7 distribution tape ready to load.

We use cat again to create the tape.ini file:

```
cat > tape.ini << "EOF"
set cpu 11/45
set cpu idle
set rp0 rp06
att rp0 rp06-0.disk
set rp1 rp06
att rp1 rp06-1.disk
att tm0 v7.tap
boot tm0
EOF
```

## start the initial instance and install from tape

I highly recommend following along with [https://www.tuhs.org/Archive/Documentation/PUPS/Setup/v7_setup.html](https://www.tuhs.org/Archive/Documentation/PUPS/Setup/v7_setup.html) as you work through the rest of this document. Setting up Unix is authoritative for installing Unix v7. With the work we have done up to this point, if you were to leave out the boot tm0 command from the ini file, the instructions can be followed verbatim (talk about durable documentation). However, I will be explaining as we go, so you may want to wait until you have worked along with these instructions before trying to solely rely on the official document.

To run the PDP-11 simulator, we simply execute the simulator and pass the ini file to it:

`pdp11 tape.ini`

The simulator will start, process our ini file, and boot the tape. The simulator will ask if we want to overwrite the last tracks of each rp06. I believe that this is asking permission to write a bad block table on the last track. Answer y and press enter.

```
PDP-11 simulator V4.0-0 Beta        git commit id: 0f43551d
Disabling XQ
RP0: creating new file
Overwrite last track? [N]y
RP1: creating new file
Overwrite last track? [N]y
```

We don't have to key in a boot routine, because SimH has a built in tape rom that works fine. However, if we wanted to we could key in the TU10 boot routine manually and run it.

The simulator will boot the tape and display the word Boot followed by a carriage return and a colon prompt. At this point, no operating system is present. However a tape is loaded and a standalone program called tm is loaded. If we run tm, it will run a program directly from the tape, indexed by the tape controller and file on the tape. It is a zero based index. We want to run the 4th file on the tape, which is a standalone version of mkfs to create a filesystem on the rp06 diskpack. The target device name is hp for the rp06. This time the index refers to the controller and the partition. We want to create a filesystem on the first controller's first partition. This will prepare our disk for a root filesystem.

```
Boot
: tm(0,3)
file sys size: 5000
file system: hp(0,0)
isize = 1600
m/n = 3 500
Exit called
```

Again the `Boot` and `:` prompt will be displayed. Now that a filesystem is prepared, we will use another program from the tape, restor, to populate it. The standalone program restore will take a tape file as input and a disk device as output. The sixth file on the tape is a dump of rp0 (a root filesystem). The same conventions as above apply regarding the indexes:

```
Boot
: tm(0,4)
Tape? tm(0,5)
Disk? hp(0,0)
Last chance before scribbling on disk.
End of tape
```

At this point, a root filesystem is available. We can boot Unix from the root. Using the indexing scheme described above, we can load and run the hptmunix (hp and tm drivers are included) kernel from the root filesystem.

```
Boot
: hp(0,0)hptmunix
mem = 177344
#
```

The system comes up single user. It also comes up with UPPERCASE characters and is slow to print output to the console, which is annoying and weird. We could enter multi-user mode and it would fix this and other annoyances, but because of our remaining low level tasks, it is simpler and more effective to stay in single user mode. In order to fix the console issues, we will use stty to set lowercase and to add no delays to newlines or carriage returns. This will make our console snappy to respond and lower the case:

```
# STTY -LCASE NL0 CR0
```

Typing hp(0,0)hptmunix is a pain, let's shorten it to hp(0,0)unix and get rid of unused kernels in the root filesystem:

```
# mv hptmunix unix
# rm hp*ix
# rm rp*ix
# ls *ix
unix
```

In order to use Unix to complete the installation, we will need to create a number of special files to represent our hardware devices. Special files serve as interfaces between the user and the underlying devices. They are the magic that allows the Unix system to present nearly all hardware to the user as simple files. The special file abstraction maps a filename to a memory vector that points to a limited set of common I/O operations (read, write, getchar, putchar, etc). The device drivers that implements these I/O operations are either part of the operating system, as is the case for all of our devices, or are supplied as add-ons. The makefile in `/dev` contains sections for the most common devices and serves as a template for us to determine what devices we need to instantiate.

The rp06 section in that file looks like this:

```
rp06:
/etc/mknod rp0 b 6 0
/etc/mknod swap b 6 1
/etc/mknod rp3 b 6 7
/etc/mknod rrp0 c 14 0
/etc/mknod rrp3 c 14 7
chmod go-w rp0 swap rp3 rrp0 rrp3
```

The syntax for mknod from man with edits is:
`/etc/mknod name [c][b] major minor`

The first argument is the name of the entry. The second is b if the special file is block-type (buffered, block sized I/O, slower) or c if it is character-type (unbuffered, byte sized I/O, faster, aka raw). The last two arguments are numbers specifying the major device type and minor device (unit, drive, line-number).

For our purposes, we obtain the major device number from the makefile (6 for block-type rp and 14 for character-type rp). The minor device is a number represented by a byte that combines the block device index and the partition.

In order to know what partitions to use requires a bit of detective work, but I will just tell you that partition 7 is the largest available partition for us to use on the disk. The reference for the curious is HP(4), where the original authors describe the rp06 partition scheme.

So, here are the devices we will need to create special files for:
The first rp06, partition 0 is root, partition 1 is swap, we will leave the rest unused for the time being.
The second rp06, partition 7 will be used for /usr.
The magtape

We will manually create block and character devices for each rp06, but we will use make to create the tape device.

According to the makefile, the rp06 major devices are 6 and 14, respectively for block and character devices. The minor numbers are:

for the first drive, drive 0's first partition, it is 00000000, decimal 0.
for the first drive's second partition, it is 00000001, decimal 1.
although, we aren't using it, the first drive's seventh partition would be 00000111, decimal 7
for the second drive, drive 1's seventh partition, it is 00001111, decimal 15

Using this information results in the following commands, which we run to create the special files for the rp06 and give them appropriate permissions:

```
# cd /dev
# /etc/mknod rp0 b 6 0
# /etc/mknod swap b 6 1
# /etc/mknod rp3 b 6 15
# /etc/mknod rrp0 c 14 0
# /etc/mknod rrp3 c 14 15
# chmod go-w rp0 swap rp3 rrp0 rrp3
```

Now, rp0 refers to disk 0, partition 0 (the root device), swap refers to disk 0, partition 1, rp3 refers to disk 1, partition 6 (/usr), rrp0 refers to the raw disk 0, partition 0, and rrp3 refers to the raw disk 1, partition 6.

We use make to create the tape special files (regular device, rewinding device, and non-rewinding device) and set appropriate permissions:

```
# make tm
/etc/mknod mt0 b 3 0
/etc/mknod rmt0 c 12 0
/etc/mknod nrmt0 c 12 128
chmod go+w mt0 rmt0 nrmt0
```

At this point you should have the following special files in /dev:

```
# ls -l
total 2
crw--w--w- 1 root    0,  0 Dec 31 19:02 console
crw-r--r-- 1 bin     8,  1 Jan 10 15:40 kmem
-rw-rw-r-- 1 bin       775 Jan 10 15:26 makefile
crw-r--r-- 1 bin     8,  0 Jan 10 15:39 mem
brw-rw-rw- 1 root    3,  0 Dec 31 19:02 mt0
crw-rw-rw- 1 root   12,128 Dec 31 19:02 nrmt0
crw-rw-rw- 1 bin     8,  2 Jan 23 16:35 null
crw-rw-rw- 1 root   12,  0 Dec 31 19:02 rmt0
brw-r--r-- 1 root    6,  0 Dec 31 19:02 rp0
brw-r--r-- 1 root    6, 15 Dec 31 19:02 rp3
crw-r--r-- 1 root   14,  0 Dec 31 19:02 rrp0
crw-r--r-- 1 root   14, 15 Dec 31 19:02 rrp3
brw-r--r-- 1 root    6,  1 Dec 31 19:02 swap
crw-rw-rw- 1 bin    17,  0 Jan 10 15:40 tty
```

With the devices attached and working and the special files representing them available, it is time to create a filesystem for the /usr partition and copy files from tape into the filesystem. We will use mkfs to create the filesystem and icheck to check the result.

```
# cd /
# etc/mkfs /dev/rp3 322278
isize = 65496
m/n = 3 500
# icheck /dev/rp3
/dev/rp3:
files      2 (r=1,d=1,b=0,c=0)
used       1 (i=0,ii=0,iii=0,d=1)
free  314088
missing    0
```

We will use dd to move the tape to the appropriate starting point (skipping 6 files and setting the tape to point at the seventh file, a dump of rp3). Then we will use restor to restor the files in that tape file. Note that we are reading from nrmt0, the non-rewinding tape device.

```
# dd if=/dev/nrmt0 of=/dev/null bs=20b files=6
202+80 records in
202+75 records out
# restor rf /dev/rmt0 /dev/rp3
last chance before scribbling on /dev/rp3. [press enter]
end of tape
```

Finally, we will mount the newly populated partition on /usr and copy a boot block from that mount to the first block of our first disks' root partition:

```
# /etc/mount /dev/rp3 /usr
# dd if=/usr/mdec/hpuboot of=/dev/rp0 count=1
0+1 records in
0+1 records out
```

The installation is complete. It is a good idea to ensure that the superblocks of our filesystems are written (sync'ed) to disk before we virtually turn the power off:

```
# sync
# sync
# sync
# sync
```
Halt the Unix system by typing CTRL-E

```
# CTRL-E
Simulation stopped, PC: 002306 (MOV (SP)+,177776)
Exit the simulator by tying q at the sim prompt:
sim> q
Goodbye
```

Next, we will create an ini file that is appropriate for normal booting. We'll also upgrade the system to a beefier PDP-11 in the process.

## create the final instance boot file

The following ini file is similar to the initial boot file, with the following changes. First, it includes comments and creates a PDP-11/70 with 2 Megs of memory, without requiring any addition changes or configurations to perform an upgrade. The second change is the removal of the tape, this is optional. The last change is that we boot directly from the rp06 instead of from tape.

```
cat > nboot.ini << "EOF"
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
boot rp0
EOF
```

## start the final instance and enjoy

When running, remember that the simulator will not initially provide a recognizable prompt, just type boot and a colon prompt should appear.

```
pdp11 nboot.ini

PDP-11 simulator V4.0-0 Beta        git commit id: 0f43551d

After Disabling XQ is displayed type in boot
and at the : prompt type in hp(0,0)unix

Disabling XQ
boot
Boot
: hp(0,0)unix
mem = 2020544
#
```

Rather than continuing on to single user mode, it is just a matter of pressing CTRL-D to obtain a properly configured multi-user mode console:

```
# CTRL-D

# RESTRICTED RIGHTS: USE, DUPLICATION, OR DISCLOSURE
IS SUBJECT TO RESTRICTIONS STATED IN YOUR CONTRACT WITH
WESTERN ELECTRIC COMPANY, INC.
WED DEC 31 20:02:48 EST 1969

login: root
Password:
You have mail.
# mail
From bin Thu Jan 11 19:28:15 1979
Secret mail has arrived.

? q
#
```

The system is operational. To exit, write the superblock and halt Unix, then exit the simulation:

```
#sync
#sync
#sync
# CTRL-E
Simulation stopped, PC: 002306 (MOV (SP)+,177776)

Exit the simulator by tying q at the sim prompt:
sim> q
Goodbye
```

Enjoy!

*post added 2022-11-30 15:04:00 -0600*
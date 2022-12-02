---
layout:	post
title:	Quick Setup RT-11v5.3 (Mac/Linux)
date:	2016-01-20 12:17:00 -0600
categories:	pdp-11 rt-11 macro-11s
---
A quick start note for getting up and running with RT-11v5.3 on PDP-11 with little to no fuss.

see [Tutorial - Setting up RT-11 v5.3 on SimH PDP-11 (Dec 30, 2015)]({% post_url 2015-12-30-tutorial-setting-up-rt-11-v5.3-on-simh-pdp-11 %}) for a more verbose version.
<!--more-->

## The Minimalist Version

see **truly minimalist version** section below for a truly minimalist version

### Make a directory and cd into it:

```
mkdir rt-11v5.3
cd rt-11v5.3
```


### Download an RT-11 installation disk and an empty RL02 disk image:

```
curl -O http://www.bitsavers.org/simh.trailing-edge.com/kits/rtv53swre.tar.Z
curl -O http://www.dbit.com/pub/pdp11/empty/rl02.dsk.gz
```

### Unzip the downloaded archives:

```
tar xvf rtv53swre.tar.Z
gunzip rl02.dsk.gz
```

### [Optional] Clean up unneeded files:

```
mkdir backup
mv rtv53swre.tar.Z backup/
mv Disks/rtv53_rl.dsk backup/
mv rl02.dsk backup/
rm -fr Disks/
rm -fr Licenses/
cp backup/rtv53_rl.dsk distribution.dsk
cp backup/rl02.dsk storage.dsk
cp backup/rl02.dsk distribution-backup.dsk
cp backup/rl02.dsk working.dsk
```

### Create an initial.ini file for use with SimH:

```
cat >initial.ini <<"EOF"
set cpu 11/23+ 256K
set tti 8b
set tto 8b
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

### Start simh

```
pdp11 initial.ini

Screen 1 - RT-11 Automatic Installation Process
Press the "RETURN" key when ready to continue.

Press Return Key

Screen 2 - RT-11 Automatic Installation Process
Do you want to use the automatic installation procedure?
(Type YES or NO and press the "RETURN" key):

Type YES and Press Return

Screen 3 - RT-11 Automatic Installation Process
Press the "RETURN" key when ready to continue.

Press Return Key

Screen 4 - Enter Today's Date
Type in the date, then press the "RETURN" key.

Enter the current day and month and the year 88 to get matching weekdays. The distribution is not Y2K compliant.
20-JAN-88

Screen 5 - Backing Up Distribution Disk
Press the "RETURN" key when you have mounted the disk.

The disk is already mounted via the initial.ini file, so press the Return Key

Screen 6 - Backing Up Distribution Disk
Press the "RETURN" key when you have removed the disk

Press CTRL-E to pause the simulation and obtain a sim> prompt
sim> det rl1
sim> ! cp distribution-backup.dsk backup/
sim> att rl1 working.dsk
sim> c
Press the Return key to continue

Screen 7 - Building Working System
Press the "RETURN" key when you have mounted the disk.

The disk is already mounted via your work at the sim> prompt in the prior step, press the Return Key to continue

Screen 8 - RT-11 V5.3 Installation Complete
Press the "RETURN" key when ready to continue.

Press the Return key to boot the new working disk.

The system will display TYPE V5USER.TXT and present you with a dot prompt
.
```

The working system is built.

Exit the simulation by pressing `CTRL-E` to obtain the `sim>` prompt followed by `q`:

```
Simulation stopped, PC: 152644 (BMI 152704)
sim> q
Goodbye
```

### Create a boot.ini file for normal use with SimH:

```
cat >boot.ini <<"EOF"
set cpu 11/70
set cpu fpp
set cpu 4M
set TTI 8B
set TTO 8B
attach LPT lpt.txt
attach PTR ptr.txt
attach PTP ptp.txt

set rl0 writeenabled
attach rl0 working.dsk
set rl1 writeenabled
attach rl1 storage.dsk
set rl1 badblock

boot rl0
EOF
```

### Start the new system:

`pdp11 boot.ini`

Be sure to answer Y to the Overwrite last track? [N] prompt, or the initialization of the storage volume will report bad blocks. In the future, there will be no need to overwrite the track.

### Initialize the storage volume

`.initialize dl1:`

### Assign the shortcut vol: to the storage volume:

```
.assign dl1: vol:
.dir vol:


0 Files, 0 Blocks
10172 Free blocks

.
```

The assignment of `dl1:` to the shortcut `vol:` will only last as long as you are logged in. To make it permanent, add it to `STARTF.COM`:

`edit startf.com`

scroll to the bottom of the file and add:

`ASSIGN DL1: VOL:`

When you are finished editing the file exit and save the file. The key presses required to exit are `GOLD-COMMAND` and type `EXIT `at the `Command:` prompt followed by pressing `ENTER`. If you have followed my previous tutorial, you will have mapped the `GOLD` and `COMMAND` keys to `F1` and `F5 `respectively. If you have a numeric keypad, `GOLD` is the top-left key, `COMMAND` is 7, and `ENTER `is the enter key on the numeric keypad. If these are not available, the escape sequence for `GOLD` is `[ESC]OP`, the escape key followed by the upper case letter O followed by the upper case letter P. Command is `[ESC]Ow`, note the lower case w. Finally, if you are using a Macbook, the function keys and enter key require that you press the `fn` key, so `F1` becomes `fn-F1`.

RT-11 does not require a particularly graceful shutdown, just halt the simulation and exit it:

```
CTRL-E
Simulation stopped, PC: 152660 (BIT #100200,(R5))
sim> q
Goodbye.
```

Future booting can be accomplished by:

`pdp11 boot.ini`


## The Truly Minimalist version

Here is the minimalist version sans the bulk of the comments:

```
mkdir rt-11v5.3
cd rt-11v5.3
curl -O http://www.bitsavers.org/simh.trailing-edge.com/kits/rtv53swre.tar.Z
curl -O http://www.dbit.com/pub/pdp11/empty/rl02.dsk.gz
tar xvf rtv53swre.tar.Z
gunzip rl02.dsk.gz
mkdir backup
mv rtv53swre.tar.Z backup/
mv Disks/rtv53_rl.dsk backup/
mv rl02.dsk backup/
rm -fr Disks/
rm -fr Licenses/
cp backup/rtv53_rl.dsk distribution.dsk
cp backup/rl02.dsk storage.dsk
cp backup/rl02.dsk distribution-backup.dsk
cp backup/rl02.dsk working.dsk
```

```
cat >initial.ini <<"EOF"
set cpu 11/23+ 256K
set tti 8b
set tto 8b
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

```
cat >boot.ini <<"EOF"
set cpu 11/70
set cpu fpp
set cpu 4M
set TTI 8B
set TTO 8B
attach LPT lpt.txt
attach PTR ptr.txt
attach PTP ptp.txt

set rl0 writeenabled
attach rl0 working.dsk
set rl1 writeenabled
attach rl1 storage.dsk
set rl1 badblock

boot rl0
EOF
```

### Start Installation

```
pdp11 initial.ini

Overwrite last track? [N] PRESS RETURN
PRESS RETURN
TYPE YES and PRESS RETURN
PRESS RETURN
TYPE 20-JAN-88 and PRESS RETURN
PRESS RETURN
PRESS CTRL-E
Simulation stopped, PC: 146740 (MOV PC,R5)
sim> det rl1
sim> att rl1 working.dsk
sim> c
PRESS RETURN
PRESS RETURN

At the dot prompt, press CTRL-E
.
Simulation stopped, PC: 152624 (CLRB @#177776)
sim> q
Goodbye
```

### Start the regular system:

```
pdp11 boot.ini

Overwrite last track? [N] TYPE Y and PRESS RETURN

.initialize dl1:
DL1:/Initialize; Are you sure? Y

.assign dl1: vol:

.dir vol:

0 Files, 0 Blocks
20382 Free blocks

.edit startf.com
add ASSIGN DL1: VOL:
save and exit

.CTRL-E
Simulation stopped, PC: 152656 (BEQ 152676)
sim> q
Goodbye
```

### Future Booting

Future booting can be accomplished by:

`pdp11 boot.ini`

Celebrate!

*post added 2022-12-01 11:43:00 -0600*

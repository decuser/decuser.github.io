---
layout:	post
title:	Enabling the DZ in v7
date:	2022-02-03 12:56:00 -0600
categories:	unix research-unix v7
---
A short note about installing and using the DZ-11 Terminal Multiplexor in v7 for access from telnet on a host.

<!--more-->

## Prereqs

This note assumes you have a working instance of V7 and you want to use the DZ-11 Terminal Multiplexor to serve up telnet. It further assumes that you have not previously configured UNIX for another set of additional terminal interfaces (such as the DC-11). If you have, that's fine, you will just need to remove the existing /dev/tty?? entries. Otherwise, this note should work for you as well.

My guide for setting up a V7 instance will work for this (follow the directions through setting up a multi-user system and don't do the multi-session instructions). The most current post is [here]({% post_url 2022-01-03-installing-and-using-research-unix-v7-in-simh-pdp-11-45-and-70-emulators-rev-2.0 %})

## Boot up your v7 instance

```
cd ~/workspaces/v7-work
pdp11 nboot.ini
```

login as root

## Make changes to the configuration and build a new kernel

```
cd /usr/sys/conf

ed mkconf.c
249a

		"dz",
		0, 300, CHAR+INTR,
	"    dzin; br5+%d.\n    dzou; br5+%d.",
		".globl _dzrint\ndzin:  jsr     r0,call; jmp _dzrint\n",
	".globl    _dzxint\ndzou:    jsr    r0,call; jmp _dzxint\n",
	"",
		"       dzopen, dzclose, dzread, dzwrite, dzioctl, nulldev, dz_tty,",
	"",
		"int    dzopen(), dzclose(), dzread(), dzwrite(), dzioctl();\nstruct    tty    dz_tty[];",
.
45a
	"dz",
.
w
q

cc mkconf.c
mv a.out mkconf

cp hptmconf myconf
echo dz >> myconf
mkconf < myconf
make unix
sum unix
```

Should result in:

`43924   108`

## Save the kernel

`mv unix /munix`

## Edit the ttys file
 
```
ed /etc/ttys
266
2,17s/./1/
w
q

# sed -n '1,17p' /etc/ttys
14console
10tty00
10tty01
10tty02
10tty03
10tty04
10tty05
10tty06
10tty07
10tty08
10tty09
10tty10
10tty11
10tty12
10tty13
10tty14
10tty15
```
 
## Determine the major device number from c.c

```
cat /usr/sys/conf/c.c |grep dz
int    dzopen(), dzclose(), dzread(), dzwrite(), dzioctl();
struct  tty     dz_tty[];
	   dzopen, dzclose, dzread, dzwrite, dzioctl, nulldev, dz_tty,      /* dz = 19 */
```

It's 19, use that to create the devices.

## Create the devices:

```
/etc/mknod /dev/tty00 c 19 0
/etc/mknod /dev/tty01 c 19 1
/etc/mknod /dev/tty02 c 19 2
/etc/mknod /dev/tty03 c 19 3

/etc/mknod /dev/tty04 c 19 4
/etc/mknod /dev/tty05 c 19 5
/etc/mknod /dev/tty06 c 19 6
/etc/mknod /dev/tty07 c 19 7

/etc/mknod /dev/tty08 c 19 8
/etc/mknod /dev/tty09 c 19 9
/etc/mknod /dev/tty10 c 19 10
/etc/mknod /dev/tty11 c 19 11

/etc/mknod /dev/tty12 c 19 12
/etc/mknod /dev/tty13 c 19 13
/etc/mknod /dev/tty14 c 19 14
/etc/mknod /dev/tty15 c 19 15
chmod 640 /dev/tty??
```

## Set the baud rate

Edit .profile to set the baud rate to something reasonable:

`stty erase "^h" kill "^u" nl0 cr0 9600`


## Shutdown the V7 instance

```
# sync
# sync
# sync
#
Simulation stopped, PC: 002306 (MOV (SP)+,177776)
sim> q
Goodbye
```

## Modify boot.ini to accommodate the DZ

```
vi mboot.ini

set dz en
set dz line=16
;att dz -m 2222
att dz 2222
```

## Test it out with telnet on the host

`telnet localhost 2222`

Celebrate!

*post added 2022-12-02 12:14:00 -0600*
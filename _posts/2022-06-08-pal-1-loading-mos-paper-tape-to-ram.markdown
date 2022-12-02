---
layout:	post
title:	PAL-1 Loading MOS Paper Tape to RAM
date:	2022-06-08 00:00:00 -0600
categories:	retro-computing pal-1
---
 This post describes how to get your Mac talking to your PAL-1 in order to send MOS papertape format ascii files via minicom to your PAL-1 and run them. Future installments will go into more detail, from the ground up.

<!--more-->

## Preliminaries

* a PC (in this case, I'm using a Mac, running Mojave)
* macports (homebrew might work, but support for older oses is suspect)
* a PAL-1 (get one here)
* a 7 volt 1 amp (or 2 amp) DC power supply w/ 2.5mm x 5.5mm tip
* a DB-9 gender changer
* a USB 2.0 to Serial (9-Pin) DB-9 RS-232 Converter Cable, Prolific Chipset
* to install the Prolific USB2Serial driver (get it here)
* to install minicom (sudo port install minicom)
* a MOS file (to be described below)

## Create a MOS file

```
vi test.mos
;030200A90C0000BA
;0000010001
```

## Configure minicom

Configure minicom by editing the configuration file (or use the interface):

```
sudo vi /opt/local/etc/minirc.dfl

# add to file
# Machine-generated file - use "minicom -s" to change parameters.
pu pprog9           ascii-xfr -dsv -c10 -l100
pu port             /dev/cu.usbserial
pu baudrate         1200
pu bits             8
pu parity           N
pu stopbits         1
pu updir            /Users/wsenn/pal
pu downdir          /Users/wsenn/pal
pu rtscts           No
```

## Connect the PAL-1

Attach gender changer to the serial connector, attach the USB2Serial cable to that and to the USB connector of your Mac. Attach power to the PAL-1. Press RS.

## Start minicom and connect to PAL-1

`$ minicom`

press `enter`

![one](/assets/img/mos-tape/01.png)

## Send a file to the PAL-1

* Press `L`
* Press `CTRL-A S`
* select `ascii` for the Upload dialog

    ![two](/assets/img/mos-tape/02.png)

* locate and select your test.mos file

    ![three](/assets/img/mos-tape/03.png)

* you will briefly see progress

    ![four](/assets/img/mos-tape/04.png)

* type 0200 space and enter a few times to see the changes to memory

    ![five](/assets/img/mos-tape/05.png)


## Run the program

To run it, be sure to initialize 17FA/FB to 00 1C and 17FE/FF to same, then, type 0200 space and G to run the code. When it's done, type 00F3 space to see the contents of the A register (0C).

![six](/assets/img/mos-tape/06.png)


That's it. Success. I know it's not a very sophisticated program (it just loads 0C into the A register), but this demonstrates the moving of a tape file into ram on the PAL-1, so celebrate!

<!--more-->

*post added 2022-12-02 14:40:00 -0600*

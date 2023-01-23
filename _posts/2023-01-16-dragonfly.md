---
layout: post
title:  "Installing and running DragonFly BSD 6.4"
categories: operating-systems bsd dragonfly-bsd
---
This note is about installing and running DragonFly BSD 6.4

![one](/assets/img/dragonfly/01.jpeg)

DragonFly BSD from [https://dragonflybsd.org](https://dragonflybsd.org) is a BSD :). As such, it is a rock and the userland is sane. It was forked from FreeBSD long ago and is renowned for its HAMMER FS. I started the exploration with the intention of learning more about HAMMER and have enjoyed the journey.

<!--more-->

Link to high res image:

* [dragonfly-running on metal](/assets/img/dragonfly/01-big.jpeg)

I like DragonFly BSD, but there is a bit of a learning curve, even for someone used to FreeBSD... I say this as someone who has been using FreeBSD for more than a decade and while there is some overlap, it's still pretty different. Maybe if I had used an earlier version of FreeBSD it would seem more familiar, but I started with 8.

### Requirements

----

* A machine to run it on - I put it on my Dell Optiplex 755, Core 2 Quad  CPU   Q9550  @ 2.83GHz w/8GB RAM, and a 240 GB SSD
* DragonFly BSD 6.4 USB image from [https://www.dragonflybsd.org/download/](https://www.dragonflybsd.org/download/)

### Resources

----

* DragonFly BSD Handbook [https://www.dragonflybsd.org/docs/handbook/](https://www.dragonflybsd.org/docs/handbook/)
* Mailing List and IRC [https://www.dragonflybsd.org/mailinglists/](https://www.dragonflybsd.org/mailinglists/)
* DragonFly Digest [https://www.dragonflydigest.com/](https://www.dragonflydigest.com/)


### Getting started

----

#### Create a workarea on your existing system

```
mkdir -p ~/Downloads/dragonfly
cd ~/Downloads/dragonfly/
```

#### Download the image, decompress it, and verify it

Note that md5's of the releases are available at [http://avalon.dragonflybsd.org/iso-images/md5.txt](http://avalon.dragonflybsd.org/iso-images/md5.txt)

MD5 (dfly-x86_64-6.4.0_REL.img) = b3b23e1a18292c46643f8df435e4ab68

```
aria2c https://mirror-master.dragonflybsd.org/iso-images/dfly-x86_64-6.4.0_REL.img.bz2
bzip2 -d dfly-x86_64-6.4.0_REL.img.bz2
md5 dfly-x86_64-6.4.0_REL.img
MD5 (dfly-x86_64-6.4.0_REL.img) = b3b23e1a18292c46643f8df435e4ab68
```
#### Burn it to USB - I use Balena Etcher


### Installing DragonFly BSD

----

#### Boot to the USB stick

#### DragonFly Boot Menu

The DragonFly Boot Menu will appear after a few seconds.

* Choose `1. Boot DragonFly [kernel]`

The bootup process takes a minute or so... be patient.

#### Running the DragonFly BSD Installer

----

* login as `installer` with no password


The installer will begin  and display its dialogs:

##### Welcome screen and staring the installation

* Welcome to DragonFly BSD

 A brief description of Dragonfly BSD is presented.

 * Choose `Install DragonFly BSD`

*  Begin Installation

 The installer describes what it's about to do.

 *  Again, choose `Install DragonFly BSD`

##### Disk Setup

* UEFI or legacy BIOS

 * Choose `Legacy BIOS` (or UEFI, if you have it)

* Select Disk - a list of disks is presented.

 * Choose `da0: 244198MB`

* How Much Disk? - asks you how much of the disk (all of it, or just part of it).

 * Choose `Use Entire Disk`

* Are you absolutely sure?

 * Acknowledge by choosing `OK`

* Information

 ```
The disk
da0: 244198MB
was formatted.
```
 * Acknowledge by choosing `OK`

##### File System Setup

* Select file system
 * Choose `Use HAMMER2` as recommended.
* Create Subpartitions

 ```
/boot 1024M
swap 16G
/ 166G
/build *
```
 * Choose `Accept and Create`

The filesystem is created.

##### OS Installation

* Install OS

 * Choose `Begin Installing Files`

 It will take a couple of minutes for the operating system files to be written to disk.
 
##### Boot Block Installation

* Install Bootblock(s)

 ```
 Disk Drive   Install Bootblock? Packet Mode?
 [da0      ]  [X]                [X]
 ```   
 * Choose Accept and Install Bootblocks

 * Information

     `Bootblocks were successfully installed!`

 * Acknowledge by choosing `OK`

##### Completing the installation

* DragonFly BSD is Installed!

The base installation, now it's time to configure the system.

* Choose `Configure this system`

#### Configuring the newly installed system

----

#### Timezone configuration

* Choose `Select Timezone`

* Local or UTC (Greenwich Mean Time) clock

  * Choose `YES`

* Select Timezone

 * Choose `America`

 * Choose `Chicago`

 * Information

     ```
The Time Zone has been set to
/mnt/usr/share/zoneinfo/America/Chicago.
```
 * Acknowledge by choosing `OK`

##### Date and Time configuration

* Set date and time

 * Set Time/Date as you like

 *  Confirm your choices by choosing `OK`

 * Information

     `The time and date have been set.`

 * Acknowledge by choosing `OK`

##### Keyboard map configuration

* Choose `Set keyboard map`

 * Select Keyboard Map

     * Choose `us.pc-ctrl-kbd`

##### Root password configuration

* Choose `Set root password`

 * Set Root Password

     * Enter root password

     * Enter root password again

     * Choose `Accept and Set Password`

     * Information

         `The root password has been set.`

     * Acknowledge by choosing `OK`

##### Additional user configuration

* Choose `Add a user`

 * Add user

 * 
 ```
 Username wsenn
Real Name Will Senn
Password **
Password again **
Shell /bin/sh
Home Directory /home/wsenn
User ID (leave blank)
Login Group (leave blank)
Other Group Membership [wheel,video]
```

 * Choose `Accept and Add`

 * Information

     `The user 'wsenn' was added.`

   * Acknowledge by choosing `OK`

##### Network configuration

* Choose `Configure network interfaces`

 * Assign IP Address

     * choose `em0`

     * Use DHCP

         * Choose `Use DHCP`

             It takes a few seconds to initialize the nic.
    
     * Information

         `Lots of em0 info is displayed`

     * Acknowledge by choosing `OK`

##### Hostname and domain configuration
 
* Choose `Configure hostname and domain`

 * Enter your hostname

 * Enter your domain	

 * Confirm your selections by choosing `OK`

##### Console font configuration (optional)

Probably don't need to change it but if you do...

Choose cp437 fonts

##### Screen map configuration

Probably don't need to change it but if you do...

Choose the iso-8859-1 to cp437 screen map

##### Wrapping up configuration

* Choose `Return to Welcome Screen`

* Choose `Reboot This Computer`

 * Reboot

     * Choose `Reboot`

* Remove the USB Stick and reboot

I had to power cycle the computer at this point.

### Running DragonFly BSD

----

The computer will reboot and display the Dragonfly BSD Boot manager.

```
F1 DF/FBSD
Default: F1
```

After about 10 seconds, the computer will boot the default entry (DragonFly BSD).

The Dragonfly BSD Boot menu will appear and a countdown timer will count down before booting the default entry - `1. DragonFly BSD (kernel)`.


#### Login as regular user

```
login: wsenn
password:
```

#### Get the ip

```
ifconfig
...
192.168.254.12
...
```

#### Temporarily change ssh to allow password based logins

```
su -

vi /etc/ssh/sshd_config
PasswordAuthentication yes
service sshd restart
```

#### Copy over your user key (if you plan to log in remotely)

on remote host

`ssh-copy-id loki`

#### Change ssh back to only allow key based logins

on loki

```
su -

vi /etc/ssh/sshd_config
PasswordAuthentication no
service sshd restart
```

#### Log in over ssh

```
ssh loki
```

#### Do updates and upgrade

Note: 6.4.0 ships with an old version of pkg and the upgrade fails as a result and blows away the pkg configuration. The simple solution is to copy the sample configuration over and rerun the upgrade as described below.

```
pkg update
pkg upgrade
```

This results in the following error:

```
Updating Avalon repository catalogue...
Avalon repository is up to date.
All repositories are up to date.
New version of pkg detected; it needs to be installed first.
The following 1 package(s) will be affected (of 0 checked):

Installed packages to be UPGRADED:
	pkg: 1.14.4 -> 1.18.4 [Avalon]

Number of packages to be upgraded: 1

3 MiB to be downloaded.

Proceed with this action? [y/N]: Y
[1/1] Fetching pkg-1.18.4.pkg: 100%    3 MiB 790.6kB/s    00:04    
Checking integrity... done (0 conflicting)
[1/1] Upgrading pkg from 1.14.4 to 1.18.4...
[1/1] Extracting pkg-1.18.4: 100%
pkg: Failed to execute lua script: [string "-- args: etc/pkg.conf.sample..."]:12: attempt to call a nil value (field 'stat')
pkg: lua script failed
No active remote repositories configured.
```

##### Restore the borked configuration

`cp /usr/local/etc/pkg/repos/df-latest.conf.sample /usr/local/etc/pkg/repos/df-latest.conf`

##### Rerun the upgrade step

`pkg upgrade`

This time, things ought to be good.

#### Install some useful baseline packages

```
pkg install sudo vim bash sysrc
visudo
uncomment
%wheel ALL=(ALL:ALL) NOPASSWD: ALL

exit
```

#### Change the user shell to bash

as user

```
chsh
/usr/local/bin/bash
```


#### Install a Windowing Environment

```
sudo -s
pkg install xorg xf86-input-evdev windowmaker leafpad nautilus chromium slim slim-themes

echo "exec wmaker" > .xinitrc

sysrc slim_enable="YES"
sysrc dbus_enable="YES"
sysrc snd_hda_load="YES"

sysrc -f /boot/loader.conf autoboot_delay="1"

sudo shutdown -r now
```
should restart with slim

#### Login, fire up Chrome and youtube, stuff oughta just work

* Right-click on the desktop, open a terminal, then

`chrome`


logging out of windowmaker takes 10 seconds then beep


### Post installation rigamarole

----

I have an ASUS ATI Radeon HD 650 Silence video card. I did the following to learn more about it.

``` 
kldload radeon
kldstat
Id Refs Address            Size     Name
 1   26 0xffffffff80200000 1ada9a8  kernel
 2    1 0xffffffff81cdb000 7c550    ehci.ko
 3    1 0xffffffff81d58000 8a1f0    xhci.ko
 4    1 0xffffffff82600000 16000    ums.ko
 5    1 0xffffffff82616000 19a7000  radeon.ko
 6    1 0xffffffff83fbd000 baa000   drm.ko
 7    1 0xffffffff84b67000 1f000    iicbus.ko
 8    1 0xffffffff84b86000 a000     radeonkmsfw_CAICOS_pfp.ko
 9    1 0xffffffff84b90000 b000     radeonkmsfw_CAICOS_me.ko
10    1 0xffffffff84b9b000 a000     radeonkmsfw_BTC_rlc.ko
11    1 0xffffffff84ba5000 f000     radeonkmsfw_CAICOS_mc.ko
12    1 0xffffffff84bb4000 f000     radeonkmsfw_CAICOS_smc.ko
13    1 0xffffffff84bc3000 3b000    radeonkmsfw_SUMO_uvd.ko
```

I have onboard sound. Here's the exploration.

```
kldload snd_hda
cat /dev/random > /dev/dsp
```

Static sound ensues :).

```
cat /dev/sndstat
Installed devices:
pcm0: <Analog Devices AD1984 (Analog)> (play/rec) default
pcm1: <Analog Devices AD1984 (Analog)> (play/rec)
pcm2: <ATI R6xx (HDMI)> (play)

dmesg|grep pcm
pcm0: <Analog Devices AD1984 (Analog)> at nid 18 and 20 on hdaa0
pcm1: <Analog Devices AD1984 (Analog)> at nid 17 and 21 on hdaa0
pcm2: <ATI R6xx (HDMI)> at nid 3 on hdaa1
```

I mucked up loader.conf and booting became an issue. Here's the fix.

* insert usb and boot to it
* select r for ramdisk
* in the booted system, `mount /dev/da0s1a`
* find and edit `loader.conf` in /mnt
* reboot


I originally had a janky mouse, the fix was to install `xf86-input-evdev`

To enable X11 over ssh
sudo vi /etc/ssh/sshd_config
X11Forwarding yes

*post last updated 2023-01-19 13:12:00 -0600*

---
layout:	post
title:	Setting up XDM on FreeBSD 12.1
date:	2020-07-21 17:48:00 -0600
categories:	unix freebsd
---
A note about how I I got XDM working on my Thinkpad T430 in 2020. It's not difficult, but it's not common anymore.

XDM is the x display manager and provides login capability for unix systems. It is particularly useful for old-style window managers like TWM.

<!--more-->

## Prerequisites

* FreeBSD 12.1 Installed and Running on T430
* Xorg up and running with TWM (default)

## Steps

1. Install XDM

 `sudo pkg install xdm`

2. Edit ttys to turn xdm on

 ```
 sudo vi /etc/ttys
 # change 
 ttyv8   "/usr/local/bin/xdm -nodaemon"  xterm   off secure
 # to
ttyv8   "/usr/local/bin/xdm -nodaemon"  xterm   on secure
```

3. Create a basic .xsession file

 ```
 vi ~/.xsession
 xrdb -Dhostname=astra $HOME/.Xresources
 xset c off s 300
 twm &
 xterm -geometry 80x24+0-0
 ```
 
4. reboot

 `sudo reboot`

## Notes
* /etc/ttys is the terminal control file and it's what starts all of
* the pseudo terminals. ttyv8 is the 9th tty (CTRL-ALT-F9)
* .xsession is basically .xinitrc for xdm, if it's missing xdm won't
* start a session when you login, so you will endlessly enter your
* name and password wondering why nothing is starting.
* xrdb will load your .Xresources file - here's an example

 ```
 XTerm*foreground:   green
 XTerm*background:   black
 ```  
* the xset sets keyclick off and sets the screen saver to 5 minutes

It's not magic, but oh, how long it took me to figure it out... I just
received my copy of X Window System Users' Guide for X11 R3 and R4
by Valerie Quercia and Tim O'Reilly Volume Three in the mail - written in 1990,
but still amazing book. If it weren't for this book, I'd still be in the dark
about .Xdefaults, .Xresources, .xsession, .xinitrc, and three dozen other
Xisms.
    
*post added 2022-12-02 08:05:00 -0600*
---
layout:	post
title:	Using a Mac's xterm as a remote Tektronics display for a FreeBSD 12.1 Server
date:	2020-07-21 16:00:00 -0600
categories:	unix macos
---
How to use the macos terminal as a remote tektronics display device for a terminal graphics process running on another unix system. In this case, freebsd.

<!--more-->

## Prerequisites

* Mac OS X installed (mine is a MacBook Pro running Mojave by choice)
* XQuartz 2.7.11 (X11 for Mac)
* FreeBSD 12.1 installed (mine is a Thinkpad T430) w/X11

### Install gnuplot on freebsd

We need a graphics proces that's simple and easy to use from the command line.

`sudo pkg install gnuplot`

### Start a terminal on macos

```
ssh -Y astra
xterm -bg black -fg green &
gnuplot -e "set terminal xterm; plot [-5:5] sin(x)"
```
opens a tektronix window showing a sine wave

### Start a terminal first and then switch to tek mode

* Requires either a three-button mouse or that xterm is emulating three buttons:
 
 > In xterm, open preferences.
 >
 > On the Input tab, check **Emulate three button mouse**
 >
 > Close preferences.
  
Fire up an xterm

`$ xterm`

press `ctrl-option-click` or click the middle button of a mouse and select `switch to tek mode` in the menu that appears.

in texmode window

`gnuplot -e "set terminal xterm; plot [-5:5] sin(x)"`


## Notes
1. xterm on mac works pretty well. to help it out, remember to open preferences and set emulate 3
button mouse (unless you are actually using one, in which case, this isn't necessary). Then to access:

* Main Options Menu: `Ctrl-Click`
* VT Options: `Ctrl-Option-Click`
* VT Fonts Menu: `Ctrl-Cmd-Click`

2. The xterm is pretty smart about opening the Tektronix display as needed (the sine wave window is a graphics terminal). You can fire up your own Tek window by bringing up the VT Options Menu and selecting "Switch to Tek Mode"

*post added 2022-12-02 08:28:00 -0600*




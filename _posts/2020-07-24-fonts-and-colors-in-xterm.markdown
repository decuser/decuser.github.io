---
layout:	post
title:	Fonts and Colours in xterm
date:	2020-07-24 07:53:00 -0600
categories:	unix
---
![macos xterm color](/assets/img/xterm-color.png){: width="640" }

A note on how to set fonts and colors for xterms for freebsd & macos.

<!--more-->

## In FreeBSD

### Get the list of available fonts

```
fc-list :fontformat=TrueType -f "%{family}\n" | sort -u | grep -i mono
DejaVu Sans Mono
Luxi Mono
Noto Mono
....
```

### Try one out in xterm

`xterm -fa 'Noto Mono' -fs 12 &`

### Make selections permanent in `.Xresources`

```
vi ~/.Xresources
XTerm*foreground:   green
XTerm*background:   black
XTerm*faceName: Noto Mono
XTerm*faceSize: 12
```

Note: Anytime you edit `.Xresources`, tell X about those changes by merging with xrdb

`xrdb -merge .Xresources`

#### Fire up an xterm

`xterm`

## In macos

#### Get a list of available fonts

```
fc-list :fontformat=TrueType -f "%{family}\n" | sort -u | grep -i mono
Andale Mono
Bitstream Vera Sans Mono
Luxi Mono
PT Mono
...
```

### Try one out in xterm

`xterm -fa 'Bitstream Vera Sans Mono' -fs 12 &`

### Make selections permanent in `.Xresources`

```
vi ~/.Xresources
XTerm*foreground:   green
XTerm*background:   black
XTerm*faceName: Bitstream Vera Sans Mono
XTerm*faceSize: 12
```

Note: Anytime you edit `.Xresources`, tell X about those changes by merging with xrdb

`xrdb -merge .Xresources`

#### Fire up an xterm

`xterm`

Celebrate!

*post added 2022-12-02 08:44:00 -0600*
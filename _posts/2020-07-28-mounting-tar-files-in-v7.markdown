---
layout:	post
title:	Mounting tar files in v7
date:	2020-07-28 07:59:00 -0600
categories:	unix research-unix v7
---
How to mount a tar file in v7 running in SimH
This was difficult to figure out, but perseverance, tuhs, and simh mailing lists helped.

Modern tar files are easy to mount as tapes in SimH (at least theoretically). This note shows the way.

<!--more-->

## Attach the tarball in SIMH

`simh> ATTACH TM0 -V -F TAR whatever.tar`

## Untar the tarball in v7

`tar xv0`

But, some tar files (back in the day stuff), don't work this way. In order to get them to work requires some work.

1. Get Wolfgang Helbig's enblock program - [http://doc.cat-v.org/unix/v6/operating-systems-lecture-notes/v6/enblock.c](http://doc.cat-v.org/unix/v6/operating-systems-lecture-notes/v6/enblock.c)

 `aria2c http://doc.cat-v.org/unix/v6/operating-systems-lecture-notes/v6/enblock.c`

2. compile it and put it somewhere useful - ~/bin or somesuch

 ```
 cc -Wno-implicit-function-declaration enblock.c -o enblock
 cp enblock ~/bin/
 ```

3. Get a useful old tarball - [https://www.tuhs.org/Archive/Distributions/UCB/2bsd.tar.gz](https://www.tuhs.org/Archive/Distributions/UCB/2bsd.tar.gz)

 `aria2c https://www.tuhs.org/Archive/Distributions/UCB/2bsd.tar.gz`

4. Unzip the tarball and enblock it

```
gunzip 2bsd.tar.gz
cat 2bsd.tar | enblock > 2bsd.tap
```

5. Do the simh/v7 dance

* in SimH:

 `att tm0 2bsd.tap`

* in v7:

 ```
 tar xv0

 tar: bin/ - cannot create
 x bin/csh, 40412 bytes, 79 tape blocks
 tar: bin/etc/ - cannot create
 x bin/etc/htmp, 0 bytes, 0 tape blocks
 x bin/etc/install, 81 bytes, 1 tape blocks
 ```
 
Don't worry too much about the cannot create messages - the dirs actually do get created.

*post added 2022-12-02 08:57:00 -0600*
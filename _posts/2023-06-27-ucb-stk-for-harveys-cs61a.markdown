---
layout: post
title:  "UCB STk Interpreter for Working Through Brian Harvey's CS61A Course"
categories: development scheme ucb-stk
---

This note describes how to install the UCB STk 4.0.1 Scheme interpreter on modern 64 bit Debian based systems. It also describes a method of building the Debian Package used to install the program. This is the version of scheme used by Brian Harvey in his 2011 course, CS61A: Structure and Interpretation of Computer Programs, named after and using famed text, Structure and Interpretation of Computer Programs by Harold Abelson and Gerald Jay Sussman with Julie Sussman, a phenomenally good computer science textbook.

Now, I'm not a package maintainer and I certainly don't know the nuances of building packages, this is just meant to document how I was able to get this working in 2023 after reading tons of "too bad, so sad, I can't get it to work posts", YMMV.

Here's a screenshot of the working system:

![one](/assets/img/scheme/01.png)

<!--more-->

### Resources

* CS561A: Structure and Interpretation of Computer Programs Video Lectures - [https://archive.org/details/ucberkeley-webcast-PL3E89002AA9B9879E](https://archive.org/details/ucberkeley-webcast-PL3E89002AA9B9879E)

* UCB Scheme Webpage - [https://people.eecs.berkeley.edu/~bh/61a-pages/Scheme/](https://people.eecs.berkeley.edu/~bh/61a-pages/Scheme/)

* Structure and Interpretation of Computer Programs 2nd ed. eBook - [https://web.mit.edu/6.001/6.037/sicp.pdf](https://web.mit.edu/6.001/6.037/sicp.pdf)

* Erick Gallesio's github repo - [https://github.com/egallesio/STk](https://github.com/egallesio/STk)

### Test Environment

* IBM ThinkCentre M92p running Linux Mint Debian Edition 5 (I expect this would work with any Mint 20+, but haven't tested it)

### Build Environment
* Ubuntu 16.04.1 LTS 64 bit - VirtualBox instance

### Installation using the debian package

The package requires that you have 32bit support in your environment which LMDE does. Other than this, it requires:

* libsm6:i386

`sudo apt install libsm6:i386`

* [stk_4.0.1-1_amd64.deb](/assets/files/scheme/stk_4.0.1-1_amd64.deb)

`sudo dpkg -i stk_4.0.1-1_amd64.deb`

That should be all it takes, test it:

`stk-simply`

I usually install rlwrap so that I can get command history. If you want that then, install rlwrap:

`sudo apt install rlwrap`

Then add an alias or three to your .bashrc:

```
alias rlstk-simply='rlwrap stk-simply'
alias rlstk-explorin='rlwrap stk-explorin'
alias rlstk-grfx='rlwrap stk-grfx'
```

Then you can do stuff like this:

![two](/assets/img/scheme/02.png)

Yeah, I know. It's not all about the graphics or turtles, but hey - still kind of cool that it works.

### Extras

Since UCB Scheme is based on Erick Gallesio's STk, we can use the manual from STk for everything that's not a UCB Scheme extension. Here's the manual:

[gallesio-1999-stk-4.0-manual.pdf](/assets/files/scheme/gallesio-1999-stk-4.0-manual.pdf)

The differences between Gallesio's STk and the UCB Scheme environment are summed up in this document:

[explorin-vs-simply.txt](/assets/files/scheme/explorin-vs-simply.txt)

And an FAQ is also available:
[faq.html](/assets/files/scheme/faq.html)


### Build the Debian Package from the RPM distribution

The first thing to do is to get the RPM. It is available here:

[RPM distribution](http://inst.eecs.berkeley.edu/~scheme/precompiled/Linux/STk-4.0.1-ucb1.3.6.i386.rpm)

or locally, here:

[STk-4.0.1-ucb1.3.6.i386.rpm](/assets/files/scheme/STk-4.0.1-ucb1.3.6.i386.rpm)


The second thing to do is to download the Ubuntu 16.0.1 LTS 64 bit server image:

[ubuntu-16.04.1-server-amd64.iso](https://old-releases.ubuntu.com/releases/16.04.6/ubuntu-16.04.1-server-amd64.iso)

Create a new Virtual Box Instance and use Bridged Networking so your instance will get an IP address on your network. During installation, enable the SSH server.

After the installation, get the IP address of the instance:

```
ifconfig
192.168.254.15
```

From your host, scp the rpm file into the instance:

`scp STk-4.0.1-ucb1.3.6.i386.rpm your_user@instanceip:STk-4.0.1-ucb1.3.6.i386.rpm`

Then ssh into the instance:

`ssh 192.168.254.15`

Install some necessary applications and libraries:

`sudo apt install alien libsm6:i386 libx11-6:i386 libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1`

Create the debian package from the rpm:

`fakeroot alien --target=amd64 STk-4.0.1-ucb1.3.6.i386.rpm`

That's all there is to converting rpm to a 64 bit friendly debian package. On the host, scp the file from the instance:

`scp your_user@instanceip:stk_4.0.1-1_amd64.deb ./stk_4.0.1-1_amd64.deb`

Now, you have a deb file that can be saved off and reused.

### Get a copy of the manual, build the unmodified source code

Gallesio's STk is buildable, just realize that it isn't suitable for following the course. I include these instructions for the sake of getting the manual and for completeness.

Get the source code and checkout the appropriate version:

```
cd ~/sandboxes-git
git clone https://github.com/egallesio/STk.git
cd STk
git checkout Version_4.0.1
```

Convert the manual to pdf:

`ps2pdf Doc/Reference/manual.ps ~/Desktop/gallesio-1999-stk-4.0-manual.pdf`


Build the source and optionally install it (don't do this if you have the modified program installed):

```
./configure
make
sudo make install
```

A quick test on my system:

![three](/assets/img/scheme/03.png)

Reach out to me if you find any issues or have suggestions.

\- will

*post last updated 2023-06-27 21:24:00 -0600*

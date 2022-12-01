---
layout:	post
title:	hello-world-in-assembly-on-research-unix-v6
date:	2016-01-22 18:30:00 -0600
categories:	unix research-unix v6
---
# Hello, World! in Assembly on Research Unix Version 6

This note demonstrates assembling and running a simple **hello, world** Unix assembly language application on Research Unix Sixth Edition. It's short and sweet, but gets the job done!

## Prerequisites

* A working Research Unix v6 environment: [Installing and Using Research Unix Version 6 in SimH PDP-11/40 Emplator (Nov 23, 2015)]({% post_url 2015-11-23-installing-and-using-research-unix-v6-in-simh-pdp-11-40-emulator %})
* A recent version of SimH (since December 2015): [https://github.com/simh/simh](https://github.com/simh/simh) 
* Some experience with SimH and copying and pasting between host and simulated os.

## Version 1 - Hello, World using mesg from the system library

First, fire up your v6 environment in SimH:

```
$ pdp11 nboot.ini

PDP-11 simulator V4.0-0 Beta        git commit id: 9c977e93
Disabling XQ
Listening on port 5555
@rkunix
login: root
#
```

Rather than editing using ed, it is simpler to use cat and the SimH copy paste capability. To do this, redirect cat's output to hello.s:

`# cat > hello.s`

and paste the contents into the terminal window:

---snip

```
/ hello world using external mesg routine

        .globl  mesg

        mov     sp,r5
        jsr     r5,mesg; <Hello, World!\n\0>; .even
        sys     exit
```

---snip


Be careful not to mess with the tab characters. Everything between the snips is content. To signal cat that the file is complete, type `CTRL-d`. You will be returned to the prompt.

To assemble the file, type as and the file to assemble:

`# as hello.s`

In order for the program to actually work, it will need to be linked with the system library:

`# ld -s a.out -l`

Test the program:

```
# a.out
Hello, World!
#
```

Save it:

`# cp a.out hello`

##Version 2 - Hello, World using mesg inline

The version above is simple and works. However, it relies on an external library and requires a link step. Below is the same program, but with the mesg routine moved directly into the assembly file, just for fun.

Redirect cat to a new file:

`# cat > hello2.s`

and paste the contents into the terminal window:

---snip

```
/ hello world using internal mesg routine

        mov     sp,r5
        jsr     r5,mesg; <Hello, World!\n\0>; .even
        sys     exit

mesg:
        mov     r0,-(sp)
        mov     r5,r0
        mov     r5,0f
1:
        tstb    (r5)+
        bne     1b
        sub     r5,r0
        com     r0
        mov     r0,0f+2
        mov     $1,r0
        sys     0; 9f
.data
9:
        sys     write; 0:..; ..
.text
        inc     r5
        bic     $1,r5
        mov     (sp)+,r0
        rts     r5
```

---snip

To assemble the file, as before:

`# as hello.s`

This version can be run directly without linking:

```
# a.out
Hello, World!
#
```

Save it:

`# cp a.out hello2`

The source for the mesg routine is taken directly from `/usr/source/s3/mesg.s`

## Next Steps

This is a quickie note and will evolve as I learn more about using assembly in Unix v6.

*post added 2022-12-01 12:15:00 -0600*

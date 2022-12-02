---
layout:	post
title:	ratfor and Kernighan and Plaugers Software Tools
date:	2022-02-03 13:43:00 -0600
categories:	unix research-unix v7 ratfor
---
A short note documenting the process of getting ratfor working on a v7 instance.

<!--more-->

## Prereqs

This note assumes you have a working v7 setup. The most current post is [here]({% post_url 2022-02-08-installing-and-using-research-unix-v7-in-simh-pdp-11-45-and-70-emulators-rev-2.1 %})

## Getting Started

Fire up the v7 instance

### log in as a normal user

```
cd ~/workspaces/v7-work
pdp11 mboot.ini
...
login: wsenn

$
```

### Create a working directory

```
mkdir copy
cd copy
```



## Create a simple ratfor program 

This is really mostly a fortran program

```
ed hello.r
a
# hello world in ratfor
		print *, 'hello, world!'
		stop
		end
.
w
q
```

## Run ratfor

```
$ ratfor -C hello.r
c hello world in ratfor
	  print *, 'hello, world!'
	  stop
	  end
```

### Run it again and redirect the output to a file:

`ratfor -C hello.r > hello.f`


## Run fortran to compile the code

```
f77 -o hello hello.f 

hello.f:
   MAIN:
```

## Run the executable

```
./hello

hello, world!
```

### Celebrate, if you like. Job well done.

Then, back to work. The copy routine and its dependencies, getc and putc, outlined in the first chapter contains 7 symbolic constants that we need to know the values of and a character type that we will change to integer, for convenience. Read the book to learn more about replacing constants and macros.

The stuff we need to know about is:

```
MAXLINE
MAXCARD
NEWLINE 
STDIN
STDOUT
EOF
SPACE
character
```

* **MAXLINE** - the number of characters on a card, plus one, 81.
* **MAXCARD** - the number of characters on a card, 80.
* **NEWLINE** - the end of a line of characters, the ascii value 10 works.
* **STDIN** - the LUN for the card reader, 5.
* **STDOUT** - the LUN for the card punch, 6.
* **EOF** - the end of file marker, -1.
* **SPACE** - the blank space character, 32.
* **character** - the character data type, integer works.

The author's copy program relies on two primitive operations, getc, and putc, that are not provided by v7 (they are provided in 4.2/4.3 BSD, but that's another story for another day). The authors talk about this and provide simple implementations that we can leverage to get things rolling. The idea is to take the copy. getc, and putc routines provided by K&P, replace the symbolic constants, replace character with integer and run the result.

## Create a more realistic combined ratfor source

```
$ ed copy.r
?copy.r
a
# $ ratfor -C copynew.r > copynew.f
# $ f77 -o copynew copynew.f

# getc (simple version) - get characters from standard input
		integer function getc(c)
		integer buf(81), c
		integer i, lastc
		data lastc /81/,buf(81) /10/
		# note MAXLINE = MAXCARD + 1

		lastc = lastc + 1
		if(lastc > 81) {
				read(5, 100, end=10) (buf(i), i = 1, 80)
						100 format(80 a 1)
				lastc = 1
				}
		c = buf(lastc)
		getc = c
		return
		
10      c = -1
		getc = -1
		return
		end

# putc (simple version) - put characters on the standard output
		subroutine putc(c)
		integer buf(80), c
		integer i, lastc
		data lastc /0/

		if (lastc > 80 | c == 10) {
				for (i = lastc + 1; i <= 80; i = i + 1)
						buf(i) = 32
				write(6, 100) (buf(i), i = 1, 80)
						100 format(80 a 1)
				lastc = 0
				}
		if (c != 10) {
				lastc = lastc + 1
				buf(lastc) = c
				}
		return
		end

# copy - copy input characters to output
		integer getc
		integer c

		while(getc(c) != -1)
				call putc(c)
		stop
		end
.
w
1337
q
```

## Run ratfor (see rafor(1) for incantations):

`$ ratfor -C copy.r > copy.f`
 

## Compile the fortran (see f77(1) for incantations):

```
$ f77 -o copy copy.f
copy.f:
   getc:
   putc:
   MAIN:
```

## Run the result:

```
$ ./copy
This is a test.
This is a test.                                                                
^d
$
```

### Now, you can really celebrate :)!

*post added 2022-12-02 13:03:00 -0600*
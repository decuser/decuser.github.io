---
layout:	post
title:	v6 Bootable Tape
date:	2017-11-11 00:00:00 -0600
categories:	unix research-unix v6
---
A note describing how to boot from Dennis Rithchie's v6 disk-set. It shows two methods, one that builds a bootable tape from scratch, and another that extracts the bootblock of a running v6 system.

<!--more-->

## References

* [http://gunkies.org/wiki/Installing_UNIX_Sixth_Edition#Installation_tape_contents](http://gunkies.org/wiki/Installing_UNIX_Sixth_Edition#Installation_tape_contents)
* [http://mercury.lcs.mit.edu/~jnc/tech/V6Unix.html#Initial](http://mercury.lcs.mit.edu/~jnc/tech/V6Unix.html#Initial)

## Rationale

My intention was to be able to boot from Dennis Ritchies v6 disk-set from
[http://www.tuhs.org/Archive/Distributions/Research/Dennis_v6](http://www.tuhs.org/Archive/Distributions/Research/Dennis_v6)

I don't think this is possible without a bootstrap program being installed. So, I set out to install a bootstrap to the v6root image in the set. Here are a couple of methods, beginning with the easiest.

## Method 1 - From Scratch

```
mkdir -p ~/sandboxes/retro-workarea/bootblock
cd ~/sandboxes/retro-workarea/bootblock
```

### Get tape and utilities

Get Ken Wellsch's distribution and the enblock utility for converting bits to tape image:

```
curl -O -L http://www.tuhs.org/Archive/Distributions/Research/Ken_Wellsch_v6/v6.tape.gz
curl -O -L http://www.tuhs.org/Archive/Distributions/Research/Bug_Fixes/V6enb/v6enb.tar.gz
openssl sha1 *gz

SHA1(v6.tape.gz)= 2e9d1e030f1f27cf1da7ec22e7312148856e0883
SHA1(v6enb.tar.gz)= b9c6898d0b9ad8aaaecf94ccccddb5ad2b22013c

gunzip v6.tape.gz
dd if=v6.tape of=boot.dd count=101 bs=512

tar xvzf v6enb.tar.gz enblock
tar xvzf v6enb.tar.gz --strip-components 1 v6enb/enblock.c
gcc enblock.c -o enblock
./enblock < boot.dd > boot.tap

openssl sha1 boot.tap 
SHA1(boot.tap)= dffa78a51f572d57d3c708878198997dd901b379
```

### Get Dennis's root disk

```
curl -O -L http://www.tuhs.org/Archive/Distributions/Research/Dennis_v6/v6root.gz
openssl sha1 v6root.gz
SHA1(v6root.gz)= 105bb5c4f79bb1af0ed50ac63b90dca1229373c1

gunzip v6root.gz
```

### Create a simh tape boot file

```
cat > tboot.ini <<EOF
set cpu 11/40
set tm0 locked
attach tm0 boot.tap
attach rk0 v6root
d cpu 100000 012700
d cpu 100002 172526
d cpu 100004 010040
d cpu 100006 012740
d cpu 100010 060003
d cpu 100012 000777
g 100000
EOF
```

### Boot to tape

```
pdp11 tboot.ini

^E
g 0
sim> g 0
=tmrk
disk offset
0
tape offset
100
count
1
=
^E
Simulation stopped, PC: 137274 (TSTB @#177560)
sim> q
Goodbye
```

### Backup work and create disk boot file

```
tar cvzf v6root-bootable.tar.gz v6root

cat > dboot.ini <<EOF
set cpu 11/40
set tto 7b
attach rk0 v6root
dep system sr 173030
boot rk0
EOF
```

### Boot up the instance

```
pdp11 dboot.ini
@rkunix
mem = 1036
# 
^E
```

### Back up the work

```
tar cvzf wellsch-bootblock.tar.gz boot.dd boot.tap
a boot.dd
a boot.tap
mv wellsch-bootblock.tar.gz ~/_workarea/_resources/retro-resources/v6/
```

## Method 2 - Extracting from a running v6

alternatively, using a working v6 system and having downloaded Ken's dist.tap and enblock

start a v6 system that has devices RK{0-3} and where RK3 is not already used.

### Boot system and extract boot block
```
sim> att rk3 v6root
sim> att tm0 dist.tap
sim> c
dd if=/dev/rmt0 of=boot.dd count=101
dd if=boot.dd of=/dev/rrk3
sync
sync
^E
sim> q
Goodbye
```

# Create boot.tap

```
mv rk3 boot.dd
./enblock < boot.dd > boot.tap
```

Now you have a boot.tap file that can be used with Dennis's disk-set!

*post added 2022-12-01 13:27:00 -0600*



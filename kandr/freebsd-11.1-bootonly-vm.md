# FreeBSD 11 on VM from the Bootonly media


## Install NCFTP (or not, your choice)

On a Mac:

```
brew install ncftp
```

On Mint:

```
sudo apt-get install ncftp
```

Find the version you want to use from the [FreeBSD Download Site](https://www.freebsd.org/where.html#download). I picked an 11.1 version from [FreeBSD 11.1 ISO's](https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/11.1/). You could download directly from the site, but I am using ftp for this exercise.

Find a [mirror](https://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/mirrors-ftp.html). I chose [ftp://ftp.freebsd.org/pub/FreeBSD/](ftp://ftp.freebsd.org/pub/FreeBSD/).

## Make some space and download the iso and checksums

```
mkdir ~/freebsd-test
cd ~/freebsd-test

ncftp ftp.freebsd.org
cd /pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/11.1/
bookmark freebsd
quit
ncftp freebsd
get C*
get FreeBSD-11.1-RELEASE-amd64-bootonly.iso.xz
quit

grep FreeBSD-11.1-RELEASE-amd64-bootonly.iso.xz C*512*
openssl sha512 FreeBSD-11.1-RELEASE-amd64-bootonly.iso.xz 
SHA512(FreeBSD-11.1-RELEASE-amd64-bootonly.iso.xz)= d267e66a434c40ed409862ecdbe1610f3ced7a11cfc6f3b4ac59bd849d169169982ab8b028681c6daf30f6cf0815aec3b3c89fdfb1c442bef193ece1143dc605


unxz FreeBSD-11.1-RELEASE-amd64-bootonly.iso.xz
grep FreeBSD-11.1-RELEASE-amd64-bootonly.iso C*512*
openssl sha512 FreeBSD-11.1-RELEASE-amd64-bootonly.iso
SHA512(FreeBSD-11.1-RELEASE-amd64-bootonly.iso)= aa5891b9ab0bd2a1c13fdffd3ab80998f3d17bc54afeae0c183cf286d746f9b5eb8e1bd6b1a5598aeb36419fd1ca0becfa02d3f9854f382b1d7ad0cc2423f47f
```

The bootonly iso is still 299 MB!

## Create a new VM in Virtual Box
- Name FreeBSD1
- 8192 GB RAM (or whatever you like up to around half your ram)
- One or two hard drives 16GB each...
- 4 CPUs (or whatever you like up to around half your cores)
- Add bootonly iso to storage
- Choose NAT Adapter
- Configure SSH port forward 2222->22

## Boot from install media and install the base system
- Press Enter at the Boot Menu to select the default
- Press Enter to Select Install at the Welcome screen
- Press Enter to Continue to use the default US keymap
- Set the hostname - freebsd1.my.home
- Select doc and unselect ports, so that only doc and lib32 packages are selected and Press Enter
- Press Enter to Acknowledge that this is a Network Installation
  - Press Enter to Select em0 Intel Pro 1000
  - Press Enter to Select IPv4
  - Press Enter to Select DHCP
  - Select No to IPv6 and Press Enter
  - Press Enter to Select OK to confirm Network configuration
- Choose a mirror (I picked the Last USA Mirror in the hopes that it would have a smaller load than the others) ftp://ftp15.us.freebsd.org
- Select Auto (ZF) Guided Root-on-ZFS and press Enter
  - Select T Pool Type/Disks and Press Enter
  - Select Spripe - No Redundancy and Press Enter
  - Press Space to select ada0 and Press Enter
  - Select >>> Install and Press Enter
  - Select Yes and Press Enter to Confirm ZFS Configuration and write changes to ada0

The BSD installer gets the install files from the ftp server and installs the selections to disk

- Set root password and confirm
- Select Yes to choose UTC for local clock
  -Select 2. America
  - 49 United States
  - 11 Central Time
  - Select Yes for CDT
- Select sshd, moused, ntpd, powerd, dumpdev as services to start at boot
- Select Yes to add user
  - set Username, Full name, wheel, and password
  - Select Yes to save
  - Select No to stop adding users
- Select Exit to apply configurations
- Select No for manual configuration
- Select Reboot and remove media after it unmounts

## Post install

from host:

```
ssh freebsd1
```

login as normal user and become root:

```
su -
```

sync the time:

```
ntpdate -u pool.ntp.org
```

bring the system up to date (will install the pkg system):

```
freebsd-update fetch
freebsd-update install
halt

```

power off the vm

set vm to headless and restart

```
VBoxManage list vms
...
"FreeBSD1" ...

```
Set the VM to headless (use SSH to connect, Show the Console via the Gui if you need to see something)

```
VBoxManage modifyvm "FreeBSD1" --defaultfrontend headless

```

A headless VM Session can also be started from the command line via

```
VBoxHeadless -s "FreeBSD1"
```

or

```
VBoxManage startvm "FreeBSD1" --type headless
```

start the vm from the gui

from the host:

```
ssh freebsd1
```

on the guest:

```
su -
```

Upgrade the pkg system

```
doas -s
pkg update
pkg upgrade

exit

ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa.pub host

```

and from host

```
ssh-copy-id freebsd1
```

on the guest:

```
su -

freebsd-version -uk
11.1-RELEASE-p4
11.1-RELEASE-p6

pkg install doas bash subversion vim htop
mount -t fdescfs fdescfs /dev/fd

vi .profile
edit EDITOR=vim
add alias vi='vim'


vi /usr/local/etc/doas.conf
permit keepenv :wheel
exit
```

as user

```
doas ls to test
chsh
/usr/local/bin/bash

doas vi /etc/fstab
fdesc           /dev/fd         fdescfs rw      0       0
proc            /proc           procfs  rw      0       0

doas vi /boot/loader.conf
add
kern.vty=vt
autoboot_delay="1"
kern.ipc.shmmax=67108864
kern.ipc.shmall=32768
hw.ata.ata_dma="1"
hw.ata.atapi="1"
```

halt, powerdown and snapshot the vm post-setup

restart vm

```
ssh freebsd1
```

login as user

## build system from source

get the source for the release stable branch

```
doas svn checkout https://svn.freebsd.org/base/releng/11.1 /usr/src
```

enter a cleanroom environment

```
doas env -i bash
```

build the userland and kernel - takes a long time (as in an hour and a half)

```
cd /usr/src
time make -j4 buildworld buildkernel
...
real	95m58.850s
user	336m16.186s
sys	36m58.213s

install the kernel - takes a minute or so
cd /usr/src
make installkernel
shutdown -r now
```

install the userland - takes 10 minutes or so

```
doas env -i bash
cd /usr/src
make installworld
shutdown -r now
```

update config files and clean up - takes a minute or two

```
doas env -i bash
mergemaster -Ui

cd /usr/src
make check-old
make delete-old
make check-old-libs
make delete-old-libs
shutdown -r now
```

```
freebsd-version -uk
11.1-RELEASE-p6
11.1-RELEASE-p6

uname -a
FreeBSD freebsd1.my.home 11.1-RELEASE-p6 FreeBSD 11.1-RELEASE-p6 #0 r329423: Fri Feb 16 16:48:10 CST 2018     root@freebsd1.my.home:/usr/obj/usr/src/sys/GENERIC  amd64
```

## set up git repo for c explorations

```
doas pkg install git-gui 

git config --global user.name "User Name"
git config --global user.email user@emailprovider.com
git config --global push.default simple
git config --global core.pager "less -e -F -R -X"
git config --global core.excludesfile "~/.gitignore_global"
```


confirm the settings

```
git config --global -e

vi ~/.gitignore_global
*~
\#*\#
.emacs.desktop
.emacs.desktop.lock
*.elc
auto-save-list
tramp
.\#*

mkdir sandboxes
cd sandboxes
git clone your git repo
```

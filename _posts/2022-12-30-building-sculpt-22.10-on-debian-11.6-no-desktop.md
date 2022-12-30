---
layout: post
title:  "Building Sculpt 22.10 on Debian 11.6 Bullseye without a Desktop"
categories: operating-systems genode sculpt
---
Sheesh, live and learn. I didn't pay any attention to system requirements in the prior note [Building Sculpt 22.10 on Debian 11.6 Bullseye]({% post_url 2022-12-29-building-sculpt-22.10-on-debian-11.6 %}). I just glibly provisioned using a small portion of my available resources. In this note, I've corrected this oversight. The system requirements are much, much more modest than what I originally provisioned. There is no need for the overkill.

This note is about building a bootable Sculpt OS 22.10 image using a Debian 11 "Bullseye" Guest OS running in VirtualBox without a desktop. If you were to include the desktop, expect that the system requirements would increase, but not by lot. I expect it would work with these same provisions, but would work better with more CPUs and RAM, as well as with a bigger allocation of hard disk space.

Bottom line - The image can be built comfortably, in a reasonable amount of time (call it 15 minutes to download the toolchain, and source code, and do the build), on a system with 512 MB RAM, 1 CPU, 12 GB HDD, but it's faster with more resources provisioned, where CPU seems to be the biggest factor - more is better letting us use parallel threads in make.

<!--more-->

### Resources

* Genode Operating System Framework Website [https://genode.org/](https://genode.org/)
* Genode OS Framework 22.05 Foundations Document [html](https://genode.org/documentation/genode-foundations/22.05/index.html) [pdf](https://genode.org/documentation/genode-foundations-22-05.pdf)
* Sculpt OS 22.10 Documentation [html](https://genode.org/documentation/articles/sculpt-22-10) [pdf](https://genode.org/documentation/sculpt-22-10.pdf)
* Mailing List [https://genode.org/community/mailing-lists](https://genode.org/community/mailing-lists)
* Genodians - Stories around the Genode Operating System [https://genodians.org/](https://genodians.org/)
* Git repository - [https://github.com/genodelabs/genode](https://github.com/genodelabs/genode)

### Prerequisites

* Host system - Mine is 2010 Mac Pro running Mojave
* VirtualBox w/extension pack - I'm running 6.1.40

### Download the Debian 11.6 Bullseye netinst.iso

 `aria2c https://gemmei.ftp.acc.umu.se/debian-cd/current/amd64/iso-cd/debian-11.6.0-amd64-netinst.iso`

### Create a new debian virtualbox instance
* name: debian-11.6
* 1 GB RAM (tested with 512 MB RAM)
* 2 CPU (tested with 1 CPU, no parallel threads with make)
* 12 GB HDD

### Configure instance
* ssh port forwarding
* attach debian-11.6.0-amd64-netinst.iso

### Install Debian

Start the VM and let it boot to the installer. Choose Install and not Graphical Install to use the perfectly adequate and much faster text installer.

Make the following choice for packages:

* ssh
* standard system utilities

### Boot the VM (even headless works fine) 

### ssh into the instance

`ssh user@localhost -p 2222`

### Check disk space

```
df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            471M     0  471M   0% /dev
tmpfs            98M  500K   98M   1% /run
/dev/sda1        11G 1010M  9.3G  10% /
tmpfs           489M     0  489M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs            98M     0   98M   0% /run/user/1000

```

### Prepare Debian for building Sculpt

### Get rid of bracketed paste

* as regular user

`echo 'set enable-bracketed-paste off' >> ~/.inputrc`

exit and reenter

* as root

```
su -
echo 'set enable-bracketed-paste off' >> ~/.inputrc
```

exit and reenter

#### Install Packages

* update apt package list and upgrade packages

 `apt update && apt full-upgrade -y`

* install basic dev tools

 Note: build-essential and gdisk are already installed)

 * basics
     * build-essential
     * htop
     * sudo
     * vim
 * vbox dependencies
     * dkms
     * linux-headers
 * build system dependencies see Genode Foundations - Getting Started
     * autoconf
     * autogen
     * bison
     * byacc
     * ccache
     * e2tools
     * expect
     * flex
     * gawk
     * gdisk
     * git-gui
     * gperf
     * libsdl2-dev
     * libxml2-utils
     * qemu
     * subversion
     * xorriso
     * xsltproc

 Note: apt will ignore already installed packages and different base selections such as Gnome vs Cinnamon may result in a different mix of already installed packages.

 ```
apt install build-essential htop sudo vim \
     dkms linux-headers-$(uname -r) \
     autoconf autogen bison byacc ccache e2tools expect flex gawk \
     gdisk git-gui gperf libsdl2-dev libxml2-utils qemu subversion \
     xorriso xsltproc -y
```

* set vim as default editor

 `update-alternatives --config editor # pick vim.basic`

* turn off mouse nonsense in vim as root and regular user

 `echo "set mouse-=a" >> ~/.vimrc`

* Add user to sudo and enable sudo with no password

 ```
visudo
%sudo	ALL=(ALL:ALL) NOPASSWD:ALL
```

* add user to sudo group

 ```
 usermod -a -G sudo wsenn
 exit
 ```

* as regular user add sbin to path for build resize2fs requirement

 ```
echo "export PATH=$PATH:/sbin" >> ~/.bashrc
```

* exit and reenter ssh

`ssh user@localhost -p 2222`

### Run htop to see system resources during the build

* ssh into a second terminal instance and fire up htop

```
ssh user@localhost -p 2222
htop
```

### Install Genode Toolchain and Source Code

* Download the toolchain and install it in /usr/local/genode

 ```
mkdir -p ~/Downloads
cd ~/Downloads
wget -O genode-toolchain-21.05-x86_64.tar.xz https://sourceforge.net/projects/genode/files/genode-toolchain/21.05/genode-toolchain-21.05-x86_64.tar.xz/download
sudo tar xvPf genode-toolchain-21.05-x86_64.tar.xz
```

* Clone the source code and switch to the 22.10 release branch

 ```
cd
git clone https://github.com/genodelabs/genode.git
cd genode
git checkout -b sculpt-22.10 sculpt-22.10
```

### Build Sculpt

* Get the nova kernel files

 `./tool/depot/download genodelabs/bin/x86_64/base-nova/2022-10-11`

* Get the sculpt files

 `./tool/depot/download genodelabs/pkg/x86_64/sculpt/2022-10-13`

* Handle vim-minimal tarball error by just restarting

You may see an error concerning vim-minimal (I do):

```
download genodelabs/src/vim-minimal/2022-08-30.tar.xz
download genodelabs/src/vim-minimal/2022-08-30.tar.xz.sig
xz: (stdin): Unexpected end of input
tar: Unexpected EOF in archive
tar: Unexpected EOF in archive
tar: Error is not recoverable: exiting now
make[1]: *** [/home/wsenn/genode/tool/depot/mk/downloader:45: /home/wsenn/genode/depot/genodelabs/src/vim-minimal/2022-08-30] Error 2
```

* If so, just restart the download

 `./tool/depot/download genodelabs/pkg/x86_64/sculpt/2022-10-13`

* Get the drivers, wifi, and ipxe files

 ```
./tool/depot/download genodelabs/pkg/x86_64/drivers_managed-pc/2022-10-11 \
 genodelabs/pkg/x86_64/wifi/2022-10-13 \
 genodelabs/bin/x86_64/ipxe_nic_drv/2022-10-11
```

* Create the build directory

 `./tool/create_builddir x86_64`

* Edit the build configuration (required)

 `vi build/x86_64/etc/build.conf`

 * Enable parallel threads in make if you have more than one CPU

     `MAKE += -j4`

 * Enable ccache

     `CCACHE := yes`

 * Enable depot updates

     `RUN_OPT += --depot-auto-update`

 * Change from iso target to disk in QEMU_RUN_OPT

     `QEMU_RUN_OPT := --include power_on/qemu  --include log/qemu --include image/disk`

 * Enable port repos by uncommenting them (all but world)
      * libports
      * ports
      * dde_linux
      * dde_rump
      * gems
      * pc
      * dde_bsd
      * dde_ipxe

* Prepare ports

 ```
./tool/ports/prepare_port bash coreutils curl dde_ipxe dde_linux dde_rump e2fsprogs-lib gnupg grub2 jitterentropy libarchive libc libgcrypt libnl libpng libssh linux linux-firmware ncurses nova openssl stb ttf-bitstream-vera vim wpa_supplicant x86emu xz zlib
```

* Build the image

 `make -C build/x86_64 run/sculpt KERNEL=nova BOARD=pc`

* Success is indicated by the creation of the image

 `Created image file var/run/sculpt.img (29140kiB)`

### Test the created image on metal

* Transfer the image to the host
 ```
 mkdir -p ~/Downloads
 cd ~/Downloads
 scp -P 2222 localhost:genode/build/x86_64/var/run/sculpt.img .
 ```
* Burn it to USB using your preferred tool (I use balena etcher or dd)

* Test it out with your target device (mine is T430)

* Hope it works great! 

*post last updated 2022-12-29 11:53:00 -0600*
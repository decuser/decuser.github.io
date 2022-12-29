---
layout: post
title:  "Building Sculpt 22.10 on Debian 11.6 Bullseye"
categories: operating-systems genode sculpt
---
This note is about building a bootable Sculpt OS 22.10 image using a Debian 11 "Bullseye" Guest OS running in VirtualBox. This is useful as a starting point for building a custom image. My Thinkpad T430 runs Sculpt just fine, but wifi doesn't work, so I would like to add the needed firmware. This is work in that direction.

The note also applies, leaving out the VirtualBox specifics, to building Sculpt OS 22.10 on a Debian instance running on metal (confirmed working 12/28).

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
* 8GB RAM
* 2 CPUs
* 20GB HDD
* attach ~/shared
* attach debian-11.6.0-amd64-netinst.iso

### Install Debian

Start the VM and let it boot to the installer. Choose Install and not Graphical Install to use the perfectly adequate and much faster text installer.

Make the following choice for packages:

* Debian desktop environment
    * Cinnamon (relatively lightweight and just works)
* standard system utilities

### Prepare Debian for building Sculpt

#### Add user to sudo

* enable sudo with no password

 ```
su -
visudo
%sudo	ALL=(ALL:ALL) NOPASSWD:ALL
```

* add user to sudo group

 `usermod -a -G sudo wsenn`

* Restart to get the group to take (should just require logout and back in, but it's what it is)

#### Install Packages

* update apt package list and upgrade packages

 `sudo apt update && sudo apt full-upgrade -y`

* install basic dev tools

 Note: build-essential and gdisk are already installed)

 * basics
     * build-essential
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
sudo apt install build-essential vim \
     dkms linux-headers-$(uname -r) \
     autoconf autogen bison byacc ccache e2tools expect flex gdisk git-gui \
     gperf libsdl2-dev libxml2-utils qemu subversion xorriso xsltproc
```

* as regular user set vim as default editor

 `sudo update-alternatives --config editor # pick vim.basic`

* turn off mouse nonsense in vim

 ```
vi ~/.vimrc
set mouse-=a
```

* add sbin to path for build resize2fs requirement

 ```
vi .bashrc
export PATH=$PATH:/sbin
```

#### Install Guest Additions

* mount the cd and install guest additions

* in vbox - `Devices->Insert Guest Additions CD Image`

 ```
sudo mount /dev/cdrom /mnt
cd /mnt
sudo sh ./VBoxLinuxAdditions.run
```

* create a location to mount shared files

 `mkdir ~/shared`

* add it to fstab

 ```
sudo vi /etc/fstab
shared    /home/wsenn/shared    vboxsf    defaults    0    0
```

* enable vbox module for sharing

 ```
sudo vi /etc/modules
vboxsf
```

* Reboot

 `sudo shutdown -r now`


#### Test shared folder and enable clipboard

* Test the share

 `ls ~/shared`

 Should list any files you've put in shared.

* Enable bi-directional clipboard

 in vbox `Devices->Shared Clipboard->Bidirectional`


### Install Genode Toolchain and Source Code

* Download the toolchain and install it in /usr/local/genode

 ```
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

If you get an error concerning vim-minimal (I do), just restart the download of the sculpt packages...

 ```
download genodelabs/src/vim-minimal/2022-08-30.tar.xz
download genodelabs/src/vim-minimal/2022-08-30.tar.xz.sig
xz: (stdin): Unexpected end of input
tar: Unexpected EOF in archive
tar: Unexpected EOF in archive
tar: Error is not recoverable: exiting now
make[1]: *** [/home/wsenn/genode/tool/depot/mk/downloader:45: /home/wsenn/genode/depot/genodelabs/src/vim-minimal/2022-08-30] Error 2
```

* Restart the sculpt files download

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

 * Enable parallel threads in make

     `MAKE += -j8`

     Note: if your cpu can't handle it, dial it back to -j4.

 * Enable ccache

     `CCACHE := yes`

 * Enable depot updates

     `RUN_OPT += --depot-auto-update`

 * Change from iso target to disk in QEMU_RUN_OPT

     `QEMU_RUN_OPT := --include power_on/qemu  --include log/qemu --include image/disk`

 * Enable port repos by uncommenting them
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

* Attach usb to host

* Capture it in VirtualBox

* Determine the assigned usb device

 ```
sudo dmesg|grep sd
...
[ 7754.230860] sd 3:0:0:0: [sdb] Attached SCSI removable disk
```

* Determine the mounted drives

 `mount | grep sd`

 Note: this important as the order of assigned devices could change and you want to be sure to write to the usb and not a hard drive (virtual or otherwise).

* Write the image to the target USB

 `sudo dd if=build/x86_64/var/run/sculpt.img of=/dev/sdb bs=1M conv=fsync`

* Test it out with your target device (mine is T430)

* Hope it works great! 

*post last updated 2022-12-29 11:53:00 -0600*
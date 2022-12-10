---
layout:	post
title:	Restoring Grub - dual boot FreeBSD and Linux
date:	2018-08-09 14:29:00 -0600
categories:	unix
---
Note describing how to restore the grub bootloader after it is catastrophically removed. Please note that it may be specific to my setup:
<!--more-->

```
FreeBSD 11.2 running root on ZFS alongside Linux Mint 18.2
5 gpt partitions:
1. freebsd-boot 128K
2. freebsd-swap 17G
3. freebsd-zfs 63G
4. linux-ext4 137G
5. linux-swap 17G
```

Notice that there isn't a bios-boot or efi boot.


When I installed Mint, FreeBSD was already installed. The Mint installer happily installed its root system into /dev/sda4 and the grub boot manager into /dev/sda. I had to create a 40_custom file in /etc/grub.d and tell it how to find my freebsd instance, but once that was done and update-grub did its thing, I got dual boot working.

Fast forward a few hours and I thought running this command was a good idea:

`gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada0`

But, this kinda hurt because the FreeBSD boot loader was back in charge and it knows nothing about linux on a gpt partition. So, I was off to figuring out how to restore grub. After a lot of scouring the Internet and some painful re-and-re-re-installations, I figured out how to get it restored.

Thankfully, mint keeps a record of the installation in `/var/installation/syslog`. By reading this file, I found the magic incantation that was required. --force, an argument that should be self explanatory was the solution...

Here is the procedure that worked:

1. Boot the T430 from the Linux Mint live install media
2. Fire up a Terminal and run these commands

```
# enter a root shell
sudo -s                                                         

# mount the linux-ext4 root fs
mount /dev/sda4 /mnt                                            

# mount dev et al in /mnt for chroot
for i in /dev /dev/pts proc sys; do mount -B $i /mnt/$i; done   

# enter the chroot for the root fs
chroot /mnt                                                     

# don't do additional probing
chmod a-x /mnt/etc/grub.d/30_os_prober                          

# update grub
update-grub                                                     

# if you don't force, will fail due to gpt
grub-install --force /dev/sda                                   

# exit the chroot
exit                                                            

# exit the root shell
exit                                                            

# exit the user shell
exit
```

Reboot, and voila! Grub is back.

For reference, here's the 40_custom file (I mount the dataset zroot/ROOT/default as / in FreeBSD:

```
menuentry "FreeBSD" --class freebsd --class bsd --class os {
savedefault
insmod zfs
insmod part_gpt
search -s -l zroot
kfreebsd /ROOT/default/@/boot/kernel/kernel
kfreebsd_module_elf /ROOT/default/@/boot/kernel/opensolaris.ko
kfreebsd_module_elf /ROOT/default/@/boot/kernel/zfs.ko
kfreebsd_module /ROOT/default/@/boot/zfs/zpool.cache type=/boot/zfs/zpool.cache
set kFreeBSD.vfs.root.mountfrom=zfs:zroot/ROOT/default
set kFreeBSD.hw.psm.synaptics_support="1"
}
```

*post added 2022-12-01 07:57:00 -0600*
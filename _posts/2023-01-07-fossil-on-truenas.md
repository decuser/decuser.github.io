---
layout: post
title:  "Installing and running Fossil on TrueNAS Core"
categories: operating-systems truenas-core fossil
---
This note is about installing and running Fossil SCM on TrueNAS Core. 

Fossil is brought to us by the same people who developed SQLite. It was created to serve their needs, but is useful to everybody with a similar set of needs (pretty much any dev team). According to the fossil folks over at [https://fossil-scm.org](https://fossil-scm.org), "Fossil is a simple, high-reliability, distributed software configuration management system..." To mme, it's my git-killer.

I have been running Fossil for about a year to see if it was worth replacing git for my own use. After this year, while I still like git and I will continue to use it for disposable repos, I have completely jumped ship for my own repos and won't be going back to hosting them on anything else anytime soon. Fossil is very lightweight, fast and responsive, has a fantastic server side ui, and is slightly more intuitive to use. It is also easier to recover from when things go wonky.

<!-- more -->

I will be posting more about TrueNAS Core in the near future, as I learn more about it (so far, it rocks!).

### Requirements

* A host to work from (I'm using Mac Pro, Mojave)
* A TrueNAS Core instance (mine is TrueNAS-13.0-U3.1 running on a Lenovo Thinkcentre m92p w/lots of memory, disks, a working network, etc.

### Overview

This is a quick guide for getting fossil up and running in a FreeBSD 13.1 jail, running in TrueNAS Core instance. The steps are:

* Create the Jail

 * Start the add jail wizard
 * Name it and choose the FreeBSD Release version
 * Configure the network
 * Review the Summary and hit Submit
* Configure the Jail
 * Start the Jail
 * Open the Jail's Shell
 * Add a new user
 * Enable and start sshd
 * Get ssh working
 * Do updates and upgrades
 * Install sudo and configure
 * Add a mount point for the fossils directory
 * Mount the fossil directory in the jail in TrueNAS UI
     * Stop the jail
     * Add the mount point
     * Start the jail
 * Install fossil
 * Add a tweak to rc file
 * Start fossil
 * Browse to the repos

#### Create the Jail

##### Start the add jail wizeard
* Select Jails->Add->Wizard


##### Name it and choose the FreeBSD Release version

```
    Name: fossil
    Jail Type: Default (Clone Jail)
    Release 13.1 RELEASE
    Next
```

##### Configure the network

``` 
    DHCP Autoconfigure IPv4 (it will pick VNET and Berkley Packet Filter)
    Next
```

##### Review the Summary and hit Submit

```
    Jail Summary

    Jail Name: fossil
    Release: 13.1-RELEASE
    DHCP Autoconfigure IPv4: Yes
    VNET Virtual Networking: Yes
    NAT Autoconfigure IPv4: No
```

* Click Submit

#### Configure the Jail

##### Start the Jail

* Select the jail and click the Start button

##### Open the Jail's Shell

* Select the jail and click Shell

##### Add a user (add them to wheel)

` adduser`

##### Enable and start sshd for the jail

```
sysrc sshd_enable="YES"
service sshd start
```

##### Get sshd working

* Get the ip address for the jail

```
ifconfig 
...
192.168.254.24
...
```

* On the host add an entry to /etc/hosts

`192.168.254.24 fossil fossil.sentech`

* Copy your ssh key over

`ssh-copy-id fossil`

* ssh in, become root, and change the password

 ```
ssh fossil
su -
passwd
```

* turn DNS off for sshd - it adds latency

``` 
vi /etc/ssh/sshd_config
UseDNS no
```

* Restart sshd and relogin

```
service sshd restart
exit

ssh fossil
```

##### Do updates and upgrades

```
su -
pkg update
pkg upgrade -y
```

##### Install sudo and configure

```
pkg install sudo
visudo
%wheel ALL=(ALL:ALL) NOPASSWD: ALL
exit
sudo ls
```

##### Add a mount point for the fossils directory

`sudo mkdir -p /zfs/fossils`

##### Mount the fossil directory in the jail in the TrueNAS UI

###### Stop the jail using TrueNAS UI

###### add mountpoint for /zfs/fossils

```
Source: /mnt/zfs/fossils
Destination: /zfs/fossils
```

* Click Submit

###### Start the jail using TrueNAS UI

Note: the filesystem will appear to be a regular directory, 
do zfs operations in TrueNas...

* If your fossils are owned by a user, chown them to nobody

```
ssh fossil
sudo chown -R nobody:nobody /zfs/fossils
```

##### Install fossil

`pkg install fossil`


##### Add a tweak to rc file

* Add support for fossil_errorlog variable to fossil_args

Put the following with the other fossil_args

```
vi /usr/local/etc/rc.d/fossil
[ -n "${fossil_errorlog}"  ] && fossil_args="${fossil_args} --errorlog ${fossil_errorlog}"
```

* Configure using rc vars

```
sysrc fossil_enable="YES"
sysrc fossil_repolist="YES"
sysrc fossil_directory="/zfs/fossils"
sysrc fossil_listenall="YES"
sysrc fossil_errorlog="/zfs/fossils/fossil.log"
```

##### Start fossil
service fossil start

##### Browse to the repos
http://fossil:8080

Tool around and convince yourself things are working and celebrate!


*post last updated 2023-01-07 15:36:00 -0600*
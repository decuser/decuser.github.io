---
layout:	post
title:	freebsd 2020 ep 1 installing freebsd 12.1 on virtualbox 6.1 the long version
date:	2020-08-03 00:00:00 -0600
categories:	unix freebsd videos
---
<iframe width="560" height="315" src="https://www.youtube.com/embed/9-fCRK8XSS8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

<!--more-->

Welcome to the Systems Development in FreeBSD (2020) Series. This series of videos are presented to help students of my systems development class setup and use a virtual FreeBSD system for doing systems development. Errata are at the end of the description (last update 20200805)

The first two videos in this series are inspired by and similar in nature to Roller Angel's presentations to FreeBSD Fridays entitled "FreeBSD InstallFest" Parts 1 and 2:

* Part 1: [https://youtu.be/K8cBa8y3RNQ](https://youtu.be/K8cBa8y3RNQ)
* Part 2: [https://youtu.be/pbZZDWoH7LE](https://youtu.be/pbZZDWoH7LE)

This first video is a tutorial on how to install FreeBSD 12.1 in VirtualBox. 

I am running on a Macbook Pro (mid 2012) with MacOS 10.14.6 Mojave and VirtualBox 6.1, but the tutorial also applies to Windows or Linux or pretty much any platform capable of running VirtualBox. 

Next Up: Installing TWM and Lumina for a Lightweight Desktop Experience

Next Next Up: Installing Plasma for a full Desktop Experience


Errata (thanks to helpful critiques from viewers and FreeBSD forum users):

1. @diizzy - bootonly image is sufficient for this usecase, since we are accessing the network anyway. The main difference between the disc1 image and bootonly is that bootonly doesn't have the distribution files or packages on the media and downloads the distribution files over the network.
2. @diizzy - disc1 isn't actually a cd image (hasn't been for a while), it's just a 900MB iso image.
3. @diizzy - Use AHCI as the controller type rather than the default PIIX4. It's more current and better supported.
4. @diizzy - Use GPT (GUID Partition Table), it's more current and supported. Oh, and Windows has supported it since Windows 7 :)
5. @diizzy - Mistakenly referred to the ada device as AHCI or ATAPI, it's not ATAPI, and since we didn't select AHCI as the controller, initially, it isn't AHCI, either, but it is an ATA (Advanced Technology Attachment) Direct Access Device.

*post added 2022-12-02 08:57:00 -0600*
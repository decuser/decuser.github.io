---
layout:	post
title:	Installing freebsd 8.4 to work with Kongs driver book
date:	2020-08-06 00:00:00 -0600
categories:	unix freebsd videos
---
<iframe width="560" height="315" src="https://www.youtube.com/embed/li5YB9Q1dOg" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

<!--more-->

his tutorial walks the user through setting up a virtual development environment capable of being used to work through Joseph Kong's book, "FreeBSD Device Drivers: A Guide for the Intrepid" in 2020. The book was written in 2013 and while it can be used with a more recent installation, there are some annoying changes that will frustrate the developer working through the book.


The environment that is setup is a FreeBSD 8.4 instance running ssh. The VM doesn't require access to the network and probably shouldn't have that access. The VM is suitable for building and testing kernel modules. Anything developed in the VM would likely need some minor modifications to run in a modern system, but would be entirely suitable for learning about device driver development as discussed in the book.


Here's a link to the [script file](https://gist.github.com/decuser/288b263867442ac8dfe6052ae7b63beb) 


*post added 2022-12-02 09:57:11 -0600*
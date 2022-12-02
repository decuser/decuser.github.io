---
layout:	post
title:	How to forward mail from root to user
date:	2020-07-22 10:31:00 -0600
categories:	unix
---
This note explains the super simple approach to forwarding mail on the local system from the root account to a user. It's really for people who manage their own system and don't want to have to always be logging in as the root user to read the system mail. It is based on the idea that you really are the root user, but you're logging in as a normal user.

If you're running X (twm, etc), this lets you run xbiff as a normal user and get notified when the system sends an email to root (sudo, periodic scripts, etc).

<!--more-->

## Edit aliases to add an alias

```
sudo vi /etc/aliases
# root:    me@my.domain
root: yourusername
```

## Tell the system about the changes

`sudo newaliases`

That's it. Now roots mail will come direct to your mailbox.

## To test

```
mail root
Subject: A test email to root
This is a test
.
EOT
```

Reenter mail

```
mail
Mail version 8.1 6/6/93.  Type ? for help.
"/var/mail/youruser": 1 messages 1 new 1 unread
>N 1 youruser@yourhost.yourdomain Wed Jul 22 12:27  19/800   "A test email to root"
& 1
From youruser@yourhost.yourdomain Wed Jul 22 11:06:30 2020
Date: Wed, 22 Jul 2020 11:06:30 -0500 (CDT)
From: "Your User" <youruser@yourhost.yourdomain >
To: root@yourhost.yourdomain
Subject: A test email to root

This is a test

& x
```

Celebrate!

*post added 2022-12-02 08:36:00 -0600*

---
layout:	post
title:	Fix for Thunderbird hangs while indexing messages
date:	2024-08-16 05:05:00 -0600
categories:	unix
---
This note describes a method for fixing Thunderbird when it hangs while indexing.


I'm posting this in case it's useful to folks and for my own reference. It took me a quite a while to figure it out.

So you have been using Thunderbird for your email for a while, on Windows, Linux, Mac, FreeBSD, and so on, for let's say a couple of decades. If you copy your profile around much, you are bound to hit an indexing issue where Thunderbird is unable to index your archives. You open up Activity Manager and it helpfully reports:

Indexing 32 of 14243 messages in Archives/2002-2020/2016

Read on for the fix.
<!--more-->

You watch the Activity Manager for a while, mesmerized perhaps by it's stolid refusal to progress or go away. Then you fire up your favorite search engine and start looking for answers. If you're lucky, this page pops up, otherwise you read drivel like "try again", "delete your index and rebuild it", or even reinstall.

If you're on linux, or another unix that has similar functionality, you can do this!

In a terminal:

```
strace  thunderbird
```

In thunderbird:
open Tools->Activity Manager

When it gets to the place where it hangs, in the terminal, press CTRL-C to end the session. Capture the output from the terminal window into a text editor and search from the bottom up for the directory it's complaining about. In the above example, look for the last occurance of 2016/. The trailing slash is important to include in your search to find the correct information.

In my strace output, the last occurance(s) are:

```
access("/home/wsenn/Thunderbird/Mail/Local Folders-maildir/Archives.sbd/2002-2020.sbd/2016/cur", F_OK) = 0
openat(AT_FDCWD, "/home/wsenn/Thunderbird/Mail/Local Folders-maildir/Archives.sbd/2002-2020.sbd/2016/cur/1723773452464.eml", O_RDONLY) = 147
```

This is likely (so far, it's always, but time may tell if there are exceptions) the file that's breaking the indexing. Move it off somewhere to review:

```
mkdir -p ~/Desktop/2016
mv "/home/wsenn/Thunderbird/Mail/Local Folders-maildir/Archives.sbd/2002-2020.sbd/2016/cur/1723773452464.eml" ~/Desktop/2016/
```

Restart thunderbird without strace and pull up activity manager to see if it continues. If so, rinse and repeat as needed.

-- will

*post added 2024-08-16 10:27:00 -0600*

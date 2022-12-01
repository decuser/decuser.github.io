---
layout:	post
title:	linux-mint-note
date:	2018-04-21 00:00:00 -0600
categories:	unix linux mint
---

# Linux Mint Note

## Mint 18 - utf issue

**FIX**: 'Warning: No support for locale: en_US.utf8' issue in mint - sheesh, dunno why this persists. The folks on the forums say it's not a real problem. Apparently, they don't work with apt much. This stupid error causes apt to pause multiple times during updates while it 'figures out' that the utf files are 'missing'. To fix:

`sudo locale-gen --purge --no-archive`

This gets rid of the local-archive in `/usr/lib/locale` and generates the 'missing' utf8 files.

**FIX**: To boot mint to the last booted OS by default, put the following in `/etc/default/grub`:

```
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
```

Then run:

`sudo update-grub`

*post added 2022-12-01 17:14:00 -0600*
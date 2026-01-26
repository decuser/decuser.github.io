---
title:	Turn off that pesky Visual Mode mouse integration in VIM
tags: unix vim
---
This is a note about how to kill that mouse craziness with vim.

If you're already in vim type
`: set mouse-=a`

If you want it off all the time, edit your .vimrc and add

```
vi ~/.vimrc
set mouse-=a
```

Now you can select, copy, and paste using vim and your os's normal functionality.

<!--more-->

*post added 2022-12-02 08:07:00 -0600*
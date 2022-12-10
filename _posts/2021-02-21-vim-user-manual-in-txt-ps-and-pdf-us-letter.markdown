---
layout:	post
title:	Vim User Manual in txt and ps and pdf us-letter
date:	2021-02-21 00:00:00 -0600
categories:	unix vim
---
This note describes how to create a pdf (and ps, and txt) version of the latest Vim documentation. I got sick of trying to find a useable and current pdf on the web, so I just figured out how to do it from source and am posting the howto for others who might come after.

This is current as of February 17, 2021.

<!--more-->
 
```
mkdir -p ~/sandboxes/_others
cd ~/sandboxes/_others
git clone https://github.com/vim/vim.git
mkdir ~/Desktop/vim-usr_doc
cd ~/Desktop/vim-usr_doc
cp ~/sandboxes/_others/vim/runtime/doc/usr* .
cat usr_toc.txt usr_??.txt > usr_doc.txt
vim usr_doc.txt -c "syntax off | hardcopy > usr_doc.ps | q"
ps2pdf usr_doc.ps
open usr_doc.pdf
```

Simple, no?

Here is the text version (8.2): [https://bit.ly/3pq1hjv](https://bit.ly/3pq1hjv)

Here is the postscript version (8.2): [https://bit.ly/37nXMEl](https://bit.ly/37nXMEl)

Here is the pdf version (8.2): [https://bit.ly/3k0d86I](https://bit.ly/3k0d86I)

*post added 2022-12-02 09:54:00 -0600*
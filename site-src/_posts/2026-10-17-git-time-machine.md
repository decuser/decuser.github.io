---
title: "Git Time Machine: Browsing a Repository Through Time."
tags: [git pascal lazarus freepascal fuse software-tools]
---

## Git Time Machine: a filesystem with a past.

I have been working on a tool called Git Time Machine (GTM). The idea is simple: instead of thinking of a Git repository as a sequence of commits, treat it as a filesystem that can be visited at different points in time.

Pick a repository, a branch, and a moment. GTM finds the corresponding historical snapshot. From there you can browse files, inspect their histories, compare versions, and extract an older file without disturbing your working tree.

<!--more-->

The project has a shared Free Pascal core, a command-line interface, and a Lazarus GUI. There is also a terminal interface, because sometimes a terminal is exactly the right place to be.

The GUI, with its timeline and historical file browser:

![Git Time Machine graphical interface](/assets/img/gtm/gtm-gui.png)

And the terminal interface:

![Git Time Machine terminal interface](/assets/img/gtm/gtm-tui.png)

One part of the experiment is exposing a selected snapshot as a read-only filesystem through FUSE. The interesting thing is that the files are not restored into a checkout: the historical view is supplied on demand from Git objects.

GTM is still development software. There are rough edges, particularly around navigating large histories and presenting branches, forks, and merges clearly. But the central idea is working well enough to use while developing other projects.

Source and development baseline:

[https://github.com/decuser/gtm](https://github.com/decuser/gtm)

I like the idea of moving a slider and watching a repository become what it used to be.

*post updated 2026-10-17 16:15:00 -0500*

---
title: "Lions Laboratory: A Sixth Edition UNIX Laboratory for OpenSIMH"
tags: [unix unix-v6 lions pdp-11 opensimh]
---

As a follow-up to my note on [setting up a Sixth Edition UNIX laboratory in OpenSIMH](/posts/setting-up-unix-sixth-edition-opensimh-laboratory-for-reading-lions/), I have now put the complete laboratory repository on GitHub:

[decuser/lions-laboratory](https://github.com/decuser/lions-laboratory)

The repository contains the V6 distribution materials, OpenSIMH configurations, PDP-11/40 and peripheral documentation, known-good system checkpoints, and the working notes I have accumulated while reading Lions and experimenting with the system.

<!--more-->

The original note concentrated on constructing a complete, restorable V6 system suitable for reading John Lions' *A Commentary on the UNIX Operating System*. The repository takes that a bit further. Rather than being just a finished V6 installation, it is intended as a laboratory in which the system can be examined, changed, broken, debugged, and restored.

Along with the basic V6 environment, I have been adding notes from things I have actually tried while working through Lions. So far these include working backward through the RK05 boot process from the kernel to the filesystem-aware `rkuboot` and finally to an 11-word first-stage bootstrap; stepping through portions of the boot process under OpenSIMH; examining device-driver behavior; and making small kernel modifications such as adding `/dev/zero`.

The repository also includes the documentation for the PDP-11/40 and the peripherals configured in the laboratory. This makes it possible to move back and forth between Lions' source listing, the V6 source tree, the DEC hardware documentation, and the behavior of the running machine.

The goal is not simply to have V6 running in an emulator. It is to provide a reasonably self-contained environment for exploring how the system actually works at the level Lions describes it.

The laboratory is here:

[decuser/lions-laboratory](https://github.com/decuser/lions-laboratory)

The original setup note is here:

[Setting Up UNIX - Sixth Edition: An OpenSIMH Laboratory for Reading Lions](/posts/setting-up-unix-sixth-edition-opensimh-laboratory-for-reading-lions/)

And the companion source edition is here:

[Updated and expanded Lions V6 source v1.4](/posts/updated-lions-v6-source-w-appendices-and-helps-v1.4/)

*post added 2026-08-08 18:15:00 -0500*


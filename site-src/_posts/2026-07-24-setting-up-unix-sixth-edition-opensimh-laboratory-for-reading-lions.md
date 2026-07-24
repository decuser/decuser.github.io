---
title: Setting Up UNIX—Sixth Edition: An OpenSIMH Laboratory for Reading Lions
tags: unix research-unix v6
---

This note covers building a complete, restorable Sixth Edition UNIX laboratory in OpenSIMH for reading John Lions’ *A Commentary on the UNIX Operating System*. First, the reader is led through restoring the original V6 distribution from tape to RK05 disk images. Next, the kernel is reconfigured and rebuilt for the PDP-11/40 and the simulated devices used in the laboratory. The remaining source and documentation filesystems are then installed, the required special files are created, and the completed system is verified and archived as a restorable baseline.

The note explains each step of the process in detail and connects Lions’ commentary and numbered source listing to the corresponding files and configured kernel in the running V6 system.

<!--more-->

Last Updated July 24, 2026

### Revision history

Version 1.0 - initial release:

* Reconstructs the PDP-11/40 environment assumed by Lions.
* Installs the complete V6 source and documentation filesystems.
* Rebuilds the kernel for the OpenSIMH laboratory configuration.
* Creates and verifies the required device special files.
* Produces a tested, restorable baseline archive.
* Intended for use with my updated and expanded edition of *UNIX Operating System Source Code Level Six*.

Here's the note, as a PDF:

<iframe
  allow="autoplay"
  src="https://drive.google.com/file/d/1GDx9S1faP6-iPqFVnJUk84KIg2vZkJA-/preview"
  style="width:100%; max-width:640px; height:480px; border:0;">
</iframe>

Local copy here: [setting-up-unix-v6-opensimh-reading-lions-v1.0.pdf](/assets/pdf/unix/setting-up-unix-v6-opensimh-reading-lions-v1.0.pdf)

Companion source edition: [Updated and expanded Lions V6 source v1.4](/posts/updated-lions-v6-source-w-appendices-and-helps-v1.4/)

*post added 2026-07-24 14:00:00 -0500*

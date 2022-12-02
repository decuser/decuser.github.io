---
layout:	post
title:	Nyquist what?! Gobsmacked by Sampling Frequency
date:	2022-06-09 14:45:00 -0600
categories:	electronics theory
---
A note to capture what I learned the hard way about sampling frequencies.

<!--more-->

Today, I was messing around with my el-cheapo logic analyzer and getting some funky results. I hooked it up to the CLK-IN signal of my PAL-1 6502 and was told by Pulseview that the clock was 5xxHz, when that crystal says 1Mhz on it! After much ado, Hans in the PAL-1 Google group told me about Nyquist Frequency. I looked it up, watched this fantastic video by NERDfirst [https://youtu.be/yWqrx08UeUs](https://youtu.be/yWqrx08UeUs), and reran my experiment. The results were much better. The moral of the story is that whenever you set a sampling rate, it needs to be a little more than 2 times the highest frequency waveform you are hoping to capture to even have a snowballs chance of being accurate. I set Pulseview to 4Mhz - 4 times the 1Mhz clock signal I was trying to sense. 

Before:

![one](/assets/img/nyquist/01.png)

After:

![two](/assets/img/nyquist/02.png)

Nifty.

Links to high res images:

* [before correction](/assets/img/nyquist/01-big.png)
* [after correction](/assets/img/nyquist/02-big.png)


<!--more-->

*post added 2022-12-02 10:54:00 -0600*
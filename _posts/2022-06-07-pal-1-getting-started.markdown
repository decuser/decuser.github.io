---
layout:	post
title:	PAL-1 Getting Started
date:	2022-06-07 06:56:00 -0600
categories:	retro-computing pal-1
---

This is a note on how to get and get started using a PAL-1. The PAL-1 is a replica of the KIM-1, an old-school 6502 trainer, from back in the day.

<!--more-->

Let's get started.

## Preliminaries
In order to put the PAL-1 together, you should have a work area that is well lit, a magnifying glass, a soldering iron/station, and a desoldering wick/pump.

1. Get a PAL-1 kit (a pcb and lots of parts to solder) [https://www.tindie.com/products/tkoak/pal-1-a-mos-6502-powered-computer-kit](https://www.tindie.com/products/tkoak/pal-1-a-mos-6502-powered-computer-kit)

 It's $80 and it goes in and out of stock pretty regularly.

2. Get a 7 volt 1 or 2 amp DC power supply with 2.5mm x 5.5mm jack

3. Get the user manual and read it [http://pal.aibs.ws/assets/PAL_en.pdf](http://pal.aibs.ws/assets/PAL_en.pdf)

4. Open the box and take out the parts. Refer to the interactive bill of materials (BOM) [http://pal.aibs.ws/assets/ibom/pal-1.html](http://pal.aibs.ws/assets/ibom/pal-1.html)

 Use the BOM to make sure all of the parts are present before you start soldering. It is also super useful for locating where parts are located on the PCB when you start soldering.

5. Optionally, consider cleaning the flux off the board before soldering - use a fiberglass brush or other method. This makes soldering faster and reduces the chances of cold joints.

6. Solder in a rational order and watch out for solder bridges

 * Start with resistors, capacitors and diodes (low profile components)
 * Then do resistor network, electrolytic capacitors, led, and sockets
 * Then do power regulator and power jack
 * Do a smoke test (plug in and see if anything smokes)
 * Then do pushbuttons, and sst switch
 * Then do io pins and jumper pins
 * Then do the 7-segments, use a black sharpie on the outside edges of the packages if you want a cleaner look (otherwise, you might see the white edges between the devices, purely cosmetic)
 * Then do the rs232
 * Do another smoke test
 * Last, do the crystal
 * Do a final smoke test

 Basically, start with the shortest components and passive and work your way progressively taller and active. Otherwise, you'll wind up needing a third hand to help you hold components in place while you solder on the backside and you'll minimize the damage by doing passive components first.

7. Plug in the IC's

Watch the direction of the sockets when installing the chips (6502 and 6532 are different from the other horizontal chips).

8. Leave JP-1 open and close JP-2 (keyboard operation, onboard memory)
 
9. Power up and see if it works. If you get the lit LED and nothing is smoking, you should also see the 7-segment LEDs light up. Press RS and you are ready to go.

Thanks to Magnus Olsson and Jim McClanahan for their suggestions.

*post added 2022-12-02 10:54:00 -0600*
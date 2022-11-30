---
layout:	post
title:	raspberry-pi-b-plus-i2c-and-ds3231-rtc
date:	2015-02-23 00:00:00 -0600
categories:	general
---

# Raspberry Pi B+, i2c, and DS3231 RTC
Here are some notes on how to get your pi talking to a cheapo DS3231 Realtime clock using nothing more than a pi, an ethernet cable (for downloads), a serial cable, and an RTC.

xref: [http://www.switchdoc.com/ds3231-real-time-clock-module/](http://www.switchdoc.com/ds3231-real-time-clock-module/)

Here are links to the required materials:

The Pi (this is a B+, but the newer Pi 2 is way more powerful):
[https://www.adafruit.com/products/1914](https://www.adafruit.com/products/1914)

The RTC:
[http://www.amazon.com/gp/product/B00HR8LDGS](http://www.amazon.com/gp/product/B00HR8LDGS)

The Serial Cable:
[http://www.amazon.com/gp/product/B00PQMUBQK](http://www.amazon.com/gp/product/B00PQMUBQK)

Ethernet Cable:
[http://www.amazon.com/Mediabridge-Cat5e-Ethernet-Patch-Cable/dp/B003O973OA](http://www.amazon.com/Mediabridge-Cat5e-Ethernet-Patch-Cable/dp/B003O973OA)

Some female-female jumpers:
[http://www.amazon.com/Kalevel®-120pcs-Multicolored-Female-Breadboard/dp/B00M5WLZDW](http://www.amazon.com/Kalevel®-120pcs-Multicolored-Female-Breadboard/dp/B00M5WLZDW)

Install the drivers for your Serial Cable, if you're on a Mac or PC.

Hook up the serial cable to the GPIOs and connect the RTC to the GPIOs

The pinout for the pi is available here:
[https://learn.adafruit.com/assets/3059](https://learn.adafruit.com/assets/3059)

The color wires are not meaningful beyond convention.

For the serial cable, use the outside of the gpio pins red (5V), skip, black (GND), white (TXD), green (RXD)

For the rtc, use the inside of the pins, red (3.3V), white (SDA), green (SCL), skip, black (GND)

Plug in the ethernet cable

Plug in the USB

On a Mac (PC Users - use Putty or something) use screen to connect to the usbserial connection:
`screen /dev/tty.usbserial 115200`

if you get a complaint about the device, type `ls /dev/*usb*` to see a list of usb related devices...

boot stuff will flash by and then the pi prompt will appear, login as pi with password `raspberry`

If this is the initial boot, run
`sudo-raspi-config` and configure the locale, etc., and enable the i2c kernel modules (advanced menu)

```
sudo vi /etc/modules
i2c-bcm2708
i2c-dev
```

reboot and lsmod should show the loaded modules

```
sudo apt-get update 
sudo apt-get dist-upgrade
sudo apt-get install python-smbus i2c-tools
sudo adduser pi i2c
```

reboot
`sudo i2cdetect -y 1`

should show the ports 57 and 68

`git clone https://github.com/switchdoclabs/RTC_SDL_DS3231.git`

set a fake date for the pi

```
sudo date -s "2 OCT 2006 18:00:00"
cd RTC_SDL_DS3231/
python test.py
```

```
Here's a python test snippet (Not mine - original src here, with my minor edits):
#!/usr/bin/env python
#
# Test SDL_DS3231
# John C. Shovic, SwitchDoc Labs
# 08/03/2014
#
#

# imports

import sys
import time
import datetime

import SDL_DS3231

# Main Program

print ""
print "Test SDL_DS3231 Version 1.0 - SwitchDoc Labs"
print ""
print ""
print "Program Started at:"+ time.strftime("%Y-%m-%d %H:%M:%S")

filename = time.strftime("%Y-%m-%d%H:%M:%SRTCTest") + ".txt"
starttime = datetime.datetime.utcnow()

ds3231 = SDL_DS3231.SDL_DS3231(1, 0x68)

# uncomment the line below to initially set the time
# ds3231.write_now()

# Main Loop - sleeps 10 seconds, then reads and prints values of the pi and rtc clocks

while True:

currenttime = datetime.datetime.utcnow()

deltatime = currenttime - starttime

print ""
print "Raspberry Pi=\t" + time.strftime("%Y-%m-%d %H:%M:%S")

print "DS3231=\t\t%s" % ds3231.read_datetime()

time.sleep(10.0)
```

*wds added 2022-11-30 12:16:00 -600*
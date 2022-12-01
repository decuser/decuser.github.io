---
layout:	post
title:	how-to-set-up-tor-on-freebsd-11.2
date:	2018-07-27 10:38:00 -0600
categories:	unix freebsd
---

# How to set up tor on FreeBSD 11.2

created 20180727.1036

Note: Tricky business, this tor on freebsd, but when it's all said and done, it really works fine.

## get the package

`sudo pkg install tor`


## allow system to assign random IP_ID's to outgoing packets

```
sudo vi /etc/sysctl.conf
net.inet.ip.random_id=1

sudo sysctl net.inet.ip.random_id=1
```

## edit the torrc config file

`sudo vi /usr/local/etc/tor/torrc`

uncomment lines 18, 38, and 42:

```
SOCKSPort 9050
Log notice file /var/log/tor/notices.log
Log notice syslog
```

## start tor

`sudo -u _tor tor`

in another console:

`sudo tail -f /var/log/tor/notices.log`

open firefox, enable tor using tor switch or manually configure the proxy and browse to:

`https://check.torproject.org`


## Add the tor service to rc.conf

```
sudo vi /etc/rc.conf
tor_enable="YES"

reboot
```

## Notes

### Firefox Quantum 61.0.1 Configuration

* add the default new private browsing window button to the toolbar
* Useful addons:
 * noscript (on/off switch for javascript)
 * tor switch (on/off switch for tor)
 * cookie (on/off switch for cookies)
* Manual Configuration of Proxy Settings (about->preferences scroll down to proxy settings, skip if using tor switch):
 * Manual proxy configuration
     * clear HTTP Proxy and Port
     * clear SSL Proxy and Port
     * clear FTP Proxy and Port
     * set SOCKS Host 127.0.0.1 and Port 9050
     * set SOCKS v5
     * No Proxy for localhost, 120.0.0.1
     * Select Proxy DNS when using Socks v5 or not, for faster resolution, don't.

## To completely remove tor

```
sudo -s
pkg remove tor
pkg autoremove
pw userdel _tor
rm -fr /var/log/tor
rm -fr /usr/local/etc/tor

vi /etc/rc.conf
remove:
tor_enable="YES"

reboot 
```

*post added 2022-12-01 15:20:00 -0600*
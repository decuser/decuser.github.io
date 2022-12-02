---
layout:	post
title:	How to Monitor Battery Life and Sleep on FreeBSD 12.1
date:	2020-07-21 16:53:00 -0600
categories:	unix freebsd
---
A non-ui method for monitoring battery life and sleep on FreeBSD. This is useful for when you just want to run the command line or a lightweight window manager like TWM, FVWM, etc. Installs as a service and will sleep the machine as the battery approaches it's lowpoint of charge.

<!--more-->

## Sources

* Original answer to my post: [https://forums.FreeBSD.org/threads/sleeping-laptop-without-a-gui.76271/post-470222](https://forums.FreeBSD.org/threads/sleeping-laptop-without-a-gui.76271/post-470222
)
* This work, posted as a *useful script*:
[https://forums.freebsd.org/threads/useful-scripts.737/page-14#post-470419](https://forums.freebsd.org/threads/useful-scripts.737/page-14#post-470419)

## Check battery status:

```
apm
APM version: 1.2
APM Management: Disabled
AC Line status: off-line
Battery Status: low
Remaining battery life: 7%
Remaining battery time:  0:33:00
Number of batteries: 1
Battery 0:
    Battery Status: low
    Remaining battery life: 7%
    Remaining battery time:  0:33:00
```

## Create and install a daemon to monitor battery

After several failed attempts, I have figured out how to get my laptop to sleep when it's low on reserves, even without a DE.

The approach is as follows:

1. create a script to monitor battery levels and put the laptop to sleep
2. create an rc script to control the monitor script
3. install the scripts
4. register and start the service

### Create the monitor script

```
vi sbin-sleepd
#!/bin/sh

# who to warn
email=root
# battery level critical %
critlevel=10
# seconds to recheck and eventually act when battery is low
sleeps=120
# seconds to pause between script runs
loop=300

while true

do

# battery %
battery1=$( /sbin/sysctl -n hw.acpi.battery.life )
# AC plugged in?
acpower1=$( /sbin/sysctl -n hw.acpi.acline )

if [ ${battery1} -le ${critlevel} ] && [ ${acpower1} = "0" ]
 then
  /bin/sleep ${sleeps}

  battery2=$( /sbin/sysctl -n hw.acpi.battery.life  )
  acpower2=$( /sbin/sysctl -n hw.acpi.acline )

   if [ ${battery2} -lt ${battery1} ] && [ ${acpower2} = "0" ]
    then
     echo "Insert power plug or kill PID $$ to prevent automatic shutdown." | /usr/bin/mail -s "Battery ${battery2} % - Will shutdown in ${sleeps} seconds" ${email}
     /bin/sleep ${sleeps}

      acpower3=$( /sbin/sysctl -n hw.acpi.acline )

      if [ ${acpower3} = "0" ]
       then /usr/sbin/zzz
      fi
   fi
fi

/bin/sleep ${loop}
done
```

### Create the rc script

```
vi rc-sleepd
#!/bin/sh
#
# PROVIDE: sleepd
# REQUIRE:
# KEYWORD:

. /etc/rc.subr

name="sleepd"
rcvar="sleepd_enable"

sleepd_command="/usr/sbin/sleepd"
pidfile="/var/run/${name}.pid"
command="/usr/sbin/daemon"
command_args="-P ${pidfile} -r -f ${sleepd_command}"

load_rc_config $name
: ${sleepd_enable:=no}

run_rc_command "$1"
```

### Install the scripts

```
sudo install -b -g wheel -m 0555 -o root -v rc-sleepd /etc/rc.d/sleepd
sudo install -b -g wheel -m 0555 -o root -v sbin-sleepd /usr/sbin/sleepd
```


### Register and start the service

```
sysrc -f /etc/rc.conf sleepd_enable="YES"
service sleepd start
```

*post added 2022-12-01 15:26:00 -0600*
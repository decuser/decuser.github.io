---
layout:	post
title:	An Open Letter to Apple and the Time Machine Bug
date:	2020-10-26 07:35:00 -0600
categories:	unix macos
---
Dear Apple,

This morning, I had a row in your Apple Technical Support forums that I thought I should preserve.

<!--more-->

By way of background, I've been an Apple User since Mac OS X Panther... about 17 years. I used to have a TimeCapsule and it worked flawlessly for a decade. A few years ago, I switched to hosting my TimeMachine backups on my Mac Pro through an AFP share. Lately, as in the last two years or so, I have been experiencing the well known and publicized error message "Time Machine completed a verification of your backups. To improve reliability, Time Machine must create a new backup for you." In a nutshell, this error means you have two choices:

1. Ignore it and you have access to prior backups but you must forgo future backups

2. Create a new backup, which is an hours long prospect and does not preserve prior backups

This years-old issue is well documented in the forums, but is neither acknowledged as an issue by Apple, nor is it fixed.

I thought it would be a good idea to raise the issue and ask that it be addressed. Here's what I wrote:

Here it is 2020 and Apple has yet to acknowledge and fix their time machine backups. Every couple of months I get the message:

Time Machine completed a verification of your backups. To improve reliability, Time Machine must create a new backup for you.

What a crock. Some folks in the historic threads seem to be ok with this complete nonsense and suggest you have backups of the backups of your backups.

Maybe this is the best one can do with APFS or Mac OS Journaled filesystems. Apple won't say whether the problem is bit-rot, rot-on-write, meta-rot, or what, but in 2020 randomly-corrupting backups are completely unacceptable. My Macbook has a 1TB drive, it takes hours for it to backup the first time, but then it's ok. The idea that after a month or two of taking snapshots, it's 'too bad, so sad, but we're gonna have to start over', is nuts! *** Apple? Is there no one on the dev team willing (or able) to kick this up a notch and get it fixed (for Sierra onward)?

Honestly, I don't think the backups are being corrupted on disk, I think the TimeMachine process itself is messing with it's own metadata. I've hosted an AFP share on ZFS and hit the same issue and I know the filesystem is both sane and valid.

Just a thought for you marketing folks that read these threads - ask a serious developer what's up.

This is a well-publicized issue that Apple continues to ignore. Maybe enough people haven't spoken up to get them to take action, I thought I'd do my part and raise it again. Hilarious that Time Machine isn't even listed in the non-alphabetic list of Topics :).

 To my utter shock and amazement, Apple censored the post (ala Twitter, Facebook, and dare I say it, Google):

Hi decuser,

Thanks for participating in the Apple Support Communities.

We’ve removed your post Time machine corruption in 2020 because it contained either feedback or a feature request that was not constructive.

To read our terms and conditions for using the Communities site, see this page:  Apple Support Communities  - Terms of Use

We hope you’ll keep using our Support Communities. You can find more information about participating here:  Apple Support Communities - How To Articles

If you have comments about any of our products, we welcome your feedback:  Apple - Feedback

Rather than allowing an open debate on the issue, y'all simply removed the post, which is admittedly an effective way of stifling discussion on an uncomfortable topic, but is rather draconian. Yes, I used WTF, which the submission software changed from what the fridge to ***, but really? I can only imagine that some young tender soul read the rough and ready post and thought they needed to shield their followers from the aggressive nature of the post. I sincerely hope I'm over dramatizing their reaction, but it does seem that this was a bit of overreaction. 

Clearly, you do not 'welcome' my feedback. I am sad to see a tech giant having to fall back on silencing the messenger, rather than simply addressing the substance of the complaint. Fix your horribly broken software, it is obnoxious to have to resort to a full backup every time a prior backup has a consistency error!

Regards,

Will


*post added 2022-12-02 09:45:00 -0600*
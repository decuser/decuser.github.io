## Welcome to Decuser's Random Notes

added note on how to extract the bootstrap from Ken Wellsch's V6 distribution for use in other contexts: https://github.com/decuser/decuser.github.io/blob/master/bootable-tape-v6.txt

added boolean algebra note: https://github.com/decuser/decuser.github.io/blob/master/boolean-algebra-notes.txt

added algebra of sets note: https://github.com/decuser/decuser.github.io/blob/master/algebra-of-sets.txt

added k&r area: https://github.com/decuser/decuser.github.io/blob/master/kandr/knr.md

added linux kernel development note https://decuser.github.io/love-kernel/centos-6.9-with-2.6.34-kernel.txt 

added another linux kernel development note https://decuser.github.io/bovet-cesati-kernel/centos-4.8-with-2.6.11-kernel.txt 

added another linux kernel development note https://decuser.github.io/kroah-hartman-kernel/centos-5.11-with-2.6.18-kernel.txt 

added a corrected linux kernel development note https://decuser.github.io/kroah-hartman-kernel/centos-5.11-with-2.6.17.8-kernel.txt

fix utf issue in mint - sheesh, dunno why this persists, but I think it's just the fact that they use a lowercase utf

```sudo update-locale LANG=en_US.UTF-8```

Put the following in /etc/default/grub:

GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true

Then run:

```sudo update-grub```

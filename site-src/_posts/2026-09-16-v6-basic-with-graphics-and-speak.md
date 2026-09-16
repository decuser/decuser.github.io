---
title: "V6 Speaks! in OpenSIMH: Reconstructing the Votrax Speech Synthesizer Endpoint."
tags: [unix v6 research-unix basic pdp-11 opensimh votrax]
---

## Research UNIX V6 speaks again.

After getting the old VT01 graphics path working under OpenSIMH, I went back to another piece of Bell Labs hardware support still present in the sources: the Votrax speech interface.

The path now works end to end:

Research UNIX V6 `speak`
* historical pronunciation rules
* `/dev/vs`
* original V6 Votrax driver behavior
* reconstructed Votrax/SC-01A synthesis
* modern audio output

The UNIX side remains historical: `speak` emits its native Votrax byte stream, including the original phoneme numbering and inflection bits, while the simulator handles the hardware realization.

This is what speaks:

```
echo 'all your base are belong to us. Research Unix V6 is speaking aloud
in 2026' | /bin/speak
```

Listen:

<audio controls>
  <source src="https://decuser.github.io/assets/audio/votrax-v6.wav" type="audio/wav">
  Your browser does not support the audio element.
</audio>

Code, historical sources, reconstruction notes, and tested procedures:

[https://github.com/decuser/v6vtvs](https://github.com/decuser/v6vtvs)

It is gloriously mechanical, a little difficult to understand, and very recognizably Votrax.

*post added 2026-09-16 14:51:00 -0500*

---
title: "m65c02: Making the Invisible Visible"
tags: 6502 kim-1 emulators retro-computing programming
---

<div style="display:flex;flex-wrap:wrap;align-items:center;gap:0.75rem;margin:1rem 0">
  <a href="/assets/img/m65c02/kim1-front-panel.png" target="_blank" rel="noopener noreferrer" title="KIM-1 front panel"><img src="/assets/img/m65c02/kim1-front-panel.png" alt="KIM-1 front panel thumbnail" style="height:140px;width:auto;max-width:100%"></a>
  <a href="/assets/img/m65c02/kim1-logic-analyzer.png" target="_blank" rel="noopener noreferrer" title="KIM-1 logic analyzer"><img src="/assets/img/m65c02/kim1-logic-analyzer.png" alt="KIM-1 logic analyzer thumbnail" style="height:140px;width:auto;max-width:100%"></a>
  <a href="/assets/img/m65c02/mos-basic-terminal.png" target="_blank" rel="noopener noreferrer" title="MOS BASIC terminal"><img src="/assets/img/m65c02/mos-basic-terminal.png" alt="MOS BASIC terminal thumbnail" style="height:140px;width:auto;max-width:100%"></a>
</div>

I've been spending a lot of time with the 6502 lately, first with the Apple IIe and KIM-1, and now with an emulator of my own. The project is called [m65c02](https://github.com/decuser/m65c02). It started with a simple question: what if I could see what the processor was doing, one cycle at a time?

Running an old machine is fun. Understanding how it runs is even better. An instruction like `LDA` is simple enough to describe in a sentence, but that description hides the activity on the address and data buses. I wanted to get closer to the hardware, without having to attach probes to an actual board every time I had a question.

One inspiration is Software Masters' *The Visible Computer: 6502*. Back in the early 1980s, it made the processor's operation something you could watch and learn from, stepping through instructions and their microsteps. I like that idea. With m65c02, I'm taking it further into the bus cycles and the surrounding hardware. The aim is the same: make the computer less mysterious by making its workings visible. The [original Visible Computer manual](https://mirrors.apple2.org.za/ftp.apple.asimov.net/documentation/programming/6502assembly/The%20Visible%20Computer-6502%20Manual.pdf) is worth a look.

<!--more-->

## From CPU to computer

The 65C02 is the core of the project, but a CPU by itself isn't much of a computer. The KIM-1 has been a particularly interesting target because the machine is small enough to understand as a whole. It has a keypad, a six-digit display, ROM, RAM, and two 6530 RRIOT devices. You can get surprisingly close to the metal.

Here's the KIM-1 front panel running in a browser. The keypad and display are useful in their own right, but what interests me is what happens underneath when you press a key or execute an instruction.

![KIM-1 front panel with six-digit LED display and keypad](/assets/img/m65c02/kim1-front-panel.png)

## Watching the wires

The logic analyzer is where the project gets especially interesting. It displays the CPU's address and data buses along with control signals such as read/write and SYNC. It can also show the state of the KIM-1's RRIOT interfaces on the same cycle timeline.

The amber separators mark opcode fetches. You can pause, step, inspect retained cycles, and export traces for closer examination. The point isn't simply to prove that an instruction produced the right result. It's to see *how* it got there.

![Cycle-level logic analyzer showing CPU buses and control signals](/assets/img/m65c02/kim1-logic-analyzer.png)

This brings back something I liked about early microcomputers: there wasn't much distance between an experiment and what the machine actually did. You could watch an address line, examine memory, or single-step a program and reason about the result.

## And, of course, BASIC

One of the more satisfying milestones was getting MOS Technology's 6502 BASIC running through the KIM-1 terminal interface. This is BASIC V1.2, with its familiar 1977 Microsoft copyright notice. Here it is accepting a little `FOR` loop.

![MOS Technology 6502 BASIC V1.2 running in the KIM-1 terminal](/assets/img/m65c02/mos-basic-terminal.png)

It's a small demonstration, but it exercises much more than a single instruction. There is a processor executing code, memory to hold the program, and enough I/O to interact with it. Watching BASIC run while tracing the underlying cycles is a different sort of experience from simply typing `RUN` and waiting for the answer.

## Where this is going

I'm building m65c02 as an instrument for exploration. The goal is to make machine behavior visible and understandable, including the details that normal emulators quite reasonably hide. There's still work to do, and I'm not calling it finished. But the combination of a cycle-oriented CPU, an interactive KIM-1, and a logic analyzer has already made it a useful laboratory.

The source is on GitHub: [decuser/m65c02](https://github.com/decuser/m65c02).

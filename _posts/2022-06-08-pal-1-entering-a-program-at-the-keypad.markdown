---
layout:	post
title:	PAL-1 Entering a Program at the Keypad
date:	2022-06-08 06:45:00 -0600
categories:	retro-computing pal-1
---
Note describing a minimalist example of how to input and run a program on the PAL-1.

<!--more-->

## Planning
To program the PAL-1, there is some planning required.

First, we have to decide where our program will reside in memory. According to Appendix A of the PAL-1 manual, there are 5k memory addresses available, but looking at the KIM-1 user manual, pg 38, we see that the first 512 ($0200 hex) bytes are used for page 0: $0000-$00EE, reserved: $00EF-$00FF, and the stack: $00FF-$01FF, and anything above $03FF is expansion (labeled optional for PAL-1). So, for our example, we will stay out of the optional RAM area and for simplicity, begin our program at the first user friendly location of $200. So long as we don't go past $03FF, we will be KIM-1 compatible. This gives us 512 bytes to play with.

Start your program at $200.

Next, we need to decide what our program will do. In this case, we will do a pretty minimal thing, we will change the contents of the A register to the value $FF and break. A more minimal program is possible, but this program has an effect that we will be able to detect.

By looking at the 6502 Programming Manual, we learn that LDA is the instruction that moves a value into the A register, and that there is an immediate mode that will let us specify the value directly. We also learn that BRK is the instruction to interrupt a program.

In assembly language mnemonics:

```
LDA $FF
BRK
```

Assembly language is great as a high level language :), but we can't type in assembly language on our PAL-1, we need something more low level. In this case machine code is called for... So, back in the programming manual, we see that LDA has 8 different machine code representations, one for each addressing mode, the addressing mode we are interested in here, is immediate mode and sure enough, there is only one code for that mode, $A9, and that it is a 2 byte instruction, where the first byte is the code, and the second is the data to be loaded, in our case $FF. Similarly, looking up BRK, finds only one code, $00 for the implied mode, and that it is a 1 byte instruction.

In machine code:
`A9 FF 00`

That's our program. It requires 3 bytes of machine code and we have it!

Next, we need to decide on what should happen when an interrupt (like our BRK) occurs. To keep things simple, we will leverage an existing functionality that the PAL-1 (or KIM-1) ROMs provide, which is the keyboard monitor, itself. We will load the interrupt vector with the location of the start of the keyboard monitor. This will cause the program interrupt to run the monitor (wait for commands from the user) - super handy!

The interrupt vector, IRQ, is located at $17FE-$17FF, the location of the start of the monitor is $1C00. We store the location LO-BYTE then HI-BYTE, this is known as little-endian order. So, in memory, this will look like:

```
17FE 00
17FF 1C
```

That's it for preliminaries and planning. In the discussion below, keep in mind that the labels of the keys are below the keys themselves.

## Keying it in

1. Open JP-1 (Keypad Entry)
2. Close JP-2 (Onboard memory)
3. Attach Power to PAL-1 (LEDs should light up with memory location and contents)
4. Press RS to initialize the PAL-1 (pushbutton at the top right)
5. Enter your program

 * Press AD to enter address mode
Enter the starting address of the program, in hex, using the keypad

     `0200`

 * Press DA to enter data mode
Enter each byte (pair of hex digits) followed by + to move to the next byte

     ```
     A9 +
     FF +
     00 +
     ```

6. Confirm that the bytes are entered correctly
 * Press AD to reenter address mode and enter the start address of the program

     `0200`
     
     Observe that the data byte displayed is `A9`

 * Press `+` twice and note that the data bytes displayed are `FF` and `00` respectively

 This means that memory now looks like:

 ```
 0200 A9
 0201 FF
 0202 00
 ...
 ```

 and our program is in RAM, ready to run.

7. Set up the interrupt vector to start the monitor

 We do this so that our program will run, and will return to the monitor

 * Press AD to enter address mode and enter the Interrupt vector, `17FE` (this is IRQL, low byte of IRQ)
 * Enter the low byte of the start of the monitor and press `+`

     `00 +`

     The address displayed is now `17FF` (this is IRQH, high byte of IRQ)
 * Enter the high byte of the start of the monitor and press `+`

     `1C +`

8. Confirm that the IRQ is properly configured (left as an exercise for the reader, see 6, above)

9. Initialize the contents of the A register before we run our program

 The KIM-1 User manual tells us that the A register is mapped to memory location $00F3.

 * Press AD and enter 00F3
 * Press DA and enter 00 +

10. Run our program

To run a program entails entering the address where we want to start and pressing GO.

* Press AD and enter 0200
* Press GO

If all went well, the LEDs should display:

`0204 XX`

The program ran, was interrupted and has restarted the monitor - it is displaying the location of the Program Counter and the contents of that location. XX will be whatever was previously stored at `$0204`.

11. Celebrate!

## Troubleshooting
If the LEDs go blank when you press GO and do not relight, this means your PAL-1 is busy doing something other than driving the LEDs. The most likely cause is that you forgot to set the IRQ to the monitor start.

To regain control of the PAL-1, press `RS`.

Then confirm memory looks like you would expect:

* Press AD and enter 0200
* Press + a few times

* Press AD and enter 17FE
* Press + a couple of times

* Press AD and enter 00F3

If all of that looks right, then be sure that you actually started your program at `0200`:

* Press AD 0200
* Press G

If it's still not working, get on the PAL-1 google group and ask for help - the folks there are friendly and helpful.

*post added 2022-12-02 16:11:00 -0600*
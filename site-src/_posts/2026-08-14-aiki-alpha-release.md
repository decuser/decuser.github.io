---

title:	Aiki: First Public Alpha
tags: aiki programming-languages ai education
---

I've put the first public alpha of Aiki on GitHub.

[Aiki](https://github.com/decuser/aiki) is a small experimental programming language I've been working on for the past several months. I describe it as both a programming language and a *learning field*: an environment designed to make computational relationships visible enough to inspect, experiment with, and reason about.

The current release is `v0.4.0-alpha`. It includes the interpreter, standard library, documentation, examples, tests, validation machinery, and the project's engineering record. Intel/amd64 release archives are available for Linux, Windows, and macOS.

<!--more-->

Aiki has become considerably more serious than the small language experiment I started with, but it is still small enough to get your hands around.

Building and starting it on Linux is deliberately uneventful:

![Aiki build, REPL, exact arithmetic, and left-to-right evaluation](/assets/img/aiki/Fig1.png)

There are a couple of things hiding in that little transcript.

Aiki uses exact rational arithmetic. `1/3` is `1/3`, and decimal notation does not quietly introduce binary floating-point approximation: `0.1 + 1/10 + 0.1` is exactly `3/10`.

Ordinary binary expressions are evaluated from left to right unless parentheses explicitly group them. Thus:

```text
2 + 3 * 4
```

is `20`, while:

```text
2 * 3 + 4
```

is `10`.

That is intentional. Evaluation order is part of the visible language rather than something the programmer has to reconstruct from a precedence table.

## A Small Surface

One of the things I want from Aiki is inspectability. The language should not require a great deal of machinery before you can begin to understand what is there.

Typing `help()` at the REPL gives a pretty good view of the current surface:

![Aiki help showing syntax, prelude, and modules](/assets/img/aiki/Fig2.png)

The syntax, prelude, and available modules fit comfortably on one screen. More detailed help is available directly from the REPL with forms such as:

```aiki
help("spawn")
help("math")
help("math.sqrt")
```

The same idea runs through the rest of the system: make the important relationships visible, inspectable, and executable where possible.

## A Little Turtle

Aiki is also supposed to be approachable.

The `turtle/simple` module deliberately removes most of the machinery needed to get something moving on the screen:

```aiki
use("turtle/simple")

new(400)
background(:white)
pencolor(:black)
pen_size(3)

forward(50)
right(90)
forward(50)
right(90)
forward(50)
right(90)
forward(50)
```

![Aiki turtle/simple drawing](/assets/img/aiki/Fig3.png)

That side of the language matters to me. I am working on a few little books about Aiki, including material aimed particularly at non-programmers, younger learners, and readers who might like to explore programming without first absorbing a large body of machinery.

The idea is that you ought to be able to begin by making a turtle move around a screen and, if curiosity carries you far enough, eventually find yourself thinking about evaluation, recursion, concurrency, representation, and the machinery underneath.

## What Aiki Has Become

The alpha includes exact rational arithmetic, left-to-right evaluation, shaped data, modules, graphics and turtle facilities, recoverable errors, isolated spawn concurrency, executable documentation, semantic profiling, and a fairly broad standard library.

Aiki also now has an extensive invariant framework.

Grammar and evaluator behavior are coupled. Documentation examples execute. Library exports are checked against help and documentation. Behavioral tests are checked against gold files. The distribution tree itself is structurally checked. These are not simply piles of tests; each one expresses a relationship that the project intends to keep true.

This matters particularly because of another unusual aspect of Aiki.

Generative AI has been used extensively as an implementation instrument. I conceived, architected, designed, specified, and directed the language; AI systems produced substantial amounts of source code, tests, tooling, and related engineering material under that direction.

I have made that relationship explicit in the repository rather than hiding it or reducing it to a vague statement that "AI was used."

Design authority and generated implementation are deliberately separated. The implementation is judged against the observable language, specifications, executable documentation, behavioral tests, gold files, structural invariants, and other externally imposed criteria. The generated implementation is replaceable. The language is not whatever the implementation happens to do.

The README contains the fuller statement on AI and authorship, along with a description of the invariant framework and working method.

## Two Aiki Documents

I've also made two longer documents available.

*This Is Aiki* is the more conversational introduction to the language and its ideas.

<iframe allow="autoplay" height="480" src="https://drive.google.com/file/d/1aMRSnBhokCJhtZI3ABlm1cK9u9kTv0mm/preview" width="640"></iframe>

*Report on the Programming Language Aiki* is the more formal language report.

<iframe allow="autoplay" height="480" src="https://drive.google.com/file/d/1fQbTSoCGZiALZOBZUnn4sdjV8jWyrUTq/preview" width="640"></iframe>

Both are alpha documents too. They will continue to evolve with the language.

## The Alpha

Aiki is cross-platform and is developed primarily on Linux. The first alpha provides Intel/amd64 builds for Linux, Windows, and macOS. Linux remains the primary development and validation environment; Windows and macOS have received lighter smoke testing.

This is still an alpha. Syntax, library interfaces, tooling, and other details may change as I continue to simplify, harden, and exercise the language.

But Aiki has reached the point where I think it is worth putting in front of other people.

If you try it, I am interested in failures, questions, experiments, documentation problems, criticism, and especially places where the language behaves differently from the way its surface led you to expect.

### Links

* [Aiki on GitHub](https://github.com/decuser/aiki)
* [Aiki releases](https://github.com/decuser/aiki/releases)
* [Aiki v0.4.0-alpha](https://github.com/decuser/aiki/releases/tag/v0.4.0-alpha)
* [This Is Aiki — PDF](/assets/pdf/aiki/this-is-aiki-a1.pdf)
* [Report on the Programming Language Aiki — PDF](/assets/pdf/aiki/report-aiki-a1.pdf)
* [This Is Aiki — Google Drive](https://drive.google.com/file/d/1aMRSnBhokCJhtZI3ABlm1cK9u9kTv0mm/view?usp=sharing)
* [Report on the Programming Language Aiki — Google Drive](https://drive.google.com/file/d/1fQbTSoCGZiALZOBZUnn4sdjV8jWyrUTq/view?usp=sharing)

*post added 2026-08-14 19:38:00 -0500*

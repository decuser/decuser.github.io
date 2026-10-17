---
title: "Nezha: Aiki's Smaller, Tougher Sibling."
tags: [nezha aiki programming-languages interpreters language-design blockly wails]
---

## Nezha: smaller, tougher, and less patient with baggage.

Nezha is Aiki's smaller, tougher sibling. The name comes from the youthful warrior of Chinese mythology: formidable despite his size, independent-minded, and not especially interested in accepting the way things have always been done.

Aiki gave Nezha its starting point. Nezha is an effort to pare the language down and tackle a harder question: can the essential acts of program evaluation be described by a small, finite declarative vocabulary, rather than buried inside a handwritten evaluator?

<!--more-->

The current implementation is a working language with `.nez` source files, a parser, formatter, evaluator, and an executable reference corpus. The larger experiment is still in progress.

The intended separation is:

```text
syntax
  +
evaluation specification
  |
  v
common evaluation contract
  |
  +-- interpreter
  +-- virtual machine
  +-- native implementation
```

That is a research direction, not a claim that three backends already exist. Right now the evaluator is handwritten; the task is to determine which operations are truly fundamental and whether their behavior can be stated independently of that implementation.

Oh, and there is a block-based user interface thrown in as an experiment. It uses Blockly inside a Wails desktop wrapper to assemble programs visually and generate Nezha source. It is not the central architectural project, but it is fun to play with.

![Nezha experimental Blockly interface](/assets/img/nezha/nezha-blockly-ui.png)

The language can be built and exercised from the command line:

```sh
make build
make reference
make validate-lang
```

Source, design notes, and the development baseline:

[https://github.com/decuser/nezha](https://github.com/decuser/nezha)

The ambition isn't to make Aiki larger by another name. It is to find out just how small—and how precise—the mechanism underneath a programming language can be.

*post added 2026-10-17 16:16:00 -0500*

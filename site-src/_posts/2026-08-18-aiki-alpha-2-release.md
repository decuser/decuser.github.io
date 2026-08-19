---
title: Aiki Alpha 2 Released
tags: aiki programming-languages systems
---

Aiki Alpha 2 is out.

Tagged [`v0.4.0-alpha-35`](https://github.com/decuser/aiki/tree/v0.4.0-alpha-35) and available from the [GitHub release](https://github.com/decuser/aiki/releases/tag/v0.4.0-alpha-35).

Alpha 1 made the language real. Alpha 2 made the architecture explicit.

<!--more-->

The grammar is now the single authority for the syntax surface. Parser, evaluator, formatter, linter, help, and structural checks all derive from it. Newline termination is an explicit language rule rather than parser private policy.

A substantial portion of Aiki is now implemented in Aiki itself: independent lexer, normalizer, parser, evaluator, module loader, and bootstrap path. These are exercised against the Go-hosted implementation through conformance checks and recursive self-interpretation.

The host boundary was redesigned. HAL, capability, and authority are distinct. Trusted code receives explicit grants. Portable facilities (`bits`, `bytes`, `hash`, `string`) have genuine native Aiki implementations and optional `/ffi` realizations. Native is the default. For portable facilities, FFI does not define a second semantic surface. Host-boundary capabilities such as `store`, `file`, `process`, and `canvas` are classified honestly rather than mislabeled as FFI.

Aiki also now has a substantial systems-development library surface: files, paths, processes, signals, terminals, networking, time, bytes, hashing, storage, environment and system facilities, all organized around that boundary.

```text
aiki check --ffi-use program.ai
````

Distribution is relocatable. Language services (LSP, formatting, completion, hover, tags, Xed, VS Code) share the same core. Validation is substantially stronger: behavioral, structural, conformance, self-host, invariant, native/FFI boundary, property, fuzz, distribution, and gold coverage all feed the release path.

The three experiments remain the stress tests:

* 001 — semantic profiling and recursive self-interpretation
* 002 — Thompson’s 1968 regex compiler on an Aiki 7094 emulator
* 003 — Four-Way Life (processes, channels, storage, explicit native/FFI choices)

The core character of the language remains recognizable: exact rationals, left-to-right evaluation, explicit grouping, recoverable errors as values, and isolated concurrency.

What has changed is that far more of the system now has an explicit authority, a declared realization, and an executable witness.

Release archives are available for Linux, macOS, and Windows.

### Links

* [Aiki on GitHub](https://github.com/decuser/aiki)
* [Alpha 2 release](https://github.com/decuser/aiki/releases/tag/v0.4.0-alpha-35)
* [Alpha Milestone 26](/posts/aiki-alpha-mileston26-update/)
* [First Public Alpha](/posts/aiki-alpha-release/)

*post added 2026-08-18 23:06:00 -0500*



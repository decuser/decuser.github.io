---

title: Aiki Alpha 3 Released
tags: aiki programming-languages systems
---

Aiki Alpha 3 is out.

Tagged [`v0.4.0-alpha-36`](https://github.com/decuser/aiki/tree/v0.4.0-alpha-36) and available from the [GitHub release](https://github.com/decuser/aiki/releases/tag/v0.4.0-alpha-36).

Alpha 1 made the language real. Alpha 2 made the architecture explicit. Alpha 3 makes the implementation substantially more exact, efficient, constrained, and observable without enlarging the core language.

<!--more-->

| Area         | Alpha 3                                                                           |
| ------------ | --------------------------------------------------------------------------------- |
| Numbers      | One exact language-level number model with adaptive internal realization          |
| Runtime      | Major reductions in allocation, call overhead, traversal, and realization cost    |
| Lists        | Adaptive persistent realization beneath immutable list semantics                  |
| Control      | Lazy `and` / `or`, proper tail calls, strict left-to-right evaluation retained    |
| Math         | Exact native authority, bounded exact FFI acceleration, explicit approximate math |
| Profiling    | Single observation network for calls, boundaries, allocations, and host cost      |
| Coverage     | Static coverable structure combined with dynamic observation hits                 |
| Libraries    | Stronger module/help/export/native/FFI invariants across the shipped library      |
| Tooling      | Unified command registry, recursive target handling, stronger validation levels   |
| Distribution | Relocatable Linux, macOS, and Windows amd64 releases                              |
| Repository   | Engineering material consolidated; experiments moved to their own repository      |

The most important changes, roughly in descending order of impact:

* **Runtime realization is much cheaper.** Calls, environments, argument frames, AST traversal, literal realization, parser bookkeeping, and immutable string observation were all tightened. The intent is semantic invariance: the language remains the same while the machinery underneath it does less work.

* **Exact numbers now have adaptive physical representations.** Aiki still presents one exact `number` type. Internally, values can use compact integers, compact rationals, exact finite-binary forms, or arbitrary-precision rationals as appropriate. Representation is an implementation choice; exactness is the language rule.

* **Persistent lists received the same treatment.** Lists remain immutable values, but their realization can adapt between flat, frontier, and persistent/forked forms without exposing those choices to programs.

* **Proper tail calls and lazy logical control are now part of the realized language surface.** `and` and `or` evaluate their right operand only when required. Other binary expressions still evaluate strictly left to right; Aiki still has no conventional operator-precedence hierarchy.

* **Profiling was rebuilt as a single observation network.** It can account for caller/callee relationships, runtime-layer and implementation-boundary crossings, allocation counts and bytes, inclusive and exclusive host cost, and selected realization categories.

* **Coverage now shares that same execution evidence.** Coverable sites come from a static model of the program and AST; dynamic hits come from the observation network rather than from a second independent runtime accounting mechanism.

* **The math surface is now separated by semantic role.** `math/native` is the exact semantic authority and bare `math` resolves there. `math/ffi` accelerates the exact `floor`, `ceil`, and `modulo` surface. `math/approx` contains explicitly approximate `sin`, `cos`, and `sqrt` rather than weakening Aiki's number model.

* **Library structure is more mechanically constrained.** Module summaries, exports, help, documentation, aliases, native/FFI policy, and declared acceleration surfaces are checked against one another instead of being allowed to drift independently.

* **Command-line and validation structure were simplified.** Top-level dispatch and help share one registry, recursive target handling is centralized, and validation now has explicit levels including `make validate-lang`, `make validate-all`, `make rigorous`, `make distcheck`, and `make historycheck`.

* **The repository is smaller and more sharply divided by purpose.** Engineering records, proposals, profiling material, Git hooks, evidence, and the AI-assisted engineering method now live under `engineering/`. Samples and editor support have explicit homes. The core repository is increasingly about the language itself.

The experiments have also moved out of the Aiki core repository into a separate project:

* [aiki-experiments](https://github.com/decuser/aiki-experiments)

That separation is intentional. The experiments use Aiki from the outside and act as independent integration and stress surfaces rather than becoming part of the language implementation.

The existing experiments include:

* 001 — semantic profiling and recursive self-interpretation
* 002 — Thompson’s 1968 regular-expression compiler and IBM 7094 reconstruction
* 003 — Four-Way Life, exercising concurrency, processes, storage, and mixed implementation surfaces
* 005 — PDP-11/40 reconstruction aimed at running UNIX V6 on a monitorable machine surface

This arrangement also makes the boundary clearer: machine-specific work stays in the experiment unless it exposes a genuine Aiki bug or a generally useful missing capability.

Alpha 3 includes updated editions of *Report on the Programming Language Aiki* and *This Is Aiki — The Aiki Alpha 3 Release*. The language report now covers the complete shipped library surface and the formal grammar; the historical Alpha 1 and Alpha 2 documents remain preserved.

Aiki remains an alpha. Syntax, libraries, tooling, and implementation details may still change. The core design remains recognizable: exact values, left-to-right evaluation, explicit grouping, recoverable shaped errors, proper tail calls, isolated concurrency, inspectable implementation boundaries, and executable invariants tying the system together.

Release archives are available for Linux, macOS, and Windows.

### Links

* [Aiki on GitHub](https://github.com/decuser/aiki)
* [Alpha 3 release](https://github.com/decuser/aiki/releases/tag/v0.4.0-alpha-36)
* [Aiki Experiments](https://github.com/decuser/aiki-experiments)
* [Alpha 2 release](https://github.com/decuser/aiki/releases/tag/v0.4.0-alpha-35)

*post added 2026-08-30 15:27:00 -0500*


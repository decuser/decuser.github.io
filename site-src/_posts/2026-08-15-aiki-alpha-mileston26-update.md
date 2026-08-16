---

title: Aiki: Alpha Milestone 26 Update
tags: aiki programming-languages ai self-hosting
---

I have been busy with Aiki lately, and the last couple of days have been especially active. I return to my day job next week. I am a Computer Information Systems professor at Tarleton State University. So, I have been using the remaining summer window to close several related pieces of work.

The current state is tagged [`v0.4.0-alpha-26`](https://github.com/decuser/aiki/tree/v0.4.0-alpha-26). I do not plan to create a GitHub Release for every such point. `master` moves as development continues; tags mark states worth stopping on.

The first public alpha already included most of the language proper: exact rational arithmetic, left-to-right evaluation, first-class functions, recursion and iteration, pipelines, shaped data, modules, recoverable errors, isolated concurrency, graphics, a standard library, semantic profiling, executable documentation, behavioral golds, grammar coverage, and a substantial invariant framework. Most of the work since then has not enlarged that surface very much. It has made the relationships underneath it considerably stricter.

<!--more-->

## Authority and the Grammar

The first substantial post-alpha work was on newline handling. `grammar.ebnfx` described the productions, but part of the actual surface rule still lived in parser code: whether a physical newline terminated a statement depended on a private completion set and delimiter-suppression logic. That policy now lives in the grammar. The parser consumes it, help exposes it, and structural analysis derives its consequences.

This exposed several useful facts about the existing language. Some tokens that initially looked like problematic continuations: `(`, `[`, and `-`, are actually resolved as beginnings of new expressions after termination. Other continuations are unambiguously blocked by the current rule. A function literal ending in `}` exposes another edge because `}` can end an expression without itself being part of the newline-completion set. I did not change those language choices merely to make the rule more symmetrical. They are now visible design questions rather than behavior hidden in parser code.

The same work tightened several grammar-sensitive relationships. Evaluator coverage is checked against the syntax the grammar can actually produce. Formatter coverage is explicit across the grammar rather than falling through silent recursion. Linter knowledge about syntax nodes is checked. Binary-operator membership comes from the grammar instead of a separate evaluator list. Newline help and related diagnostics derive from the declared policy.

A second pass then found that several consumers were independently walking the grammar to derive the same structural facts. Those derivations are now centralized in a cached grammar analysis. Production names, token references, AST-producing node types, terminal alternatives, and newline analysis are derived once and consumed where needed.

The working rule is straightforward: a fact should have one authority. Consumers may have their own policy and representation, but they should not independently reconstruct the same fact.

## Tooling and Failure Semantics

The newline work introduced deliberately unparsable smoke specimens, which exposed some weaknesses in the surrounding tools. Negative parser specimens now declare themselves explicitly:

```text
# @negative parse
````

The declaration is restricted to the test fixtures where it is meaningful. It cannot be used in ordinary source to exempt malformed code from formatting or linting.

Following that through uncovered several older problems. Recursive formatting could encounter malformed source, report it, and still fail to propagate the error correctly. Lint's formatting preflight could stop after the first malformed file. Several commands returned status codes internally that the top-level executable discarded, allowing a command to print failure and still exit successfully.

Those paths now propagate their status to the shell.

The fuller lint traversal also exposed a separate module-resolution drift. Runtime resolved public package names through the module registry, while lint maintained a filesystem approximation of that rule. Valid code using `use("list")` was enough to expose the disagreement once lint began reaching source it had previously skipped. Lint now uses the same registry model for public package resolution while retaining normal relative-path handling for path imports.

I followed the grammar project with a more general audit and began recording findings with stable identifiers and explicit dispositions. Some were fixed, some accepted, some deferred. Newline delimiter suppression, for example, now tracks expected closing delimiters rather than an aggregate depth that an unmatched closer could corrupt. The point of the ledger is not to turn every observation into work; it is to keep credible findings from disappearing when a project ends.

## Distribution and Location Independence

Aiki had also accumulated an implicit assumption that the source tree was the installation.

That worked because the development executable normally lived beside `lib/`, but it meant runtime correctness was partly dependent on where the process happened to be started. The running executable now identifies its distribution. Shipped modules are found relative to that executable, user modules have an explicit home, and named package discovery does not recursively scan arbitrary trees beneath the current working directory.

The normal installation model is therefore just:

```text
unpack Aiki
add the directory to PATH
run aiki
```

`make dist` constructs the user distribution. `make distcheck` goes further: it unpacks that distribution under a temporary prefix, runs from an unrelated directory, plants misleading package trees there, and verifies that the installed Aiki still resolves and runs its own modules correctly.

There is also a separate `make baseline` target for development snapshots. A baseline retains the repository, including `.git`, and is intended as a complete restartable development state. It is not the user distribution.

This distinction later became important again during self-hosting. Several things that worked from the repository root turned out to depend on being there.

## An Independent Aiki Front End

The largest body of post-alpha work began with a question about self-description: how much of Aiki could be implemented independently in Aiki itself?

There is now an Aiki-written lexer, newline normalizer, and recursive-descent parser under `selfhost/`. They do not call the Go lexer or parser.

Independence does require duplication of some facts. A lexer has to know the keywords and operators it recognizes. A newline normalizer has to know the completion and suppression policy. Those duplicated facts are checked against values derived from `grammar.ebnfx`; the algorithms themselves remain independent.

The lexical and newline implementations are compared with the Go implementation against reviewed conformance projections. For parsing, I reused the existing grammar-shaped parse golds rather than inventing another expected-tree format. The result is a useful three-way relationship among grammar and reviewed evidence, the Go implementation, and the Aiki implementation.

This is different from simply adding more tests around the same implementation. The second front end has its own code and its own opportunities to be wrong.

## Language Services

The editor work grew from the same concern about authority.

A parser, formatter, linter, editor extension, and LSP server can easily become several incomplete copies of the language. Rather than make the LSP server another owner of Aiki semantics, I moved reusable language knowledge into an editor-independent service layer.

That layer now provides document analysis, structured diagnostics, symbols, definition lookup, canonical formatting, completion, and hover information. `aiki lsp` is an adapter over that service rather than the service itself.

This has been exercised through three rather different editors. Xed uses its normal GtkSourceView mechanism for lexical presentation and a thin plugin for live diagnostics. VS Code uses a conventional thin language client and has been tested for diagnostics, completion, hover, Go to Definition, and Format Document. For nvi, Aiki generates ordinary tags:

```text
aiki tags -o tags source.ai
```

and nvi uses them in the usual way.

The live editor tests were useful. Xed exposed Save-As document identity and the presentation of zero-width EOF diagnostics. VS Code exposed an invalid JSON-RPC null response and an assumption that definition requests would be positioned at the first byte of an identifier. Desktop-launched editors also demonstrated that their process environment cannot be inferred from an interactive shell's `PATH`.

Those were adapter problems, not invitations to move Aiki semantics into the adapters.

## From Parser to Interpreter

The independent front end then grew into an interpreter.

Aiki now has an Aiki-written runtime environment and evaluator supporting lexical lookup, shadowing, assignment into enclosing scopes, closures, recursion, rest parameters, lists, shapes, indexing, field access, statements, control flow, pattern matching, pipelines, and returns.

This work exposed two gaps in the language surface.

The parser could read arbitrary symbol literals, but ordinary Aiki had no operation for constructing an arbitrary native symbol from a string. A self-hosted interpreter therefore could not faithfully turn a source lexeme into the corresponding value without either maintaining a finite private symbol table or introducing its own substitute representation. Neither was acceptable.

The result was:

```aiki
to_symbol("foo")
```

which produces `:foo`.

Shaped values exposed a related boundary. The substrate already knew how to construct them, but ordinary Aiki did not. That became:

```aiki
shaped(:point, [1, 2])
```

These are small additions to the language, but they came from a useful criterion: an implementation of Aiki written in Aiki should not need a private representation for values that ordinary Aiki source can express.

## Modules and the HAL Boundary

Modules required a similar decision.

It would have been easy for the self-hosted evaluator to delegate `import()` back to the host interpreter, but that would also delegate source-module semantics to the implementation being checked. The self-hosted path therefore performs Aiki-source module loading itself:

```text
resolve
read
lex
normalize
parse
evaluate
collect exports
cache
```

Platform facilities remain host capabilities. A privileged bootstrap captures the HAL functions needed by blessed library modules and installs them into the interpreted library environment without exposing those raw bindings to ordinary callers.

The distinction is intentional. Aiki source semantics can be implemented in Aiki. File access, clocks, graphics, native regex, and other platform effects still have to come from the substrate.

## Behavioral Conformance

Running existing behavior specimens through the independent evaluator found a semantic mistake that the more focused evaluator tests had missed.

Aiki recoverable errors such as:

```text
[@error, :math, "division by zero"]
```

are ordinary values. They can be bound, returned, inspected, and matched.

The self-hosted evaluator initially used `is_error()` to recognize its own internal failures, thereby conflating a recoverable Aiki value with an evaluator halt. The interpreter now uses a separate private fault representation for its own control path, leaving `[@error, ...]` values recoverable.

The behavior-conformance work now covers representative arithmetic, closures and recursion, matching, pipelines, relative imports, strings, file effects, pure and HAL-backed modules, bytes, hashes, regex behavior, and other existing language specimens. Concurrency, graphics, debugger-only cases, and interactive I/O remain outside the present self-host proof rather than being silently counted as covered.

## Recursive Self-Interpretation

The eventual target was to run an Aiki-written interpreter through itself.

The first attempts appeared to spend most of their time parsing the inner parser, which suggested that recursive-descent parsing under a tree-walking interpreter was the main problem. Semantic profiling showed otherwise. A large part of the cost was in the independent lexer's character handling: repeated string indexing caused repeated rune materialization over large source strings.

`string.chars` now has a linear substrate realization, and the self-host lexer snapshots the source once and avoids some repeated table scans and position work. That reduced the measured workload enough to expose the next problems.

Those were module problems rather than parser problems. Path fallback in the independent loader did not quite match the host loader. Different paths involving `.` and `..` could name the same physical module but become separate cache entries. Running recursively from outside the repository then exposed a further assumption: the self-hosted loader needed access to the same ordered distribution module roots as the host loader.

Those were corrected without handing the inner parser or evaluator back to Go.

The resulting path now works:

```text
Go-hosted Aiki
    -> Aiki-written interpreter
        -> self-host-loaded Aiki interpreter
            -> 1 + 2 * 3
                -> 9
```

The result is `9` because ordinary Aiki binary expressions are evaluated left to right: `(1 + 2) * 3`. The same visible semantic rule survives at the third level.

Go remains the production runtime and bootstrap substrate. The self-host implementation is a second implementation and conformance boundary, not an attempt to pretend that the underlying machine or host runtime has disappeared.

## Profiling the Profiler

Semantic profiling was already present in the first alpha. During the self-hosting work it became useful enough that the measurements themselves deserved scrutiny.

The recursive profiles are large. Rather than accept them because they looked plausible, I built a calibration experiment beginning with work whose semantic counts can be read directly from a few lines of Aiki.

The first programs put:

```aiki
1 + 1
```

inside one, two, three, and four nested loops of ten. The leaf calculation therefore executes 10, 100, 1,000, and 10,000 times. The total completed loop-body iterations are 10, 110, 1,110, and 11,110. The profiler reports those counts exactly.

Arithmetic is equally direct. Each leaf contributes one addition and each loop-body iteration increments one loop variable, so the expected arithmetic counts are 20, 210, 2,110, and 21,110. Those counts are exact as well. The observed comparison sequence: 11, 121, 1,221, and 12,221, is also exactly what follows from testing each loop condition once more than its body executes.

A simpler expression:

```aiki
1 + 2 + 3 + 4
```

contains three arithmetic operations; the profiler reports three.

A conventional loop:

```aiki
while i < N {
    x = x + 1
    i = i + 1
}
```

has the directly predictable relationships:

```text
arithmetic = 2N
comparison = N + 1
iteration  = N
```

For `N` equal to 10, 100, and 1,000, the observed counts match all three relationships exactly.

The experiment then moves into self-interpretation. With one Aiki-written interpreter loaded, one additional evaluation contributes:

```text
arithmetic       958
comparison      1,082
call            3,255
iteration         832
index             935
```

Two evaluations add exactly twice that work, and four add exactly four times that work.

At the next interpreter level the fixed baseline is already large:

```text
arithmetic       689,681
comparison     1,346,671
call           5,021,109
iteration        498,039
index            793,179
```

One additional third-level evaluation then adds:

```text
arithmetic      +353,930
comparison      +388,932
call          +2,342,216
iteration       +304,091
index           +397,156
```

and the next identical evaluation adds exactly the same vector.

I ran the complete experiment twice. Every semantic counter was reproduced exactly across the two runs, including the native, one-level, and two-level self-host cases. The Go realization figures: elapsed time, cumulative allocation traffic, malloc count, and garbage-collection cycles, varied modestly, as expected.

The distinction is important. The semantic counters describe Aiki-level work. The Go measurements describe a particular realization of that work by the runtime and machine.

The calibration therefore connects programs countable by inspection with recursive interpretation involving millions of semantic events. Large recursive profiler counts are not being accepted merely because they have plausible scale; they are produced by the same instrumentation that is exact on small source and additive under repeated interpreted work.

## Experiments Are Not Tests

That calibration became Experiment 001 and, in the process, exposed the need for another kind of project artifact.

Tests and experiments answer different questions. A test normally states a relationship the implementation is required to preserve. An experiment records a procedure, an observation, and an interpretation without turning the observation into a correctness gold.

Aiki experiments therefore have a simple structure:

```text
001-profiler-calibration/
    README.md

    experiment/
        PROCEDURE.md
        run.sh
        materials...

    results/
        observations...

    analyses/
        interpretations...
```

The root orients the reader. `experiment/` records the procedure and its materials. `results/` contains what happened. `analyses/` contains what I think the observations mean.

New work can be scaffolded outside the source tree with:

```text
aiki experiment new "name"
```

The running distribution supplies the sequence number from its curated `experiments/` collection, while the experiment itself is created in the caller's current directory. Finished work can then be promoted into the repository.

The distinction among procedure, observation, and interpretation is useful enough that I expect experiments to become a regular part of Aiki development.

## The Commitments

None of this changes the original commitments of the project.

I still want Aiki to have a small surface and to make computational relationships visible enough to apprehend rather than merely execute. I still prefer direct composition over hidden machinery. The implementation still does not define the language merely by existing.

The extensive use of generative AI in the implementation makes this more important rather than less. The response is not to obscure that AI produced source code. It is to make the resulting source increasingly answerable to authorities and evidence outside itself.

The grammar owns syntax facts. Reviewed behavior constrains semantics. Executable documentation constrains examples. The language surface constrains implementation choices. Independent implementations can be compared. Editor clients exercise the service boundary. Relocated distributions test assumptions about location. Experiments retain their observations beside the procedure that produced them.

The direction is toward fewer places where an implementation assumption can quietly become a language fact.

## Platforms

Linux remains Aiki's development home. That is where it is built, changed, and exercised continuously.

Intel macOS is periodically put through the more rigorous build and validation path rather than being assumed portable merely because it compiles. Windows is also run periodically and remains part of the portability work, although neither platform receives the continuous development attention that Linux does.

Aiki is cross-platform alpha software, developed primarily on Linux.

## Pending Work

The authority work made several unresolved language questions easier to see. Newline behavior still has intentionally deferred edges, including the treatment of some leading continuations and the special case around function-literal endings. Those are now explicit language-design questions rather than accidental parser rules.

The language-service architecture is also deliberately incomplete. Incremental parsing, workspace-wide indexing, semantic tokens, rename/refactoring, and similar facilities are possible extensions, but they are not requirements merely because LSP has names for them. I would rather add them when actual use shows where the simpler model is inadequate.

Spawned abnormal termination needs further thought as well. Aiki's concurrency model makes isolation and message passing explicit; failure of spawned computations should have equally explicit observable semantics rather than becoming a leak from the Go substrate.

The broader project record now distinguishes proposals, audit findings, design decisions, experiments, bugs, and implementation sessions. I expect to continue using those distinctions rather than turning every open question into an implementation task.

## Future Direction

The architectural direction is to continue tightening responsibilities and authorities: make each fact, capability, and policy belong somewhere definite; derive rather than duplicate where possible; and make important relationships executable.

The next capability work is likely to concentrate on the systems substrate.

### Process Execution

I expect to start with process execution. A useful interface needs to launch a program with arguments, standard input, environment, and working directory, and return standard output, standard error, and exit status.

The host operation is narrow and belongs below the HAL boundary. Process orchestration belongs in Aiki. This is a small addition with a large practical effect because it allows Aiki programs to compose ordinary system tools.

### Networking

TCP requires a similarly small host surface: listen, accept, connect, read, write, and close.

Aiki already has isolated `spawn`, channels, and message passing. A concurrent server should be constructed by composing those facilities with networking rather than by adding a separate server model.

### JSON

JSON should be largely an Aiki library. The self-host lexer has already demonstrated character-level scanning, and Aiki values map reasonably well onto JSON values. A parser and emitter written in Aiki would be another useful test of where the HAL boundary belongs.

### Operating-System Surface

A systems environment also needs ordinary process facts: arguments, environment variables, current directory, directory change, exit status, process ID, hostname, and related information.

I expect these to be a collection of small HAL capabilities behind an Aiki `os` module rather than additions scattered through the prelude.

### Signals

Signal handling has to fit the concurrency model. My present direction is for signals such as SIGINT and SIGTERM to arrive as channel events, allowing ordinary message passing and `select` to coordinate them instead of introducing an unrelated asynchronous control mechanism.

### Timers

Wall-clock time, elapsed time, and sleeping are straightforward host facilities. Timed coordination should compose with concurrency; `time.after` naturally fits the existing `select` design.

### Cryptographic Hashing

SHA-256 and HMAC are another relatively clean boundary and become useful once programs begin dealing with integrity or authentication.

Across these additions the question remains the same: what is the smallest thing the host must provide, and what can Aiki construct from it?

## Aiki at `v0.4.0-alpha-26`

Much of the work since the first alpha is architectural rather than immediately visible at the prompt. The following is a compact inventory of the tagged system.

### Language

* exact rational arithmetic;
* left-to-right ordinary binary evaluation;
* numbers, booleans, runes, strings, symbols, lists, and first-class functions;
* functions, closures, recursion, rest parameters, iteration, and pipelines;
* pattern matching;
* shaped list data and named fields;
* recoverable error values;
* modules and explicit imports;
* isolated spawn-based concurrency and channels;
* graphics, canvas, and turtle facilities.

### Language Authority and Description

* declarative grammar owning the syntax surface;
* grammar-owned newline termination and suppression policy;
* centralized cached structural grammar analysis;
* grammar/evaluator coupling;
* grammar/formatter coupling;
* checked linter syntax knowledge;
* grammar-derived binary-operator membership;
* grammar-backed syntax help;
* reviewed structural parse projections;
* executable documentation.

### Implementations

* production Go-hosted interpreter;
* independent Aiki-written lexer;
* independent Aiki-written newline normalizer;
* independent Aiki-written recursive-descent parser;
* Aiki-written runtime environment;
* Aiki-written evaluator;
* self-hosted Aiki-source module resolution, loading, exports, and caching;
* scoped bootstrap bridge for HAL capabilities;
* recursive self-interpretation through a third-level Aiki program.

### Language Services and Editors

* editor-independent document analysis;
* structured diagnostics;
* symbol discovery and definition lookup;
* canonical formatting;
* completion;
* hover from source definitions and authored help;
* language-service observation and instrumentation;
* `aiki lsp`;
* Xed syntax and live diagnostics;
* VS Code diagnostics, completion, hover, definition, and formatting;
* classic `aiki tags` generation for nvi and other tags consumers.

### Modules and Platform Boundary

* standard Aiki module library;
* pure Aiki and HAL-backed modules;
* explicit distribution module roots;
* user library support;
* explicit relative imports;
* relocatable distribution lookup;
* dynamic symbol construction with `to_symbol`;
* general shaped-value construction with `shaped`.

### Validation and Conformance

* Go tests;
* Aiki-native tests;
* behavioral smokes;
* reviewed gold files;
* executable documentation;
* grammar-production coverage;
* structural engine golds;
* formatter parse-preservation checks;
* lint;
* tree integrity checking;
* fuzz tests;
* property tests;
* explicit negative-test declarations;
* cross-implementation lexer, newline, parser, and behavioral conformance;
* recursive self-interpretation invariants.

### Profiling and Experiments

* deterministic Aiki-level semantic counters;
* source attribution;
* Go runtime-realization measurements;
* recursive self-host profiling;
* empirical profiler calibration;
* numbered reproducible experiment homes;
* separate procedure, raw results, and analyses;
* Experiment 001, profiler calibration.

### Distribution and Development

* `make validate`;
* `make dist`;
* `make distcheck`;
* restartable repository baselines;
* relocatable user distributions;
* structural checking of distributed artifacts;
* proposals;
* audit findings;
* recorded design decisions;
* in-repository AI engineering provenance and restart records.

## Where This Leaves Aiki

The first public alpha established that Aiki had become a usable small language. Milestone 26 is less about adding another layer of surface features than about making more of the system accountable to explicit relationships.

The grammar now owns more of the syntax it describes. Several formerly duplicated facts have identifiable authorities. The editor integrations consume common language services. A second implementation now covers the front end, evaluator, and module path. Aiki can run that implementation recursively. Distribution and self-hosting have both been exercised away from the source-tree environment that originally sheltered them. The profiler has been calibrated from directly countable programs through recursive interpretation.

There is plenty left to do, but this is a useful state to mark.

Development continues on `master`; `v0.4.0-alpha-26` is the milestone.

### Links

* [Aiki on GitHub](https://github.com/decuser/aiki)
* [Aiki `v0.4.0-alpha-26`](https://github.com/decuser/aiki/tree/v0.4.0-alpha-26)
* [First Public Alpha](/posts/aiki-alpha-release/)

*post added 2026-08-15 19:49:00 -0500*


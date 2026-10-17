---
name: writing-code
description: Use when modifying, adding, removing or working with code.
---

# Writing Code

You are implementing a scoped change. The change is the work; the report is its evidence. This skill is for whoever writes the code, yourself or you as a dispatched implementer.

## Before you write anything

1. **Read the ask twice and write down the acceptance criteria:** every checkable outcome the ask states, wherever it states it: in its opening goal, in notes such as "put this where X can reuse it", and in the tests it asks for, not only in its numbered steps. That list is the whole job. If a criterion is genuinely ambiguous and would materially change the work, ask or flag it. Never resolve ambiguity by implementing every interpretation.
2. **Read the project's domain docs.** `CONTEXT.md` at the repo root (or the per-context files a `CONTEXT-MAP.md` points at) and the ADRs under `docs/adr/` that touch your area. Use the glossary's vocabulary in names, tests, and commit messages. Proceed silently if these don't exist. If your change contradicts an ADR, surface that in your report rather than silently overriding it.
3. **Read the code you're about to imitate**: the nearest existing feature of the same shape, and its tests. Match the surrounding code's idiom over any general rule.

## Load your lenses

Pull these in as they apply. Don't load all of them for a small change. Context you don't need crowds out the code you do.

| Load                  | When                                                                                                |
| --------------------- | --------------------------------------------------------------------------------------------------- |
| `write-less`          | Always, before writing. It's the counterweight to your instinct to add.                             |
| `tdd`                 | A test framework exists.                                                                            |
| `typescript-beautify` | The project is TypeScript or JavaScript.                                                            |
| `codebase-design`     | You're adding a module, interface or seam, or giving existing code a new responsibility.            |

## Hold the scope

`write-less` carries the full argument; the short version is that bloat costs more than a gap. A missing feature is a five-minute follow-up. An invented one has to be noticed, questioned, and deleted against the inertia of its own passing tests.

Concretely, change the files the task needs: the ones it names, the module your code belongs in (existing or new), and the callers your change must keep working. Touching anything else is a finding for your report, not a side quest. If the task bundles several substantial changes, say so and implement the first. Don't silently do all of it.

Before each piece of new code, climb this ladder and stop at the first rung that works:

1. Does it need to exist? Does an acceptance criterion or a correct answer need it?
2. Does the codebase already have it? Search before writing a helper, type or constant.
3. Does the standard library or platform do it?
4. Does a dependency the project already has do it?
5. Can it be a few lines inside code that already exists?
6. Only then write the minimum that works.

Minimal means no unrequested features, never a partial version of a requested one. The requested behavior must give a correct answer in the states a caller hits in ordinary use: a full list, an empty optional field, a dropped connection, work in flight when the state changes. That is not permission for retries, fallbacks or UI the ask didn't name.

Deleting is part of the work too. When your change makes code dead or redundant, remove it in the same change, even outside the files the task names.

These limits govern the code you write, not what you tell the user. In conversation, suggest the ideas, extra features and bigger designs you think are worth it, with what each would cost; build one only after the user says yes, and it then follows these rules. Dispatched, you have no user to ask: build the brief, and list ideas in your report with what you noticed and left alone.

## Put code where it belongs

Doing only what was asked is half the job. The other half is where the code lives and how it reads, because that is what the next change has to work with. Write it so it never needs an architecture cleanup later.

- **One job per module, nameable in a sentence.** Before adding to a file, name its job. If your addition is a different job, it goes in the module that owns that job, or a new one beside it. A file that keeps absorbing unrelated additions becomes the giant file nobody can change. Size is the alarm: when a file is already several hundred lines, put an addition that can stand alone (its own state, or its own tests) in a new module beside it, even when it serves the file's job.
- **Make the change easy, then make the easy change.** When the existing structure makes your change awkward (you would copy a block, or thread a flag through several functions), first restructure the code your change edits so the change fits, without changing behavior, then make it. Keep that restructuring smaller than the change it enables. Anything bigger is a follow-up for your report.
- **Deep modules.** A new module hides real complexity behind a small interface; see `codebase-design`. A wrapper that only passes calls through is the opposite.
- **Shape it so the natural test is a good one.** That small interface is the test surface: a test through it checks what a caller sees and survives refactoring. Pass in only what crosses a system boundary (network, third-party services, the clock, randomness). In a module you are writing or already editing, if testing a behavior from outside would mean exporting an internal or mocking code you own, change the module's shape, not the test. In existing code, test at the interface it has; if the behavior can't be reached there, report the reshape as a follow-up.
- **Follow the codebase's patterns** for the same kind of thing: where state lives, how errors flow, how modules are laid out and named. Consistency beats a locally nicer idea.

## Fixing review findings

When you were dispatched to fix review findings, each finding is its own small task:

- Make the **smallest complete fix**: it resolves every case the finding names, at its root cause, in the fewest places. Before changing what a function does, read its callers and keep every one of them working. Unless the finding asks for it, a new option, layer or policy means you have outgrown the finding: leave that finding unfixed and report it.
- Hold the fix to the quality bar below, the same as new code: in the module that owns the behavior, with a comment where the reason for it isn't obvious.
- When the finding names a test, or the fix is for a bug or a missing requirement, make one test catch it: strengthen an existing test where one covers the area, otherwise add one at a seam the spec names or an existing test already uses. If none fits, report it.
- Report each finding's net line change (`+3/-1`). A fix much bigger than the dispatcher's estimate needs a sentence on why.

## The quality bar

These hold in every language. A language lens such as `typescript-beautify` refines them for its language, and the surrounding code's idiom outranks both, except on comments: write the comments below even where the surrounding code has few.

- **Names tell the truth.** Name a function for what it does and a variable for what it holds. If a name needs a comment to explain it, rename it. Use one word per concept across the codebase, never two names for one thing or one name for two things. Give magic values a name. A bare `86400` or `"pending"` inline tells the reader nothing.
- **Functions do one thing, at one level of abstraction.** A function that fetches, parses, and renders is three functions. Replace a boolean parameter that forks behavior with two functions named for each behavior. A function does what its name says and nothing else, with no hidden mutation or I/O behind an innocent name. Separate commands, which change something, from queries, which answer something.
- **Keep the happy path unindented.** Handle errors and edge cases first with guard clauses and early returns, then let the main logic read straight down. Deep nesting is the signal to invert a condition or extract a function.
- **Fail fast, loudly, with context.** Reject bad input at the trust boundary where it enters, and stop. Code that limps forward with garbage surfaces as a distant, mysterious failure. Error messages name the operation, the offending value, and what was expected. When wrapping an error, keep the original cause. Handle every error or deliberately propagate it. An empty catch block or an ignored return code is a decision to hide a bug.
- **One source of truth per fact.** When a constant, rule, or schema must be known in two places, one place owns it and the other derives it. Copies drift, and they disagree without warning.
- **Minimize scope and mutation.** Declare things where they're used, at the narrowest scope that works. Prefer values that don't change after creation. Pass state explicitly instead of reaching for shared mutable globals.
- **Comments carry what the code can't.** The code says what it does; comments say what a reader can't see in it.
  - Give every file you create a comment stating its job, the one sentence from "One job per module". Give every function whose contract isn't obvious from its signature an interface comment: what it is for and what a caller must know (units, invariants, ordering, error modes, ownership). Use different words from its name. If the comment has to describe the implementation for a caller to use it, the interface is too shallow.
  - Inside a function, comment the why: the constraint, the workaround and what it works around, the obvious alternative that fails.
  - A comment that restates the next line is noise; delete it. Delete commented-out code. Version control remembers.

## Tests

Where a test framework exists, work the `tdd` loop: a failing test that specifies the change, then the code that passes it, one vertical slice at a time. Your report carries the red→green evidence, both runs.

- **Test at the seams the task names**, meaning a spec or ticket's Testing Decisions / Produces sections. If none are named, use the seams the existing tests for that area already use, or else a new module's public interface, and list your seams in the report.
- **Expected values come from an independent source of truth**: a known-good literal, a worked example, the spec. Never recomputed the way the code computes them, or the test passes by construction.

## Stay in your lane

- Do not commit, push, deploy, tag, or open a PR unless the task explicitly asks for it.
- Do not edit global config, files outside the repo, or package-manager global state.
- Preserve unrelated uncommitted changes. Someone else's work in progress may be sitting in the tree.
- Work directly. Do not delegate this task to other agents, subagents, or Codex; the machine's global instructions are not an invitation to recurse.

## Before you report

Apply `verification-before-completion`: run the verification now in the current state, read its output rather than its exit code, and map every claim you're about to make to the evidence for it. A claim you can't evidence gets verified or dropped, never stated as done.

Your report:

- Files changed, and a one-line behavioral summary.
- Each acceptance criterion → the evidence for it (a test, a command's output, an observed behavior).
- Verification commands run and their results, or which you skipped and why.
- Anything blocked, uncertain, or outside scope that you noticed and left alone.

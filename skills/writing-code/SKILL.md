---
name: writing-code
description: Use when modifying, adding, removing or working with code.
---

# Writing Code

You are implementing a scoped change. The change is the work; the report is its evidence. This skill is for whoever writes the code, yourself or you as a dispatched implementer.

## Before you write anything

1. **Read the ask twice and write down the acceptance criteria.** That list is the whole job. If a criterion is genuinely ambiguous and would materially change the work, ask or flag it. Never resolve ambiguity by implementing every interpretation.
2. **Read the project's domain docs.** `CONTEXT.md` at the repo root (or the per-context files a `CONTEXT-MAP.md` points at) and the ADRs under `docs/adr/` that touch your area. Use the glossary's vocabulary in names, tests, and commit messages. Proceed silently if these don't exist. If your change contradicts an ADR, surface that in your report rather than silently overriding it.
3. **Read the code you're about to imitate**: the nearest existing feature of the same shape, and its tests. Match the surrounding code's idiom over any general rule.

## Load your lenses

Pull these in as they apply. Don't load all of them for a small change. Context you don't need crowds out the code you do.

| Load                  | When                                                                                                |
| --------------------- | --------------------------------------------------------------------------------------------------- |
| `write-less`          | Always, before writing. It's the counterweight to your instinct to add.                             |
| `tdd`                 | A test framework exists.                                                                            |
| `typescript-beautify` | The project is TypeScript or JavaScript.                                                            |
| `codebase-design`     | You're shaping a new module, interface, or seam. Not for a change that fits inside an existing one. |

## Hold the scope

`write-less` carries the full argument; the short version is that bloat costs more than a gap. A missing feature is a five-minute follow-up. An invented one has to be noticed, questioned, and deleted against the inertia of its own passing tests.

Concretely, change the files the task names. Touching something else is a finding for your report, not a side quest. If the task bundles several substantial changes, say so and implement the first. Don't silently do all of it.

## The quality bar

These hold in every language. A language lens such as `typescript-beautify` refines them for its language, and the surrounding code's idiom outranks both.

- **Names tell the truth.** Name a function for what it does and a variable for what it holds. If a name needs a comment to explain it, rename it. Use one word per concept across the codebase, never two names for one thing or one name for two things. Give magic values a name. A bare `86400` or `"pending"` inline tells the reader nothing.
- **Functions do one thing, at one level of abstraction.** A function that fetches, parses, and renders is three functions. Replace a boolean parameter that forks behavior with two functions named for each behavior. A function does what its name says and nothing else, with no hidden mutation or I/O behind an innocent name. Separate commands, which change something, from queries, which answer something.
- **Keep the happy path unindented.** Handle errors and edge cases first with guard clauses and early returns, then let the main logic read straight down. Deep nesting is the signal to invert a condition or extract a function.
- **Fail fast, loudly, with context.** Reject bad input where it enters and stop. Code that limps forward with garbage surfaces as a distant, mysterious failure. Error messages name the operation, the offending value, and what was expected. When wrapping an error, keep the original cause. Handle every error or deliberately propagate it. An empty catch block or an ignored return code is a decision to hide a bug.
- **One source of truth per fact.** When a constant, rule, or schema must be known in two places, one place owns it and the other derives it. Copies drift, and they disagree without warning.
- **Minimize scope and mutation.** Declare things where they're used, at the narrowest scope that works. Prefer values that don't change after creation. Pass state explicitly instead of reaching for shared mutable globals.
- **Comments say why, not what.** Write them for the constraint, invariant, or rejected alternative the code can't express. Delete commented-out code. Version control remembers.

## Tests

Where a test framework exists, work the `tdd` loop: a failing test that specifies the change, then the code that passes it, one vertical slice at a time. Your report carries the red→green evidence, both runs.

- **Test only at the seams the task names**, meaning a spec or ticket's Testing Decisions / Produces sections. If none are named, propose seams in your report before relying on them.
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

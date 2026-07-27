---
name: writing-code
description: How to implement a scoped change well — what to read first, how to hold scope, how to test, and what evidence your report owes. Load BEFORE writing code for a task, ticket, or fix, whether you are working directly or you were dispatched as an implementer.
---

# Writing Code

You are implementing a scoped change. The change is the work; the report is its evidence. This skill is for whoever writes the code — yourself, or you as a dispatched implementer.

## Before you write anything

1. **Read the ask twice and write down the acceptance criteria.** That list is the whole job. If a criterion is genuinely ambiguous and would materially change the work, ask or flag it — never resolve ambiguity by implementing every interpretation.
2. **Read the project's domain docs.** `CONTEXT.md` at the repo root (or the per-context files a `CONTEXT-MAP.md` points at) and the ADRs under `docs/adr/` that touch your area. Use the glossary's vocabulary in names, tests, and commit messages. Proceed silently if these don't exist. If your change contradicts an ADR, surface that in your report rather than silently overriding it.
3. **Read the code you're about to imitate** — the nearest existing feature of the same shape, and its tests. Match the surrounding code's idiom over any general rule.

## Load your lenses

Pull these in as they apply. Don't load all of them for a small change — context you don't need crowds out the code you do.

| Load | When |
| --- | --- |
| `write-less` | Always, before writing. It's the counterweight to your instinct to add. |
| `tdd` | A test framework exists. |
| `typescript-beautify` | The project is TypeScript or JavaScript. |
| `codebase-design` | You're shaping a new module, interface, or seam — not for a change that fits inside an existing one. |

## Hold the scope

`write-less` carries the full argument; the short version is that bloat costs more than a gap. A missing feature is a five-minute follow-up. An invented one has to be noticed, questioned, and deleted against the inertia of its own passing tests.

Concretely: change the files the task names. Touching something else is a finding for your report, not a side quest. If the task bundles several substantial changes, say so and implement the first — don't silently do all of it.

## Tests

Where a test framework exists, work the `tdd` loop: a failing test that specifies the change, then the code that passes it, one vertical slice at a time. Your report carries the red→green evidence — both runs.

- **Test only at the seams the task names** (a spec or ticket's Testing Decisions / Produces sections). If none are named, propose seams in your report before relying on them.
- **Expected values come from an independent source of truth** — a known-good literal, a worked example, the spec. Never recomputed the way the code computes them, or the test passes by construction.

## Stay in your lane

- Do not commit, push, deploy, tag, or open a PR unless the task explicitly asks for it.
- Do not edit global config, files outside the repo, or package-manager global state.
- Preserve unrelated uncommitted changes — someone else's work in progress may be sitting in the tree.
- Work directly. Do not delegate this task to other agents, subagents, or Codex; the machine's global instructions are not an invitation to recurse.

## Before you report

Apply `verification-before-completion`: run the verification now in the current state, read its output rather than its exit code, and map every claim you're about to make to the evidence for it. A claim you can't evidence gets verified or dropped — never stated as done.

Your report:

- Files changed, and a one-line behavioral summary.
- Each acceptance criterion → the evidence for it (a test, a command's output, an observed behavior).
- Verification commands run and their results — or which you skipped and why.
- Anything blocked, uncertain, or outside scope that you noticed and left alone.

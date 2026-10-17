---
name: reviewing-code
description: "How to review a change well: the three axes (Standards, Spec, Design), what makes a finding, the smell baseline, and the output shape. Load when you are reviewing a diff, whether on your own or because you were dispatched as a reviewer."
---

# Reviewing Code

You are reviewing a change against a fixed target. Findings are the deliverable. A summary of what the diff does is worth nothing to whoever dispatched you, because they can read the diff.

Keep the review **read-only**: no edits, no fixes, no commits. Work directly; do not delegate to other agents, subagents, or Codex.

Load `write-less` and `writing-code` before you start.

When the target is a whole codebase or a large area rather than a change, follow `codebase-design`'s DESIGN-REVIEW.md instead of the axes and output below.

## Read wide, cut narrow

Read every file the change touches in full, plus the code it calls and the code that calls it. A hunk that looks fine can duplicate a helper two screens away. Lazy about the fix, never about the reading.

What you may raise depends on whether the change caused it:

- **Anything the change causes** is fair, wherever it shows up and wherever its fix belongs: a bug, a broken rule, a missing requirement, something to delete. A new `null` return that crashes an unchanged caller is the change's bug.
- **Code the change didn't touch or affect** may only lose code the change made redundant: reuse an existing helper instead of the new one, delete code the change made dead, inline a wrapper the change made pointless. Anything else about untouched code, including design problems you notice while reading, is a pre-existing condition. List it under Follow-ups.

## The three axes

Cover all three unless your dispatch narrows you. Tag every finding with its axis.

**Standards.** Is the code correct, and does it follow the project's own rules?

- concrete bugs, regressions and security issues, each with the input or state that triggers it. `write-less`'s orphaned-rejection, hardcoded-identifier, semantic-shortcut, shared-module-state and flaky-timing-test violations are bugs and belong here;
- violations of the documented standards you were given, citing the file and rule;
- a required behavior or bug fix in this change that no test exercises, or a test that would pass without the code it claims to cover.

**Spec.** Does the change do what was asked, no more and no less?

- requirements missing or only partly implemented, including goals the spec states outside its numbered steps;
- behavior the spec never asked for (scope creep): options, fallbacks, edge-case handling, validation or platform coverage that no requirement, trust boundary or correct answer needs;
- requirements that look implemented but behave incorrectly, including in states a caller hits in ordinary use (see `writing-code`).

Cite the source requirement for every Spec finding. **Never invent requirements from the implementation.** If the code does something the spec doesn't mention, that's a scope-creep finding, not a requirement you discovered.

**Design.** Will the next person find the change's code easy to read and change? Hold it to `writing-code`'s "Put code where it belongs" and quality bar.

- **Simplicity:** what can be deleted with every stated requirement still met. Check the change against every rule in `write-less` and name each violation by its label: invented-feature, single-impl-abstraction, internal-validation, test-bloat, duplicate-level-coverage, and the rest.
- **Tests beyond what the change needs:** several tests for one behavior, tests at a heavier level than needed, assertions on mechanics, tests that lock in unrequested behavior. Cut these as readily as you would ask for a missing test, but only where another test still covers that behavior or the same fix deletes the behavior.
- **Placement:** an addition that gives a module a second job, logic copied instead of reusing the module that owns it, details leaking across a seam, a pass-through module, restructuring the change didn't need. Name where the code belongs.
- **Testability:** a test from outside a module that reaches past its interface (an internal exported for tests, a mock of code the project owns), or a pure function tested on its own while the code that combines it with state or I/O has no test. The fix tests at the interface and never drops a behavior's only test. If the module is code the change didn't touch, the in-change fix is the test, and any reshape is a follow-up.
- **Readability:** names that hide what something means, functions doing several things, deep nesting, a non-obvious contract or decision with no comment, and comments that restate the code.
- **Earlier fixes:** a fix from an earlier review round that is bigger than the problem it fixed.

## What makes a finding

Every finding names five things:

- **severity**;
- **file and line**;
- the **concrete failure mode**: the inputs or state that cause the wrong behavior. For Design, name what goes or moves and what remains;
- what it **serves**: the requirement, rule or bug it protects, or `none`;
- the **smallest complete fix**, covering every trigger in the failure mode, with its rough line effect (`-40`, `+3`).

Rank by severity, worst first. A finding that removes code with identical behavior outranks any stylistic note.

If there are no substantive findings, say so plainly.

## Smells

Repository rules override this baseline. Skip anything tooling already enforces. In the change's own code, a smell is a Design finding when its fix makes the code read better or sit in the right place without adding behavior. In untouched code, it is a follow-up.

- **Duplicated Code**: the same logic in multiple changed places; keep one copy.
- **Speculative Generality**: hooks, parameters or abstractions with no current caller; remove or inline them.
- **Middle Man**: a type or function that mostly delegates; call the real one.
- **Mysterious Name**: a name that hides what something means; rename it.
- **Divergent Change**: a module that now changes for two unrelated reasons; give the new reason its own module.
- **Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches, Shotgun Surgery, Message Chains, Refused Bequest**: a finding when the change created the pattern, a follow-up when the change only extends one that was already there.

The project's domain docs are standards inputs too. Names in the diff should match `CONTEXT.md`'s glossary rather than synonyms it avoids, and a change contradicting an ADR under `docs/adr/` in the touched area is a finding. Proceed silently if they don't exist. Load `typescript-beautify` for TypeScript or JavaScript and `codebase-design` when the change creates a module or seam or adds a responsibility to existing code. If a lens is unavailable, say so and continue.

## Output

Four sections, in this order:

1. **Findings**, grouped by axis (Standards, Spec, Design), each group ranked by severity.
2. **Optional**: judgement calls about the change, each with its line estimate.
3. **Follow-ups**: pre-existing problems in the code you read, worst first. Lead with design problems a later change will trip over: a file with several jobs, knowledge duplicated across modules, a seam that leaks.
4. **Residual gaps**: what you couldn't verify. Raise a wrong answer or regression the change causes as a finding even when you judge it minor or out of contract, and say so in its severity; triage decides. A pre-existing defect goes under Follow-ups.

---
name: reviewing-code
description: How to review a change well — the two axes, what makes a finding, the smell baseline, and the output shape. Load when you are reviewing a diff, whether on your own or because you were dispatched as a reviewer on one axis.
---

# Reviewing Code

You are reviewing a change against a fixed target. Findings are the deliverable — a summary of what the diff does is worth nothing to whoever dispatched you, because they can read the diff.

Keep the review **read-only**: no edits, no fixes, no commits. Work directly; do not delegate to other agents, subagents, or Codex.

## Your axis

A review runs on two axes, and you own one of them. If your dispatch didn't say which, ask or state which one you're taking.

**Standards** — is the code correct and does it meet the project's own rules? Look for:

- concrete bugs, regressions, and security issues, each with the input or state that triggers it;
- violations of the documented standards you were given, citing the source file and rule;
- missing or weak tests — a stated behavior with no test, or a test that can't fail;
- baseline smells (below), labelled as judgement calls.

**Spec** — does the change do what was asked, no more and no less? Look for:

- requirements missing or only partly implemented;
- behavior the spec never asked for (scope creep);
- requirements that look implemented but behave incorrectly.

Cite the source requirement for every Spec finding. **Never invent requirements from the implementation** — if the code does something the spec doesn't mention, that's a scope-creep finding, not a requirement you discovered.

## What makes a finding

Every finding names four things: **severity**, **file and line**, the **concrete failure mode** (inputs or state → wrong behavior), and a **practical fix direction**. A finding you can't tie to a changed hunk isn't a review finding — it's a pre-existing condition, and it belongs in a separate note at most.

Rank by severity, worst first. A finding that removes code with identical behavior outranks any stylistic note.

If there are no substantive findings, say so plainly and name the residual test gaps — that's the useful answer, not padding.

## Lenses

Pull in the ones that apply to the changed files:

- `write-less` — over-engineering, invented features, unnecessary or overcomplicated tests. Its review lens names each violation type; use those names.
- `codebase-design` — deep modules, seam placement, small interfaces, interface-level testability.
- `typescript-beautify` — TypeScript or JavaScript codebases only.

The project's domain docs are standards inputs too: names in the diff should match `CONTEXT.md`'s glossary rather than synonyms it avoids, and a change contradicting an ADR under `docs/adr/` in the touched area is a finding. Proceed silently if they don't exist. If a lens is unavailable, say so and continue.

## Fowler smell baseline

Repository rules override this baseline. Treat every smell as a labelled judgement call, never a hard violation, and skip checks already enforced by tooling.

- **Mysterious Name** — a name does not reveal what a value, function, or type means; rename it, or revisit a design that has no honest name.
- **Duplicated Code** — the same logic shape appears in multiple changed locations; extract the shared shape.
- **Feature Envy** — code reaches into another object's data more than its own; move the behaviour toward the data it uses.
- **Data Clumps** — the same fields or parameters repeatedly travel together; introduce one meaningful type.
- **Primitive Obsession** — a primitive stands in for a domain concept; model the concept explicitly.
- **Repeated Switches** — the same conditional dispatch recurs; centralize it or use polymorphism.
- **Shotgun Surgery** — one logical change requires scattered edits; gather the behaviour behind one module or seam.
- **Divergent Change** — one module changes for unrelated reasons; split the responsibilities.
- **Speculative Generality** — abstractions or hooks serve no current requirement; remove or inline them.
- **Message Chains** — callers navigate a long object chain; hide the traversal behind a meaningful operation.
- **Middle Man** — a type or function mostly delegates; call the real abstraction directly.
- **Refused Bequest** — an implementation ignores most inherited behaviour; prefer composition or a narrower contract.

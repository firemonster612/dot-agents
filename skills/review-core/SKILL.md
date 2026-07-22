---
name: review-core
description: The shared process for independent code reviews — target pinning, spec and standards discovery, the Fowler smell baseline, reviewer prompts, and aggregation. Use whenever running a review via claude-review or codex-review, or when another skill needs the review process.
---

# Review Core

The process both review-delegate skills follow. The tool-specific mechanics — CLI invocation, model choice, edge cases — live in `claude-review` and `codex-review`; consult the one you're dispatching through.

Use an independent reviewer when the user wants a second pass or a change is broad enough to benefit from another perspective. Do not delegate merely to avoid reading the code. Treat the reviewer's output as evidence, not authority.

## Process

### 1. Pin and validate the review target

Resolve the target before delegating. Capture the exact command once so both axes inspect the same change:

- Branch, tag, or base ref: verify it with `git rev-parse <fixed-point>`, then use `git diff <fixed-point>...HEAD` and `git log <fixed-point>..HEAD --oneline`. The three-dot diff compares against the merge-base.
- Commit: verify the SHA, then use `git show <sha>`.
- Uncommitted work: use `git status --porcelain`, `git diff HEAD`, and include untracked files explicitly.
- Specific files: name the paths and the comparison point.

Fail early if the ref is invalid or the target is empty. Do not make two reviewers rediscover a bad target.

### 2. Find the spec source

Build the Spec axis from the best available source, in this order:

1. Requirements or a spec path supplied by the user.
2. Issues or PRs referenced by commit messages; use the repository's documented issue-tracker workflow (`docs/agents/issue-tracker.md`) when present.
3. A matching PRD or spec under `docs/`, `specs/`, or `.scratch/`.

If no reliable spec exists, skip the Spec reviewer and report `No spec available`. Never invent requirements from the implementation.

### 3. Find the standards sources

Identify all instructions that apply to the changed files, including scoped `AGENTS.md` or `CLAUDE.md` files, `CONTRIBUTING.md`, coding standards, architecture documents, and test conventions.

The project's domain docs are standards inputs too: `CONTEXT.md` (names in the diff should match the glossary, not synonyms it avoids) and ADRs under `docs/adr/` in the touched area (a change that contradicts an ADR is a finding). Proceed silently if they don't exist.

The Standards axis also checks correctness, regressions, security, and missing or weak tests. Apply these additional review lenses when available:

- `codebase-design` for deep modules, clean seam placement, small interfaces, and interface-level testability.
- `write-less` for over-engineering, unnecessary code or tests, and overcomplicated tests.
- `typescript-beautify` for TypeScript or JavaScript codebases.

Keep the review read-only. If a lens is unavailable, state that and continue.

#### Fowler smell baseline

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

### 4. Run two isolated reviewers in parallel

Run one Standards reviewer and, when a spec exists, one Spec reviewer. Give both the exact target command and commit list. Do not let either see the other's report.

The Standards prompt must include the applicable standards sources and the smell baseline. Ask for:

- concrete bugs, regressions, security issues, and meaningful test gaps;
- every documented-standard violation, citing the source file and rule;
- possible baseline smells, labelled as judgement calls and tied to a changed hunk;
- severity, file and line, concrete failure mode, and a practical fix direction for every finding.

The Spec prompt must include the spec path or contents. Ask for:

- missing or partial requirements;
- behaviour not requested by the spec (scope creep);
- requirements that appear implemented but behave incorrectly;
- the source requirement and changed file/line for every finding.

Tell both reviewers: `Do not edit files. Work directly; do not delegate to other agents, subagents, or codex. Prioritize findings over summary. If there are no substantive findings, say so and identify residual test gaps.`

## Aggregate and report

Inspect every cited hunk before relaying a finding. Within each axis, distinguish confirmed findings from suggestions you could not verify.

Present separate `## Standards` and `## Spec` sections. Do not merge or rerank findings across axes. End with the finding count and worst issue within each axis; do not pick one overall winner. If an axis has no findings, say so. If no spec was available, say what target was reviewed and explicitly mark the Spec axis as skipped.

If the reviewer CLI is unavailable or fails, report the exact failure and offer to perform the review directly.

---
name: review-loop
description: At the end of a change, review it with independent reviewers in a loop — pin the target, dispatch one reviewer per axis, triage findings, dispatch one fixer, repeat. Only invoke if a skill asks or the user asks.
---

# Review Loop

Review is the one place where delegating is the point rather than a convenience: an agent reviewing its own implementation has already decided the code is right. Use independent reviewers here even when you'd do everything else yourself.

Treat their output as **evidence, not orders**.

> If you have dynamic workflows (i.e. you're running in Claude Code), script this loop as a workflow. Otherwise run it by hand.

## 1. Pin the target

Resolve it once, and give every reviewer the identical command so they inspect the same change:

- **Branch or base ref:** verify with `git rev-parse <base>`, then `git diff <base>...HEAD` and `git log <base>..HEAD --oneline`. Three dots — it compares against the merge-base.
- **Commit:** verify the SHA, then `git show <sha>`.
- **Uncommitted work:** `git status --porcelain` plus `git diff HEAD`, and name untracked files explicitly.
- **Specific files:** the paths plus the comparison point.

Fail early if the ref is invalid or the diff is empty. Don't make reviewers rediscover a bad target.

## 2. Gather the inputs

**Spec**, in order of preference: requirements or a spec path the user supplied; issues or PRs referenced by the commit messages (via `docs/agents/issue-tracker.md` when present); a matching spec under `docs/`, `specs/`, or `.scratch/`. If no reliable spec exists, skip the Spec axis and report `No spec available` — never reconstruct requirements from the implementation.

**Standards:** every instruction that applies to the changed files — scoped `AGENTS.md`/`CLAUDE.md`, `CONTRIBUTING.md`, coding standards, architecture docs, test conventions — plus `CONTEXT.md` and the ADRs under `docs/adr/` touching the area.

## 3. Dispatch one reviewer per axis

**Two reviewers, not four: the axis is the unit of dispatch, and the model family is a knob on each.** Put the two axes on different model families when both are available — that's where the independence comes from. Double up an axis only for an unusually high-stakes change.

Each reviewer gets: the `reviewing-code` skill, which axis it owns, the pinned target command and commit list, and that axis's inputs from step 2. Neither sees the other's report. Keep both read-only.

Route models per the rubric in `AGENTS.md` — judgment and taste on one axis, execution focus on the other. Where you have no native subagents, `cli-subagents` carries the command shapes.

## 4. Triage before fixing anything

Open every cited hunk yourself. Drop findings that don't survive contact with the code, and separate the ones you confirmed from the ones you couldn't verify. This step is not optional — relaying an unverified finding to a fixer spends a whole implementation cycle on nothing.

## 5. Dispatch ONE fixer

One implementer with the full verified findings list, not one fixer per finding — per-finding fixers each rebuild context and re-run the suite. It follows `writing-code`.

## 6. Repeat

Review → triage → fix, until neither axis has remaining complaints or you hit 2 iterations (or whatever count the user set).

## Reporting

Separate `## Standards` and `## Spec` sections. **Do not merge or rerank findings across axes** — they answer different questions, and a combined ranking hides which one failed. End each axis with its finding count and worst issue; don't pick one overall winner. Say so explicitly when an axis had no findings, and when the Spec axis was skipped for want of a spec, name the target that was reviewed instead.

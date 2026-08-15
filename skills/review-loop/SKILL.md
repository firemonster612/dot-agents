---
name: review-loop
description: Review changes in a loop with multiple model families.
---

# Review Loop

Review is the one place where delegating is the point rather than a convenience. An agent reviewing its own implementation has already decided the code is right. Use independent reviewers here even when you'd do everything else yourself.

Treat their output as **evidence, not orders**.

This skill is dispatcher-facing. It defines the loop: pin the target, dispatch reviewers, compile and triage their reports, dispatch one fixer, repeat. How a reviewer conducts the review is `reviewing-code`'s job, and how the fixer works is `writing-code`'s. Hand those skills as paths; don't restate their content in dispatch prompts.

**The loop is exactly one level deep.** You dispatch; reviewers and the fixer are leaves. Every dispatch prompt carries the direct-work line: `Work directly; do not delegate to other agents.` Never invoke review-loop from inside a dispatched agent. A delegate that starts its own review loop recurses without bound.

> If you have dynamic workflows (i.e. you're running in Claude Code or Pi), script this loop as a workflow. Otherwise run it by hand.

## 1. Pin the target

Resolve it once, and give every reviewer the identical command so they inspect the same change:

- **Branch or base ref:** verify with `git rev-parse <base>`, then `git diff <base>...HEAD` and `git log <base>..HEAD --oneline`. Three dots, so it compares against the merge-base.
- **Commit:** verify the SHA, then `git show <sha>`.
- **Uncommitted work:** `git status --porcelain` plus `git diff HEAD`, and name untracked files explicitly.
- **Specific files:** the paths plus the comparison point.

Fail early if the ref is invalid or the diff is empty. Don't make reviewers rediscover a bad target.

## 2. Gather the inputs

**Spec**, in order of preference: requirements or a spec path the user supplied; issues or PRs referenced by the commit messages (via `docs/agents/issue-tracker.md` when present); a matching spec under `docs/`, `specs/`, or `.scratch/`. If no reliable spec exists, skip the Spec axis and report `No spec available`. Never reconstruct requirements from the implementation.

**Standards:** every instruction that applies to the changed files, including scoped `AGENTS.md`/`CLAUDE.md`, `CONTRIBUTING.md`, coding standards, architecture docs, and test conventions, plus `CONTEXT.md` and the ADRs under `docs/adr/` touching the area.

## 3. Dispatch two reviewers

**Two reviewers, each covering both axes, on different model families.** Both get the same target and the same inputs; the independence comes from the family split, not from dividing the work. Add a third reviewer only for an unusually high-stakes change.

Each reviewer gets: the `reviewing-code` skill as a path, the pinned target command and commit list, the inputs from step 2, and the direct-work line. Nothing else — the axes, finding shape, and smell baseline are `reviewing-code`'s to apply. Neither reviewer sees the other's report. Keep both read-only.

Route models per the rubric in `AGENTS.md`: one family strong on judgment and taste, the other on execution focus. Where you have no native subagents, `cli-subagents` carries the command shapes.

## 4. Compile and triage before fixing anything

Compile both reports into one findings list, merging duplicates — both reviewers cover both axes, so overlap is expected, and a finding both raised is corroboration. Then open every cited hunk yourself. Drop findings that don't survive contact with the code, and separate the ones you confirmed from the ones you couldn't verify. This step is not optional. Relaying an unverified finding to a fixer spends a whole implementation cycle on nothing.

## 5. Dispatch ONE fixer

One implementer with the full consolidated, verified findings list, not one fixer per finding. Per-finding fixers each rebuild context and re-run the suite. It gets `writing-code` as a path and the direct-work line, same as the reviewers.

## 6. Repeat

Review → triage → fix, until neither axis has remaining complaints or you hit 2 iterations (or whatever count the user set).

## Reporting

Separate `## Standards` and `## Spec` sections. **Do not merge or rerank findings across axes.** They answer different questions, and a combined ranking hides which one failed. End each axis with its finding count and worst issue; don't pick one overall winner. Say so explicitly when an axis had no findings, and when the Spec axis was skipped for want of a spec, name the target that was reviewed instead.

---
name: review-loop
description: Review a finished change in a loop with multiple model families. Use once, after a large batch of changes is complete, not after each small edit.
---

# Review Loop

Review is the one place where delegating is the point rather than a convenience. An agent reviewing its own implementation has already decided the code is right. Use independent reviewers here even when you'd do everything else yourself.

Treat their output as **evidence, not orders**.

This skill is dispatcher-facing. It defines the loop: pin the target, dispatch reviewers, compile and triage their reports, dispatch fixers, repeat. How a reviewer conducts the review is `reviewing-code`'s job, and how a fixer works is `writing-code`'s. Hand those skills as paths; don't restate their content in dispatch prompts.

**The loop is exactly one level deep.** You dispatch; reviewers and fixers are leaves. Every dispatch prompt carries the direct-work line: `Work directly; do not delegate to other agents.` Never invoke review-loop from inside a dispatched agent. A delegate that starts its own review loop recurses without bound.

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

## 3. Select and dispatch reviewers

**Every part of the change gets at least one Claude-side and one GPT-side reviewer, each covering both axes.** Two reviewers on the whole change is the baseline. Add more when the change is broad, for example one reviewer per area of the code (server, client, migrations), with areas that together cover the whole diff.

**Reviewers share none of your context.** Dispatch each one as a fresh agent, never a fork of your conversation, so it sees none of your reasoning, your earlier attempts, or your belief that the code is right. It gets only: the `reviewing-code` skill as a path, the pinned target command and commit list (plus its area, if you split by area), the inputs from step 2, and the direct-work line. The axes, finding shape, and smell baseline are `reviewing-code`'s to apply. No reviewer sees another's report. Keep all of them read-only.

Select each reviewer's model and effort through the review-routing guidance in `AGENTS.md`; an area reviewer can get a model suited to that area. Assess both the complexity of understanding the change and the consequences if something slips through. Use the actual diff, affected behavior, verification evidence and rollback constraints; line count alone is not a proxy for either. Keep cleanliness and maintainability in scope alongside correctness.

State the chosen reviewers and the reason in one short sentence, then dispatch. The user does not need to choose models or approve routine reviewer selection. Honor an explicit user override when one is supplied. Resolve supported model IDs and effort before dispatch, prefer native tools, and use `cli-subagents` only for models native tools cannot reach. If a model is unavailable, choose a supported alternative appropriate to the same work and report the substitution.

## 4. Compile and triage before fixing anything

Compile all reports into one findings list, merging duplicates. Every reviewer covers both axes, so overlap is expected, and a finding raised by more than one reviewer is corroboration. Then open every cited hunk yourself. Drop findings that don't survive contact with the code, and separate the ones you confirmed from the ones you couldn't verify. This step is not optional. Relaying an unverified finding to a fixer spends a whole implementation cycle on nothing.

## 5. Dispatch fixers

Dispatch one or more fixers to address the verified findings, in parallel when that is faster. Give each fixer its own group of findings and files, so no two fixers edit the same file. Each fixer gets `writing-code` as a path, its findings, and the direct-work line, same as the reviewers.

## 6. Repeat

Review → triage → fix, until neither axis has remaining complaints or you hit 2 iterations (or whatever count the user set). If findings reveal greater complexity or consequences than initially assessed, reselect reviewers through AGENTS.md for the remaining passes. Changing models does not reset the iteration limit.

## Reporting

Separate `## Standards` and `## Spec` sections. **Do not merge or rerank findings across axes.** They answer different questions, and a combined ranking hides which one failed. End each axis with its finding count and worst issue; don't pick one overall winner. Say so explicitly when an axis had no findings, and when the Spec axis was skipped for want of a spec, name the target that was reviewed instead.

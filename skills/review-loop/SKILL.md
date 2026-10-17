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

**Every part of the change gets at least one Claude-side and one GPT-side reviewer, each covering all three axes.** Two reviewers on the whole change is the baseline. Add more when the change is broad, for example one reviewer per area of the code (server, client, migrations), with areas that together cover the whole diff.

**Reviewers share none of your context.** Dispatch each one as a fresh agent, never a fork of your conversation, so it sees none of your reasoning, your earlier attempts, or your belief that the code is right. It gets only: the `reviewing-code` skill as a path, the pinned target command and commit list (plus its area, if you split by area), the inputs from step 2, and the direct-work line. The axes, finding shape, and smell baseline are `reviewing-code`'s to apply. No reviewer sees another's report. Keep all of them read-only.

Select each reviewer's model and effort through the review-routing guidance in `AGENTS.md`; an area reviewer can get a model suited to that area. Assess both the complexity of understanding the change and the consequences if something slips through. Use the actual diff, affected behavior, verification evidence and rollback constraints; line count alone is not a proxy for either. Keep cleanliness and maintainability in scope alongside correctness.

State the chosen reviewers and the reason in one short sentence, then dispatch. The user does not need to choose models or approve routine reviewer selection. Honor an explicit user override when one is supplied. Resolve supported model IDs and effort before dispatch, prefer native tools, and use `cli-subagents` only for models native tools cannot reach. If a model is unavailable, choose a supported alternative appropriate to the same work and report the substitution.

## 4. Triage: true, then worth fixing

Compile all reports into one findings list, merging duplicates. Overlap is expected, and a finding raised by more than one reviewer is corroboration.

**True.** Open every cited hunk yourself. Drop findings that don't survive contact with the code, and separate the ones you confirmed from the ones you couldn't verify. Relaying an unverified finding spends a whole fix cycle on nothing.

**Worth fixing.** A true finding is not yet a fix. Give each confirmed finding one decision, recorded with its reason:

- **Fix**: a bug, a broken project rule, a missing requirement, a scope-creep finding, or a Design finding whose fix adds no behavior and only moves, renames, splits, flattens, deletes or comments the change's own code. A bug includes a regression (an input or caller that worked before the change and now fails) and a requested behavior that fails in a state a caller hits in ordinary use, such as the states `writing-code` lists. Judge that by the outcome the ask names, not by the mechanism the change chose; the fix makes the behavior correct and adds no retries, fallbacks or UI the ask didn't name. Also a test for a required behavior or bug fix that no test exercises, written once at the cheapest level.
- **Decline**: everything else. For example: proposals that add scope (new behavior, options, fallbacks, validation that no requirement, trust boundary or correct answer needs), Optional items unless their fix deletes code, requests for extra tests of behavior that is already covered or unrequested, restructuring of code the change didn't touch, and Design fixes bigger than the code they restructure. Reviewers' Follow-ups are never fixed in this change; they go in the report.
- **Ask the user**: a choice between options that are each correct, which nobody has made, such as a retry budget, a new API argument, a stricter admission rule or a recovery policy. A bug or a goal the spec states is never a question; it is Fix. When a user can answer, ask, and leave the choice out of the fix brief. In an unattended run, make a choice a Fix item depends on yourself: the smallest option that keeps every caller working, named in the fix brief and your report. If no option keeps every caller working, report it as a blocker. Other questions go in the report.

## 5. Dispatch fixers

Before dispatching, record the pre-fix state: the `HEAD` SHA, or for uncommitted work, stage everything (`git add -A`) and record the SHA `git stash create` prints. Round 2's target is `git add -A && git diff --cached <sha>` in either case, so files a fixer created show.

Dispatch one or more fixers for the **Fix** list, in parallel when that is faster. Give each fixer its own group of findings and files, so no two fixers edit the same file. A fixer whose fix needs a file another fixer owns reports it instead of editing it. Each fixer gets `writing-code` as a path, the direct-work line, and its findings, each with its axis, its severity and the smallest complete fix you expect: one that covers every case the finding names, never a narrower one. Hand over the findings as triaged, never "fix every finding" or a reviewer's raw report.

Read each fixer's diff against the fixes you expected. A fix that grew well past its expected size gets cut back, or its extra lines justified in the report.

## 6. Repeat once at most

Round 2 reviews the fix diff only, with the same three axes. Give its reviewers the round-1 Fix list, each finding with its trigger, so they can check that each fix resolved its finding and stayed small. Fix only an unresolved round-1 finding, a bug, or a regression, scope creep or Design problem a fix introduced. The last round's fixes get no further review; list them in the report as checked only by you. Stop after 2 rounds, or the count the user set. Anything still open goes in the report as a known risk or a follow-up for the user to schedule. If findings reveal greater complexity or consequences than initially assessed, reselect reviewers through AGENTS.md for round 2. Changing models does not reset the limit.

## Reporting

Separate `## Standards`, `## Spec` and `## Design` sections. **Do not merge or rerank findings across axes.** They answer different questions, and a combined ranking hides which one failed. End each axis with its finding count and worst issue. Say so explicitly when an axis had no findings, and when the Spec axis was skipped for want of a spec, name the target that was reviewed instead. Then list the declined findings, the questions for the user, and the reviewers' Follow-ups (pre-existing bugs and design problems), merged and worst first, each in one line, and the net lines the fixes added or removed.

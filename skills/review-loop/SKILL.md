---
name: review-loop
description: Independent Claude and GPT review of a finished change, argued finding by finding with the author. Use when the user says review loop or sol loop, or when a finished change needs its independent review.
---

# Review Loop

You own the change. Two reviewers from different model families review it, because each family catches bugs the other misses. You fix what's right and push back on what's wrong. Each reviewer answers your pushback on its own findings. The loop ends when they agree or the budget runs out.

Reviewers are evidence, not orders. The argument keeps both sides honest. A reviewer that hears your reason can concede a bad finding, and pushback you got wrong gets challenged with evidence instead of quietly standing. The goal is the smallest change that meets the intent: review makes it correct, not bigger.

**The loop is one level deep.** You dispatch; reviewers and fixers are leaves. Every dispatch prompt carries `Work directly; do not delegate to other agents, subagents, or codex.` Never run this skill from inside a dispatched agent.

## 1. Pin the target

Resolve it once and give every reviewer the same command in round 1:

- **Branch:** verify `git rev-parse <base>`, then `git diff <base>...HEAD` and `git log <base>..HEAD --oneline`.
- **Commit:** `git show <sha>`.
- **Uncommitted work:** `git status --porcelain` plus `git diff HEAD`, naming untracked files.

Stop if the ref is invalid or the diff is empty.

Gather the **spec** (the user's requirements, linked issues or PRs, a spec under `docs/`, `specs/` or `.scratch/`) and the **standards** (scoped `AGENTS.md`/`CLAUDE.md`, `CONTRIBUTING.md`, `CONTEXT.md`, ADRs touching the area). With no reliable spec, tell reviewers to skip the Spec axis. Never reconstruct requirements from the implementation.

## 2. Pick the reviewers

One Claude-family and one GPT-family reviewer, each on the whole change, chosen through Review routing in `AGENTS.md`. For a large change that spans areas (server, client, migrations), give each area its own Claude and GPT pair instead.

Name them and the reason in one sentence, then dispatch. Keep the same reviewers every round unless findings show more risk than you assessed, or the user overrides the choice. Then change them as the user said, or, for risk, step that side up through Review routing; a new reviewer takes over its side's findings, and the budget doesn't reset.

Every round waits for every reviewer. Under an agent cap, run them one after another rather than dropping one.

## 3. Round 1

Dispatch every reviewer in parallel as a fresh read-only agent. Each gets `reviewing-code` as a path (`~/.claude/skills/reviewing-code/SKILL.md`), the pinned target, the spec and standards, its area if any, the direct-work line, and the closing line `End with VERDICT: approve or VERDICT: changes requested.` No reviewer sees another's report.

## 4. Triage: respond and fix

Keep a **ledger** file in a scratch directory: every finding with an ID, the reviewer that raised it, your response and its status (open, fixed, conceded by the reviewer). Merge duplicates and record both reviewers on them. The ledger is yours alone; each reviewer gets only its own rows from it (step 5).

Open every cited hunk yourself, then give each finding one response:

- **Fix** a bug, a regression, a broken project rule, a missing requirement, scope the change added that the ask didn't, or a Design finding whose fix adds no behavior and only moves, renames, splits, deletes or comments the change's own code. Name that category in the ledger; a finding that fits none of them gets pushed back. Use `writing-code`'s smallest complete fix. Add a test only for a required behavior or bug fix that nothing exercises.
- **Push back**, with the reason, on anything else: new options, fallbacks or validation nobody asked for, extra tests of covered behavior, restructuring code the change didn't touch, nits, and findings that don't survive contact with the code. Pushing back is your job; scope creep is the main way this loop goes wrong.
- **Ask the user** when the finding is a choice between options that are each correct, such as a retry budget or a new API argument. In an unattended run, take the smallest option that keeps every caller working and say so in the ledger. If none does, record it as a blocker.

Before you respond each round, record the base: the SHA from `git rev-parse HEAD`, or for uncommitted work the SHA that `git add -A && git stash create` prints. The next round's diff is `git add -A && git diff --cached <base>`, so new files show. A round where you only pushed back sends an empty diff with your responses.

Make the fixes yourself. On a large change you may hand fixes to fixers, one per group of files so no two touch the same file, each with `writing-code` as a path. You still own every response. A reviewer never fixes its own findings.

When a fix breaks an earlier fix in the same mechanism, stop patching it. Rethink that mechanism's design, record the decision in the ledger, and send the redesign through the next round.

## 5. Later rounds

Dispatch each reviewer again in parallel, as in step 3, with the diff since the recorded base as its target. Each also gets a file holding only the findings it raised, copied from the ledger with your response to each. It answers every one on its own line: `<ID> accepted` for a fix, `<ID> conceded` for your pushback, or `<ID> held: <evidence>`. Evidence is a file and line, a failing input, a caller that breaks; repeating the original claim is not evidence. It may also raise new problems in the fix diff. A held item stays open, and you respond to it as in step 4. A finding both reviewers raised closes when neither still holds it.

Keep arguing a held finding round by round until you and its reviewer agree. Evidence breaks a tie, never the user: a held finding backed by a failing test, a reproduction or a caller that breaks gets fixed; one without stays pushed back, with both positions in the report.

## 6. Stop

- **Budget:** 3 rounds, or the count the user set. Extend to 5 only when open findings touch auth, permissions, secrets, security or data loss. Every dispatch of a reviewer counts toward it, whatever you call it: a recheck or a quick final check is a round.
- **Stop early** when every reviewer approves, or a round raises only nits.
- **At the budget,** settle each open finding by evidence as in step 5 and record both positions in one line each; don't fix just to end the argument. A fix made after the last round is checked only by you; say so in the report.

## 7. Report

Report the reviewers, rounds run, each reviewer's final verdict, the last commit any reviewer saw and the final commit, findings fixed, pushback conceded, items still disputed with both positions, and the reviewers' Follow-ups, merged. Include the net lines the fixes added or removed, leaving out committed evidence such as logs and screenshots.

When you file or update a PR for this change, end its description with:

```
Reviewed with review loop: <reviewer models>, <n> rounds, last reviewed <sha>, final <sha>, verdicts: <reviewer: approved | changes requested, ...>
<one line per disputed item, if any>
```

State a verdict that isn't approve exactly as it is.

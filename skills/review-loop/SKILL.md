---
name: review-loop
description: Two reviewers from different model families review a finished change, then argue their findings with you round by round until you agree or the budget ends. Use when the user says review loop or sol loop, or when a finished change needs its independent review.
---

# Review Loop

You own the change. Two reviewers from different model families review it, because each family catches bugs the other misses. You fix what's right and push back on what's wrong. Each reviewer answers your pushback on its own findings. The loop ends when they agree or the budget runs out.

Reviewers are evidence, not orders. The argument keeps both sides honest. A reviewer that hears your reason can concede a bad finding, and a decline you got wrong gets challenged with evidence instead of quietly standing. The goal is the smallest change that meets the intent: review makes it correct, not bigger.

**The loop is one level deep.** You dispatch; reviewers and fixers are leaves. Every dispatch prompt carries `Work directly; do not delegate to other agents, subagents, or codex.` Never run this skill from inside a dispatched agent.

## 1. Pin the target

Resolve it once and give every reviewer the same command every round:

- **Branch:** verify `git rev-parse <base>`, then `git diff <base>...HEAD` and `git log <base>..HEAD --oneline`.
- **Commit:** `git show <sha>`.
- **Uncommitted work:** `git status --porcelain` plus `git diff HEAD`, naming untracked files.

Stop if the ref is invalid or the diff is empty.

Gather the **spec** (the user's requirements, linked issues or PRs, a spec under `docs/`, `specs/` or `.scratch/`) and the **standards** (scoped `AGENTS.md`/`CLAUDE.md`, `CONTRIBUTING.md`, `CONTEXT.md`, ADRs touching the area). With no reliable spec, tell reviewers to skip the Spec axis. Never reconstruct requirements from the implementation.

## 2. Pick the reviewers

One Claude-family and one GPT-family reviewer, each on the whole change, chosen through Review routing in `AGENTS.md`. For a large change that spans areas (server, client, migrations), give each area its own Claude and GPT pair instead.

Keep the same reviewers for every round. Name them and the reason in one sentence, then dispatch.

## 3. Round 1

Dispatch every reviewer in parallel as a fresh read-only agent (in T3 Code, one `delegate_task` each with its own `clientRequestId`). Each gets `reviewing-code` as a path (`~/.claude/skills/reviewing-code/SKILL.md`), the pinned target, the spec and standards, its area if any, the direct-work line, and the closing line `End with VERDICT: approve or VERDICT: changes requested.` No reviewer sees another's report.

## 4. Respond and fix

Keep a **ledger** file in a scratch directory: every finding with an ID, the reviewer that raised it, your response and its status (open, fixed, conceded, withdrawn). Merge duplicates and record both reviewers on them.

Open every cited hunk yourself, then give each finding one response:

- **Fix** a bug, a regression, a broken project rule, a missing requirement, or scope the change added that the ask didn't. Use `writing-code`'s smallest complete fix. Add a test only for a required behavior or bug fix that nothing exercises.
- **Push back**, with the reason, on anything else: new options, fallbacks or validation nobody asked for, extra tests of covered behavior, restructuring code the change didn't touch, nits, comment-only and doc-only findings, and findings that don't survive contact with the code. Pushing back is your job; scope creep is the main way this loop goes wrong.
- **Ask the user** when the finding is a choice between options that are each correct, such as a retry budget or a new API argument. In an unattended run, take the smallest option that keeps every caller working and say so in the ledger.

Make the fixes yourself. On a large change you may hand fixes to fixers, one per group of files so no two touch the same file, each with `writing-code` as a path. You still own every response. A reviewer never fixes its own findings.

## 5. Later rounds

Dispatch each reviewer again in parallel as a fresh agent. Each gets the diff since the last round, the ledger path, and the findings it raised. For each of its findings it accepts the fix, concedes your pushback, or holds its position with new evidence: a file and line, a failing input, a caller that breaks. Repeating the original claim is not evidence. It may also raise new problems in the fix diff. A held item stays open, and you respond to it as in step 4. A finding both reviewers raised closes when either accepts it.

## 6. Stop

- **Budget:** 3 rounds. Extend to 5 only when open findings touch auth, permissions, secrets, security or data loss.
- **Stop early** when every reviewer approves, or a round raises only nits.
- **At the budget,** whatever is still open stays open. Record both positions in one line each; don't fix just to end the argument.

## 7. Report

Report the reviewers, rounds run, each reviewer's final verdict, findings fixed, pushback conceded, and items still disputed with both positions. Include the net lines the fixes added or removed.

When you file or update a PR for this change, end its description with:

```
Reviewed with review loop: <reviewer models>, <n> rounds, verdicts: <model: approved | changes requested, ...>
<one line per disputed item, if any>
```

State a verdict that isn't approve exactly as it is.

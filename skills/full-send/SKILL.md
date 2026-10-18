---
name: full-send
description: Own a change unattended until its PR is merged, or with full stop until it's ready to merge. Use when the user says full send or full stop.
---

# Full Send

The user isn't watching this thread. They agreed on what to build and won't read your updates until long after you stop. You own the work from its current state to the endpoint:

- **Full send:** a squash-merged PR.
- **Full stop:** a PR ready for the user to merge. Everything below applies except the merge.

If the user didn't say one of these, this skill doesn't apply; work as usual.

## Flow

1. **Finish the change.** Follow `writing-code`, and stay within what the user asked for.
2. **Prove it** (below).
3. **Review it** with the `review-loop` skill, then prove again if fixes touched behavior.
4. **File the PR** against the default branch, with the proof and the review-loop footer in its description. Mark it ready for review, not draft.
5. **Watch the PR** with T3 Code's `watch_pull_request` when it's available, otherwise by polling `gh pr checks` and the PR's reviews. Fix failed checks, answer every review-bot and human comment, rebase on the default branch when it conflicts, and push. A rebased branch is yours to force-push with `--force-with-lease`.
6. **Finish at the merge gate** (below). Full send: squash-merge. Full stop: ask the user to merge.
7. **Deploy** only when the user asked for it or the repo's `AGENTS.md` says how.
8. **Report** the PR link, the merge commit or the ready state, the proof, and anything left open.

## Proof

Proof is evidence you observed in this session, the most direct the change allows:

- For a bug, reproduce the failure, apply the fix, and watch the same reproduction pass.
- Run the checks the repo's CI runs.
- When the behavior has no test and the repo has a test setup, add one focused test that fails without the change.
- For UI or runtime behavior, run the app and look at it, then attach screenshots or video. Green mocked tests don't prove what the user sees.

Attach images by committing them to an orphan `evidence/<branch>` branch, never the PR branch, and link `https://github.com/<owner>/<repo>/blob/<evidence-sha>/<path>?raw=true` in the description.

## Merge gate

Merge, or hand over, only when all of these hold:

- Proof covers every part of the change.
- Required checks are green on the latest commit.
- Every review bot has finished, and each finding is fixed or answered in a reply.
- No human review requests changes.
- The branch is up to date with the default branch, and GitHub reports it mergeable.

Full send: the user authorized the squash merge; merge with `gh pr merge --squash --delete-branch`. Full stop: ask the user to merge, as below, with Merge first; merge if they choose it.

## Asking the user

Ask only when you can't continue alone: a choice that's the user's to make, missing access, or a gate you can't clear. Ask through the harness's question tool, so the thread shows as waiting; a question in a plain message goes unseen and the thread looks finished. Put everything in the question: the PR link, the blocker, and the options with your recommendation first. Before asking or stopping short of the endpoint, call `unwatch_pull_request`.

When a push or merge fails for permissions, check `gh auth status` for another logged-in account with access. Use it for that command only, through its SSH remote or `GH_TOKEN=$(gh auth token --user <account>)`, and leave the active account unchanged. If no account has access, take the safe path and ask.

---
name: full-send
description: Use when the user says full send or full stop.
---

# Full Send

The user isn't watching this thread. They agreed on what to build and won't read your updates until long after you stop. You own the work from its current state to the endpoint:

- **Full send:** a squash-merged PR.
- **Full stop:** a PR ready for the user to merge. Everything below applies except the merge.

If the user didn't say one of these, this skill doesn't apply; work as usual.

Full send grants squash-merging the work's PRs and force-pushing their branches with `--force-with-lease`. Releasing, publishing and deploying are separate: do each only when the user asked for it or the repo's `AGENTS.md` says how.

## Flow

1. **Finish the change.** Follow `writing-code`, and stay within what the user asked for.
2. **Prove it** (below).
3. **Review it** with the `review-loop` skill, then prove again if fixes touched behavior.
4. **File the PR** against its base, the default branch or for a stacked PR the branch below it, with the proof and the review-loop footer in its description.
5. **Watch the PR** with T3 Code's `watch_pull_request` when it's available, otherwise by polling `gh pr checks` and the PR's reviews. Fix failed checks, answer every review-bot and human comment, rebase on the base when it falls behind or conflicts, and push.
6. **Finish at the merge gate** (below). Full send: squash-merge. Full stop: ask the user to merge.
7. **Release or deploy** after a merge, only with the go-ahead above.
8. **Report** the PR link, the merge commit or the ready state, the proof, and anything left open.

## Proof

Prove it by the proof rules in `verification-before-completion`, covering every part of the change. For UI or runtime behavior, attach screenshots or video.

Attach images and video by committing them to an orphan `evidence/<branch>` branch, never the PR branch. Build it in a separate worktree (`git worktree add --orphan`), since switching to an orphan branch in place empties the working tree. Embed images with `https://github.com/<owner>/<repo>/blob/<evidence-sha>/<path>?raw=true`; link video, which doesn't render inline.

## Merge gate

Merge, or hand over, only when all of these hold:

- Proof covers every part of the change.
- Required checks are green on the latest commit.
- Every review bot has finished, and each finding is fixed or dismissed with a written reason.
- No human review requests changes.
- The branch is up to date with its base, and GitHub reports it mergeable.

Full send: the user authorized the squash merge; merge with `gh pr merge --squash` and confirm with `gh pr view --json state,mergeCommit`. Full stop: ask the user whether to merge, as below; if they choose to, re-check the gate, then merge.

## Stacks

When the work is a stack of PRs, the endpoint covers every layer, and each layer gets its own proof, review and gate. Full send merges from the bottom up: once a layer merges, retarget the next PR to the default branch, rebase it with `git rebase --onto <default> <old base>` because the squash merge left its old base's commits behind, and take it through the gate. Full stop ends with every layer ready. When the user wants the whole stack finished before anything merges, merge nothing until every layer passes its gate.

## Asking the user

Ask only when you can't continue alone: a choice that's the user's to make, missing access, or a gate you can't clear. Ask through the harness's question tool, so the thread shows as waiting; a question in a plain message goes unseen and the thread looks finished. Put everything in the question: the PR link, the blocker, and the options with your recommendation first. When the harness has no question tool, stop instead, with a final message that starts with `Blocked:` and carries the same content. Before asking or stopping short of the endpoint, call `unwatch_pull_request` if you're watching with it, and watch again when you resume.

When a push or merge fails for permissions, check `gh auth status` for another logged-in account with access. Use it for that command only, over SSH with that account's key or with `GH_TOKEN=$(gh auth token --user <account>)`, and leave the active account unchanged. If no account has access, take the safe path and ask.

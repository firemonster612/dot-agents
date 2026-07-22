---
name: finishing-a-development-branch
description: Use when implementation on a branch is complete and the work needs to be integrated — merge, PR, keep, or discard — including any worktree cleanup.
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling the chosen workflow.

**Core principle:** Verify tests → Detect environment → Present options → Execute choice → Clean up.

## The Process

### Step 1: Verify Tests

Before presenting options, run the project's test suite and read the output yourself — a passing exit code is not evidence until you have read what actually ran (see `verification-before-completion`).

**If tests fail:** show the failures and stop — no merge/PR until they pass.

### Step 2: Detect Environment

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

| State | Menu | Cleanup |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON` (normal repo) | Standard 4 options | No worktree to clean up |
| `GIT_DIR != GIT_COMMON`, named branch | Standard 4 options | Provenance-based (Step 6) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | Reduced 3 options (no local merge) | None (externally managed) |

### Step 3: Determine Base Branch

```bash
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main — is that correct?"

### Step 4: Present Options

**Normal repo and named-branch worktree — exactly these 4 options:**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Detached HEAD — exactly these 3 options:**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)
3. Discard this work

Which option?
```

Keep the options concise — don't add explanation.

### Step 5: Execute Choice

#### Option 1: Merge Locally

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# Merge first — verify success before removing anything
git checkout <base-branch>
git pull
git merge <feature-branch>

# Verify tests on the merged result
<test command>
```

Only after the merge succeeds: clean up the worktree (Step 6), then `git branch -d <feature-branch>`.

#### Option 2: Push and Create PR

```bash
git push -u origin <feature-branch>
```

Do NOT clean up the worktree — it's needed to iterate on PR feedback.

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>." No cleanup.

#### Option 4: Discard

**Confirm first:**

```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for the exact confirmation. If confirmed: `cd` to the main repo root, clean up the worktree (Step 6), then `git branch -D <feature-branch>`.

### Step 6: Cleanup Workspace

**Only runs for Options 1 and 4.** Options 2 and 3 always preserve the worktree.

- **Normal repo** (`GIT_DIR == GIT_COMMON`): nothing to clean up.
- **Harness-managed worktree** (created by a native tool such as `EnterWorktree` / an isolation param): use the harness's exit tool (`ExitWorktree`) or leave it — the harness owns cleanup. Do NOT `git worktree remove` it; that creates phantom state the harness can't see.
- **Manually created worktree** (under `.worktrees/` or `worktrees/` — created by a git-fallback flow we own):

  ```bash
  MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
  cd "$MAIN_ROOT"
  git worktree remove "$WORKTREE_PATH"
  git worktree prune
  ```

## Quick Reference

| Option | Merge | Push | Keep Worktree | Delete Branch |
|--------|-------|------|---------------|---------------|
| 1. Merge locally | yes | - | - | yes |
| 2. Create PR | - | yes | yes | - |
| 3. Keep as-is | - | - | yes | - |
| 4. Discard | - | - | - | yes (force) |

## Common Mistakes

- **Skipping test verification** → merging broken code. Always verify first.
- **Open-ended "what next?"** → present the exact numbered menu instead.
- **Cleaning up the worktree for Option 2** → the user needs it for PR iteration.
- **Deleting the branch before removing the worktree** → `git branch -d` fails while the worktree references it. Merge, remove worktree, then delete branch.
- **Running `git worktree remove` from inside the worktree** → fails; `cd` to the main repo root first.
- **Cleaning up a harness-owned worktree** → phantom state. Only remove worktrees created by a manual git-fallback flow.
- **No confirmation for discard** → accidental data loss. Require the typed "discard".

---

> Adapted from [obra/superpowers](https://github.com/obra/superpowers) (MIT).

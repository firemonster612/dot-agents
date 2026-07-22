---
name: codex-review
description: Use when the user asks to have Codex or GPT review work, when the model-selection rubric calls for a GPT review perspective, or when a change should be audited against its requirements by an independent GPT reviewer. Covers uncommitted changes, branch diffs, commits, or a specific implementation. For a review by the current agent itself, use the normal review process instead.
---

# Codex Review

**If Codex/GPT models are available as native subagents, use two native GPT subagents in parallel. Do not use the CLI.** The CLI instructions below are for agents that can only shell out, or wrapper subagents whose job is to run Codex.

**Follow the `review-core` skill for the process: target pinning, spec and standards discovery, the smell baseline, the two parallel reviewers, and aggregation.** Everything below is specific to the Codex CLI.

## Codex CLI invocation

Create a temporary artifact directory with separate prompts and reports. Pick one target selector and use it unchanged for both axes:

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-review.XXXXXX")"

# Choose exactly one:
TARGET_ARGS=(--uncommitted)
# TARGET_ARGS=(--base main)
# TARGET_ARGS=(--commit <sha>)

codex -C "$REPO" review "${TARGET_ARGS[@]}" - \
  < "$ARTIFACT_DIR/standards-prompt.md" \
  > "$ARTIFACT_DIR/standards-report.md" \
  2> "$ARTIFACT_DIR/standards.stderr.log" &
STANDARDS_PID=$!

# Start this only when a spec exists.
codex -C "$REPO" review "${TARGET_ARGS[@]}" - \
  < "$ARTIFACT_DIR/spec-prompt.md" \
  > "$ARTIFACT_DIR/spec-report.md" \
  2> "$ARTIFACT_DIR/spec.stderr.log" &
SPEC_PID=$!

wait "$STANDARDS_PID"
wait "$SPEC_PID"
```

## CLI edge cases

- Always feed prompts on stdin and ensure stdin reaches EOF. Avoid background processes with inherited stdin; use `</dev/null` only when no prompt stream is required.
- Run inside a Git repository or pass `-C <repo>`; use `--skip-git-repo-check` only for deliberate non-repository work.
- Keep stdout and stderr separate, inspect both exit codes, and poll artifact files when reviews can exceed the shell timeout.

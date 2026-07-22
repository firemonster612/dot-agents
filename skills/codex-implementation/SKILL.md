---
name: codex-implementation
description: Use when the user asks to delegate implementation to Codex or gpt, when the model-selection rubric routes the work to gpt, or when a bounded task would benefit from another coding agent producing a patch. This is how gpt is invoked for implementation work.
---

# Codex Implementation

**If you already have access to Codex/GPT models via subagents — meaning you do not need the CLI — use the subagents. Do not use the CLI.** The CLI instructions below are for agents that can only shell out, or for wrapper subagents whose job is to run the CLI.

**Follow the `implement-core` skill for the shared contract: the scoping workflow, the prompt requirements, and the post-run review.** Everything below is specific to the Codex CLI.

## Command shape

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-implementation.XXXXXX")"
REPORT="$ARTIFACT_DIR/report.md"
PROMPT="$ARTIFACT_DIR/prompt.md"

# Write a self-contained prompt to $PROMPT (per implement-core), then run:
codex exec \
  -C "$PWD" \
  --add-dir "$ARTIFACT_DIR" \
  -s workspace-write \
  -o "$REPORT" \
  - < "$PROMPT"
```

Pick the GPT-5.6 tier with `-m` per the model rubric (Luna for mechanical work, Terra for ordinary implementation, Sol for hard or long-running work).

## Sandboxing

Use `-s workspace-write` by default. Use `-s danger-full-access` only when the implementation truly needs access outside the repo, app launch automation, simulator work, package manager global state, or other machine-level operations.

## CLI Edge Cases

- Always feed `codex exec` prompts on stdin and ensure stdin reaches EOF before expecting Codex to start. Avoid passing large prompts as shell arguments or launching background Codex processes with inherited stdin. If running Codex without a prompt stream, redirect stdin from `</dev/null`.
- Run from inside a git repo or pass `-C <repo>`; use `--skip-git-repo-check` only for deliberate non-repo work.
- Long runs can exceed your shell's command timeout: pass an explicit timeout, or run in the background and poll for `$REPORT`.

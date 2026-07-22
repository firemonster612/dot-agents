---
name: codex-implementation
description: Use when the user asks to delegate implementation to Codex or gpt, when the model-selection rubric routes the work to gpt, or when a bounded task would benefit from another coding agent producing a patch. This is how gpt is invoked for implementation work.
---

# Codex Implementation

**If you already have access to Codex/GPT models via subagents — meaning you do not need the CLI — use the subagents. Do not use the CLI.** The CLI instructions below are for agents that can only shell out, or for wrapper subagents whose job is to run the CLI.

Use Codex as a separate implementation agent for bounded code changes. Claude remains responsible for scoping the task, reviewing the diff, running or checking verification, and explaining the final result.

Use this when the user asks for Codex or delegation, or when a bounded task would benefit from a parallel implementation agent producing a patch. Do not let Codex commit, push, deploy, or edit global config unless the user explicitly asked for that.

## Workflow

1. Pin the current state with `git status --short` and note any user changes already present.
2. Define the implementation scope: files or behavior to change, files to avoid, constraints, and verification commands.
3. Create a temporary artifact directory for Codex's report.
4. Run `codex exec` with repo write access.
5. After Codex exits, inspect `git status` and `git diff`.
6. Run the cheapest reliable verification yourself when practical.
7. Report what Codex changed, what Claude verified, and any remaining risks.

Use this command shape:

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-implementation.XXXXXX")"
REPORT="$ARTIFACT_DIR/report.md"
PROMPT="$ARTIFACT_DIR/prompt.md"

# Write a self-contained prompt to $PROMPT, then run:
codex exec \
  -C "$PWD" \
  --add-dir "$ARTIFACT_DIR" \
  -s workspace-write \
  -o "$REPORT" \
  - < "$PROMPT"
```

Use `-s workspace-write` by default. Use `-s danger-full-access` only when the implementation truly needs access outside the repo, app launch automation, simulator work, package manager global state, or other machine-level operations.

Always feed `codex exec` prompts on stdin and ensure stdin reaches EOF before expecting Codex to start. Avoid passing large prompts as shell arguments or launching background Codex processes with inherited stdin. If running Codex without a prompt stream, redirect stdin from `</dev/null>`. Run from inside a git repo or pass `-C <repo>`; use `--skip-git-repo-check` only for deliberate non-repo work.

## Prompt Requirements

Tell Codex:

- The exact implementation goal and acceptance criteria.
- The repo path and current branch context if relevant.
- Which existing patterns, files, or tests to inspect first.
- Files or behavior that must not be changed.
- That it must preserve unrelated user changes.
- That it must not commit, push, deploy, or edit global config.
- Where a test framework exists: to write a failing test that specifies the change before implementing, and include the red→green evidence (both runs) in the report.
- Which verification commands to run, or to explain why they were skipped.
- To write a concise final report with files changed, verification, and unresolved questions.

Keep the task bounded. If the requested work bundles several substantial changes, split it into separate Codex runs or ask the user to choose the first scope.

## Example Prompt

```text
You are implementing a scoped change.

Repository: /absolute/path/to/repo
Artifact directory: /tmp/codex-implementation.XXXXXX

Goal:
- Add keyboard navigation to the command palette.

Acceptance criteria:
- ArrowUp and ArrowDown move the highlighted item.

Report:
- Files changed
- Behavioral summary
- Verification run and result
- Anything blocked or uncertain
```

## Review After Codex

Always inspect Codex's diff before telling the user the work is done. Revert only Codex-created mistakes when you are sure they are not user changes. If Codex leaves the repo in a worse state or changes unrelated files, stop and report the issue with the diff summary.

If `codex` is not installed or the command fails, report the error and offer to implement the change directly instead.

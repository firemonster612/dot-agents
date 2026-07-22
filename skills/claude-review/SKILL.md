---
name: claude-review
description: Use when the user asks to have Claude review work, when the model-selection rubric calls for a Claude review perspective, or when a change should be audited against its requirements by an independent Claude reviewer. Covers uncommitted changes, branch diffs, commits, or a specific implementation. For a review by the current agent itself, use the normal review process instead.
---

# Claude Review

**If Claude models are available as native subagents, use two native Claude subagents in parallel. Do not use the CLI.** The CLI instructions below are for agents, such as Codex, that can only shell out.

**Follow the `review-core` skill for the process: target pinning, spec and standards discovery, the smell baseline, the two parallel reviewers, and aggregation.** Everything below is specific to the Claude CLI.

## Claude CLI invocation

Create separate prompts, results, and stderr logs for each axis. Run from inside the repository; `claude` has no `-C` flag.

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/claude-review.XXXXXX")"

run_claude_review() {
  claude -p \
    --model opus --effort high \
    --output-format json \
    --no-session-persistence \
    --permission-mode dontAsk \
    --disallowedTools "Edit,Write,NotebookEdit" \
    --allowedTools "Bash(git diff *),Bash(git log *),Bash(git show *),Bash(git status *),Bash(git rev-parse *)" \
    --strict-mcp-config \
    < "$1" > "$2" 2> "$3"
}

(cd "$REPO" && run_claude_review "$ARTIFACT_DIR/standards-prompt.md" "$ARTIFACT_DIR/standards.json" "$ARTIFACT_DIR/standards.stderr.log") &
STANDARDS_PID=$!

# Start this only when a spec exists.
(cd "$REPO" && run_claude_review "$ARTIFACT_DIR/spec-prompt.md" "$ARTIFACT_DIR/spec.json" "$ARTIFACT_DIR/spec.stderr.log") &
SPEC_PID=$!

wait "$STANDARDS_PID"
wait "$SPEC_PID"

jq -r '.result' "$ARTIFACT_DIR/standards.json" > "$ARTIFACT_DIR/standards-report.md"
jq -r '.result' "$ARTIFACT_DIR/spec.json" > "$ARTIFACT_DIR/spec-report.md"
jq '{is_error, num_turns, total_cost_usd, permission_denials}' "$ARTIFACT_DIR/standards.json"
jq '{is_error, num_turns, total_cost_usd, permission_denials}' "$ARTIFACT_DIR/spec.json"
```

## Model choice

- Always pass `--model` explicitly; otherwise the run inherits the machine's default.
- Use `--model opus --effort high` by default, `--model fable --effort high` for the hardest ambiguous reviews, and `--model sonnet --effort medium` for a quick sanity pass. Never use Haiku.
- Claude tokens cost money. Use `--max-budget-usd <n>` as a guard for large reviews and inspect `total_cost_usd` in each result envelope.

## CLI edge cases

- Silence is normal. Text and JSON output appear only when the run finishes. For progress, use `--output-format stream-json --verbose --include-partial-messages`, or run in the background and poll the result files.
- Claude waits for stdin EOF. Feed each prompt on stdin; if there is no prompt stream, use `</dev/null`. Piped stdin is capped at 10 MB.
- Keep stdout and stderr separate so shell noise cannot corrupt the JSON envelope.
- Check the process exit code plus `.is_error` and `.permission_denials`; exit code zero alone is insufficient.
- Headless mode loads user/project settings, `CLAUDE.md`, hooks, and MCP servers. The explicit permission flags and `--strict-mcp-config` keep the run deterministic and read-only.
- Global instructions may tell Claude to delegate. The prompt's direct-work instruction (from `review-core`) prevents recursive delegation — never omit it.
- Do not use `--bare`: it drops subscription/keychain auth and requires `ANTHROPIC_API_KEY`.
- `-p` skips workspace trust and ignores invalid settings files, so run it only in trusted repositories.
- Authentication uses the machine's credentials. Report missing or expired auth instead of retrying; a stale `ANTHROPIC_API_KEY` can override subscription auth.
- Long reviews may exceed shell timeouts. Keep them in the background and poll their artifacts.
- For follow-ups, omit `--no-session-persistence`, capture `.session_id`, and resume with `claude -p --resume <session-id>` while re-passing all permission flags.

---
name: claude-implement
description: Use when the user asks to delegate implementation to Claude, when the model-selection rubric routes the work to a Claude model, or when a bounded task would benefit from another coding agent producing a patch. This is how Claude is invoked for implementation work from a CLI-only agent such as Codex.
---

# Claude Implement

**If you already have access to Claude models via subagents — meaning you do not need the CLI (for example, you are running in Claude Code, where Agent/Workflow spawn Claude subagents natively) — use the subagents. Do not use the CLI.** The CLI instructions below are for agents, such as Codex, that can only shell out.

**Follow the `implement-core` skill for the shared contract: the scoping workflow, the prompt requirements, and the post-run review.** Everything below is specific to the Claude CLI.

## Command shape (verified)

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/claude-implement.XXXXXX")"
PROMPT="$ARTIFACT_DIR/prompt.md"
RESULT="$ARTIFACT_DIR/result.json"
REPORT="$ARTIFACT_DIR/report.md"

# Write a self-contained prompt to $PROMPT (per implement-core), then run FROM INSIDE THE REPO
# (there is no -C flag; claude uses the shell's cwd):
cd "$REPO" && claude -p \
  --model sonnet --effort medium \
  --output-format json \
  --permission-mode acceptEdits \
  --allowedTools "Bash(git diff *),Bash(git status *),Bash(pnpm *),Bash(bun *)" \
  --strict-mcp-config \
  --max-budget-usd 10 \
  < "$PROMPT" > "$RESULT" 2> "$ARTIFACT_DIR/stderr.log"

jq -r '.result' "$RESULT" > "$REPORT"
jq '{is_error, num_turns, total_cost_usd, session_id, permission_denials}' "$RESULT"
```

## Permissions

- `--permission-mode acceptEdits` auto-approves file reads, edits, and safe filesystem commands, but Bash commands still need `--allowedTools` entries. Tailor the `Bash(...)` patterns to the task's actual verification commands (test runner, build, linter); prefix-match with a trailing `*` like `Bash(pnpm *)`.
- If the run finishes with entries in `.permission_denials`, the allowlist was too narrow: expand it and resume the same session (see edge cases) instead of restarting from scratch.
- Use `--dangerously-skip-permissions` instead of the allowlist only when the task truly needs broad machine access — package-manager global state, launching apps, work outside the repo — and only in repos/machines you trust. It is refused when running as root.

## Model Choice

- **Always pass `--model` explicitly.** Without it, the run inherits the machine's default model from user settings — often an expensive high-context configuration.
- Per the model rubric: `--model sonnet --effort medium` for ordinary bounded implementation, `--model sonnet --effort high` for sustained or messy work, `--model opus --effort high` or `--model fable` for judgment-heavy, ambiguous, or user-facing work (taste). Never haiku.
- Claude tokens cost real money (unlike Codex). Keep `--max-budget-usd` as a runaway guard and report `total_cost_usd` when relevant.

## CLI Edge Cases

- **Silence is normal, not a hang.** With `--output-format text` or `json`, `claude -p` prints NOTHING until the entire run finishes — implementation runs can be silently busy for many minutes. Do not kill the process or conclude it is stuck. For live progress, add `--output-format stream-json --verbose --include-partial-messages` and tail the event stream, or run in the background (`nohup ... &`) and poll for `$RESULT` while watching `git status` for file changes.
- Feed the prompt on stdin (`< "$PROMPT"`) or as an argument. Claude waits for stdin EOF before starting — a background shell holding stdin open hangs it; use `</dev/null` when there is no prompt stream. Empty stdin with no prompt argument exits 1 with "Input must be provided". Piped stdin is capped at 10MB.
- Keep stdout and stderr separate: the JSON envelope goes to stdout, but shell-init noise and errors go to stderr and will corrupt the JSON if merged.
- Exit code 0 on success, non-zero with the message on stderr on failure. Also check `.is_error` and `.permission_denials` — a "successful" exit can still be a run that got blocked and gave up.
- Headless mode loads the machine's user/project settings, CLAUDE.md files, hooks, and MCP servers, so default behavior varies per machine. The explicit flags above make runs deterministic; `--strict-mcp-config` keeps unrelated MCP servers out of the session. Without `--permission-mode`, recent versions use an "auto" classifier that is nondeterministic and aborts after repeated blocks.
- The machine's global CLAUDE.md may instruct Claude to orchestrate or delegate work to other agents (including Codex). The prompt's "work directly; do not delegate" line (from `implement-core`) prevents recursion — never omit it.
- Do NOT use `--bare` to isolate settings: it drops OAuth/keychain auth and only accepts `ANTHROPIC_API_KEY`, which breaks subscription-authenticated machines.
- `-p` skips the workspace trust dialog and silently ignores invalid settings files — only run it in repos you trust.
- Auth uses the machine's logged-in credentials. "Not logged in" means credentials are missing/expired — report it, don't retry. A stale `ANTHROPIC_API_KEY` env var silently overrides subscription auth.
- Long runs can exceed your shell's command timeout. Run in the background writing to `$RESULT`, then poll for the file.
- Iterating on the same task: sessions persist by default. Capture `.session_id` from the envelope and continue with `claude -p --resume <session-id> "fix the failing test" ...` — the delegate keeps its context. Re-pass the same permission and model flags; they are per-invocation, not per-session.
- `--add-dir <path>` grants access to directories outside the repo (e.g. a fixtures directory) without widening permissions elsewhere.

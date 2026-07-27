---
name: cli-subagents
description: How to spawn a Codex or Claude subagent by shelling out — command shapes, permissions, model flags, and the gotchas that make CLI runs look broken when they aren't. Use only when you have no native subagent primitive; covers both implementation and review delegates.
---

# CLI Subagents

**If you can spawn subagents natively, do that instead.** In Claude Code, `Agent` and `Workflow` spawn Claude subagents directly, and native GPT subagents (where available) beat shelling out. This skill is for agents that can only reach another model through a shell — Codex calling Claude, Claude calling Codex, or a thin wrapper agent whose whole job is to run a CLI.

Transport only. What the delegate should *do* lives in `writing-code` and `reviewing-code`.

## Every dispatch, regardless of CLI

1. **Make an artifact directory** and keep the prompt, the report, and stderr in separate files there.
2. **Write the prompt to a file and feed it on stdin.** Never paste a large prompt as a shell argument.
3. **Hand skills as paths, not pasted text.** A CLI delegate can read files: point it at `~/.claude/skills/writing-code/SKILL.md` or `~/.claude/skills/reviewing-code/SKILL.md` and tell it to read that first. Pasting the contract into every prompt is how the contract drifts.
4. **Include the direct-work line:** `Work directly; do not delegate to other agents, subagents, or codex.` A delegate that reads the machine's global instructions may otherwise try to re-delegate your task.
5. **Pass the model explicitly** per the rubric in `AGENTS.md`. Without it, the run inherits whatever the machine's default is — often an expensive configuration.
6. **Give the delegate its target and its scope**: the repo path, the diff or ref under review, the files it may change, and the verification commands to run.

Parallel implementers in one checkout will collide. Give each its own worktree, or run them one at a time.

## Codex

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-delegate.XXXXXX")"

# Implementation — writes to the repo:
codex exec -m <tier> -C "$REPO" --add-dir "$ARTIFACT_DIR" \
  -s workspace-write -o "$ARTIFACT_DIR/report.md" \
  - < "$ARTIFACT_DIR/prompt.md"

# Review — pick exactly one target selector and reuse it across reviewers:
codex -C "$REPO" review --base main - \
  < "$ARTIFACT_DIR/prompt.md" > "$ARTIFACT_DIR/report.md" 2> "$ARTIFACT_DIR/stderr.log"
#            --uncommitted | --commit <sha>
```

- `-m` picks the tier: Luna for mechanical work, Terra for ordinary implementation, Sol for hard or long-running work.
- `-s workspace-write` by default. `-s danger-full-access` only when the work genuinely needs outside-the-repo access — app launch automation, simulators, global package state.
- Run inside a git repo or pass `-C <repo>`; `--skip-git-repo-check` only for deliberate non-repo work.
- Codex runs don't cost tokens you pay for, so prefer Codex for exploratory or bulk delegation.

## Claude

`claude` has no `-C` flag — it uses the shell's cwd, so run it from inside the repo.

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/claude-delegate.XXXXXX")"

# Implementation:
cd "$REPO" && claude -p \
  --model sonnet --effort medium \
  --output-format json --permission-mode acceptEdits \
  --allowedTools "Bash(git diff *),Bash(git status *),Bash(pnpm *),Bash(bun *)" \
  --strict-mcp-config --max-budget-usd 10 \
  < "$ARTIFACT_DIR/prompt.md" > "$ARTIFACT_DIR/result.json" 2> "$ARTIFACT_DIR/stderr.log"

# Review — read-only, so deny the edit tools outright:
cd "$REPO" && claude -p \
  --model opus --effort high \
  --output-format json --no-session-persistence --permission-mode dontAsk \
  --disallowedTools "Edit,Write,NotebookEdit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git show *),Bash(git status *),Bash(git rev-parse *)" \
  --strict-mcp-config \
  < "$ARTIFACT_DIR/prompt.md" > "$ARTIFACT_DIR/result.json" 2> "$ARTIFACT_DIR/stderr.log"

jq -r '.result' "$ARTIFACT_DIR/result.json" > "$ARTIFACT_DIR/report.md"
jq '{is_error, num_turns, total_cost_usd, session_id, permission_denials}' "$ARTIFACT_DIR/result.json"
```

- **Permissions:** `acceptEdits` auto-approves reads, edits, and safe filesystem commands, but Bash still needs `--allowedTools` entries — tailor the `Bash(...)` prefixes to the task's actual test/build/lint commands. Entries in `.permission_denials` mean the allowlist was too narrow: widen it and resume the session rather than restarting. Use `--dangerously-skip-permissions` only for work that truly needs broad machine access, in repos you trust; it's refused as root.
- **Model:** `sonnet --effort medium` for ordinary bounded implementation, `sonnet --effort high` for sustained or messy work, `opus --effort high` for reviews and judgment-heavy work, `fable --effort high` for the hardest ambiguous calls. Never Haiku.
- **Cost:** Claude tokens cost real money where Codex doesn't. Keep `--max-budget-usd` as a runaway guard and report `total_cost_usd` when it matters.
- **Iterating:** capture `.session_id` and continue with `claude -p --resume <id> "fix the failing test" ...`, re-passing the model and permission flags — they're per-invocation, not per-session.
- `--add-dir <path>` grants access to one directory outside the repo without widening anything else.

## Gotchas that bite both

- **Silence is not a hang.** With `text` or `json` output, nothing prints until the run finishes — implementation runs can be quietly busy for many minutes. Don't kill it. For live progress, use Claude's `--output-format stream-json --verbose --include-partial-messages`, or background the run and poll the report file while watching `git status`.
- **Both wait for stdin EOF.** Feed the prompt on stdin and let it close; redirect `< /dev/null` when there's no prompt stream. A backgrounded shell holding stdin open hangs the run. Claude's piped stdin caps at 10MB; empty stdin with no prompt argument exits 1.
- **Keep stdout and stderr separate.** Shell-init noise on stderr will corrupt a JSON envelope if you merge them.
- **Exit code 0 is not success.** Check `.is_error` and `.permission_denials` too — a run that got blocked and gave up can still exit clean.
- **Long runs exceed shell timeouts.** Pass an explicit timeout, or background the run and poll for the report file.
- **Headless runs load the machine's own settings** — user and project config, `CLAUDE.md`/`AGENTS.md`, hooks, MCP servers — so behavior varies per machine. The explicit flags above plus `--strict-mcp-config` keep a run deterministic.
- **Auth uses the machine's credentials.** "Not logged in" means they're missing or expired: report it, don't retry. A stale `ANTHROPIC_API_KEY` silently overrides subscription auth. Never use Claude's `--bare` to isolate settings — it drops keychain auth entirely.
- If the CLI isn't installed or the run fails, report the exact failure and offer to do the work directly instead.

---
name: claude-review
description: Use when the user asks to have Claude review work, when the model-selection rubric calls for a Claude review perspective, or when a change should be audited against its requirements by an independent Claude reviewer. Covers uncommitted changes, branch diffs, commits, or a specific implementation. For a review by the current agent itself, use the normal review process instead.
---

# Claude Review

**If Claude models are available as native subagents, use two native Claude subagents in parallel. Do not use the CLI.** The CLI instructions below are for agents, such as Codex, that can only shell out.

Use Claude as an independent reviewer when the user wants a second pass or a change is broad enough to benefit from another perspective. Do not delegate merely to avoid reading the code. Treat Claude's output as evidence, not authority.

## Process

### 1. Pin and validate the review target

Resolve the target before delegating. Capture the exact command once so both axes inspect the same change:

- Branch, tag, or base ref: verify it with `git rev-parse <fixed-point>`, then use `git diff <fixed-point>...HEAD` and `git log <fixed-point>..HEAD --oneline`. The three-dot diff compares against the merge-base.
- Commit: verify the SHA, then use `git show <sha>`.
- Uncommitted work: use `git status --porcelain`, `git diff HEAD`, and include untracked files explicitly.
- Specific files: name the paths and the comparison point.

Fail early if the ref is invalid or the target is empty. Do not make two reviewers rediscover a bad target.

### 2. Find the spec source

Build the Spec axis from the best available source, in this order:

1. Requirements or a spec path supplied by the user.
2. Issues or PRs referenced by commit messages; use the repository's documented issue-tracker workflow when present.
3. A matching PRD or spec under `docs/`, `specs/`, or `.scratch/`.

If no reliable spec exists, skip the Spec reviewer and report `No spec available`. Never invent requirements from the implementation.

### 3. Find the standards sources

Identify all instructions that apply to the changed files, including scoped `AGENTS.md` or `CLAUDE.md` files, `CONTRIBUTING.md`, coding standards, architecture documents, and test conventions.

The Standards axis also checks correctness, regressions, security, and missing or weak tests. Apply these additional review lenses when available:

- `codebase-design` for deep modules, clean seam placement, small interfaces, and interface-level testability.
- `write-less` for over-engineering, unnecessary code or tests, and overcomplicated tests.
- `typescript-beautify` for TypeScript or JavaScript codebases.

Keep the review read-only. If a lens is unavailable, state that and continue.

#### Fowler smell baseline

Repository rules override this baseline. Treat every smell as a labelled judgement call, never a hard violation, and skip checks already enforced by tooling.

- **Mysterious Name** — a name does not reveal what a value, function, or type means; rename it, or revisit a design that has no honest name.
- **Duplicated Code** — the same logic shape appears in multiple changed locations; extract the shared shape.
- **Feature Envy** — code reaches into another object's data more than its own; move the behaviour toward the data it uses.
- **Data Clumps** — the same fields or parameters repeatedly travel together; introduce one meaningful type.
- **Primitive Obsession** — a primitive stands in for a domain concept; model the concept explicitly.
- **Repeated Switches** — the same conditional dispatch recurs; centralize it or use polymorphism.
- **Shotgun Surgery** — one logical change requires scattered edits; gather the behaviour behind one module or seam.
- **Divergent Change** — one module changes for unrelated reasons; split the responsibilities.
- **Speculative Generality** — abstractions or hooks serve no current requirement; remove or inline them.
- **Message Chains** — callers navigate a long object chain; hide the traversal behind a meaningful operation.
- **Middle Man** — a type or function mostly delegates; call the real abstraction directly.
- **Refused Bequest** — an implementation ignores most inherited behaviour; prefer composition or a narrower contract.

### 4. Run two isolated reviewers in parallel

Run one Standards reviewer and, when a spec exists, one Spec reviewer. Give both the exact target command and commit list. Do not let either see the other's report.

The Standards prompt must include the applicable standards sources and the smell baseline. Ask for:

- concrete bugs, regressions, security issues, and meaningful test gaps;
- every documented-standard violation, citing the source file and rule;
- possible baseline smells, labelled as judgement calls and tied to a changed hunk;
- severity, file and line, concrete failure mode, and a practical fix direction for every finding.

The Spec prompt must include the spec path or contents. Ask for:

- missing or partial requirements;
- behaviour not requested by the spec (scope creep);
- requirements that appear implemented but behave incorrectly;
- the source requirement and changed file/line for every finding.

Tell both reviewers: `Do not edit files. Work directly; do not delegate to other agents, subagents, or Codex. Prioritize findings over summary. If there are no substantive findings, say so and identify residual test gaps.`

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

### Model choice

- Always pass `--model` explicitly; otherwise the run inherits the machine's default.
- Use `--model opus --effort high` by default, `--model fable --effort high` for the hardest ambiguous reviews, and `--model sonnet --effort medium` for a quick sanity pass. Never use Haiku.
- Claude tokens cost money. Use `--max-budget-usd <n>` as a guard for large reviews and inspect `total_cost_usd` in each result envelope.

### CLI edge cases

- Silence is normal. Text and JSON output appear only when the run finishes. For progress, use `--output-format stream-json --verbose --include-partial-messages`, or run in the background and poll the result files.
- Claude waits for stdin EOF. Feed each prompt on stdin; if there is no prompt stream, use `</dev/null>`. Piped stdin is capped at 10 MB.
- Keep stdout and stderr separate so shell noise cannot corrupt the JSON envelope.
- Check the process exit code plus `.is_error` and `.permission_denials`; exit code zero alone is insufficient.
- Headless mode loads user/project settings, `CLAUDE.md`, hooks, and MCP servers. The explicit permission flags and `--strict-mcp-config` keep the run deterministic and read-only.
- Global instructions may tell Claude to delegate. The prompt's direct-work instruction prevents recursive delegation.
- Do not use `--bare`: it drops subscription/keychain auth and requires `ANTHROPIC_API_KEY`.
- `-p` skips workspace trust and ignores invalid settings files, so run it only in trusted repositories.
- Authentication uses the machine's credentials. Report missing or expired auth instead of retrying; a stale `ANTHROPIC_API_KEY` can override subscription auth.
- Long reviews may exceed shell timeouts. Keep them in the background and poll their artifacts.
- For follow-ups, omit `--no-session-persistence`, capture `.session_id`, and resume with `claude -p --resume <session-id>` while re-passing all permission flags.

## Aggregate and report

Inspect every cited hunk before relaying a finding. Within each axis, distinguish confirmed findings from suggestions you could not verify.

Present separate `## Standards` and `## Spec` sections. Do not merge or rerank findings across axes. End with the finding count and worst issue within each axis; do not pick one overall winner. If an axis has no findings, say so. If no spec was available, say what target was reviewed and explicitly mark the Spec axis as skipped.

If `claude` is unavailable or fails, report the exact failure and offer to perform the review directly.

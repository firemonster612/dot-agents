---
name: implement-core
description: The shared contract for dispatching implementation delegates — scoping workflow, prompt requirements, and post-run review. Use whenever dispatching an implementer via codex-implementation or claude-implement, or when another skill needs the delegate contract.
---

# Implement Core

Everything the two implementation-delegate skills share. The tool-specific mechanics — CLI shape, permissions/sandboxing, model choice, edge cases — live in `codex-implementation` and `claude-implement`; consult the one you're dispatching through.

You (the orchestrator) remain responsible for scoping the task, reviewing the diff, running or checking verification, and explaining the final result. Do not let the delegate commit, push, deploy, or edit global config unless the user explicitly asked for that.

## Workflow

1. Pin the current state with `git status --short` and note any user changes already present. Record the base SHA (`git rev-parse HEAD`).
2. Define the implementation scope: files or behavior to change, files to avoid, constraints, and verification commands.
3. Create a temporary artifact directory for the prompt and report.
4. Dispatch the delegate (see the tool skill for the exact command).
5. After it exits, inspect `git status` and `git diff` (plus any result envelope the tool provides).
6. Run the cheapest reliable verification yourself when practical.
7. Report what the delegate changed, what you verified, and any remaining risks.

## Prompt requirements

Write a self-contained prompt telling the delegate:

- The exact implementation goal and acceptance criteria.
- The repo path and current branch context if relevant.
- Which existing patterns, files, or tests to inspect first.
- Files or behavior that must not be changed.
- That it must preserve unrelated user changes.
- That it must not commit, push, deploy, or edit global config.
- That it must work directly and not delegate to other agents, subagents, or codex.
- **Domain docs:** read `CONTEXT.md` at the repo root (or the per-context files a `CONTEXT-MAP.md` points at) and the ADRs under `docs/adr/` that touch the area, before exploring the code. Proceed silently if they don't exist. Use the glossary's vocabulary in names, tests, and commit messages. If the change contradicts an ADR, surface that in the report rather than silently overriding it.
- **Tests:** where a test framework exists, hold the delegate to the `tdd` skill's loop — spell its rules out in the prompt (the delegate cannot read skills): write a failing test that specifies the change before implementing, red before green, one vertical slice at a time, and include the red→green evidence (both runs) in the report. Test only at the seams the spec or ticket names (its Testing Decisions / Produces sections); if none are named, propose seams in the report before relying on them. Expected values must come from an independent source of truth — a known-good literal, a worked example, the spec — never recomputed the way the code computes them.
- **Tickets:** if the task is a tracker ticket, include the issue number and its acceptance criteria in the prompt, and require the report to map each criterion to evidence (a test, a command output, a behavior shown).
- Which verification commands to run, or to explain why they were skipped.
- To write a concise final report with files changed, verification, and unresolved questions.

Keep the task bounded. If the requested work bundles several substantial changes, split it into separate runs or ask the user to choose the first scope.

## Example prompt

```text
You are implementing a scoped change. Work directly; do not delegate to other agents, subagents, or codex.

Repository: /absolute/path/to/repo
Ticket: #42 (if applicable — paste its acceptance criteria below)

Before exploring: read CONTEXT.md and docs/adr/ entries touching this area, if they exist. Use the project's vocabulary.

Goal:
- Add keyboard navigation to the command palette.

Acceptance criteria:
- ArrowUp and ArrowDown move the highlighted item.

Constraints:
- Do not commit, push, or edit anything outside this repo.
- Preserve unrelated uncommitted changes.

Tests:
- Write a failing test first at the agreed seam; include red→green evidence in the report.

Verification:
- pnpm test -- command-palette

Report:
- Files changed
- Behavioral summary
- Each acceptance criterion → the evidence for it
- Verification run and result
- Anything blocked or uncertain
```

## Review after the delegate

Apply the `verification-before-completion` skill before telling the user the work is done — a delegate's "success" report is a claim, not evidence: inspect the diff, run the cheapest reliable verification, and map each claim to evidence. Revert only delegate-created mistakes when you are sure they are not user changes. If the delegate leaves the repo in a worse state or changes unrelated files, stop and report the issue with the diff summary.

If the delegate CLI is not installed or the command fails, report the error and offer to implement the change directly instead.

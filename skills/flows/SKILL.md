---
name: flows
description: Which skill or flow fits your situation — the router over this whole setup. Orients only; does no work itself.
disable-model-invocation: true
---

# Flows

You don't remember every skill, so ask. Describe your situation; this skill answers **which skill or chain fits, in what order**, then hands off. It never does the work itself.

## Masters — one command per situation

- **`/new-project-semi-auto`** — an idea with no codebase yet. Wayfinds if foggy, grills, scaffolds (Bun/TS/React/Tailwind/Convex/Clerk, oxfmt/oxlint), wires the tracker, then runs the chain below.
- **`/add-feature-semi-auto`** — change an existing codebase. Features **and refactors** (wide refactors get expand–contract slicing from `to-tickets`).
- **`/fix-bug-semi-auto`** — something is broken. Diagnose → delegate fix → review → finish.

## The main chain (what the masters run)

```
grill-with-docs → to-spec → [one session? → implement it (writing-code)
                             too big?    → to-tickets → frontier of fresh delegates]
                → review-loop (once, BASE..HEAD) → finishing-a-development-branch
```

Keep everything through `to-tickets` in ONE unbroken context window. Each ticket then gets a **fresh** delegate whose context package is the spec + the ticket + the blockers' commits — that freshness is why multi-ticket work delegates. A change that fits one session doesn't need a delegate at all; implement it directly unless the model rubric points elsewhere. Review runs once at the end — it's token-heavy.

## On-ramps

- **`/triage`** — raw inbound issues and PRs you didn't create: verify the claim, grill into shape, leave `ready-for-agent` briefs the masters pick up. Never triage `to-tickets` output — those are already agent-ready.
- **`/wayfinder`** — an effort too big for one session whose route is still foggy. Charts a map of decision tickets on the tracker, resolves one per session, then merges onto the chain at `to-spec`. Not for well-understood features — it's heavy by design.

## Precondition

- **`/setup-project`** — run once per repo before any tracker-touching skill. Writes `docs/agents/` (issue tracker conventions, triage labels, domain-doc rules) — the config layer everything above reads.

## Vocabulary layers (model-invoked; the agent pulls these in itself)

- **`codebase-design`** — deep modules, seams, interfaces, the deletion test.
- **`domain-modeling`** — the glossary (`CONTEXT.md`) and ADR discipline.
- **`write-less`** — anti-over-engineering: load BEFORE implementing, and use as the review lens. (Prefer this over `simplify`.)
- **`typescript-beautify`** — TS/JS style. Only in TypeScript projects.
- **`tdd`** — the red-green loop and what makes a good test; `writing-code` pulls it in when tests exist.

## Doing the work (model-invoked)

These are worker-facing — load them when *you* are the one writing or reviewing, and point delegates at them too.

- **`writing-code`** — load before implementing anything: what to read first, holding scope, test discipline, what your report owes.
- **`reviewing-code`** — load when reviewing a diff: the two axes, what makes a finding, the smell baseline.
- **`verification-before-completion`** — the gate before any "done" claim: run the verification, read the output, map claim → evidence.

## Dispatching (model-invoked)

- **`review-loop`** — the two-axis independent review at the end of a change. The one place delegation is structural, not optional.
- **`cli-subagents`** — how to spawn a Codex or Claude delegate by shelling out, when no native subagent primitive is available. Transport only. Route models by the rubric in AGENTS.md.

## Standalones

- **`prototype`** — throwaway code answers one design question: logic TUI, or UI variants behind `?variant=`.
- **`diagnosing-bugs`** — tight red loop before theorising. (`/fix-bug-semi-auto` drives it.)
- **`resolving-merge-conflicts`** — mid-merge/rebase, resolve by intent, never `--abort`.
- **`grilling`** / **`grill-with-docs`** — the interview primitive / its docs-writing wrapper.
- **`deep-research`** — cited multi-source web research. Harness-provided (Claude Code plugin), not part of this repo — where it's absent, dispatch a Codex research delegate per the model rubric instead.
- **`teach`** — long-running learning workspace in the current directory.
- **`writing-great-skills`** — the reference for editing this skill set itself.
- **`finishing-a-development-branch`** — the merge/PR/keep/discard menu at the end of any branch.
- **`human-writing`**, **`shadcn`**, **`html`**/**`html-plan`**/**`html-diagram`**, **`playwriter`**, **`computer-use-linux`**, **`tailnet-fleet`** — task-specific tools; reach for them by name.

## Cross-session

After compaction, trust the progress ledger, the tracker's issue states, and `git log` over recollection. A session that resumes a multi-ticket run reads the ledger first and never re-dispatches a completed ticket.

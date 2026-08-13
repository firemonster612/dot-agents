# dot-agents

## Description

My AI coding setup/dot files.

## Quick start

```sh
git clone https://github.com/firemonster612/dot-agents.git ~/.agents
git clone https://github.com/firemonster612/write-less.git ~/.agents/skills/write-less
git clone https://github.com/firemonster612/typescript-beautify ~/.agents/skills/typescript-beautify
ln -s ~/.agents/skills ~/.claude/skills
ln -s ~/.agents/AGENTS.md ~/.claude/CLAUDE.md
ln -s ~/.agents/AGENTS.md ~/.codex/AGENTS.md
```

## How to use

Work is conversational: most skills trigger themselves off their own descriptions when the situation matches. Names written with a slash (`/to-tickets`) are user-invoked — they fire only when you type them.

Once per repo, run `/setup-repo`. It writes `docs/agents/` (issue-tracker conventions, triage labels, domain-doc rules) — the config layer every tracker-touching skill reads.

The typical arc of a feature, when its pieces are wanted: stress-test the idea (`grilling` / `/grill-with-docs`) → split multi-session work into tickets (`/to-tickets`) → implement (`writing-code`, with `tdd` and `write-less` as lenses) → independent review (`review-loop` — never let the only review of a change be by whoever wrote it) → gate every "done" claim (`verification-before-completion`).

Understanding the codebase: `how` for mechanism, `why` for rationale. Continuity between sessions: `/recall` to catch up, `/handoff` to pass on.

## Skill index

**Understanding the codebase:** [how](skills/how/SKILL.md) — how something works, code walkthroughs, and where-should-this-live questions · [why](skills/why/SKILL.md) — design rationale, decisions, and tradeoffs, cited from source control, trackers, docs, and chat · [codebase-design](skills/codebase-design/SKILL.md) — shared vocabulary for designing deep modules and finding seams · [domain-modeling](skills/domain-modeling/SKILL.md) — build and sharpen a project's domain model and ubiquitous language

**Shaping work:** [grilling](skills/grilling/SKILL.md) — grill the user relentlessly to stress-test a plan or idea · [/grill-with-docs](skills/grill-with-docs/SKILL.md) — the same interview, writing ADRs and a glossary as it goes · [prototype](skills/prototype/SKILL.md) — throwaway prototype to answer a design or UI question · [/to-tickets](skills/to-tickets/SKILL.md) — break a plan or conversation into tracer-bullet tickets with blocking edges · [/setup-repo](skills/setup-repo/SKILL.md) — once-per-repo setup: issue tracker, triage labels, domain-doc layout

**Doing the work (worker-facing — load when you're the one writing; point delegates at them too):** [writing-code](skills/writing-code/SKILL.md) — what to read, how to hold scope, how to test a scoped change · [reviewing-code](skills/reviewing-code/SKILL.md) — the two review axes, what counts as a finding, the output shape · [tdd](skills/tdd/SKILL.md) — test-driven development, red-green-refactor · [write-less](skills/write-less/SKILL.md) — steering and review lens against over-engineering · [verification-before-completion](skills/verification-before-completion/SKILL.md) — gate before claiming work is done; evidence over claims · [diagnosing-bugs](skills/diagnosing-bugs/SKILL.md) — diagnosis loop for hard bugs and performance regressions · [typescript-beautify](skills/typescript-beautify/SKILL.md) — rules for senior-level TypeScript: types, errors, async, naming

**Review & dispatch:** [review-loop](skills/review-loop/SKILL.md) — independent reviewers per axis, triage, one fixer, repeat · [cli-subagents](skills/cli-subagents/SKILL.md) — shelling out to a Codex or Claude subagent when no native primitive exists

**Session continuity:** [/recall](skills/recall/SKILL.md) — reconstruct recent working context into a current-state brief · [/handoff](skills/handoff/SKILL.md) — compact the conversation into a handoff document for the next session

**Verification harnesses:** [/create-verification-skill](skills/create-verification-skill/SKILL.md) — generate a project-local skill that drives the app like a user · [/maintain-verification-skill](skills/maintain-verification-skill/SKILL.md) — periodic audit keeping a verification skill and feature map honest

**Writing:** [writing-for-agents](skills/writing-for-agents/SKILL.md) — writing documents for agents: skills, AGENTS.md, CLAUDE.md · [human-writing](skills/human-writing/SKILL.md) — write text that reads as authentically human, not AI-generated · [unslop](skills/unslop/SKILL.md) — cut AI tells from any writing

**Deliverables:** [/html](skills/html/SKILL.md) — self-contained HTML artifact for reports, explainers, decks, prototypes · [/html-plan](skills/html-plan/SKILL.md) — self-contained HTML plan, pragmatic and visually organized · [/html-diagram](skills/html-diagram/SKILL.md) — self-contained HTML architecture diagram, light on prose

**Environment:** [playwriter](skills/playwriter/SKILL.md) — drive the user's own Chrome via Playwright snippets in a stateful sandbox · [computer-use-linux](skills/computer-use-linux/SKILL.md) — observe or control the local Linux desktop GUI · [tailnet-fleet](skills/tailnet-fleet/SKILL.md) — reference for tailnet machines reachable over SSH, and when to offload to them · [shadcn](skills/shadcn/SKILL.md) — manage shadcn/ui components, registries, and presets

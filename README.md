# dot-agents

## Description

My AI coding setup/dot files.

## Quick start

```sh
git clone https://github.com/firemonster612/dot-agents.git ~/.agents
ln -s ~/.agents/skills ~/.claude/skills
ln -s ~/.agents/AGENTS.md ~/.claude/CLAUDE.md
ln -s ~/.agents/AGENTS.md ~/.codex/AGENTS.md
```

## My workflow / How to use

Not sure where to start? Type `/flows` — it routes every situation to the right skill.

**Once per repo:** run `/setup-project`. It writes `docs/agents/` (issue tracker conventions, triage labels, domain-doc rules) — the config layer every tracker-touching skill reads. Everything below assumes it has run.

**Three masters — one command per situation:**

| Situation | Command |
| --- | --- |
| New project from an idea | `/new-project-semi-auto` |
| Feature or refactor in an existing codebase | `/add-feature-semi-auto` |
| Something's broken | `/fix-bug-semi-auto` |

**The chain the masters run:**

```
grill-with-docs → to-spec → [fits one session → single delegate
                             too big → to-tickets → frontier of fresh delegates]
                → review-loop (once, BASE..HEAD) → finishing-a-development-branch
```

Specs and tickets are GitHub issues: tickets are sub-issues with native blocked-by edges, delegates claim by self-assign, commits say `Closes #N`, and the tracker is the progress ledger.

**On-ramps:** raw inbound issues/PRs → `/triage` (five-state machine, verified claims, agent briefs). Efforts too foggy to spec → `/wayfinder` (a map of decision tickets, one resolved per session, hands off to `to-spec`).

## Skill index

**Masters (user-invoked):** [new-project-semi-auto](skills/new-project-semi-auto/SKILL.md) · [add-feature-semi-auto](skills/add-feature-semi-auto/SKILL.md) · [fix-bug-semi-auto](skills/fix-bug-semi-auto/SKILL.md)

**Setup & navigation (user-invoked):** [setup-project](skills/setup-project/SKILL.md) — run once per repo · [flows](skills/flows/SKILL.md) — the router · [triage](skills/triage/SKILL.md) — inbound issue state machine · [wayfinder](skills/wayfinder/SKILL.md) — map foggy multi-session efforts

**Chain steps:** [grilling](skills/grilling/SKILL.md) · [grill-with-docs](skills/grill-with-docs/SKILL.md) · [to-spec](skills/to-spec/SKILL.md) · [to-tickets](skills/to-tickets/SKILL.md) · [review-loop](skills/review-loop/SKILL.md) · [finishing-a-development-branch](skills/finishing-a-development-branch/SKILL.md)

**Delegation & review cores:** [implement-core](skills/implement-core/SKILL.md) · [codex-implementation](skills/codex-implementation/SKILL.md) · [claude-implement](skills/claude-implement/SKILL.md) · [review-core](skills/review-core/SKILL.md) · [codex-review](skills/codex-review/SKILL.md) · [claude-review](skills/claude-review/SKILL.md) · [verification-before-completion](skills/verification-before-completion/SKILL.md)

**Vocabulary & lenses:** [codebase-design](skills/codebase-design/SKILL.md) · [domain-modeling](skills/domain-modeling/SKILL.md) · [write-less](skills/write-less/SKILL.md) · [typescript-beautify](skills/typescript-beautify/SKILL.md) · [tdd](skills/tdd/SKILL.md)

**Standalones:** [prototype](skills/prototype/SKILL.md) · [diagnosing-bugs](skills/diagnosing-bugs/SKILL.md) · [resolving-merge-conflicts](skills/resolving-merge-conflicts/SKILL.md) · [writing-great-skills](skills/writing-great-skills/SKILL.md) · [teach](skills/teach/SKILL.md) · [human-writing](skills/human-writing/SKILL.md) · [shadcn](skills/shadcn/SKILL.md) · [html](skills/html/SKILL.md) · [html-plan](skills/html-plan/SKILL.md) · [html-diagram](skills/html-diagram/SKILL.md) · [playwriter](skills/playwriter/SKILL.md) · [computer-use-linux](skills/computer-use-linux/SKILL.md) · [tailnet-fleet](skills/tailnet-fleet/SKILL.md)

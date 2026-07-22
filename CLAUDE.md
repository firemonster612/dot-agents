# dot-agents repo rules

These apply when editing this repo itself (the global preferences live in `AGENTS.md`).

- Every skill in `skills/` has a one-line entry in the skill index in `README.md`.
- `skills/flows/SKILL.md` is the router over the whole set. Whenever a skill is added, renamed, removed, or changes its role in a flow, update the router (and the README index) in the same change — a stale router lies.
- When deleting a skill folder, prune its entry from `.skill-lock.json`.
- A skill folder's name must match its frontmatter `name:`.
- `skills/typescript-beautify`, `skills/write-less`, and `skills/hydra-sync` are separate git repos linked in place — edit them in their own repos, not through this one.

## Coherence contract — layers that must agree

An edit to any one of these layers is checked against its counterparts in the same change:

- **Masters ↔ chain steps.** The masters (`new-project-semi-auto`, `add-feature-semi-auto`, `fix-bug-semi-auto`) name chain skills by name (grilling, to-spec, to-tickets, review-loop, finishing-a-development-branch, implement-core, diagnosing-bugs). Renaming or re-scoping a chain skill means updating every master that names it.
- **Cores ↔ adapters.** `implement-core` ↔ `codex-implementation`/`claude-implement`; `review-core` ↔ `codex-review`/`claude-review`. Shared contract text lives only in the core; adapters hold only tool-specific mechanics. Never re-introduce contract text into an adapter.
- **Tracker conventions.** `setup-project`'s seed files own the tracker vocabulary (labels, claiming, blocked-by, `Closes #N`). Other skills reference the tracker abstractly and read `docs/agents/*.md` — never hard-code `gh` commands outside the seeds.
- **Catalog.** The README index and `flows` router list exactly the skills that exist, plus harness-provided ones explicitly marked as such (e.g. `deep-research`). A skill referenced anywhere must either exist in `skills/` or carry that marking — the audit is: extract referenced skill names, diff against `skills/`.

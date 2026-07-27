# dot-agents repo rules

These apply when editing this repo itself (the global preferences live in `AGENTS.md`).

- Every skill in `skills/` has a one-line entry in the skill index in `README.md`.
- `skills/flows/SKILL.md` is the router over the whole set. Whenever a skill is added, renamed, removed, or changes its role in a flow, update the router (and the README index) in the same change — a stale router lies.
- When deleting a skill folder, prune its entry from `.skill-lock.json`.
- A skill folder's name must match its frontmatter `name:`.
- `skills/typescript-beautify`, `skills/write-less`, and `skills/hydra-sync` are separate git repos linked in place — edit them in their own repos, not through this one.

## Coherence contract — layers that must agree

An edit to any one of these layers is checked against its counterparts in the same change:

- **Masters ↔ chain steps.** The masters (`new-project-semi-auto`, `add-feature-semi-auto`, `fix-bug-semi-auto`) name chain skills by name (grilling, to-spec, to-tickets, writing-code, review-loop, finishing-a-development-branch, diagnosing-bugs). Renaming or re-scoping a chain skill means updating every master that names it.
- **Worker skills ↔ dispatch skills ↔ transport.** `writing-code` and `reviewing-code` are **worker-facing**: they address whoever writes or reviews the code, and are loaded by that agent — self or delegate alike. `review-loop` and AGENTS.md's delegation hygiene are **dispatcher-facing**: target pinning, triage, aggregation, who-gets-what. `cli-subagents` is **transport only** — command shapes and flags, never task content. Instructions belong in exactly one layer: a worker rule in the dispatcher layer has to be transcribed into every prompt (which is how it drifts), and task content in the transport layer duplicates per CLI.
- **Tracker conventions.** `setup-project`'s seed files own the tracker vocabulary (labels, claiming, blocked-by, `Closes #N`). Other skills reference the tracker abstractly and read `docs/agents/*.md` — never hard-code `gh` commands outside the seeds.
- **Catalog.** The README index and `flows` router list exactly the skills that exist, plus harness-provided ones explicitly marked as such (e.g. `deep-research`). A skill referenced anywhere must either exist in `skills/` or carry that marking.

Run `scripts/lint-skills.sh` before every push — it enforces this contract mechanically (names, catalog, dangling references, master invocation flags, lock hygiene).

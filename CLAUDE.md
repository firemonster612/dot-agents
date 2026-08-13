# dot-agents repo rules

These apply when editing this repo itself (the global preferences live in `AGENTS.md`).

Skills are invoked two ways. Model-invocable skills trigger off their frontmatter descriptions mid-conversation, which makes those descriptions load-bearing. User-invoked skills (`disable-model-invocation: true`) are reachable only by the user typing `/<name>` — their descriptions never reach the model, so the README index is where they get found. Write and prune both per `skills/writing-for-agents`.

- Every skill in `skills/` has a one-line entry in the skill index in `README.md` — with the router gone, the index is the only catalog.
- A skill folder's name must match its frontmatter `name:`.
- `.skill-lock.json` tracks upstream-installed skills. Prune a skill's entry when deleting its folder, and also when editing it into a local fork — a lock entry claims upstream ownership, and a later update would clobber local edits.
- `skills/typescript-beautify`, `skills/write-less`, and (where cloned) `skills/hydra-sync` are separate git repos linked in place — edit them in their own repos, not through this one.

## Coherence contract — layers that must agree

An edit to any one of these layers is checked against its counterparts in the same change:

- **Worker skills ↔ dispatch skills ↔ transport.** `writing-code` and `reviewing-code` are **worker-facing**: they address whoever writes or reviews the code, and are loaded by that agent — self or delegate alike. `review-loop` and AGENTS.md's delegation hygiene are **dispatcher-facing**: target pinning, triage, aggregation, who-gets-what. `cli-subagents` is **transport only** — command shapes and flags, never task content. Instructions belong in exactly one layer: a worker rule in the dispatcher layer has to be transcribed into every prompt (which is how it drifts), and task content in the transport layer duplicates per CLI.
- **Tracker conventions.** `setup-repo`'s seed files own the tracker vocabulary (labels, claiming, blocked-by, `Closes #N`). Other skills reference the tracker abstractly and read `docs/agents/*.md` — never hard-code `gh` commands outside the seeds.
- **Catalog.** The README index lists exactly the skills that exist. A skill referenced anywhere must exist in `skills/`, be explicitly marked as harness-provided, or be referenced only behind an is-installed check (the lint script holds both allowlists).

Run `scripts/lint-skills.sh` before every push — it enforces this contract mechanically (names, catalog, dangling references, lock hygiene).

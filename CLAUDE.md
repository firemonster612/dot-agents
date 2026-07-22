# dot-agents repo rules

These apply when editing this repo itself (the global preferences live in `AGENTS.md`).

- Every skill in `skills/` has a one-line entry in the skill index in `README.md`.
- `skills/flows/SKILL.md` is the router over the whole set. Whenever a skill is added, renamed, removed, or changes its role in a flow, update the router (and the README index) in the same change — a stale router lies.
- When deleting a skill folder, prune its entry from `.skill-lock.json`.
- A skill folder's name must match its frontmatter `name:`.
- `skills/typescript-beautify`, `skills/write-less`, and `skills/hydra-sync` are separate git repos linked in place — edit them in their own repos, not through this one.

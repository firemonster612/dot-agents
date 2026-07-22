---
name: new-project-semi-auto
description: Start a new project from an idea — wayfind if foggy, grill, scaffold, wire the tracker, then run the spec → tickets → implement → review pipeline. This should not be invoked automatically.
disable-model-invocation: true
---

# The Workflow

1. **Fog check.** Could you write the spec after one grilling session — is the route visible? If the idea is genuinely foggy (product shape, architecture, and stack all open at once, too much for one session), run `/wayfinder` first and stop there for this session. When its map is clear, come back here: the map's decisions replace most of step 2's interview.

2. **Interview.** Run a `/grilling` session with the `/domain-modeling` skill about the product, its users, and its constraints. As decisions land, seed `CONTEXT.md` with the domain terms and record hard-to-reverse choices as the project's first ADRs.

3. **Scaffold.** Confirm the project name and directory with the user, then create the skeleton. Stack, unless the interview decided otherwise: Bun, TypeScript, React, Tailwind, Convex, Clerk — with oxfmt and oxlint (never eslint/Prettier on a new React project; bun as package manager unless the project already uses pnpm). `git init` and make the first commit.

4. **Repo + tracker.** Offer to create the GitHub repo (`gh repo create` — confirm with the user first; this is outward-facing). Then run `/setup-project` so `docs/agents/` (issue tracker, triage labels, domain docs) exists from day one.

5. **Spec onward.** Continue exactly as `add-feature-semi-auto` steps 2–6: record the base SHA, `to-spec` (fed by the interview and any wayfinder map) → size branch → `to-tickets` + frontier loop of fresh delegates when multi-session → one `review-loop` over the whole `BASE..HEAD` → `finishing-a-development-branch`.

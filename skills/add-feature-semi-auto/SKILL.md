---
name: add-feature-semi-auto
description: Given a feature idea, run the full interview → spec → (tickets) → implement → review-loop pipeline. This should not be invoked automatically.
disable-model-invocation: true
---

# The Workflow

Refactors ride this same pipeline — a spec'd refactor is a feature-shaped change, and `/to-tickets` already knows to slice wide refactors as expand–contract.

Tracker mechanics (creating issues, claiming, closing) come from `docs/agents/issue-tracker.md` — run `/setup-project` if it's missing.

1. **Interview.** Run a `/grilling` session using the `/domain-modeling` skill to interview the user about the feature idea.

2. **Spec.** Record the base SHA (`git rev-parse HEAD`). Use the `to-spec` skill to turn the feature idea and the user's interview answers into a published spec. Note its size verdict.

3. **Size branch.**
   - **Fits one session** → implement it in one pass, following `writing-code`. Delegate that pass to a fresh implementer when the model rubric points at another model or you want to keep this context clear; do it here otherwise. Then go to step 5.
   - **Too big for one session** (to-spec's verdict, or plainly so) → run the `to-tickets` skill, then step 4.

4. **Frontier loop.** Repeat until no open tickets remain:
   - Pick the first **frontier** ticket: open, all blockers closed, unclaimed.
   - **Claim it** (self-assign on GitHub; `Status:` line locally) before any work.
   - Dispatch a **fresh** implementer subagent, pointed at `writing-code`. Its context package: the master spec, the ticket, and what's already implemented (the progress ledger plus the blockers' commits). Never reuse an earlier ticket's delegate — each ticket gets a clean context. This is the one part of the chain where delegating is structural rather than optional: the fresh context per ticket is the point.
   - After verifying the delegate's diff yourself: commit the ticket's work referencing its issue (`Closes #N`), post the verification evidence as a comment on the ticket, close it, and append a ledger line: `Ticket #N: complete (<base>..<head>)`.

5. **Review loop.** Once ALL implementation is done, use the `review-loop` skill on the full `BASE..HEAD` — one review pass for the whole feature, not per ticket (review is token-heavy).

6. **Finish.** Hand off to the `finishing-a-development-branch` skill: verify tests, present the merge/PR/keep/discard options, and clean up. Close the spec issue when the work lands.

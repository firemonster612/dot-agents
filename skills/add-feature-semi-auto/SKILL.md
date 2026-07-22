---
name: add-feature-semi-auto
description: Given a feature idea, run the full interview → spec → implement → review-loop pipeline. This should not be invoked automatically.
disable-model-invocation: true
---

# The Workflow

1. **Interview.** Run a `/grilling` session using the `/domain-modeling` skill to interview the user about the feature idea.

2. **Spec.** Use the `to-spec` skill to turn the feature idea and the user's interview answers into a published spec.

3. **Implement.** Record the base SHA (`git rev-parse HEAD`) before dispatching anything. Then use one or more implementer subagents to implement the spec, via the `codex-implementation` or `claude-implement` skills as the model rubric directs.

4. **Review loop.** use the `review-loop` skill.

5. **Finish.** Hand off to the `finishing-a-development-branch` skill: verify tests, present the merge/PR/keep/discard options, and clean up.

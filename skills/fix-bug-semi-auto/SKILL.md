---
name: fix-bug-semi-auto
description: Given a bug — a report, a tracker issue, or a symptom — run the diagnose → fix → review pipeline. This should not be invoked automatically.
disable-model-invocation: true
---

# The Workflow

1. **Source.** If the bug lives on the tracker, fetch the issue (`docs/agents/issue-tracker.md` — run `/setup-project` if missing), work from its agent brief when one exists, and claim the issue. Record the base SHA (`git rev-parse HEAD`).

2. **Diagnose.** Run the `diagnosing-bugs` skill: build a tight red feedback loop before any theorising, reproduce, minimise, rank falsifiable hypotheses, find the root cause and the regression-test seam.

3. **Fix.** Implement the fix following `writing-code`, carrying the minimised repro, the root cause, and the regression-test seam from diagnosis. A small obvious fix belongs right here — diagnosis already built the context, so handing it to a delegate throws that away. Dispatch a fresh implementer when the fix is substantial or the model rubric points elsewhere.

4. **Review loop.** Use the `review-loop` skill on `BASE..HEAD`.

5. **Finish.** Hand off to `finishing-a-development-branch`. The commit references the issue (`Closes #N`); the post-mortem — which hypothesis held — goes in the commit message or an issue comment.

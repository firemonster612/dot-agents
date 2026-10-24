---
name: verification-before-completion
description: Gate before claiming any work is done, fixed, or passing. Use before reporting completion of an implementation, a fix, a migration, or a delegated task. Every claim needs evidence you have actually looked at.
---

# Verification before completion

A completion claim is a factual statement about the world, not a feeling about the work. Before saying "done", "fixed", "passing", or "implemented":

1. **Run the verification:** the test suite, the build, the command from the acceptance criteria. Run it now, in the current state; a run from before the last edit is stale evidence.
2. **Read the output.** A zero exit code is not evidence until you have read what actually ran: 0 tests executed, skipped suites, and "no tests found" all exit 0.
3. **Map claim → evidence.** For each thing you are about to claim, name its evidence: the test that proves it, the command output, the behavior observed. A claim with no evidence gets verified now or dropped from the report, never stated as done.
4. **Check the diff.** `git diff` for your own work; for a delegate's, read its diff yourself. Its report is a claim, not evidence.

Tell-tale failure modes:

- "Should work now" is a prediction, not a verification.
- Relaying a delegate's success report without opening the diff.
- Declaring a bug fixed against a loop that never went red on that bug.
- A passing suite covering none of the acceptance criteria: green tests, unverified claim.

When verification cannot be run (missing environment, credentials, access), say exactly that, naming what you could not verify and why, instead of letting the claim stand in for the check.

## What counts as proof

Proof is evidence you observed in this session, the most direct the change allows:

- For a bug, reproduce the failure, apply the fix, and watch the same reproduction pass.
- Run the checks the repo's CI runs.
- When the behavior has no test and the repo has a test setup, add one focused test that fails without the change.
- For UI or runtime behavior, run the app and look at it. Green mocked tests don't prove what the user sees.

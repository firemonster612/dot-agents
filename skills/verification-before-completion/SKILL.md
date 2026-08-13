---
name: verification-before-completion
description: Gate before claiming any work is done, fixed, or passing. Use before reporting completion of an implementation, a fix, a migration, or a delegated task — every claim needs evidence you have actually looked at.
---

# Verification Before Completion

A completion claim is a factual statement about the world, not a feeling about the work. Before saying "done", "fixed", "passing", or "implemented":

1. **Run the verification** — the test suite, the build, the command from the acceptance criteria. Run it now, in the current state; a run from before the last edit is stale evidence.
2. **Read the output.** A zero exit code is not evidence until you have read what actually ran: 0 tests executed, skipped suites, and "no tests found" all exit 0.
3. **Map claim → evidence.** For each thing you are about to claim, name its evidence: the test that proves it, the command output, the behavior observed. A claim with no evidence gets verified now or dropped from the report — never stated as done.
4. **Check the diff.** `git diff` for your own work; for a delegate's, read its diff yourself — its report is a claim, not evidence.

Tell-tale failure modes:

- "Should work now" — a prediction, not a verification.
- Relaying a delegate's success report without opening the diff.
- Declaring a bug fixed against a loop that never went red on that bug.
- A passing suite covering none of the acceptance criteria — green tests, unverified claim.

When verification cannot be run (missing environment, credentials, access), say exactly that — what you could not verify and why — instead of letting the claim stand in for the check.

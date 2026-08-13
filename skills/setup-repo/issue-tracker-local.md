# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, never a single combined tickets file
- Each issue file records its state in a `Status:` line near the top: a triage role from `triage-labels.md` (tickets publish as `ready-for-agent`), then `claimed`, then `resolved`.
- Comments and conversation history append to the bottom of the file under a `## Comments` heading

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Ticket graph operations

Used by `to-tickets` when publishing, and by whoever dispatches a multi-ticket run (see AGENTS.md's delegation hygiene) to find and claim the next unblocked ticket.

- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked when every file it lists is `resolved`.
- **Frontier**: scan `.scratch/<feature-slug>/issues/` for files that are open, unblocked, and unclaimed; first by number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Complete**: set `Status: resolved` once the ticket's acceptance criteria are met and the work is committed. A ticket is open while its status is anything other than `resolved`.

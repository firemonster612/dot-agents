---
name: wayfinder
description: Plan a huge chunk of work, more than one agent session can hold, as a map of decision tickets in local Markdown files, resolving them one at a time until the way to the destination is clear. Use when the user asks to chart a plan too big for one session, when a repo has a plan/ map to continue or a ticket to work, or when a resolved decision on a map needs revising.
disable-model-invocation: true
---

A loose idea has arrived, too big for one agent session and wrapped in fog: the way from here to the **destination** isn't visible yet. Wayfinding is about finding that way, not charging at the destination. This skill charts the way as a **map** of local Markdown files, then works the map's **decision tickets**, questions whose resolution is a decision rather than a slice of a build to execute, one at a time until the route is clear.

The destination varies per effort, and naming it is the first act of charting, since it shapes every ticket. It might be a spec to hand off and iterate on, a decision to lock before planning starts, or a change made in place like a data-structure migration. The map is domain-agnostic: engineering work, course content, whatever fits the shape.

Everything lives in the repo as plain files. No issue tracker, plugin, or downstream skill is assumed. When the map clears, what remains is linked decisions; collapse them into a spec however the project likes.

## Plan, don't do

Wayfinder is planning by default: each ticket resolves a decision, and the map is done when the way is clear, nothing left to decide before someone goes and does the thing. The pull to just do the work is usually the signal you've reached the edge of the map and it's time to hand off. An effort can override this in its **Notes**, carrying execution into the map itself; absent that, produce decisions, not deliverables.

## Refer by name

Every map and ticket is a file with a title. In everything the human reads, narration and the map's Decisions so far alike, refer to it by that title, never by a bare number or filename. A wall of `03, 04, 06` is illegible; names read at a glance. The path doesn't vanish, it rides inside the name as a link, never standing in for it.

## The map

The map is `plan/MAP.md`, the canonical artifact; its tickets are files in `plan/tickets/`. A repo running several efforts at once namespaces each as `plan/<effort>/MAP.md` with `plan/<effort>/tickets/`.

The map is an **index**, not a store. It lists the decisions made and points at the tickets that hold their detail; a decision lives in exactly one place, its ticket, so the map never restates it, only gists it and links.

### The map body

The whole map at low resolution, loaded once per session. Open tickets are not listed here; find them by scanning `tickets/`.

```markdown
## Destination

<what reaching the end of this map looks like: the spec, decision, or change
this effort is finding its way to. One or two lines; every session orients to
it before choosing a ticket.>

## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

<!-- the index. One line per resolved ticket: enough to judge relevance, then
zoom the link for the detail the ticket holds -->

- [<resolved ticket title>](tickets/NN-slug.md): <one-line gist of the answer>

## Not yet specified

<!-- see "Fog of war": in-scope fog you can't ticket yet; graduates as the
frontier advances -->

## Out of scope

<!-- see "Out of scope": work ruled beyond the destination; never graduates -->
```

### Tickets

One file per ticket at `plan/tickets/NN-<slug>.md`, numbered from `01`, never a single combined file. The body is the question, sized to one agent session:

```markdown
---
status: open        # open | claimed | resolved | dropped
type: grilling      # grilling | prototype | research | task
blocked-by: []      # ticket filenames, e.g. [04-agent-stack.md]
---

# <title>

## Question

<the decision or investigation this ticket resolves>
```

The answer is not part of the body; it is appended on resolution under `## Answer`. Conversation history appends under `## Comments`. Assets created while resolving are linked from the ticket, not pasted in.

A session **claims** a ticket by setting `status: claimed` first, before any work, so concurrent sessions skip it. That status is the claim: an `open` ticket is unclaimed.

A ticket is **unblocked** when every file its `blocked-by` lists is `resolved` (or `dropped`). The **frontier** is the open, unblocked, unclaimed tickets, the edge of the known; compute it by scanning `tickets/`, first by number wins.

## Ticket types

Every ticket is either **HITL**, human in the loop, worked with a human who speaks for themselves, or **AFK**, driven by the agent alone. A HITL ticket only resolves through that live exchange; the agent never stands in for the human's side of it (a grilling agent that answers its own questions has broken this).

- **Research** (AFK): reading documentation, third-party APIs, or local resources like knowledge bases to surface a fact a decision waits on. Resolved by a background subagent whose findings are appended to the ticket. Use when knowledge outside the current working directory is required.
- **Prototype** (HITL): raise the fidelity of the discussion by making a cheap, rough, concrete artifact to react to: an outline, a rough take, a stub, or UI/logic code, via the prototype skill. Link the prototype as an asset. Use when "how should it look" or "how should it behave" is the key question.
- **Grilling** (HITL): conversation. The default case. Always invoke the grilling and domain-modeling skills.
- **Task** (HITL or AFK): manual work that must happen before a decision can be made; nothing to decide, prototype, or research, but the discussion is blocked until it's done. Signing up for a service so its API can be judged, provisioning access, moving data so its shape can be seen. This is the one type that does rather than decides, and it earns its place by unblocking a decision, not by delivering the destination. The agent drives it alone where it can (AFK); otherwise it hands the human a precise checklist (HITL). Resolved when the work is done; the answer records what was done and any resulting facts (credentials location, new URLs, row counts) later tickets depend on.

## Fog of war

The map is deliberately incomplete: chart only what you can see. Beyond the live tickets lies the **fog of war**, the dim view of decisions and investigations you can tell are coming but can't yet pin down, because they hang on questions still open. Resolving a ticket clears the fog ahead of it, graduating whatever's now specifiable into fresh tickets, one at a time, until the way to the destination is clear and no tickets remain.

The map's **Not yet specified** section is where that dim view is written down: the suspected question, the area to revisit later. It's the undiscovered frontier toward the destination; everything here is in scope, just not sharp enough to ticket. Write as loosely or as fully as the view allows; it doubles as a signpost for collaborators reading where the effort is headed.

**Fog or ticket?** The test is whether you can state the question precisely now, not whether you can answer it now.

- **Ticket when** the question is already sharp, even if it's blocked and you can't act on it yet.
- **Not yet specified when** you can't yet phrase it that sharply. Leave the fog coarse rather than pre-slicing it into ticket-sized pieces: one patch may graduate into several tickets, or none, once the frontier reaches it.

**Not yet specified** excludes what's already decided (Decisions so far), what's already a live ticket, and what's out of scope.

## Out of scope

Fog only ever gathers toward the destination. The destination fixes the scope, so work beyond it is **out of scope**; it isn't fog, and it doesn't belong in Not yet specified. It gets its own **Out of scope** section on the map: work you've consciously ruled out of this effort. Scope, not sharpness, lands it here.

Out-of-scope work never graduates; the frontier stops at the destination. It returns only if the destination is redrawn, and then as a fresh effort, not a resumption.

Ruling something out of scope is a scoping act, not a step on the route. When an existing ticket turns out to sit past the destination, mis-scoped in while charting or exposed by a resolution, set its status to `dropped` (a dropped ticket is unambiguously off the frontier) and leave one line in Out of scope: the gist plus why, linking the dropped ticket. It stays out of Decisions so far, which records the route actually walked; a scope boundary isn't a step on it.

## Invocation

Two modes. Either way, never resolve more than one ticket per session, with the exception of research tickets.

### Chart the map

User invokes with a loose idea.

1. **Name the destination.** Invoke the grilling and domain-modeling skills to pin down what this map is finding its way to: the spec, decision, or change. The destination fixes the scope, so it's settled first.
2. **Map the frontier.** Grill again, breadth-first this time: fan out across the whole space rather than deep on any one thread, surfacing the open decisions and the first steps takeable now. If this surfaces no fog, the way is already clear and the whole journey fits one session: no map needed. Stop and ask the user how they'd like to proceed.
3. **Create the map** at `plan/MAP.md`: Destination and Notes filled in, Decisions so far empty, the fog sketched into Not yet specified.
4. **Create the tickets you can specify now**, then fill in `blocked-by` in a second pass once every ticket has its number. Wiring sorts them into the frontier and the blocked; everything you can't yet specify stays in Not yet specified.
5. **Fire the research subagents.** For each research ticket just created, spin up a background subagent to resolve it in parallel, appending findings to the ticket for the user to ratify.
6. Stop. Charting is one session's work; it hand-resolves nothing.

### Work through the map

User invokes with a map (or the repo has one). A ticket is optional; without one, you pick the next decision, not the user.

1. Load the map: the low-res view, not every ticket body.
2. Choose the ticket. If the user named one, use it. Otherwise take the first frontier ticket in order. **Claim it**: set `status: claimed` before any work.
3. Resolve it per its type, zooming as needed: read the full body of any related or resolved ticket on demand, and invoke whichever skills the map's Notes names. If in doubt, invoke grilling and domain-modeling.
4. Record the resolution: append the answer under `## Answer`, set `status: resolved`, and append a one-line gist plus link to the map's Decisions so far.
5. Add newly surfaced tickets (create, then wire `blocked-by`); graduate any fog the answer has made specifiable, clearing each graduated patch from Not yet specified so it lives only as its new ticket. If the answer reveals a ticket, this one or another, sits beyond the destination, rule it out of scope rather than resolving it on the route. If the decision invalidates other parts of the map, update or delete those tickets.

When the user says a resolved decision was wrong, revise the map: reopen the ticket, record what changed and why beneath the old answer, update its line in Decisions so far, and add a note to any resolved ticket that leaned on it.

The user may run unblocked tickets in parallel, so expect other sessions to be editing `plan/` concurrently.

---

Ported from [mattpocock/skills](https://github.com/mattpocock/skills) wayfinder (MIT), rewritten for local Markdown files with no tracker or companion-skill dependencies.

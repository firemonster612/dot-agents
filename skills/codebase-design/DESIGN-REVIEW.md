# Reviewing a codebase's design

Use this when the target is a codebase or a large area of one, not a change. The goal is a short, ranked list of design problems that are making changes hard, each with a plan that can land on its own. A list of every smell is not the goal.

## 1. Find where change hurts

Start from evidence, not from reading files in order.

- **Size:** `git ls-files -- . ':!*.lock' ':!*-lock.yaml' ':!*.lockb' ':!*.json' ':!*.svg' | xargs wc -l | sort -rn | head -30`, skipping generated and vendored directories. Large files are candidates, not verdicts.
- **Churn:** `git log --since=3.months --format=%h --numstat | awk 'NF==3 {c[$3]+=$1+$2} END {for (f in c) print c[f], f}' | sort -rn | head -30`. A file that is both large and changing often is where design debt costs the most.
- **Change coupling:** files in different modules that keep changing in the same commits, visible in the same log without the `awk`, where each commit's files sit under its hash. Coupled files across a seam mean the seam is in the wrong place or leaks.
- **Duplicated knowledge:** the same rule, constant, schema or switch over the same enum in several modules. Search for the domain terms from `CONTEXT.md`.

## 2. Judge each candidate

For every candidate module, write its job in one sentence. Then check:

- **Several jobs.** A sentence that needs "and", or groups of functions that never call each other, are cues to look closer, not verdicts. Call it several modules only when the parts change for unrelated reasons (separate commits, separate features) and share no rules. A cache that reads and writes the same entries is one job.
- **Depth.** Apply the deletion test. A shallow module, whose interface is nearly as complex as its implementation, is a pass-through to remove or a cluster to deepen; see [DEEPENING.md](DEEPENING.md).
- **Leaks.** Callers that must know a module's internals (call order, private state, formats) mean the interface is wrong.
- **Tests that can't see the bug.** A pure function tested on its own while the code that combines it with state or I/O has no test: bugs hide where it is called. The missing test belongs at that caller's interface, and if no interface can reach the behavior, the seam is in the wrong place.
- **Names.** A module named for its implementation (`utils`, `helpers`, `manager`, `index` with 5,000 lines) has no job yet.

## 3. Plan

Report the five worst problems at most, ranked by how much they slow the changes the churn data shows. For each:

- the problem, with files and line ranges as evidence;
- the target shape, in this skill's vocabulary: which modules, which seams, what each interface hides, and which tests get simpler;
- a sequence of behavior-preserving steps, each small enough to review and land on its own, starting with the step that unblocks the most;
- what it costs to leave it.

Leave out problems in code that rarely changes. A messy module nobody touches costs nothing.

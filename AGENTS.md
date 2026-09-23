# Personal Preferences

Use oxfmt and oxlint when initing react projects instead of eslint and Prettier.

please, when developing web apps or using web tech, do not use native browser prompts/pop ups

when you want to run a command with sudo on an interactive machine with a graphical desktop env on linux, use pkexec

## Terminology

- `workflow/workflows` a claude code specific feature that allows for scripting to control subagents to execute a task.

## Package Managers

- Use pnpm if the project already uses it, otherwise use bun.
- Never use npm or yarn.

## Tech Stack Preferences

When uncertain, prefer: Tailwind, TypeScript, Bun, React, Convex, Clerk, Vercel.

## Code Style

- Always strive for concise, simple solutions.
- Correctness and cleanliness are separate requirements. Prefer clear names, simple control flow, well-placed shared definitions, and code that fits the existing system. Passing tests alone does not make code maintainable.
- If a problem can be solved in a simpler way, propose it.

## General preferences

- If asked to do too much work at once, stop and state that clearly.
- If computer use is helpful for completing or verifying work, shell out to Codex for it.

## Behaviour

- Do the work yourself or delegate it, whichever actually serves the task. You decide, per task. When I want subagents I'll ask for them.
- always prefer your built-in subagent tools rather than calling subagents via the shell.
- Whenever you are going to spin off another model, subagent, or workflow to do anything, always consult the model-selection rubric below on which model to choose. Do not default to your own native model family just because it is convenient.
- always apply the `unslop` skill at the beginning of every chat
- When writing instructions for agents, omit citations, bibliographies, and research narration. Verify the information before writing it as practical guidance.

## When delegating pays

Three reasons, and they're the whole list:

- **Cheaper.** Bulk or mechanical work that a lower tier does just as well, or exploration whose findings are worth more than the context they'd cost you to gather yourself.
- **Faster.** Genuinely independent work that can run in parallel. Serial steps dressed up as parallel ones are slower, not faster.
- **Better.** An independent reviewer who hasn't seen my reasoning, or a fresh context per ticket on a long multi-ticket run.

**Review is the one standing exception: never let the only review of a change be by whoever wrote it.** Independence is the entire mechanism. See the `review-loop` skill. Everything else is a judgement call.

Don't delegate when writing the brief would cost more context than doing the work, when the task is small enough that a round trip dominates, or when I asked a question rather than for a change.

## Delegation hygiene

When you do delegate:

- Point delegates at the worker-facing skills (`writing-code`, `reviewing-code`) by path rather than transcribing their rules into the prompt. A delegate can read files, and a pasted contract drifts from the real one.
- Hand artifacts as **files, not pasted text**: write the task brief and the diff (`git diff -U10 BASE..HEAD > file`) to a scratch file and pass the path. Pasted context stays resident in your context forever; a file path costs nothing.
- **Record the base SHA before dispatching an implementer.** Review and diff `BASE..HEAD`, never `HEAD~1`, which silently drops all but the last commit of a multi-commit task.
- Multi-ticket runs keep a **progress ledger** (`.scratch/<feature-slug>/progress.md`, one line per completed ticket with its issue number and commit range, e.g. `Ticket #42: complete (a1b2c3d..d4e5f6a)`). After compaction, trust the ledger, the tracker's issue states, and `git log` over your own recollection. Never re-dispatch a ticket the ledger or tracker marks complete.
- When a review wave returns findings, dispatch **one fix agent with the full findings list**, not one fixer per finding. Per-finding fixers each rebuild context and re-run suites.
- Never pre-judge findings in a reviewer's dispatch prompt ("don't flag X", "treat as minor at most"). Let the reviewer raise it, then adjudicate the finding yourself afterward.
- A delegate's "success" report is a claim, not evidence: check the diff yourself before relaying it (see the `verification-before-completion` skill).

## Picking the right models for workflows and subagents

Choose the model for the task before dispatch. These defaults apply when the user has not chosen a model. Use native subagents when they support the selected model. Use the CLI only for a model native tools cannot reach. Pass a real supported model ID and an explicit effort level; never dispatch the family name `GPT` or invent a combined model-and-effort ID.

### Routing

| Model | Concrete model ID | Effort | Role |
| --- | --- | --- | --- |
| Opus 5.5 | `claude-opus-5-5` | medium | Default for most code writing, visual design, routine debugging, refactors, ordinary explanations, evidence synthesis and product work |
| GPT-6 Sol | `gpt-6-sol` | medium | Codex interactive default; substantial supporting implementation, source exploration and independent review |
| GPT-6 Luna | `gpt-6-luna` | high | Small noncoding tasks: extraction, classification, summarization and structured transformations with explicit acceptance criteria |
| GPT-6 Astra | `gpt-6-astra` | high | Difficult mechanisms, exhaustive audits, complex debugging and demanding computer use |
| Fable 5 | `claude-fable-5` | medium | Intent interpretation, code cleanliness review, selected design judgment and collaborative explanation |
| Fable 5.1 | `claude-fable-5-1` | high | Alternative design judgment; stalled PR recovery and coupled long-running work where its extra usage is justified |

Opus 5.5 is the ordinary coding and visual-design choice. Review the Code Style criteria separately from runtime correctness. Fable 5 remains available when its particular strengths matter. For Opus, move to high for a difficult task and xhigh for a defined hard phase. Max is an exception requiring a concrete reason; do not assume a higher effort improves the result. Low is not the coding default. Start Sol at medium and Luna at high rather than inheriting the previous generation's effort settings.

Choose review models and effort automatically from the actual change. Assess complexity and the consequences of a missed defect separately. Complexity includes interacting state, concurrency, unfamiliar mechanisms and coupled package boundaries. Risk includes data loss, authorization failures, money movement, destructive migrations, public compatibility and difficult rollback. A small diff can be high risk; a large mechanical diff can be low complexity. Weak tests or uncertain behavior increase the depth needed.

| Review needs | Starting selection |
| --- | --- |
| Bounded, familiar change with limited consequences and clear checks | Fable 5 medium and GPT-6 Sol medium |
| Substantial interacting logic with moderate consequences and a checkable endpoint | Fable 5 medium and GPT-6 Sol high |
| Difficult mechanisms, weak verification of critical behavior, or serious consequences if a defect escapes | Fable 5 medium and GPT-6 Astra high |

Choose each reviewer for the work, rather than treating the pairs as fixed. Select Fable 5.1 high when coupled architectural changes, difficult cleanup or stalled review/recovery specifically need its stronger cross-package judgment. High risk alone is not a reason to upgrade every reviewer. Keep cleanliness and maintainability in scope at every level; both reviewers cover standards and spec.

Use two fresh independent reviewers from different model families for substantial changes. Give them the pinned diff and requirements. Briefly state the selection and the concrete complexity or risk that motivated it, then dispatch without asking the user to choose models. Reassess if findings expose greater complexity or consequences, while keeping the existing review-pass limit. The implementing agent must not be its only reviewer. An explicit user choice of reviewer count, model or number of passes overrides this automatic selection; no override is required.

Retain GPT-5.6 Sol, Terra and Luna, and Opus 5 only as explicit compatibility fallbacks. Read `references/model-routing-legacy.md` only when selecting an older model. Its notes describe those models, not their replacements. Sonnet remains a thin wrapper when a Claude-only workflow cannot call GPT directly. Never use Haiku. When the requested model is unavailable, report the supported substitution.

### Local usage and pricing

The subscription pool is one Claude Max 20x account plus two Max 5x accounts, and one Codex Pro 5x account, behind a load-balancing proxy. Within included usage, both providers have zero incremental cash cost. Account capacity, resets and task completion still matter. A five-percent delta on a 5x account is not equivalent to the same delta on a 20x account.

Standard API prices per million uncached input/cached input/output tokens are Opus 5.5 $4/$0.20/$20, GPT-6 Sol $2/$0.20/$10 and GPT-6 Luna $0.10/$0.01/$0.50. API cache-write and processing premiums are separate. Fable 5.1 API input/cache-read/output prices are $10/$0.25/$50 per million tokens. These prices are not subscription meters.

Standard Codex credits per million uncached input/cached input/output tokens are Astra 250/25/1,250, Sol 50/5/250 and Luna 2.5/0.25/12.5. For an identical token mix, Sol uses one-fifth Astra's credits and Luna one-twentieth Sol's. Model token demand and caching change per-task cost. Fast mode consumes 2.5x Standard Codex credits where available. Prefer Standard unless speed warrants the extra draw.

Treat Claude per-model subscription depletion as unmeasured until account readings establish it. Report token-derived estimates separately from actual five-hour and weekly depletion. Preserve cache locality when the existing proxy supports it, and record the actual returned model when fallbacks occur. Never infer upstream identity solely from the requested model ID.

### Opus 5.5 behavior and dispatch

These are provisional launch-era observations. Revisit them after ordinary work on this setup.

- Use it for complete scoped coding tasks. Give it the requested outcome, files or repository, preserved behavior, and finite checks. Ordinary work starts at medium. It can produce well-organized shared definitions and thorough tests, but medium can still spend substantial reasoning and output on source inspection and fixtures. Require the actual package typecheck even when runtime tests pass; branded-type assertion errors can survive those tests. Keep fixtures focused on required behavior.
- Higher effort can cause long thinking and repeated work. Max has produced multi-hour planning loops with little progress. If progress stalls, inspect the current diff, running commands and remaining acceptance criteria; narrow the task, lower effort or hand it off. Do not answer a stall by increasing effort automatically.
- Long performance tasks can drift into repairs unrelated to the requested improvement. Name the measured bottleneck and behaviors to preserve. A nearby issue belongs in the report unless fixing it is necessary to the task.
- It can worry about the context window and invent explanations about work being lost. State whether the filesystem persists and whether the client compacts automatically. Keep a brief progress record with paths, current state and remaining checks. After compaction, read those artifacts and continue. Require evidence for crash, delay and data-loss claims.
- A progress report can end a turn while requested work remains. Name the full endpoint in the brief, including verification and any explicitly authorized publication steps. Status updates should accompany continued work. A report, a started command and a launched delegate do not establish completion. Preserve genuine user-input blockers.
- Reports are usually clearer than Opus 5's. Use the user's existing writing preferences and ask for literal, concise status. Avoid adding repeated prose restrictions without a demonstrated need.
- It is promising for browser games, Three.js and animation. Start with a working medium-effort version and use a separate refinement phase if needed. Verify controls, frame behavior, lighting, transparency and flicker in the application.
- Use Opus 5.5 for visual design, including marketing pages and frontend polish. The user reports strong results here. Fable 5.1 remains an alternative when a different design approach or further refinement is useful. For an existing product, preserve components, branding, navigation and interaction sequence and name the specific visual changes allowed.
- It may miss issues in an exhaustive codebase review even when its own implementation is good. Keep an independent GPT reviewer; use Astra for deep audits.
- Give multi-application tasks the relevant sources and applications explicitly. It can start acting before discovering context the brief left implicit.
- The model's public API always uses adaptive thinking. Lower effort controls latency more reliably than instructions to stop thinking. Do not carry manual thinking budgets, disabled thinking, or forced tool selection into an integration without checking compatibility.
- Progress updates can arrive in thinking blocks rather than text. An apparently silent run may be a client-rendering issue. Inspect supported progress output before blaming the model or adding repeated prompts.
- Model switches do not guarantee preservation of prior thinking. Pass concrete artifacts and a short state summary to a fresh delegate. Use documented per-message effort changes if supported; changing top-level effort can invalidate cache.

### GPT-6 Sol behavior and dispatch

Use Sol for everyday and complex code work as well as bounded support. Keep its brief tied to a checkable endpoint. Specify repository conventions, the relevant compiler settings and verification command. Use high for a difficult bounded task; use Astra when the work needs stronger judgment or exhaustive reasoning.

For strict TypeScript work, name the actual compiler flags and require the type checker, including `noUncheckedIndexedAccess` when the project uses it. For async work, require checks that observe pending work, scheduling after failure and the exact returned rejection. Inspect the assertions behind its test claims.

Keep the ordinary write-less and verification skills. Sol can write compact production code that fits an existing query architecture, but inspect cross-package type ownership and duplicated defaults. Ask it to reuse a named shared contract rather than restating filter shapes in every caller. New tests must compile and execute; an incorrect import can break a test while production code is sound. Assess cleanliness separately from runtime correctness. Judge long sessions, UI work and ambiguous product tasks by their actual artifacts; escalate when completeness or judgment is inadequate.

### GPT-6 Luna behavior and dispatch

Use Luna for small noncoding tasks with a precise contract: extraction, classification, summarization, and structured data transformations. Give it the source, required output format and a finite correctness check. Do not route implementation, code review, architectural decisions or coupled migrations to Luna. Use Sol for supporting work requiring code judgment and Opus for ordinary implementation.

High is provisional for these noncoding roles. Tune effort against representative tasks; an optimal default has not been established. Its low per-token price does not establish time to completion or factual reliability. Evaluate reliability on representative noncoding tasks before expanding its role.


### GPT-6 Astra behavior and delegation

- Strengths: difficult reasoning, real code and bug fixes, 3D and image understanding, and operating professional software. Use it for compiler rewrites, performance work, complex puzzles, and testing real applications to find and fix edge cases. Difficult puzzles can still require hints; distinguish solving the problem from looking up a published answer.
- It can use a browser or desktop app to verify actual behavior, make a temporary tool to inspect results, edit images in Affinity, and set up and color-correct Final Cut projects. Give it the application, assets, target result, and a concrete way to check success. It is also strong at writing prompts for other agents.
- UI/UX is a weak point despite better code and prose. It can invent a new brand, replace an existing interface during a port, add excessive labels and subtitles, and turn simple actions into complicated flows. For a migration, explicitly preserve the existing components, branding, navigation, and interaction sequence; define exactly which parts may change. Delegate new visual design to Opus 5.5 when that is the central task; use Fable 5.1 for an alternative design judgment.
- It can stop after answering a question, making a local fix, starting subagents, or responding to a side request while the original task remains incomplete. Name the endpoint and keep it active across follow-ups. For authorized PR work, specify the whole loop: fix, verify, commit, push, wait for checks and reviews on the new commit, assess findings, and repeat until ready. Launching workers or making one pass is not completion.
- Vague instructions can produce unwanted initiative while clear next steps still get skipped. Its confidence and summaries can imply delivery even when changes remain local. Require it to report the actual state, such as local edits, commit, pushed branch, PR, checks, or merge, with evidence for what occurred and a clear statement of what remains. Do not infer a push or release from "fixed."
- Earlier mistakes can become a repeated conversational pattern. Give an explicit correction describing future behavior, not just an expression of frustration. If the same failure repeats, hand a fresh agent the current artifacts, outstanding work, and corrected instructions. Carry the intended outcome forward.
- It sometimes asks a question and keeps working as though it received an answer. It has substituted the user's SSH key after asking for a friend's missing key. Specify which missing inputs block dependent work; asking does not authorize a guess. Continue independent work while awaiting the real answer.
- Thorough verification can make simple tasks slow. Define proportionate checks and finish once they pass; repeat only for a change, failure, or unresolved concern. Audit conflicting skill instructions because Astra is unusually sensitive to them. Other tendencies include unnecessary clarification pauses, verbose formatting, and less delegation than a workflow may expect. Request delegation when the task warrants it, within the configured tools and concurrency.
- Early-access runs sometimes stopped on safety alerts during ordinary audits or puzzles. Report the actual interruption and unfinished work. Do not assume the alert pattern or frequency is unchanged at release.

### Fable 5.1 behavior and delegation

Use this model for the specific strengths below when Opus 5.5, Fable 5 or GPT is unlikely to finish as well for less usage.

- It is particularly useful for taking over stalled PRs that have become repeated review/fix loops, finding the important remaining issues, and finishing the change. It is a useful escalation for difficult streaming/projection bugs after other agents stall. Send the current branch, original intent, failed approaches, and full outstanding findings to one takeover agent.
- It handles changes across package boundaries and can carry audit, cleanup, implementation, and review work through an extended task. Examples span server, web, desktop, and mobile packages, as well as cleanup ordered so deletions simplify later PRs. This is a reason to use 5.1 for a coupled change; keep the scope tied to the user's outcome.
- Visual design and animation are specific strengths. Use it as an alternative for marketing pages, tasteful transitions, game movement and feedback, and Blender work when Opus 5.5 needs another design approach. Use Anthropic's frontend design skill for homepage work when available. Visual polish can coexist with awkward controls and incomplete details, so check the interaction as well as its appearance. Prefer Astra for general browser/desktop operation.
- It may run many tool calls with almost no progress text. Ask for brief progress updates when the user or orchestrator needs visibility; silence alone is not a hang.
- Writing is generally clearer, with fewer stock phrases and unexplained jargon, but can become dense and long. Ask for literal language, shorter sentences, and paragraph breaks. Older blanket bans on formatting may now suppress useful structure. When summarizing sources, request marked quotations and attribution; it can reproduce passages without marking them as quotes.
- It can still pause to ask whether to proceed, repair nearby code outside scope, or add too many tests. State the authorized endpoint, preservation constraints, and appropriate verification. For long tasks, identify what compaction must retain: decisions, outstanding work, constraints, and artifact locations.
- Better reasoning does not eliminate confident mistakes about existing behavior. In a PR-linking audit it incorrectly denied automatic linking until corrected. Provide concrete terminology and require source evidence for assertions that a behavior does not exist.
- Stronger delegation can multiply usage rapidly. Assign bounded work and the needed concurrency, and use cheaper GPT models for supporting tasks. Fable 5.1's ability to manage many agents is not a reason to make every worker Fable 5.1.

### Fable 5 and Sonnet behavior

- Fable 5 is a specialist for intent interpretation, code cleanliness review, and selected implementation. It writes concise code that fits an existing system, interprets intent well, knows obscure platforms, and is useful for planning and orchestration. It can favor a clever workaround over addressing the whole problem, skip edge cases, or stop short while believing the result is good enough. Give it the required behavior and preservation constraints; ask the GPT reviewer to investigate missing cases and actual runtime behavior.
- Sonnet 5 mainly runs thin wrappers when a Claude-only workflow needs to call GPT. Keep its brief mechanical and pass through the worker's artifacts without having the wrapper redesign the solution. Use low effort for the wrapper.

### GPT inside Claude Code workflows

Use a thin Claude wrapper only when the workflow's model parameter cannot select GPT directly.

- The wrapper uses `model: 'sonnet', effort: 'low'`, reads `cli-subagents`, and runs `codex exec -m <chosen-gpt-model>` with a concrete supported model ID and explicit effort. Return the worker's report and artifacts; use `schema` for structured output where supported.
- Label workers with the actual model, for example `gpt-6-astra:review-auth`, `gpt-6-sol:migrate-data`, or `gpt-6-luna:classify`. The wrapper's visible model is not the worker's model.
- Parallel implementation workers use `isolation: 'worktree'` or separate checkouts to avoid collisions.
- Workflow token budgets count Claude wrapper usage, not the GPT worker's usage. Track that separately when a budget or account limit matters.

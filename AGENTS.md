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

### Routing

The orchestrator chooses the model for each task. Use **Fable 5 or GPT-6 Astra for most code writing**, including substantial implementation. Choose by the work and the behavior notes below, not by your own model family. Fable 5.1 is an additional option, not a replacement for Fable 5.

- Choose Fable 5 when concise, maintainable code, UI/UX, API design, interpreting product intent, or low-friction collaboration matters most.
- Choose GPT-6 Astra when difficult mechanisms, debugging, broad implementation with a checkable endpoint, computer use, or multimodal reasoning matters most. Its code quality makes it a primary implementer, not just a worker under a Claude-written plan. Give it concrete constraints and completion criteria.
- Choose Fable 5.1 only when its specific strengths justify the extra usage: stalled PR recovery, changes that must stay consistent across several packages, difficult audits and cleanup, extended review-and-fix work, or visual design and animation beyond Fable 5's results. Explain the relevant strength in the dispatch brief. A newer version alone is not a reason to select it.
- Choose GPT-5.6 Terra for bounded, well-specified supporting work and GPT-5.6 Luna for short mechanical work. These remain useful for exploration, classification, and bulk changes; they are not the default for most code writing. GPT-5.6 Sol remains available for focused execution when Astra's overhead or behavior is a poor fit.
- Opus 5 is a fallback for a bounded task that benefits from its diligence or when Claude subscription availability makes it useful. It is not the default implementer or the automatic escalation for hard judgment. Sonnet 5 mainly handles thin workflow wrappers.
- For substantial changes, use one independent Claude reviewer and one independent GPT reviewer, each covering both review axes, per `review-loop`. Normally choose Fable 5 and GPT-6 Astra. Select Fable 5.1 for the review only when one of its strengths above is needed. Match cheaper reviewers to smaller changes.
- Never use Haiku.

`GPT` in a skill means the GPT family, with the concrete model and effort chosen here at dispatch time. It is not an executable model ID and does not mean Sol by default. Pass an actual model ID supported by the current tool or CLI. Prefer native subagent tools; use `cli-subagents` only for a model the native tools cannot reach. If a model is unavailable, choose a supported alternative and report the substitution.

### Local ratings and usage

Updated 2026-09-05. These are provisional routing judgments for this user's setup, not benchmark measurements or vendor specifications. Intelligence, taste, and speed use a relative 1–10 scale. Intelligence means difficulty the model can handle; behavior notes describe how much supervision it needs. Speed means time to useful completion, including verification and rework, not tokens per second. Taste covers code and product design; Astra's UI weakness needs its own rating.

Cost scores run from 1–100, higher meaning less personal cost or usage pressure. Codex use has no incremental monetary cost to this user, so GPT models share 100 here; that does not mean their API prices, token use, or subscription limits are identical. Terra and Luna can still reduce latency and reserve frontier-model quota when account metering distinguishes models. Check actual limits. Claude scores are rough local preferences, not measured ratios.

| Model | Personal cost score | Intelligence | Taste | Speed | Default effort | Role / usage consideration |
| --- | --- | --- | --- | --- | --- | --- |
| GPT-6 Astra | 100 | 10 | 8 code / 5 UI | 5 | high | Primary coder; difficult reasoning and computer use; excessive verification can dominate small tasks |
| GPT-5.6 Sol | 100 | 8.5 | 6 | 8 | high | Focused execution fallback; relatively efficient, but code can grow too much |
| GPT-5.6 Terra | 100 | 6.5 | 5 | 9 | medium | Bounded supporting work; lower capability than Sol or Astra |
| GPT-5.6 Luna | 100 | 6 | 4 | 10 | low | Short mechanical tasks; avoid difficult autonomous work |
| Sonnet 5 | 10 | 5 | 7 | 4 | medium | Thin wrappers; limited reason to use for substantial work |
| Opus 5 | 50 | 7 | 8 | 3 | high | Diligent but unpredictable; verification overhead can dominate bounded tasks |
| Fable 5 | 20 | 9 | 9 | 6 | medium | Primary coder; strong intent, code taste, and collaboration |
| Fable 5.1 | 10 | 10 | 10 | 5 | high | Selective upgrade; significantly more usage per task in this setup |

Budget more usage per task for Fable 5.1 than Fable 5. It generates more output, takes on broader tasks, and can multiply usage through delegation. Use it only when its specific strengths justify that cost.

Separate subscription usage from API cost. As of September 2026, Fable 5.1 API pricing is $10 input / $50 output per million tokens, with cache reads at $0.25 per million. Cheaper cache reads can offset some additional output cost in agentic workloads. Compare actual task costs rather than assuming either version is always cheaper.

The table is the source of truth for default effort. Effort changes how long a model reasons; it does not change its capability tier. Escalate to Astra when work exceeds the selected tier. In normal routing, Sol, Opus 5, and Fable 5 stop at high; Fable 5.1 starts at high, with limited observed benefit from going higher. An explicit configured task override takes precedence.

### GPT-6 Astra behavior and delegation

- Strengths: difficult reasoning, real code and bug fixes, 3D and image understanding, and operating professional software. Use it for compiler rewrites, performance work, complex puzzles, and testing real applications to find and fix edge cases. Difficult puzzles can still require hints; distinguish solving the problem from looking up a published answer.
- It can use a browser or desktop app to verify actual behavior, make a temporary tool to inspect results, edit images in Affinity, and set up and color-correct Final Cut projects. Give it the application, assets, target result, and a concrete way to check success. It is also strong at writing prompts for other agents.
- UI/UX is a weak point despite better code and prose. It can invent a new brand, replace an existing interface during a port, add excessive labels and subtitles, and turn simple actions into complicated flows. For a migration, explicitly preserve the existing components, branding, navigation, and interaction sequence; define exactly which parts may change. Delegate new visual design to Fable when that is the central task.
- It can stop after answering a question, making a local fix, starting subagents, or responding to a side request while the original task remains incomplete. Name the endpoint and keep it active across follow-ups. For authorized PR work, specify the whole loop: fix, verify, commit, push, wait for checks and reviews on the new commit, assess findings, and repeat until ready. Launching workers or making one pass is not completion.
- Vague instructions can produce unwanted initiative while clear next steps still get skipped. Its confidence and summaries can imply delivery even when changes remain local. Require it to report the actual state, such as local edits, commit, pushed branch, PR, checks, or merge, with evidence for what occurred and a clear statement of what remains. Do not infer a push or release from "fixed."
- Earlier mistakes can become a repeated conversational pattern. Give an explicit correction describing future behavior, not just an expression of frustration. If the same failure repeats, hand a fresh agent the current artifacts, outstanding work, and corrected instructions. Carry the intended outcome forward.
- It sometimes asks a question and keeps working as though it received an answer. It has substituted the user's SSH key after asking for a friend's missing key. Specify which missing inputs block dependent work; asking does not authorize a guess. Continue independent work while awaiting the real answer.
- Thorough verification can make simple tasks slow. Define proportionate checks and finish once they pass; repeat only for a change, failure, or unresolved concern. Audit conflicting skill instructions because Astra is unusually sensitive to them. Other tendencies include unnecessary clarification pauses, verbose formatting, and less delegation than a workflow may expect. Request delegation when the task warrants it, within the configured tools and concurrency.
- Early-access runs sometimes stopped on safety alerts during ordinary audits or puzzles. Report the actual interruption and unfinished work. Do not assume the alert pattern or frequency is unchanged at release.

### Fable 5.1 behavior and delegation

Use this model for the specific strengths below when Fable 5 or GPT is unlikely to finish as well for less usage.

- It is particularly useful for taking over stalled PRs that have become repeated review/fix loops, finding the important remaining issues, and finishing the change. It is a useful escalation for difficult streaming/projection bugs after other agents stall. Send the current branch, original intent, failed approaches, and full outstanding findings to one takeover agent.
- It handles changes across package boundaries and can carry audit, cleanup, implementation, and review work through an extended task. Examples span server, web, desktop, and mobile packages, as well as cleanup ordered so deletions simplify later PRs. This is a reason to use 5.1 for a coupled change; keep the scope tied to the user's outcome.
- Visual design and animation are specific strengths. It produces better marketing pages, tasteful transitions, game movement and feedback, and useful Blender work. Use Anthropic's frontend design skill for homepage work when available. Visual polish can coexist with awkward controls and incomplete details, so check the interaction as well as its appearance. Prefer Astra for general browser/desktop operation.
- It may run many tool calls with almost no progress text. Ask for brief progress updates when the user or orchestrator needs visibility; silence alone is not a hang.
- Writing is generally clearer, with fewer stock phrases and unexplained jargon, but can become dense and long. Ask for literal language, shorter sentences, and paragraph breaks. Older blanket bans on formatting may now suppress useful structure. When summarizing sources, request marked quotations and attribution; it can reproduce passages without marking them as quotes.
- It can still pause to ask whether to proceed, repair nearby code outside scope, or add too many tests. State the authorized endpoint, preservation constraints, and appropriate verification. For long tasks, identify what compaction must retain: decisions, outstanding work, constraints, and artifact locations.
- Better reasoning does not eliminate confident mistakes about existing behavior. In a PR-linking audit it incorrectly denied automatic linking until corrected. Provide concrete terminology and require source evidence for assertions that a behavior does not exist.
- Stronger delegation can multiply usage rapidly. Assign bounded work and the needed concurrency, and use cheaper GPT models for supporting tasks. Fable 5.1's ability to manage many agents is not a reason to make every worker Fable 5.1.

### Opus 5 behavior and delegation

Favor bounded tasks over unsupervised work with ambiguous requirements. Review the actual code before treating an Opus implementation as ready to merge.

- Useful traits: diligence, good clarifying questions, persistence, and catching edges Fable can miss. It can provide a useful second view on a bounded plan or implementation. Its code taste is generally better than GPT-5.6's, but below Fable's.
- It can turn uncertainty into repeated double-, triple-, and quadruple-checking, write more code than Fable, and take substantially longer. Give it the actual difficulty, smallest acceptable scope, and a finite verification endpoint. Thoroughness alone does not justify further work.
- When asked to publish an HTML plan, it opened a browser for an unsolicited visual check, acknowledged a request to stop, then opened it twice more. It blamed the publishing tool without evidence before retracting the claim. Give clear tool-use boundaries and check that corrections changed its actions. Demand evidence for causal explanations rather than accepting a confident apology.
- It can follow explicit instructions well, but conflicting system prompts, skills, and repeated restrictions can over-constrain it. Use one coherent task brief. Its tendency to fill gaps with unsupported explanations makes it a poor automatic choice for ambiguous, unsupervised work. It has less factual knowledge than Fable, so prefer Fable for obscure platforms and knowledge-heavy tasks, and verify factual claims against sources when using Opus.
- Lower API prices do not guarantee proportional savings. Opus can use more tokens per task than Fable and spend substantial time checking. Raw token counts do not map one-to-one to subscription usage because pricing and model-specific allowances and metering differ. Subscription allowances have permitted more Opus work than Fable work. Check current account limits.

### Other models' behavior

- Fable 5 remains a primary coding model. It writes concise code that fits an existing system, interprets intent well, knows obscure platforms, and is useful for planning and orchestration. It can favor a clever workaround over addressing the whole problem, skip edge cases, or stop short while believing the result is good enough. Give it the required behavior and preservation constraints; ask the GPT reviewer to investigate missing cases and actual runtime behavior.
- GPT-5.6 Sol is useful for focused execution, system tasks, and difficult mechanisms when the scope is clear. It is literal and produces too much code or tests or expands a fix. Give it explicit acceptance criteria and existing code examples, then use a Fable review for simplification and design quality. Its ratings and these observations are specific to Sol, not the whole GPT family.
- GPT-5.6 Terra is the bounded supporting worker. Give it concrete inputs, files, and a checkable output; escalate when the task requires substantial inference or judgment. GPT-5.6 Luna is for short mechanical tasks with obvious correctness checks. Raising effort does not make either a substitute for Astra on hard autonomous work.
- Sonnet 5 mainly runs thin wrappers when a Claude-only workflow needs to call GPT. Keep its brief mechanical and pass through the worker's artifacts without having the wrapper redesign the solution. Use low effort for the wrapper.

### GPT inside Claude Code workflows

Use a thin Claude wrapper only when the workflow's model parameter cannot select GPT directly.

- The wrapper uses `model: 'sonnet', effort: 'low'`, reads `cli-subagents`, and runs `codex exec -m <chosen-gpt-model>` with a concrete supported model ID and explicit effort. Return the worker's report and artifacts; use `schema` for structured output where supported.
- Label workers with the actual model, for example `gpt-6-astra:review-auth`, `gpt-5.6-terra:migrate-data`, or `gpt-5.6-luna:classify`. The wrapper's visible model is not the worker's model.
- Parallel implementation workers use `isolation: 'worktree'` or separate checkouts to avoid collisions.
- Workflow token budgets count Claude wrapper usage, not the GPT worker's usage. Track that separately when a budget or account limit matters.

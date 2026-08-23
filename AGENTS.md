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

### Model routing: answer two questions for every spawn (subagent, workflow, or CLI)

This is the routing procedure. Everything below it in this section (rankings, effort guidance, mechanics) is reference for executing the decision, never an alternative way to make it.

**Q1: Family.** Does the output need taste (user-facing UI, copy, API/SDK design) or peak judgment (ambiguous architecture, high-stakes review)?

- **Yes → Claude** (opus-5 or fable-5, via the Agent/Workflow model param). sonnet-5 exists mainly as a thin wrapper for Codex calls inside workflows.
- **No → GPT-5.6 via Codex** for exploration, investigation, implementation, debugging, analysis, and bulk work.

This split is a **cost** argument, not a capability one. opus-5 and Sol are close on raw intelligence, but Codex tokens are free to me and Claude's aren't. So route the work Codex handles well to Codex because it's free, not because Claude couldn't. Where a native Claude subagent is markedly better suited, like a broad `Explore` fan-out or a diff you're already holding in context, take it and don't apologise for it.

**Q2: Tier within the family.** Judge by the cost of the model being under-qualified:

- Trivial, mechanical, high-volume → Luna
- Ordinary, well-specified → Terra
- Hard, ambiguous, long-running, high-stakes → Sol / opus-5, with fable-5 for the very hardest judgment problems

### Reference: rankings, effort, and mechanics

Rankings, higher = better. Cost reflects what I actually pay, not list price. Intelligence is how hard a problem you can hand the model unsupervised. Taste covers UI/UX, code quality, API design, and copy. Speed is real-world task completion speed at the model's default effort: throughput plus time-to-first-token plus token efficiency, derived from Artificial Analysis measurements (2026-07-09), not raw tokens/s.

| model         | cost    | intelligence | taste | speed | default effort |
| ------------- | ------- | ------------ | ----- | ----- | -------------- |
| gpt-5.6 Sol   | 65/100  | 9            | 6     | 7     | high           |
| gpt-5.6 Terra | 85/100  | 6.5          | 5     | 9     | high           |
| gpt-5.6 Luna  | 100/100 | 6            | 4     | 10    | high           |
| sonnet-5      | 10/100  | 5            | 7     | 4     | medium         |
| opus-5        | 50/100  | 9            | 8     | 6     | high           |
| fable-5       | 20/100  | 10           | 9     | 5     | high           |

How to apply:

- In GPT-5.6 model names, `5.6` is the generation. `Sol`, `Terra`, and `Luna` are separate capability tiers, not aliases or reasoning-effort settings.
- GPT-5.6 Sol is the flagship. Use it for the hardest coding, long-running agent work, computer use, difficult debugging, and work where correctness matters more than latency. The scores above are based on Sol; do not transfer its intelligence score to Terra or Luna.
- GPT-5.6 Terra is the balanced daily driver. It costs much less than Sol. Use it for ordinary implementation, research, planning, and analysis when Sol would be wasteful.
- GPT-5.6 Luna is the fastest and cheapest tier. Use it for small, clear tasks, high-volume mechanical work, summaries, classification, and thin wrapper agents. Do not route hard reasoning, architecture, or autonomous long-running work to Luna just because it is in the 5.6 family.
- Effort controls how much inference-time work one model spends. It does not turn Luna into Terra, Terra into Sol, or Opus into Fable. Move up a model tier when a task exceeds the lower tier's strengths; raise effort when the chosen model fits the task but needs more time to think.
- GPT-5.6 Sol: use `high` for normal hard work. ignore everything above for this model
- GPT-5.6 Terra: use `medium` for everyday coding, research, and planning. Raise it to `high` for a bounded difficult task. Prefer Sol over pushing Terra to `xhigh` or `max` for high-stakes or long-running work; Terra is the balanced, lower-cost tier.
- GPT-5.6 Luna: use `low` for short mechanical work and `medium` when a cheap task needs a little judgment. Do not spend `high`, `xhigh`, or `max` effort trying to make Luna solve a Sol-class problem. OpenAI identifies Luna as the faster, lower-intelligence fallback, even though published evaluations show that it too improves as reasoning increases.
- 5.6 is VERY literal, it will not try to find the deeper intent of your prompt but instead will follow it literally and exactly word for word almost. So be very specific when calling 5.6

- Sonnet 5: use `medium` by default. Anthropic's cost/performance tests favor medium effort, while higher effort closes some of the gap to the Opus tier on agentic search and computer-use tasks. Use `high` for sustained implementation or messy debugging and `xhigh` when keeping Sonnet is more useful than switching models. For judgment-heavy work, switch to Opus or Fable instead of paying for repeated Sonnet retries.

- Opus 5: use `high` by default, dont use anything reasoning-effort above that.
- Opus 5 is more thorough than fable but has some strange behaviours like doing way too much work, writing way too many tests, trying to verify too much, and will try to approach every problem like it is the hardest problem, and will try to bruteforce the hell out of everything.

- Fable 5: use `medium` by default. Use `high` for ambiguous architecture, research, difficult reviews, and long autonomous work. ignore efforts above high for this model. For refrence on deepswe the coding benchmark fable scored
- 65% on medium
- 69% on high

- Don't let cost prevent you from using the right model for the job. Instead, take advantage of cheaper options to get more information and try things before moving the work to a more expensive option.
- Bulk or mechanical work: use GPT-5.6 Luna for small, independent, high-volume tasks. Use GPT-5.6 Terra for clear-spec implementation, data analysis, and migrations that still need sustained reasoning.
- Anything user-facing (UI, copy, API design) needs taste >= 7.
- Reviews of plans and implementations: use fable-5 or opus-5 for judgment and taste, plus GPT-5.6 Sol for an independent execution-focused review. One reviewer per family, each covering both axes, per the `review-loop` skill.
- Never use Haiku.

#### Using GPT-5.6 inside Claude Code workflows (ONLY inside workflows: their model parameter only takes Claude models, so use a wrapper)

This wrapper pattern applies to workflows alone. Everywhere else, including when you are a plain subagent, call Codex directly through the shell per the `cli-subagents` skill; never insert a wrapper agent.

- Spawn a thin Claude wrapper agent with `model: 'sonnet', effort: 'low'` whose prompt tells it to read the `cli-subagents` skill and delegate the task through it to `codex exec -m <chosen-gpt-5.6-tier>`, then return the report (use `schema` on the wrapper to get structured output back).
- Always label these agents with the actual GPT-5.6 tier, such as `gpt-5.6-sol:review-auth`, `gpt-5.6-terra:migrate-data`, or `gpt-5.6-luna:classify`. The workflow UI shows the wrapper's Claude model, so the label is the only indication of the real worker and tier.
- Parallel GPT-5.6 implementation agents must use `isolation: 'worktree'` so Codex edits don't collide in the shared checkout.
- Workflow token budgets only count Claude tokens; codex work is free and invisible to `budget.spent()`.
- When writing and reviewing code, remember that GPT-5.6 has a low taste score. It generates functional code, but it is often too complex and has poor API and SDK taste. Always use Opus and an independent GPT-5.6 Sol subagent to review substantial code, no matter which model wrote it.

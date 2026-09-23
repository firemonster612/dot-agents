# Legacy model guidance

Read only when an older model is explicitly selected. Current routing and effort choices in AGENTS.md take precedence. These are historical, generation-specific judgments; do not transfer them to new models.

## Historical ratings and usage

Updated 2026-09-05. These are provisional routing judgments for this user's setup, not benchmark measurements or vendor specifications. Intelligence, taste, and speed use a relative 1–10 scale. Intelligence means difficulty the model can handle; behavior notes describe how much supervision it needs. Speed means time to useful completion, including verification and rework, not tokens per second. Taste covers code and product design.

Cost scores run from 1–100, higher meaning less personal cost or usage pressure. Codex use has no incremental monetary cost to this user, so GPT models share 100 here; that does not mean their API prices, token use, or subscription limits are identical. Terra and Luna can still reduce latency and reserve frontier-model quota when account metering distinguishes models. Check actual limits. Claude scores are rough local preferences, not measured ratios.

| Model | Personal cost score | Intelligence | Taste | Speed | Default effort | Role / usage consideration |
| --- | --- | --- | --- | --- | --- | --- |
| GPT-5.6 Sol | 100 | 8.5 | 6 | 8 | high | Focused execution fallback; relatively efficient, but code can grow too much |
| GPT-5.6 Terra | 100 | 6.5 | 5 | 9 | medium | Bounded supporting work; lower capability than Sol or Astra |
| GPT-5.6 Luna | 100 | 6 | 4 | 10 | low | Short mechanical tasks; avoid difficult autonomous work |
| Opus 5 | 50 | 7 | 8 | 3 | high | Diligent but unpredictable; verification overhead can dominate bounded tasks |

For these older models, use the historical effort defaults above unless the task explicitly overrides them. Current model roles, pricing and escalation decisions belong to AGENTS.md.

## Opus 5 behavior and delegation

Favor bounded tasks over unsupervised work with ambiguous requirements. Review the actual code before treating an Opus implementation as ready to merge.

- Useful traits: diligence, good clarifying questions, persistence, and catching edges Fable can miss. It can provide a useful second view on a bounded plan or implementation. Its code taste is generally better than GPT-5.6's, but below Fable's.
- It can turn uncertainty into repeated double-, triple-, and quadruple-checking, write more code than Fable, and take substantially longer. Give it the actual difficulty, smallest acceptable scope, and a finite verification endpoint. Thoroughness alone does not justify further work.
- When asked to publish an HTML plan, it opened a browser for an unsolicited visual check, acknowledged a request to stop, then opened it twice more. It blamed the publishing tool without evidence before retracting the claim. Give clear tool-use boundaries and check that corrections changed its actions. Demand evidence for causal explanations rather than accepting a confident apology.
- It can follow explicit instructions well, but conflicting system prompts, skills, and repeated restrictions can over-constrain it. Use one coherent task brief. Its tendency to fill gaps with unsupported explanations makes it a poor automatic choice for ambiguous, unsupervised work. It has less factual knowledge than Fable, so prefer Fable for obscure platforms and knowledge-heavy tasks, and verify factual claims against sources when using Opus.
- Lower API prices do not guarantee proportional savings. Opus can use more tokens per task than Fable and spend substantial time checking. Raw token counts do not map one-to-one to subscription usage because pricing and model-specific allowances and metering differ. Subscription allowances have permitted more Opus work than Fable work. Check current account limits.

## GPT-5.6 behavior

- GPT-5.6 Sol is useful for focused execution, system tasks, and difficult mechanisms when the scope is clear. It is literal and produces too much code or tests or expands a fix. Give it explicit acceptance criteria and existing code examples, then use a Fable review for simplification and design quality. Its ratings and these observations are specific to Sol, not the whole GPT family.
- GPT-5.6 Terra is the bounded supporting worker. Give it concrete inputs, files, and a checkable output; escalate when the task requires substantial inference or judgment. GPT-5.6 Luna is for short mechanical tasks with obvious correctness checks. Raising effort does not make either a substitute for Astra on hard autonomous work.

---
name: review-loop
description: At the end of a change, review the changes in a loop. Only invoke if a skill asks or the user asks.
---

# Review Loop

**Review loop** process

> Note: if you have access to dynamic workflows (basically, if you're running in Claude Code), script this loop as a workflow; otherwise run it by hand.

1.  Dispatch a GPT review subagent and a Claude review subagent in parallel on `BASE..HEAD`, using the `codex-review` and `claude-review` skills.
2.  Triage the compiled findings before fixing anything: verify each cited hunk yourself and drop findings that don't hold up — reviewer output is evidence, not orders.
3.  Dispatch ONE fix implementer subagent with the full verified findings list (not one fixer per finding).
4.  Repeat review → triage → fix until neither reviewer has remaining complaints or concerns, or you reach 2 iterations (or another count if the user specified one).

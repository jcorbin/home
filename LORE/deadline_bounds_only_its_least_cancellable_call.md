---
kind: lore
tags: [go, concurrency, anti-pattern, diagnosis, recurring]
created: 2026-08-11
sources: [pivoker LORE/deadline_bounds_only_its_least_cancellable_call.md, pivoker TADA/1199, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A `context.WithTimeout` bounds only the calls that actually thread ctx down

## The mechanism

A deadline binds a call only if the ctx reaches something that observes it —
`exec.CommandContext`, a `select`, a ctx-aware client. **One ctx-less helper
manufacturing `context.Background()` inside is an invisible hole** that reads as
bounded and tests green.

It is *disproportionately likely to be the stall you are hunting*, because it is
also the call nobody has reasoned about. Recorded: a status survey was
cancellable in 8 of 9 sections. The ninth hardcoded `Background()` and ran
**first** — exactly the window whose symptom, a placeholder that never advances
at all, was the one being reported.

## Fail-soft does not cover this

Fail-soft degrades a section that **errors**. A **hang** produces no error to
degrade. And once the deadline does fire, cancellation flowing into those same
fail-soft paths yields a complete-*looking* report full of "unknown"s.

## The rule

1. **Grep `context.Background()` under any deadline.** That is the whole search.
2. **Fix additively**: add `XContext(ctx, …)` and keep the old name as a
   wrapper, so callers migrate without a flag day.
3. **Also run the work on a goroutine and `select` on the deadline**, so the
   bound survives the *next* ctx-less probe someone adds — gating any outward
   write the leaked goroutine still owns.
4. **Check `ctx.Err()` between steps and bail**, rather than continuing into a
   fail-soft cascade.
5. **Record WHICH step was in flight**, not just that time ran out. That one
   field is usually the entire diagnosis.

## A refutation worth keeping

A stale git `index.lock` **cannot** cause a hang: read plumbing (`ls-tree`,
`show`, `log`) never touches the index, and even a writer fails fast rather than
blocking. Refuted in 30 seconds — the kind of check worth spending before a
theory becomes the plan.

## Siblings

- [[positive_signal_not_ctx_cancellation]] — the other half of "ctx carries less
  meaning than you think".
- [[adjacent_log_line_is_not_evidence]] — the discipline that would have caught
  the wrong theory sooner.

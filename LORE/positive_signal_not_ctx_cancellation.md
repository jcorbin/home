---
kind: lore
tags: [go, concurrency, pattern, anti-pattern, recurring]
created: 2026-08-11
sources: [pivoker LORE/positive_signal_not_ctx_cancel.md, pivoker LORE/ctx_cancellation_targeted_vs_shutdown.md, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Arm an explicit flag for the special path — ctx cancellation encodes no intent

## The mechanism

`ctx.Done()` tells you the context was cancelled. It does **not** tell you
*why*, and the two reasons that matter are usually opposites:

- **targeted cancel** — this specific piece of work is being called off, and
  cleanup should take the special path;
- **shutdown** — everything is stopping, and the special path is wrong.

Worse, you often cannot even distinguish them by inspection, because a
`defer cancel()` in the *same frame* fires on the normal return path too. LIFO
defer ordering then decides what your handler observes, which means the
behaviour depends on declaration order somewhere else in the function.

## The rule

**Carry intent in an explicit signal, not in the absence of one.**

Set a flag, send a typed value on a channel, or pass a cause — something that
says *"this is the targeted case"* affirmatively. Then the cleanup path branches
on a fact rather than on an inference from cancellation.

Go's `context.WithCancelCause` / `context.Cause` makes this cheaper than it used
to be, but the rule is older than the API: **a signal that means "something
ended" cannot be overloaded to mean "this particular thing ended, on purpose".**

## Siblings

- [[deadline_bounds_only_its_least_cancellable_call]] — the other half of "ctx
  carries less than you think".
- [[a_wait_with_no_named_producer_is_a_drop]] — the same "absence is not a
  signal" family, at the lifecycle level.

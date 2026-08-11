---
kind: lore
tags: [state, health, pattern, diagnosis, recurring]
created: 2026-08-11
sources: [pivoker LORE/elided_writes_break_timestamp_liveness.md, pivoker TADA/1280, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# If a writer may skip a no-op write, that file's timestamp cannot tell you when the writer last ran

## The mechanism

A file's mtime answers **"when did the content last change"**. It answers *"when
did the writer last run"* only if the writer writes unconditionally. The moment
someone adds a sensible no-op elision, any freshness check aging that file is
reading a signal **the writer never agreed to provide**.

Worked case: a capabilities file was written only on change; a rubric warned if
it was older than 24h. Result — a **permanent** warning on the *healthiest*
hosts, the ones whose capabilities never change. The offered automatic fix
routed back through the same elision and was therefore a guaranteed no-op: a
self-healing affordance that could never heal. It went unnoticed for a month
because the warning looked like a known grumble.

## The tell

A comment asserting **another component's** behaviour — *"the daemon rewrites
this on every tick"* — which was simply false.

> **When a rubric's justification NAMES another component, go read it.** That
> sentence is a claim, not a citation.

## The rule

Pick one, deliberately:

- **interval-floor the writer** so it touches the file even when nothing
  changed;
- **keep a separate `verified_at` / heartbeat** distinct from the content
  timestamp; or
- **delete the freshness dimension** — it may not be earning its keep.

Whichever you pick: **write cadence and warn threshold are a matched pair.**
Pin the margin with a test, because "keep these in sync" comments are exactly
what let them drift.

## Siblings

- [[committed_is_not_running]] — the same "an absence is not evidence of
  liveness" family.
- [[a_wait_with_no_named_producer_is_a_drop]] — a quiet state that looks healthy
  while nothing is happening.

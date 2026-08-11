---
kind: lore
tags: [anti-pattern, architecture, observability, bug-saga, recurring]
created: 2026-08-11
sources: [pivoker LORE/silent_failure_log_and_swallow.md, pivoker TADA/devoker/03, pivoker TADA/devoker/444, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Silent failure masked by log-and-swallow is the most expensive bug class there is

## The mechanism

Two individually sound disciplines conspire:

- a hook or wrapper's **"never block the user's operation"** rule, and
- a daemon's defensive **early-return-on-error** paths.

Both turn a real bug into a quiet no-op. The operation succeeds, the log line
scrolls past, and the failure stays invisible for days or weeks.

Roll-call from one codebase: a missing git identity in a container made every
commit fail with exit 128, masked **for weeks**; an agent read EOF and quietly
did nothing; a scanner/dispatcher wedged with no loud signal; a state watermark
silently failed to advance.

## The remedy that recurs

1. **Per-exit distinct logging.** Every early-return and error path gets its own
   distinguishable line, not a shared generic one. *"It failed"* is useless;
   *"it failed at the git-identity check"* is bisectable.
2. **Downstream log-content assertions.** Tests assert the *specific* line was
   (or was not) emitted, so a regression that re-routes into a swallow path is
   caught by the suite rather than by a human weeks later.
3. **Sentinel files over rendered reads.** A path that should have run drops a
   sentinel; the test checks the sentinel rather than parsing output that a
   no-op can fake.

## The tension to hold

"Never block the push" and "never early-return-swallow" are **both right**. The
resolution is **fail loud without failing the operation**: do the defensive
thing, but emit an unmistakable, distinct, test-asserted signal on the way out.

A swallow without a loud, specific, tested log line is a future multi-week
debugging session waiting to happen.

## Siblings

- [[a_probe_failure_must_not_render_as_an_answer]] — the same "an error became a
  value" transformation, one layer up.
- [[seam_injection_for_testability]] — sentinel and recorded-call assertions are
  how you test these paths at all.

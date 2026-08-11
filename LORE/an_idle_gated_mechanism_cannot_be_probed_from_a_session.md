---
kind: lore
tags: [measurement, probe-design, agent-harness, process-hazard, recurring]
created: 2026-08-11
sources: [pivoker LORE/idle_gated_mechanism_cannot_be_probed_from_a_session.md, pivoker TADA/1525, pivoker TADA/1529, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A mechanism gated on the system being idle cannot be watched from inside a live session

## The mechanism

The session **is** what holds every idle gate shut. Probe and subject are
mutually exclusive by construction: for as long as you are watching, the thing
you want to observe cannot run.

This misdiagnoses beautifully. One session read it as a branch-ordering problem;
another re-derived the same wrong answer later wearing a different hat.
**Re-filing for later does not help — "later" is still a session.**

Distinct from *"the mechanism ran and I read the wrong trace"*: here it
genuinely never runs while watched.

## The shape that worked

1. **Arm a threshold so the FIRST increment fires** — 0→1, never a streak that
   needs several idle rounds you will never get.
2. **Put it behind a live-reloadable setting**, so landing the change *is*
   deploying it.
3. **Make the disarm ride the mechanism under test.** The mechanism's own
   delivered output reads a banner, restores the real value, and deletes the
   banner — so **the cleanup is the evidence**.
4. **Back it with a passive fallback that does not itself hold the gate shut.**
   Anything queued as *runnable* makes the work-pending count non-zero, which
   gates shut the very producer you are probing. Park it as not-yet-ready.

## Two things this shape does not give you

- **Pulses already in flight still land after the disarm.** Budget for a late
  wake whose instructions must stay safe post-disarm.
- **It is not repeatable.** Reaching for it twice on the same mechanism means
  the finding is *"this needs a manual trigger"*, not *"probe harder"*.

## Siblings

- [[probe_the_turn_not_its_side_effects]] — the mechanism runs and the observer
  reads the wrong trace. When nothing records the run at all, this entry takes
  over.
- [[committed_is_not_running]] — the arming half of the same problem.

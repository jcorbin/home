---
kind: lore
tags: [lifecycle-hazard, architecture, directive, bug-saga, recurring]
created: 2026-08-11
sources: [pivoker LORE/escalation_park_liveness_hole.md, pivoker LORE/periodic_rewake_needs_producer_stamp.md, pivoker TADA/1136, pivoker TADA/1335, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Waiting is the one state that looks correct while doing nothing — name what will end it

## The mechanism

Every other broken state looks broken. A blocked, parked, deferred or
waiting-on-X item looks **exactly like a healthy one**: quiet, accounted for,
somebody else's turn. Nothing surfaces a wait that no mechanism can satisfy,
because such an item is silent in precisely the way a healthy wait is silent.

So the question at the moment you park is **not** whether the wait is justified.
It is: **what concretely will end it?**

If you cannot name a producer, you are not parking. **You are dropping.**

Two recorded instances:

- an escalation parked with a timestamp and an expired marker, and **nothing
  aged it** — no re-surface existed until one was built;
- an item parked on an *event* with no producer. The re-wake mechanism available
  was time-shaped, the condition was not elapsed time, so the author correctly
  declined it — and the item **sat seven days** with nothing watching.

## The matched pair

The two halves are the same noun from opposite sides:

- **the defect** — a wait with no producer stamp at all (this entry);
- **the fix's own failure mode** — a periodic re-wake keyed only on a fixed
  origin timestamp **re-fires every tick forever** once crossed. It needs a
  persisted, producer-side *last-surfaced* stamp gated on the interval. A
  consumer-deleted marker cannot serve as that throttle.

## The rule

**Write down what emits the event that ends this wait.** If nothing does:

1. build the producer, or
2. fall back to a defensible time-shaped nudge, or
3. **do not park.**

And scope the rule wide. Stated narrowly ("this applies to escalations"), it
read as *"not my case"* to the ordinary park that then cost a week.

## Siblings

- [[positive_signal_not_ctx_cancellation]] — the same "absence is not a signal"
  family, at the call level.
- [[committed_is_not_running]] — any mechanism whose evidence of working is an
  absence needs a separate liveness check.

---
kind: lore
tags: [measurement, evidence-quality, diagnosis, process-hazard, recurring]
created: 2026-08-11
sources: [pivoker LORE/probe_the_turn_not_its_side_effects.md, pivoker TADA/1329, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Probe the run, not what the run happened to produce

## The mechanism

A side-effect counter cannot separate **"never ran"** from **"ran, correctly
decided there was nothing to do, and exited clean"**. For any sequencer, sweep,
drain or scheduled job, the second case is *most executions* — so the counter
reads a healthy steady state as death.

The recorded instance was filed on `zero commits authored by <component>`. The
count was **accurate** and the inference was wrong: 39 transcript events showed
the component running throughout, authoring nothing because a pass over a queue
with nothing to do reviews it and exits clean. The task chased a stall that had
been fixed four days earlier.

No new instrumentation was needed. The transcript records the *run*; the commit
log records only its *output*.

## The rule

Ask, in this order:

1. **Is my counter counting executions, or effects?**
2. **What already records the execution?** Logs, transcripts, a heartbeat, an
   exit stamp, journald, a scheduler's own history. Usually something does, and
   nobody looked because the effect-counter was closer to hand.

If the answer to (2) is genuinely *nothing* — no trace of the run exists at all
— then you have a different and more expensive problem: you must add a producer
signal, and that costs something to emit. Do not confuse the two situations. The
cheap fix is picking a better instrument; the expensive one is building one.

## Siblings

- [[an_idle_gated_mechanism_cannot_be_probed_from_a_session]] — the case where
  the mechanism genuinely never runs while you are watching, because watching is
  what stops it.
- [[a_reading_names_its_producer_not_the_system]] — right instrument, over-broad
  claim.

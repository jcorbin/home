---
kind: lore
tags: [evidence-quality, agent-harness, process-hazard, concurrency, recurring]
created: 2026-08-11
sources: [pivoker LORE/write_success_is_not_a_durable_landing.md, pivoker TADA/1338, pivoker TADA/1340, pivoker TADA/1400, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A write tool's success is a claim about the call, not about the durable state

## The mechanism

An `Edit`/`Write` returning success tells you the call did not error. It does
not tell you the bytes are where a later reader will look. Four observed shapes,
none of them concurrency in the usual sense:

1. **The path moved underneath it.** A backgrounded subagent reported success
   writing to a file whose parent had, by then, moved it elsewhere. The edit
   went to a path that no longer existed and was silently lost. The cause is
   *ordering*, not contention — backgrounding let the caller proceed and commit,
   and the commit is what made the file movable.
2. **The write never reached the tree.** An `Edit` returned success; the
   following `git commit` said "nothing to commit, working tree clean" and the
   bytes were absent.
3. **It landed and was regenerated over.** A curated section was replaced five
   minutes later by a mechanical generator that shared the same slot, while a
   frontmatter field still asserted the curated version was live.
4. **The stand-down that would have prevented (3) was right and unreached** —
   an earlier branch returned before ever calling it — and later right and
   *overruled*, when a failed curation call fell back to the generator over
   still-good work.

## The rule

**Read the bytes back from the authority a later reader will read.** `git show
HEAD:<path>`, the destination path, the deployed config — never the writer's own
exit code.

This is a **verification** rule, not a locking one, and reaching for a lock is
the wrong size: of the first three instances one had no concurrent writer at all
and one happened inside a context already holding the relevant lock.

Corollaries earned the hard way:

- **Verify at delivery, not merely after the call.** Wherever a curated write
  and a generated write share one slot, the generator wins on re-run unless
  something makes it stand down — and the stand-down flag being *right* is not
  the same as the stand-down *happening*.
- **Check a stand-down's reachability from every caller**, not just its logic,
  and key it on a predicate the losing producer cannot forge.
- **A fan-out may run N concurrent writers; the caller must not proceed past
  them.** Dispatch synchronously when the next step makes the target mutable.

## The generalisable part

**A success report from a subordinate is the weakest evidence you will handle.**
It comes from the actor least able to observe the outcome and most motivated to
report completion. That holds for subagents, for background jobs, and for any
tool whose return value describes its own effort rather than the world.

## Siblings

- [[mise_untrusted_config_exits_zero_false_green]] — the same "success is not
  work" shape at the process-exit layer.
- [[a_reading_names_its_producer_not_the_system]] — a *correct* reading that is
  still narrower than the claim being made from it.

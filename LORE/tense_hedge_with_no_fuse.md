---
kind: lore
tags: [documentation, process-hazard, evidence-quality, recurring]
created: 2026-08-11
sources: [pivoker LORE/tense_hedge_with_no_fuse.md, pivoker TADA/1499, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A tense hedge is a dated claim wearing no date

## The mechanism

"The **forthcoming** drift checks." "The version-skew **placeholder**." "For
now, X."

Each was **true when written**, so no reviewer ever flags it. Its falsifier is
an **event** — the named work shipping — and no mechanism is watching for that
event. So it becomes false silently and stays false permanently, because nothing
in the system is capable of noticing.

Two were found in one sweep, in two artifact kinds, both having survived
multiple arcs of green CI: a README calling a shipped function "forthcoming",
and a package comment presenting a live CLI surface as future work. Neither
breaks a test and **neither can** — tests bind the code's actual behaviour, so
green CI is not evidence about a hedge.

## The rule

**A hedge must name its fuse** — the task id, ticket, or symbol whose existence
falsifies it:

```
// forthcoming (see checks.CheckVersion / TODO-89)
```

so the sweep is mechanical the day that work lands.

**The fuse belongs ON the hedge, not in the plan.** The task that ships the
feature will not grep for adjectives.

**Prefer no hedge to an unfused one.** If you cannot name what would falsify it,
you are advertising more than the code honours.

## When you find one

Fix the **tense**, not everything adjacent. One sweep deliberately left 293
stale spellings of another kind to a follow-up and **named that owner at the
edit site** — because half a doc fix with no note reads as an oversight to the
next auditor.

## Siblings

- [[prose_cannot_retire_a_runnable_instruction]] — there a correction was
  attempted and landed in the wrong slot. Here none was ever attempted.
- [[a_path_in_prose_is_an_unchecked_assertion]] — same medium, different
  falsifier.

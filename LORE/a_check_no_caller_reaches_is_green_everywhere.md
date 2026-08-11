---
kind: lore
tags: [testing, health, anti-pattern, pattern, recurring]
created: 2026-08-11
sources: [pivoker LORE/a_check_no_caller_reaches_is_green_everywhere.md, pivoker TADA/1425, pivoker TADA/1320, pivoker TADA/1174, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A check no operator-facing caller reaches passes every test it has and guarantees nothing

## The mechanism

The check function is correct. Its unit tests are correct. The gap is in the
**registry or the gate** — and a test of the check function cannot see it.

Three recorded shapes:

- a check sat behind a `!SkipLocal()` condition in one battery and was **absent
  from the other entirely**, so the command form a remote caller always uses
  emitted 19–26 rows, worst status Warn, exit 0 — on a machine that was missing
  the very binary the check exists to find;
- a **renamed** rubric left a wired fix handler dead for two releases;
- an allocator answered `unknown command` and read as *"no such feature"*.

## The rule

**Assert on the invocation, with the arguments an operator actually types.** Not
on the function.

Three corollaries:

1. **A worst-status gate cannot distinguish "holds" from "nobody asked."** Gate
   on the row's **presence** as well as its verdict.
2. **When a check is gated, ask what the gate is ABOUT.** A `SkipLocal()`
   predicate asks about *this host*; the file it guards was about the *remote
   party*. The fix was to move the check to the battery whose scope it always
   described — not to un-gate it.
3. **Follow the REPAIR path separately.** The same mis-scoping pointed an
   automatic fix at the wrong machine, while the correctly-routed dispatch hit a
   name filter matching nothing.

**Grep the registry, not the definition.** When two modes register different
check sets, the union is not what either one emits.

## Siblings

- [[a_probe_failure_must_not_render_as_an_answer]] — the check runs and its
  error becomes a value.
- [[pin_a_behaviour_on_what_its_opposite_would_touch]] — green and proving
  nothing, at the assertion level rather than the invocation level.

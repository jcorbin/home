---
kind: lore
tags: [decision, architecture, directive, recurring]
created: 2026-08-11
sources: [pivoker LORE/design_out_dont_coordinate_around.md, pivoker LORE/lighter_cut_design_discipline.md, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Design the hazard out; do not coordinate around it

## The decision rule

When a hazard is discovered, there are two shapes of response:

- **Coordinate around it** — a rule, a comment, a checklist item, an ordering
  everyone must respect, a lock everyone must remember to take.
- **Design it out** — restructure so the hazard cannot be expressed.

Prefer the second. A coordination rule is enforced only by whoever remembers it,
and its failures are silent by construction: nothing in the system can tell that
someone skipped a step nobody records.

A rule that can only be followed by knowing an undocumented invocation is not a
rule that will be followed. When a written-down process rule keeps recurring,
**re-measure whether the correct action is even reachable** before concluding
carelessness.

## The corollary: form decides which half gets obeyed

A two-part rule whose *check* is a copy-pasteable command and whose *action* is
prose will be obeyed as the check alone — someone will run the verification and
take it for the action.

**Fold the check into the action** rather than re-explaining the order. Adding a
fourth advisory warning just rebuilds the same two-part rule inside one command.

## The counterweight: the lighter cut

Designing out is not licence to build the general mechanism. Ship the **smallest
thing that captures most of the value**, and prefer demoting an old mechanism to
a fallback over a flag-day replacement — no cutover, no window where neither
path works.

The two rules resolve cleanly: *design out* is about where the correctness lives
(in the structure, not in anyone's memory); *lighter cut* is about how much you
build to put it there.

## Siblings

- [[prose_cannot_retire_a_runnable_instruction]] — the same "form decides what
  gets obeyed" mechanism, applied to corrections.
- [[a_wait_with_no_named_producer_is_a_drop]] — a hazard you cannot coordinate
  around, because its failure mode is silence.

---
kind: lore
tags: [debugging, ci, evidence-quality, process-hazard, recurring]
created: 2026-08-11
sources: [pivoker LORE/varying_error_text_is_not_evidence_of_flakiness.md, pivoker TADA/1505, pivoker TADA/1506, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Output that differs across runs is not flakiness until you ask which part is varying

## The mechanism

"The error text is different every time" is the strongest heuristic anyone has
for *flaky*, and it is worthless until you ask **which part** varies. If the
varying part is banners, ordering or worker ids — and the deterministic failure
line is never in view — you measured the scheduler, not the bug.

Two individually harmless halves composed into the illusion:

- a note builder **flattened** the gate's output and truncated the head at 300
  bytes, 96 of which were constant boilerplate; and
- the failing task fanned out to a parallel runner, so every surviving byte was
  a per-command **START banner**.

The real failure sat below the cut every time. Three consecutive rejections each
named a different random-looking set of unrelated components, driving the whole
verb past its retirement threshold on a diagnosis that was never true.

Note what did *not* help: serialising the outer lane. The truncation window
never reached past its first step, and that step is the one that fans out.

## The exculpatory pair that means nothing

Do not trust "zero code diff" + "every component passes lint by hand". Both were
**true**, and neither bore on it: the failing check was a whole-corpus sweep
whose input is the **merged** tree, so per-component reproduction could never
reach it.

## The rule

1. **Locate the deterministic failure line before theorising.** If your view of
   the output is truncated, fix the view first — you are debugging a renderer,
   not a test.
2. **Reproduce on the same input the check actually consumes.** For anything
   gated on a merge, that is the merged tree, not your branch tip:

   ```sh
   git worktree add --detach /tmp/x <target>
   git -C /tmp/x merge --no-ff <your-branch>
   # run the gate there
   ```

   That got an identical, deterministic failure every time.
3. **A varying set of "affected components" with no common mechanism is a
   rendering artifact until proven otherwise.** Randomness in *which* things are
   named is a stronger signal of a display bug than of a real race.

## Siblings

- [[adjacent_log_line_is_not_evidence]] — the prior question: is the line you
  are reading even conditional on the failure?
- [[a_test_that_reads_shared_mutable_state_is_flaky_by_construction]] — the case
  where the variance *is* real and still isn't the bug you think.

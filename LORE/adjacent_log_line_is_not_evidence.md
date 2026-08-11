---
kind: lore
tags: [debugging, testing, evidence-quality, anti-pattern, recurring]
created: 2026-08-11
sources: [pivoker LORE/adjacent_log_line_is_not_evidence.md, pivoker TADA/1087, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A log line next to a failure is not evidence until you have seen a passing run

## Why it matters

A flake report is usually a failure line plus whatever was printed near it. The
nearby lines look like clues — they were *right there* when it broke. But a
test's log output is mostly unconditional: it prints on every run, pass or fail.
Until you have the passing run's output to diff against, "adjacent" and "causal"
are indistinguishable, and the scariest-looking adjacent line quietly becomes
your hypothesis.

In the recorded case this cost the entire first pass of the investigation. The
filed report had already reasoned from the adjacent line to a specific
mechanism, a suggested fix, and a warning not to paper over it — a complete,
plausible, wrong theory, built before anyone ran the test green and looked.

## The shape

The failure:

```
FAIL	<pkg>	2.305s
```

and the adjacent line, which reads like a smoking gun — a write failing on a
path under the test's own temp dir, naming the failing test, at shutdown. That
is a very good story: the fixture directory was unlinked by cleanup while a
goroutine still ran, so the fix must be a join.

One command settles it: run the test on its own and look. The line appears
verbatim **on the passing run**. It is unconditional noise.

The real cause was mundane and elsewhere: a 2s liveness deadline that starves
under repo-wide parallel test load. `2s` + fixture setup = the reported
`2.305s`. **The number in the failure line was the actual evidence, and it was
in plain sight the whole time.**

## The rule

1. **Run it green and diff the output.** Anything present in both is noise. One
   command, almost always the fastest step available.
2. **Check whether the suspect code can even fail a test.** A `log.Printf` that
   returns cannot. If it can't fail the test, it isn't the failure — at most
   it's a second, separate bug.
3. **Read the numbers, not just the words.** Durations, counts and ids in the
   failure line are hard evidence; prose nearby is not.
4. **Reproduce before fixing.** Artificial starvation (`taskset -c 0` against N
   CPU burners) turns a "seen once under load" flake into a round-1 failure —
   which then proves the fix under the same harness.

**Corollary for filing:** record the raw failure output verbatim and stop. A
filed hypothesis is sticky — the next session starts by trying to confirm it
rather than by looking. If you must theorise, mark it unverified and name the
one command that would falsify it.

## Siblings

- [[varying_error_text_is_not_evidence_of_flakiness]] — the next question up:
  *which part* of the output is varying.
- [[falsify_the_filed_premise_at_the_primary_source]] — what to do about the
  sticky filed hypothesis this entry warns you not to create.

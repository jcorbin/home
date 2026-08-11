---
kind: lore
tags: [testing, pattern, anti-pattern, recurring]
created: 2026-08-11
sources: [pivoker LORE/fixture_supplies_a_precondition_production_never_has.md, pivoker TADA/1439, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A green, non-tautological test can still be pinning your fixture's world instead of production's

## The mechanism

The mirror of the missing-side-effect trap: here the fake does not *omit*
something real, it **supplies a precondition production never has** — usually by
leaving an optional seam unwired, so the code takes a **degraded-environment
branch the real caller never takes**.

Worked case: four tests skipped a setter, leaving a counter at its sentinel
`-1`. That routed all four down the "we don't know, so trigger" path — while
their names and assertions claimed to prove *"sweeps do not run while work is
pending"*. Production takes the other branch. So did a sibling test in another
file, which is what eventually exposed it.

The test was green. It was not tautological. It mutation-tested fine. It simply
described a world that only the fixture inhabits.

## The rule

1. **Diff the fixture against production's WIRING**, not against its inputs. Ask
   which optional seams the real caller sets that your fixture leaves nil.
2. **Pair every negative with a divergent positive.** If you assert "X does not
   happen", have a sibling test where X *does*, under a fixture that differs
   only in the thing under test.
3. **Assert you reached the path.** A bare `!called` is vacuous if the code
   never got near the branch — check for a positive marker of arrival first.
4. **Name the PATH, not the input.** A test called `TestSkipsWhenBusy` that
   actually exercises the unknown-state branch is mis-titled, and the title is
   what the next reader trusts.

## Siblings

- [[seam_injection_for_testability]] — the same seam, failing the other
  direction.
- [[fixture_speaking_in_the_wrong_voice_certifies_the_bug]] — worse: there the
  fixture makes the suite actively *defend* the defect.

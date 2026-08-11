---
kind: lore
tags: [testing, pattern, architecture, recurring]
created: 2026-08-11
sources: [pivoker LORE/seam_injection_for_testability.md, pivoker TADA/devoker/101, pivoker TADA/devoker/112, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Inject the system-touching seam at design time, and make the fake model the side effects you assert about

## The pattern

Every package that touches the real system — the process table, git, the
network, the clock, another program — is built around an **injectable seam**: an
interface whose production implementation shells out, and whose test
implementation records calls and returns scripted results.

The canonical seam is the runner: code calls `runner.Run(...)`, never
`exec.Command(...)` directly. Production wires a real runner; tests wire a fake
that asserts on the command line and returns canned output.

## The trap: fakes that omit a real side effect

A seam is only as good as the fake's fidelity, and the recurring failure is a
fake that **omits a side effect the real system has** — so the test passes and
production diverges.

The worked case: `enable-linger` also spawns `user@<uid>.service`. The fake
didn't model that, so an "expect inactive" assertion passed in test and failed
against a real kernel. That gap is precisely why a real-kernel VM tier exists:
some behaviours cannot be faithfully modelled by any in-process fake, and must
be asserted against the real thing.

## The rule

1. **Inject the seam at design time**, not retrofitted later. Designing the
   contract before the implementation is what makes the seam fall out naturally
   instead of being carved back in around a hard dependency.
2. **A fake must model the side effects the test asserts about.** If the test
   asserts "the unit is inactive", the fake must model what really makes a unit
   active. When it can't, escalate that case to a real-system tier rather than
   trusting the fake.
3. **Prefer recorded-call assertions and sentinel files over rendered reads.** A
   fake returning a rendered string can mask a path that never ran; asserting on
   the *call* — or on a sentinel the call drops — catches the no-op.

## Siblings

- [[fixture_supplies_a_precondition_production_never_has]] — the mirror image:
  the fake does not omit a side effect, it *supplies* a precondition production
  never has.
- [[silent_failure_log_and_swallow]] — sentinel and recorded-call assertions are
  how you test the swallow paths.

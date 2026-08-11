---
kind: lore
tags: [testing, pattern, anti-pattern, recurring]
created: 2026-08-11
sources: [pivoker LORE/pin_a_behaviour_on_what_its_opposite_would_touch.md, pivoker TADA/1443, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A "did not happen" assertion is evidence only if it reads an instrument the other branch would have written to

## The mechanism

Negative assertions are only as good as their instrument. If the branch you are
excluding would have written somewhere *else*, your empty reading was empty
either way — and the test passes with its guard deleted.

The trap comes wrapped in good advice. A hard-won instrument rule is usually
stated **for one direction only**: "on the headless posture, assert on the
notification capture" is right for a **delivery** and exactly wrong for a
**drop** within that same posture, whose fallback posts to the *transport*
instead. The drop test read an empty capture, and the emptiness proved nothing.

## What made it unfixable, and the durable half

The posture check matched the **concrete type** of the transport
(`*headlessTransport`), fusing "is headless" to that type's incidental
unobservability. No fake could be both headless **and** recording, so the test
could not be written correctly even by someone who saw the problem.

> **Declare a posture as a capability** (a marker interface, a predicate) —
> never match its implementation.

## The rule

1. **Assert on both conduits** when a behaviour can express itself two ways.
2. **Mutation-test each assertion separately.** Sibling tests in one file each
   needed a *different* mutation to prove they had teeth.
3. **Check that the excluded path has somewhere to GO.** A zero-scope fixture
   just relocates the same tautology.
4. When you inherit an instrument rule, ask **which direction it was written
   for**.

## Siblings

- [[fixture_speaking_in_the_wrong_voice_certifies_the_bug]] — the positive-
  assertion counterpart.
- [[a_check_no_caller_reaches_is_green_everywhere]] — the invocation-level
  version of "green, and proving nothing".

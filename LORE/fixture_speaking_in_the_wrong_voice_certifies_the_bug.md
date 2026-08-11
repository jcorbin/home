---
kind: lore
tags: [testing, anti-pattern, evidence-quality, recurring]
created: 2026-08-11
sources: [pivoker LORE/fixture_speaking_in_the_wrong_voice_certifies_the_bug.md, pivoker TADA/1475, pivoker TADA/1436, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A fixture value only another component could have produced makes its test pin the inverse of the intended invariant

## The mechanism

A test seeds a value into a sink and asserts the sink reports it. If that value
is one **only a different producer** could have written, the test pins the
opposite of the invariant it names — and it **passes because of the defect**.

Worked case: the sole test on a refusal-reason path asserted the reason
contained a particular remedy string, under the comment *"want the gate's
verdict text"*. It seeded no gate. It was reading the **agent's own summary**
field, and it passed *because* the wrong field was being used.

The tell was available the whole time: **no real producer emits that string in
that voice.** Gate vocabulary had been put in the agent's mouth by the test —
and then codified by the helper's doc comment, which described the wrong
behaviour as the contract.

## Why this is worse than an ordinary bad test

Because it still **fails under mutation**, the next audit of that exact sink
reads code and tests agreeing and concludes it is sound. **The suite does not
miss the bug; it defends it.** One audit fixed a nearby precedence issue and
declared it "the one place" while the ordinary route stayed open — surfacing
much later as work refused for being correct.

## The rule

1. **Read the fixture's literals and ask: who in production writes this
   string?** If the answer is "a component this test never instantiated", the
   test is pinning a fiction.
2. **Give each fake an unmistakable voice** — a prefix, a marker — so a value
   can never be mistaken for another producer's.
3. **Assert the negative**: the reason does NOT contain the agent's summary. The
   bug is a wrong *speaker*, not a missing sentence, so only a negative
   assertion can see it.
4. **Mutation-check every direction a guard has.** A fill-if-empty has two:
   disabling it re-opens the fallback, and making it unconditional clobbers the
   more specific producer that carried the real remedy.
5. **State the invariant on the PRODUCERS.** Precedence in a sink cannot invent
   a value nobody wrote — so the durable rule lives where the value originates.

## Siblings

- [[fixture_supplies_a_precondition_production_never_has]] — same family, one
  degree less severe: a fiction the suite tolerates rather than defends.
- [[pin_a_behaviour_on_what_its_opposite_would_touch]] — how to choose the
  instrument so an assertion can fail at all.

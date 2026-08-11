---
kind: lore
tags: [documentation, decision, architecture, recurring]
created: 2026-08-11
sources: [pivoker LORE/schema_duplication_doc_drift.md, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Cross-reference a schema's one canonical definition; never inline-copy it into a second doc

## The mechanism

Two copies of a rule drift the moment one is edited, and **nothing catches it**.
The failure is quiet in a specific way: tests lock in the *code's actual
behaviour*, so the copy that is wrong is the doc — and the build stays green
while the doc lies. The drift surfaces only when an audit happens to read both
side by side.

## The rule

- **One canonical home per schema, contract, or format.** Everything else links
  to it and says only what is *different* about its own surface.
- **When code and doc disagree, decide which is right and fix the other** —
  including the test that encoded the wrong one. A test that pins the wrong
  behaviour is not neutral; it is the reason the wrong behaviour survived.
- **A skipped audit step is how duplication accumulates.** It is cheap to catch
  at the moment of writing and expensive at every point after.

## The exception worth knowing

Two implementations of one rule are acceptable — even *preferable* — when
something mechanically enforces that they agree. A reference implementation plus
a production implementation plus a parity test that runs both over the live
corpus is stronger than a single implementation with nothing watching it.

The anti-pattern is **two copies with nothing enforcing agreement**. Adding a
gate converts a duplication hazard into a redundancy asset; removing the
"redundant" copy without noticing it was the gate's other half deletes the gate.

## Siblings

- [[a_path_in_prose_is_an_unchecked_assertion]] — the same "written claim, no
  verifier" family at the level of individual references.
- [[no_dead_parsed_fields]] — the code-side version of advertising more than is
  honoured.

---
kind: lore
tags: [git, gates, false-positive, test-quality, recurring]
created: 2026-08-11
sources: [pivoker LORE/rename_detection_is_similarity_not_identity.md, pivoker TADA/1205, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Git's `-M` answers "are these blobs alike?", never "is this the same file"

## The mechanism

Rename detection is a **similarity heuristic** with a threshold (50% by
default), not an identity record. Git stores no rename; it infers one at diff
time by comparing content.

So a gate that exempts moves by `Status == 'R'` stops exempting **exactly the
ones that changed the most** — which, for anything moved at the end of its life,
is exactly the completed ones. A file that was rewritten as it moved measured
18% similar and arrived as an unclearable `D` + `A` pair.

The polarity is the trap: the check works on trivial moves and fails on
substantial ones, so it passes every test anyone thinks to write.

## The rule

- **Pair the `D` and the `A` by the identity key you already compute**, not by
  git's inference. A `D` proves the entity existed at the base; an `A` with the
  same key is the same entity.
- **Build the set over the whole diff**, and key on full identity rather than a
  fragment of it.
- **Do not "fix" it by lowering the threshold.** There is no threshold at which
  a similarity score becomes an identity claim.

## The test lesson riding along

Its passing unit test **hand-built the `R` status it assumed git emitted**. The
fake encoded the premise, so the test could never contradict it.

**Keep one real-tool test pinning the premise your fakes encode.**

## Siblings

- [[fixture_supplies_a_precondition_production_never_has]] — the general form of
  that test failure.
- [[a_path_in_prose_is_an_unchecked_assertion]] — shares the noun "rename" and
  nothing else.

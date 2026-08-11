---
kind: lore
tags: [testing, concurrency, ci, diagnosis, anti-pattern, recurring]
created: 2026-08-11
sources: [pivoker LORE/gate_reads_the_live_board_which_moves.md, pivoker TADA/1353, pivoker TADA/1350, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A check that walks live shared state fails red-then-green-on-re-run — the one shape that trains its reader to dismiss the gate

## The mechanism

A test suite that runs inside the same working directory another process mutates
is reading a moving target. Two distinct mechanisms, both observed:

1. **Two reads of one collection.** A parity test read the corpus in one
   language, then again from a helper script 0.8 seconds later, and compared
   them. Anything that moved in between is a spurious mismatch.
2. **`readdir` names a file that `open` then cannot find.** 26 of 40 runs under
   churn. This one is **production too**, not just tests — any ranking pass over
   a live directory has it.

The damage is not the failing run. It is that re-running makes it pass, which
teaches everyone to re-run — and a gate whose failures are habitually dismissed
has stopped being a gate.

## The rule

- **Snapshot into a private directory and point both readers at the copy.** The
  copy need *not* be atomic: a parity claim is about two rule sets agreeing on
  **one input**, not about the input being sane.
- **Tolerate `fs.ErrNotExist` and only that** where you walk a live directory.
  Widening the tolerance hides real errors.
- **Reproduce before believing it is environmental.** Both shapes reproduce on
  demand in under two minutes by flipping a scratch file in a loop — so *"could
  not reproduce"* is not an honest stopping point here.
- **Check whether it is tier-specific before assuming so.** The racy checks
  carried no build tag, so every tier compiled them.

## Siblings

- [[tool_forks_a_detached_helper_behind_your_back]] — the other source of a
  cleanup-time race that only appears under load.
- [[varying_error_text_is_not_evidence_of_flakiness]] — how to read the output
  once one of these fires.

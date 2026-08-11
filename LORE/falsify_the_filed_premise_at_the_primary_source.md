---
kind: lore
tags: [verification, evidence-quality, process-hazard, directive, recurring]
created: 2026-08-11
sources: [pivoker LORE/falsify_the_filed_premise_at_the_primary_source.md, pivoker TADA/938, pivoker TADA/940, pivoker TADA/1224, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A filed root cause is a hypothesis with a citation — falsify it at the primary source

## The mechanism

Before landing a fix, spend the one cheap act that could falsify the premise:
grep the callers, re-read what the comment is actually about, measure the
claimed cost. **That act counts only if it reaches a source outside the artifact
being verified.**

This is the half you can perform *wrongly while believing you performed it*.
Every other falsifying act you either did or did not do; a circular check has
the same form, the same wording, and the same review outcome as a real one,
because an artifact will happily cite itself.

The worked case: a config line `ops: "#ops"` carried a verification comment,
passed review, and was dead for the life of the file. Its cited authority was
**another line in the same file making the same guess**. The answerable question
was never "does the code say `#ops`" — it did, twice, agreeing with itself — but
"does `#ops` resolve in the live DOM", which it did not.

## The rule

**Ask where the cited authority LIVES before crediting it.**

For selectors, ids, paths and config keys, the primary source is the thing that
must **resolve at runtime** — the live DOM, the running process, the actual
ledger — not a sibling declaration of what it ought to be. Pin it with a test
that reads the external source, or the citation rots back into a guess.

Three recorded outcomes, all cheap:

- one premise died to a single caller-grep;
- one to a re-read plus a measurement;
- one framing was wrong even though the fix it produced was fine.

## Why it is worth the minute

**A fix on a false premise retires the incident narrative while leaving the
mechanism live.** The symptom stops, the report is closed, and the next
occurrence starts from a record that confidently points the wrong way.

## Siblings

- [[adjacent_log_line_is_not_evidence]] — where filed premises come from.
- [[a_path_in_prose_is_an_unchecked_assertion]] — the same "written down, never
  verified, no verifier exists" shape in documentation.
- [[a_reading_names_its_producer_not_the_system]] — a reading can be correct and
  still not support the claim made from it.

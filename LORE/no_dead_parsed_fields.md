---
kind: lore
tags: [pattern, directive, config, architecture]
created: 2026-08-11
sources: [pivoker LORE/no_dead_parsed_fields.md, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Parse only what a consumer reads — a parsed field with no reader is a promise the code does not keep

## The mechanism

A field that is parsed, validated, and stored — but never read — is worse than
an absent one. It **advertises a capability that does not exist**:

- a user sets it and observes no effect, with no error to explain why;
- a reviewer sees it handled and assumes it works;
- a later change "fixes" behaviour by wiring it up, silently activating settings
  that have been sitting inert in real config files for months.

The last one is the expensive shape: the values were written by people who
believed they were doing something, and they take effect all at once, on deploy,
with no diff to point at.

## The rule

- **Add the field in the same change as its consumer.** If you cannot name the
  reader, do not parse it.
- **If a field must exist before its consumer** (a staged rollout, a schema you
  do not own), say so explicitly at the declaration and name the fuse — the
  ticket or symbol whose arrival makes it live.
- **When removing a consumer, remove the field or record why it stays.** A field
  that outlives its only reader is the same defect arrived at from the other
  direction.

## Siblings

- [[tense_hedge_with_no_fuse]] — the prose transposition of exactly this:
  advertising more than the code honours, with nothing watching.
- [[schema_duplication_doc_drift]] — the doc-side family.

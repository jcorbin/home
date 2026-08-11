---
kind: lore
tags: [documentation, process-hazard, evidence-quality, skills, recurring]
created: 2026-08-11
sources: [pivoker LORE/prose_cannot_retire_a_runnable_instruction.md, pivoker TADA/1136, pivoker TADA/1126, pivoker TADA/1147, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A correction must edit the slot the reader acts from

## The mechanism

**Form decides which version gets obeyed.** A wrong command sitting in its own
stanza beats a right paragraph three lines below it, every time — because the
reader is scanning for the thing they can run, and prose is not it.

Worked case: session 3 wrote a resume trigger as a runnable probe in a task's
banner. Session 5 established the probe could **never fire**, and recorded that
finding as prose further down instead of editing the stanza. Every later reading
ran the stale probe anyway, and the task sat parked seven days on evidence
already sitting in the file.

Three surfaces have paid for this and only one is mechanically enforced:

- **index gists**, where a correction stranded below a truncation point is
  invisible to anyone reading the summary (now gated by a test);
- **design docs**, where a commit message said "Replaced" and the diff was
  purely **additive**, leaving the wrong claim three lines above the right one;
- **runnable stanzas in working documents**, still ungated.

## The rule

1. **Match the form you are correcting.** A wrong command is retired by editing
   the command, never by a note near it.
2. **Demote the retired version *below* the correction**, labelled as
   superseded — do not shelve the correction beside the thing it corrects.
3. **An additive "correction" does not retire the claim it corrects**, and a
   commit message saying "replaced" is not evidence that anything was.

## The coverage trap

Stating the rule in one artifact's preamble is not coverage for the others. The
index preamble states it for index authors — **while the violators are authoring
working documents and never read it.** Put the rule where the wrong form is
being written.

## Siblings

- [[a_path_in_prose_is_an_unchecked_assertion]] — the same "stale, unverifiable,
  in a medium with no verifier" family, for paths.
- [[tense_hedge_with_no_fuse]] — where no correction was ever attempted, and
  none ever will be.
- [[skill_body_is_a_template_not_a_file]] — the instruction on disk is right and
  is corrupted in transit; the opposite failure.

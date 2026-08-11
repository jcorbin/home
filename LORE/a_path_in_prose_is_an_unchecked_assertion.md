---
kind: lore
tags: [documentation, process-hazard, evidence-quality, recurring]
created: 2026-08-11
sources: [pivoker LORE/a_path_in_prose_is_an_unchecked_assertion.md, pivoker TADA/1499, pivoker TADA/1488, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A path written in prose is a claim about the filesystem made in a medium with no verifier

## The mechanism

A rename is the common falsifier, and the asymmetry is total: `git mv` plus the
compiler reroutes every import with a 100%-reliable enforcer, while **every path
string** — doc cross-references, package comments, worked examples, a `git add`
pathspec inside a copy-pasteable snippet — keeps naming a directory that no
longer exists. CI stays green forever, because tests bind symbols and the paths
live in markdown.

One filed stale citation produced three more on the sweep, across three artifact
kinds. The sharpest was not stale prose at all but a **runnable instruction that
fails** (`pathspec did not match any files`) sitting in a skill.

Measured in the one corner that was mechanised: ~72 stale citations at the point
the convention was introduced, 2663 by the time anyone swept — because "every
task eventually lands", so a path-shaped citation is stale by default with time.

## The rules

- **Cite the identifier, not `path:line`.** A line number rots on the next edit;
  the symbol is already unique repo-wide, and a grep finds it.
- **Sweep the INFERENCE, not the token, in the same change as the rename.** A
  bare grep for the old directory under-reports: the name also hides behind
  package selectors and in prose like *"the evoke package"*.
- **Triage into fix-now / benign-and-recorded / out-of-scope, and write the
  benign ones down.** Archived records and shelved proposals are *correct*
  naming the old path; an unrecorded decision to skip them reads as an oversight
  to the next auditor.
- **Gate it where you can.** A convention with no gate is a preference.

## Siblings

- [[prose_cannot_retire_a_runnable_instruction]] — a runnable stale instruction
  outranks a prose nit; fix that one first.
- [[falsify_the_filed_premise_at_the_primary_source]] — the general form: a
  written claim whose authority nobody checked.

---
kind: lore
tags: [git, diagnosis, evidence-quality, anti-pattern, recurring]
created: 2026-08-11
sources: [pivoker LORE/absent_ref_reads_as_unmerged.md, pivoker TADA/1065, pivoker TADA/1099, pivoker TADA/1122, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A probe that errors must not render as a negative answer

## The mechanism

```sh
git merge-base --is-ancestor "$a" "$b" && echo MERGED || echo UNMERGED
```

reads as a two-valued question. It is three-valued: `--is-ancestor` exits **128**
for an *absent* ref, and `&& … || …` collapses that error into the `UNMERGED`
branch.

The polarity is what makes it systematic: a cleanup worker deletes the branch as
the **last step of a successful landing**. So the idiom reports precisely the
cleanly-completed entities as never-merged, forever, and the false negatives
concentrate on the happy path.

## The rule

- **Probe stable identities** — commit shas, not branch names that a successful
  path deletes.
- **In code, make "unknown ref" a matchable third outcome** and force callers to
  treat it as *indeterminate* (re-probe from another source), never as "no".
- **Check the authoritative record first** — if a completion is recorded
  somewhere durable, read that before inferring from ref topology.
- **Never let a probe failure render as an answer.** Any `cmd && A || B` where
  `cmd` can fail for reasons other than "the answer is no" is this bug.

## The half that cost the most

Fixing the probe is not fixing the bug. **Review the call sites, and fix them
all in the same change.** One pass fixed one site of four and recorded the
residual only in its own prose; another site went on recording completed work as
conflicted for an entire arc until someone grepped for it.

Classify each site rather than sweeping: some needed the re-probe, some were
correct as-is — and those now say *why* in a comment. **If you knowingly leave a
residual, file it**; prose in the fixing task is not a fuse.

## Siblings

- [[a_check_no_caller_reaches_is_green_everywhere]] — the sibling where the
  check is correct and simply never invoked.
- [[silent_failure_log_and_swallow]] — the same "an error became a value"
  transformation, one layer down.

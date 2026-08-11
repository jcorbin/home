---
kind: lore
tags: [git, measurement, diagnosis, retcon, recurring]
created: 2026-08-11
sources: [pivoker LORE/two_dot_range_is_one_sided_across_a_rewrite.md, pivoker TADA/1309, pivoker TADA/1310, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# `A..B` is a "behind" count only while A is an ancestor of B

## The mechanism

`git log A..B` answers "commits reachable from B but not from A". That is the
"how far behind" number you wanted **only while A is an ancestor of B**. Once a
history rewrite — a rebase, a retcon, a filter — moves the commits under A, the
range silently drops A's entire side and **still prints a small, plausible
integer**.

Measured after one such rewrite: 1109 commits invisible, while the freshness
surface reported "9 commits behind" — into an auto-deploy that restarts daemons.

`A...B` is not the fix. It is `diff merge-base(A,B) B`: blind to what the
rewrite dropped from A's side *and* over-reporting churn — 2 files vs 200+ on
the same measurement.

## The rule

1. **Ask ancestry FIRST.** It decides which computation is even meaningful:

   ```sh
   git merge-base --is-ancestor A B
   ```

2. **Across a rewrite, compare TREES, not commits:**

   ```sh
   git diff --name-only A B      # two dots
   ```

   A well-formed rewrite preserves the net tree, so **identical trees mean the
   running code IS current** — a fact no commit-based reading can express.

3. **Do not collapse every non-ancestor into UNKNOWN.** Consumers refuse to act
   on UNKNOWN, so the mechanism goes permanently silent after the first rewrite.
   Distinguish "the distance is undefined" (a real verdict) from "nothing could
   be determined".

4. **Name the pathspec in the rendered line.** An entire "9 vs 16 disagreement"
   turned out to be a scoped count beside a raw one — both right, only one
   described.

## The part that recurred a surface later

Sharing a measurement's **inputs** does not stop two surfaces disagreeing. Two
readouts were given a shared path constant so they would "ask the same
question", and they still contradicted each other, because each still spelled
its own decision procedure over those shared paths.

**Hoist the DECISION — the function that produces the verdict — not just the
constants it consumes**, and let layering pick where it lives.

A note saying "the sibling surface measures this the same way, deliberately left
alone" is a filed defect with a fuse, not a note.

## Siblings

- [[stale_binary_masquerades_as_a_new_bug]] — the other way a freshness number
  lies.
- [[tense_hedge_with_no_fuse]] — what a "deliberately left alone" note becomes.

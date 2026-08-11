---
kind: lore
tags: [git, concurrency, process-hazard, worktree, recurring]
created: 2026-08-11
sources: [pivoker LORE/blind_add_a_sweep_reverts_sibling_board.md, pivoker LORE/liaison_git_mv_races_concurrent_realm_writer.md, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# `git add -A` on a shared or stale checkout commits someone else's work as a revert

## The mechanism

A whole-worktree `git add -A` stages **everything the working tree says**,
including the parts that are stale relative to what another writer has already
landed. Commit that and you have authored a revert of their change — rendered in
the diff as, for example:

```
R100  live/x.md → pending/x.md
```

a clean, plausible-looking rename that undoes a transition someone else
completed. Nothing errors. The commit looks like yours and is.

Two entry points, one outcome:

- **stale checkout** — your tree predates their landing, so `-A` re-asserts the
  old state;
- **concurrent writer** — an ad-hoc `git mv` + `git commit` racing another
  process's commit in the same checkout can silently drop staged edits.

## The rule

Pick one of these, deliberately:

1. **Own the state exclusively** — work in your own worktree or a temp clone,
   and commit from a fresh index.
2. **Hold the lock, with the worktree at HEAD** — if the system has a mutation
   lock, take it, and verify the tree is not carrying someone else's pending
   state before staging.
3. **Scope the commit to the paths you own** — `git commit <pathspec>` /
   `git add <specific paths>`, never `-A`, whenever the checkout is shared.

For any codebase where several agents or daemons write to one checkout, tag each
commit call site with which of the three it is relying on. That classification
is the durable artifact; the fix for any individual site follows from it.

## Siblings

- [[git_mv_of_modified_file_stages_the_old_blob]] — the non-racy, purely local
  version: the move lands, the content doesn't.
- [[git_config_worktree_scope_breaks_every_other_worktree]] — the other way one
  worktree's convenience damages its siblings.

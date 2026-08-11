---
kind: lore
tags: [git, worktree, incident, process-hazard, recurring]
created: 2026-08-11
sources: [pivoker LORE/git_config_worktree_scope_breaks_every_other_worktree.md, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# `git config --worktree` in one worktree breaks every other worktree in the repo

## The mechanism

`git config --worktree <key> <value>` does two things, and only the first is the
one you wanted:

1. it writes the key into *this* worktree's config, and
2. it **silently sets `extensions.worktreeConfig = true` repo-wide.**

Once that extension is on, every *other* worktree begins resolving config
through per-worktree files it does not have. `status`, `add`, `commit` and
`merge` break in all of them until each is given a `core.bare=false` override in
its own `config.worktree`.

Measured cost: a ~16-minute outage across an entire multi-worktree system, from
one command typed in one worktree.

## The rule

- **Do not reach for `--worktree` to scope a setting.** Prefer `-c key=value` on
  the single invocation that needs it, an environment variable, or a plain
  repo-level setting you accept as shared.
- **If `extensions.worktreeConfig` is already on**, know that it is a repo-wide
  property and treat any change to it as a repo-wide change.
- **Recovery**, per broken worktree:

  ```sh
  git -C <worktree> config --worktree core.bare false
  ```

  and, if you want the extension gone entirely, unset it *after* every worktree
  has been checked — it is the flag, not the value, that does the damage.

## The generalisable part

**A flag that reads as narrowly scoped may enable a repo-wide mode as a side
effect.** Before using a scoping flag on shared state, check what turning it on
does to everyone else — the blast radius of "just for me" options is not always
what the option name implies.

## Siblings

- [[git_add_all_on_a_shared_checkout_commits_a_revert]] — the other way one
  worktree's convenience damages its siblings.

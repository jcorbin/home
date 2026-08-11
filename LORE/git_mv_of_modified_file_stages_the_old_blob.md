---
kind: lore
tags: [git, process-hazard, recurring]
created: 2026-08-11
sources: [pivoker LORE/git_mv_of_modified_file_stages_the_old_blob.md, pivoker 937 session 2, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# `git mv` on a modified file stages the OLD blob — your edits stay behind

## The mechanism

The natural sequence is "edit the file, then move it":

```sh
# 1. edit notes/foo.md   (UNSTAGED)
git mv notes/foo.md archive/foo.md
git commit -m 'archive foo'
```

That commit contains the rename with the **pre-edit content**. `git mv` renames
the *index entry*, and the index still holds the previously committed blob; your
unstaged working-tree edits are not swept in, and a plain `git commit` (no `-a`)
never looks at them. **The move lands; the substance does not.**

## The tell

```console
$ git commit -m 'archive foo'
$ git status --short
 M archive/foo.md        # ← modified AFTER a commit that "included" it
```

A file still dirty immediately after you commit it was not committed. Confirm in
the diff's blob header: `index 0064ee1f19..cfa65da669` where the left side is
the *original* blob means HEAD carries the old content.

## The fix

```sh
git add archive/foo.md
git commit --amend --no-edit
```

## The habit

**Always `git status --short` after a commit and expect it blank.** Or avoid the
window entirely — stage before moving:

```sh
git add notes/foo.md && git mv notes/foo.md archive/foo.md && git commit …
```

## Why it is worth a rule

The failure is silent and it inverts the usual polarity: the *visible*
bookkeeping (the file is where it should be, the log shows the commit) all
succeeds, so nothing prompts a second look. The content that mattered — the
edit — is the only casualty.

## Siblings

- [[git_add_all_on_a_shared_checkout_commits_a_revert]] — the racy cousin: same
  ending, "the move landed, the content didn't", with another writer involved.
- [[write_success_is_not_a_durable_landing]] — the general shape one layer out.

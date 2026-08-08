---
name: retcon
description: Rewrite a branch's commit history into a sensibly-grouped, reviewable sequence WITHOUT changing its net diff — reset to the integration base and restage the same working tree as one commit per feature, collapsing WIP/fixup/merge/checkpoint noise. Use when the user says "retcon <branch>", "clean up this branch's history", "regroup these commits for review", or before opening a PR from a branch whose history is a mess.
---

# Skill: retcon

Reset a branch to its base and restage the same net diff as a deliberately
grouped commit history. **The net diff is unchanged; only the grouping changes.**
The verb: *retcon* = retroactively continuity-fix a branch's history so a
reviewer reads intent instead of archaeology.

Use it when a branch's history is an accurate record of how the work *happened*
(WIP checkpoints, "fix typo", "address review", merge commits from the base,
three passes over the same file) and a poor record of what the work *is*.

## The one load-bearing property

> `git diff <base>..<new head>` is **byte-identical** to `git diff <base>..<old head>`.

Equivalently: the new tip's tree equals the old tip's tree. Everything else in
this skill is procedure; that is the contract. It is verified mechanically
(`verify.sh`), and if it fails you roll back rather than "fix it up".

## Use the strongest reasoning model for the bucketing

The git mechanics are trivial. The judgment — grouping by feature rather than by
component, ordering commits so each makes sense given the ones before, deciding
when to split a hot file and when not to bother — is where weaker models make
systematic mistakes the user then hand-fixes.

If the session model is already the strongest available, do the bucket analysis
inline. If not, spawn a subagent on the strongest model with the diff and the
rules below, and execute its plan mechanically. Treat the spawn as a convenience,
not a requirement — a stalled subagent is a reason to do it inline, not to wait.

## Preconditions

1. **Clean worktree.** `git status --porcelain` must be empty. Uncommitted work
   is silently swept into whatever you commit next.
2. **Base is current.** `git merge-base --is-ancestor <base> <branch>` must exit
   0. If the branch *lags* its base, merge or rebase the base in first, then
   retcon. Retcon is not a rebase-onto-a-new-base.
3. **Know what depends on this tip.** `git branch --contains <branch>` and
   `git worktree list`. Any branch forked off the old tip loses its merge-base
   when you rewrite; any other worktree checked out on the branch needs
   `git -C <wt> reset --hard <branch>` afterward. See "Dependents" below.
4. **Know whether it is published.** If the branch is pushed and shared, the
   rewrite ends in `git push --force-with-lease`, and anyone else holding it must
   re-fetch. If others may have based work on it, prefer the snapshot cut.

## Two cuts — prefer the snapshot

**Snapshot cut (default, safe).** Never rewrite the live branch. Freeze a
snapshot, retcon *that*, and let the user review/integrate it:

```sh
BR=feature/thing            # the branch whose history is messy
BASE=main                   # what it is reviewed against
ID=$(date +%F)
SNAP="retcon/$BR-$ID"

git branch -f "$SNAP" "$BR"     # freeze
# …run the Procedure below with BR="$SNAP"…
```

The user reviews `$SNAP` (identical tree, deliberate history) and either
fast-forwards `$BR` onto it, opens the PR from it, or integrates it out of band.
Nothing that references `$BR` moves until they say so, and the frozen snapshot
can't be invalidated by the live branch advancing mid-build.

**In-place cut.** Rewrite `$BR` directly. Only when the user asked for it, the
branch is yours alone, and preconditions 3–4 are satisfied. The procedure is
identical with `BR` as the real branch.

Either way the anchor (`refs/backup/pre-retcon-*`) is the undo.

## What the retcon produces

### One commit per feature — NOT per component

The single most common failure is grouping by directory/package. A commit
summarized as `api: add caching, fix pagination, rename handler, bump deps`
reads as "several unrelated changes dumped together" and is too broad to review.

- **The separator test.** If a commit's one-line summary needs more than **two**
  separators (`,` `;` `/` `+` `and`) to enumerate its contents, it is too broad —
  split it.
- **A feature that spans five directories is still ONE commit.** Component is the
  wrong axis; the feature is the right one. So enumerate **features first**, then
  map each to its files (which may cross packages) — never enumerate packages and
  sweep each into a commit.
- **Bundle only genuine entanglement**: two changes that share code which cannot
  be cleanly separated, where the split diff makes less sense than the joint one.
- **Implementation and its tests go in the same commit** — a deliberate departure
  from "test commit, then implementation commit". The reviewer wants the behavior
  and its proof together.

### Sequence commits in dependency order

Once split by feature, **order them so the history reads as a buildable
narrative**: a reviewer reading top-to-bottom should find each commit sensible
given the ones before it.

- A commit that introduces a seam/primitive comes **before** the commit that
  consumes it.
- Foundational fixes precede their follow-ups.
- For mutually independent features, order by which the reviewer should
  understand first (the more foundational).
- **Do not emit commits in discovery or chronological order.** That is half the
  win, thrown away.
- Residual "hub"/wiring commits (below) land **after** the dedicated feature
  commits whose wiring they carry.

### The technique: dedicated files vs hub files

Classify each changed file:

- **dedicated** — touched by exactly one feature (`cache.go`, `Pagination.tsx`).
- **hub** — a hot file whose net diff interleaves N features (`app.go`,
  `routes.ts`, `index.js`, the god-object).

Then:

1. **Commit dedicated-file features first**, one clean single-feature commit
   each, in dependency order (`git add <paths>` whole). This is most of the arc
   and shrinks what remains.
2. **Hub files:** if the features live in *distinct functions*, split with
   `git add -p` (it works non-interactively — feed it a `y/n` sequence). If they
   **interleave within one function**, do NOT burn effort hunk-splitting
   interleaved logic — commit the hub as one `≤2-separator` "wiring" commit
   naming the 2–3 genuinely entangled features. That residual is the honest
   floor, not a failure.
3. **A feature spanning a dedicated file + hub wiring** gets split across its own
   commit and the hub commit. Acceptable — the dedicated commit carries the
   substance.
4. **`git add -p` coalesces adjacent hunks.** A `y/n` sequence keyed to the count
   of `@@` headers in `git diff` will over-stage. After every partial stage,
   verify: `git diff --cached <file> | grep -c '<a marker only the excluded
   region contains>'` must be 0. If a region leaked, `git restore --staged
   <file>` and redo.

### The cross-cutting buckets

- **Docs** are cross-cutting: group by **tier** (per-package docs as one commit;
  top-level `README`/design docs as another), each with a `≤2-separator` message.
  Per-concept hunk-splitting of prose rarely pays.
- **Generated / mechanical content gets its own skippable commit(s)** — lockfiles
  (`package-lock.json`, `Cargo.lock`, `go.sum`), generated clients/protobufs,
  snapshot fixtures, vendored trees, formatter-only reflows. These are part of
  the net diff, must be kept, and are pure noise to a reviewer. Isolating them is
  what lets the reviewer skip them wholesale.
- **Keep distinct kinds of noise in distinct commits.** Do not conflate a lockfile
  bump with a vendored-dep refresh with a snapshot regeneration just because all
  three are skippable. A reviewer skips them at different speeds and for
  different reasons; one bundled `chore:` commit forces them to check.
- **Repo-meta** (CI config, tooling, editor config, Makefiles) — one commit.
- **A cross-cutting refactor that must land atomically** — one commit covering
  every path it touches, with a message naming the *concept*, not one component.

### Messages: match the repo, not a spec

Read `git log --oneline -50 <base>` first and imitate what you find. If the repo
uses conventional-commits, use it; if it uses `area: summary`, use that; if it
uses bare imperative sentences, use those. Never impose a convention the repo
does not already have. First line imperative; the body says **why**, not what the
diff already shows.

## Procedure

```sh
BR=retcon/feature/thing-2026-08-08    # branch being rewritten (the snapshot)
BASE=main
ID=2026-08-08
WT=$(pwd)                             # worktree you are running in

# 0. Preconditions.
git -C "$WT" status --porcelain                       # must be empty
git -C "$WT" merge-base --is-ancestor "$BASE" "$BR"   # must exit 0
git -C "$WT" rev-parse --abbrev-ref HEAD              # must be $BR

# 1. Mint the anchor (the undo + the invariant reference). This also retires any
#    previous anchor for this branch, which is what keeps them from piling up.
ANCHOR=$(~/.claude/skills/retcon/mint-anchor.sh --branch "$BR" --id "$ID" | tail -1)

# 2. Reset to base, keeping the net diff as working-tree state.
#    --mixed, NEVER --hard (--hard discards the very diff you are restaging).
git -C "$WT" reset --mixed "$BASE"

# 3. Restage by logical group, in dependency order. `git status` after EVERY add
#    to confirm only the intended paths are staged.
git -C "$WT" add path/to/dedicated/feature/files
git -C "$WT" status --short
git -C "$WT" commit -m "<feature A: one-line summary>"
# …one commit per feature, implementation + tests together…

# 4. Docs, then repo-meta.
# 5. Generated/mechanical content, each kind its own commit.

# 6. Verify. THE check.
~/.claude/skills/retcon/verify.sh --anchor "$ANCHOR" --branch "$BR" --base "$BASE"

# 7. Publish (only if the branch was published and the user wants it):
git push --force-with-lease origin "$BR"
#    Other worktrees on $BR: git -C <other> reset --hard "$BR"
```

**Alternative staging for the review-branch shape** (building the retcon on a
*fresh* branch cut at base rather than resetting an existing one):

```sh
git switch -c "$SNAP" "$BASE"
git merge --squash "$BR" && git reset      # stages the FULL net diff, HEAD at base
```

Use `merge --squash`, **not** `git checkout <branch> -- .`. The latter overlays
files but does **not** apply deletions or renames, so files a rename moved linger
at their old paths and the tree silently doubles them — a net-diff violation you
will only notice at step 6.

**Nothing may be left over.** After the last commit, `git status --porcelain`
must be empty. A leftover unstaged or untracked file is unbucketed *substance*
you failed to classify — do not sweep it into the last commit with `git add -A`;
find the feature it belongs to. (`verify.sh` checks this.)

**Never `git add -A` into a noise commit.** Before committing generated content,
inspect `git status --porcelain` and confirm every path is genuinely generated.
Real source changes hide in that sweep — it is the single most-repeated mistake
in this skill's history, and the reviewer is the one who pays.

**Watch for ephemeral files entering tracked history.** A path that exists in the
snapshot because a tool wrote it (a temp file, a local cache, an editor artifact,
a runtime marker deleted on next start) must not be committed. If one is staged
and is not yet ignored, add the `.gitignore` entry in the same commit and unstage
the file. Committing it leaves a tracked-but-deleted entry that dirties the tree
on every subsequent run.

## Verify — and roll back if it fails

```sh
~/.claude/skills/retcon/verify.sh --anchor "$ANCHOR" --branch "$BR" --base "$BASE"
```

It asserts three things:

1. `git diff <anchor> <branch>` is **empty** — the decisive check; same tree.
2. `git status --porcelain` is empty — nothing left unbucketed.
3. Prints `git diff --stat <base>..<branch>` for eyeball comparison against the
   pre-retcon stat.

If (1) or (2) fails, the retcon went wrong. **Do not patch it up** — roll back
and start over:

```sh
git reset --hard "$ANCHOR"
```

## Dependents: branches and worktrees that pointed at the old tip

A rewrite strands anything forked from the old tip: its merge-base disappears, so
the next merge sees two divergent histories of net-identical content and
conflicts on everything, and no auto-resolution fixes it.

**When to handle it: at the moment the *original* branch advances — not at the
moment of the rewrite.** Under the snapshot cut those are different events, often
days apart. Rewriting `retcon/foo-<id>` strands nothing, because `foo` has not
moved; every dependent is still an ancestor. The strand appears when the user
integrates and `foo` advances past the dependents' fork. A no-op at rewrite time
is correct and is **not** evidence there is nothing to do later.

What must hold at that later moment is that the anchor **still exists** — it is
the proof reference. So: accept the retcon and re-point dependents in the same
sitting, and only then let the anchor go.

For each dependent branch:

```sh
git diff "$ANCHOR" <dep>          # empty ⇒ fully subsumed ⇒ safe to re-point:
git branch -f <dep> "$BR"         #   (the anchor makes this reversible)
```

A **non-empty** diff is not automatically net-new work — the branch may carry
content the rewrite deliberately dropped or curated forward — and must never be
blind-rebased. Inspect it and either `git rebase --onto "$BR" "$ANCHOR" <dep>`
once you have confirmed the delta is real work, or surface it to the user.

Other worktrees checked out on the rewritten branch: `git -C <wt> reset --hard <branch>`.

## Anchor lifecycle

Recovery refs accumulate invisibly and then cost a full session to unwind. Two
scripts keep that from happening.

**They live in their own ref arena** — `refs/backup/**` for live candidates,
`refs/rescue/**` for retired ones. Not tags (that is the *release* namespace;
recovery scaffolding interleaved with version tags makes `git tag --list` answer
nothing) and not branches (anything under `refs/heads/**` is visible to every
piece of branch-walking machinery in the repo, wanted or not). They remain
ordinary refs: objects stay reachable, `git update-ref -d` deletes,
`git for-each-ref refs/rescue/` enumerates.

### `mint-anchor.sh` — creation performs retirement

```sh
~/.claude/skills/retcon/mint-anchor.sh --branch "$BR" [--id 2026-08-08] [--dry-run]
```

**Invariant: at most one `pre-retcon-<branch>-*` anchor per branch.** Minting a
new one retires the previous to `refs/rescue/<name>` (an annotated tag *object*
created with `git mktag`, so the message naming what superseded it survives) and
deletes the old ref. This is why the anchor is never deleted by hand: it lives
until the *next* retcon of the same branch, which is always strictly later than
the dependent re-pointing that consumes it. The window closes because it was
superseded, not because a clock ran out.

Unlike its sibling this script **acts by default** (`--dry-run` to look first):
its only mutation is re-parking a ref at an identical commit, verified equal
before the old name is dropped.

### `audit-backup-refs.sh` — prove a ref safe to retire

```sh
~/.claude/skills/retcon/audit-backup-refs.sh                    # verdict per ref
~/.claude/skills/retcon/audit-backup-refs.sh --apply            # retire the provable ones
~/.claude/skills/retcon/audit-backup-refs.sh --older-than 30 --apply   # periodic sweep
```

It computes, per ref, the **exact set of objects deleting it would orphan**, then
classifies the residue by path:

| verdict | meaning | `--apply` action |
|---|---|---|
| `CLEAN` | 0 unique objects — all reachable from a durable ref | delete outright |
| `SUPER` | unique objects, but every unique blob sits on a path the tip still holds (an older revision of a live file) | park at `refs/rescue/<name>`, then delete |
| `REVIEW` | unique blobs on paths with no counterpart anywhere | **never** auto-retired — a human accounts for them |
| `PINNED` | a tracked file says `recovered_from: <ref>` or `evidence_ref: <ref>` | **never** retired, at any age |
| `ANCHOR` | a live `pre-retcon-*` anchor | skipped; `mint-anchor.sh` owns it |
| `YOUNG` | newer than `--older-than` | skipped |

**Age is a filter, never the predicate.** Prove containment first, *then* apply
the age cut. A bare age sweep is exactly the machinery that deletes the one
anchor a rescue still needed. If you find yourself adding a `--force`, re-read
this paragraph.

**`PINNED` and the absence of a verdict store.** Verdicts are recomputed from the
tree on every run, so a `REVIEW` a human already accounted for reappears. That is
deliberate. A record that could **grant** retirement would be a stale allowlist, a
switch a later run could trip; a record that can only **withhold** it cannot be
stale in the dangerous direction (worst case: a ref kept too long). So keeping a
ref is recordable — put `evidence_ref: <ref>` (a judgement) or `recovered_from:
<ref>` (an act: "I pulled content out of this ref") in a tracked file and it reads
`PINNED` — and *accounting for* a ref is not. Close a `REVIEW` by making the
underlying fact true so the verdict changes honestly, or by retiring the ref by
hand with the accounting written into the `refs/rescue/` annotation.

`--no-pins` reproduces the un-pinned verdicts, which is how you see what a pin is
holding back. Never pair it with `--apply`: that is precisely the run that deletes
the evidence a recovery drew on.

Three things it encodes that are easy to get wrong by hand:

- **`git rev-list --objects B --not <refs>` overstates uniqueness.** It marks
  trees UNINTERESTING lazily and will report a blob as unique when it is
  byte-identically the same object the tip already holds. The script uses an exact
  `comm -23` set difference. Do not "simplify" it back.
- **One deletion candidate cannot vouch for another.** All `refs/backup/**` refs
  are excluded from the durable set, as is `refs/stash` (worktree-local *and*
  shared across every worktree). Use `--ephemeral <regex>` to exclude any other
  ref class the repo reaps routinely.
- **Age means ref-creation time, not the tip's commit date.** A backup minted
  today can point at a months-old commit; `creatordate` would call it ancient and
  hand an age sweep exactly the anchor it must not take. The script reads the
  oldest reflog entry (which is why the creation sites pass `--create-reflog`).

## Pitfalls

- **`git reset --hard` instead of `--mixed`** in step 2 — discards the working
  tree and loses the net diff you were about to restage.
- **`git checkout <branch> -- .`** to stage the net tree — does not apply
  deletions or renames. Use `git merge --squash`.
- **Forgetting the anchor.** Without it the invariant check has no reference *and*
  there is no rollback.
- **Deleting the anchor too early.** Keep it until the user has reviewed and
  accepted *and* dependents are re-pointed. It is the only undo.
- **`git add -A` sweeping substance into a noise commit.** `git status` after
  every add; nothing unclassified at the end.
- **A bucket survey that enumerates a hand-picked list of directories.** Derive it
  mechanically: `git diff --name-only <base> <branch>` and account for *every*
  path. Every leak of substance into a noise commit traces back to a path nobody
  bucketed.
- **Grouping by component instead of feature**, or emitting features in discovery
  order instead of dependency order.
- **Rewriting a branch someone else has based work on** without re-pointing it.
- **Rewriting a skill/config file you are simultaneously editing on another
  branch** — expect a three-way conflict on reintegration, and expect a re-point
  to discard the later refinements. Land such edits in one place per cycle.
- **A published branch rewritten with plain `--force`** rather than
  `--force-with-lease`.

## Provenance

Generalized from a project-specific version of this skill, itself ported from
`kriskowal/garden`'s retcon. The invariant (net diff unchanged; only grouping changes) is garden's and
carries over verbatim. The feature-not-component rule, the separator test, the
dependency-ordering requirement, the dedicated-vs-hub technique, the
`merge --squash` staging fix, the noise-commit separation, and the
anchor-lifecycle machinery are all lessons paid for in real runs.

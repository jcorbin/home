---
name: lore-recall
description: Read-only LORE retrieval — given a question, a task, or a plan, read the corpus index, pick by judgment the entries that actually bear on it, read those in full, and return citations plus the facts that apply plus the gaps ("no entry covers X"). Use when starting non-trivial work in a repo that has a LORE corpus, when authoring or revising a task/plan file that a later session will execute, or any time an agent wants corpus knowledge without spending its own context walking every entry. Dispatch it as a cheap-tier subagent. Writes nothing except, when handed a file, that file's `## Relevant LORE` section.
---

# Lore recall

One question in, a short citation list out. This exists so an agent that needs
corpus knowledge does not spend its own context budget walking a hundred-entry
corpus, and so that what lands in a task file was **chosen for that task**
rather than keyword-matched at it.

Companion to `lore-capture`, which owns the corpus format, provenance rules, and
index discipline. This file does not restate them — one copy of a rule, or the
two copies drift.

## Why judgment, not keyword matching

This is the load-bearing design decision, and it is measured, not assumed.

A mechanical component/area matcher stamping the top-5 entries into each task
was measured over 91 completed tasks: **11 of 453 stamped entries (2.4%) were
ever cited outside the stamped section** — below what stamping 5 at random would
have landed, while 16 entries *were* cited that the matcher never offered. A
follow-up paired measurement showed the ranking does carry real signal (top-5
kept: 4.1% cited, vs 1.6% for the ones demoted to ranks 6–10, p=0.012) — but
that is a conditional result. **The ranking was never the bottleneck; the level
was.** Roughly a 4% ceiling.

So: do not re-run a matcher's logic, do not score tokens. **Read and decide.**
Selection by reading is expected to earn its keep on the two things a matcher
structurally cannot do — answering the *specific* question, and reporting
**gaps**.

(A related trap from the same work: the first attempt to A/B the matcher was
unusable because four contemporaneous 30-task cohorts of *unchanged* code read
4.1% / 0.7% / 2.7% / 5.7%. Between-task variance swamped the effect. If you ever
measure a change like this, measure the estimator's variance first.)

## Corpus location

```
~/.claude/skills/lore-capture/lore-dir.sh -v
```

One script, shared with `lore-capture`, rather than each skill re-deriving the
lookup. If it exits non-zero there is no corpus here: say so and stop. Do not
create one as a side effect of a read.

## Posture — read-only, and narrowly so

- **Never edits the corpus.** Not the entries, not `INDEX.md`. A recall pass
  that notices the index is wrong *says so in its answer*; a human or a
  `lore-capture` pass fixes it.
- **Never edits any file except the one it was handed**, and within that file
  only the `## Relevant LORE` section. Everything else belongs to the author.
- **Never invents an entry.** Every citation must be a file that exists. A
  hallucinated citation is worse than no citation: it costs the next reader a
  lookup and it *reports as coverage*.
- **An empty citation list with a real gaps section is a good answer,** not a
  failed one.

## Procedure

1. **Read `INDEX.md` once, whole.** Every entry has a one-line gist and tags there.
2. **Select by judgment.** Ask what this task will actually *do* — which files it
   touches, which seams it crosses, which failure modes are in reach — and pick
   the entries that bear on that. Cross-cutting entries count: a task about
   config may need a git entry. **At most 5.** Fewer beats padding.
3. **Read the selected entries in full.** Not the gist. The gist is a lead
   sentence by construction, and corrections may sit below the cut. *Selection*
   happens on the index; *distillation* happens on the entry.
4. **Distil.** One line per entry on why **this** task needs it — specific enough
   that a reader can tell whether to open the link. "May be relevant to the
   component" is not an answer.
5. **Name the gaps.** What does this work turn on that no entry covers? This is
   the output nobody else produces and it is not optional. Write `(none)` only
   after actually looking.

## Output — answering a question

Prose is fine. Citations (slug + one line why), the facts distilled from
reading them, then the gaps. Then stop — the caller does what it was going to do.

## Output — enriching a task or plan file

Replace the file's `## Relevant LORE` section, idempotently. A section spans
from its heading through the line before the next heading of the **same level or
shallower** (or EOF); deeper subsections nest inside it. Take the level from the
heading itself — hardcoding `##` means an H1 later in the file does not stop the
scan, and the replacement eats the rest of the document.

```markdown
## Relevant LORE

Selected by lore-recall on 2026-08-11 by reading this task against the corpus
index — not a keyword match. Open any that touch your work before you start.

- [`some_slug`](../LORE/some_slug.md) — why THIS task needs it, in one line.
- [`other_slug`](../LORE/other_slug.md) — likewise.

**Key facts:**

- The specific thing from an entry above that applies here, with the slug it
  came from.

**Gaps** — no entry covers:

- The thing this task turns on that the corpus is silent about. Or `(none)`.
```

Two rules on that block:

- **The lead paragraph begins with `Selected by lore-recall`.** That marker is
  what later lets a citation census tell a *curated* section from a
  *generated* one — which is the whole basis of the genuine-vs-auto split that
  `lore-capture`'s review pass runs on. Forging it over a mechanical answer
  corrupts the only measurement the system has.
- **Cite the slug literally**, in a link whose text is the slug. The census
  greps for slugs; a citation that never spells one is invisible to it.

If the file has YAML frontmatter, stamp `lore_recall_at: <ISO-8601 UTC>` and
nothing else. No `lore_refs:` list — that is a second copy of the citations in
the body, and it drifts the first time someone edits one of them.

## Dispatching a recall pass — the caller's recipe

**Dispatch as a subagent on the cheap/fast tier.** Under this harness that is an
`Agent` call with a small `model`. The procedure above is deliberately bounded
(one index read, at most a handful of entry reads) so it fits a small model's
competence. The prompt needs nothing but a pointer — this file is the contract:

> Follow `~/.claude/skills/lore-recall/SKILL.md` against `<path>`, per its
> "Output — enriching a task or plan file". Replace that file's
> `## Relevant LORE` section. Change nothing else in that file, and no other
> file.

**One file per dispatch.** Five tasks means five small passes, not one pass over
five files. Each pass then touches exactly one file, so a bad pass damages one
task instead of the batch — and five small passes fit the cheap tier where one
big one would not.

**Dispatch synchronously — never in the background.** Backgrounding inverts the
ordering: you proceed without waiting, you commit, the commit makes the file
claimable, and the pass's write then races whoever picked it up. Observed
failure: a backgrounded pass reported success, but by then the file had been
moved under a claim, so its edit went to a path that no longer existed and was
silently lost. A fan-out may run N concurrent passes; what must not happen is
the **caller** proceeding past them.

**Run it after the body is final, before the commit.** A pass followed by more
content edits is a selection made against a document that no longer exists.

**When it cannot run, write nothing.** No Agent tool, degraded session, provider
outage, agent returned junk → proceed without the section and without the
timestamp. Absence is a signal a later pass can act on; a stamped
`lore_recall_at` with no work behind it suppresses that fix forever.

**Verify before committing.** A small model just edited a file:

```sh
grep -c '^Selected by lore-recall' <path>     # 1 — curated, not a forged lead
grep -oE '[a-z0-9_]+\.md' <path> | sort -u    # then check each exists in the corpus
```

Every cited file must exist. This check costs one command and catches the one
failure mode that reports as coverage.

**Recovering a stalled pass — resume, don't re-dispatch.** A pass that dies
mid-stream has usually already read the index and the entries and died on the
way to its edit. Resuming with "make the edits now, no further reading" is
strictly cheaper than a fresh dispatch, which repeats the expensive part.
Re-dispatch only when resume is unavailable or the output was *wrong* rather
than absent. Two failures on one file → write nothing and move on; a stalled
provider is not a reason to hold a commit.

**When to re-run.** New task → always. Materially rewritten task (what it *does*
changed) → yes. Retitle, typo, status change → no.

## Editing this skill later

Never put a bare dollar-digit token in this body: the loader splices the
caller's positional arguments into it before the agent reads it, code fences
included, silently. Bind to a named variable, write `$<digit>` or `${1}` in
prose, or put the recipe in a script — script files are not substituted.

---
name: lore-capture
description: Extract durable, transferable lessons from finished work into a LORE corpus of one-lesson-per-file entries with provenance and an index, so a future session gets the lesson without re-paying for it. Use after a hard debugging arc, a surprising failure, a wrong-but-plausible theory that cost real time, or a design decision where an option was rejected for a reason; when the user says "capture that as lore", "mine the learnings", "write that up for next time"; or when archiving a batch of completed work. Also runs the citation-review pass that surfaces never-cited entries as retirement candidates.
---

# Lore capture

A **LORE corpus** is a directory of one-lesson-per-file markdown entries plus an
`INDEX.md`. Its purpose is narrow: *a future agent, with no access to this
session, should not re-pay for what this session already learned.*

That purpose sets every rule below. An entry is not documentation and not a
changelog — it is **input to a future agent**, which is why provenance is
required, why the title is a claim rather than a topic, and why the corpus needs
pruning as much as it needs growth.

## What is lore, and what is not

Write an entry when a future reader would otherwise **do the wrong thing**.

| Not lore | Where it belongs |
| --- | --- |
| How this code works | doc comments, `DESIGN.md` |
| How to build/test/run this project | `CLAUDE.md` |
| What changed and why, in this diff | commit message, PR body |
| Who the user is, what they prefer, what project is live | the memory system |
| A one-off typo, a routine refactor | nowhere |

The test that settles most cases: **strip the session away — is the lesson still
recoverable from the code?** If a reader would find it by reading the file they
are about to edit, it is a comment, not lore. Lore is what the code *cannot*
tell you: that the obvious check is unreachable, that the adjacent log line is
noise, that this tool's success return is not a durable landing.

Six shapes that reliably earn an entry:

1. **A surprise that cost time** — the mechanism was not what anyone would guess.
2. **A plausible-but-wrong theory** that a competent reader would form again.
   Record the falsifying command, not just the conclusion.
3. **A rejected option with its rationale** — the next person will propose it again.
4. **A recurrence** — the same shape has now bitten twice in different clothes.
5. **A false green** — a check, test, or gate that passed while the thing was broken.
6. **A directive with a why** — a rule the user set, plus the cost that motivated it.

## Where the corpus lives

```
~/.claude/skills/lore-capture/lore-dir.sh -v          # resolve; explain the choice
~/.claude/skills/lore-capture/lore-dir.sh --create    # make one if none exists
```

Resolution, first hit wins: `CLAUDE_LORE_DIR` → `<repo root>/LORE/` → `~/LORE/`.

Choose scope by **who the lesson binds**. A lesson about *this* codebase's seams
goes in the project corpus, versioned with the code that made it true. A lesson
about a tool, a language, a harness behaviour, or your own working method goes
in `~/LORE/` and travels. When it could go either way, prefer project — a
portable lesson is easy to promote later; a project-specific one polluting the
cross-project corpus is noise in every unrelated repo.

## The title is the lesson

This is the single highest-leverage rule in the system. A reader scanning an
index of 120 gists is reading **titles as assertions**, and an entry titled for
its topic delivers nothing until opened.

```
GOOD  adjacent_log_line_is_not_evidence
GOOD  write_success_is_not_a_durable_landing
GOOD  a_check_no_caller_reaches_is_green_everywhere
BAD   flake_investigation_notes
BAD   logging_gotchas
BAD   thoughts_on_error_handling
```

Slug: `snake_case`, states the claim. H1 title: the same claim in a full
sentence, with the mechanism if it fits.

## Entry format

```markdown
---
kind: lore
tags: [pattern, process-hazard, evidence-quality, recurring]
created: 2026-08-11
# Provenance — REQUIRED. See "Provenance is the trust chain" below.
sources: [<commit sha / PR / issue / task file / dated user directive>, session <uuid>]
---

# The claim, stated as a claim

## The mechanism
What actually happens, concretely. Real paths, real commands, real output.

## What it cost, and why that polarity is dangerous
Not "this was annoying" — what a reader who does not know this will *do*, and
why the wrong result looks like a right one.

## The rule
The next reader's actual next move. One or two commands if there are commands.

## Siblings, not duplicates
Links to related entries with one line on how this one differs. Two entries
that read as the same lesson should be one entry.
```

`## Siblings` matters more than it looks: it is the mechanism that keeps a
corpus from accumulating five near-duplicates of one lesson, and writing it
forces you to check whether you should be *folding* rather than minting.

## Provenance is the trust chain

`sources:` is required on every entry, and it is not bookkeeping. Entries get
selected into future agents' context, so "where did this directive actually come
from?" is a trust question a reader must be able to answer without you.

- At least one source must resolve to something real and checkable — a commit,
  a PR, an issue, a task file, or a dated directive from the user.
- Add the session id when known; it is the tightest anchor for "which run
  produced this".
- Never fabricate one. If you cannot determine the session, list what you can.
- Use a flow list on the key line (`sources: [a, b]`) or an indented block list.
  A flow list whose `[` opens on the *next* line parses to zero items, and the
  failure looks exactly like an entry that cites nothing.

## The index, and the lead-sentence rule

`INDEX.md` is a table per area: link, one-line gist, tags. **Writing an entry
without adding its index row is not done** — a corpus is discovered through its
index, and an unindexed entry is invisible. `lore-lint.sh` fails on it.

The gist carries a rule that governs every later edit:

> **A gist's lead sentence is the whole message.** Anything that reads only the
> lead — a person skimming, a stamp that truncates — must not be misdirected by it.

So when a new instance comes back to an existing entry, decide which it is:

- **Incident** — another site, another cost, more evidence for a lead that still
  stands. Append it to the tail. The tail is the entry's history.
- **Correction** — it retires a check, replaces a command, inverts a conclusion,
  or makes the lead's obvious next move the wrong one. **Fold it into the
  lead.** Rewrite the lead to say the current thing; move the retired wording
  down with `Superseded (<ref>):`.

The test is the reader's next move, not the wording: *acting on the lead alone,
does a reader do something this instance proves wrong?* A lead that states a
hazard and a tail that adds a remedy is not a correction — nothing in the lead
misdirects.

Two markers, and the difference is which one is live. `Corrected by <ref>:`
means "the text near this is wrong" and belongs in the **lead**.
`Superseded (<ref>):` labels the retired version kept in the **tail**.

## Procedure — capturing from the session you just finished

1. **Resolve the corpus** (`lore-dir.sh`); read `INDEX.md` before writing anything.
2. **State the lesson in one sentence, as a claim.** If you cannot, you do not
   have a lesson yet — you have a war story.
3. **Check for an existing entry it belongs to.** Folding beats minting; a
   second instance is usually the *strongest* thing you can do to an entry,
   because recurrence is what makes a lesson credible.
4. **Write the entry** (or fold), with real evidence — the command, the output,
   the path. Prose that summarises evidence you did not paste is not evidence.
5. **Add the index row** in the same change. Entry and index are a dual write.
6. **Run `lore-lint.sh`.**
7. **Commit** with the entry and index row together, if the corpus is versioned.

### Folding is a dual write too

When you fold a new instance into an existing entry, **extend its `sources:` as
well as its body**. Provenance that names only the original occurrence makes the
new one invisible to every later "is this already captured?" check — including
your own, next month.

## Procedure — mining a batch

For a sweep over many finished items (an archive pass, a retro, "extract
lessons from the last two months"):

1. **List the targets and print the count before proceeding.** A mining run
   whose scope was never stated is a run nobody can reproduce.
2. **Read in batches**, and produce a *report first*, not entries. One block per
   candidate: source, type (surprise / wrong-theory / rejected-option /
   recurrence / false-green / directive), the lesson in one sentence, whether it
   is a new entry or a fold into an existing slug.
3. **Present the report and let the user decide** which candidates land. A
   batch mine that writes 14 entries unprompted is how a corpus goes abundant
   and inert. A single lesson from the session you just did is different — write
   that one directly and show what landed.
4. **Deduplicate across the batch** before writing. One saga produces one entry,
   not one per commit.

## Citation review — the counter-pressure

Mining only ever grows a corpus. Growth without pruning is itself a documented
way to *degrade* transmission: an entry can be present, auto-injected into every
relevant context, and still functionally invisible because no session ever
reached for it.

```
~/.claude/skills/lore-capture/lore-cite.sh     # census: genuine vs auto citations
```

The split is the point. A mention under a `## Relevant LORE` heading is
*auto-selected* — the machine handed it over, which is not evidence anyone used
it. A mention anywhere else is *genuine*. **Many auto, zero genuine** is the
sharpest abundance signal available.

Entries younger than the grace window (default 30 days) are reported separately
as too new to judge — a new entry has not had a fair chance to be cited.

Report one block per candidate: references (total, auto/genuine), age, signal
(never-cited / auto-only / long-uncited), one line on what it claims and whether
a newer entry supersedes it, and a recommendation: retire / keep (say why it is
still load-bearing) / merge into `<other slug>` / defer.

**This pass produces a queue; it does not empty it.** Retirement is a decision
on review, exactly like promotion is. An uncited entry may be a lesson nobody
has needed yet — or one whose slug nobody could guess, which is a *title* bug,
not a retirement case.

## Lint

```
~/.claude/skills/lore-capture/lore-lint.sh     # errors: provenance, index, structure
```

Errors are mechanical: missing frontmatter, empty `sources:`, no `created:`, no
H1, entry missing from the index, index linking a file that does not exist.
Warnings cover the lead-sentence discipline above.

## Editing this skill later

**Never put a bare dollar-digit token (`$<digit>`) in a SKILL.md body — code
fences do not protect it.** The skill loader substitutes the caller's positional
arguments into the body *before the agent reads it*, with no marker and no
warning, so an `awk` recipe referring to the whole record arrives with the
caller's first argument spliced in, matches nothing, and returns a plausible
empty answer. The file on disk is correct the whole time, which is why grepping
it "to verify the recipe" verifies a version you were never handed.

That is why every recipe here is a call to a script on disk: script files are
not substituted. Keep it that way. If prose must name the token, write it as
`$<digit>` or `${1}` — both are inert to the substitution.

## What this skill does not do

- **Does not delete or retire entries autonomously.** The review pass proposes.
- **Does not write a batch of entries unprompted.** Report, then land what the
  user picks. One lesson from the session at hand is the exception.
- **Does not mine source code.** Docs drift is a different pass.
- **Does not read the corpus for a task.** That is `lore-recall`, which exists
  so retrieval does not spend this session's context.

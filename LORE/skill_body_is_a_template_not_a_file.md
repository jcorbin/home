---
kind: lore
tags: [tooling, false-green, agent-harness, skills, evidence-quality, recurring]
created: 2026-08-11
sources: [pivoker LORE/skill_body_is_a_template_not_a_file.md, pivoker TADA/1537, pivoker TODO/1538, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A skill body is a template, not a file — a dollar-digit token is rewritten before you read it

## The mechanism

The skill loader performs **positional argument substitution on the `SKILL.md`
body before delivering it to the agent**. Every `$0`, `$1`, `$2` is replaced by
the corresponding word of the caller's `args` — **including inside fenced code
blocks**, which the substitution does not treat as inert.

`Skill(groom, args: "devoker — Epoch 12 …")` delivered an awk recipe written as

```
m=split(<whole-record>,a," ")
```

with the record variable replaced by the literal word `devoker`. In awk that is
an unset variable, so `m=0`, the loop never runs, and the recipe emits
**nothing**. No marker in the delivered text, no warning, no diagnostic. The
file on disk was correct the whole time.

## What it costs

That recipe computed which ids were *referenced* by live work — the input to an
archive decision. An empty token set does not error; it reads as "nothing is
pinned", which is plausible, and it licenses moving files that live work cites.

## Diagnosis: compare received against on-disk, first

When a recipe from a skill misbehaves, the first act is **not** to debug the
recipe. It is one command:

```sh
/usr/bin/grep -n 'split(' path/to/SKILL.md
```

…then compare that to the text you were actually handed. If they differ, that
comparison *is* the whole diagnosis.

The sharper corollary: **grepping the skill on disk to "verify" a recipe
verifies a version you were never given.** A session that checks the file and
concludes "the recipe is fine" has confirmed nothing about the text it ran. The
delivered body is not persisted anywhere you can read it back — the value *is*
the invocation.

## The rule

When editing **any** skill: a dollar-digit token in a code block is not inert
text. Write runnable recipes with no positional token at all.

- **awk** — let `gsub` re-split the record and use `NF` / `$i`; never the
  whole-record or first-field variables by their positional names.
- **shell** — bind to a named variable (`f="$lf"`), never a bare positional.
- **prose that must name the token** — write `$<digit>` or `${1}`; both are
  inert to the substitution and still readable.
- **Best of all: put the recipe in a script file.** Script files are not
  substituted. A skill body that only *calls* scripts cannot have this bug.

If a positional is genuinely unavoidable, say so in the skill *next to it*, with
what a correct delivery looks like — a warning three lines below a
copy-pasteable broken command loses to the command.

## Siblings

- [[agent_shell_may_shadow_a_standard_binary]] — same polarity two runs running,
  but there a shell function shadowed a binary and `type <cmd>` finds it. Here
  the binary is honest and the instruction was corrupted in transit.
- [[prose_cannot_retire_a_runnable_instruction]] — about a *stale* runnable
  instruction. Here the instruction on disk is current and correct.

---
kind: lore
tags: [tooling, false-green, agent-harness, skills, evidence-quality, recurring]
created: 2026-08-11
sources: [pivoker LORE/skill_body_is_a_template_not_a_file.md, pivoker TADA/1537, pivoker TODO/1538, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323, incident 2026-08-11 authoring ~/.claude/skills/lore-capture in that same session]
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

When editing **any** skill: a dollar-digit token is not inert text **anywhere in
the body — prose and code fences alike.** Write runnable recipes with no
positional token at all.

> **Corrected by the 2026-08-11 incident below:** this rule previously read *"a
> dollar-digit token **in a code block** is not inert text"*. Scoped that way it
> reads as licensing prose, which is exactly the mistake that incident made.
> `Superseded (2026-08-11):` "a dollar-digit token in a code block is not inert
> text."

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

## Incident, 2026-08-11: the warning is subject to the warning

Authoring `~/.claude/skills/lore-capture` — a skill whose closing section exists
purely to warn future editors about this hazard — the warning itself was written
as:

```
**Never put a bare `$0`–`$9` in a fenced block in a SKILL.md body.**
```

Three literal dollar-digit tokens, in inline code, in prose. Invoked with any
arguments, the loader would have delivered *"Never put a bare `pivoker`–`` in a
fenced block"* — the warning about mangling, mangled, and mangled in a way that
destroys the very characters that identify the hazard. Caught on a final
`grep -n '\$[0-9]'` sweep of the file before finishing, not by writing it.

Two things generalise:

- **The scope was the bug, not the carelessness.** The author knew the rule and
  applied it correctly to every code fence in the file. The rule as written said
  "code block", so prose read as exempt. A rule stated narrower than its
  mechanism will be obeyed exactly as narrowly as it is stated.
- **A document about a hazard is written in the medium the hazard operates on.**
  Warnings, examples, and the "here is what the broken version looks like"
  snippet are all live text. **After writing any document that describes a
  trap, run the trap's own detector against that document.** Here that is one
  command:

  ```sh
  /usr/bin/grep -n '\$[0-9]' path/to/SKILL.md
  ```

## Siblings

- [[agent_shell_may_shadow_a_standard_binary]] — same polarity two runs running,
  but there a shell function shadowed a binary and `type <cmd>` finds it. Here
  the binary is honest and the instruction was corrupted in transit.
- [[prose_cannot_retire_a_runnable_instruction]] — about a *stale* runnable
  instruction. Here the instruction on disk is current and correct.

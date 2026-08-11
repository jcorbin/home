---
kind: lore
tags: [tooling, false-green, evidence-quality, agent-harness, diagnosis, recurring]
created: 2026-08-11
sources: [pivoker LORE/agent_shell_shadows_grep_with_ugrep.md, pivoker TOQU/1487, pivoker TADA/1497, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# The agent's shell may shadow a standard binary, and the wrong answer is byte-identical to the right one

## The mechanism

Claude Code's shell snapshot (`~/.claude/shell-snapshots/snapshot-zsh-*.sh`)
installs shell *functions* over standard utilities — its own comment says
*"Shadow find/grep with embedded bfs/ugrep"*. A bare `grep` in an agent shell
can therefore exec `ARGV0=ugrep … -G --ignore-files --hidden -I`, not GNU grep.

ugrep and GNU grep are not the same engine. Measured: ugrep treats `^` **inside
an alternation group** as unmatchable, so the boundary idiom

```
(^|[^0-9])PREFIX([^0-9]|$)
```

returns **0** matches where GNU grep returns **16**. The alternation works. The
anchor works. Only the anchor *inside* the alternation breaks — and there is no
stderr, no warning, and an `exit 1` that is the perfectly correct result of an
honest zero-match.

## What it costs, and why the polarity is the dangerous part

On a real corpus that scored 5 pinned / 78 free against a truth of 30 / 53 —
one `git mv` away from archiving 24 files that live work still cited. It was
caught only because an unrelated finding contradicted the table.

A zero-match reads as *"nothing references this"*, which is a plausible answer
and it **licenses destruction**. This is worse than the ordinary false-green
family: with a tool that refuses loudly you can gate on stderr; here the refusal
and the success paths produce byte-identical output, so **no output-shaped gate
exists**. The only defence is calibration.

It is also invisible from outside the harness. `zsh -ic 'which grep'` answers
`/usr/bin/grep`, so a human reproducing your command by hand cannot see your
bug, and "I verified the regex" from any other posture verified nothing.

## The rule

1. **`type <cmd>` is the one-line check.** Run it before trusting any sweep.
2. **Name the binary for anything that must be exhaustive** — `/usr/bin/grep`
   or `rg`, never bare `grep -r`.
3. **Prefer an idiom with no anchor-in-alternation at all** — a deterministic
   `awk` token pass does not depend on which regex engine you got.
4. **A zero-match must never license a destructive act until the detector has
   reproduced a known positive.** Feed it something you know it should find.

The general form, which is the part worth keeping: **for any computation that
licenses a destructive step, derive the answer a second, independent way before
taking the step.** Inspecting the failing mechanism does not find this class —
the contradiction always comes from outside it.

## Siblings

- [[skill_body_is_a_template_not_a_file]] — same silent-zero-match polarity, one
  layer over: there the binary is honest and the *instruction text* is mutated in
  transit, so interrogating the tool finds nothing.
- [[mise_untrusted_config_exits_zero_false_green]] — same family, but mise leaves
  a stderr tell you can gate on. This one leaves none.

---
kind: lore
tags: [shell, false-green, tooling, anti-pattern, testing]
created: 2026-08-11
sources: [authored 2026-08-11 while writing ~/.claude/skills/lore-capture/lore-lint.sh, session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A checker that tallies findings inside a pipeline reports zero while printing them

## The mechanism

Bash runs each stage of a pipeline in a **subshell**. A counter incremented
inside `| while read` is incremented in that subshell and discarded when the
pipeline ends:

```bash
errors=0
err() { errors=$((errors + 1)); printf 'ERROR %s\n' "$*"; }

find_problems | while read -r p; do err "$p"; done   # ← counts vanish here

printf '%d errors\n' "$errors"      # 0
exit $(( errors > 0 ))              # 0 — success
```

The findings **print correctly**. A human reading the output sees the errors. The
summary line says `0 errors` and the exit code says clean, so anything consuming
this programmatically — CI, a pre-commit hook, `&&` in a script — reads it as a
pass.

That polarity is the whole hazard: the loud, human-facing half works, so nothing
prompts you to check the quiet, machine-facing half.

The fix is one character of structure — feed the loop by **process
substitution**, so the loop body runs in the current shell:

```bash
while read -r p; do err "$p"; done < <(find_problems)
```

## The second shape: a tool re-invoked over your input

`xargs` may split a long input list across **several** invocations of the
command. Each invocation runs its own `END` block, so a per-file tallying `awk`
emits one partial result set per batch:

```bash
xargs -a files -d '\n' awk '…{count[key]++} END{for (k in count) print count[k], k}'
```

Small input: one invocation, correct output, passes review. Large input: N
invocations, N partial rows per key, and whatever consumes it either double-counts
or silently keeps the last batch. **The bug is latent in exactly the direction
that hides it — it appears only at scale, and only once the tool is useful.**

Either aggregate the partials in a second pass, or guarantee a single invocation
(and accept `ARG_MAX`). Aggregating is the safer default:

```bash
… | awk -F'\t' '{n[$2] += $1} END {for (k in n) printf "%d\t%s\n", n[k], k}'
```

## The rule

**A checker's exit code and its printed findings are two separate claims.**
Verify them separately, on a fixture with a **known non-zero** number of
findings:

```bash
./check.sh broken-fixture; echo "rc=$?"   # must be non-zero, and the count
                                          # must match the printed lines
```

Never gate CI on a checker that has not been demonstrated to fail. This is the
same discipline as reproducing a known positive before trusting a zero-match —
a checker that has only ever been run on clean input has demonstrated nothing
except that it does not crash.

## Provenance note

Both shapes were caught in review while authoring `lore-lint.sh` and
`lore-cite.sh`, before either ran against a real corpus — so the evidence here is
the code shape and a constructed reproduction, not a production incident. That is
also why it is worth writing down: the pipeline version had already been typed
twice, and reads as completely ordinary.

## Siblings

- [[mise_untrusted_config_exits_zero_false_green]] — the same "exit 0 means the
  process declined to fail, not that the work happened" family, from the tool
  side rather than the author side.
- [[agent_shell_may_shadow_a_standard_binary]] — where the fix is calibration:
  reproduce a known positive before trusting a zero.
- [[a_check_no_caller_reaches_is_green_everywhere]] — green because nothing
  asked, rather than green because the tally was dropped.

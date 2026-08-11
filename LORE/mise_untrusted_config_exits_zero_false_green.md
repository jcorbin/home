---
kind: lore
tags: [tooling, ci, false-green, mise, process-hazard, recurring]
created: 2026-08-11
sources: [pivoker LORE/mise_untrusted_config_exits_zero_false_green.md, pivoker DOIN/936 session 1, pivoker TADA/1417, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# `mise run` in an untrusted directory runs nothing and exits 0

## The mechanism

A fresh checkout — a new worktree, a clone, a CI scratch path — is an untrusted
path, so its `mise.toml` is untrusted. `mise run` then refuses to do anything
and **exits 0 anyway**:

```console
$ mise run //project:test ; echo $?
mise ERROR Config files in /path/to/wt/mise.toml are not trusted.
Trust them with `mise trust`. ...
0
```

Zero tests ran. Exit code says success.

Newer mise shares trust across git worktrees — a config in a linked worktree is
trusted once the equivalent path in the **main checkout** has been. That retires
this entry only if you *have* such a path: with a **bare** main repo there is no
equivalent path to inherit from, and every worktree starts untrusted. Check the
claim against your own layout before believing an upstream fix applies to it.

## Why it bites the *before* run specifically

The workflow rule is "run the tests before and after the change". The **after**
run is scrutinised — you want to know your change passed, so you read it. The
**before** run is a formality, expected to be boring and green, often
backgrounded and skimmed by `tail`. That asymmetry is the whole hazard: the
formality is the one that silently lies.

A fabricated baseline is worse than no baseline. It licenses "my change didn't
break anything" against a suite that never executed, and it equally hides a
**pre-existing** red you then inherit.

## The rule

- **`mise trust <path>/mise.toml` as a reflex on entering a fresh checkout**,
  before the baseline run — not after something looks wrong.
- **Never accept exit 0 as proof a suite ran.** Gate on evidence of work: `ok
  <pkg>` lines, a test count, `grep -c FAIL` over the output. It costs nothing.
- **A green you did not look at is not a green.** If a backgrounded run's only
  evidence is "exit code 0", open the output before believing it.
- **Automation needs the assertion, not the reflex.** A human can be told to
  remember; a gate that shells out to a wrapper cannot. Block on the refusal
  *in the output*, regardless of exit code.

## The generalisable shape

`exit 0` means "the process declined to fail", which is not "the work happened".
Any wrapper — `mise`, `make`, a shell script chaining `&&`, a task runner — can
swallow a precondition failure and still exit clean. **When a tool's refusal
path and its success path share an exit code, the exit code has stopped being a
signal.** Gate on output that only real work can produce.

## Siblings

- [[agent_shell_may_shadow_a_standard_binary]] — the harder version: there the
  refusal and success outputs are byte-identical, so no output-shaped gate
  exists either.
- [[write_success_is_not_a_durable_landing]] — same "success is not work" shape
  one layer in, at the write call.

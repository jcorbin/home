---
kind: lore
tags: [testing, concurrency, git, diagnosis, anti-pattern, recurring]
created: 2026-08-11
sources: [pivoker LORE/tool_forks_a_detached_helper_behind_your_back.md, pivoker TADA/1468, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A tool can fork a detached helper that outlives your call

## The mechanism

A fixture that shells out to a real binary can be left with a writer that no
"what is still running?" reasoning finds, because **it is not in the fixture's
source** — it is the binary's own detached helper.

`git commit` ends by forking `git maintenance run --auto --quiet --detach`. That
child writes into `.git/objects/pack` after the commit has exited and after the
test has returned. Meanwhile `os.RemoveAll` empties a directory and *then*
unlinks it, so a file landing between those two steps fails:

```
TempDir RemoveAll cleanup: unlinkat …/.git/objects/pack: directory not empty
```

on a test whose assertions all passed.

## The tells

- **The failure is in cleanup, not on a test line.**
- **`ENOTEMPTY` means a live writer** — `RemoveAll` only reports it *after*
  emptying the directory, so something re-created a file in the gap.
- **It needs load.** An idle host will not reproduce it: 1440 parallel fixture
  repos and six instrumented suite passes produced zero hits.

## The rule

1. **Run `GIT_TRACE=1` (or the tool's equivalent) on the one suspect command and
   read for `run_command` — before budgeting a stress reproduction.** One
   command answers what a day of load testing might not.
2. **Disarm the fork at its source**, in the shared fixture runner:
   `git -c maintenance.auto=false -c gc.auto=0 commit …`. Never a cleanup retry
   — that hides every *other* writer behind the same window.
3. **Pin it on the process tree, not on config.** `git config maintenance.auto`
   reads `false`-and-passing with the flags deleted, because a `-c` override is
   not persisted. **The value IS the invocation.**

## The generalisable part

Before concluding "nothing else could be writing here", ask what the tools you
called may have spawned on their way out. The set of live writers is not the set
of processes your code created.

## Siblings

- [[agent_shell_may_shadow_a_standard_binary]] — the other half of "the value is
  the invocation": what you get is a property of the call site, not of anything
  you can inspect afterwards.
- [[a_test_that_reads_shared_mutable_state_is_flaky_by_construction]] — the same
  class of red-then-green-on-re-run that trains its reader to dismiss the gate.

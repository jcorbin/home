---
kind: lore
tags: [durability, lifecycle-hazard, pattern, bug-saga, recurring]
created: 2026-08-11
sources: [pivoker LORE/durable_state_ordering_breadcrumb_before_killswitch.md, pivoker TADA/562, pivoker TADA/1339, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Write the durable recovery trace BEFORE the destructive act, not after

## The mechanism

A trace written *after* a destructive step can be lost to **the very failure it
was meant to survive** — and a destruction with no trace is indistinguishable
from "it never existed".

Two instances, and the second is the one people miss:

- **Inside the crash window.** A hard reboot between a committed kill-switch and
  its not-yet-written breadcrumb bricked the host, with nothing on disk to drive
  the auto-clear.
- **Outside it, with no crash at all.** Two pieces of work were dropped with no
  decline note written. Five days of cleanup passes, a full audit, two history
  rewrites and a retcon all passed straight over the loss — **none of them look
  for something that isn't there.** The only surviving copy was in a backup ref
  that happened to refuse automatic retirement.

## The rule

1. **Order the writes so the trace lands first.** Trace, then destroy.
2. **A reorder alone is not sufficient** when the pre-fix code has already
   written state on disk in the bad shape. Pair the reorder with a source-gated
   self-heal that recognises and repairs the old shape.
3. **A destructive path's done-criteria must name the trace it leaves.** "The
   work is dropped" is not a completion condition; "the decline note is
   committed at X" is.
4. **"The parent landed fine" says nothing about its children.** Cascading
   destruction needs a trace per casualty.

## Why absence is the hard case

Every audit is built to check that things are *right*. Almost none are built to
notice that something is *gone*, because the gone thing left no row to inspect.
That asymmetry is why the ordering has to be right the first time — no later
process will catch it for you.

## Siblings

- [[a_fix_cannot_protect_its_own_deploy]] — the same "the window is where it
  bites" reasoning for deploys rather than crashes.
- [[silent_failure_log_and_swallow]] — the same invisibility, from a failure
  that was caught and quietly discarded.

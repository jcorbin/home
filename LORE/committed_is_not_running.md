---
kind: lore
tags: [deploy, config, systemd, evidence-quality, process-hazard, recurring]
created: 2026-08-11
sources: [pivoker LORE/enabled_in_the_repo_is_not_enabled_in_the_realm.md, pivoker LORE/reexec_invisible_to_systemd.md, pivoker TADA/1130, pivoker TADA/1148, pivoker TADA/1336, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Committing `enabled: true` records an intent — the system changes when the process holding the setting restarts

## The mechanism

For any restart-class setting, the commit is not the change. The behaviour moves
only when the process that holds the setting picks up the new value, and
typically **nothing enforces that it did**.

Two ways it goes wrong, and they are different questions:

- **Nothing restarted.** A feature was armed by a commit, three documents
  recorded it as armed, and the holder had been running since two days before
  the feature's *code* existed. It was inert for a day.
- **Something restarted and no one could tell.** Where two mechanisms act on one
  deploy event they must key on the **same signal**. A self-restart watch keyed
  on the *binary* correctly re-exec'd; an "is this an upgrade?" check keyed on
  the *version string* did not fire, so a same-commit rebuild swapped every live
  process onto new code with no announce and no post-upgrade wake — while the
  freshness rubric read `current`, accurately, because the sha never moved.

## Do not ask systemd

**A healthy in-place `syscall.Exec` re-exec is invisible to systemd's restart
bookkeeping.** `NRestarts`, `ExecMainStartTimestamp` and `MainPID` do not move.
Reasoning from those fields cost 1.5 days chasing a fabricated recurrence, and
they had been condemned by name a month before the sessions that used them
anyway.

Ask what the process **executes**:

```sh
readlink /proc/$PID/exe            # the inode actually running
# then, with the build sha it reports:
git merge-base --is-ancestor <commit> <running-sha>
```

Never `stat /proc/$PID/exe` — that mtime is the process's, not the binary's.
Note also that a unit which re-loads config on every start *cannot* be stale,
while a long-lived sibling can be; check the one that can.

## The rule

**A change that arms live behaviour is not done at the commit. Name the process
that must restart, and record that it did.**

Prefer a three-way verdict per holder — `current` / `PREDATES <sha>` /
`unknown` — and refuse to collapse an indeterminate reading into a verdict.

## The unfalsifiable-silence trap

The reason nobody caught the inert feature: **its success signal was "nothing
happened".** A healthy guard and an unwired one emit the identical
no-alert-no-state-file, so the prediction of silence was unfalsifiable and its
coming true read as confirmation.

**Any mechanism whose evidence of working is an absence needs a separate
liveness check, or it is indistinguishable from dead.**

## Siblings

- [[stale_binary_masquerades_as_a_new_bug]] — asks "is the artifact current?".
  This asks "did any process pick it up?" — and here the artifact was freshly
  built while every running process predated it.
- [[a_fix_cannot_protect_its_own_deploy]] — the transition itself is performed
  by the old code.

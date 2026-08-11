---
kind: lore
tags: [systemd, observation, evidence-quality, linux, process-hazard, recurring]
created: 2026-08-11
sources: [pivoker LORE/journald_is_not_an_evidence_store.md, pivoker LORE/liaison_has_systemd_user_journal_access.md, pivoker TOQU/1109, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# "Do the thing, then read the journal to confirm" fails in the shape of a passing observation

## The mechanism

You grep for the event you just caused, find nothing, and read it as *"it didn't
happen"* — when the truth is *"the record is gone"*.

Measured on one busy host: a **3m44s** retention window holding 1214 entries,
83% of them from a single container test run.

The root cause is a **byte budget, not a time window**. A vendor drop-in
(`/usr/lib/systemd/journald.conf.d/*.conf` — invisible if you read the
all-commented `/etc/systemd/journald.conf`) capped `SystemMaxUse=50M`, and eight
users' active files consumed it entirely, so there were **zero archives**: every
rotation was vacuumed instantly.

Three consequences follow:

- **the window shrinks exactly when you are busy** — i.e. when you are
  investigating;
- **investigating spends the budget** (your own tooling's output is in there);
- **you cannot predict it in advance.**

## The rule

1. **Run the tell BEFORE planning an observation:**

   ```sh
   journalctl --user --disk-usage
   journalctl --user -o short-iso | head -1     # the real oldest entry
   date -Is                                      # compare
   ```

2. **Prefer a durable artifact over a log line** — a file, a commit, a state
   record you can `git log -S` later.
3. **Otherwise capture FORWARD before triggering:**

   ```sh
   journalctl --user -f --since now > /tmp/capture.log &
   ```

   Reading backwards is not an option once the budget has rolled.
4. **Agents can read `journalctl --user` directly** — no escalation needed — so
   pull incident evidence **immediately**, not later. "I'll grab the logs after
   I finish this" is how the evidence is lost.

## The done-criterion corollary

*"After deploying, observe X in the journal"* is closable **only if X can be
triggered on demand.** If X is spontaneous, that is not an observation — it is a
vigil, and what you actually wanted was a test.

## Siblings

- [[probe_the_turn_not_its_side_effects]] — what to reach for when the log is
  gone but something else recorded the run.
- [[stale_binary_masquerades_as_a_new_bug]] — the weaker sibling: there the
  number is stale, here there is no number at all.

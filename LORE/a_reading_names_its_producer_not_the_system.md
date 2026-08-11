---
kind: lore
tags: [measurement, evidence-quality, deploy, diagnosis, pattern, recurring]
created: 2026-08-11
sources: [pivoker LORE/measurement_names_its_producer_not_the_realm.md, pivoker TADA/1355, pivoker TADA/1358, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A self-describing reading is about the process that produced it — the definite article promotes it to a claim nobody can check

## The mechanism

A version string, a health probe, a `uname`, a "what am I running" call: each is
accurate about **the process that produced it**. Rendering it with a definite
article —

> "**the** running build is X" · "**the** cluster is converged" · "all units
> picked up the deploy"

— silently promotes a per-process fact to a system-wide claim. **The grammar is
the bug, not the value.** The sentence is true either way whenever the system
happens to be converged, so it reads correct right up until someone asks
*because* something is wrong.

Recorded twice in one arc: a tool rendered one daemon's build as the whole
system's, and a human reported "all units converged" from a probe covering three
of four hosts, by hand.

**The tell is a multi-holder system whose members upgrade by different
mechanisms** — a self-restart watcher, a timer that re-execs, and one process
with neither. They are indistinguishable right up until a deploy, i.e. wrong
exactly when the question is being asked.

## The remedy is stamping, not re-sourcing

The filed premise ("it reads the wrong variable") was **false** — the figure
merely *equalled* the stale value because the producer was itself one deploy
behind. The fix is to make the reading name its producer:

- attach the producing role **and pid** to the reading, so the line is checkable
  by a third party (`/proc/<pid>/exe`);
- in prose, name the holder or go possessive: *"this process (pid N) is running
  X"*, *"the 4 hosts I probed all report X"*.

## The diligence tell, which generalises well beyond deploys

Reading a stale number funded a careful, correct-sounding analysis that was
entirely unnecessary. **An answer more elaborate than the situation warrants is
evidence about the input, not about the analysis.**

And the reason it hid for a month: the wrong input produced the *right*
conclusion. **A correct verdict is no evidence that its inputs were correct.**

## Siblings

- [[stale_binary_masquerades_as_a_new_bug]] — the reading is stale on axes the
  output does not show.
- [[committed_is_not_running]] — the config-side twin: the repo records intent,
  the process holds the behaviour.
- [[probe_the_turn_not_its_side_effects]] — wrong instrument, rather than right
  instrument over-claimed.

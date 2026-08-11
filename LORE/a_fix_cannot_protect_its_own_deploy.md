---
kind: lore
tags: [deploy, lifecycle-hazard, pattern, recurring]
created: 2026-08-11
sources: [pivoker LORE/a_fix_cannot_protect_its_own_deploy.md, pivoker TADA/1259, pivoker TADA/1296, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# A change to a teardown, restart or handoff path cannot protect its own deploy

## The mechanism

During the one transition that installs it, the behaviour is performed by **the
old process running the old code**. Your guard does not exist yet at the moment
it is most needed.

Two recorded instances:

- an inode-checked unlink would still have destroyed the seam during its own
  rollout, because the unlink that ran was the *previous* build's;
- an ordering mechanism could not sequence the very deploy that installed it.

## The question to ask

> During the deploy of **this** change, which process runs the behaviour I just
> fixed?

If the answer is "the old one", then:

1. **Write the transition order somewhere the deploy will read** — a runbook the
   deployer follows, a pre-flight step, a migration — not into the new code.
2. **Falsify your guards against the PRE-fix build**, not the post-fix one. A
   test that only exercises the new code proves nothing about the window.
3. **Never reconstruct deploy history from a coordination artifact.** A plan on
   disk says an ordering was *asked for*, not that anything could hear it.

## Siblings

- [[committed_is_not_running]] — the general form: intent lands in the repo,
  behaviour lives in a process.
- [[durable_state_ordering_write_the_trace_before_the_destructive_act]] — the
  same "the window is where it bites" reasoning, for crash rather than deploy.

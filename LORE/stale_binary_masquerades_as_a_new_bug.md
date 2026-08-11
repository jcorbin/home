---
kind: lore
tags: [deploy, diagnosis, evidence-quality, process-hazard, recurring]
created: 2026-08-11
sources: [pivoker LORE/stale_invoker_binary_masquerades_as_new_bug.md, pivoker LORE/invoke_cli_measures_the_deployed_build.md, pivoker LORE/baked_artifact_cache_split_brain.md, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# Before re-investigating a recurring bug, check whether the running binary contains the fix

## The mechanism

A deployed artifact — an installed binary, a dev symlink, a baked VM or
container image, a cached layer — goes stale silently. Every symptom it produces
is indistinguishable from a live bug, and the obvious response (re-investigate,
re-design) is expensive and wrong.

Recorded: a 473-commit-stale binary made an already-fixed dispatch bug look like
it needed a new design. On another day, **three** separate fixes were inert at
once, ~1600 lines behind.

**Any number a CLI prints is stale on axes its output does not show:**

1. **Build.** The binary predates the fix.
2. **Scope.** A reader that consults the integration branch by construction
   cannot see a fix still on your branch.
3. **Entrypoint.** Same inode, different `argv[0]`, different registered command
   set — so a check simply *does not run* and its row is absent. Axes 1–2 give a
   wrong number you might disbelieve; axis 3 gives an **absent row that reads as
   "nothing to report"**. "Same binary, so the entrypoint cannot matter" is a
   dismissal to distrust.

## The rule

- **With a suspect fix:** `git merge-base --is-ancestor <fix-commit>
  <deployed-sha>`.
- **With only a symptom:** take the whole inventory —
  `git diff --stat <deployed-sha>..HEAD -- '*.go'` — because more than one fix
  can be inert at once and a stuck component gives you nothing to point a
  targeted check at.
- **Resolve the build sha and the read scope *before* reading any number.**
  Deploy freshness is an **input to the measurement**, not a parallel box to
  tick afterwards.
- **To verify pre-land**, replicate the check against your own ref, *calibrate
  it by reproducing the known-good result first*, and measure the **merged**
  tree — not your branch tip, which is a third scope again.
- It runs the other way too: **docs ahead of the binary**. A convention citing a
  command the deployed build rejects turns every compliant user into a false
  "the tool is broken" report. Fix by deploying, not by a carve-out.

## The durable move

When a cheap, correct check keeps being skipped, **move it to the producer of
the notice it was meant to inform** rather than writing a louder instruction.
Once the deployed-vs-source delta was computed onto every stuck-work
notification, nobody had to remember it.

## Siblings

- [[committed_is_not_running]] — the artifact is current and *no process picked
  it up*. Distinct question, not implied by this one.
- [[a_reading_names_its_producer_not_the_system]] — a fresh, correct reading
  that still describes only one holder.

---
kind: lore
tags: [measurement, process-hazard, pattern, recurring]
created: 2026-08-11
sources: [pivoker LORE/measure_estimator_variance_before_designing_the_ab.md, pivoker TADA/1057, pivoker TADA/1071, distilled in session e9c14ce3-6b84-4667-935a-3816a12dd323]
---

# "Re-measure over the next ~30 units" is usually unfalsifiable — cohort the unchanged history first

## The mechanism

The natural way to check whether a change helped is to measure the next N units
of work and compare against the last N. That design is worthless until you know
what the estimator does **when nothing changes.**

Measured: four *contemporaneous* 30-unit cohorts of unchanged history read
**0.7%, 2.7%, 4.1% and 5.7%.** Six-fold noise, with nothing under test. At that
variance, seeing a genuine doubling would need roughly **181 units per arm** —
so the filed design could return a false null *and* a false positive, and the
corpus demonstrates both.

## The fix

**Pair within the unit that carries the variance.** Instead of comparing cohort
to cohort, compare two things *inside* one unit — ranks 1–5 against ranks 6–10
of the same selection, on the same work item. Holding the unit constant removes
the between-unit variance that was swamping everything.

That reframing produced **p=0.012 from data already on disk**, with no waiting
period at all.

Then:

- **stratify on whatever else differs between arms** (exposure, size, age), and
- **report the result as CONDITIONAL.** "These 5 beat those 5" is a statement
  about *ranking*. It never settles "is surfacing 5 worth it" — the level and
  the ordering are different questions, and only one of them was measured.

## The rule

**Before designing a before/after comparison, measure the estimator's variance
on unchanged history.** It costs one pass over data you already have, and it is
the difference between an experiment and a ritual.

## Siblings

- [[a_reading_names_its_producer_not_the_system]] — a correct number, an
  over-broad claim.
- [[probe_the_turn_not_its_side_effects]] — picking the instrument before
  worrying about its variance.

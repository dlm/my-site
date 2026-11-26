---
title: "Porting Go's Sort Tests Found Bugs in the C Original"
date: 2026-11-25
draft: true
---

**Draft outline: facts, numbers and story beats to turn into prose.** Post 5
of the blqsort series (the list is at the top of
`branchless-quicksort-in-go`).

## What I ported

- Ported the Go standard library's own sort tests (value-based, since
  blqsort moves values instead of swapping by index): Bentley-McIlroy
  matrix, McIlroy's "antiquicksort" adversary, inconsistent comparators,
  plus fuzzing and the race detector.

## What they found

- mine: the generated 2-element sorting network was empty (the C `sort2`
  macro is the primitive itself, not a network of `sort2` calls);
- inherited from the C version: no duplicate handling in small partitions
  (quadratic within a part when most values equal the pivot);
- inherited: only lopsided splits with a tiny *left* side were detected
  (upstream fixed this independently a few days later);
- inherited: pivot samples clustered at both ends and the middle, which
  picks extreme pivots on positionally structured input (50-94% of
  elements ended in the heapsort fallback);
- mine: a reversed-input shortcut that fired on an incomplete scan.

## Upstream context

- A Lean 4 model of blqsort.h (by someone else) had just found a partition
  bug (chkas/blqsort#4); the commit I ported already contained the fix.
- The McIlroy adversary stays bounded after the fixes (3.93 n lg n at
  1M-10M).

## Takeaways (candidates)

- The stdlib's tests were worth porting: they found three real issues in the
  C original.

---
title: "Your Comparator Has Branches"
date: 2026-11-25
draft: true
---

**Draft outline: facts, numbers and story beats to turn into prose.** Post 2
of the blqsort series (the list is at the top of
`branchless-quicksort-in-go`). Assumes the reader has seen post 1's
one-paragraph idea, or repeat it briefly. All numbers in this post come
from separate, earlier runs, not in `run-benchmarks.sh`: say so once in
the prose, or use post 1's `[^oneoff]` footnote on the first number.

## The surprise

- With a comparator (`slices.SortFunc` style), blqsort was **20% slower**
  than `slices.SortFunc`.

## The wrong explanation

- First explanation (register spills around the call, Go has no
  callee-saved registers) was mostly wrong. The per-comparison cost of the
  call was about the same for both sorts (~1.5-2 ns).

## The real reason

- `cmp.Compare` compiles to two data-dependent branches. pdqsort
  was already paying that misprediction in its own loop (the branches are
  correlated, so the predictor absorbs one), but for blqsort it was a brand-new
  cost. With a branch-free comparator blqsort was **1.8x faster** than
  `slices.SortFunc`.

## What it did to the API

- `SortByKey(xs, func(x T) K)` keeps the comparison inside
  the library, where it's branch-free; `SortLess` with a simple less works
  too. PGO devirtualizes the call for `SortLess` (60 -> 46 ms).

## Generating the comparison

- Code generation (a specialized sorter per type, `cmd/blqsortgen`) inlines
  the comparison: **3.5x** over `slices.SortFunc` on 8-byte records, 1.8x on
  64-byte ones, 1.4x on 56-byte records with an int and two string keys.
- Multi-key comparisons must be generated branch-free: `a || b && c`
  compiles to branches and lost to pdqsort until rewritten as
  `lt1 | eq1 & lt2` on 0/1 integers.

## Takeaways (candidates)

- In branchless code, every function you call has to be branchless too, or
  you get the mispredictions back.
- The obstacle in Go wasn't the language, it was the comparator API.

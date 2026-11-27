---
title: "Your Comparator Has Branches"
date: 2026-11-25
draft: true
---

**Draft outline: facts, numbers and story beats to turn into prose.** Post 2
of the blqsort series (the list is at the top of
`branchless-quicksort-in-go`). Assumes the reader has seen post 1's
one-paragraph idea, or repeat it briefly. Numbers are medians from
`records.txt` in `../branchless-quicksort-in-go/data/` (1M records, 8-byte
`rec{id, value int32}` unless noted), Intel / M1 Pro. The per-call cost and
the PGO numbers come from separate, earlier runs: use post 1's `[^oneoff]`
footnote on those.

## The surprise

- With a comparator (`slices.SortFunc` style, built from `cmp.Compare`),
  blqsort was **33% slower** than `slices.SortFunc` on Intel (122 vs 92 ms)
  and 14% slower on M1 (120 vs 105 ms). (The first, one-off measurement
  said 20%.)

## The wrong explanation

- First explanation (register spills around the call, Go has no
  callee-saved registers) was mostly wrong. The per-comparison cost of the
  call was about the same for both sorts (~1.5-2 ns)[^oneoff].

## The real reason

- `cmp.Compare` compiles to two data-dependent branches. pdqsort
  was already paying that misprediction in its own loop (the branches are
  correlated, so the predictor absorbs one), but for blqsort it was a brand-new
  cost. With a branch-free comparator blqsort was **1.7x faster** than
  `slices.SortFunc` on Intel (54 vs 91 ms) and 1.9x on M1 (55 vs 105 ms).
  The branch-free comparator doesn't help `slices.SortFunc` (92 / 101 ms),
  since pdqsort's own loop still branches.

## What it did to the API

- `SortByKey(xs, func(x T) K)` keeps the comparison inside
  the library, where it's branch-free; `SortLess` with a simple less works
  too (`SortByKey` 53 / 57 ms, `SortLess` 53 / 54 ms). PGO devirtualizes
  the call for `SortLess` (60 -> 46 ms)[^oneoff].

## Generating the comparison

- Code generation (a specialized sorter per type, `cmd/blqsortgen`) inlines
  the comparison: **3.2x** over `slices.SortFunc` on 8-byte records on
  Intel (29 vs 92 ms) and 4.4x on M1 (24 vs 105 ms); 2.1x / 1.7x on 64-byte
  records (`rec64`, an int64 key plus padding).
- But the gain shrinks as records grow, because blqsort copies every
  element more than pdqsort does. A specialized *pdqsort* (same generated
  comparison, Go's pdqsort) beats specialized blqsort from 32 bytes up:
  Intel 69 vs 74 ms at 32 bytes, 76 vs 103 ms at 64 bytes; M1 75 vs 82 and
  79 vs 140 ms. At 8 and 16 bytes blqsort wins easily (Intel 29 vs 59 and
  37 vs 61 ms). So blqsortgen is for small records.
- Multi-key comparisons must be generated branch-free: `a || b && c`
  compiles to branches and lost to pdqsort (two keys: blqsort 96 vs a
  specialized pdqsort's 68 ms on Intel, 99 vs 82 on M1) until rewritten as
  `lt1 | eq1 & lt2` on 0/1 integers (blqsort 39 / 33 ms; the same rewrite
  makes pdqsort slower, 78 / 84 ms).

## Takeaways (candidates)

- In branchless code, every function you call has to be branchless too, or
  you get the mispredictions back.
- The obstacle in Go wasn't the language, it was the comparator API.

[^oneoff]: This number comes from a one-off experiment I ran while working on
    the port, not from the benchmark suite in blqsort-experiments, so it
    isn't in the data published with the first post.

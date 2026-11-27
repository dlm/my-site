---
title: "Benchmarks That Remember"
date: 2026-11-25
draft: true
---

**Draft outline: facts, numbers and story beats to turn into prose.** Post 4
of the blqsort series (the list is at the top of
`branchless-quicksort-in-go`). Numbers are medians from the runs in
`../branchless-quicksort-in-go/data/` (`crossover.txt`, `threshold.txt`,
`stdlib.txt`); `[^oneoff]` marks separate, earlier runs not in
`run-benchmarks.sh` (same footnote as post 1).

## Possible opening

- On random data blqsort is about 2.5-3.6x faster than `slices.Sort` (int64
  1M: 2.59x Intel, 3.60x M1 Pro). On Go's own sort benchmarks it's roughly
  a wash or worse (SortInt1K 0.82x Intel / 1.00x M1; SortInt1K_Mod8 0.87x on
  both; full table in post 3). Which one is telling the truth? Post 3
  answers half (structure); this post answers the other half (repetition).

## The suspicion

- The careful runs first said blqsort is about *even* with `slices.Sort` at
  1K random ints (0.95x Intel, 1.08x M1), with the gain appearing somewhere
  before 100K. Suspicion: every small benchmark sorts the same input
  thousands of times, and branch predictors with long histories can learn
  it.

## Same vs fresh

- `BenchmarkCrossover` sorts batches of ~1M elements in total, each sort on
  either a copy of one random input ("same") or a different random input
  ("fresh"). Speedup of blqsort over `slices.Sort` (exact sizes):

| elements | Intel, same | Intel, fresh | M1 Pro, same | M1 Pro, fresh |
|---|---|---|---|---|
| 100 | 1.34x | **1.40x** | 1.00x | **2.80x** |
| 300 | 1.20x | **1.65x** | 1.13x | **3.09x** |
| 1,000 | 1.07x | **1.86x** | 1.12x | **3.28x** |
| 3,000 | 2.63x | **2.00x** | 2.45x | **3.42x** |
| 10,000 | 2.85x | **2.16x** | 3.62x | **3.50x** |
| 30,000 | 2.39x | **2.29x** | 3.59x | **3.55x** |
| 100,000 | 2.44x | **2.41x** | 3.65x | **3.61x** |

- On a repeated 1,000-element input, `slices.Sort` is 4.5x (Intel) / 3.6x
  (M1) faster than on fresh ones: that is the misprediction cost, memorized
  away. blqsort gains less (2.6x / 1.2x): it never branches on comparisons,
  but loop counts, recursion and network sizes depend on the data.
- With fresh inputs there is no crossover, just a ramp: blqsort wins from 100
  elements up. Memorization fades between ~3K and ~10K elements on both
  CPUs; above that both methods agree, so the large-size results stand.
- Odd stretch on Intel: at 3K-10K repetition helps blqsort *more* than
  `slices.Sort`, inflating the "same" column there.

## Ruling out the threshold

- Is blqsort's own switch at 1,025 elements (small path below, large
  partition above) part of the story? `BenchmarkThreshold` (fresh inputs,
  sizes clustered around it): going from 1,025 to 1,026 elements costs
  blqsort ~3% per element on Intel (1.573 -> 1.625 ns per n log2 n) and
  nothing on M1 (1.018 -> 1.019); the speedup ramps smoothly across it
  (Intel 1.73x at 500 -> 1.99x at 3,000; M1 3.22x -> 3.42x). The threshold
  is well placed and explains nothing.

## Other benchmarking lessons

- A hybrid CPU (performance + efficiency cores) gave up to 30% run-to-run
  noise until pinned to one core (`taskset`)[^oneoff].
- A laptop on battery ran every benchmark about 22% slower (ratios moved up
  to about 3%); `run-benchmarks.sh` now records the power state and refuses
  to run on battery.

## Takeaways (candidates)

- Microbenchmarks of small sorts (including Go's own `sort` benchmarks)
  measure a memorized input, which flatters branchy code.
- Benchmarks encode assumptions: Go's sort benchmarks would have shown no
  gain, because their inputs are structured and, at 1K, repeated (so the
  branch predictor memorizes them).

[^oneoff]: This number comes from a one-off experiment I ran while working on
    the port, not from the benchmark suite in blqsort-experiments, so it
    isn't in the data published with the first post.

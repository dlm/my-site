---
title: "Where Branchless Loses"
date: 2026-11-25
draft: true
---

**Draft outline: facts, numbers and story beats to turn into prose.** Post 3
of the blqsort series (the list is at the top of
`branchless-quicksort-in-go`). Numbers are medians from the runs in
`../branchless-quicksort-in-go/data/`; `[^oneoff]` marks separate, earlier
runs not in `run-benchmarks.sh` (same footnote as post 1).

## The main idea

- Branchless code costs the same whatever the data. Branchy code costs what
  the branch predictor lets it, which depends on how predictable the data
  is. blqsort is a bet that comparisons are unpredictable.

## The pattern matrix

- On the stdlib's pattern matrix (450 structured inputs), blqsort was slower
  than `slices.Sort` in about a third of the cases on Intel (160/450), worst
  0.15x. Yet the geometric mean over the matrix at n=100K is 1.23x on Intel
  and 1.49x on M1: averages hide the losses.
- Instrumenting the stdlib pdqsort showed why: on those inputs it does
  nearly its full workload, but each element visit costs **0.46-0.56 ns
  instead of 3.85 ns** on random data[^oneoff]. Regular structure makes its
  comparison branches predictable. Branchless code costs the same either
  way.

- At 1M elements, the structured rows of the library comparison (ms; the
  other rows are in post 1):

| input | | `slices.Sort` | blqsort | zermelo (radix) | sorty (1 goroutine) |
|---|---|---|---|---|---|
| `i % 8` | Intel | **2.01** | 2.14 | 4.56 | 6.85 |
| | M1 Pro | **2.93** | 3.08 | 3.67 | 10.0 |
| `i ^ 0xcccc` | Intel | 20.3 | 21.2 | 14.0 | **13.2** |
| | M1 Pro | 24.3 | 17.2 | **12.4** | 18.0 |

## Go's own sort benchmarks

- Go's own sort benchmarks use structured inputs (`i ^ 0x2cc`, `i % 8`) and
  small sizes, and there blqsort is roughly a wash (speedup vs
  `slices.Sort`, careful runs):

| Go stdlib benchmark | input | Intel | M1 Pro |
|---|---|---|---|
| SortInt1K | `i ^ 0x2cc`, 1K | 0.82x | 1.00x |
| SortInt64K | `i ^ 0xcccc`, 64K | 1.00x | 1.56x |
| SortInt1K_Mod8 | `i % 8`, 1K | 0.87x | 0.87x |
| SortInt1K_Sorted | 1K | 1.38x | 1.85x |
| SortInt1K_Reversed | 1K | 1.01x | 1.21x |
| SortString1K | strings, 1K | 0.88x | 1.10x |

- Two caveats on the 1K rows: they shift with the build, and every
  iteration sorts the *same* input, which the branch predictor learns
  (-> post 4). Within a run, the 10 repetitions agree to a few percent.
  Build examples: in an earlier run with everything in one package, Intel
  SortInt1K was 1.08x; and Intel SortInt1K_Reversed was 1.11x in a run at an
  earlier commit with identical library code (only the experiments
  differed), 1.01x here.

## Things that didn't help

- Shuffling the input first (the textbook randomization answer): blqsort
  was never more than 1% slower than its own random-data speed[^oneoff], so there
  was no bad luck to remove; shuffling only destroys structure pdqsort
  exploits.
- Upstream's newer ideas (Lomuto switch on non-random data, order-preserving
  swap buffer, insertion sort for nearly sorted parts): no gain in Go, cost
  4% on random and 18% on few-unique data[^oneoff]. (Upstream's unbounded insertion
  sort also looks quadratic on two large sorted blocks; read, not run.)
- Branchless pdqsort (Orson Peters' BlockQuicksort-style partition in Go's
  pdqsort): about half of blqsort's gain on random data (int64 1M: 1.61x
  Intel, 2.13x M1, vs blqsort 2.59x / 3.60x), and *worse* on structured data
  (SortInt1K_Mod8 0.45x on Intel), because the adaptivity that matters is branch
  prediction, which any branchless partition gives up.

## And on arm64?

- The C original goes branchy on arm64 because branchless was slower on
  Apple M1 in C. In Go, branchless has the *larger* lead on an M1 Pro, and
  wins most of the stdlib benchmarks above there.
- Open: a branchy blqsort in Go on M1 was never tried (DAV-100), so whether
  the C author's observation holds in Go is unknown.

## Takeaways (candidates)

- Branch prediction is the adaptivity that matters; a branchless sort gives
  it up on purpose, and wins exactly when there's nothing to predict.

[^oneoff]: This number comes from a one-off experiment I ran while working on
    the port, not from the benchmark suite in blqsort-experiments, so it
    isn't in the data published with the first post.

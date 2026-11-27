Raw benchmark output for this post
==================================

One directory per machine, produced by run-benchmarks.sh from
github.com/dlm/blqsort-experiments at commit feb312b4aaad:

  https://github.com/dlm/blqsort-experiments/tree/feb312b4aaadc239fea13e95a01c6a58dac0918c

Both runs measure blqsort v0.1.1.

  zbornak-x86_64/   Intel Core Ultra X7 358H, Linux, go1.26.10, pinned to a
                    performance core (taskset -c 3), on AC power
  tanner-arm64/     Apple M1 Pro, macOS, go1.26.10 (same Nix flake dev
                    environment), not pinned (macOS can't pin to a core),
                    on AC power, low power mode off

Each directory has:

  env.txt        date, CPU, OS, Go version, blqsort version, experiments
                 commit, pinning, power state, and the exact commands
  stdlib.txt     Go's own sort benchmarks (BenchmarkGoStdlib): 10 runs of
                 2000 iterations each, ns/op
  bench.txt      libraries, input shapes, branchless pdqsort: 5 runs of 1s
                 each, ns/op
  records.txt    1M records sorted by a key: the comparator API, branch-free
                 comparators, and specialized (generated) sorters for 8- to
                 64-byte records (BenchmarkAPI, BenchmarkBranchlessCmp,
                 BenchmarkSpecialized): 5 runs of 1s each, ns/op
  crossover.txt  fresh vs repeated inputs, 100 to 100K elements
                 (BenchmarkCrossover)
  threshold.txt  fresh inputs around blqsort's small-path switch at 1025
                 elements (BenchmarkThreshold)
  patterns.txt   the Bentley-McIlroy pattern tables; each case is the
                 minimum of 7 timings

crossover.txt and threshold.txt use ns/sort: each benchmark op sorts a
batch of about 1M elements in total, so use the ns/sort column, not ns/op.
Both have 5 runs of 1s each. Use medians, for example with benchstat.

To rerun: clone github.com/dlm/blqsort-experiments, check out feb312b4aaad
(or main, for the latest version), and run ./run-benchmarks.sh from its
root (with Nix: nix develop --command ./run-benchmarks.sh). Plug the
machine in first; the script refuses to run on battery. It takes roughly
half an hour.

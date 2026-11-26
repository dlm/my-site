Raw benchmark output for this post
==================================

One directory per machine, produced by ../run-benchmarks.sh (a copy of
experiments/run-benchmarks.sh from github.com/dlm/blqsort). Both runs are
at blqsort commit 5f28a5c74eb7.

  zbornak-x86_64/   Intel Core Ultra X7 358H, Linux, go1.26.10, pinned to a
                    performance core (taskset -c 3)
  tanner-arm64/     Apple M1 Pro, macOS, go1.26.10 (same Nix flake dev
                    environment), not pinned (macOS can't pin to a core)

Each directory has:

  env.txt        date, CPU, OS, Go version, blqsort commit, pinning, and
                 the exact commands
  stdlib.txt     Go's own sort benchmarks (BenchmarkGoStdlib): 10 runs of
                 2000 iterations each, ns/op
  bench.txt      libraries, input shapes, branchless pdqsort: 5 runs of 1s
                 each, ns/op
  crossover.txt  fresh vs repeated inputs, 100 to 100K elements
                 (BenchmarkCrossover)
  threshold.txt  fresh inputs around blqsort's small-path switch at 1025
                 elements (BenchmarkThreshold)
  patterns.txt   the Bentley-McIlroy pattern tables; each case is the
                 minimum of 7 timings

crossover.txt and threshold.txt use ns/sort: each benchmark op sorts a
batch of about 1M elements in total, so use the ns/sort column, not ns/op.
Both have 5 runs of 1s each. Use medians, for example with benchstat.

To rerun: clone github.com/dlm/blqsort, then from its experiments/ directory
run ./run-benchmarks.sh. It takes roughly half an hour.

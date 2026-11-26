#!/usr/bin/env bash
# Runs the careful blqsort benchmark suite and records the results and the
# environment they came from.
#
# Usage: run-benchmarks.sh [BLQSORT_REPO] [OUT_DIR]
#
#   BLQSORT_REPO  checkout of github.com/dlm/blqsort (default: the repository
#                 this script is in)
#   OUT_DIR       where to write results (default: ./results/<host>-<arch>)
#
# Benchmarks run single-threaded (GOMAXPROCS=1). On Linux they are pinned to
# one core with taskset: a performance core on hybrid Intel CPUs (not core 0), or
# $PIN_CPU if set. macOS cannot pin threads to cores; that is recorded.
# Takes 30-40 minutes. ONLY=crossover or ONLY=threshold runs just that
# benchmark (a few minutes).
#
# Works with the bash 3.2 that macOS ships.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "${1:-$here/..}" && pwd)
host=$(hostname -s)
arch=$(uname -m)
out=${2:-"$PWD/results/$host-$arch"}
mkdir -p "$out"
out=$(cd "$out" && pwd)

pin=()
pinned="no (macOS cannot pin threads to cores)"
if [ "$(uname -s)" = Linux ]; then
	pinned="no (taskset not found)"
	if command -v taskset >/dev/null 2>&1; then
		cpu=${PIN_CPU:-}
		if [ -z "$cpu" ] && [ -r /sys/devices/cpu_core/cpus ]; then
			# Hybrid Intel: performance cores are listed here, e.g. "0-3".
			# Take the last of the first range: core 0 gets more interrupts.
			cpu=$(cut -d, -f1 /sys/devices/cpu_core/cpus | awk -F- '{print $NF}')
		fi
		cpu=${cpu:-0}
		pin=(taskset -c "$cpu")
		pinned="yes, taskset -c $cpu"
	fi
fi

cpu_name() {
	if [ "$(uname -s)" = Darwin ]; then
		sysctl -n machdep.cpu.brand_string
	else
		grep -m1 'model name' /proc/cpuinfo | sed 's/.*: //'
	fi
}

run() { # run OUTFILE ARGS...: run the test binary, tee output to OUTFILE
	local f=$1
	shift
	echo "+ GOMAXPROCS=1 ${pin[*]+${pin[*]}} exp.test $*" | tee -a "$out/env.txt"
	GOMAXPROCS=1 ${pin[@]+"${pin[@]}"} "$out/exp.test" "$@" | tee "$out/$f"
}

{
	echo "date:    $(date -u +%Y-%m-%dT%H:%M:%SZ)"
	echo "host:    $host"
	echo "os:      $(uname -srm)"
	echo "cpu:     $(cpu_name)"
	echo "go:      $(go version)"
	echo "blqsort: $(git -C "$repo" describe --always --dirty --abbrev=12)"
	echo "pinned:  $pinned"
	echo
	echo "commands:"
} >"$out/env.txt"
cat "$out/env.txt"

cd "$repo/experiments"
echo "== correctness tests"
go test -count=1 .
go test -c -o "$out/exp.test" .

case "${ONLY:-}" in
crossover | threshold)
	name=$(echo "$ONLY" | awk '{print toupper(substr($0, 1, 1)) substr($0, 2)}')
	echo "== $ONLY only"
	run "$ONLY.txt" -test.run '^$' -test.bench "^Benchmark$name\$" -test.benchtime=1s -test.count=5
	rm -f "$out/exp.test"
	echo "done: $out"
	exit 0
	;;
"") ;;
*)
	echo "ONLY must be crossover or threshold" >&2
	exit 2
	;;
esac

echo "== stdlib benchmark equivalents (1K-64K elements: many iterations)"
run stdlib.txt -test.run '^$' -test.bench '^BenchmarkGoStdlib$' -test.benchtime=2000x -test.count=10

echo "== libraries, input shapes, branchless pdqsort"
run bench.txt -test.run '^$' -test.bench '^(BenchmarkLibraries|BenchmarkLibraryShapes|BenchmarkContenders)$' \
	-test.benchtime=1s -test.count=5

echo "== crossover: fresh vs repeated inputs, 100 to 100K elements"
run crossover.txt -test.run '^$' -test.bench '^BenchmarkCrossover$' -test.benchtime=1s -test.count=5

echo "== threshold: fresh inputs around blqsort's small-path switch"
run threshold.txt -test.run '^$' -test.bench '^BenchmarkThreshold$' -test.benchtime=1s -test.count=5

echo "== pattern tables"
export BLQ_PATTERNS=1 # enables the long-running pattern tables
run patterns.txt -test.run '^(TestPatternTimes|TestPatternContenders)$' -test.v

rm -f "$out/exp.test"
echo "done: $out"

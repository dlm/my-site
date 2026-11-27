#!/usr/bin/env bash
# Runs the careful blqsort benchmark suite and records the results and the
# environment they came from.
#
# Usage: run-benchmarks.sh [OUT_DIR]
#
#   OUT_DIR  where to write results (default: ./results/<host>-<arch>)
#
# The blqsort version measured is the one go.mod requires; env.txt records
# it next to the commit of this repository.
#
# Benchmarks run single-threaded (GOMAXPROCS=1). On Linux they are pinned to
# one core with taskset: a performance core on hybrid Intel CPUs (not core
# 0), or $BLQ_PIN_CPU if set. macOS cannot pin threads to cores; that is
# recorded. Takes roughly half an hour. BLQ_ONLY=crossover or
# BLQ_ONLY=threshold runs just that benchmark (a few minutes).
#
# Laptops slow down on battery (about 20% on the Intel machine used for the
# blog post), so the script refuses to run on battery unless
# BLQ_ALLOW_BATTERY=1. env.txt records the power state and, on Linux, the
# CPU frequency settings.
#
# All environment variables this script and the tests read start with BLQ_.
#
# Works with the bash 3.2 that macOS ships.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
host=$(hostname -s)
arch=$(uname -m)
out=${1:-"$PWD/results/$host-$arch"}
mkdir -p "$out"
out=$(cd "$out" && pwd)

pin=()
pinned="no (macOS cannot pin threads to cores)"
if [ "$(uname -s)" = Linux ]; then
	pinned="no (taskset not found)"
	if command -v taskset >/dev/null 2>&1; then
		cpu=${BLQ_PIN_CPU:-}
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

# power_state prints the power source and CPU power settings, one line.
power_state() {
	if [ "$(uname -s)" = Darwin ]; then
		local src lpm
		src=$(pmset -g batt | head -1 | sed -n "s/.*'\(.*\)'.*/\1/p")
		lpm=$(pmset -g | awk '/lowpowermode/ {print $2}')
		echo "${src:-unknown}, low power mode ${lpm:-unknown}"
		return
	fi
	local src=unknown f c=${cpu:-0}
	for f in /sys/class/power_supply/*; do
		[ "$(cat "$f/type" 2>/dev/null)" = Mains ] || continue
		if [ "$(cat "$f/online" 2>/dev/null)" = 1 ]; then src="AC Power"; else src="Battery Power"; fi
		break
	done
	f=/sys/devices/system/cpu/cpu$c/cpufreq
	echo "$src, governor $(cat $f/scaling_governor 2>/dev/null || echo unknown)," \
		"epp $(cat $f/energy_performance_preference 2>/dev/null || echo unknown)," \
		"platform profile $(cat /sys/firmware/acpi/platform_profile 2>/dev/null || echo unknown)"
}

power=$(power_state)
case "$power" in
"Battery Power"*)
	if [ "${BLQ_ALLOW_BATTERY:-}" != 1 ]; then
		echo "on battery ($power): plug in, or set BLQ_ALLOW_BATTERY=1" >&2
		exit 1
	fi
	;;
esac

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
	echo "blqsort: $(cd "$here" && go list -m -f '{{.Version}}{{with .Replace}} (replaced by {{.Path}}){{end}}' github.com/dlm/blqsort)"
	echo "experiments: $(git -C "$here" describe --always --dirty --abbrev=12)"
	echo "pinned:  $pinned"
	echo "power:   $power"
	echo
	echo "commands:"
} >"$out/env.txt"
cat "$out/env.txt"

cd "$here"
echo "== correctness tests"
go test -count=1 .
go test -c -o "$out/exp.test" .

case "${BLQ_ONLY:-}" in
crossover | threshold)
	name=$(echo "$BLQ_ONLY" | awk '{print toupper(substr($0, 1, 1)) substr($0, 2)}')
	echo "== $BLQ_ONLY only"
	run "$BLQ_ONLY.txt" -test.run '^$' -test.bench "^Benchmark$name\$" -test.benchtime=1s -test.count=5
	rm -f "$out/exp.test"
	echo "done: $out"
	exit 0
	;;
"") ;;
*)
	echo "BLQ_ONLY must be crossover or threshold" >&2
	exit 2
	;;
esac

echo "== stdlib benchmark equivalents (1K-64K elements: many iterations)"
run stdlib.txt -test.run '^$' -test.bench '^BenchmarkGoStdlib$' -test.benchtime=2000x -test.count=10

echo "== libraries, input shapes, branchless pdqsort"
run bench.txt -test.run '^$' -test.bench '^(BenchmarkLibraries|BenchmarkLibraryShapes|BenchmarkContenders)$' \
	-test.benchtime=1s -test.count=5

echo "== records: comparator API, branch-free comparators, specialized sorters (1M records)"
run records.txt -test.run '^$' -test.bench '^(BenchmarkAPI|BenchmarkBranchlessCmp|BenchmarkSpecialized)$' \
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

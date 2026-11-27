---
title: "Branchless Quicksort in Go"
date: 2026-11-20
draft: true
---

Welcome to my series of posts on branchless quicksort in Go. In the middle of
November 2026, I came across Christof Kaser's [blqsort](https://tiki.li/blog/blqsort), a
sorting algorithm written in C. He reports that it beats C++'s `std::sort` by
avoiding branch mispredictions and using sorting networks. I was kind of
wondering, does that carry over to Go, or do Go's differences (bounds checks,
no templates, register ABI) kill it? The short version is that it works pretty
well even without `unsafe`. Indeed, for large random inputs it is 2.4-3.7x
faster than Go's `slices.Sort` and the lead is biggest on an Apple M1 Pro, the
one place where Kaser's own C version gives up on branchless code.

## Kaser's idea

Kaser's interesting idea is a quicksort whose partition loop, where nearly
all of the work happens, never branches on the comparison with the pivot. He
calls it BranchLess Quicksort (blqsort). Here I give a high-level overview of
the algorithm, but for the full treatment, see
[blqsort](https://tiki.li/blog/blqsort).

The blqsort algorithm has two major ideas. First, recall that quicksort
compares every element with a pivot. On random data, with a pivot near the
median, that comparison is close to a coin flip, so a partition loop that
branches on it mispredicts a lot. In blqsort, each element is written to
*both* possible destinations (left side or a swap buffer) and the result of
the comparison only advances one of the two write indices. That means that
blqsort does more copying, but its partition loop has no comparison branch to
mispredict.

Second, once the recursion gets down to small enough parts (up to 18 elements
in the version I ported), blqsort finishes them with a branch-free "sorting
network". I had not heard of sorting networks before studying Kaser's work,
but basically, a sorting network sorts a fixed-size array by comparing and
swapping the same pairs in the same order, whatever the data.

## The port

So, Kaser gets some impressive results in C, and I was curious whether Go's
safety checks (like bounds checking) or the way it compiles generics would
erase those gains. Working with Claude Code, I started with a direct port of
the C implementation, then made it into a Go library, with its own API, a code
generator, and a few fixes the tests turned up. You can find it on my
[GitHub](https://github.com/dlm/blqsort). Like the original, it's MIT
licensed, with Kaser's copyright kept next to mine, and its sorting networks
are generated straight from his C header.

When I compiled it with bounds checks turned off (`-gcflags=-B`), sorting 50M
random int64s or float64s got 8-12% faster on the Intel machine.[^oneoff]
But, I did NOT use `unsafe`: it wasn't worth giving up memory safety for 10%.
I did play with removing the provable bounds checks with safe idioms
(fixed-size array chunks, masked indices). It bought nothing: the expensive
checks are on the data-dependent write indices, and I couldn't get the
compiler to eliminate those.

## How fast

To understand the performance of blqsort v0.1.1, I compared it with Go's
built-in `slices.Sort` on random data. I used two systems:

- a Linux laptop with an Intel Core Ultra X7 358H (amd64), with the
  benchmarks pinned to one performance core, and
- a MacBook Pro with an Apple M1 Pro (arm64), which can't pin to a core
  (macOS doesn't allow it).

Both ran Go 1.26.10, single-threaded (`GOMAXPROCS=1`) and plugged in. Each
number is the median of 5 runs, and the raw benchmark output is published
with this post (see [data/README.txt](data/README.txt)).

For the small sizes (100 to 10,000 elements), each timed batch sorts many
*different* random inputs, while for 100K elements and up, each timed sort gets
a copy of the same random input, restored outside the timed region. It turns
out that on small inputs, sorting the same input over and over lets the
CPU's branch predictor memorize it, which makes branchy sorts like
`slices.Sort` look better than they really are. So, if you
benchmark small sorts yourself, use a fresh input each time (more on that in an
upcoming post).

The table shows the speedup: `slices.Sort`'s time divided by blqsort's, so 2x
means blqsort takes half as long.

| random data, speedup vs `slices.Sort` | Intel (amd64) | M1 Pro (arm64) |
|---|---|---|
| int64, 100 / 1,000 / 10,000 | 1.40x / 1.86x / 2.16x | 2.80x / 3.28x / 3.50x |
| int64, 100K / 1M / 10M | 2.41x / 2.59x / 2.60x | 3.60x / 3.60x / 3.67x |
| float64, 100K / 1M / 10M | 2.68x / 2.86x / 2.87x | 2.78x / 2.98x / 3.13x |

The quick takeaway here is that blqsort is about 2.4-2.9x faster on Intel and
2.8-3.7x faster on M1 from 100K elements up, and ahead at every tested size,
including 100 elements.

The arm64 results were a surprise. On arm64, the C original switches to
branchy code, because branchless was slower on Apple M1. So I expected the Go
version to do worse there too. Instead, its lead over `slices.Sort` was
larger on the M1 Pro. At 1M int64s,
blqsort is 3.6x faster than `slices.Sort` on the M1, compared to 2.6x on
Intel. I haven't tried a branchy Go version yet, so I can't say whether
Kaser's observation holds in Go.

## How it compares to other Go sorting libraries

I also compared blqsort with two other sorting libraries for Go:

- [zermelo](https://github.com/shawnsmithdev/zermelo), a radix sort for
  integers and floats. It doesn't compare elements at all, and it needs a
  scratch buffer as big as the input. I gave it one up front; otherwise, it
  allocates one on every call.
- [sorty](https://github.com/jfcg/sorty), a concurrent sort. Since everything
  else here is single-threaded, I limited it to one goroutine, which is not
  what it was designed for.

Here is how long each one takes to sort 1M int64s, in milliseconds (lower is
better):

| input | | `slices.Sort` | blqsort | zermelo (radix) | sorty (1 goroutine) |
|---|---|---|---|---|---|
| random | Intel | 56.9 | 22.0 | 22.8 | 49.1 |
| | M1 Pro | 64.2 | 17.6 | **11.6** | 56.4 |
| 10 distinct values | Intel | 9.87 | **3.61** | 4.70 | 13.8 |
| | M1 Pro | 11.3 | 4.86 | **3.82** | 17.2 |
| sorted | Intel | 0.37 | **0.29** | 0.84 | 3.69 |
| | M1 Pro | 0.63 | **0.32** | 0.71 | 7.15 |
| reversed | Intel | 0.63 | **0.59** | 14.9 | 3.92 |
| | M1 Pro | 0.91 | **0.75** | 12.6 | 7.31 |

On random int64s, zermelo ties blqsort on Intel and beats it on the M1, and
on random float64s it beats blqsort on both machines. But on reversed input it
takes 12.6-14.9 ms, where blqsort and `slices.Sort` take under a millisecond.

So, if you only sort integers or floats, your data is random, and you can
spare a buffer, zermelo is worth a look, especially on Apple silicon.
Otherwise, blqsort is the fastest general option I found for random data.
But, if your data has a lot of structure, `slices.Sort`
is the safer default (see "When not to use it" below).

## Using it

So, it is easy to give it a try. Just run:

```bash
go get github.com/dlm/blqsort@v0.1.1
```

And you can call it on a slice of numbers or strings, or on a slice of
structs like this `Person`:

```go
type Name struct {
	First, Last string
}

type Person struct {
	ID    int64
	Name  Name
	Age   int
	Score float64
}

blqsort.Sort(ages) // any cmp.Ordered slice ([]int, []float64, []string, ...), like slices.Sort
blqsort.SortByKey(people, func(p Person) int64 { return p.ID })
blqsort.SortLess(people, func(a, b Person) bool { return a.ID < b.ID })
blqsort.SortFunc(people, cmpFn) // like slices.SortFunc; only fast with a branch-free cmpFn
```

A few things to note. First, like `slices.Sort`, blqsort doesn't allocate and
isn't stable: tied elements don't necessarily keep their order. `Sort` orders
NaNs first, like `slices.Sort`, and `SortByKey` orders elements whose key is
NaN first. Second, when you sort by your own comparison, I suggest `SortByKey`
(or `SortLess`) instead of `SortFunc`, which mirrors `slices.SortFunc`. A
comparator built from `cmp.Compare` branches on the data, which brings back
the mispredictions blqsort avoids (more on that in an upcoming post).

Third, for structs, you can use `cmd/blqsortgen` to generate a sorter for
your own type and keys. After adding it to your module with `go get -tool
github.com/dlm/blqsort/cmd/blqsortgen@v0.1.1`, a line like

```go
//go:generate go run github.com/dlm/blqsort/cmd/blqsortgen -type Person -by=-Age,Name.Last
```

generates `sortPersonByAgeDescLast(people)`, which sorts by `Age` descending
(that's the leading `-`) and then by `Name.Last`. The generated file doesn't
import blqsort. On 1M records with random keys, a generated sorter was about
3.2x faster than `slices.SortFunc` with `cmp.Compare` for 8-byte records (an
int32 key) and 2.1x faster for 64-byte records (an int64 key plus padding), on
the Intel machine (4.4x and 1.7x on the M1). The
[example package](https://github.com/dlm/blqsort/tree/main/cmd/blqsortgen/example)
in the repo has the full setup.

## When not to use it

So, blqsort is not a silver bullet. If your data has a regular structure
(periodic, interleaved or partly sorted), the CPU's branch predictor learns the
pattern and the branchy partitioning in `slices.Sort` becomes cheap, so
`slices.Sort` can win, sometimes by a lot. To check this, I used the 450
structured inputs from the classic Bentley-McIlroy sort tests, timing each one
7 times and keeping the fastest (instead of the median of 5 runs used above).
On Intel, across sizes from 100 to 100,000 elements, `slices.Sort` was more
than 5% faster in 160 of the 450 cases. For
example, take 100,000 values made of two interleaved ascending runs, reversed
(a "stagger" input): `slices.Sort` takes 0.27 ms and blqsort takes 1.8 ms (I
dig into why in an upcoming post). blqsort does hand inputs that are made of a few long runs to
`slices.Sort`, but it doesn't catch every structured input.

## Is it correct?

I wanted to make sure it was actually correct, so I spent some time on
testing. blqsort is tested against `slices.Sort` on many
distributions and sizes. I ported the Go standard library's own sort
tests, checked the sorting networks exhaustively, and ran fuzzing and the race
detector. It turned out to be worth it: the tests found three problems that
were inherited from the C original. That's a story for an upcoming post.

## Wrapping up

So, perhaps unsurprisingly, Kaser's idea carries over to Go.
In the rest of the series, I dig into the parts that did surprise me:

1. why your comparator has branches, and what that did to the API,
2. where branchless loses,
3. benchmarks that remember their inputs, and
4. how porting Go's sort tests found bugs in the C original.

If you want to give it a try, the library is at
[github.com/dlm/blqsort](https://github.com/dlm/blqsort), and the experiments
behind the numbers in this post are at
[github.com/dlm/blqsort-experiments](https://github.com/dlm/blqsort-experiments).

[^oneoff]: This number comes from a one-off experiment I ran while working on
    the port, not from the benchmark suite in blqsort-experiments, so it
    isn't in the data published with this post.

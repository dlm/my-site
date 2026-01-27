---
title: "Stop Being a Crab and Try Something Nu"
date: 2026-01-15
---

I have been doing Computer Science for a while now.  Specifically, my first
programming experience was with turtle graphics back in the 80s.  While fun, it
didn't really stick until I got to high school in the mid 90s, where we used
C++.  I taught myself Java and it was fine, but as I got further along in
research, I found that most of the major code bases in computational geometry,
computational topology, and numerical analysis are written in C or C++ and so
focus on those languages seemed like a good idea.

Since I finished my PhD, I have hopped back and forth between academia and
industry. For research I would use C++, Python, Fortran, and R. For industry: at
ProductionPro we used Python and Node; at Nowsta, we used Ruby and Javascript;
and at Blocky, we used Go.  During each of those time periods, I had limited
time for personal projects. When I did have a weekend to work on something, I
would default to languages that I knew well instead of using a new language.

But, this year, I decided to take some time and so I figured, why not spend
some cycles on projects that have been rolling around in my head for a while.
And, if I have the time, why not take advantage of it and use a new language?

But does it matter?  If I asked my more theory-minded colleagues from academia,
they would say that language choice is not important.  After all, all programs
ultimately produce instructions for a CPU.  But from going back and forth
between academia and industry, I don't agree.  I think like a human language, a
programming language can have a significant impact on how one thinks about
problem solving.

Interestingly, back in 2001, the ACM published [curriculum
recommendations](https://www.acm.org/binaries/content/assets/education/curricula-recommendations/cc2001.pdf)
that discussed using various methodologies for teaching computer science.
Moreover, significant work has gone into studying learning outcomes with
[functional-first](https://www2.ccs.neu.edu/racket/pubs/cse2003-fffk.pdf),
[imperative-first](https://cs.stanford.edu/people/eroberts/papers/SIGCSE-1993/UsingCInCS1.pdf)
and [object-first](https://dl.acm.org/doi/pdf/10.1145/611892.611966)
approaches. Including some [comparisons between
methodologies](https://dl.acm.org/doi/abs/10.5555/364132.364177). But there is
little work on how these languages affect problem solving and design on larger
scales with intermediate and advanced developers. So it seems that language
does matter (at least when getting started).  But, what to choose?  For the
first time in a long time, I get to choose based purely on my interests.
Previously, I had to consider the learning curve for my students or the team I
was leading. But this time, why not choose languages purely because I want to?

Well, I have always really liked functional programming. In college, back in the
early 00s, I learned SML and Haskell and in graduate school, I did some work
with Scheme. I really enjoyed these languages.  Perhaps it is because my CS
background is a little more on the mathematical side of computer science.  But
I really like how functional languages encourage me to think about invariants
and interfaces. But, I think the downside of some of these languages is that
they are pretty niche.  If I am going to invest some time in a new language, it
would be nice if there was enough of a community around it to make it worth the
time investment. (Yes, I get it, choosing a language based on practicality is
at odds with some of my previous statements, but I am still a practical
person---baby steps.)

Rust seems like it could be good option.  It is heavily influenced by
functional programming and is being used in all sorts of places. Obviously, the
Linux kernel but also all the AWS Nitro tooling that I worked with at Blocky.
But, Rust isn't the newest thing, so, you may ask, "Dave, if you haven't used
it yet, why now?" Good question.  In fact, Rust has been on my radar for a
while. The first time I heard about it was around 2014 when I met one of the
team members at a meetup back when I lived in NYC. Unfortunately, I do not
remember who that was but I do remember being fascinated by their job. You see,
until that point, the only person I knew that worked on Programming Languages
was [Edmond Schonberg](https://dblp.org/pid/75/4871.html) and so I thought that
PL work was restricted to Academia.

Since then, I have poked around with Rust.  But, it never stuck.  I think one
major reason for that was because I don't think Rust is very good for small
simple projects.  When compared to interpreted languages like Python and Ruby
or the spectacular compilation speed of Go, iterating in Rust felt slow. So,
if I do want to stick with the theme of new languages, I would need to figure
out something for simple and small projects (on the order of a few hundred
lines). But, I happen to be in luck.

Last year, I started using NuShell. I switched to it because when I was
cleaning up my nix configuration, I was shocked to see how many tools I needed
that were not part of core-utils, just to do "standard" cli stuff. As a shell,
I really like Nu and from what I have seen in the Ghostty project, it seems
like there is a lot of power in the scripting language itself, so perhaps that
could be a good place for small projects?  Seems worth a try.

So, there you have it.  I'll focus on Rust for "medium" sized projects and Nu
for prototypes and small projects. Seems like a nice combo to try.  So adios to
Bash and Go... at least for now. I suspect that I will have some "thoughts" as
I get further down this rabbit hole. But here is to jumping in the deep end!

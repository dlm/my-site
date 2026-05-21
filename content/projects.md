---
title: "Projects"
---

## Industry

### Blocky

[Blocky](https://blocky.rocks) is a data and computation integrity platform I
co-founded and serve as CTO. The core problem: how do you trust data when you
can't trust the systems that produced it? Blocky answers that by building
cryptographic provenance into the data pipeline itself, so consumers can verify
what they interact with rather than relying on assumptions about their
environment.

I co-designed all protocols and intellectual property, and architected and led
development of all systems. This work was supported by two NSF SBIR grants
totaling $1.2M: a Phase I award for a microservices approach to low-latency
process interaction through distributed ledgers, and a Phase II award for a
provable data lineage system for the data sharing economy.

### ProductionPro

[ProductionPro](https://www.production.pro) is a collaboration platform for
film, theatre, and television. I was the first technical hire and grew the
engineering team from zero to six engineers. I led design and implementation
from paper prototype to initial release, including the backend architecture on
AWS and Firebase, internal and external APIs and data models in Django,
authentication and security systems, real-time collaboration infrastructure,
and a natural language processing system for script interpretation.

### Nowsta

[Nowsta](https://www.nowsta.com) is a payments and logistics platform providing
next-day payment processing for hourly workers. As Engineering Team Lead and
later Technical Advisor, I led development of the payments platform and worker
recommendation engine, redesigned the messaging system, and architected the
CI/CD pipeline.

### MC21 — Monte Carlo Particle Transport

At Bettis Atomic Power Laboratory, I was a member of the MC21 core team, a
continuous energy Monte Carlo particle transport simulation code used in
nuclear reactor design. I led development of the geometric kernel: designing
and implementing algorithms, reviewing contributed code, planning future
development, and reporting to funding sources. This followed multiple
internships at Bettis Atomic Power Laboratory where I developed algorithms for
volume computation and point-in/point-out predicates for complex CSG
geometries. This work reduced lost particles in physical simulations even for
extremely complex model geometries.

---

## Research

### Computational Geometry and Topological Data Analysis

My academic research focused on building geometric algorithms that are provably
correct under numerical constraints — treating precision as a limited resource
rather than an assumption. Applications included physical simulation,
constructive solid geometry, image processing, nearest-neighbor queries, and
surface simplification. This work was the foundation of my PhD at UNC Chapel
Hill, where I was advised by Jack Snoeyink, and continued through my faculty
appointment at Montana State University.

At MSU, this research thread expanded into topological data analysis: using
tools from algebraic topology to extract structure from complex datasets.
Projects included analyzing musical compositions with TDA, topology-driven
approaches to localization, and studying the "power" of various topological
descriptors.

### BRaID — Biofilm Resource and Information Database

As PI on an NSF ABI Innovation grant ($300K), I led development of BRaID, a
system for fusing and organizing diverse biofilm data types using ontology and
Bayesian networks. The project brought together researchers in computer
science, microbiology, and data science.

---

## Software Utilities

These are a sample of some of my current favorite small utilities that I have
worked on recently.

### muxwm

[muxwm](https://github.com/dlm/muxwm) is a workflow management layer for the i3
window manager, bringing tmux-like project and task semantics to i3. It lets
you switch between named project views without managing workspace numbers
manually. Written in Rust.

### pluck

[pluck](https://github.com/dlm/pluck) extracts code snippets from source files
by tag — using function and type definitions as anchors rather than line
numbers — so documentation stays in sync as code evolves. A lightweight
alternative to literate programming. Written in Go.

### abi

[abi](https://github.com/dlm/abi) is a minimal Go library for Ethereum ABI
encoding and decoding. No reflection, no code generation, zero dependencies.
Written in Go.

---

## Joke Projects

Not everything needs to ship to production.

### Code HIIT

[Code HIIT](https://dlm.github.io/code-hiit/) applies the principles of
high-intensity interval training to the one muscle that matters most: your
fingers. Timed drills for symbols, brackets, regex, and other characters that
separate real programmers from people who use GUIs. Intervals for coders.

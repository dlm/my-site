---
title: "The Haplab Stack"
date: 2026-03-31
draft: true
---

Over the past month, I have been trying to form my own opinion on multi-agent
workflows while staying at a reasonable price point. So, for these
experiments, I used a Claude Pro and Code Plus plan. Each plan is $20 per
month. So, while not cheap, the cost is about the same as a monthly gym
membership at a "big-box" gym like Crunch. In this experiment, I used a
multi-agent system to vibe code a (very silly) tool that does high intensity
interval training (HIIT) for typing code. (The irony is delicious.)

I explored a few different workflows, but decided to try some tools from
[Haplab](https://haplab.com/). Two were particularly interesting to me. The
first is [Sidecar](https://sidecar.haplab.com/), which is a tool for managing
agentic workflows.  The second is [td](https://td.haplab.com/), which is a
project management tool specifically designed for agentic teams.

Sidecar was neat in concept. Specifically, it provides the user with a
collection of "plugins". The one I found most useful was the one that manages
a collection of terminals where each terminal has a running agent. In practice
though, it didn't work very well. Specifically, the plugin achieves its
functionality by wrapping tmux. While tmux runs fine on my system, when I used
it from within Sidecar it was less responsive and introduced some lag. Often,
it felt like typing over a slow ssh connection and caused a lot of mistyping.
But, I like the direction that the author is taking and plan to continue to
watch the progress of the project.

TD knocked it out of the park! TD tries to solve the problem of coordinating the
work of a multi-agent team. I liked to think of it as taskwarrior meets jira
but for agentic coding tools. What I mean is that it is stored locally and
interacted with via cli---similar to taskwarrior---but it enforces structure,
process, and workflows---similar to jira. One of the "key" workflow items is
that if an agent codes the task, a different agent must review the code. These
agents "hand off" context via the `td` tool, which allows the operator (in this
case, me) to follow and guide the process. That allowed me to function as a PM
but still actually understand the code and architecture of the system.

After a few days of playing around with different workflows, I found it was
convenient to have two teams. Each team consisted of a coding agent (usually
claude-code) and a review agent (usually codex). Often, I would have one team
working on coding a feature while I worked on designing a feature with the
other team. A few times, I also worked on the project's website with a third
team. On occasion, I used a separate claude-code instance to talk through some
ideas for feature creation. I also tried to get the free version of
[amp](https://ampcode.com/) in on these shenanigans, but it kept spitting out
errors and so I gave up on that. With respect to the claude agents, I tended
to find that restarting each claude agent for each new feature worked better
than letting them run for a while, but I was surprised to find how resistant
it was to following the content in the AGENTS.md file. In fact, it even
deleted the file at one point.

Shockingly, this workflow was pretty smooth. I did hit my limits on
claude-code during this experiment, which I had yet to do before. Moreover, I
suspect that I could have scaled this workflow up a little more but my computer
started to struggle. (I think it may be from a [memory leak in
ghostty](https://mitchellh.com/writing/ghostty-memory-leak-fix).) But, with
respect to scaling the workflow, I am not sure I would want to do that for
something that I was sending to production. I found that as I "scaled up" the
workflow, I was producing more code than I could review. So, if I was sending
this code into production (and it "mattered"), I do not think I would feel
comfortable signing off. But, I did think that for a POC, this was great!

With respect to managing all of these parallel tasks, while I was hoping that
[Sidecar](https://sidecar.haplab.com/) would be an unlock, it was not. But
even without that tool, I did not find managing all of these tasks to be a
problem. I think it may have to do with a personal workspace management tool
that I am working on (and will post about in the next month... so stay tuned).

Overall, for the HIIT coding tool, I think it turned out meh. While I am
trying to stay true to the "vibe coding" thing and "trust the model", I did
peek in on the code every now and then and almost always found a bug. Moreover,
codex seemed to find or produce a bug with every task as well. But, for some
projects, I am not sure I care. I was able to spike out an idea really quickly.
And while I don't think that HIIT-based code-typing training is going to be the
next big thing, this may be a nicer way to try something out that has less
smoke and mirrors and more of a "playground" feel.

Oh, yeah, and if for some reason you are interested in HIIT based code typing
training, you can find it at [code-hiit](https://dlm.github.io/code-hiit/).
Feel free to play around with it; it is kind of fun for a few minutes.

## Versions

Codex version 0.63.0 w/ gpt-5.1-codex-max
Claude version v2.0.50 w/ Sonnet 4.5
Amp version 0.0.1763985694-g51fa6e
Sidecar version 0.77.0
TD version 0.41.0

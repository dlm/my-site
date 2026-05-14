---
title: "On Bad CLI Design"
date: 2026-05-14
draft: true
---

Yesterday (May 13, 2026), Anthropic announced that it will no longer consider
the use of the `claude -p` flag as part of a subscription usage.

> Starting June 15, 2026, Claude Agent SDK and claude -p usage no longer counts
> toward your Claude plan’s usage limits. Your subscription usage limits stay
> the same and stay reserved for interactive use of Claude Code, Claude Cowork,
> and Claude.

For those unfamiliar with this option it:

```bash
-p, --print      Print response and exit (useful for pipes). Note: The workspace trust dialog is skipped when Claude is run with the -p mode. Only use this flag in directories you trust
```

It is my understanding that the reason for this change is because tools
are using claude in a way that is not beneficial to Anthropic by using this
flag. So for example, in OpenClaw we see the
[code](https://github.com/openclaw/openclaw/blob/28550a798cf7633bad1fc226a811d4bf66bf2dd6/extensions/anthropic/cli-backend.ts#L32-L43)

```ts
      command: "claude",
      args: [
        "-p",
        "--output-format",
        "stream-json",
        "--include-partial-messages",
        "--verbose",
        "--setting-sources",
        "user",
        "--allowedTools",
        "mcp__openclaw__*",
      ],
```

That is, they build an entire agent on the `-p` flag.
We can contrast that with a tool of mine called `ask`.
You can find the source in my [env
repo](https://github.com/dlm/env/blob/78f4384d1eccf24403d4baa63fb2c199d8b81a82/bin/scripts/ask).
Generally, this tool is a quick cli that wraps some tools so that I can quickly
run some queries without leaving my terminal.  For example, `ask define <word>`
will give me the definition of a word and `ask ip` will get my public ip from
[ipify.org](https://www.ipify.org/).  So, of course, I would add a function to
oneshot claude query.  I don't need to open up claude code or go to the web
for something that I know will only be a single call.  The `nu` function is
simple:

```
# Ask Claude AI
def "main claude" [
    --continue (-c)  # Continue into interactive chat
    ...question: string
] {
    let prompt = ($question | str join ' ')
    let has_prompt = ($prompt | is-not-empty)

    # Show usage if no args and no continue flag
    if (not $has_prompt) and (not $continue) {
        print "Usage: ? your question here"
        print "       ? -c (continue last conversation)"
        print "       ? -c your question (ask then continue)"
        return
    }

    # Ask the question first if we have one
    if $has_prompt {
        gum spin --spinner dot --title "Thinking..." --show-output -- claude -p $prompt
    }

    # Continue into interactive mode if requested
    if $continue {
        claude --continue
    }
}
```

Which also allows me to `ask claude --continue` if the response requires
continuing in claude code.  So, it seems that they want to limit the agent
building use case, but that comes at the expense of good unix tool design.

The unix philosophy is a good thing.  Sharp composable tools are a good thing.  And,
in fact, the `claude -p` flag was a great example of a composable tool.
So, why does the ToS change create a bad design?
Because part of composability is the expectation that flags are orthogonal
modifiers. Changing a flag shouldn't silently switch your billing pool.

Let's consider an analogy of why this is terrible design using a totally
different domain. The `gh` tool (github's cli, which is overall, pretty good)
is designed as:

```bash
gh pr list
gh issue list
gh repo list
```

Not:

```bash
gh --list-pr
gh --list-issue
gh --list-repo
```

Because pr, issue, and repo are not “options.” They are resources. The `gh`
then uses flags inside those domains for orthogonal modifiers:

For example:

```bash
gh issue list --state closed --assignee monalisa
```

That is, these are filtering flags for specific use cases. The problem with
claude's design is that now:

```
claude        # interactive agent, billed from pool A
claude -p     # print / non-interactive mode, billed from pool B
```

That is, the flag is doing two jobs at once:
1. selecting interaction mode: interactive vs print
2. selecting billing/accounting pool
That is the non-orthogonality. So, let's see what the `gh` cli would be with
that type of URL:

```
gh issue list              # uses normal GitHub quota
gh issue list --json       # suddenly uses a different paid quota
```

The problem is that `--json` is output formatting. If the claude design was
actually good, this would not be an issue. Perhaps a setup like:

```bash
claude chat
claude api
```

Would make this much easier to manage (and one could even have `claude` alias
to `claude chat`).  But, I think the problem is that the `-p` looks like an
execution-mode flag, but now that it changes billing semantics. That violates
the expectation that flags are orthogonal modifiers, not hidden context
switches. But, I guess that is what happens when you just vibe code your way
into a hot mess.

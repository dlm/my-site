---
title: "You Need Experience to Know When AI Gets It Wrong"
date: 2026-02-08
draft: true
---

I had an interesting conversation with one of my colleagues at the end of last
week. He was just trying claude code for the first time on a web project.  He
is not a web developer, he doesn't have much experience with modern web
development, and by his own admission, he is not interested in developing those
skills. I found our discussion thought provoking because in the conversation, he
mentioned that he was amazed by how good claude code was. But also 
shared a story about how he could not get an image cropped in the way he wanted.
After fighting with the tool, he ended up using an image editor.  To me,
this seems like a contradiction in the assessment of the utility of these
tools.

But, I don't think my colleague is alone in his contradictory assessment. It
feels like about half of the tech related posts I see on social media are from
people with strongly held opinions about how amazing LLM based coding agents
are. But, if I investigate my experiences and weight the few "influencers" that
I know are somewhat decent engineers, I see a different picture.  And to be
frank, I think it may have something to do with experience.

Let me illustrate with an example from a small UI element that I created for
the i3 window manager. (Note that this was in session so not all of the history
is provided.)

> Let's add a feature so that I can press a key combo while on container X.  The
> key combo pops up a rofi window where I can see the list of workspaces.  I can
> either select one workspace or type the name of a new workspace and the
> container X will be sent to that workspace and we will moved to that workspace.

This is a very simple script that would be very easy to write manually. But, to
my surprise, the result was kind of "insane".  Here is the suggested
code (you don't need to understand all of this, just skim it for the highlights):

```
#!/usr/bin/env bash
set -euo pipefail

# Pick your rofi binary/options here
ROFI_BIN="${ROFI_BIN:-rofi}"
ROFI_OPTS=(
  -dmenu
  -i
  -p "Move container to workspace →"
  -matching normal
)

# Get workspace names via i3-msg JSON, parse via python (no jq dependency)
ws_list="$(
  i3-msg -t get_workspaces \
  | python3 - <<'PY'
import json, sys
ws = json.load(sys.stdin)
names = [w["name"] for w in ws]
# i3 already preserves order; you could sort if you prefer.
print("\n".join(names))
PY
)"

# rofi returns chosen text (existing) or arbitrary input (new workspace name)
choice="$(
  printf "%s\n" "$ws_list" | "$ROFI_BIN" "${ROFI_OPTS[@]}" || true
)"

# Cancel / empty input
if [[ -z "${choice// }" ]]; then
  exit 0
fi

# Move the focused container, then switch to that workspace
# Quote carefully: i3 understands the workspace name as a string.
i3-msg --quiet "move container to workspace \"${choice//\"/\\\"}\"; workspace \"${choice//\"/\\\"}\"" >/dev/null
```

Of particular note is the following two items.  First, the usage of variables
for rofi. These are unnecessary and could just be inlined.  I am somewhat curious
though why an LLM chose to factor out `rofi` and not `i3-msg`?
Second, is the use of the python script embedded in the bash script.  Such
a design requires fragile quoting and escaping. Crazy!

There are a lot of ways to make this more "sane".  Some would be just use
python (and not python and bash) or use `jq`.  Personally, I am on a nushell
kick right now and so I suggested that we rewrite in nu.  That produced
something that was much better:

```
#!/usr/bin/env nu
# Move focused container to a chosen/new workspace (rofi), then follow.

let rofi_bin = ($env.ROFI_BIN? | default "rofi")

# Get workspace names
let ws_list = (
  ^i3-msg -t get_workspaces
  | from json
  | get name
)

# Feed workspaces into rofi; user can also type a new name.
let choice = (
  $ws_list
  | str join "\n"
  | ^$rofi_bin -dmenu -i -p "Move container to workspace →"
  | str trim
)

if ($choice | is-empty) {
  exit 0
}

# Escape any double-quotes for i3 command strings.
let esc = ($choice | str replace -a '"' '\"')

# Move the focused container, then switch to that workspace
^i3-msg --quiet $"move container to workspace \"($esc)\"; workspace \"($esc)\"" | ignore
```

Sure, it still does the rofi variable nonsense, there is some escaping that
could be removed, and some of the i3-msg ipc could be cleaned up to make it less
error prone. But, overall, the lack of nesting makes the simplicity more clear.

But, why does this example matter?  Well, if I think back to how my students at
MSU would handle the first version (if they had LLMs at the time), most
would have accepted the code because it appeared to work and they would have
moved on.  Many would have looked at the python in bash, not really known what
was going on but been okay with it because it kind of worked.  So, maybe I am
making a leap, but I think this is a pretty good proxy for the response of a
Junior engineer.  At least from my perspective, the student/junior engineer
wouldn't have enough experience (or maybe not enough confidence) to point out
just how convoluted (and error prone) that code was.

So not to be rude, but what I think I am observing is that a lot of the people
speaking the loudest about how good LLMs based coding tool may lack the
experience to actually assess the utility of these tools. And perhaps we are
seeing some sort of cognitive bias coming into play. I kind of liken it to a
Dunning-Kruger-like effect (but maybe slightly different). I don't think I am
alone in this thinking. We have already seen
[studies](https://arxiv.org/abs/2507.09089) that demonstrate that in production
code, these tools provide only marginal productivity gains even if developers
perceive significant improvement.

So, my take on what is going on here is that most of the excitement is an issue
of inexperience.  Yes, there are some great anecdotes but those tend to be
working in conjunction with a very skilled engineers that are treating coding
agents as yet another tool just like a sophisticated text editor, an LSP, or a
debugger.  So yes, these tools are exciting, and hopefully it allows more
people to build stuff, but I suspect that to really get the full benefit of it,
we are still in the "centaur" phase.

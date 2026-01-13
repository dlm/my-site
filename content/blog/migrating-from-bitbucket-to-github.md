---
title: "Migrating my MSU Courses Material from Bitbucket to GitHub"
date: 2025-12-22
---

A while back, I was a professor in the Computer Science department at Montana
State University (MSU).  Because MSU is a public university in which the
mission was to educate the people of Montana, I thought it was wrong to lock
the course content away behind a course management system such as Brightspace.
Moreover, I was teaching courses in CS.  So, what better way to get students
comfortable with modern tools than by managing all course materials (other than
grades) via git.

I maintained a public authoritative version of the repo containing the course
materials. Materials included assignments, my notes, answers (if appropriate),
code samples, etc. Originally, I hosted the repos on Bitbucket in the [msu-cs
workspace](https://bitbucket.org/msu-cs/workspace/repositories/). At the time,
Bitbucket also supported mercurial and half of my collaborators used
mercurial, which made it a natural choice.

Over time, Bitbucket dropped mercurial support and it became clear that GitHub
was going to "win". Moreover, students wanted to use GitHub specifically. So, I
decided to start posting my course materials on GitHub.  By some amazing luck
(and persistence), I was able to claim the [MSU
handle](https://github.com/msu). (Eat your heart out Michigan State!!)

Well, a few days ago, I opened my email to find that Bitbucket was planning on
deleting "inactive" repos.  That is annoying because while I am not actively
working on those classes they are still used. Specifically, they serve as a
resource in at least two cases that I know of. First, a previous Graphics
student got a job working on a rendering engine and he returned to the course
material as he was working on particular projects.  Second, a current faculty
member had a funded project that had a heavy visualization component that could
not be supported by out-of-the-box viz tools. That faculty member had no
background in graphics and so he pointed his student to my course materials.

So, I decided to migrate all my old course material to GitHub.  Since I am
(slowly) migrating to nushell, I thought this was a great opportunity to write
my first "real" nushell script.  I have to say, nu is wonderful! Yes, the
script is simple---read a list of repos, clone each repo as a mirror, create a
repo on GitHub, and push the mirror---but the code reads like an actual program
with the ergonomics of a script.  Added bonus: function arguments can have types.

I have a few other small projects that I have been meaning to create that seem
like great options for nu.  So stay tuned for more as I experiment with nu.

Here is the [code](https://github.com/dlm/util/tree/master/bb-to-github).
Perhaps it can be a starting point for you if you need to do the same thing.


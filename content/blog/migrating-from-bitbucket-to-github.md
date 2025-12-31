---
title: "Migrating my MSU Courses Material from Bitbuckt to Github"
date: 2025-12-22
draft: true
---

When I started at MSU I had this thought that since I was teaching at a public 
univerity and the goal was to educate the children of Montana,
it seemed wrong for me to lock the course content away behind a 
course management system such as Brightspace.  Moreover, I was teaching
CS courses.  What better a way to get the students to be comfortable with 
modern tools than by managing all course materials (other than grades), via 
git repositories.  (I will save how I organized this for a separate post.)
But the main point was that I maintained an authortative version of the repo publically. 
It had all the material, assignments, etc.  Originally, I kept them all in 
https://bitbucket.org/msu-cs/workspace/repositories/.  I chose bitbutcket because 
at the time it also supported mercurial, and my main collaborator perfered mercuruial to 
git.  (Personally, I liked mercurial but since the industry seemed to be going to git, I thought it was better 
for my courses to use git. ... but I digress).
When it became clear that the students wanted to use not just git, but github, 
I looked around and was able to claim https://github.com/msu (eat your heart out Michigan State!!)

Well, a few days ago, I opened my email to find that bitbucket was planning on
deleting "inacive" repos.  That was kind of annoying to me because while I am
not actively working on those classes, I do like that the material is available
and other factuly can point students to those resources for courses that are
not longer taught since I left (for example, Computer Graphics or the Graduate
Level Database course). 

So, I decided to migrate all my old course material to github.  Since I am 
(slowly) migrating to nushell, I thought this was a great opportunity to 
write my first "real" nushell script.  I have to say, it was wonderful!
While yes, the script is simple, just read in a list of repos, 
clone each repo as a mirror, create a repo on github and push the mirror.
But, the code reads like an actual program with the ergonomics of a script
and it has types!  

... todo: say some more things that I liked to bring it home.

Here is a link to the code if you need to do the same thing.


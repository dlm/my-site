#!/usr/bin/env nu

def main [
    --title: string # the (working) title of the blog post
] {
    if ($title | is-empty) {
        print "Usage: new-post.nu --title <working-blog-title>"
        return
    }

    let filename = $title
        | str downcase
        | str replace --regex '[^a-z0-9- ]' '' --all
        | str trim
        | str replace --all ' ' '-'
    let date = date now
        | format date '%Y-%m-%d'

    let filepath = $"content/blog/($filename).md"

    let content = $"---
title: \"($title)\"
date: ($date)
draft: true
---

<!-- Start writing here -->

"
    $content | save $filepath

    print $"Created new draft post: ($filepath)"
    print "To preview drafts: hugo server -D"
    print "To publish: remove 'draft: true' from the front matter"
}

---
title: "Suprising Scoping Rules of Rust"
date: 2025-12-30
draft: true
---

### Blog topic sketch - scope in rust

One thing that it
doesn't touch on that, to me, seems interesting, is that the scope of a
variable ends on the last use of the variable, not at the end of the block.
(Maybe I missed it or perhaps it was not explained well... either way...)
We can see an example here:

The following code compiles and runs

```rust
fn main() {
    let mut s1 = String::from("hello");

    let r1 = &s1;
    let r2 = &s1;
    println!("{r1} and {r2}");

    let r3 = &mut s1;
    change(r3);
    println!("{r3}");
    println!("{s1}");
}

fn change(s: &mut String) {
    s.push_str(", world");
}
```

But this does not

```rust
fn main() {
    let mut s1 = String::from("hello");

    let r1 = &s1;
    let r2 = &s1;
    println!("{r1} and {r2}");

    let r3 = &mut s1;
    change(r3);
    println!("{r3} {s1}");
}

fn change(s: &mut String) {
    s.push_str(", world");
}
```

It is because r3 is till in scope in the println! line, but, when we break the
println into two lines, r3 is out of scope and so because there are no more
references in scope we can go back to using s1




# sh-utils
A collection of shell (sh/bash/zsh) utilities. Just playing around with this, nothing serious here. 

It's pretty POSIX-compliant.
The only exception is the use of `mktemp` which is needed to run the test-suite. 

Otherwise, it's a pretty straightforward file you could import.
Comes with some basic features for writing tests of complicated methods, and a couple examples.

This was strongly inspired by Aditya Athalye's _[Shell ain't a bad place to FP](https://www.evalapply.org/posts/shell-aint-a-bad-place-to-fp-part-0-intro/)_ series. 

I used a couple of these patterns at work, so I thought it would be nice to make a separate version publicly, for easy copy-paste. 


Haven't been using this style very long, so I wouldn't say I'm endorsing it yet, or really understanding it yet fully. 

## Example usage

```shell
. utils.sh

$ echo "one
two
three
" | map "tr -s 'a-z' 'A-Z'" \
    | filter 'test "4" = "$(tee | wc -m)"' \
    | count
2
```

`map`/`filter`/`for_each` are all taking predicate functions that are applied to each line. 
They don't have to be inline commands like that. 
If you were capitalizing things a lot, it would work equally well so long as the function takes its input through STDIN and returns its output on STDOUT.

```shell
$ capitalize() {
    tr -s 'a-z' 'A-Z'
}

$ echo "abc\ndef\n" | map capitalize
```
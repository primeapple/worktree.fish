# worktree.fish

This is a little wrapper around the `git worktree` command. It does provide convenience opinionated functions to create, switch and manage git worktrees.

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```
fisher install primeapple/worktree.fish
```

## Conventions

As we are opinionated we expect that all worktrees live right next to another in a single directory, named after the repository itself.
The naming schema for each worktree is `REPONAME+BRANCHNAME`.

This means that a usual git directory for the repo `cool-app` becomes the following folder structure:

```
cool-app/cool-app+main
cool-app/cool-app+work
cool-app/cool-app+review
cool-app/cool-app+branch1
cool-app/cool-app+chore-branch2
cool-app/cool-app+fix%2Fbranch3
...
```

As you see there are special cases (of course there are 😅).

First we have the three **parking** worktrees `main`, `work`, `review`. They are inspired by [this article](https://matklad.github.io/2024/07/25/git-worktrees.html).
They have dedicated branches: `main` (or `master` or whatever your default branch is), `parking/work`, `parking/review`.

Then there are dedicated worktree for certain branches. You don't have to create a worktree for every single one of them but you probably want to for agentic work or e.g. fuzzing.
We have to encode the `/` symbol. This is done via `%2F`.

## Usage

Let's have a sample session!

### Initializing and Switching

```sh
git clone git@github.com:primeapple/worktree.fish.git && cd worktree.fish
pwd # /worktree.fish

worktree init
# Structure created:
#   worktree.fish/
#     ├── worktree.fish+main (main branch)
#     ├── worktree.fish+work (parking/work branch)
#     ├── worktree.fish+review (parking/review branch)
pwd # /worktree.fish/worktree.fish+main

worktree switch review
pwd # /worktree.fish/worktree.fish+review
worktree switch work
pwd # /worktree.fish/worktree.fish+work
```

### Creating and Cleaning

```sh
pwd # /worktree.fish/worktree.fish+work
git switch --create feature
touch file && git add --all && git commit --message "Added feature"

worktree create
pwd # /worktree.fish/worktree.fish+feature
git branch --show-current # feature

worktree create bugfix
pwd # /worktree.fish/worktree.fish+bugfix
git branch --show-current # bugfix

worktree clean
# Info: Removing worktree /worktree.fish/repository+bugfix
# Info: Removing worktree /worktree.fish/repository+feature
# -> It removed all non-dirty worktrees except for default ones
pwd # /worktree.fish/worktree.fish+work
git branch --show-current # parking/work
```

### Parking and Resetting

```sh
pwd # /worktree.fish/worktree.fish+work
git switch --create bad-idea
touch file && git add --all && git commit --message "Added feature"

worktree park
pwd # /worktree.fish/worktree.fish+work
git branch --show-current # parking/work
# -> It also did a hard reset of the parking branch to origin/main

worktree reset
# Info: Removing worktree /worktree.fish/worktree.fish+review
# Info: Removing worktree /worktree.fish/worktree.fish+work
# -> It removed all non-dirty worktrees except for main, which was moved to it's original location
pwd # /worktree.fish
```

There are many more hidde features like e.g. switching between worktrees via `fzf` (if installed) Run `worktree` to see help output (or take a look into the completions).

Let's have fun :)

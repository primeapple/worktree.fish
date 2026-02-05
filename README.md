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

```sh
# Create a git repository
mkdir repo && cd repo && git init

# Intitialize, this will create the parking worktrees and cd into the `work` one
worktree init

# Create a new branch in a worktree, this will directly jump into there
worktree create branch1

# Switch to the work one again, this will switch the worktree 
worktree switch work # or `worktree switch main` or `worktree switch review` or just `worktree switch`

# Create a new branch in the `work` worktree
git switch --create chore-branch2
# Extract it into a separate worktree (will check out `parking/work` in the `work` worktree)
worktree create
```

There are many more commands, like `worktree clean` or `worktree park`. Run `worktree` to see help output (or take a look into the completions).

Let's have fun :)

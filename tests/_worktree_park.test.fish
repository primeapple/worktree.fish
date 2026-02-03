# RUN: %fish %s

source (dirname (status filename))/test_helpers.fish

### Setup
set -l tmpdir (setup_test_repo main)

### TEST cannot park if not in git repo
cd $tmpdir
worktree park # CHECKERR: Error: Not in a git repository

### TEST cannot park if no worktree structure found
cd $tmpdir/repository
worktree park work # CHECKERR: Error: No worktree structure found

cd $tmpdir/repository
worktree init >/dev/null
pwd # CHECK: {{.*}}/repository/repository+main

### TEST cannot park if working directory / staging area is dirty
touch thing
worktree park # CHECKERR: Error: You have uncommitted changes
echo $status # CHECK: 1
rm thing

### TEST cannot branch any other worktrees than the default ones
git worktree add -b other-worktree-branch ../repository+other-worktree-branch >/dev/null 2>/dev/null
cd ../repository+other-worktree-branch
worktree park # CHECKERR: Error: Can only park the default worktrees (main review work)

### TEST park should checkout default branch
cd ../repository+main
git switch --create test-branch 2>/dev/null
git branch --show-current # CHECK: test-branch
worktree park # CHECKERR: Warning: No remote found, not resetting to latest remote default branch
git branch --show-current # CHECK: main

cd ../repository+work
git switch test-branch 2>/dev/null
git branch --show-current # CHECK: test-branch
worktree park # CHECKERR: Warning: No remote found, not resetting to latest remote default branch
git branch --show-current # CHECK: parking/work

cd ../repository+review
git switch test-branch 2>/dev/null
git branch --show-current # CHECK: test-branch
worktree park # CHECKERR: Warning: No remote found, not resetting to latest remote default branch
git branch --show-current # CHECK: parking/review

### Teardown
cleanup_test_repo $tmpdir

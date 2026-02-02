# RUN: %fish %s

source (dirname (status filename))/test_helpers.fish

### Setup
set -l tmpdir (setup_test_repo main)

### TEST cannot switch if not in git repo
cd $tmpdir
worktree switch work
# CHECKERR: Error: Not in a git repository

### TEST cannot switch if no worktree structure found
cd $tmpdir/repository
worktree switch work
# CHECKERR: Error: No worktree structure found

cd $tmpdir/repository
worktree init >/dev/null
pwd # CHECK: {{.*}}/repository/repository+main

### TEST can switch between main branches
worktree switch work
pwd # CHECK: {{.*}}/repository/repository+work
worktree switch main
pwd # CHECK: {{.*}}/repository/repository+main
worktree switch review
pwd # CHECK: {{.*}}/repository/repository+review

### Teardown
cleanup_test_repo $tmpdir

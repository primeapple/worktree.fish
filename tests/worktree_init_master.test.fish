# RUN: %fish %s

source (dirname (status filename))/_test_helpers.fish

### Setup
set -l tmpdir (setup_test_repo master)

### TEST cannot init if not in git repo
cd $tmpdir
worktree init # CHECKERR: Error: Not in a git repository
echo $status # CHECK: 1

### TEST cannot init if working directory / staging area is dirty
cd $tmpdir/repository
touch thing
worktree init # CHECKERR: Error: You have uncommitted changes
echo $status # CHECK: 1
rm thing

### TEST basic init
worktree init
# CHECK: Structure created:
# CHECK:   repository/
# CHECK:     ├── repository+main (master branch)
# CHECK:     ├── repository+work (parking/work branch)
# CHECK:     ├── repository+review (parking/review branch)
echo $status # CHECK: 0

### TEST cd into the main worktree
pwd # CHECK: {{.*}}/repository/repository+main

### TEST have created 3 worktrees in expected locations
git worktree list
# CHECK: {{.*}}/repository/repository+main{{.*}} [master]
# CHECK: {{.*}}/repository/repository+review{{.*}} [parking/review]
# CHECK: {{.*}}/repository/repository+work{{.*}} [parking/work]

### TEST have checked out the 3 default branches in the worktrees
git branch --list
# CHECK: * master
# CHECK: + parking/review
# CHECK: + parking/work

### TEST cannot init if already in worktree structure
worktree init # CHECKERR: Error: Already in a worktree structure
echo $status # CHECK: 1

### Teardown
cleanup_test_repo $tmpdir

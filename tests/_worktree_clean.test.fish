# RUN: %fish %s

source (dirname (status filename))/test_helpers.fish

### Setup
set -l tmpdir (setup_test_repo main)

### TEST cannot clean if not in git repo
cd $tmpdir
worktree clean # CHECKERR: Error: Not in a git repository

### TEST cannot clean if no worktree structure found
cd $tmpdir/repository
worktree clean # CHECKERR: Error: No worktree structure found

worktree init >/dev/null
pwd # CHECK: {{.*}}/repository/repository+main

git worktree add --quiet -b other-clean ../repository+other-clean
git worktree add --quiet -b other-dirty ../repository+other-dirty
cd $tmpdir/repository/repository+other-dirty
touch dirty-file

### Verify worktrees exist before clean
git worktree list
# CHECK: {{.*}}repository/repository+main{{.*}}
# CHECK: {{.*}}repository/repository+other-clean{{.*}}
# CHECK: {{.*}}repository/repository+other-dirty{{.*}}
# CHECK: {{.*}}repository/repository+review{{.*}}
# CHECK: {{.*}}repository/repository+work{{.*}}

### TEST clean command removes only clean worktrees
cd $tmpdir/repository/repository+other-clean
worktree clean
# CHECK: Info: Removing worktree {{.*}}/repository/repository+other-clean
# CHECKERR: Warning: Can not remove dirty worktree {{.*}}/repository/repository+other-dirty

pwd # CHECK: {{.*}}/repository/repository+work
git worktree list
# CHECK: {{.*}}repository+main{{.*}}
# CHECK: {{.*}}repository+other-dirty{{.*}}
# CHECK: {{.*}}repository+review{{.*}}
# CHECK: {{.*}}repository+work{{.*}}

### TEST should cd into main worktree if current one is removed
cd $tmpdir/repository/repository+other-dirty
rm dirty-file
worktree clean # CHECK: Info: Removing worktree {{.*}}/repository/repository+other-dirty

pwd # CHECK: {{.*}}/repository/repository+work
git worktree list
# CHECK: {{.*}}repository+main{{.*}}
# CHECK: {{.*}}repository+review{{.*}}
# CHECK: {{.*}}repository+work{{.*}}

### Teardown
cleanup_test_repo $tmpdir

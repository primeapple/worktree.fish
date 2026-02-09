# RUN: %fish %s

source (dirname (status filename))/_test_helpers.fish

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

worktree create other/clean
cd $tmpdir/repository/repository+main
worktree create other-dirty
touch dirty-file

### Verify worktrees exist before clean
git worktree list
# CHECK: {{.*}}repository/repository+main{{.*}}
# CHECK: {{.*}}repository/repository+other%2Fclean{{.*}}
# CHECK: {{.*}}repository/repository+other-dirty{{.*}}
# CHECK: {{.*}}repository/repository+review{{.*}}
# CHECK: {{.*}}repository/repository+work{{.*}}

### TEST clean command removes only clean worktrees
cd $tmpdir/repository/repository+other%2Fclean
worktree clean
# CHECK: Info: Removing worktree {{.*}}/repository/repository+other%2Fclean
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

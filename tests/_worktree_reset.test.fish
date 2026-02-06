# RUN: %fish %s

source (dirname (status filename))/test_helpers.fish

### Setup
set -l tmpdir (setup_test_repo main)

### TEST cannot reset if not in git repo
cd $tmpdir
worktree reset # CHECKERR: Error: Not in a git repository

### TEST cannot reset if no worktree structure found
cd $tmpdir/repository
worktree reset # CHECKERR: Error: No worktree structure found

worktree init >/dev/null
pwd # CHECK: {{.*}}/repository/repository+main
worktree create other-branch
pwd # CHECK: {{.*}}/repository/repository+other-branch
touch dirty-file-other
worktree switch main
touch dirty-file-main
cd $tmpdir/repository/repository+other-branch

### TEST cannot reset if any worktrees are dirty
worktree reset # CHECKERR: Error: Cannot reset worktrees, this one is dirty: {{.*}}/repository/repository+other-branch
echo $status # CHECK: 1
rm $tmpdir/repository/repository+other-branch/dirty-file-other

git worktree list
# CHECK: {{.*}}repository/repository+main{{.*}}
# CHECK: {{.*}}repository/repository+other-branch{{.*}}
# CHECK: {{.*}}repository/repository+review{{.*}}
# CHECK: {{.*}}repository/repository+work{{.*}}

### TEST should remove worktrees and move repo back
worktree reset
# CHECK: Info: Removing worktree {{.*}}/repository/repository+other-branch
# CHECK: Info: Removing worktree {{.*}}/repository/repository+review
# CHECK: Info: Removing worktree {{.*}}/repository/repository+work
echo $status # CHECK: 0
pwd # CHECK: {{.*}}/repository
git worktree list # CHECK: {{.*}}/repository {{.*}} [main]
git branch --show-current # CHECK: main
git status --porcelain # CHECK: ?? dirty-file-main

rm dirty-file-main

### TEST should clean everything up, so that init works again
worktree init
# CHECK: Git worktree setup complete!
# CHECK: Structure created:
# CHECK:   repository/
# CHECK:     ├── repository+main (main branch)
# CHECK:     ├── repository+work (parking/work branch)
# CHECK:     ├── repository+review (parking/review branch)
echo $status # CHECK: 0

### Teardown
cleanup_test_repo $tmpdir

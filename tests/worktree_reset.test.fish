# RUN: %fish %s

source (dirname (status filename))/_test_helpers.fish

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
git branch | grep parking | wc -l # CHECK: 2

### TEST should remove worktrees and move repo back
worktree reset
# CHECK: Info: Removing worktree {{.*}}/repository/repository+other-branch
# CHECK: Info: Removing worktree {{.*}}/repository/repository+review
# CHECK: Info: Removing worktree {{.*}}/repository/repository+work
# CHECK: Info: Removing parking branch parking/review
# CHECK: Info: Removing parking branch parking/work
echo $status # CHECK: 0
pwd # CHECK: {{.*}}/repository
git worktree list # CHECK: {{.*}}/repository {{.*}} [main]
git branch --show-current # CHECK: main
git status --porcelain # CHECK: ?? dirty-file-main
git branch | grep parking | wc -l # CHECK: 0

rm dirty-file-main

### TEST should clean everything up, so that init works again
worktree init
# CHECK: Structure created:
# CHECK:   repository/
# CHECK:     ├── repository+main (main branch)
# CHECK:     ├── repository+work (parking/work branch)
# CHECK:     ├── repository+review (parking/review branch)
echo $status # CHECK: 0

### TEST should NOT delete parking branches with extra commits when resetting
cd $tmpdir/repository/repository+work
touch work-file.txt
git add work-file.txt
git commit -m "Work commit" -q
cd $tmpdir/repository/repository+main
worktree reset
# CHECK: Info: Removing worktree {{.*}}/repository/repository+review
# CHECK: Info: Removing worktree {{.*}}/repository/repository+work
# CHECK: Info: Removing parking branch parking/review
# CHECK: Warning: Can't remove branch parking/work, it has commits that are not on default branch
git branch | grep parking/work # CHECK: parking/work

### Teardown
cleanup_test_repo $tmpdir

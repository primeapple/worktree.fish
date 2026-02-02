# RUN: %fish %s

source (dirname (status filename))/test_helpers.fish

### Setup
set -l tmpdir (setup_test_repo main)
cd $tmpdir/repository

worktree init
# CHECK: Git worktree setup complete!
# CHECK: Structure created:
# CHECK:   repository/
# CHECK:     ├── repository+main (main branch)
# CHECK:     ├── repository+work (parking/work branch)
# CHECK:     ├── repository+review (parking/review branch)

pwd # CHECK: {{.*}}/repository/repository+main

git worktree list
# CHECK: {{.*}}/repository/repository+main{{.*}} [main]
# CHECK: {{.*}}/repository/repository+review{{.*}} [parking/review]
# CHECK: {{.*}}/repository/repository+work{{.*}} [parking/work]

git branch -a
# CHECK: * main
# CHECK: + parking/review
# CHECK: + parking/work

cleanup_test_repo $tmpdir

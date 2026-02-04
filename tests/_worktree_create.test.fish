# RUN: %fish %s

source (dirname (status filename))/test_helpers.fish

### Setup
set -l tmpdir (setup_test_repo main)

### TEST cannot create if not in git repo
cd $tmpdir
worktree create # CHECKERR: Error: Not in a git repository
echo $status # CHECK: 1

### TEST cannot create if no worktree structure found
cd $tmpdir/repository
worktree create # CHECKERR: Error: No worktree structure found

worktree init >/dev/null
pwd # CHECK: {{.*}}/repository/repository+main

### TEST cannot create if working directory / staging area is dirty
touch thing
worktree create # CHECKERR: Error: You have uncommitted changes
echo $status # CHECK: 1
rm thing


### TEST create with given branch name
worktree create new-branch
echo $status # CHECK: 0
pwd # CHECK: {{.*}}/repository/repository+new-branch
git branch --show-current # CHECK: new-branch

### TEST create from current branch name
git switch --create fix/slash-branch
worktree create
echo $status # CHECK: 0
pwd # CHECK: {{.*}}/repository/repository%2Fnew-branch
git branch --show-current # CHECK: fix/slash-branch

### TEST cannot create without given branch name if there already is a worktree for the current branch
cd $tmpdir/repository/repository+new-branch
worktree create # CHECKERR: Error: Worktree for branch new-branch already exists
echo $status # CHECK: 1

worktree switch main
worktree create # CHECKERR: Error: Worktree for branch main already exists
echo $status # CHECK: 1

worktree switch review
worktree create # CHECKERR: Error: Worktree for branch parking/review already exists
echo $status # CHECK: 1

worktree switch work
worktree create # CHECKERR: Error: Worktree for branch parking/work already exists
echo $status # CHECK: 1

### TEST have created 5 worktrees in expected locations
git worktree list
# CHECK: {{.*}}/repository/repository+main{{.*}} [main]
# CHECK: {{.*}}/repository/repository+review{{.*}} [parking/review]
# CHECK: {{.*}}/repository/repository+work{{.*}} [parking/work]

### Teardown
cleanup_test_repo $tmpdir

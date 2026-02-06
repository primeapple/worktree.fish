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
worktree switch work
pwd # CHECK: {{.*}}/repository/repository+work
git branch --show-current # CHECK: parking/work

### TEST create from current branch name
git switch --quiet --create very-new-branch
worktree create
echo $status # CHECK: 0
pwd # CHECK: {{.*}}/repository/repository+very-new-branch
git branch --show-current # CHECK: very-new-branch

### TEST create worktree with slash
worktree create fix/slash/branch
echo $status # CHECK: 0
pwd # CHECK: {{.*}}/repository/repository+fix%2Fslash%2Fbranch
git branch --show-current # CHECK: fix/slash/branch

### TEST create worktree with plus
worktree create plus+branch+work
echo $status # CHECK: 0
pwd # CHECK: {{.*}}/repository/repository+plus+branch+work
git branch --show-current # CHECK: plus+branch+work

### TEST cannot create without given branch name if there already is a worktree for the current branch
cd $tmpdir/repository/repository+new-branch
worktree create # CHECKERR: Error: Can only create worktree from current branch from default worktrees (main review work)
echo $status # CHECK: 1

worktree switch main
worktree create # CHECKERR: Error: Can not create worktree from parking branches (main parking/review parking/work)
echo $status # CHECK: 1

worktree switch review
worktree create # CHECKERR: Error: Can not create worktree from parking branches (main parking/review parking/work)
echo $status # CHECK: 1

worktree switch work
worktree create # CHECKERR: Error: Can not create worktree from parking branches (main parking/review parking/work)
echo $status # CHECK: 1

### TEST have created 6 worktrees in expected locations with expected branches
git worktree list
# CHECK: {{.*}}/repository/repository+main{{.*}} [main]
# CHECK: {{.*}}/repository/repository+fix%2Fslash%2Fbranch{{.*}} [fix/slash/branch]
# CHECK: {{.*}}/repository/repository+new-branch{{.*}} [new-branch]
# CHECK: {{.*}}/repository/repository+plus+branch+work{{.*}} [plus+branch+work]
# CHECK: {{.*}}/repository/repository+review{{.*}} [parking/review]
# CHECK: {{.*}}/repository/repository+very-new-branch{{.*}} [very-new-branch]
# CHECK: {{.*}}/repository/repository+work{{.*}} [parking/work]

### Teardown
cleanup_test_repo $tmpdir

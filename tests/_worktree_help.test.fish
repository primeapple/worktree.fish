# RUN: %fish %s

worktree help
# CHECK: Usage: worktree <command>
# CHECK: 
# CHECK: Available commands:
# CHECK:   clean          Remove all non-dirty worktrees except main, review and work
# CHECK:   create         Create a new worktree
# CHECK:   help           Show this help message
# CHECK:   init           Initialize worktree structure
# CHECK:   park           Resets to default branch on the special worktrees and updates them
# CHECK:   reset          Resets worktree structure
# CHECK:   switch         Switch between worktrees
# CHECK:   switch main    Switch to main worktree
# CHECK:   switch review  Switch to review worktree
# CHECK:   switch work    Switch to work worktree

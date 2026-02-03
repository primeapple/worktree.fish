# RUN: %fish %s

worktree
# CHECK: Usage: worktree <command>
# CHECK: 
# CHECK: Available commands:
# CHECK:   create         Create a new worktree
# CHECK:   help           Show this help message
# CHECK:   init           Initialize worktree configuration
# CHECK:   park           Resets to default branch on the special worktrees and updates them
# CHECK:   review         Switch to review worktree
# CHECK:   switch         Switch between worktrees
# CHECK:   switch main    Switch to main worktree
# CHECK:   switch review  Switch to review worktree
# CHECK:   switch work    Switch to work worktree

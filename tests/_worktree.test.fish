# RUN: %fish %s

worktree
# CHECK: Usage: worktree <command>
# CHECK: 
# CHECK: Available commands:
# CHECK:   init           Initialize worktree configuration
# CHECK:   create         Create a new worktree
# CHECK:   switch         Switch between worktrees
# CHECK:   switch main    Switch to main worktree
# CHECK:   switch review  Switch to main worktree
# CHECK:   switch work    Switch to main worktree
# CHECK:   review         Switch to review worktree
# CHECK:   work           Switch to work worktree
# CHECK:   help           Show this help message

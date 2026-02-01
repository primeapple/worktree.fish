function _worktree_init
    exit 1
end

function _worktree_create
    exit 1
end

function _worktree_switch
    exit 1
end

function _worktree_help
    echo "Usage: worktree <command>"
    echo ""
    echo "Available commands:"
    echo "  init      Initialize worktree configuration"
    echo "  create    Create a new worktree"
    echo "  main      Switch to main worktree"
    echo "  review    Switch to review worktree"
    echo "  work      Switch to work worktree"
    echo "  help      Show this help message"
end

function worktree --argument-names subcommand --description "Manage git worktrees"
    switch $subcommand
        case init
            _worktree_init
        case create
            _worktree_create
        case main review work
            _worktree_switch $subcommand
        case '*'
            _worktree_help
    end
end

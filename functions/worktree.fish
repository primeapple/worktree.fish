function __worktree_check_git_repo
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository" >&2
        return 1
    end
    return 0
end

function __worktree_get_default_branch
    if git rev-parse --verify refs/remotes/origin/HEAD >/dev/null 2>&1
        git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | string replace refs/remotes/origin/ ''
    else if git rev-parse --verify refs/heads/main >/dev/null 2>&1
        echo main
    else if git rev-parse --verify refs/heads/master >/dev/null 2>&1
        echo master
    else
        echo "Error: Could not determine default branch" >&2
        return 1
    end
end

function __worktree_check_clean_working_tree
    if test -n "$(git status --porcelain)"
        echo "Error: You have uncommitted changes" >&2
        return 1
    end
    return 0
end

function __worktree_check_on_default_branch --argument-names default_branch
    set -l current_branch (git branch --show-current)
    if test "$current_branch" != "$default_branch"
        echo "Error: Not on default branch ($default_branch). Current branch: $current_branch" >&2
        return 1
    end
    return 0
end

function __worktree_check_in_worktree_structure
    if git worktree list | grep --quiet "+main "
        and git worktree list | grep --quiet "+review "
        and git worktree list | grep --quiet "+work "
        return 0
    end

    return 1
end

function _worktree_init
    # Check if in git repository
    __worktree_check_git_repo
    or return 1

    set -l git_root (git rev-parse --show-toplevel)
    cd "$git_root"

    # Check for uncommitted changes
    __worktree_check_clean_working_tree
    or return 1

    # Check if already in a worktree structure
    if __worktree_check_in_worktree_structure
        echo "Error: Already in a worktree structure" >&2
        return 1
    end

    # Get default branch
    set -l default_branch (__worktree_get_default_branch)
    or return 1

    # Check we're on default branch
    __worktree_check_on_default_branch "$default_branch"
    or return 1

    set -l original_name (basename "$git_root")
    set -l parent_dir (dirname "$git_root")
    set -l new_main_name "$original_name+$default_branch"

    # Move to parent directory
    cd "$parent_dir"

    # Rename original directory to name+branch format
    mv "$original_name" "$new_main_name"

    # Create new original directory
    mkdir "$original_name"

    # Move renamed directory into new original directory
    mv "$new_main_name" "$original_name/"

    # Change to the main worktree directory
    cd "$original_name/$new_main_name"

    for worktree_name in work review
        set -l branch_name "parking/$worktree_name"
        set -l worktree_dir "../$original_name+$worktree_name"

        # Create branch if it doesn't exist
        if not git rev-parse --verify "$branch_name" >/dev/null 2>&1
            git branch "$branch_name"
        end

        git worktree add --quiet "$worktree_dir" "$branch_name"
    end

    echo "Git worktree setup complete!"
    echo "Structure created:"
    echo "  $original_name/"
    echo "    ├── $new_main_name ($default_branch branch)"
    echo "    ├── $original_name+work (parking/work branch)"
    echo "    ├── $original_name+review (parking/review branch)"
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

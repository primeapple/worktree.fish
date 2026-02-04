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

function __worktree_get_git_root
    git rev-parse --show-toplevel
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

    echo "Error: No worktree structure found" >&2
    return 1
end

function __worktree_get_current_worktree_path
    git rev-parse --show-toplevel | git worktree list | grep (__worktree_get_git_root) | awk '{print $1}'
end

function __worktree_get_worktree_name_suffix --argument-names path
    if not set -q path
        exit 2
    end
    basename $path | awk -F+ '{print $NF}'
end

function _worktree_init
    __worktree_check_git_repo
    or return 1

    set -l git_root (__worktree_get_git_root)
    cd "$git_root"

    # Check for uncommitted changes
    __worktree_check_clean_working_tree
    or return 1

    # Check if already in a worktree structure
    if __worktree_check_in_worktree_structure 2>/dev/null
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

function _worktree_park
    __worktree_check_git_repo
    or return 1

    __worktree_check_in_worktree_structure
    or return 1

    __worktree_check_clean_working_tree
    or return 1

    set -l worktree_suffix (__worktree_get_worktree_name_suffix (__worktree_get_current_worktree_path))
    if not contains $worktree_suffix main review work
        echo "Error: Can only park the default worktrees (main review work)" >&2
        return 1
    end

    set -l default_branch (__worktree_get_default_branch)
    switch $worktree_suffix
        case main
            git switch (__worktree_get_default_branch) 2>/dev/null
        case review
            git switch parking/$worktree_suffix 2>/dev/null
        case work
            git switch parking/$worktree_suffix 2>/dev/null
    end

    if git ls-remote --tags >/dev/null 2>/dev/null
        git fetch >/dev/null 2>/dev/null
        git reset --hard origin/$default_branch
        echo "Info: Reset to origin/$default_branch"
    else
        echo "Warning: No remote found, not resetting to latest remote default branch" >&2
    end
end

function _worktree_clean
    _worktree_switch work
    or return 1

    git worktree prune

    for worktree_path in (git worktree list | awk '{print $1}')
        if contains (__worktree_get_worktree_name_suffix $worktree_path) main review work
            continue
        end

        pushd "$worktree_path"
        set is_clean (__worktree_check_clean_working_tree 2>/dev/null && echo 0 || echo 1)
        popd

        if test $is_clean -eq 0
            echo "Info: Removing worktree $worktree_path"
            git worktree remove "$worktree_path"
        else
            echo "Warning: Can not remove dirty worktree $worktree_path" >&2
        end
    end
end

function _worktree_switch --argument-names location
    __worktree_check_git_repo
    or return 1

    __worktree_check_in_worktree_structure
    or return 1

    switch $location
        case main
            cd (git worktree list | grep '+main' | awk '{print $1}')
            return 0
        case review
            cd (git worktree list | grep '+review' | awk '{print $1}')
            return 0
        case work
            cd (git worktree list | grep '+work' | awk '{print $1}')
            return 0
    end

    # TODO open worktrees in fzf/zf/...
end

function _worktree_help
    echo "Usage: worktree <command>"
    echo ""
    echo "Available commands:"
    echo "  clean          Remove all clean worktrees except main, review, and work"
    echo "  create         Create a new worktree"
    echo "  help           Show this help message"
    echo "  init           Initialize worktree configuration"
    echo "  park           Resets to default branch on the special worktrees and updates them"
    echo "  review         Switch to review worktree"
    echo "  switch         Switch between worktrees"
    echo "  switch main    Switch to main worktree"
    echo "  switch review  Switch to review worktree"
    echo "  switch work    Switch to work worktree"
end

function worktree --argument-names subcmd1 subcmd2 --description "Manage git worktrees"
    switch $subcmd1
        case clean
            _worktree_clean
        case create
            _worktree_create
        case init
            _worktree_init
        case park
            _worktree_park
        case switch
            _worktree_switch $subcmd2
        case '*'
            _worktree_help
    end
end

# AGENTS.md - Agentic Coding Guidelines for worktree.fish

## Project Overview

A Fish shell plugin providing opinionated convenience functions for managing git worktrees. Worktrees follow the naming convention `REPONAME+BRANCHNAME` and live in a container directory structure.

## Build / Lint / Test Commands

```bash
# Run everything (format, lint, install, test)
make all

# Format all fish files
make fmt
# Or directly: fish_indent --write **.fish

# Lint all fish files (syntax check)
make lint
# Or directly: for file in **.fish; fish --no-execute $file; end

# Install plugin locally (requires fisher)
make install

# Run all tests
make test
# Or directly: python3 littlecheck.py --progress tests/**.test.fish

# Run a single test file
python3 littlecheck.py tests/_worktree_init.test.fish

# Clean up downloaded files
make clean
```

## Project Structure

```
.
├── functions/
│   └── worktree.fish          # Main implementation
├── tests/
│   ├── _test_helpers.fish      # Test utilities
│   ├── worktree.test.fish    # Basic command tests
│   ├── worktree_help.test.fish
│   └── worktree_init.test.fish
├── Makefile                   # Build automation
├── littlecheck.py            # Test runner (downloaded)
└── README.md
```

## Code Style Guidelines

### Naming Conventions

- **Public functions**: `worktree` (main entry point)
- **Private functions**: `_worktree_<name>` (single underscore prefix)
- **Helper functions**: `__worktree_<name>` (double underscore prefix)
- **Test files**: `_<function_name>.test.fish`
- **Variables**: Use `-l` flag for local scope, snake_case

### Function Structure

```fish
function _worktree_example --argument-names arg1 arg2
    # Check preconditions with helpers
    __worktree_check_git_repo
    or return 1
    
    # Use local variables
    set -l local_var "value"
    
    # Error handling: echo to stderr, return non-zero
    if not test -d "$path"
        echo "Error: Directory not found" >&2
        return 1
    end
    
    # Success
    return 0
end
```

### Formatting

- Use `fish_indent` for automatic formatting
- 4-space indentation (enforced by fish_indent)
- No trailing whitespace
- End files with a single newline
- Quote all variable expansions: `"$variable"`

### Error Handling

- Always validate preconditions first
- Use helper functions for common checks (`__worktree_check_git_repo`, etc.)
- Print errors to stderr: `echo "Error: message" >&2`
- Return non-zero exit codes on failure
- Use `or return 1` pattern for early exits

### Git Operations

- Use `--quiet` flag for git commands when possible
- Redirect stderr when checking conditions: `>/dev/null 2>&1`
- Use `git rev-parse --verify` to check if refs exist
- Prefer `string replace` over `sed` for text manipulation

## Testing Guidelines

### Test File Structure

```fish
# RUN: %fish %s

source (dirname (status filename))/_test_helpers.fish

### Setup
set -l tmpdir (setup_test_repo main)
cd $tmpdir/repository

### Execute and verify
worktree init
# CHECK: Expected output line 1
# CHECK: Expected output line 2

### Cleanup
cleanup_test_repo $tmpdir
```

### Test Patterns

- Use `setup_test_repo <branch>` to create temporary git repos
- Use `cleanup_test_repo $tmpdir` for cleanup
- Use `# CHECK:` for stdout assertions
- Use `# CHECKERR:` for stderr assertions
- Use `{{.*}}` regex patterns for variable output
- Test both success and error cases

### Running Single Tests

```bash
# Run specific test file
python3 littlecheck.py tests/_worktree_init.test.fish

# Run with verbose output
python3 littlecheck.py --progress tests/_worktree_init.test.fish
```

## Documentation Resources

When working on this codebase, use the context7 MCP to look up documentation for:

- **ridiculousfish/littlecheck** - Test framework documentation for writing tests
- **websites/fishshell_current** - Fish shell documentation for syntax and built-in functions

To use context7, query the MCP with specific questions about the library or language features you need help with.

## Common Patterns

### Checking Git Repository

```fish
if not git rev-parse --git-dir >/dev/null 2>&1
    echo "Error: Not in a git repository" >&2
    return 1
end
```

### Checking Clean Working Tree

```fish
if test -n "$(git status --porcelain)"
    echo "Error: You have uncommitted changes" >&2
    return 1
end
```

### Using Helper Functions

```fish
__worktree_check_git_repo
or return 1

set -l default_branch (__worktree_get_default_branch)
or return 1
```

## CI/CD

GitHub Actions workflow runs `make all` on every push/PR to main branch.

## Dependencies

- Fish shell 3.0+
- Python 3 (for testing)
- Fisher (for local installation)
- Git

## Key Conventions

1. **Worktree naming**: `REPONAME+BRANCHNAME` (e.g., `myrepo+feature-branch`)
2. **Special parking branches**: `parking/main`, `parking/work`, `parking/review`
3. **URL encoding**: `/` becomes `%2F` in branch names
4. **Container structure**: All worktrees live in a parent directory named after the repo

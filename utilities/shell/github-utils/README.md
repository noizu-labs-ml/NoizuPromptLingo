# github-tools — Git Submodule Workflow Utilities

Interactive tools for managing bulk git operations across repositories with submodules.

## Installation

```bash
make install    # Installs github-tools to ~/.local/bin
```

## Prerequisites

- `git`
- `fzf` — interactive multi-select (`brew install fzf`)

## Configuration

Uses `infra-config.yaml` for shared settings (see [k8-lib README](../k8-lib/README.md)). Every tool accepts `--config <path>` to specify an alternative config file.

The tool auto-detects the git root from the current working directory — no path configuration required. It works in any repository with `.gitmodules`, regardless of where it's installed.

## Tools

| Command | Purpose |
|---------|---------|
| `submodule-commit` | Interactive bulk commit/push for dirty submodules with nested bubbling |

## Usage

```bash
submodule-commit                    # Scan, select via fzf, commit + push
submodule-commit --all              # Commit all dirty submodules (skip fzf)
submodule-commit --dry-run          # Preview planned actions
submodule-commit --no-push          # Commit locally, skip git push
submodule-commit -m "my message"    # Provide commit message non-interactively
submodule-commit --all -m "wip"     # Fully non-interactive
submodule-commit --config my.yaml   # Use specific config file
```

### Workflow

1. **Scan** — recursively walks `.gitmodules` at every nesting level, checks each submodule for staged, modified, and untracked files
2. **Select** — fzf multi-select with TAB to toggle; shows change counts and a `git status --short` preview pane
3. **Commit** — processes deepest-first so nested submodule refs bubble up correctly:
   - `git add .` in the submodule
   - `git commit -m <message>`
   - `git push origin HEAD`
   - `git add <submodule>` in the parent repo
4. **Parent** — after all submodules, offers to commit and push the updated refs in the root repo

### Nested Submodule Handling

If your repo has submodules inside submodules (e.g., `repos/incubator/utilities/devops/k8-lib`), the tool processes them deepest-first. After committing a deeply nested submodule, it stages the updated ref in the parent, so that when the parent is committed next, it captures the new pointer.

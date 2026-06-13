# make-repo

Create a GitHub repo from the current directory and push it — with sensible defaults, parent repo inheritance, and an interactive confirmation step.

## Install

Add `make-repo/bin` to your PATH:

```bash
# In ~/.zshrc or .envrc:
export PATH="$PATH:/path/to/make-repo/bin"
```

## Quick Start

```bash
cd ~/projects/my-cool-thing
make-repo
```

This shows an interactive summary where you can review and edit every field before creating the repo. Press `y` to confirm or a number to edit a field.

```
═══════════════════════════════════════════════
  make-repo
═══════════════════════════════════════════════

  [1] Org:         noizu
  [2] Repo:        my-cool-thing
  [3] Full name:   noizu/my-cool-thing
  [4] Visibility:  private
  [5] Description: No additional details.
  [6] Groups:      (none)

  [y] Confirm and create
  [n] Abort
  [1-6] Edit a field

  >
```

## Precedence

Values are resolved in this order (highest wins):

| Priority | Source | Example |
|----------|--------|---------|
| 1 | CLI flags | `--org my-org` |
| 2 | `_OVERRIDE` env vars | `GH_NEW_REPO_ORG_OVERRIDE=my-org` |
| 3 | Parent repo detection | Inherited from containing git repo's GitHub remote |
| 4 | Base env vars | `GH_NEW_REPO_ORG=my-org` |
| 5 | Built-in defaults | `noizu`, `private` |

### Parent Repo Inheritance

When run inside a subdirectory of an existing GitHub repo (or a submodule), `make-repo` automatically inherits the parent's **org** and **visibility**. Use `--no-inherit` to skip this.

## CLI Flags

| Flag | Description |
|------|-------------|
| `--org NAME` | GitHub org or user |
| `--repo NAME` | Repo name (default: current folder) |
| `--prefix STR` | Prepend `STR-` to repo name |
| `--no-prefix` | Ignore `GH_NEW_REPO_PREFIX` |
| `--no-inherit` | Skip parent repo detection |
| `--description TEXT` | Repo description |
| `--public` | Create as public |
| `--private` | Create as private (default) |
| `--groups LIST` | Comma-separated teams, optional `:role` suffix |
| `--group-role ROLE` | Default team role (default: `push`) |
| `--yes`, `-y` | Skip confirmation prompt |
| `--edit` | Edit an existing repo (visibility, description, teams) |
| `--dry-run` | Show resolved values without creating anything |
| `--help`, `-h` | Show usage |

## Environment Variables

### Base (lowest priority after defaults)

| Variable | Description |
|----------|-------------|
| `GH_NEW_REPO_ORG` | Default org (default: `noizu`) |
| `GH_NEW_REPO_PREFIX` | Prefix prepended to repo name |
| `GH_NEW_REPO_NAME` | Override repo name |
| `GH_NEW_REPO_DESC` | Repo description |
| `GH_NEW_REPO_PUBLIC` | Set to any value for public visibility |
| `GH_NEW_REPO_GROUPS` | Comma-separated teams |
| `GH_NEW_REPO_GROUP_ROLE` | Default role for teams (default: `push`) |

### Overrides (beat parent detection)

| Variable | Description |
|----------|-------------|
| `GH_NEW_REPO_ORG_OVERRIDE` | Force org |
| `GH_NEW_REPO_PREFIX_OVERRIDE` | Force prefix |
| `GH_NEW_REPO_NAME_OVERRIDE` | Force repo name |
| `GH_NEW_REPO_DESC_OVERRIDE` | Force description |
| `GH_NEW_REPO_PUBLIC_OVERRIDE` | `1` = public, `0` = private |
| `GH_NEW_REPO_GROUPS_OVERRIDE` | Force team list |

## Examples

```bash
# Defaults: noizu/<folder>, private
make-repo

# Specific org, public
make-repo --org the-robot-lives --public

# With prefix: noizu/libs-my-thing
GH_NEW_REPO_PREFIX=libs make-repo

# Grant team access with mixed roles
make-repo --groups "devs,ops:admin,interns:pull"

# Skip confirmation for scripting
make-repo --yes --org my-org --repo my-repo

# Preview without creating
make-repo --dry-run

# Inside a submodule — inherits parent org + visibility
cd projects/cool-submodule
make-repo    # org and visibility from parent

# Edit an existing repo — interactive menu
make-repo --edit

# Edit with flags (no prompt)
make-repo --edit --public --description "Updated desc" --yes

# Add team access to existing repo
make-repo --edit --groups "devs,ops:admin" --yes
```

## Editing Existing Repos

`--edit` mode lets you modify an existing repo's visibility, description, and team access. It fetches the current settings from GitHub and presents an interactive menu:

```
═══════════════════════════════════════════════
  make-repo --edit
═══════════════════════════════════════════════

  Editing: noizu/my-cool-thing

  [1] Visibility:  private (current: private)
  [2] Description: My cool thing
  [3] Groups:      (none — add teams)

  [y] Apply changes
  [n] Abort
  [1-3] Edit a field

  >
```

Only changed fields are updated. Combine with `--yes` and flags to script edits without prompts.

## Prerequisites

- [GitHub CLI (`gh`)](https://cli.github.com/) — `brew install gh`
- Authenticated: `gh auth login`
- Org membership with repo creation permissions

## Description Generation

The description field defaults to a placeholder. The `generate_description()` function is stubbed for future integration with a CLI AI tool (e.g., `claude`, `gh copilot`) to auto-generate descriptions from repo contents.

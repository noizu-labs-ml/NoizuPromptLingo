# git-tree - Detailed Reference

Git-aware directory tree viewer that respects `.gitignore` rules.

## Synopsis

```bash
git-tree [target-folder]
```

## Arguments

| Argument | Default | Description |
|:---------|:--------|:------------|
| `target-folder` | `.` (current directory) | Directory path relative to repository root |

## How It Works

1. **Validation**: Confirms execution is inside a Git repository via `git rev-parse --is-inside-work-tree`
2. **Root detection**: Locates repository root with `git rev-parse --show-toplevel`
3. **File enumeration**: Uses `git ls-files` with flags:
   - `--cached`: Include tracked files
   - `--others`: Include untracked files
   - `--exclude-standard`: Apply `.gitignore`, `.git/info/exclude`, and global excludes
4. **Rendering**: Pipes file list to `tree --fromfile` or falls back to built-in AWK renderer

### Git ls-files Flags Explained

```bash
git -c core.quotepath=false ls-files --cached --others --exclude-standard -- "$TARGET"
```

| Flag | Effect |
|:-----|:-------|
| `-c core.quotepath=false` | Preserve Unicode filenames without escaping |
| `--cached` | Show staged/tracked files |
| `--others` | Show untracked files |
| `--exclude-standard` | Apply all ignore rules |

## Tree Rendering

### Primary: tree command

When `tree` is installed, the script uses:

```bash
tree --fromfile
```

This reads file paths from stdin and renders a tree structure.

### Fallback: AWK renderer

When `tree` is unavailable, an embedded AWK script renders the tree:

```
.
├── core
│   ├── scripts
│   │   └── git-tree
```

**Limitations of fallback renderer:**
- Uses `├──` for all entries (no `└──` for last items)
- Less refined visual alignment than native `tree`
- Functional but aesthetically inferior

## Examples

### Basic usage

```bash
# Tree of entire repository
git-tree

# Tree of specific directory
git-tree src/components

# Tree of nested path
git-tree deployments/impact-simulation
```

### Integration with other tools

```bash
# Count files in a directory
git-tree src | grep -c "──"

# Pipe to file for documentation
git-tree > docs/structure.txt

# Use in scripts
if git-tree lib 2>/dev/null | grep -q "utils"; then
  echo "Utils directory exists"
fi
```

### Combining with dump-files

```bash
# Preview structure, then dump contents
git-tree src/api
dump-files src/api
```

## Edge Cases

### Empty directories

Git does not track empty directories. `git-tree` shows only directories containing files.

### Symbolic links

Tracked symlinks appear in output. Broken symlinks excluded by `.gitignore` do not appear.

### Submodules

Submodule root directories appear, but submodule contents require running `git-tree` inside the submodule.

### Large repositories

For repositories with thousands of files, output may be extensive. Consider targeting specific directories:

```bash
# Instead of
git-tree  # entire repo

# Target specific areas
git-tree src/core
```

### Unicode filenames

The `-c core.quotepath=false` flag ensures filenames with Unicode characters display correctly rather than being escaped.

## Exit Codes

| Code | Condition |
|:-----|:----------|
| 0 | Success |
| 1 | Not inside a Git repository |

## Error Messages

**"Error: not inside a git repository."**
: Script executed outside a Git working tree. Navigate to a repository or clone one.

## Implementation Notes

### Shell options

```bash
set -euo pipefail
```

| Option | Effect |
|:-------|:-------|
| `-e` | Exit on error |
| `-u` | Error on undefined variables |
| `-o pipefail` | Propagate pipe failures |

### Working directory

The script changes to repository root before executing `git ls-files`. This ensures consistent behavior regardless of where the script is invoked from within the repository.

## Dependencies

| Dependency | Required | Notes |
|:-----------|:---------|:------|
| Git | Yes | Core functionality |
| tree | No | Fallback provided if missing |
| awk | No | Used only in fallback mode |

## Comparison with Related Tools

| Tool | Purpose | Git-aware |
|:-----|:--------|:----------|
| `git-tree` | Tree view respecting `.gitignore` | Yes |
| `tree` | Generic directory tree | No |
| `git-tree-depth` | Tree with depth indicators | Yes |
| `ls -R` | Recursive listing | No |

## See Also

- [git-tree.md](./git-tree.md) - Quick reference
- [dump-files.md](./dump-files.md) - Dump file contents
- [git-tree-depth.md](./git-tree-depth.md) - Tree with depth levels

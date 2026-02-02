# User Story: Explore Project File Structure

**ID**: US-025
**Persona**: P-001 (AI Agent)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **explore project file structure respecting .gitignore**,
So that **I understand the codebase layout before making changes**.

## Acceptance Criteria

- [ ] Can display directory tree from any path using `git-tree` command
- [ ] Respects .gitignore patterns automatically via git ls-files
- [ ] Can dump file contents from a directory using `git-dump` command
- [ ] Outputs structured, parseable format (tree format for directories, delimited for file dumps)
- [ ] Handles large directories efficiently via git index
- [ ] Provides Unicode box-drawing characters for visual tree representation
- [ ] Falls back to pure Python implementation if external `tree` command unavailable

## Notes

- First step in understanding a new codebase
- Automatically excludes build artifacts, node_modules, etc. via .gitignore
- Uses git ls-files for efficient filtering
- Console scripts installed via pyproject.toml: `git-tree` and `git-dump`
- Both tools use shared helpers from `tools/lib/git_helpers.py`

## Dependencies

- Git repository (required - uses `git ls-files`)
- Optional: `tree` command for enhanced rendering (falls back to pure Python)
- `tools/lib/git_helpers.py` - Shared helper functions

## Open Questions

- Should depth limiting be added to git-tree in the future?
- Hidden files are already handled via git ls-files (respects .gitignore)

## Related Commands

Console scripts (installed via pyproject.toml):
- `git-tree [target]` - Display directory tree (uses `tools/git_tree.py`)
- `git-dump <target>` - Dump file contents from directory (uses `tools/git_dump.py`)

Example usage:
```bash
git-tree src/npl_mcp          # Show tree of npl_mcp package
git-dump src/npl_mcp/web      # Dump all files in web module
git-tree .                    # Show entire repository tree
```

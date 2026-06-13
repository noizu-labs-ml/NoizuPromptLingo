# Search & Discovery Summary

## Quick Reference

| Tool | Purpose | Required Params | Optional Params |
|------|---------|-----------------|-----------------|
| **Glob** | Find files by pattern | `pattern` | `path` |
| **Grep** | Search file contents | `pattern` | `path`, `glob`, `type`, `output_mode`, `-i`, `-A/-B/-C`, `multiline`, `head_limit`, `offset` |

## Decision Guide

**Use Glob when:**
- Finding files by name/extension (`**/*.py`, `**/test_*.py`)
- You know the filename pattern
- Need fast file discovery

**Use Grep when:**
- Searching for code, functions, variables
- Finding TODO/FIXME comments
- Need to see where something is used
- Searching file contents

## Glob Essentials

**Common patterns:**
```
**/*.py          # All Python files recursively
src/**/*.ts      # TypeScript files under src/
**/test_*.py     # All test files
*.{js,ts}        # JS or TS in current dir
```

**Key points:**
- Very fast, works on any codebase size
- Results sorted by modification time
- For content search, use Grep

## Grep Essentials

**Output modes:**
- `files_with_matches` - Just file paths (default, fastest)
- `content` - Matching lines with context
- `count` - Match counts per file

**Common patterns:**
```json
{"pattern": "def hello", "output_mode": "files_with_matches"}
{"pattern": "TODO", "type": "py", "output_mode": "content"}
{"pattern": "import FastMCP", "output_mode": "content", "-C": 3}
{"pattern": "error", "-i": true, "output_mode": "content"}
```

**Key points:**
- Uses ripgrep syntax (not grep)
- Default is single-line matching
- Use `multiline: true` for cross-line patterns
- Literal braces need escaping: `"interface\\{\\}"` to match `interface{}`
- Much faster than bash grep

**Context options:**
- `-A`: Lines after match
- `-B`: Lines before match
- `-C`: Lines before and after match

**Regex tips:**
- `\bword\b` - Match whole word only
- `^pattern` - Match at start of line
- `(A|B|C)` - Match alternatives
- Double-escape special chars in JSON: `\\.` → `\\\\.`
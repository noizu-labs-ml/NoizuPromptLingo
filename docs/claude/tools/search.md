# Search & Discovery

## Glob

**Purpose**: Fast file pattern matching using glob patterns.

**When to use**:
- Finding files by name or extension
- Locating configuration files
- Discovering test files
- Building file lists

**Parameters**:
- `pattern` (required): Glob pattern
- `path` (optional): Directory to search (defaults to current working directory)

**Usage**:

Find all Python files:
```json
{
  "pattern": "**/*.py"
}
```

Find test files:
```json
{
  "pattern": "**/test_*.py"
}
```

Find in specific directory:
```json
{
  "pattern": "*.ts",
  "path": "/path/to/src"
}
```

**Common patterns**:
- `**/*.py` - All Python files recursively
- `src/**/*.ts` - TypeScript files under src/
- `**/test_*.py` - All test files
- `*.{js,ts}` - JS or TS files in current dir (brace expansion supported)
- `**/README.md` - All README files

**Key points**:
- Results sorted by modification time (most recently modified first)
- Very fast, works on any codebase size
- Use for known file patterns
- For content search, use Grep instead
- When doing open-ended searches requiring multiple rounds, use the Agent tool instead
- Can make multiple Glob calls in parallel for speculative searches

---

## Grep

**Purpose**: Search file contents using regex patterns (powered by ripgrep).

**When to use**:
- Finding where code is used
- Searching for function definitions
- Locating configuration values
- Finding TODO comments

**Parameters**:
- `pattern` (required): Regex pattern
- `path` (optional): File/directory to search (defaults to current working directory)
- `glob` (optional): Filter files (e.g., "*.py", "*.{ts,tsx}")
- `type` (optional): File type (js, py, rust, go, java, etc.) - more efficient than glob for standard types
- `output_mode` (optional): "content", "files_with_matches" (default), "count"
- `-i` (optional): Case insensitive
- `-n` (optional): Show line numbers (default: true, only with content mode)
- `-A`, `-B`, `-C` (optional): Context lines after/before/both (only with content mode)
- `multiline` (optional): Enable multiline mode where . matches newlines (default: false)
- `head_limit` (optional): Limit output to first N lines/entries (works in all modes, default: 0 = unlimited)
- `offset` (optional): Skip first N lines/entries before applying head_limit (default: 0)

**Usage**:

Find function definitions:
```json
{
  "pattern": "def hello",
  "output_mode": "files_with_matches"
}
```

Search with context:
```json
{
  "pattern": "import FastMCP",
  "output_mode": "content",
  "-C": 3
}
```

Search specific file types:
```json
{
  "pattern": "TODO",
  "type": "py",
  "output_mode": "content"
}
```

Case insensitive:
```json
{
  "pattern": "error",
  "-i": true,
  "output_mode": "content"
}
```

**Output modes**:
- `files_with_matches` - Just file paths (default, fastest, supports head_limit)
- `content` - Matching lines with context (supports -A/-B/-C, -n, head_limit)
- `count` - Match counts per file (supports head_limit)

**Count mode example**:
```json
{
  "pattern": "TODO",
  "output_mode": "count"
}
```
Returns results like:
```
src/auth.py: 3
src/main.py: 1
tests/test_auth.py: 5
```

**Key points**:
- Uses ripgrep syntax (not grep)
- ALWAYS use Grep tool for search, NEVER invoke `grep` or `rg` via Bash
- Literal braces need escaping: see below
- Default is single-line matching (patterns match within single lines only)
- Use `multiline: true` for cross-line patterns (e.g., `struct \{[\s\S]*?field`)
- Much faster than bash grep
- Can make multiple Grep calls in parallel for speculative searches
- Use Task tool for open-ended searches requiring multiple rounds

**Escape sequences**:

Ripgrep uses standard regex syntax. Literal braces need escaping:

| What you want to match | Pattern syntax | Example |
|------------------------|----------------|---------|
| `interface{}` (Go) | `interface\{\}` | Find Go empty interfaces |
| `file.ext` (literal dot) | `file\.ext` | Match exact filename |
| `[test]` (literal brackets) | `\[test\]` | Match literal brackets |
| `function()` (parens) | `function\(\)` | Match empty function call |

**Note**: When using JSON tool calls, backslashes must be escaped in the JSON string. So `interface\{\}` becomes `"pattern": "interface\\{\\}"` in JSON.

**Common regex patterns**:

| Pattern | Purpose | Example |
|---------|---------|---------|
| `\bword\b` | Match whole word only | Matches "TODO" but not "TODOITEM" |
| `def\s+\w+\(` | Match function definition | Matches "def my_func(" in Python |
| `^import\|^from` | Match at start of line | Matches import statements |
| `(TODO\|FIXME\|HACK)` | Match any alternative | Matches any of these markers |
| `class\s+\w+` | Match class definition | Matches "class MyClass" |
| `log.*Error` | Match with wildcards | Matches "logError", "log.Error", etc. |

**Multiline example**:
```json
{
  "pattern": "struct \\{[\\s\\S]*?myField",
  "multiline": true,
  "output_mode": "content"
}
```
This finds struct definitions containing "myField" across multiple lines.
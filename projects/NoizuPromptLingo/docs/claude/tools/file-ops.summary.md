# File Operations Summary

| Tool | Purpose | Required Params | When to Use |
|------|---------|-----------------|-------------|
| **Read** | View file contents | `file_path` | Before editing/writing; examining code, config, docs |
| **Write** | Create/overwrite file | `file_path`, `content` | New files; **NOT for editing existing files** |
| **Edit** | Exact string replacement | `file_path`, `old_string`, `new_string` | Modifying existing code/config |

## Critical Rules

1. **Always use absolute paths** (relative paths will error)
2. **MUST Read before Edit** (to see exact formatting)
3. **MUST Read before Write if file exists** (prevents accidental overwrites)
4. **Write is destructive** (replaces entire file with no undo)
5. **Prefer Edit over Write** for existing files

## Tool Selection Guide

```
Need to modify existing file? → Read + Edit
Need to create new file?      → Write
File already exists?           → Read first, then Edit
Unsure if file exists?         → Read first (errors are ok), then choose
```

## Common Patterns

### Modify existing code
1. Read file to see exact content
2. Copy exact text including whitespace
3. Edit with precise old_string/new_string

### Create new file
1. Verify parent directory exists (optional)
2. Write with complete content

### Rename variable across file
1. Read file first
2. Edit with `replace_all: true`

## Edit Gotchas

- **old_string must match exactly**: case, spaces/tabs, line endings
- **Ignore line number prefixes** from Read output (format: `spaces + number + tab + content`)
- **Preserve indentation** from actual file content (after the line number prefix)
- **Edit fails if old_string not unique** unless `replace_all: true`

## Media Support

| Format | Read Support |
|--------|--------------|
| Text files | ✅ Full (with line numbers) |
| Images (PNG, JPG) | ✅ Visual analysis |
| PDFs | ✅ Text extraction (page-by-page) |
| Jupyter notebooks | ✅ All cells + outputs |
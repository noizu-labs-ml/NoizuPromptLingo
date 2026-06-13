# File Operations

## Read

**Purpose**: Read file contents from the filesystem.

**When to use**:
- Need to examine existing code before refactoring or adding functionality
- Review configuration files (YAML, JSON, TOML)
- Check documentation or README files
- Inspect test files before modifying
- View images, PDFs, or Jupyter notebooks

**Parameters**:
- `file_path` (required): Absolute path to file
- `offset` (optional): Line number to start reading from
- `limit` (optional): Number of lines to read

**Getting absolute paths**:

If you only have a relative path like `src/main.py`, construct the absolute path using the working directory:
- Current working directory is shown in the environment context at the start of each conversation
- Combine with relative path: `/absolute/working/dir/src/main.py`
- Verify path exists first using Glob or Bash `ls`

**Usage**:
```json
{
  "file_path": "/absolute/path/to/file.py"
}
```

**With pagination** (for large files):
```json
{
  "file_path": "/absolute/path/to/large_file.py",
  "offset": 100,
  "limit": 50
}
```

**Pagination guidance**:
- Use 100-200 lines per chunk for good balance between context and speed
- Smaller chunks (50-100) are faster but reduce surrounding context
- Larger chunks (200-500) give more context but may hit output limits

**Key points**:
- Always use absolute paths (required)
- Files are returned with line numbers (cat -n format, starting at 1)
- Can read images, PDFs, Jupyter notebooks
- Lines longer than 2000 chars are truncated
- Default reads up to 2000 lines from beginning of file
- **MUST read a file before editing it** (Edit and Write will fail otherwise)

**Media type capabilities & limitations**:

| Format | Notes | Limitations |
|--------|-------|-------------|
| **Images** | PNG, JPG, GIF, etc. can be read and visually analyzed | Cannot extract embedded text (OCR not supported). Large images may be truncated. |
| **PDFs** | Text is extracted page by page | Scanned/image-based PDFs return minimal content. Page count limits may apply to very long documents. |
| **Jupyter notebooks** | All cells (code + outputs) are displayed | Metadata and cell states beyond visible output are not preserved. |

---

## Write

**Purpose**: Create a new file or completely overwrite an existing file.

**When to use**:
- Creating new files from scratch
- Completely replacing existing file contents (destructive operation)
- **NOT for editing existing files** (use Edit instead)

**⚠️ Warning**: Write completely overwrites files with no undo. Always prefer Edit for modifications.

**Parameters**:
- `file_path` (required): Absolute path
- `content` (required): Complete file contents

**Usage**:
```json
{
  "file_path": "/absolute/path/to/new_file.py",
  "content": "#!/usr/bin/env python3\n\ndef main():\n    print('Hello')\n"
}
```

**Critical rules**:
- **MUST use Read first if file already exists** (tool will fail otherwise)
- Reading first confirms file exists, prevents accidental overwrites, and provides rollback context
- **Prefer Edit over Write for existing files** (Edit is safer and more precise)
- **Never create documentation files (.md, README) proactively** (only with explicit user request)
- **Use absolute paths only** (required)

---

## Edit

**Purpose**: Make exact string replacements in existing files.

**When to use**:
- Modifying existing code
- Updating configuration
- Fixing bugs
- Adding features to existing files

**Parameters**:
- `file_path` (required): Absolute path to file
- `old_string` (required): Exact text to replace (must match character-for-character)
- `new_string` (required): Replacement text (must be different from old_string)
- `replace_all` (optional, default: false): Replace all occurrences

**What "exact match" means**:

The match is sensitive to:
- **Case**: `def hello(` ≠ `def Hello(`
- **Whitespace**: `return 'Hi'` (4 spaces) ≠ `return 'Hi'` (2 spaces)
- **Character type**: Regular space (` `) ≠ non-breaking space (`\u00A0`)
- **Tabs vs spaces**: Consistent indentation matters
- **Trailing newlines**: Whether the string ends with `\n` or not

Example where match fails:
```
File contains:  "def hello():\n    return 'Hi'\n"  (LF line endings)
old_string:    "def hello():\r\n    return 'Hi'\r\n"  (CRLF line endings)
Result:        Match fails due to line ending difference
```

**Usage**:
```json
{
  "file_path": "/path/to/file.py",
  "old_string": "def hello():\n    return 'Hi'",
  "new_string": "def hello(name: str):\n    return f'Hi {name}'"
}
```

**Replace all occurrences**:
```json
{
  "file_path": "/path/to/file.py",
  "old_string": "old_var_name",
  "new_string": "new_var_name",
  "replace_all": true
}
```

**Critical rules**:
- **MUST use Read first** (tool will fail otherwise)
- **Preserve exact indentation** from Read output (spaces vs tabs matter)
- **Ignore line number prefixes** when copying from Read output (format: `line_number→content`)
- **`old_string` must be unique** unless using `replace_all=true`
- **Edit will FAIL if**:
  - File not read first
  - `old_string` not found in file
  - `old_string` appears multiple times and `replace_all=false`
  - `new_string` equals `old_string`

**Troubleshooting: Why Edit fails even after Read**

| Symptom | Cause | Solution |
|---------|-------|----------|
| "old_string not found" | Copied from different file with similar content | Re-Read the exact file you're editing |
| "old_string not found" | Line endings changed (CRLF vs LF) | Check Read output for `^M` (CR) characters; include `\r\n` in your old_string if visible |
| "old_string not found" | File modified by another editor after Read | Re-Read to get current state |
| "old_string not found" | Unicode normalization differences | Ensure you're copying exact characters from Read output |

---

## NotebookEdit

**Purpose**: Edit cells in Jupyter notebook (.ipynb) files.

**When to use**:
- Modifying code cells in Jupyter notebooks
- Updating markdown cells in notebooks
- Adding new cells to notebooks
- Deleting cells from notebooks

**Parameters**:
- `notebook_path` (required): Absolute path to .ipynb file
- `new_source` (required): New source code/markdown for the cell
- `cell_id` (optional): ID of cell to edit (for replace) or insert after (for insert mode)
- `cell_type` (optional): "code" or "markdown" (required for insert mode)
- `edit_mode` (optional, default: "replace"): "replace", "insert", or "delete"

**Edit modes**:
- **replace** (default): Replace cell content at `cell_id`
- **insert**: Add new cell after `cell_id` (or at beginning if not specified)
- **delete**: Remove cell at `cell_id`

**Usage examples**:

Replace cell content:
```json
{
  "notebook_path": "/path/to/notebook.ipynb",
  "cell_id": "abc123",
  "new_source": "import pandas as pd\ndf = pd.read_csv('data.csv')"
}
```

Insert new code cell:
```json
{
  "notebook_path": "/path/to/notebook.ipynb",
  "cell_id": "abc123",
  "cell_type": "code",
  "edit_mode": "insert",
  "new_source": "# New analysis code\nprint('Hello')"
}
```

Delete cell:
```json
{
  "notebook_path": "/path/to/notebook.ipynb",
  "cell_id": "abc123",
  "edit_mode": "delete",
  "new_source": ""
}
```

**Note**: `new_source` is required even for delete mode (use empty string)

**Key points**:
- Use absolute paths only
- Cell IDs are shown when reading notebooks with Read tool
- Insert without `cell_id` adds cell at beginning
- Notebooks are interactive documents combining code, text, and visualizations
- Commonly used for data analysis and scientific computing
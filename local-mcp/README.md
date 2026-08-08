# @noizu/local-mcp

A standalone, local-filesystem [MCP](https://modelcontextprotocol.io) server. It
exposes git-aware file search, grep, tree, and dump tools to an MCP client (e.g.
Claude Code) over stdio. Nothing leaves your machine — every tool reads the local
filesystem and shells out to `git`/`rg` only.

## Install

```bash
cd local-mcp
npm install
npm run build
```

Then register it with Claude Code (use the absolute path to `dist/index.js`):

```bash
claude mcp add noizu-local -- node /Users/keithbrings/Work/Space/Infra/Noizu/projects/NoizuPromptLingo/local-mcp/dist/index.js
```

### Development

```bash
npm run dev     # run from TypeScript source via tsx
npm start       # run the built dist/index.js
```

## Tools

All tools return text content. Path-taking tools guard against escaping their
`root` (no `../` traversal out of the base directory). Errors are returned as MCP
tool errors with a helpful message — the process never crashes on bad input.

### `file_search`
Find files matching a glob, optionally filtered by content.

| arg | type | default | notes |
|-----|------|---------|-------|
| `root` | string | cwd | base directory to search under |
| `glob` | string | — (required) | e.g. `**/*.ts` |
| `content` | string | — | optional regex; keep only files whose text matches |
| `max_results` | int | 200 | cap on returned files |

Returns a newline list of relative paths. When `content` is given, each row is
`relpath:<first matching line>`. Ignores `node_modules`, `.git`, `dist`.

### `grep`
Search file contents by regex. Uses `ripgrep` (`rg`) when on PATH, otherwise a
Node fallback that walks files.

| arg | type | default | notes |
|-----|------|---------|-------|
| `root` | string | cwd | base directory |
| `pattern` | string | — (required) | regex |
| `glob` | string | — | optional file filter |
| `max_results` | int | 200 | cap on returned lines |
| `ignore_case` | bool | false | case-insensitive |

Returns `relpath:lineno: line` rows.

### `git_tree`
Render a directory tree of git-tracked files (respects `.gitignore`).

| arg | type | default | notes |
|-----|------|---------|-------|
| `path` | string | cwd | directory to render |
| `depth` | int | — | optional; prune subtrees below this depth |

Returns a tree string drawn with `├──`, `└──`, `│`.

### `git_dump`
Concatenate every git-tracked file under a path.

| arg | type | default | notes |
|-----|------|---------|-------|
| `path` | string | cwd | directory to dump |
| `glob` | string | — | optional filter (relative to git root) |

Each file is emitted as:

```
# <relpath>
---
<contents>
* * *
```

Binary/unreadable files are noted (`(skipped: binary file)`) rather than dumped.

### `dump_files`
Dump an explicit list of files in the same block format as `git_dump`.

| arg | type | default | notes |
|-----|------|---------|-------|
| `files` | string[] | — (required) | paths to dump |
| `root` | string | cwd | paths must resolve within this base |

Each path is validated to exist, be a regular file, and resolve within `root`.

### `file_read`
Read a file, or a 1-based line range, with `cat -n` style line numbers.

| arg | type | default | notes |
|-----|------|---------|-------|
| `path` | string | — (required) | file to read |
| `root` | string | cwd | path must resolve within this base |
| `start_line` | int | 1 | first line (inclusive) |
| `end_line` | int | EOF | last line (inclusive) |

## Notes

- Node 22+, ESM, built with `tsc` to `dist/`.
- Git/ripgrep are invoked via `execFile` (no shell), so paths and patterns are
  not subject to shell injection.

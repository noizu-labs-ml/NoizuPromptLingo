# quick-gist

A fast, ergonomic CLI wrapper around `gh gist` with interactive file picking via [fzf](https://github.com/junegunn/fzf).

## Features

- Interactive file selection with fzf (multi-select, preview)
- Pipe from stdin
- Add files to existing gists
- Public/secret visibility control (flag or env var)
- Auto-copies gist URL to clipboard
- Optional browser open after creation

## Requirements

- [GitHub CLI (`gh`)](https://cli.github.com/) — authenticated (`gh auth login`)
- [fzf](https://github.com/junegunn/fzf) — optional, required for interactive file picking

## Install

Copy the `quick-gist` script somewhere on your `$PATH`:

```bash
cp quick-gist ~/.local/bin/quick-gist
chmod +x ~/.local/bin/quick-gist
```

## Usage

```
quick-gist [options] [file ...]
```

### Create gists

```bash
# Interactive file picker (fzf)
quick-gist

# Gist specific files
quick-gist src/main.py README.md

# With a description
quick-gist -d "helper utilities" utils.py lib.py

# Open in browser after creation
quick-gist -o index.html style.css
```

### Visibility

Gists are **secret by default**. Control visibility with flags or an environment variable:

```bash
# Public gist
quick-gist --public app.js

# Explicitly secret
quick-gist --secret credentials.example

# Short flag for secret
quick-gist -s config.yaml

# Set default via environment variable
export QUICK_GIST_VISIBILITY=public
quick-gist app.js          # now public by default
quick-gist --secret app.js # override back to secret
```

### Pipe from stdin

```bash
# Pipe content (default filename: paste.txt)
echo "hello world" | quick-gist -p

# Pipe with a custom filename
cat output.json | quick-gist -p -n output.json

# Combine with other options
curl -s https://example.com | quick-gist -p -n page.html -d "fetched page" --public
```

### Manage existing gists

```bash
# Add files to an existing gist by ID
quick-gist -a abc123def file.py tests.py

# Add files interactively (fzf picker)
quick-gist -e abc123def

# List your recent gists
quick-gist -l
```

## Options

| Flag | Description |
|------|-------------|
| `-d DESC` | Description for the gist |
| `-s` | Create secret gist (same as `--secret`) |
| `--public` | Create public gist |
| `--secret` | Create secret gist |
| `-p` | Read from stdin (pipe mode) |
| `-n NAME` | Filename for stdin content (default: `paste.txt`) |
| `-a ID` | Add files to an existing gist |
| `-e ID` | Add files to existing gist via fzf picker |
| `-l` | List your recent gists |
| `-o` | Open gist in browser after creation |
| `-h` | Show help |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `QUICK_GIST_VISIBILITY` | `secret` | Default visibility (`secret` or `public`). Overridden by `--public`/`--secret`/`-s` flags. |

## License

MIT

# NPL MCP

A minimal FastMCP "hello‑world" server and the full NPL MCP server implementation.

---

## Prerequisites

- Python **3.10+**
- **uv** – a fast Python package manager and runner. Install it with:
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```

---

## Installation

From the repository root, sync the project dependencies:

```bash
uv sync          # install runtime dependencies
uv sync --editable   # editable install for local development
```

The above creates a virtual environment (in `./.venv` by default) and makes the package importable as `npl_mcp`.

---

## Running the Servers

### 1. Minimal hello‑world FastMCP server

```bash
uv run src/mcp.py
```

- Starts an SSE server on **127.0.0.1:8765**.
- Exposes a single tool `hello` that returns the string `"Hello, world!"`.

### 2. Full NPL MCP server (launcher)

```bash
# Using the module directly
uv run -m npl_mcp.launcher
```

Or, after the editable install, use the console script:

```bash
npl-mcp
```

The launcher provides several flags:

- `--status` – show whether a server is already running.
- `--stop`   – stop a running instance.
- `--config` – print the Claude Code MCP configuration snippet.
- `--test`   – run a quick connectivity test via a FastMCP client.

When started, the server:
- Serves the FastMCP SSE endpoint at **/sse**.
- Serves the Next.js UI at **/** if the frontend has been built (see below).

---

## Building the Frontend (optional)

The UI lives in `worktrees/main/mcp-server/frontend`. To build it:

```bash
cd worktrees/main/mcp-server/frontend
npm install
npm run build
```

The static files are placed in `src/npl_mcp/web/static` and will be served automatically by the FastAPI app.

---

## Testing

If a test suite exists under a `tests/` directory, run it with:

```bash
uv run -m pytest
```

To run a single test file:

```bash
uv run -m pytest path/to/test_file.py
```

---

## Building a Distribution

Create a wheel for publishing:

```bash
uv build
```

The wheel is placed in the `dist/` directory.

---

## Quick Reference

| Action | Command |
|--------|---------|
| Install dependencies | `uv sync` |
| Editable install | `uv sync --editable` |
| Run hello‑world server | `uv run src/mcp.py` |
| Run full server (module) | `uv run -m npl_mcp.launcher` |
| Run full server (script) | `npl-mcp` |
| Run tests | `uv run -m pytest` |
| Build wheel | `uv build` |

---

Enjoy building with **uv**!
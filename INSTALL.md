# Installation

## Prerequisites

- Python 3.11+
- [uv](https://docs.astral.sh/uv/)

## Setup

```bash
git clone <repo-url>
cd NoizuPromptLingo
uv sync
```

## Running the MCP Server

```bash
uv run -m npl_mcp.launcher          # starts on port 8765 (default)
uv run -m npl_mcp.launcher --port 9000  # custom port
```

## Adding to Claude Code

Connect Claude Code to a running instance via SSE:

```bash
claude mcp add npl --transport sse http://localhost:8765/sse
```

Use `--scope user` to make it available globally instead of per-project:

```bash
claude mcp add npl --transport sse http://localhost:8765/sse --scope user
```

## Verify

```bash
claude mcp list
```

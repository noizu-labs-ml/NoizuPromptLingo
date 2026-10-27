# AGENT-README

> Orientation for AI coding agents working in this repo. Human docs: README.md.

## Type

phoenix+react+mcp-server

## Purpose

NoizuPromptLingo (NPL): the structured prompt-engineering syntax — `conventions/*.yaml` is the single source of truth — plus a public MCP (`/mcp`: `NPLLoad`, `NPLSpec`), REST (`/api/v1/npl/*`), and a conventions admin UI serving that corpus at promptlingo.dev.

## Stack

Three-container stack: Next.js 15 frontend (`frontend/`), Phoenix 1.8 Elixir backend (`backend/`, app `noizu_prompt_lingua`), nginx reverse proxy — on Postgres (PostGIS, pgvector) + Redis, Weaviate for semantic MCP tool search; Liquibase-canonical schema + Ecto app-level; Helm chart deploys; secondary Python tooling (`src/npl_mcp`, uv-managed).

## Dev mode

```bash
make init        # generate .env files with secrets
make build       # build backend + frontend + nginx images
make run         # start the stack (nginx on :8080)
make run-dev     # hot-reload dev mode (source-mounted; -d for detached)
```

## Ports / URLs

- `http://localhost:8080` — nginx entrypoint for the whole stack (`make run`)
- MCP at `/mcp`, REST at `/api/v1/npl/*` (prod: `https://promptlingo.dev/mcp`)

## Tests

```bash
cd backend && mix test   # Phoenix backend (ExUnit)
uv run -m pytest         # Python tooling (tests/)
```

## Gotchas

- Liquibase owns canonical schema (`liquibase/`); `make migrate` / `migrate-status` / `migrate-rollback` for migrations.
- `yq` here is v3.4.3: no `-i` flag — filter before flags, pipe to a temp file.
- `npl/npl-full.md` is a generated artifact (`uv run npl-docs-regen`; `--check` exits non-zero when stale).
- MCP endpoint itself is open (no auth); Authentik OIDC sign-in gates only the conventions admin UI.
- Repo CLAUDE.md mandates session init (`ToolSession.Generate`) with `$NPL_PROJECT` set before any work.
- Worktrees convention: MAIN checkout owns `deps/` + `_build/` for the Elixir backend; worktrees under `.claude/worktrees/` symlink them by absolute path.

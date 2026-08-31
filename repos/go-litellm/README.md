# go-litellm

A CGO-free Go reimplementation of [ex-litellm](../ex-litellm): an
OpenAI-compatible multi-provider LLM gateway plus run-claude's front-proxy
routing, in **one static binary**.

Drop-in for the Python `litellm` binary and for `ex-litellm`: same
`--host/--port/--config` CLI, same `config.yaml` shape, same master-key auth,
same HTTP surface. No Elixir, no Mix release, no Prisma, no Postgres container.

## Install

Needs [Go 1.22+](https://go.dev/dl/). CGO is not required.

```bash
cd repos/go-litellm
make install          # → ~/.local/bin/go-litellm
```

Or without make:

```bash
CGO_ENABLED=0 GOBIN=~/.local/bin go install ./cmd/go-litellm
```

run-claude launches `go-litellm` by default once the binary is on `PATH`.
See [INTEGRATION.md](INTEGRATION.md). Override with
`FRONT_PROXY_COMMAND=ex-litellm` or `FRONT_PROXY_COMMAND=python`.

## Why this exists

`ex-litellm` is a self-contained Mix release, but building it still needs
Elixir 1.18 / OTP and `MIX_ENV=prod mix release`. `go-litellm` is `go build`
(or `go install`) and a single file on `PATH`.

## Two-in-one gateway

One process, one port (run-claude uses **4443**):

| Surface | Paths |
|---------|--------|
| LiteLLM | `/v1/chat/completions`, `/v1/embeddings`, `/v1/models`, `/model/*`, health |
| Front | `/v1/messages` (Claude Code), Anthropic passthrough, `/front/rules` |
| Admin | `/status`, `/status.json`, `/status/requests`, `/keys` |

Dev default bind is `127.0.0.1:4445` so a live Python/Elixir proxy on 4443/4444
is never disturbed. run-claude always passes `--port 4443`.

## CLI

```
go-litellm [--host HOST] [--port PORT] [--config FILE]
```

Env (same as litellm / ex-litellm):

- `LITELLM_MASTER_KEY`
- `LITELLM_DATABASE_URL` (sqlite path, or `sqlite://…`; postgres URLs currently
  keep the SQLite request log)
- `STORE_MODEL_IN_DB`
- `CONFIG_FILE_PATH`

SQLite default: `~/.local/state/go-litellm/go_litellm.db`.

## Development

```bash
make test
make build
go-litellm --host 127.0.0.1 --port 4445 --config /path/config.yaml
```

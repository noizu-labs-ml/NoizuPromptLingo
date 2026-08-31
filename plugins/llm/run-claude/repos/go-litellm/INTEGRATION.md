# Wiring go-litellm into run-claude

`go-litellm` is a drop-in for `ex-litellm`: one process that serves both the
LiteLLM API surface *and* the front-proxy routing run-claude used to run as
two Python processes (front :4443 + litellm :4444).

## Build + install

```bash
cd repos/go-litellm
make install                          # ~/.local/bin/go-litellm
# or: CGO_ENABLED=0 GOBIN=~/.local/bin go install ./cmd/go-litellm
```

No system Elixir/Erlang. The binary is statically linked (`CGO_ENABLED=0`).

From the run-claude tree:

```bash
make install-go-litellm
```

## Default cutover

run-claude launches `go-litellm` by default. **No env var is required.**
`make install` (or `make install-go-litellm`) builds the binary to
`~/.local/bin/go-litellm` and `run_claude/bin/go-litellm`. The Python launcher
resolves that path itself — a login-shell `PATH` is not required.

`FRONT_PROXY_COMMAND` is only an override.

- `start_front_proxy()` launches `go-litellm --host 127.0.0.1 --port 4443
  [--config <generated>]`.
- `start_proxy()` is a health-check no-op — the gateway already serves the
  LiteLLM role, so no separate litellm proxy on 4444 is started.
- `get_proxy_url()` returns `http://127.0.0.1:4443`.
- `stop_front_proxy()` stops the gateway.

Claude Code's `ANTHROPIC_BASE_URL` already points at `http://127.0.0.1:4443`.

## Rollback

```bash
export FRONT_PROXY_COMMAND=ex-litellm   # Elixir Mix-release gateway
export FRONT_PROXY_COMMAND=python       # legacy two-process Python proxies
```

## Verified contract

Same launch flags and HTTP surface as `ex-litellm`:

- `POST /model/new`, `GET /model/info`, `GET /health`, `/health/readiness`
- `GET /keys`, `POST /keys`, `POST /keys/delete`, `POST /keys/switch` (named
  provider keys; `run-claude keys switch zai tyna` rebinds `zai/*`)
- `/v1/chat/completions` (+ SSE), `/v1/embeddings`, `/v1/models`
- `POST /v1/messages` (`claude-*` → Anthropic passthrough; other registered
  models → native inference with Anthropic-shaped I/O)
- `GET /api/claude_cli/bootstrap`

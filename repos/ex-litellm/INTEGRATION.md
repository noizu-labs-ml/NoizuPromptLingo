# Wiring ex-litellm into run-claude

ex-litellm ships as a **unified gateway** — one process that serves both the
LiteLLM API surface *and* the front-proxy routing that run-claude's Python
`front_proxy.py` used to. It replaces **both** Python proxies (the front proxy
on 4443 and the litellm proxy on 4444) with a single Elixir process on 4443.

## Build + install

```bash
cd repos/ex-litellm
MIX_ENV=prod mix release --overwrite          # self-contained release (bundles ERTS + NIFs)

# Install release + launcher to a stable prefix + symlink onto PATH:
INSTALL=~/.local/share/ex-litellm
rm -rf "$INSTALL"; mkdir -p "$INSTALL/bin"
cp -R _build/prod/rel/ex_litellm "$INSTALL/bin/ex_litellm"
cp bin/ex-litellm "$INSTALL/bin/ex-litellm"
ln -sf "$INSTALL/bin/ex-litellm" ~/.local/bin/ex-litellm
```

The release is fully self-contained — it needs no system Elixir/Erlang on PATH.

## Enable (opt-in)

run-claude's default unified gateway is `go-litellm`. To launch this Mix
release instead:

```bash
export FRONT_PROXY_COMMAND=ex-litellm
```

With this set, run-claude's `proxy.py`:

- `start_front_proxy()` launches `ex-litellm --host 127.0.0.1 --port 4443
  [--config <generated>]` (the unified gateway) instead of `python -m
  run_claude.front_proxy`.
- `start_proxy()` becomes a health-check no-op — the gateway already serves the
  LiteLLM role, so no separate litellm proxy on 4444 is started.
- `get_proxy_url()` returns `http://127.0.0.1:4443`, so model registration
  (`/model/new`), `/model/info`, and health checks all target the gateway.
- `stop_proxy()` is a no-op; `stop_front_proxy()` stops the gateway.

Claude Code's `ANTHROPIC_BASE_URL` already points at `http://127.0.0.1:4443`, so
nothing changes on the client side. Model registration, inference (OpenAI-path
and `/v1/messages`), streaming, and the `/api/claude_cli/bootstrap` discovery
endpoint all work through the one port.

## Rollback

```bash
unset FRONT_PROXY_COMMAND               # back to go-litellm (the compiled default)
export FRONT_PROXY_COMMAND=python       # legacy two-process Python proxies
```

The switch is a single env var; nothing else changes.

## Verified

Driven through run-claude's own `proxy.py` functions:

- `start_front_proxy` → gateway up on 4443 ✓
- `start_proxy` (unified no-op health) → True ✓
- `ensure_models` → `POST /model/new` → HTTP 200, model registered ✓
- inference through 4443 (Groq) ✓; `/v1/messages` claude → Anthropic passthrough ✓
- bootstrap model discovery ✓; stop path ✓
- run-claude's 100 unit tests still pass (unified mode is off by default).

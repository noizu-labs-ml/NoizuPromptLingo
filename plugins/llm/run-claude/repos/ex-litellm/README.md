# ex-litellm

An interface-identical Elixir reimplementation of the [LiteLLM](https://github.com/BerriAI/litellm)
proxy, plus run-claude's front-proxy routing tier, folded into one OTP app.

It is a **drop-in replacement** for the Python `litellm` binary that
[run-claude](../..) launches: same `--host/--port/--config` CLI, same
`config.yaml` shape, same master-key auth, same OpenAI-compatible HTTP surface —
but with **SQLite by default** (no Postgres/Prisma/container required) and a
**runtime-alterable** front-proxy routing layer.

run-claude's **default** gateway is now [`go-litellm`](../go-litellm) (same
HTTP/CLI contract, no Elixir). To use this Mix release instead:

```bash
export FRONT_PROXY_COMMAND=ex-litellm
```

## Why

The Python proxy pulls in a Prisma query-engine subprocess and a mandatory
Postgres instance (run-claude spins up a TimescaleDB container just for it), and
resolves callbacks via a brittle file-path shim. ex-litellm removes all of that:
one self-contained binary, one SQLite file, callbacks resolved as Elixir modules.

## Two tiers

| Tier | Module | Dev port | Prod port | Role |
|------|--------|----------|-----------|------|
| LiteLLM | `ExLiteLLM.Proxy.Endpoint` | 4445 | 4444 | OpenAI-compatible multi-provider inference + admin |
| Front | `ExLiteLLM.FrontProxy` | 4446 | 4443 | runtime-alterable routing / auth-swap / passthrough |

Dev ports (4445/4446) are deliberately offset from the live Python proxy
(4444/4443) so development never disturbs a running session.

## Status

Built and verified live against real providers:

- ✅ **Phase 1** — skeleton, config loader (`os.environ/` interpolation), SQLite
  repo, health/readiness endpoints.
- ✅ **Phase 2** — provider behaviour + OpenAI adapter + OpenAI-compatible thin
  adapters (Groq, Cerebras, DeepSeek, xAI, Mistral, Perplexity, Ollama),
  provider resolution, `drop_params`, master-key auth, non-streaming
  `/v1/chat/completions` + `/v1/embeddings` + `/v1/models`.
- ✅ **Phase 3** — SSE streaming + the distinct Anthropic adapter (system
  hoisting, content-block flattening, tool_use, typed-event stream parsing).

Roadmap continues through the router (strategies, cooldowns, fallbacks),
persistence, callbacks, full endpoint parity, the front-proxy tier, and the
run-claude cutover.

## Development

```bash
# Toolchain: Elixir 1.18 / OTP 28 (see .tool-versions)
mix deps.get
mix compile
mix test

# Run the LiteLLM tier on the dev port with a config:
LITELLM_MASTER_KEY=sk-dev mix run --no-halt   # binds :4445
```

Config is a standard litellm `config.yaml` (`model_list`, `litellm_settings`,
`general_settings`), plus an optional `front_proxy` block for the front tier.

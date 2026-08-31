# How to: point Claude Assist at a different LLM provider

**Goal:** swap the embedding provider (used for semantic search) or the LLM provider (used by Convert's artifact generation and Safety Watch) away from the local default.
**Prereqs:** API running (`llm-toolkit` or `llm-toolkit api`); an API key for whichever provider you pick.

## Option A — Web UI / TUI Settings page

1. Open `/settings` in the Web UI, or `npx tsx packages/cli/bin.ts interactive` → Settings page.
2. Under **LLM**, pick a provider: `anthropic`, `openai`, `groq`, `cerebras`, `deepseek`, `zai`, `litellm`, or `ollama`.
3. Fill in model, API key, base URL, and `apiType` (`openai` or `anthropic` — controls which request/response shape is used against the endpoint). `litellm`/`ollama`/custom OpenAI-compatible endpoints need `baseUrl` + `apiType: openai`.
4. Save. Use the Settings page's test-prompt action to confirm the provider answers before relying on it elsewhere.

## Option B — environment variables (no UI needed)

Set the provider's key before starting the API; it overlays whatever's saved in config:

| Provider | Env var |
|----------|---------|
| Anthropic | `ANTHROPIC_API_KEY` |
| OpenAI | `OPENAI_API_KEY` |
| Groq | `GROQ_API_KEY` |
| Cerebras | `CEREBRAS_API_KEY` |
| DeepSeek | `DEEPSEEK_API_KEY` |
| Z.ai | `ZAI_API_KEY` |
| LiteLLM | `LITELLM_API_KEY` (falls back to `OPENAI_API_KEY` if unset) |
| Ollama | `OLLAMA_BASE_URL` (overrides baseUrl; no key needed) |
| LiteLLM base URL | `LITELLM_BASE_URL` |

```bash
export ANTHROPIC_API_KEY=sk-ant-...
llm-toolkit api
```

Then set `provider: anthropic` in config (via Settings, or `PATCH /api/config`) — the env var supplies the key, you don't paste it into config.

**Verify:** `GET /api/config` returns your provider under `llm`, with `apiKey` shown masked (`sk-...abcd`) — masked output is expected and is not the stored value being empty.
**Gotchas:**
- The key shown by `GET /api/config` is always masked (`isMaskedKey`/`maskKey` in `packages/api/src/routes/config.ts`); re-`PATCH`-ing that masked string back verbatim will overwrite your real key with garbage — only send a real key when actually changing it.
- Provider name must exactly match the table above (lowercase) — the env overlay only fires on an exact match to `config.llm.provider`.
- `ollama`/`litellm` need `baseUrl` set (via env or config) — there's no default endpoint to fall back to.

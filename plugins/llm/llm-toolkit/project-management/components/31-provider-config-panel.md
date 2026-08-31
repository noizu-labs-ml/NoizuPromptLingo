# 31: Provider Config Panel

| Field | Value |
|-------|-------|
| ID | CMP-31 |
| Category | Input & Forms |
| Surfaces | web, cli-ink |
| Used In | SCR-14, SCR-27 |

## Description
Shared form pattern for configuring a provider integration — used three times on Settings for three different concerns: index paths + reindex (IndexConfig), embedding provider (EmbeddingConfig — Local/Transformers.js vs. Hosted/API-key), and LLM provider for simplify/summarize/convert-candidate operations (LLMConfig, with per-operation override and a "validate connectivity" action).

## Size Variants

| Variant | Use Case |
|---------|---------|
| IndexConfig | Watched paths (PathList) + full/incremental ReindexBtn |
| EmbeddingConfig | Local vs. Hosted provider toggle, model selector or API key field |
| LLMConfig | Provider selector, per-operation override, Validate button |

## Props / Configuration
- `provider` — selected provider identifier
- `credentials` — API key / endpoint (masked in UI, never logged)
- `onValidate` — connectivity check callback, surfaces specific failure reasons (auth/network/endpoint) rather than a generic error

## Interactions
- Switching embedding provider warns that a reindex is required (existing embeddings become stale)
- Validate performs a lightweight connectivity check before the section is saved

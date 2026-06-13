# Adapter Config Form

| Field | Value |
|-------|-------|
| **ID** | `adapter-config-form` |
| **Category** | Domain-Specific |
| **Used In** | 07-Agent Detail |

## Description

Dynamic configuration form for agent adapter settings. Form fields change based on selected adapter type (openai, anthropic, langchain, http, bedrock, vertex). Includes model picker, auth reference, headers, request/response templates, and streaming toggle.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full-page form section with adapter-specific fields |

## Props / Configuration

- `adapterType` — Selected adapter (openai, anthropic, langchain, http, bedrock, vertex)
- `config` — Current adapter configuration object
- `onChange` — Callback when config changes
- `testConnection` — Button to verify configuration works
- `streamingToggle` — Enable/disable streaming response support

## Interactions

- Select adapter type (changes visible fields)
- Configure adapter-specific settings (model, auth, headers, templates)
- Test connection with minimal ping
- Toggle streaming support
- Validation per adapter type

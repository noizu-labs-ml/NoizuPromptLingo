# Admin: LLM Model Catalog

| Field | Value |
|-------|-------|
| **ID** | `admin-llm-model-catalog` |
| **Type** | Settings |
| **Category** | Platform Admin |
| **User Stories** | US-057 |

## Description

Platform-wide catalog of available LLM providers/models at `/app/admin/llm-models`, including live connectivity testing before a model is made available to organizations.

## Key Components

- **Model Catalog Table** — provider, model id, status, enabled orgs
- **Add Model Provider Form** — credentials and endpoint config (US-057)
- **Live Connectivity Test Button** — fires a live test call and reports pass/fail (US-057)
- **Provider Health Badge** — last-known connectivity status per row (US-057)

## Interactions

- Admin fills the Add Model Provider Form and clicks Live Connectivity Test Button → inline pass/fail result before saving (US-057)
- Admin toggles a model's enabled state → Provider Health Badge updates on the next scheduled check (US-057)

## Navigation

- Accessible from: Admin Home (09) sidebar
- Links to: none (terminal admin settings screen)

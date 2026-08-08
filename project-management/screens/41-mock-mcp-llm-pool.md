# Mock MCP LLM Pool

| Field | Value |
|-------|-------|
| **ID** | `mock-mcp-llm-pool` |
| **Type** | Settings |
| **Category** | Agent Infrastructure |
| **User Stories** | None — configuration surface supporting the Mock MCP Builder (US-103, screen 40) |

## Description

Settings screen at `/app/[orgId]/mock-mcp/llms` for managing the pool of LLMs available to power mock MCP servers' simulated tool responses.

## Key Components

- **LLM Pool Table** — models available to mock servers, with enabled state
- **Add Model to Pool Button** — adds a model from the org's LLM catalog
- **Default Model Selector** — sets the pool's default for new mock servers

## Interactions

- User toggles a row's enabled state → model becomes available/unavailable to mock servers
- User sets the Default Model Selector → new mock servers default to that model

## Navigation

- Accessible from: Mock MCP Builder (40)
- Links to: none (terminal settings screen)

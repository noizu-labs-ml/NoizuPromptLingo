# Agent Registration

| Field | Value |
|-------|-------|
| **ID** | `agent-registration` |
| **Type** | Storyboard |
| **Category** | Agents |
| **User Stories** | US-018, US-065 |

## Description

Multi-field form for registering a new AI agent. Collects agent name, description, type, capabilities, and optional MCP connection details. Validates uniqueness and tests MCP reachability.

## Key Components

- **Agent name input** — 3-30 character text field (US-018)
- **Description textarea** — 10-500 character description (US-018)
- **Agent type selector** — LLM / Tool / MCP dropdown (US-018)
- **API endpoint input** — URL field for agent endpoint (US-018)
- **Auth method selector** — API Key / OAuth choice (US-018)
- **Capabilities checkboxes** — Text, code, image, and other capability toggles (US-018)
- **Rate limit defaults** — Initial rate limit configuration (US-065)
- **MCP server reachability validator** — Tests endpoint connectivity (US-065)
- **Name uniqueness checker** — Real-time validation of agent name (US-018)
- **API credentials display** — Shown post-creation for authentication (US-018)
- **Quick start guide panel** — Post-creation onboarding instructions (US-018)

## Interactions

- Fill registration form fields
- Check name uniqueness in real time
- Validate MCP endpoint reachability
- Submit to create the agent

## Navigation

- Accessible from: "Register Agent" button (any authenticated page), My Agents (22)
- Links to: Agent Profile (20) after creation

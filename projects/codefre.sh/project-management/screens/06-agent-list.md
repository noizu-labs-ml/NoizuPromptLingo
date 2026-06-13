# Agent List

| Field | Value |
|-------|-------|
| **ID** | `agent-list` |
| **Type** | Primary |
| **Category** | Agent Connectors |
| **User Stories** | US-012, US-061, US-062, US-063, US-065, US-122 |

## Description

Lists all configured agents in the organization with health status badges, adapter type, model, and version info. Entry point for creating new agent configurations.

## Key Components

- **Agent table** — Name, adapter type, model, current version, health badge (US-065)
- **Health badges** — Green/amber/red/gray status indicators with tooltip (US-065)
- **New Agent button** — Opens adapter picker (openai, anthropic, langchain, http, bedrock, vertex) (US-012, US-061, US-062, US-063, US-122)
- **Row actions** — Edit, test connection, view versions

## Interactions

- Click "New Agent" to open agent creation with adapter picker
- Click a row to open Agent Detail
- Health badge tooltip shows last check time and failure reason

## Navigation

- Accessible from: Global sidebar navigation
- Links to: Agent Detail (click row)

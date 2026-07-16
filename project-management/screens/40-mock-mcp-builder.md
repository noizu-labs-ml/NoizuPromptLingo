# Mock MCP Builder

| Field | Value |
|-------|-------|
| **ID** | `mock-mcp-builder` |
| **Type** | Primary |
| **Category** | Agent Infrastructure |
| **User Stories** | US-103 |

## Description

Builder at `/app/[orgId]/mock-mcp` and `/app/[orgId]/mock-mcp/[slug]` for generating a mock MCP server from a prose description, useful for testing agent integrations without hitting production tools.

## Key Components

- **Prose Description Input** — natural-language description of the desired mock server (US-103)
- **Generated Tool List Preview** — tools the builder inferred from the description (US-103)
- **Tool Definition Editor** — manual refinement of a generated tool's schema
- **Publish Mock Server Button** — activates the mock server for use

## Interactions

- User submits a description via the Prose Description Input → the Generated Tool List Preview populates for review (US-103)
- User edits a tool via the Tool Definition Editor, then clicks Publish Mock Server Button → the mock server becomes callable (US-103)

## Navigation

- Accessible from: Org Dashboard (17), MCP API Keys & Setup (08)
- Links to: Mock MCP LLM Pool (41)

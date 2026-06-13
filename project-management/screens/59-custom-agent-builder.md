# Custom Agent Builder

| Field | Value |
|-------|-------|
| **ID** | `custom-agent-builder` |
| **Type** | Storyboard |
| **Category** | Agent Management |
| **User Stories** | US-083 |

## Description

Multi-step agent creation wizard with role definition, system prompt editor, tool permission matrix, behavioral constraint rules, escalation configuration, and dry-run testing before activation.

## Key Components

- **Name/role fields** — Agent identity and role description
- **System prompt editor** — Full text editor for agent system prompt
- **Tool permission matrix** — Which tools the agent can access
- **Constraint rules editor** — Behavioral guardrails and boundaries
- **Escalation config** — When and how the agent escalates to humans
- **Dry-run test mode** — Test agent behavior with sample inputs
- **Save as template action** — Save agent config as reusable template

## Flow Steps

1. **Identity** — Name, role, description, avatar
2. **System prompt** — Define agent personality and instructions
3. **Permissions** — Set tool access and resource permissions
4. **Constraints** — Define behavioral boundaries and guardrails
5. **Escalation** — Configure human escalation triggers
6. **Test** — Dry-run with sample scenarios
7. **Activate** — Deploy agent to the workspace

## Navigation

- Triggered from: Agent Team Dashboard (create agent), Template Library
- Outputs to: Agent Team Dashboard (new agent)

# Agent Personas Management

| Field | Value |
|-------|-------|
| **ID** | `agent-personas-management` |
| **Type** | Primary |
| **Category** | Agent Infrastructure |
| **User Stories** | US-022, US-023, US-024, US-028 |

## Description

Management surface at `/app/[orgId]/personas` for the product's Agent Persona entity — bio, journal, and private knowledge base — distinct from the UX-persona documentation set used to design this product. Also where an agent's call sign and live state are registered and tracked.

## Key Components

- **Persona Bio Card** — name, bio, call sign, and current state (US-022, US-028)
- **Journal Entry Timeline** — chronological log of completed-work entries (US-023)
- **Knowledge Base Entry List** — persona's private KB entries (US-024)
- **Agent State Indicator** — live status badge (idle/active/error) tied to the registered call sign (US-028)
- **New Persona Form** — registers a new persona with an initial bio (US-022)

## Interactions

- User submits the New Persona Form → persona is created with a bio and appears in the roster (US-022)
- Agent or user adds an entry via the Journal Entry Timeline's composer → entry appended (US-023)
- User adds an entry to the Knowledge Base Entry List → available to that persona's private KB immediately (US-024)
- Agent State Indicator updates live as the registered call sign reports state changes (US-028)

## Navigation

- Accessible from: Org Dashboard (17)
- Links to: Agent Memory Browser (36) for the selected persona's memory store

# Agent Registration Form

| Field | Value |
|-------|-------|
| **ID** | `agent-registration-form` |
| **Type** | Primary |
| **Category** | Agent Management |
| **User Stories** | US-026, US-027, US-032 |

## Description

Multi-step form for agent operators to register new agents, declare capabilities, and configure API endpoints. Entry point for bringing agents onto the platform.

## Key Components

- **Basic info step** — Agent name (unique per operator), description, type selection (US-026)
- **Capabilities step** — Structured taxonomy selector with categories, subcategories, and proficiency levels (US-027)
- **API endpoint step** — HTTPS URL field, authentication type selector (API key/Bearer/HMAC), credential input with test ping (US-032)

## Interactions

- Name input with uniqueness validation against user's existing agents
- Description with minimum character validation
- Capability multi-select with at-least-one requirement
- Proficiency level dropdown per selected capability
- Endpoint URL with HTTPS validation
- Authentication type switching toggles credential input type
- Test ping button with loading state and 5-second timeout

## Navigation

- Accessible from: Agent Dashboard "Register Agent" button
- Links to: Agent Detail page (after successful registration), Calibration Flow
# Admin: Authz (MCP Keys + PBAC)

| Field | Value |
|-------|-------|
| **ID** | `admin-authz` |
| **Type** | Settings |
| **Category** | Platform Admin |
| **User Stories** | US-062, US-063, US-064, US-086 |

## Description

Platform-wide authorization control center at `/app/admin/authz` combining MCP key usage auditing with PBAC policy simulation, denial explanation, and shadow-mode identity-mismatch logging.

## Key Components

- **PBAC Policy Simulator** — runs a hypothetical actor/action/resource check (US-062)
- **Denial Explanation Panel** — breaks down why a simulated or real check was denied (US-063)
- **MCP Key Usage Audit Table** — cross-org key usage log (US-064)
- **Shadow-Mode Mismatch Log** — tool_guard identity mismatches recorded without enforcement (US-086)

## Interactions

- Admin fills the PBAC Policy Simulator inputs and runs a check → result renders, with the Denial Explanation Panel expanding automatically if denied (US-062, US-063)
- Admin filters the MCP Key Usage Audit Table by org/key/date range (US-064)
- Admin reviews Shadow-Mode Mismatch Log entries to evaluate impact before promoting a policy to enforcing (US-086)

## Navigation

- Accessible from: Admin Home (09) sidebar
- Links to: Admin: Users (10) and Admin: Organizations (11) for the actors/orgs referenced in audit rows

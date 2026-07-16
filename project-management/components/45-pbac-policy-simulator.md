# PBAC Policy Simulator

| Field | Value |
|-------|-------|
| **ID** | `pbac-policy-simulator` |
| **Category** | Domain-Specific |
| **Used In** | 12-admin-authz |

## Description

Runs a hypothetical actor/action/resource policy-based-access-control check and explains the result, auto-expanding a denial breakdown when the simulated (or a real) check is denied. Paired on the same screen with a shadow-mode mismatch log, letting admins evaluate a policy's real-world impact before promoting it from shadow mode to enforcing. Single screen, but a genuinely complex, NPL-authz-specific tool combining simulation, explanation, and pre-promotion impact analysis.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Actor/action/resource input form with pass/deny result |
| **Full Page** | Simulator plus denial explanation and shadow-mode mismatch log, combined authz workbench |

## Props / Configuration

- `actor` / `action` / `resource` — the hypothetical check inputs
- `result` — allow/deny outcome of the simulated (or real) check
- `shadowModeLog` — recorded identity mismatches from shadow-mode (non-enforcing) evaluation

## Interactions

- Admin fills the actor/action/resource inputs and runs a check → the result renders, with the denial explanation panel expanding automatically if the check is denied
- Admin reviews shadow-mode mismatch log entries → evaluates real-world impact before switching a policy from shadow mode to enforcing

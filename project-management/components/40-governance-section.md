# Governance Section

| Field | Value |
|-------|-------|
| **ID** | `governance-section` |
| **Category** | Domain-Specific |
| **Used In** | 07-Agent Detail, 24-Organization Settings |

## Description

Configuration section for cost and rate governance controls. Includes daily cost cap, rate limit per minute, and default governance settings at org level. Shows current usage against limits.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Inline fields within a settings section |

## Props / Configuration

- `dailyCostCap` — Maximum daily spend in USD
- `rateLimitPerMinute` — Max requests per minute
- `currentUsage` — Current spend/rate for context
- `scope` — `agent` | `organization` (agent-specific or org-wide defaults)
- `onChange` — Callback when limits are modified

## Interactions

- Set cost cap and rate limit values
- View current usage against limits
- Org-level defaults cascade to new agents

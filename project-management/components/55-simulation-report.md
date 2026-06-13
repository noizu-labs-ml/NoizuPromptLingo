# Simulation Report

| Field | Value |
|-------|-------|
| **ID** | `simulation-report` |
| **Category** | AI-Specific |
| **Used In** | 08-Policy Simulation |

## Description

Summary of simulation results: total requests replayed, allow/deny counts, new denials (potential breakage), new allows (potential risk), per-caller breakdown.

## Size Variants

| Variant | Description |
|---------|-------------|

## Props / Configuration

- `results`
- `impactLevel`
- `affectedCallers`

## Interactions

- Click request for full trace
- Deploy policy
- Modify and re-run


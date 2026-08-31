# 42: skill-manage Context Budget Report (command output)

| Field | Value |
|-------|-------|
| ID | SCR-42 |
| Surface | cli-command |
| Type | primary |
| Category | skill-manage (audit) |
| Route / Entry | `skill-manage context --provider <all\|claude\|codex\|grok> --json` |
| Primary Personas | P-008 |
| User Stories | US-095 |

## Description
One-shot command reporting how much of each provider's context/metadata budget is consumed by currently enabled skills/agents, so a user can check headroom before enabling another skill rather than discovering bloat after the fact.

## Entry Points
- `skill-manage context --provider all --json` (or scoped to a single provider) from any shell

## Key Components
- Per-provider budget usage report (valid JSON with `--json`) — consumed budget per enabled skill/agent
- Over-budget flag — items exceeding a configurable threshold are marked `"over_budget": true`

## States
- **All-provider view:** report keyed by provider when `--provider all`
- **Single-provider view:** report scoped to just the requested provider
- **Over-budget:** flagged entries are distinguishable in the JSON without needing a separate lookup

## Interactions
- `--provider` scopes the report (`all` or a specific provider name)
- `--json` is the documented/expected output mode for scripting and pre-enable checks

## Navigation
- **From:** shell invocation (typically run before `skill-manage tui` bulk-enable actions)
- **To:** n/a (prints and exits)

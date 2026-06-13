# Capability Comparison Matrix

| Field | Value |
|-------|-------|
| **ID** | `capability-comparison-matrix` |
| **Category** | Domain-Specific |
| **Used In** | 16-Agent Comparison View |

## Description

Grid layout placing capabilities as rows and agents as columns. Each cell indicates whether the capability is present, absent, or proficient at a specific level. Gap highlighting draws attention to capabilities where one or more agents fall short.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full comparison layout with all capability rows, agent columns, and gap highlights |

## Props / Configuration

- `agents[]` — Array of agent records providing column headers (id, name)
- `capabilities[]` — Array of capability definitions providing row labels (key, label, category)
- `proficiencyMap` — Nested map of agentId → capabilityKey → value (absent | present | proficiency level)
- `highlightGaps` — Whether to apply visual highlighting to cells where capability is absent for at least one agent

## Interactions

- Hover a cell to see a tooltip with the specific proficiency level and any associated notes
- Filter rows by capability category to reduce matrix size

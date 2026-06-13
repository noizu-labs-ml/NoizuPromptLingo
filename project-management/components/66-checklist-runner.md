# Checklist Runner

| Field | Value |
|-------|-------|
| **ID** | `checklist-runner` |
| **Category** | Domain-Specific |
| **Used In** | 41-Runbook Manager, 44-Checklist Library, 46-Pre-Deploy Checklist, 47-Agent-Generated Checklist Review |

## Description

Interactive step-by-step checklist with auto-check items, manual check-offs, and overall gate status

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed checklist with completion count |
| **Expanded** | Full checklist with items, auto-checks, and status |

## Props / Configuration

- `items` — array of {text, type: auto|manual, status}
- `gateStatus` — pass|fail|pending
- `overrideEnabled` — boolean
- `onComplete` — callback

## Interactions

- check off manual items
- auto items verify in real-time
- override with reason
- gate status updates live

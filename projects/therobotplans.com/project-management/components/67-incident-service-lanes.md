# Incident Service Lanes

| Field | Value |
|-------|-------|
| **ID** | `incident-service-lanes` |
| **Category** | Domain-Specific |
| **Used In** | 33-Incident Detail |

## Description

Parallel horizontal lanes per service showing events during an incident with causation arrows between lanes

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Multi-lane timeline with arrows |
| **Full_Page** | Full-page incident reconstruction |

## Props / Configuration

- `services` — array of service names
- `events` — per-service event arrays
- `causationLinks` — array of arrow connections
- `timeRange` — start-end

## Interactions

- toggle lanes on/off
- click events for detail
- follow causation arrows
- zoom timeline

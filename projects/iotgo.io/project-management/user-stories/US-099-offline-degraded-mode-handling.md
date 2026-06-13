---
id: US-099
title: "Offline / Degraded Mode Handling"
slug: "offline-degraded-mode-handling"
personas: [P-008, P-002]
epic: "Accessibility, Performance & Edge Cases"
priority: "could-have"
complexity: "M"
tags: [offline, resilience, degraded-mode, ux, edge-cases]
---

# US-099: Offline / Degraded Mode Handling

## User Story

**As a** Junior IoT Technician (P-008),
**I want to** receive clear feedback when the IoTGo platform or a data source becomes unreachable,
**So that** I understand the system state and know what actions are still available versus unavailable during an outage.

## Acceptance Criteria

- [ ] Given my browser loses internet connectivity, when I interact with any IoTGo page, then a persistent banner reads "You are offline — live data is unavailable. Cached views may be stale." and write actions are disabled
- [ ] Given the IoTGo API becomes unreachable while I am active, when the connection drops, then the banner appears within 10 seconds without requiring a page refresh
- [ ] Given a specific data source (MQTT broker, cloud connector) goes offline, when I view its card, then a warning badge with "Source offline since [time]" is displayed without affecting the rest of the dashboard
- [ ] Given the platform is degraded (partial service disruption), when I check the status indicator in the nav bar, then it shows an amber "Degraded" state with a link to the status page
- [ ] Given connectivity is restored, when the API becomes reachable again, then the offline banner disappears automatically, data refreshes, and a brief toast confirms "Connection restored"

## Notes

Cached data displayed during offline mode must be clearly timestamped. Relates to US-098 (loading states). The status page URL should be configurable for self-hosted deployments.

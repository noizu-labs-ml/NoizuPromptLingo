---
id: US-065
title: "Fleet Segmentation by Type, Location, and Tag"
slug: "fleet-segmentation"
personas: [P-001, P-002]
epic: "Fleet & Device Management"
priority: "must-have"
complexity: "M"
tags: [segmentation, fleet, tags, location, filter]
---

# US-065: Fleet Segmentation by Type, Location, and Tag

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** define and manage fleet segments by device type, physical location, and custom tags,
**So that** I can scope agent monitoring, playbook execution, and dashboards to meaningful subsets of the fleet rather than managing every device individually.

## Acceptance Criteria

- [ ] Given I create a fleet segment, when I define it, then I can use any combination of: device type (e.g., "temperature sensor"), location hierarchy (e.g., building > floor > zone), and custom key-value tags as inclusion criteria.
- [ ] Given a segment is defined, when new devices are connected that match the segment criteria, then they are automatically included in the segment without manual update.
- [ ] Given I view a segment, when it loads, then I see the current member device count, a list of member devices, and the segment definition criteria.
- [ ] Given a segment is referenced by a playbook or agent, when I modify the segment criteria, then I am warned that the change will affect active playbooks and must confirm before saving.
- [ ] Given I have multiple segments, when I view the segment list, then I can see overlap counts (devices in multiple segments) to understand how segmentation coverage intersects.

## Notes

Segments are the primary targeting mechanism for US-052 (canary deployment), US-054 (safety limits), and US-059 (scheduling). Segment membership is evaluated dynamically at execution time.

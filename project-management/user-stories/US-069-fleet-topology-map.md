---
id: US-069
title: "Fleet Topology Map"
slug: "fleet-topology-map"
personas: [P-003, P-002]
epic: "Fleet & Device Management"
priority: "could-have"
complexity: "XL"
tags: [topology, map, visualization, fleet, spatial]
---

# US-069: Fleet Topology Map

## User Story

**As a** Smart Building Facility Manager (P-003),
**I want to** view devices on an interactive spatial map (floor plan, geographic, or logical hierarchy) with real-time health overlays,
**So that** I can immediately identify problem areas by location rather than scanning a table and dispatch technicians efficiently.

## Acceptance Criteria

- [ ] Given I open the Fleet Topology Map, when it loads, then devices are rendered as markers on either a geographic map (for outdoor assets) or a custom floor plan image (for indoor assets), based on their location metadata.
- [ ] Given devices are rendered, when I look at the map, then each marker is color-coded by health status (green / yellow / red / grey for offline) and I can toggle between health score and connection status overlays.
- [ ] Given I click a device marker, when the popup opens, then I see device name, type, current health score, and a link to the Device Detail view.
- [ ] Given I want to upload a floor plan image, when I upload a PNG/SVG, then I can pin devices onto the plan by dragging them to their physical location; coordinates are saved as device metadata.
- [ ] Given the map is loaded and data refreshes, when device health changes, then markers update color in real time without requiring a full page reload.

## Notes

Geographic map uses a tile-based provider (e.g., Mapbox or Leaflet with OSM). Floor plan upload and pinning requires a coordinate storage extension to device metadata (US-068). This is a differentiating feature but technically complex — suitable for post-MVP milestone.

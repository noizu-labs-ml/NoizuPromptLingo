---
id: US-063
title: "Telemetry Viewer"
slug: "telemetry-viewer"
personas: [P-006, P-001]
epic: "Fleet & Device Management"
priority: "must-have"
complexity: "L"
tags: [telemetry, charts, time-series, visualization]
---

# US-063: Telemetry Viewer

## User Story

**As a** Data Scientist/ML Engineer (P-006),
**I want to** visualize device telemetry as interactive time-series charts with configurable time ranges, metric selection, and anomaly overlays,
**So that** I can analyze sensor behavior, validate ML model inputs, and identify patterns that precede failures.

## Acceptance Criteria

- [ ] Given I open the Telemetry Viewer for a device, when it loads, then I see a chart for each reported telemetry metric with data for the last 24 hours by default.
- [ ] Given I select a custom time range, when the range is applied, then all charts update to show data within that range; the minimum granularity available is determined by the data retention policy.
- [ ] Given multiple metrics are available, when I select or deselect metrics from a legend, then the chart updates immediately to show only the selected metrics; I can overlay up to 8 metrics on a single chart.
- [ ] Given anomaly detection has flagged events in the selected time range, when the "Show Anomalies" toggle is on, then anomaly markers are overlaid on the relevant metric chart with a tooltip showing the anomaly type and agent response.
- [ ] Given I want to share a specific view, when I click "Copy Link", then a shareable URL encoding the selected time range, metrics, and device ID is copied to clipboard.

## Notes

Data is streamed from the connected IoT platform (US-074); IoTGo displays but does not own raw telemetry storage. Anomaly overlays connect to the anomaly detection pipeline.

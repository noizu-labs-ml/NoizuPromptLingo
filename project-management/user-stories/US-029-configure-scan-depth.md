---
id: US-029
title: "Configure scan depth"
slug: "configure-scan-depth"
personas: [P-001, P-002]
epic: "Defender — Scan Configuration"
priority: "should-have"
complexity: "S"
tags: [defender, scan-config, depth, performance]
---

# US-029: Configure Scan Depth

## User Story

**As a** Enterprise AppSec Manager (P-002),
**I want to** choose between quick, standard, and thorough scan modes,
**So that** I can balance scan completeness against time and cost depending on my testing context (ad-hoc spot check vs. pre-release gate vs. deep audit).

## Acceptance Criteria

- [ ] Given I am configuring a scan, when I select a depth mode, then I see a clear description of what each mode tests (e.g., quick = top-10 critical techniques, standard = full suite single-pass, thorough = multi-variant full suite).
- [ ] Given I select "quick", when the scan runs, then it completes in under 5 minutes for a standard attack suite selection.
- [ ] Given I select "thorough", when I view the configuration, then I am shown an estimated duration and token cost estimate before launching.
- [ ] Given I am on a free tier, when I attempt to select "thorough", then I am informed it requires a paid plan and shown an upgrade path.
- [ ] Given depth is set, when I save as a template (US-032), then the depth setting is persisted with the template.

## Notes

"Thorough" mode runs multiple prompt variants per technique to reduce false negatives; quick mode uses only the highest-signal variant per technique. Cost estimation is based on average token counts per technique.

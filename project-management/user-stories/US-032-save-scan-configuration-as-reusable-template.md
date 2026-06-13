---
id: US-032
title: "Save scan configuration as reusable template"
slug: "save-scan-configuration-as-reusable-template"
personas: [P-002, P-007]
epic: "Defender — Scan Configuration"
priority: "should-have"
complexity: "M"
tags: [defender, scan-config, templates, reuse, workflow]
---

# US-032: Save Scan Configuration as Reusable Template

## User Story

**As a** Enterprise AppSec Manager (P-002),
**I want to** save a scan configuration as a named template,
**So that** my team can launch consistent, pre-approved scans against new endpoints without reconfiguring attack suites, depth, and rate limits from scratch every time.

## Acceptance Criteria

- [ ] Given I have configured a scan, when I click "Save as Template", then I am prompted for a name and optional description before saving.
- [ ] Given a template is saved, when I create a new scan, then I can select from my saved templates to pre-fill the configuration form.
- [ ] Given I load a template, when I view the configuration, then all fields (attack suites, depth, rate limits, model family hint) are populated from the template — credentials are not included.
- [ ] Given I have multiple templates, when I open the template list, then I can search by name, sort by last used, and delete templates I no longer need.
- [ ] Given my organization has team-level access, when an admin saves a template, then it is optionally shareable with the whole org as a "shared template".

## Notes

Credentials are intentionally excluded from templates for security reasons — users must supply auth per scan. Templates should be exportable as JSON to enable version control and sharing outside the platform (dependency on US-041 for JSON export format).

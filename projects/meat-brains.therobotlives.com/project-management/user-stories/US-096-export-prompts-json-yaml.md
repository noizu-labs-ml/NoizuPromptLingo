---
id: US-096
title: "Export Own Prompts as JSON or YAML"
slug: "export-own-prompts-json-yaml"
personas: [P-001, P-003, P-005, P-007]
epic: "Integration & API"
priority: "could-have"
complexity: "S"
tags: [export, data-portability, json, yaml, api, developer]
---

# US-096: Export Own Prompts as JSON or YAML

## User Story

**As a** Prompt Engineer (P-001) or ML Researcher (P-003),
**I want to** export all of my published prompts as a structured JSON or YAML file,
**So that** I can back up my work, migrate to another platform, or use my prompts in local tooling.

## Acceptance Criteria

- [ ] Given a logged-in user navigates to their profile settings, when they select "Export my prompts," then they are offered a choice of JSON or YAML format
- [ ] Given the user selects a format and confirms, when the export is triggered, then a file is generated containing all their public and private prompts with full metadata (id, title, body, tags, model, created_at, vote_score)
- [ ] Given the export contains more than 100 prompts, when generation takes more than 2 seconds, then the file is generated asynchronously and a download link is emailed to the user when ready
- [ ] Given the exported file is downloaded, when a developer inspects its structure, then each prompt entry is self-contained and includes all fields needed to re-import it to a compatible system

## Notes

The export format should be documented in the API docs (US-093) as an importable schema to encourage ecosystem tooling. Private prompts must only be included in exports by the prompt's own author and must be clearly marked as `visibility: private` in the export. Export requests should be rate-limited to prevent abuse (e.g., one full export per hour).

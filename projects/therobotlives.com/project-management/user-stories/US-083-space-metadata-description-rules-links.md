---
id: US-083
title: "Space Metadata (Description, Rules, Links)"
slug: "space-metadata"
personas: [P-001, P-003, P-007]
epic: "Spaces - Advanced"
priority: "could-have"
complexity: "S"
tags: [spaces, metadata, community-guidelines]
---

# US-083: Space Metadata (Description, Rules, Links)

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** add rich metadata to the spaces I own including description, community rules, and external links,
**So that** community members understand the space's purpose and guidelines.

## Acceptance Criteria

- [ ] Given I am a space owner, when I edit space settings, then I can provide: a description (markdown, 500 chars), community rules (markdown list), and external links (URLs with labels)
- [ ] Given I add a description "A space for sharing and critiquing ChatGPT prompts", when I save, then the description appears on the space's homepage
- [ ] Given I add community rules like "No prompt dumping—include context when sharing", when I view the space, then a "Community Rules" card displays the rules
- [ ] Given I add links to "Our Discord" and "Prompt Library", when users view the space sidebar, then they see clickable links to external resources
- [ ] Given I don't provide a description or rules, when the space renders, then these sections are hidden (no empty placeholders)

## Notes

Links section should support up to 5 external links. Links open in new tabs for better UX.
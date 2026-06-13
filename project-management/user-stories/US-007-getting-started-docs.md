---
id: US-007
title: "View getting-started documentation"
slug: "getting-started-docs"
personas: [P-002, P-004, P-008]
epic: "Installation & Onboarding"
priority: "should-have"
complexity: "M"
tags: [documentation, onboarding, noizurpg.com, guides]
---

# US-007: View Getting-Started Documentation

## User Story

**As an** interactive fiction author, tabletop GM, or CS educator (P-002, P-004, P-008),
**I want to** access clear, well-structured getting-started documentation on noizurpg.com,
**So that** I can understand what NoizuRPG does, how its components relate, and follow a guided path from zero to a working game.

## Acceptance Criteria

- [ ] Given I visit noizurpg.com/docs/getting-started, when the page loads, then I see a structured guide with sections: Overview, Prerequisites, Installation, Quick Start, Next Steps — in that order.
- [ ] Given the documentation site, when I navigate between doc pages, then each page loads within 2 seconds and the left sidebar shows my current location in the doc tree.
- [ ] Given the "Overview" section, when I read it, then it explains the six core components (Character System, World State Manager, Narrative Engine, Quest Engine, Dialogue Manager, Memory System) in plain language without requiring prior framework knowledge.
- [ ] Given a CS educator (P-008) using the docs in a classroom, when they navigate to any code example, then the example includes a plain-language explanation of what each code block does suitable for students unfamiliar with RPG frameworks.
- [ ] Given the documentation, when I search for a term using the site search, then relevant pages appear in results ranked by relevance within 1 second.
- [ ] Given the documentation site, when I view it on a screen reader, then all navigation elements have proper ARIA labels and the reading order follows the visual hierarchy.

## Notes

Mei (P-008) needs the docs to be pedagogically clear enough to assign as coursework. Elena (P-002) needs the docs to address narrative design patterns, not just technical APIs. Documentation should be versioned to match PyPI releases. See US-010 for the API reference story and US-002 for the quick-start tutorial story.

---
id: US-088
title: "Tag and categorize archived prompts"
personas: [sarah-kim]
domain: prompt-archival
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to tag and categorize archived prompts by domain, agent role, effectiveness, and custom labels so that my team can quickly find relevant prompts and identify which approaches work best for specific tasks.

## Acceptance Criteria

- [ ] Prompts can be tagged with system-provided categories (domain, agent role, task type) and user-defined custom labels
- [ ] An effectiveness tag (e.g., "proven", "experimental", "deprecated") can be set per prompt version to signal reliability
- [ ] Tag-based search and filtering works across all archived prompts with boolean operators (AND, OR, NOT)
- [ ] Bulk tagging is supported — select multiple prompt versions and apply tags in one action
- [ ] Tags are visible in the timeline view and searchable from the global search bar

## Notes

Tagging turns the prompt archive from a flat history into a navigable knowledge base. For Sarah's team context, the key use case is knowledge transfer: when onboarding a new team member, they can filter prompts by "proven" + "code-review" to see what works. The system-provided categories should auto-populate from the agent's metadata where possible (e.g., if an agent is assigned to the "backend" project, tag its prompts accordingly). Consider suggesting tags based on prompt content using lightweight NLP.

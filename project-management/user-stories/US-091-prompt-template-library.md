---
id: US-091
title: "Maintain a shared prompt template library"
personas: [james-oduya]
domain: prompt-archival
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **James Oduya (Agency Owner)**, I want to maintain a shared prompt template library with base templates for common agent roles so that my team can spin up consistently configured agents across client projects without reinventing prompts from scratch.

## Acceptance Criteria

- [ ] A template library view lists all available prompt templates organized by category (code review, triage, documentation, client reporting, etc.)
- [ ] Each template includes: base system prompt, recommended tool permissions, default constraints, and usage notes describing ideal contexts
- [ ] Templates can be forked into project-specific instances that maintain a link back to the base template for future upstream updates
- [ ] Template authors can publish updates that downstream forks can pull in selectively (cherry-pick changes, not forced updates)
- [ ] Access controls support library-level permissions: some templates are agency-wide, others are team-private or client-specific

## Notes

For an agency managing multiple client projects, prompt consistency is a quality control mechanism. The fork-and-track model borrows from package management: base templates are like upstream packages, project instances are like pinned versions with local patches. James needs templates that encode his agency's standards (response tone, escalation thresholds, reporting formats) while allowing per-client customization. The library should ship with a handful of high-quality starter templates out of the box so new users aren't staring at a blank screen. Consider a community template marketplace in future phases.

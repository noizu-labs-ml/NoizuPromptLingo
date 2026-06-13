---
id: US-065
title: "Design Custom Lab from Catalog Technique"
slug: "design-custom-lab-from-catalog-technique"
personas: [P-001, P-002]
epic: "Academy — Labs"
priority: "won't-have-yet"
complexity: "XL"
tags: [academy, labs, custom, authoring, enterprise, catalog]
---

# US-065: Design Custom Lab from Catalog Technique

## User Story

**As an** AI red team lead (P-001),
**I want to** design a custom private lab by selecting a catalog technique, configuring a target LLM, and authoring a challenge briefing and scoring rubric,
**So that** my team can train against techniques specific to our product's attack surface rather than only generic public labs.

## Acceptance Criteria

- [ ] Given I am on an enterprise plan, when I navigate to the Lab Builder, then I can create a new custom lab by selecting one or more catalog techniques as the basis
- [ ] Given I have selected techniques, when I fill out the lab builder form, then I can configure: lab title, briefing narrative, learning objectives, target LLM endpoint (platform sandbox or custom API key), difficulty rating, hint tier content (at least 3 tiers), and scoring criteria
- [ ] Given I have authored a lab, when I click "Preview," then I can launch the lab as a participant would experience it, in a sandbox session that uses my configuration
- [ ] Given I publish a custom lab (scoped to my team), when team members browse Academy, then the custom lab appears in a "Custom Labs" section visible only to my team
- [ ] Given a custom lab is published, when a team member completes it, then scoring and progress tracking work identically to native platform labs, and completions appear in the team dashboard

## Notes

This is the highest-complexity feature in the entire Academy epic and should not be built until the core sandbox infrastructure (US-053), scoring engine (US-054), and team management (US-061 to US-063) are stable. The Lab Builder is an enterprise differentiator that justifies premium pricing. Authored labs should go through a basic automated safety review before activation to prevent misuse.

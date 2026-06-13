---
id: US-030
title: "Create and apply project templates"
personas: [james-oduya]
domain: projects
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **James Oduya (Agency Owner)**, I want to create project templates from past successful projects and apply them to new engagements so that I don't rebuild project structures from scratch every time.

## Acceptance Criteria

- [ ] Any existing project can be saved as a template, capturing: methodology configuration, workflow states, item templates (with relative dates, not absolute), role definitions, agent configurations, and label/tag taxonomy
- [ ] Templates are stored in a workspace-level template library with name, description, and tags for discoverability
- [ ] Applying a template to a new project creates the full structure with placeholder items, and prompts for project-specific values (client name, start date, team members)
- [ ] Templates support parameterized items where specific values (dates, names, URLs) are filled in during application via a setup wizard
- [ ] Templates can be versioned — updating a template does not affect projects already created from it, but a diff view shows what changed for manual adoption

## Notes

For an agency, project templates are institutional knowledge. A "Website Redesign" template that captures the team's proven workflow, standard phases, and known risks is enormously valuable. Consider a marketplace or sharing mechanism for templates in the future. Templates should capture agent configurations too — which agents to attach and how they're configured.

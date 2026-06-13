---
id: US-067
title: "Manage library of item, project, and workflow templates"
personas: [james-oduya]
domain: checklists
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **James Oduya (Agency Owner)**, I want to manage a library of item templates, project templates, and workflow templates so that I can spin up new client projects with consistent structure in minutes instead of hours.

## Acceptance Criteria

- [ ] Template library supports three template types: item templates, project templates (full hierarchy), and workflow templates
- [ ] Project templates can include pre-configured items, checklists, workflows, labels, and agent assignments
- [ ] Templates support parameterized variables (client name, start date, team size) resolved on instantiation
- [ ] Library has search, tagging, and categorization for managing templates at scale (50+)
- [ ] Template versioning: updates to a template do not affect already-instantiated projects

## Notes

James runs multiple client projects with different methodologies (Scrum, Kanban, hybrid). A project template should encode the full methodology choice. This is the agency power feature: "new client onboarding" becomes a single template instantiation. Consider a marketplace/sharing model in future phases where templates can be shared across organizations.

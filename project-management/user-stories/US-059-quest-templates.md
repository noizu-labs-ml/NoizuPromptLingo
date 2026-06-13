---
id: US-059
title: "Quest Templates for Game Designers"
slug: "quest-templates"
personas: [P-002, P-008]
epic: "Quest Engine"
priority: "should-have"
complexity: "M"
tags: [quest-engine, templates, designer-tools, reuse]
---

# US-059: Quest Templates for Game Designers

## User Story

**As an** interactive fiction author (P-002),
**I want to** instantiate quests from parameterized templates with variable substitution,
**So that** I can author reusable quest archetypes (fetch, escort, investigate) and stamp out concrete instances without duplicating quest logic.

## Acceptance Criteria

- [ ] Given a quest template registered with `QuestEngine.register_template(template_def)` containing `{{target_npc}}` and `{{location}}` placeholders, when `quest_engine.instantiate_template("fetch_item", target_npc="Alara", location="Thornwood")` is called, then the returned `QuestDefinition` has all placeholders replaced with the supplied values.
- [ ] Given `instantiate_template()` called without a required template variable, when the template specifies that variable as `required: true`, then a `TemplateMissingVariableError` is raised naming the missing variable.
- [ ] Given a template with `default_values: {difficulty: "medium"}`, when `instantiate_template()` is called without supplying `difficulty`, then the instantiated quest uses `"medium"` for that field.
- [ ] Given `quest_engine.list_templates()` called on an engine with three registered templates, then the returned list contains exactly three entries each with `id`, `name`, `description`, and `variables` fields.
- [ ] Given a template instantiation, when `quest_def.source_template_id` is accessed on the resulting definition, then it returns the ID of the template it was derived from.
- [ ] Given a template with a `stages` list where stage descriptions contain placeholders, when the template is instantiated, then placeholder substitution applies to nested string fields including stage descriptions and objective text.

## Notes

Mei Zhang (P-008) uses templates to generate classroom quest examples from a single canonical template. Template variable types should support string, integer, and list substitution. Pairs well with US-052 (procedural generation can emit template-compatible variable sets).

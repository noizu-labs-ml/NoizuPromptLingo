---
id: US-009
title: "Import existing project configuration"
slug: "import-project-config"
personas: [P-006]
epic: "Installation & Onboarding"
priority: "could-have"
complexity: "M"
tags: [import, configuration, migration, studio, yaml]
---

# US-009: Import Existing Project Configuration

## User Story

**As a** game studio lead (P-006),
**I want to** import an existing game project's configuration (characters, world, quests) into NoizuRPG from a structured YAML or JSON bundle,
**So that** my team can migrate an existing game design document or prototype into the framework without manually re-entering all data.

## Acceptance Criteria

- [ ] Given a valid NoizuRPG export bundle (`.noizu` zip file containing `config.yaml`, `characters/`, `worlds/`, and `quests/` directories), when I run `noizurpg import ./my-game.noizu`, then all entities are loaded into the project directory without data loss.
- [ ] Given a partial import bundle that contains only a `characters/` directory, when I run `noizurpg import ./characters-only.noizu`, then only the character files are imported and existing project files outside that scope are unchanged.
- [ ] Given an import bundle with a schema version older than the current NoizuRPG version, when I run `noizurpg import`, then the CLI prints a migration warning listing any fields that were deprecated and how they were mapped to current schema fields.
- [ ] Given an import bundle containing a character with a name that conflicts with an existing character in the project, when I run `noizurpg import`, then the CLI prompts: "Character 'Aria' already exists. [S]kip / [O]verwrite / [R]ename?" before proceeding.
- [ ] Given a malformed or corrupt import bundle, when I run `noizurpg import`, then the CLI exits with a non-zero status and prints a validation error identifying the first malformed file and line number.

## Notes

This story addresses Aisha's (P-006) need to migrate legacy game prototypes into NoizuRPG for studio-scale production. The `.noizu` bundle format should be the same format produced by `noizurpg export` to enable round-trip fidelity. Schema versioning is essential for long-term maintainability across NoizuRPG releases.

---
id: US-078
title: "Enable a skill for a provider"
slug: enable-skill-for-provider
personas: [P-004, P-008]
epic: "skill-manage (core)"
priority: must-have
complexity: medium
tags: [skill-manage, deploy]
---

# US-078: Enable a Skill for a Provider

## User Story

**As a** skill-authoring developer advocate (or multi-provider agent tinkerer)
**I want to** run `skill-manage enable skills <name> --provider <provider>` and have it symlink the artifact into that provider's install root
**So that** a skill I've configured becomes immediately usable by that provider, with confirmation of exactly where it landed

## Acceptance Criteria

- **Given** a skill named `<name>` exists in the catalog source directory but is not yet linked for `--provider claude`
  **When** I run `skill-manage enable skills <name> --provider claude`
  **Then** a symlink is created from Claude's install root to the skill's source directory, and the command prints the resulting link path

- **Given** the skill is already enabled for that provider
  **When** I run the same enable command again
  **Then** the command reports it's already enabled (idempotent) rather than erroring or creating a duplicate/broken link

- **Given** I specify a provider name that isn't recognized (e.g. `--provider gemini`, which is currently stubbed)
  **When** I run the enable command
  **Then** it fails with a clear message indicating that provider's importer is not yet live, rather than attempting a partial link

- **Given** the enable succeeds
  **When** I subsequently run `skill-manage list`
  **Then** the newly enabled skill shows as enabled for that provider (consistent with US-077's catalog view)

## Notes
Tobias uses `enable` as the final rollout step after configuring a skill's metadata via the Convert wizard's candidate panel; Yusuf checks that the resulting symlink path is correct before trusting cross-harness parity. Gemini/OpenCode/Aider remain stubbed per product context, so those should fail clearly rather than partially succeed.

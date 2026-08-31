---
id: US-077
title: "Catalog skills/agents/commands across providers"
slug: catalog-skills-agents-commands-across-providers
personas: [P-004, P-008]
epic: "skill-manage (core)"
priority: must-have
complexity: medium
tags: [skill-manage, catalog]
---

# US-077: Catalog Skills/Agents/Commands Across Providers

## User Story

**As a** skill-authoring developer advocate (or multi-provider agent tinkerer)
**I want to** run `skill-manage` and have it scan all provider install roots (Claude, Codex, Grok) and list every skill/agent/command with its enabled/disabled state per provider
**So that** I can see at a glance where each artifact is deployed and spot gaps in parity across providers

## Acceptance Criteria

- **Given** skills, agents, and commands exist in the catalog source directory and are symlinked into some but not all provider install roots
  **When** I run `skill-manage list` (or the TUI's catalog view)
  **Then** every artifact is listed once with a per-provider column (Claude / Codex / Grok) showing enabled or disabled for each

- **Given** an artifact is symlinked into a provider's install root but the source file has since been deleted
  **When** the catalog scan runs
  **Then** that artifact is flagged as a broken/dangling link for that provider rather than silently omitted

- **Given** I filter the catalog by type
  **When** I run `skill-manage list --type skill` (or equivalent)
  **Then** only skills are shown, excluding agents and commands

- **Given** a provider install root doesn't exist on this machine (e.g. Codex never installed)
  **When** the scan runs
  **Then** that provider's column shows "not installed" rather than every artifact appearing disabled for it

## Notes
This is the foundation Yusuf relies on to keep Claude/Codex/Grok in parity and that Tobias checks before deciding where to roll out a newly authored skill via `enable` (US-078).

---
id: US-007
title: "CLI init bootstraps config"
slug: cli-init-bootstraps-config
personas: [P-001]
epic: "Onboarding & Install"
priority: must-have
complexity: low
tags: [onboarding, cli, config]
---

# US-007: CLI Init Bootstraps Config

## User Story

**As a** solo power-user developer who lives in the CLI
**I want to** run `llm-toolkit init` and get a default config file with sane defaults
**So that** I can start using `recent`/`search`/`show` right away without hand-writing a config or answering unnecessary prompts

## Acceptance Criteria

- **Given** no config file exists yet
  **When** the user runs `llm-toolkit init`
  **Then** a config file is created with sane defaults for index path, embedding model, and API port, without prompting for values already inferable (e.g. default `~/.claude/projects` location, default local API port)

- **Given** `llm-toolkit init` completes
  **When** it finishes
  **Then** it prints the path to the created config file and a one-line summary of the defaults applied

- **Given** a config file already exists
  **When** the user runs `llm-toolkit init` again
  **Then** it does not overwrite the existing config silently — it reports that a config already exists and exits without modification, or requires an explicit `--force` flag to overwrite

## Notes
Complements US-002 (the GUI first-run wizard) as the CLI-only equivalent for Marcus (P-001), who "lives in CLI" and would consider a prompt-heavy `init` an interruption to his workflow across multiple client repos.

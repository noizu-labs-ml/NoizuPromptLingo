---
id: US-079
title: "Batch-enable a skill bundle"
slug: batch-enable-skill-bundle
personas: [P-008]
epic: "skill-manage (core)"
priority: should-have
complexity: medium
tags: [skill-manage, deploy, bundle]
---

# US-079: Batch-Enable a Skill Bundle

## User Story

**As a** multi-provider agent tinkerer
**I want to** run `skill-manage enable-set --work-type <type>` and enable a curated bundle of skills/agents in one command
**So that** I can quickly set up an environment for a given kind of work without manually enabling each skill one at a time

## Acceptance Criteria

- **Given** a curated bundle named `<type>` (e.g. `web-dev`) is defined, mapping to a list of skill/agent names
  **When** I run `skill-manage enable-set --work-type web-dev --provider claude`
  **Then** every skill/agent in that bundle is enabled for the specified provider in a single command, with a summary line per artifact (enabled / already-enabled / failed)

- **Given** one artifact in the bundle fails to enable (e.g. missing source file)
  **When** the batch operation runs
  **Then** it continues enabling the remaining artifacts in the bundle and reports the failure(s) in the summary rather than aborting the whole batch

- **Given** I run `enable-set` without specifying `--provider`
  **When** the command executes
  **Then** it enables the bundle for all installed (non-stubbed) providers, consistent with how `enable` behaves per-provider

- **Given** I run `skill-manage list` after a successful `enable-set`
  **When** I inspect the catalog
  **Then** every artifact from the bundle shows enabled for the target provider(s)

## Notes
Yusuf switches between provider setups often and wants a one-command way to stand up a consistent bundle instead of chaining multiple `enable` calls; he'd check context-budget usage afterward before committing to the full bundle on a constrained provider.

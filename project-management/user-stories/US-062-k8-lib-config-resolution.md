---
id: US-062
title: "Resolve config from k8-lib conventions"
slug: k8-lib-config-resolution
personas: [P-003]
epic: "Installation & Configuration"
priority: should-have
complexity: low
tags: [config, k8-lib, resolution, convention]
---

# US-062: Resolve config from k8-lib conventions

## User Story

**As a** DevOps engineer using the broader devops toolchain
**I want to** the tool to follow k8-lib config resolution conventions
**So that** it integrates seamlessly with the rest of the toolchain

## Acceptance Criteria

- **Given** `--config <path>` is specified
  **When** the tool starts
  **Then** the specified config is used

- **Given** `K8_CONFIG` env var is set
  **When** no `--config` flag
  **Then** the env var path is used

- **Given** neither flag nor env var
  **When** the tool starts
  **Then** it walks up from the CWD to find `infra-config.yaml`

## Notes
Resolution order: `--config` → `K8_CONFIG` env → git-root walker. Same as other devops tools.

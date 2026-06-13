---
id: US-064
title: "Process manifest file for cross-directory batches"
slug: manifest-support
personas: [P-003]
epic: "Installation & Configuration"
priority: could-have
complexity: medium
tags: [manifest, batch, cross-directory, yaml]
---

# US-064: Process manifest file for cross-directory batches

## User Story

**As a** DevOps engineer managing assets across multiple project directories
**I want to** use a manifest file to specify prompts from different locations
**So that** I can batch-generate assets across the entire project structure

## Acceptance Criteria

- **Given** a `--manifest assets.yaml` flag
  **When** the manifest is loaded
  **Then** prompt files from multiple directories are collected and processed in dependency order

## Notes
Planned feature. Manifest schema follows the asset-manifest-schema from the shared skills.

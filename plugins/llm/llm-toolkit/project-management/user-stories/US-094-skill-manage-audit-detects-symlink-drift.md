---
id: US-094
title: "skill-manage audit detects symlink drift"
slug: skill-manage-audit-detects-symlink-drift
personas: [P-004, P-008]
epic: "skill-manage (audit)"
priority: must-have
complexity: medium
tags: [skill-manage, audit]
---

# US-094: skill-manage Audit Detects Symlink Drift

## User Story

**As a** multi-provider agent tinkerer
**I want to** run `skill-manage audit --strict` and see every symlink that doesn't resolve to the shared source root, or that's missing or duplicated across providers
**So that** I can keep Claude, Codex, and Grok installs in verified parity instead of trusting they match

## Acceptance Criteria

- **Given** Tobias has enabled a skill across the Claude and Codex install roots
  **When** he runs `skill-manage audit --strict`
  **Then** any symlink that doesn't resolve to the shared source root is reported with its exact path

- **Given** a skill is enabled for Claude but missing from Codex's install root
  **When** audit runs
  **Then** it's reported as "missing for provider: codex" with the expected symlink path

- **Given** a skill has duplicate symlinks pointing to different source versions across providers
  **When** audit runs
  **Then** it's flagged as duplicated/inconsistent with both paths listed

- **Given** no drift exists
  **When** Yusuf runs `skill-manage audit --strict`
  **Then** it exits cleanly (exit code 0) with a "no drift detected" summary

## Notes
Supports Yusuf's core parity-check workflow across Claude/Codex/Grok, and gives Tobias a rollout-verification step right after `skill-manage enable`.

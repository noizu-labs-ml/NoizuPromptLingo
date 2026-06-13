---
id: US-084
title: "Use as engine behind content-media-engine skill"
slug: skill-integration
personas: [P-002, P-001]
epic: "Integration"
priority: must-have
complexity: medium
tags: [integration, skill, content-media-engine, agent]
---

# US-084: Use as engine behind content-media-engine skill

## User Story

**As a** content creator using the content-media-engine skill
**I want to** the skill to generate `.media.prompt` files and invoke the CLI
**So that** I get a seamless workflow from content ideation to asset production

## Acceptance Criteria

- **Given** the content-media-engine skill
  **When** it generates a media asset request
  **Then** it creates a `.media.prompt` file and calls `generate-media-prompt`

- **Given** the skill's agent playbook
  **When** a diagram or illustration is needed
  **Then** the skill selects the appropriate provider and format automatically

## Notes
The CLI is the execution engine. The skill provides the higher-level content strategy and provider selection logic.

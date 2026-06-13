---
id: US-082
title: "Follow k8-lib logging conventions"
slug: k8-lib-logging-conventions
personas: [P-003, P-005]
epic: "Integration"
priority: should-have
complexity: low
tags: [integration, k8-lib, logging, conventions]
---

# US-082: Follow k8-lib logging conventions

## User Story

**As a** DevOps engineer maintaining the toolchain
**I want to** `generate-media-prompt` to follow the same logging patterns as other devops tools
**So that** log output is consistent across the entire toolchain

## Acceptance Criteria

- **Given** k8-lib logging functions (step, ok, warn, fail)
  **When** the tool outputs messages
  **Then** the same formatting and color scheme is used

- **Given** the Rust binary
  **When** output is produced
  **Then** it matches the visual style of the bash-based devops tools

## Notes
Consistency with k8-lib logging functions (ui::step, ui::ok, ui::warn, ui::fail in Rust).

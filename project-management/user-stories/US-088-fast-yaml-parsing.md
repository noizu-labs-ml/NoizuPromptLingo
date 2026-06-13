---
id: US-088
title: "Fast YAML parsing for large directories"
slug: fast-yaml-parsing
personas: [P-003]
epic: "Performance & Scale"
priority: could-have
complexity: low
tags: [performance, yaml, parsing, startup]
---

# US-088: Fast YAML parsing for large directories

## User Story

**As a** DevOps engineer processing hundreds of prompt files
**I want to** fast YAML parsing
**So that** startup time is minimal even with many files

## Acceptance Criteria

- **Given** 100+ `.media.prompt` files in a directory tree
  **When** the tool starts
  **Then** all files are parsed in under 2 seconds

## Notes
Rust's serde_yaml is significantly faster than Python's pyyaml. The rewrite handles this well.

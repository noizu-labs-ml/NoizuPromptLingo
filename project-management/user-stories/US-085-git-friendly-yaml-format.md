---
id: US-085
title: "Git-friendly YAML prompt files"
slug: git-friendly-yaml-format
personas: [P-001, P-003]
epic: "Integration"
priority: must-have
complexity: low
tags: [integration, git, yaml, diff-friendly]
---

# US-085: Git-friendly YAML prompt files

## User Story

**As a** developer versioning assets with git
**I want to** `.media.prompt` files to be diff-friendly YAML
**So that** I can review prompt changes in pull requests

## Acceptance Criteria

- **Given** a `.media.prompt` file
  **When** I modify the prompt text
  **Then** `git diff` shows a clear, readable change

- **Given** generated output files
  **When** I don't want to version them
  **Then** I can add `*.png`, `*.mp3`, etc. to `.gitignore` while keeping the YAML tracked

## Notes
YAML is inherently diff-friendly. Refinement history as comments preserves the audit trail in git.

---
id: US-093
title: "Gemini/OpenCode/Aider harness import (stubbed)"
slug: gemini-opencode-aider-harness-import-stub
personas: [P-008]
epic: "Integration & API"
priority: wont-have
complexity: high
tags: [integration, harness, future]
---

# US-093: Gemini/OpenCode/Aider Harness Import (Stubbed)

## User Story

**As a** multi-provider agent tinkerer
**I want to** know explicitly that Gemini, OpenCode, and Aider session import are stubbed and not live
**So that** I don't rely on them for cross-harness parity before they're actually implemented

## Acceptance Criteria

- **Given** Yusuf runs `skill-manage import gemini`
  **When** the stub is invoked
  **Then** it clearly reports "not yet implemented" rather than partially importing or failing cryptically

- **Given** the same command is run for `opencode` and `aider`
  **When** each is invoked
  **Then** each reports the same explicit stub status

## Notes
wont-have — explicitly out of scope until Claude/Codex import (already live) is proven out in production, per the product context's note that these three importers are "currently stubbed, not live." Yusuf's persona reference already tracks which cross-harness importers are live vs stubbed, so this story exists to keep that signal explicit rather than silently absent.

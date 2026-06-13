---
id: US-087
title: codefresh login and local token management
issue_type: story
slug: cli-login-token-management
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: cli-and-cicd
components:
  - cli
  - backend
labels:
  - wave-2
  - cli
  - auth
assignee: null
reporter: null
epic: mvp-cli
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas: []
related_stories:
  - US-037
  - US-096
  - US-097
dependencies:
  - US-039
blocks:
  - US-096
duplicates: []
schema_refs:
  - api_tokens
  - memberships
  - organizations
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# codefresh login and local token management

## Story

As a **Senior ML Engineer**,
I want **`codefresh login` to authenticate via browser-based OAuth device flow and persist a token locally**
so that **I don't have to paste API keys into my shell history every time I switch machines**.

## Acceptance Criteria

- [ ] `codefresh login` opens the browser to a device-code activation page; polls for completion
- [ ] On success, stores token in `~/.config/codefresh/config.json` with `0600` perms
- [ ] `codefresh whoami` echoes the authenticated email + org
- [ ] `codefresh logout` purges the stored token
- [ ] Env var `CODEFRESH_API_TOKEN` overrides stored token for CI use
- [ ] `codefresh login --org=<slug>` pins a default org when user has multiple memberships

## Notes

- Device flow matches Claude Code / GitHub CLI patterns; users will recognize it
- Token is an org-scoped API token (issued via US-096)

## Out of Scope

- Interactive token pasting UX (redirect-to-dashboard approach only)
- Hardware-bound tokens / secure enclave storage (Wave 3)

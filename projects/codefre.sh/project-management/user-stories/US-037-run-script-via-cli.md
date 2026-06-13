---
id: US-037
title: Run a script via codefresh CLI with a YAML file
issue_type: story
slug: run-script-via-cli
status: in-progress
priority: P0
story_points: 5
estimated_scope: M
category: cli-and-cicd
components:
  - cli
  - backend
labels:
  - mvp
  - wave-1
  - cli
  - oss
assignee: null
reporter: null
epic: mvp-cli
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
  - nia-academic
secondary_personas: []
related_stories:
  - US-007
  - US-008
  - US-038
  - US-032
dependencies:
  - US-008
  - US-015
blocks:
  - US-038
duplicates: []
schema_refs:
  - agent_versions
  - agents
  - api_tokens
  - script_versions
  - scripts
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Run a script via codefresh CLI with a YAML file

## Story

As a **Senior ML Engineer**,
I want to **execute `codefresh run script.yaml --agent=<agent-slug>`**
so that **I can run my tests from CI without opening the web UI**.

## Acceptance Criteria

- [ ] `codefresh run <path-to-yaml> --agent=<slug>` triggers a run
- [ ] YAML is treated as an import (US-007) if the script doesn't exist, or matched by checksum against existing versions
- [ ] CLI authenticates via `CODEFRESH_API_TOKEN` env var (or `--token`)
- [ ] Progress streams to stdout (step prompt + agent message + verdict)
- [ ] On completion, full run JSON (US-032) is available at a stable URL or `--out=<path>`
- [ ] CLI supports `--org=<slug>` when user's token has access to multiple orgs

## Notes

- This is the OSS wedge — critical for Alex and Nia
- CLI is separate binary (likely Go or Elixir Burrito) to ship single-file

## Out of Scope

- Persona fan-out via CLI (Wave 2, `--personas=a,b,c`)
- Watch-mode / auto-rerun on file change (Wave 3)
- `codefresh init` project scaffolding (Wave 2)

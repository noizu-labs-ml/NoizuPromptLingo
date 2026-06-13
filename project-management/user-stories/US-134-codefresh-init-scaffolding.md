---
id: US-134
title: codefresh init — project scaffolding
issue_type: story
slug: codefresh-init-scaffolding
status: in-progress
priority: P2
story_points: 3
estimated_scope: S
category: cli-and-cicd
components:
  - cli
labels:
  - wave-3
  - cli
  - scaffolding
assignee: null
reporter: null
epic: mvp-cli
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - alex-oss-maintainer
  - priya-ml-engineer
secondary_personas: [] 
related_stories:
  - US-037
  - US-087
dependencies:
  - US-087
blocks: []
duplicates: []
schema_refs: []
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# codefresh init — project scaffolding

## Story

As an **OSS Framework Maintainer**,
I want **`codefresh init` to scaffold a CodeFresh project in the current directory with a sample script, CI config, and .gitignore**
so that **my framework's users can "get started with agent testing" in 30 seconds**.

## Acceptance Criteria

- [ ] `codefresh init` creates `codefresh/` directory with: sample `script.yaml`, `agents.yaml`, `.gitignore`, `README.md`
- [ ] Interactive prompts: project name, default agent adapter (openai/anthropic), CI system (github-actions/gitlab/none)
- [ ] Produces a workable configuration that runs via `codefresh run codefresh/script.yaml` immediately
- [ ] `--template=<name>` flag uses a built-in template pack (basic, ai-assistant, rag-eval, adversarial)
- [ ] `--force` overwrites existing scaffolding

## Notes

- Templates ship with the CLI binary; adding new templates requires a CLI release

## Out of Scope

- Remote template fetching (`--template=github:user/repo`) — Wave 3+
- Interactive graph editor in the CLI (never)

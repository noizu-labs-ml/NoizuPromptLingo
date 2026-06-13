---
id: US-112
title: Inline comments on script nodes
issue_type: story
slug: node-inline-comments
status: cancelled
priority: P2
story_points: 3
estimated_scope: S
category: script-authoring
components:
  - backend
  - frontend
labels:
  - wave-3
  - authoring
  - collaboration
assignee: null
reporter: null
epic: mvp-authoring
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
  - sofia-product-manager
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-002
dependencies:
  - US-002
blocks: []
duplicates:
  - US-045
schema_refs:
  - node_comments
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Inline comments on script nodes

## Story

As a **QA Lead**,
I want to **leave reviewer comments on script nodes without changing the published YAML**
so that **my author-reviewer workflow has a home in the tool rather than bouncing to Slack**.

## Acceptance Criteria

- [ ] Comment thread pinned to a `script_node_id` (not version-scoped — follows the node across versions)
- [ ] Comments show author, timestamp, markdown body
- [ ] Unresolved comments surface as a badge on the node in the graph
- [ ] Resolve / unresolve action; resolved threads collapsible
- [ ] Comments do NOT roundtrip through YAML export (editor-only metadata)

## Notes

- New `node_comments` table — schema addition folds into post-Wave-3 alignment pass

## Out of Scope

- Comment reactions / emoji (Wave 3+)
- @mention notifications (Wave 3+)

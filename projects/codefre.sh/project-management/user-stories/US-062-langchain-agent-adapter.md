---
id: US-062
title: Configure a LangChain agent adapter
issue_type: story
slug: langchain-agent-adapter
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: agent-connectors
components:
  - backend
  - frontend
labels:
  - wave-2
  - agents
  - adapters
assignee: null
reporter: null
epic: mvp-agents
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - alex-oss-maintainer
  - priya-ml-engineer
secondary_personas: []
related_stories:
  - US-012
  - US-063
dependencies:
  - US-012
blocks: []
duplicates: []
schema_refs:
  - agent_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Configure a LangChain agent adapter

## Story

As an **OSS Framework Maintainer**,
I want to **configure a LangChain agent adapter that connects to a user-hosted LangServe endpoint**
so that **users of `agent-kit-oss` and similar LangChain-based frameworks can test their agents without running them through OpenAI/Anthropic directly**.

## Acceptance Criteria

- [ ] "New Agent" picker includes `langchain` adapter
- [ ] User supplies `endpoint_url` (LangServe-compatible) + optional auth headers via `auth_ref`
- [ ] Request template maps CodeFresh messages to LangServe's input schema (configurable JSONPath)
- [ ] Response template extracts the agent turn via `response_jsonpath`
- [ ] Health check (US-013) probes the LangServe endpoint's `/invoke` with a minimal ping

## Notes

- LangServe and arbitrary LangChain-runnable-serving frameworks vary in schema; the mapping UI must be flexible
- This adapter is part of Alex's advocacy plan — needs to work cleanly out-of-box

## Out of Scope

- LangChain tool-use schema translation (LangChain tools are framework-wrapped; out of our scope)
- LangGraph-specific stateful flows (Wave 3)

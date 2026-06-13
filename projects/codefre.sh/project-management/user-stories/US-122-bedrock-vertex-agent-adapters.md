---
id: US-122
title: Bedrock and Vertex AI agent adapters
issue_type: story
slug: bedrock-vertex-agent-adapters
status: in-progress
priority: P2
story_points: 5
estimated_scope: M
category: agent-connectors
components:
  - backend
  - frontend
labels:
  - wave-3
  - agents
  - adapters
  - cloud
assignee: null
reporter: null
epic: mvp-agents
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas: []
related_stories:
  - US-012
  - US-061
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
updated_at: "2026-04-21"
---

# Bedrock and Vertex AI agent adapters

## Story

As a **Senior ML Engineer**,
I want **first-party adapters for AWS Bedrock and GCP Vertex AI**
so that **enterprise teams running agents through cloud-provider model catalogs can test them natively without building a custom HTTP adapter**.

## Acceptance Criteria

- [ ] `bedrock` adapter: IAM auth via `auth_ref` (role ARN pointer), model selector covers Claude + Titan + Mistral families on Bedrock
- [ ] `vertex` adapter: GCP service-account auth, model selector covers Gemini family and Model Garden
- [ ] Both adapters handle provider-specific quirks (Bedrock inference profiles, Vertex regional endpoints)
- [ ] Cost rates for Bedrock / Vertex models bundled with app config

## Notes

- IAM/GCP auth is tricky; use the HTTP adapter as fallback for esoteric configs

## Out of Scope

- Azure OpenAI (Wave 3+)
- On-prem model adapters (vLLM, TGI) — Wave 3+

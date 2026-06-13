---
id: US-083
title: "Create custom agents with user-defined roles and constraints"
personas: [lin-zhao]
domain: agents
priority: high
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to create custom agents with user-defined roles, prompts, tool access, and behavioral constraints so that I can tailor agent capabilities to my organization's specific workflows and governance requirements.

## Acceptance Criteria

- [ ] A custom agent builder provides fields for: name, role description, system prompt, allowed tools, denied tools, behavioral constraints, and escalation rules
- [ ] Tool access is configured via a granular permission matrix — each MCP tool can be individually allowed, denied, or set to require-human-approval
- [ ] Behavioral constraints support natural language rules (e.g., "never modify production databases", "always request review before merging")
- [ ] Custom agents can be saved as templates for reuse across projects and teams
- [ ] A dry-run mode lets users test a custom agent's behavior against sample tasks before activating it in production

## Notes

This is a power-user feature that differentiates tobornalp from platforms where agents are fixed roles. The constraint system must be enforceable, not advisory — if a tool is denied, the agent physically cannot invoke it, not just "shouldn't." The system prompt and constraints together form the agent's "charter" and should be versioned (ties to the prompt-archival domain). Consider providing starter templates for common roles: code reviewer, triage bot, standup summarizer, documentation writer.

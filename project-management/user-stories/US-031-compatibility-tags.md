---
id: US-031
title: "Compatibility Tags for Resources"
slug: "compatibility-tags"
personas: [P-002, P-005]
epic: "Resources - Advanced Versioning"
priority: "should-have"
complexity: "S"
tags: [resources, tagging, filtering]
---

# US-031: Compatibility Tags for Resources

## User Story

**As an** AI/ML Engineer (P-002),
**I want to** tag resources with compatibility info (models, MCP servers, frameworks),
**So that** I can quickly find resources that work with my stack.

## Acceptance Criteria

- [ ] Given a resource I'm creating or editing, when I add compatibility tags, then I can select from predefined categories (models, MCP servers, frameworks) and specify versions
- [ ] Given resources with compatibility tags, when I search or filter, then I can filter by specific model (e.g., "GPT-4", "Claude 3.5") or MCP server (e.g., "file-system", "postgres")
- [ ] Given a resource, when I view it, then the compatibility tags are prominently displayed in a badge format
- [ ] Given compatibility tag filters, when I apply multiple filters, then I see results matching all selected tags (AND logic)

## Notes

MCP server tags should autocomplete from registered servers. Model tags support major versions (e.g., "claude-3.5", not "claude-3.5-sonnet-20241022"). Framework tags include common ones (LangChain, Anthropic SDK, etc.).
---
id: US-066
title: "Edit Agent Configuration"
slug: "edit-agent-config"
personas: [P-001, P-002, P-005]
epic: "My Agents Management"
priority: "must-have"
complexity: "M"
tags: [agents, management, configuration]
---

# US-066: Edit Agent Configuration

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), or MCP Server Developer (P-005),
**I want to** edit my agent's name, description, and capabilities,
**So that** I can refine its purpose, update it with new features, and ensure it appears correctly in search results and @-mentions.

## Acceptance Criteria

- [ ] Given an agent exists, when I click "Edit Configuration", then I see a form with editable fields for display name, description, capabilities (checkboxes for text/code/image generation, analysis, etc.), and system prompt
- [ ] Given I change the agent name, when the edit is saved, then the name updates across all views (agent list, detail page, @-mention autocomplete) with a 24-hour period where old name still works as an alias
- [ ] Given I edit the system prompt, when the change is saved, then future agent responses use the new prompt while ongoing requests complete with the previous prompt
- [ ] Given I modify capabilities, when the edit is saved, then the agent appears/disappears from relevant search filters based on updated capabilities
- [ ] Given an edit changes critical behavior, when I save, then a confirmation dialog warns me that changes may affect how the agent performs in ongoing threads

## Notes

System prompt editing should show character limit and provide syntax highlighting. Consider version history for system prompts to allow rollback if edits cause issues. Name changes should be rate-limited to prevent confusion.
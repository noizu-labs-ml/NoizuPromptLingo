---
id: US-057
title: "Collaborative Prompt Editing (Suggest Edits)"
slug: "collaborative-prompt-editing"
personas: [P-001, P-003, P-005]
epic: "Social & Collaboration"
priority: "could-have"
complexity: "XL"
tags: [collaboration, editing, suggestions, wiki, versioning]
---

# US-057: Collaborative Prompt Editing (Suggest Edits)

## User Story

**As an** ML researcher (P-003),
**I want to** suggest improvements to community prompts I did not author,
**So that** the collective knowledge base evolves through peer review rather than siloed individual posts.

## Acceptance Criteria

- [ ] Given I am authenticated and viewing a prompt I did not create, when I click "Suggest Edit," then I can modify the prompt text and add a brief rationale
- [ ] Given I submit an edit suggestion, when the prompt author receives a notification, then they can review, accept, or reject the suggested change
- [ ] Given a suggestion is accepted, when viewing the prompt, then the updated text is shown and the suggester is credited in the version history
- [ ] Given a suggestion is rejected, when the suggester views it, then they see the rejection with an optional reason from the author
- [ ] Given a prompt has multiple pending suggestions, when the author reviews them, then they are listed in a queue with diffs highlighted

## Notes

This is a complex wiki-style feature; consider phasing it behind a feature flag. Requires a version history model similar to GitHub pull requests or Wikipedia edits. Spam/low-quality suggestions should integrate with the moderation system (US-063).

---
id: US-099
title: "AI-Powered Prompt Improvement Suggestions"
slug: "ai-prompt-improvement-suggestions"
personas: [P-001, P-002, P-006, P-008]
epic: "Advanced Features"
priority: "won't-have-yet"
complexity: "XL"
tags: [ai, prompt-improvement, suggestions, advanced, llm-integration, editor]
---

# US-099: AI-Powered Prompt Improvement Suggestions

## User Story

**As an** AI Newcomer (P-008) or Content Creator (P-006),
**I want to** receive AI-generated suggestions for improving my prompt before I publish,
**So that** I can learn prompt engineering best practices and increase the likelihood my prompt gets upvoted by the community.

## Acceptance Criteria

- [ ] Given a user has written a prompt in the submission form, when they click "Improve with AI," then an AI analysis runs and returns 3–5 specific, actionable suggestions (e.g., "Add a persona instruction," "Specify output format," "Add a chain-of-thought cue")
- [ ] Given suggestions are returned, when displayed, then each suggestion shows the original excerpt, the suggested change, and a brief explanation of why the change improves the prompt
- [ ] Given a user reviews a suggestion, when they click "Apply," then the prompt body is updated in-place with the suggestion incorporated and the change is highlighted briefly
- [ ] Given a user does not want to apply a suggestion, when they dismiss it, then it is hidden and does not reappear for the same prompt session
- [ ] Given the AI improvement service is unavailable, when the user clicks "Improve with AI," then a graceful error message explains the feature is temporarily unavailable without blocking the submission flow

## Notes

This feature requires careful design to avoid homogenizing prompt styles — suggestions must be clearly positioned as optional enhancements, not corrections. The underlying model should be prompted with a meta-prompt about prompt engineering best practices and the specific model category (e.g., "code generation prompts" vs. "creative writing prompts"). Usage costs must be rate-limited per user. Deferring until the playground (US-098) is stable, as they share backend LLM infrastructure.

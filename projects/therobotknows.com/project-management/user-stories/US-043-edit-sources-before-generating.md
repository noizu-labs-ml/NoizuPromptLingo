---
id: US-043
title: "Edit Sources Before Generating"
slug: "edit-sources-before-generating"
personas: [P-001, P-003]
epic: "Generation Engine"
priority: "should-have"
complexity: "M"
tags: [generation, rag, sources, context, control, canon]
---

# US-043: Edit Sources Before Generating

## User Story

**As a** epic novelist who wants precise control over which canon entries influence a generation (P-001),
**I want to** review and edit the auto-selected source entries before submitting a generation request,
**So that** I can remove irrelevant context and add specific entries I know should influence the output.

## Acceptance Criteria

- [ ] Given I have entered a prompt in the Generation Studio, when I click "Review Sources", then the system shows the canon entries it has auto-selected as context (ranked by relevance).
- [ ] Given the source list is displayed, when I remove an entry from the list, then it will not be included as context in the generation.
- [ ] Given the source list is displayed, when I search for and add a canon entry manually, then it is added to the context list for this generation.
- [ ] Given I have edited the source list, when I submit the generation, then only the curated list of entries is used as context (auto-retrieval is bypassed for this request).
- [ ] Given I make no changes to the auto-selected sources, when I submit, then generation proceeds with the auto-selected sources as normal (US-037 behavior).

## Notes

Depends on US-036, US-037, US-038. This gives power users control over the RAG context window, which directly affects generation quality and token cost. Related: US-044 (regenerate with different parameters).

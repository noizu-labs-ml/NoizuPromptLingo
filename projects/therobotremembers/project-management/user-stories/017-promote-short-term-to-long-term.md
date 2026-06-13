---
id: story-017
title: "Promote short-term memories to long-term storage"
persona: persona-the-curator
priority: must-have
complexity: M
status: draft
---

# Promote short-term memories to long-term storage

**As** The Curator,
**I want to** evaluate short-term memories after a stabilization period and promote high-value ones to long-term storage with `pinned: true` status,
**So that** important memories are protected from decay and given privileged status in the association graph.

## Acceptance Criteria
- [ ] All new memories start as `storage_tier: short-term` with an evaluation window of N hours (configurable, default 24)
- [ ] Promotion criteria: recalled at least once during the evaluation window, OR emotional intensity above threshold (>0.7 on any dimension), OR Guardian-validated as factually significant, OR explicitly promoted by Human Operator
- [ ] Promoted memories are moved to `storage_tier: long-term` with `pinned: true`, exempt from standard decay
- [ ] Long-term memories still undergo slow decay (10x slower than short-term) unless explicitly pinned by operator
- [ ] Promotion events trigger The Weaver to re-evaluate association links for the promoted memory with expanded neighbor search
- [ ] Memories not promoted after the evaluation window remain short-term and follow normal decay curves

## Scenario: Memory promoted by recall during evaluation window
- **Given** a memory about "the new API authentication flow uses OAuth2 PKCE" was formed 6 hours ago and has been recalled twice in response to developer questions
- **When** The Curator evaluates the memory at the 24-hour mark
- **Then** the memory is promoted to long-term storage with `pinned: true`, and The Weaver is notified to re-run association discovery with K=100 (expanded from default K=50)

## Scenario: Low-value memory remains short-term
- **Given** a memory about "checked the build logs, everything green" with neutral emotional metadata and zero recalls during the evaluation window
- **When** The Curator evaluates the memory at the 24-hour mark
- **Then** the memory remains `storage_tier: short-term` and follows standard decay scheduling

## Technical Notes
- The short-term → long-term distinction mirrors biological memory consolidation (hippocampal → cortical)
- The evaluation window should be tunable — some deployments may want faster promotion (4 hours) for high-throughput environments
- Consider a "promotion score" that combines recall count, emotional intensity, and association density into a single metric
- Promoted memories should get a salience boost (reset to 1.0) at promotion time

## Related Stories
- story-015: Decay scheduling treats long-term memories differently (slower decay, pinning)
- story-011: Weaver link creation is re-triggered on promotion with expanded search
- story-019: Dreamer consolidation may identify short-term memories that should be promoted based on pattern membership
- story-025: Human Operator dashboard should show promotion candidates and allow manual promotion

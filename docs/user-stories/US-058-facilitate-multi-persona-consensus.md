# US-058 - Facilitate Multi-Persona Consensus

**ID**: US-058
**Persona**: P-004 - Project Manager
**PRD Group**: coordination
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a project manager, I want to facilitate consensus among multiple personas with conflicting viewpoints so that architecture decisions have broad team buy-in.

## Acceptance Criteria

- [ ] Multiple personas can be invoked in "debate" or "consensus" mode
- [ ] Persona responses indicate agreement level or objections
- [ ] System synthesizes common ground and disagreement points
- [ ] Voting or weighted scoring mechanism available for final decisions
- [ ] Consensus process is logged to session worklog for traceability
- [ ] Final decision artifacts include attribution and dissenting views

## Technical Notes

Current npl-persona supports `--debate` but lacks explicit consensus synthesis. Team synthesis exists but focuses on knowledge gaps, not decision-making.

## Dependencies

- Related stories: US-032
- Related personas: P-004

## Background

Question: How do multiple personas with conflicting viewpoints reach consensus on decisions?

This story addresses the need for structured consensus mechanisms when multiple AI personas evaluate the same decision from different perspectives. While the current system can run personas in debate mode, there's no explicit synthesis of agreement/disagreement or voting mechanism to reach final decisions.

## Key Gap

Current implementation allows debate but doesn't facilitate consensus through structured synthesis, voting, or weighted scoring for architecture decisions.

---
id: US-005
title: "In-app glossary panel"
slug: in-app-glossary-panel
personas: [P-007]
epic: "Onboarding & Install"
priority: could-have
complexity: low
tags: [onboarding, help, docs]
---

# US-005: In-App Glossary Panel

## User Story

**As a** novice occasional user
**I want to** open a glossary panel from a "?" affordance that defines terms like candidate panel, quality label, rehome, and version
**So that** I can understand the app's vocabulary without leaving the page or asking someone else

## Acceptance Criteria

- **Given** the user is anywhere in the web UI
  **When** they click the persistent "?" affordance
  **Then** a glossary panel opens listing product-specific terms (candidate panel, quality label, rehome, version, gold/silver/bronze, convert wizard) each with a one- or two-sentence plain-language definition

- **Given** the glossary panel is open
  **When** the user searches or filters within it
  **Then** matching terms are shown/highlighted so they don't have to scroll a long list

- **Given** the user closes the glossary panel
  **When** they return to it later from a different screen
  **Then** it opens to the same list (not scoped to whatever screen they were last on) so it's a predictable single reference

## Notes
Could-have — deferred behind US-003/US-004 which cover the highest-friction onboarding moments; this is a nice-to-have reference for Jamie (P-007) who is "wary of Edit/Convert because they're unsure it's reversible" and would benefit from being able to look up what "version" and "rehome" actually mean before touching those features.

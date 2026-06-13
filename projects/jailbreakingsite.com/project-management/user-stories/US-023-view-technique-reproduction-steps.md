---
id: US-023
title: "View Technique Reproduction Steps (Authenticated)"
slug: "view-technique-reproduction-steps"
personas: [P-001, P-006, P-008]
epic: "Attack Catalog"
priority: "could-have"
complexity: "M"
tags: [catalog, technique, reproduction, auth-gated, research]
---

# US-023: View Technique Reproduction Steps (Authenticated)

## User Story

**As an** authenticated security researcher or red teamer (P-001, P-006, P-008),
**I want to** view step-by-step reproduction instructions for a technique,
**So that** I can validate the technique against my own LLM environment and build test cases for the Defender product.

## Acceptance Criteria

- [ ] Given I am authenticated and have accepted the Responsible Use Agreement (US-010), when I view a technique detail page, then the Reproduction Steps section is fully visible with numbered steps, example prompts, and expected model responses
- [ ] Given I am authenticated but have not accepted the Responsible Use Agreement, when I attempt to view reproduction steps, then I am prompted to review and accept the agreement before the content is revealed
- [ ] Given I attempt to view reproduction steps while unauthenticated, when the section renders, then it shows a blurred/locked overlay with a "Sign in to access" CTA
- [ ] Given reproduction steps contain example prompts, when I view them, then each prompt is individually copyable via a copy button

## Notes

Reproduction steps are the most sensitive content on the platform — auth-gating is a deliberate responsible disclosure measure, not a paywall. Acceptance of US-010 (Responsible Use Agreement) is a prerequisite. Audit logging of reproduction step views may be required for enterprise compliance.

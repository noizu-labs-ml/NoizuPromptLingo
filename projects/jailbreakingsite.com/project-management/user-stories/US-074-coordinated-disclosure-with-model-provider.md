---
id: US-074
title: "Coordinated Disclosure with Model Provider"
slug: "coordinated-disclosure-with-model-provider"
personas: [P-006, P-001, P-004]
epic: "Community & Disclosure"
priority: "won't-have-yet"
complexity: "L"
tags: [community, disclosure, coordinated, model-providers, responsible-disclosure]
---

# US-074: Coordinated Disclosure with Model Provider

## User Story

**As an** independent security consultant (P-006),
**I want to** initiate a coordinated disclosure process that notifies the affected model provider when I submit a technique,
**So that** the provider has a structured opportunity to respond or patch before the technique is published, following industry-standard responsible disclosure norms.

## Acceptance Criteria

- [ ] Given I am submitting a technique and select an affected model provider that is a registered disclosure partner, when I submit the form, then the platform automatically notifies the provider's designated security contact with a summary and the technique details (without public exposure)
- [ ] Given a provider receives a disclosure notification, when they log into the platform's provider portal (future feature), then they can acknowledge receipt, set a response timeline, and communicate status updates back to the submitter through the platform
- [ ] Given an embargo period is active for a coordinated disclosure, when the embargo expires without a response or extension request from the provider, then the platform notifies both parties that publication will proceed on the scheduled date
- [ ] Given a provider requests an embargo extension, when the request is submitted, then the submitter is notified and must approve or deny the extension — they retain final authority over their disclosure timeline
- [ ] Given a coordinated disclosure results in a fix, when the technique is published, then the catalog entry includes a "Vendor Response" section crediting the provider's remediation and noting the coordinated timeline

## Notes

This feature requires formal partnership agreements with model providers before it can ship — the technical implementation is secondary to the legal and relationship work. Initially this is a manual process mediated by the platform team; the automated provider portal is a longer-term buildout. Marked won't-have-yet because provider partnership development is a prerequisite.

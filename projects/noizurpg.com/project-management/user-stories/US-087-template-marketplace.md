---
id: US-087
title: "Template Marketplace Purchasing"
slug: "template-marketplace"
personas: [P-001, P-002]
epic: "Cloud & Commercial Services"
priority: "won't-have-yet"
complexity: "L"
tags: [marketplace, templates, purchasing, onboarding, content]
---

# US-087: Template Marketplace Purchasing

## User Story

**As an** indie game developer (P-001) and interactive fiction author (P-002),
**I want to** browse and purchase pre-built game templates (complete world configs, character archetypes, quest chains, dialogue trees) from the NoizuRPG marketplace,
**So that** I can start from a production-quality foundation instead of building everything from scratch.

## Acceptance Criteria

- [ ] Given the marketplace website, when I browse the template gallery, then I can filter by genre (fantasy, sci-fi, horror, etc.), component type (World, Quest, Dialogue), and price range, and each template shows a live demo preview via the Cloud Playground
- [ ] Given a template priced at $5-25, when I complete the purchase (Stripe checkout), then I receive a download link and the template is permanently associated with my account for re-download
- [ ] Given a downloaded template archive, when I run `noizurpg install-template ./template.nrpgt`, then the template files are placed in the correct project directories with a README explaining customization points
- [ ] Given an installed template, when I run my project, then the template configuration loads correctly and produces a playable session without any modification required
- [ ] Given a template purchase, when I attempt to install the same template on a second machine using my account credentials, then the install succeeds without an additional purchase (per-account, not per-machine licensing)

## Notes

Deferred pending marketplace infrastructure (US-086). Lower complexity than the component marketplace because templates are static files rather than executable code, so validation and licensing are simpler. Authors who create templates use the same publisher dashboard as component authors (US-086).

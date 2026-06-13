---
id: US-086
title: "Component Marketplace Publishing"
slug: "component-marketplace"
personas: [P-007]
epic: "Cloud & Commercial Services"
priority: "won't-have-yet"
complexity: "XL"
tags: [marketplace, community, publishing, monetization, ecosystem]
---

# US-086: Component Marketplace Publishing

## User Story

**As a** community contributor (P-007),
**I want to** publish my custom NoizuRPG components (providers, memory backends, quest engines, etc.) to an official marketplace and earn revenue from downloads,
**So that** my open-source contributions are discoverable, usable without copy-paste, and optionally monetized via the 20% platform take.

## Acceptance Criteria

- [ ] Given a component package that implements a valid `LLMProvider`, `MemoryBackend`, or other framework interface, when I run `noizurpg publish ./my-component`, then it validates the package against the interface contracts and uploads to the marketplace registry
- [ ] Given a published component, when another developer runs `pip install noizurpg-marketplace[my-component-slug]`, then the component is installed and importable with no manual setup beyond the install command
- [ ] Given a paid component listing ($5-25 price set by author), when a buyer purchases it, then the transaction is processed, the author receives 80% of revenue, and the buyer gets a license key scoped to their NoizuRPG account
- [ ] Given a published component, when I access my publisher dashboard, then I can see download counts, revenue earned, active license count, and version-specific adoption breakdown
- [ ] Given a component that fails the framework's automated interface validation tests, when I attempt to publish it, then the CLI rejects the upload with a list of which interface assertions failed and links to the relevant documentation

## Notes

Deferred due to marketplace infrastructure requirements (payment processing, license enforcement, registry hosting). Depends on US-091 (component interface) being stable and well-documented first. This is the primary revenue driver for P-007 and the community flywheel.

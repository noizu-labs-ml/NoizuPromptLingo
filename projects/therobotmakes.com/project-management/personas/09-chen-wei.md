# Chen Wei — Enterprise Innovation Lead ("Internal Tool Builder")

**Type:** Tertiary
**Segment:** Enterprise — Innovation
**Pipeline entry:** Phase 1 (Sketch)
**Likely exit:** Phase 3 (Ink) — exports codebase for internal deployment behind corporate firewall

---

## Demographics

- **Age:** 40
- **Role:** Director of Digital Innovation at a Fortune 500 manufacturing company
- **Location:** Shanghai, China (works with US headquarters)
- **Income:** ¥800K (~$110K USD)
- **Tech comfort:** Moderate — former developer turned manager, understands architecture

## Quote

> "Getting an internal tool approved takes 6 months. Getting a working demo approved takes 2 weeks."

## Goals

1. Rapidly prototype internal tools to demonstrate value before requesting IT budget
2. Bypass the 6-month procurement cycle by showing a working demo to leadership
3. Empower domain experts in his department to describe tools they need, then generate them
4. Reduce dependency on the central IT team for small, departmental tools

## Frustrations

- Central IT has an 8-month backlog — his team's requests are always deprioritized
- No-code tools don't meet corporate security requirements
- Hiring contractors for internal tools is expensive and slow (RFP process)
- PowerPoint mockups don't convince leadership — they need to click something

## Behaviors

- Runs an "innovation lab" with a small budget for experimentation
- Builds business cases with ROI projections — needs concrete artifacts, not slide decks
- Evaluates tools on security posture, data residency, and SSO compatibility
- Champions successful prototypes through the procurement process

## Scenario

Chen Wei's logistics team needs a shift scheduling tool. Central IT quoted 6 months. He opens noizu.ink, has his operations manager describe the workflow in plain English, and generates a PRD with 15 stories. He runs through Draft to get mockups and shows them to the VP of Operations, who says "let's pilot this." He uses the Ink phase to generate a working prototype, exports the code, and his one developer deploys it behind the corporate firewall. The pilot runs for 3 months. Based on results, IT fast-tracks the production version — using the generated spec as the requirements document.

## Feature Priorities

| Must Have | Nice to Have | Don't Care |
|-----------|-------------|------------|
| Code export (self-hostable) | SSO/SAML integration | Marketplace |
| Data stays off third-party servers | On-premise deployment option | Social features |
| Audit trail for approvals | Role-based access | Community templates |
| Professional export formats | API for integration | One-click cloud deploy |

## Tier Fit

**Builder ($49/mo)** for rapid prototyping. Would push for enterprise licensing ($500+/mo) if the tool proves value across multiple departments. Biggest concern: data security and where generated code/specs are stored.

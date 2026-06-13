# Worked Example: SaaS Platform Rebuild Proposal

A complete end-to-end walkthrough of the trl-proposal-writer skill in action.

**Scenario:** Freelance developer (you) receives an inbound from Marble Creek Analytics — a 40-person B2B SaaS company. Their legacy dashboard is crumbling. They want a proposal for a full rebuild.

---

## 1. Discovery Notes

> Raw notes captured during a 45-minute Zoom call with Dana Reyes (VP Product) and Tomás Vargara (CTO), 2026-04-22.

```
call w/ marble creek - dana + tomas
- current stack: angular 8 + rails 4 api + postgres 12
  - angular 8 EOL, rails 4 definitely EOL, nobody wants to touch it
  - 2 devs left who know it, both contractors, both leaving q3
- main pain: dashboard load times "sometimes 40 seconds" tomas said
  - dana said clients complain weekly
  - churn attributable to perf? maybe 15% tomas guesses, unverified
- what they want: "modern, fast, maintainable"
  - dana mentioned competitors using react
  - tomas wants typescript "non-negotiable"
  - dana wants "better mobile" (currently not responsive at all)
- key features to rebuild:
  - analytics dashboards (8-10 views, lots of charts)
  - user management + roles (admin, viewer, editor)
  - CSV export + scheduled email reports
  - API key management for their customers
  - billing portal (they use stripe, just need to embed/redirect)
- what they DON'T want rebuilt right now:
  - tomas was clear: don't touch the rails api yet, just the frontend
  - "we'll do the backend separately, maybe next year"
  - internal admin panel out of scope (they use retool)
- timeline:
  - dana wants something live by end of q3 (sept 30)
  - tomas said "beta with real users by august"
  - i asked about design: they have a figma file from a contractor, "mostly done"
    - need to get access to that figma
- budget:
  - dana dodged it
  - tomas said "we've had quotes from $40k to $120k, we're not going $120k"
  - read: somewhere in the $50-80k range probably
- other notes:
  - they have 3 enterprise clients on the platform, can't have downtime
  - HIPAA not relevant (analytics for retail sector)
  - need to keep existing URL structure (SEO? more likely bookmarks)
  - auth: they use auth0, keep it
  - decisions: dana signs off, tomas approves technical direction
  - they want weekly check-ins
  - asked about testing: tomas said "we got burned before, we want tests this time"
```

---

## 2. Requirements Extraction

Structured requirements pulled from the discovery notes above.

### Functional Requirements

| ID | Requirement | Source | Priority |
|----|-------------|--------|----------|
| F-01 | Rebuild frontend in React + TypeScript | Tomas, explicit | Must-have |
| F-02 | Rebuild 8–10 analytics dashboard views with charts | Dana + Tomas | Must-have |
| F-03 | User management: admin, viewer, editor roles | Dana | Must-have |
| F-04 | CSV export for all data tables | Dana | Must-have |
| F-05 | Scheduled email reports (existing frequency/format) | Dana | Must-have |
| F-06 | API key management UI for end-customers | Dana | Must-have |
| F-07 | Stripe billing portal embed/redirect | Dana | Must-have |
| F-08 | Auth0 integration (preserve existing tenant) | Tomas | Must-have |
| F-09 | Mobile-responsive layouts | Dana | Must-have |
| F-10 | Preserve existing URL structure | Implicit (bookmarks) | Must-have |
| F-11 | Implement from provided Figma file (partial) | Dana | Must-have |

### Non-Functional Requirements

| ID | Requirement | Source | Priority |
|----|-------------|--------|----------|
| N-01 | Zero planned downtime during cutover | Tomas (enterprise clients) | Must-have |
| N-02 | Full TypeScript, no `any` escape hatches | Tomas | Must-have |
| N-03 | Automated test coverage (unit + integration) | Tomas | Must-have |
| N-04 | Dashboard load time < 3s on typical dataset | Inferred from pain point | Must-have |
| N-05 | Weekly status check-ins | Dana | Must-have |

### Out of Scope (Confirmed)

| Item | Reason Excluded |
|------|-----------------|
| Rails API rebuild | Deferred by client to future engagement |
| Internal admin panel (Retool) | Client explicitly excluded |
| Backend performance optimization | Follows from API being out of scope |
| New feature development | Rebuild only — feature parity first |
| Design creation | Client has Figma file; design not in scope |

---

## 3. Scoping Decisions

### Decision Log

**SD-01: API contract is frozen**
The Rails API will not change. All frontend work must adapt to existing endpoints. Risk: undocumented endpoints discovered during build require negotiation. Mitigation: allocate 8 hours for API audit in Phase 1; document all endpoints before writing a line of frontend code. If gaps are found, change orders apply.

**SD-02: Figma file is the design source of truth**
Client supplied Figma. Assumption: file is complete enough to implement from. If Figma is incomplete or conflicts with existing behavior, client resolves it — not scope creep on our end.

**SD-03: Feature parity only, no enhancements**
All 8–10 dashboard views are rebuilt to match existing behavior. Any "while you're in there" requests after contract signature are change orders.

**SD-04: Zero-downtime cutover via feature flag**
New frontend deployed alongside old frontend. Traffic switched per-customer via feature flag in Auth0. No big-bang cutover. This protects the 3 enterprise clients.

**SD-05: Scheduled reports use existing backend job**
The Rails backend already sends scheduled emails. The frontend only needs the configuration UI — not the job itself. If the job needs changes, that's a backend engagement.

---

## 4. Deliverables Table (STAMP-Compliant)

> STAMP: Specific, Testable, Attributable, Measurable, Precedent-set

| # | Deliverable | Description | Acceptance Criteria | Owner | Due |
|---|-------------|-------------|---------------------|-------|-----|
| D-01 | API Audit Report | Document all API endpoints consumed by the current frontend, including request/response schemas | Client signs off on completeness; any gaps documented as risks | Developer | Week 2 |
| D-02 | Component Library | Reusable React/TS components matching Figma design system (buttons, inputs, tables, charts) | Storybook instance deployed; all components pass visual regression vs Figma | Developer | Week 5 |
| D-03 | Analytics Dashboard Views | All 8–10 dashboard views rebuilt in React/TS | All views render correct data from staging API; load < 3s on 10k-row dataset; responsive at 375px | Developer | Week 9 |
| D-04 | User Management Module | Role-based user admin UI (admin/viewer/editor), invite flow, role assignment | Create/edit/delete/invite flows functional; role restrictions enforced client-side; unit tested | Developer | Week 8 |
| D-05 | CSV Export | Export button on all data tables; generates valid CSV | CSV matches displayed data exactly; filename includes date; works on all 8 table views | Developer | Week 10 |
| D-06 | Scheduled Report Config UI | UI for configuring email report frequency and recipients | Config saved via API; confirmed by receiving test email; matches existing report format | Developer | Week 10 |
| D-07 | API Key Management UI | CRUD interface for customer API keys | Create/revoke/list operations confirmed against API; keys partially masked in display | Developer | Week 9 |
| D-08 | Stripe Billing Portal | Redirect/embed to Stripe customer portal | Authenticated users routed to correct Stripe customer; no cross-customer access | Developer | Week 7 |
| D-09 | Auth0 Integration | Auth0 SDK wired to existing tenant; login/logout/session refresh | Login flow works; session expires correctly; existing user accounts unaffected | Developer | Week 3 |
| D-10 | Zero-Downtime Cutover | Feature flag deployment; per-customer traffic switching | New frontend served to test accounts; production accounts unaffected until manually switched | Developer | Week 12 |
| D-11 | Test Suite | Unit tests (components) + integration tests (critical flows) | 80%+ component coverage; all 6 critical user flows covered by integration tests | Developer | Week 12 |
| D-12 | Handoff Documentation | Architecture overview, component guide, deployment runbook | Client dev team can deploy independently; documented in Notion or repo wiki | Developer | Week 13 |

---

## 5. Pricing Calculation

### Three-Point Estimation

| Phase | Optimistic | Realistic | Pessimistic |
|-------|-----------|-----------|-------------|
| P1: Discovery & API Audit | 8h | 12h | 20h |
| P2: Component Library | 32h | 48h | 72h |
| P3: Dashboard Views (8 views) | 48h | 72h | 100h |
| P4: User Management | 20h | 30h | 44h |
| P5: CSV Export | 8h | 12h | 20h |
| P6: Scheduled Report Config | 10h | 14h | 24h |
| P7: API Key Management | 12h | 16h | 24h |
| P8: Stripe Billing | 6h | 8h | 14h |
| P9: Auth0 Integration | 8h | 12h | 20h |
| P10: Zero-Downtime Cutover | 12h | 20h | 32h |
| P11: Testing | 24h | 36h | 56h |
| P12: Handoff & Documentation | 12h | 16h | 24h |
| **Totals** | **200h** | **296h** | **450h** |

**PERT estimate:** `(O + 4M + P) / 6 = (200 + 4×296 + 450) / 6 = 1834 / 6 ≈ 306h`

**Loaded rate:** $185/hr (senior contractor rate, includes overhead)

**Base estimate:** 306h × $185 = $56,610

**Risk buffer:** 15% for API surprises (frozen API = higher variance) = $8,492

**Figma gap allowance:** Flat $2,000 (design clarifications, Figma gaps)

**Total:** $67,102 → **Rounded to $67,500**

### Pricing Model Selected: Fixed-Price with Change Order Protocol

Rationale: client has budget anxiety and wants certainty. Fixed-price reduces sales friction. Change order protocol protects us from scope creep without making the client feel nickel-and-dimed.

### Payment Schedule

| Milestone | Amount | Trigger |
|-----------|--------|---------|
| Contract signature | $13,500 (20%) | Immediately upon signing |
| API Audit Report approved (D-01) | $13,500 (20%) | Client sign-off on audit |
| Component Library complete (D-02) | $20,250 (30%) | Storybook deployed + approved |
| Feature-complete (D-03 through D-09) | $13,500 (20%) | All core features in staging |
| Final handoff (D-10 through D-12) | $6,750 (10%) | Handoff docs delivered |

---

## 6. The Finished Proposal

---

**PROPOSAL**
**Frontend Modernization — Marble Creek Analytics Dashboard**
Prepared by: Jordan Ellis, Ellis Development
Prepared for: Dana Reyes & Tomás Vargara, Marble Creek Analytics
Date: 2026-04-28
Version: 1.0

---

### Executive Summary

Marble Creek Analytics is facing a compounding risk: a frontend built on Angular 8 — end-of-life since 2023 — with the two developers who know it leaving by Q3. Dashboard load times exceeding 40 seconds are driving client complaints and contributing to churn.

This proposal covers a full frontend rebuild: React + TypeScript, implemented against the existing Rails API, deployed without downtime to your enterprise clients. The result is a maintainable, fast, mobile-responsive dashboard that your team can own and extend — not a black box dependent on contractors who've left.

**Scope:** Frontend only. Rails API untouched. Feature parity with current dashboard, plus mobile responsiveness.
**Timeline:** 13 weeks. Beta with real users by Week 10. Production cutover by Week 12.
**Investment:** $67,500 fixed price.

---

### Problem Statement

The current Angular 8 frontend presents three compounding risks:

1. **Security exposure** — Angular 8 has received no security patches since December 2022. Every week it runs in production is unpatched CVE exposure.
2. **Knowledge cliff** — Two contractors hold all institutional knowledge of the codebase. Their Q3 departure leaves you with legacy code and no one to maintain it.
3. **Performance and churn** — 40-second dashboard loads are not a backend problem alone. The frontend renders inefficiently, makes redundant API calls, and has no caching layer. Clients notice and complain.

A rewrite is not a luxury. It's a deadline.

---

### Proposed Solution

A 13-week engagement to rebuild the Marble Creek dashboard in React 18 + TypeScript 5, consuming your existing Rails API without changes.

**Technical approach:**
- React 18 with concurrent rendering for perceived performance
- TypeScript 5 with strict mode — no `any`, no escape hatches
- Recharts (or Tremor) for the analytics visualization layer
- Auth0 SDK wired to your existing tenant — existing users unaffected
- Vitest + Playwright for unit and integration test coverage
- Feature-flag deployment: new frontend coexists with old; enterprise clients switched manually when ready

**What this is not:**
This engagement covers the frontend only. The Rails API will not be modified. The internal Retool admin panel is not in scope. New features beyond current parity are not in scope — they are the right next step after a stable foundation exists.

---

### Deliverables

*See Section 4 deliverables table above — reproduced in full in the actual proposal document.*

All 12 deliverables are listed with explicit acceptance criteria. No deliverable is accepted without client sign-off against its stated criteria.

---

### Timeline

| Week | Milestone |
|------|-----------|
| 1–2 | Kickoff, API audit, Figma review |
| 3 | Auth0 integration, routing scaffold |
| 4–5 | Component library + Storybook |
| 6–7 | Stripe billing, user management |
| 8–9 | Dashboard views (all 8–10), API key management |
| 10 | CSV export, scheduled report config, beta with real users |
| 11 | QA, bug fixes, integration tests |
| 12 | Zero-downtime production cutover |
| 13 | Handoff documentation, final invoice |

Beta with internal users: **Week 8**. Beta with real customers: **Week 10**. Production: **Week 12**.

---

### Investment

Fixed price: **$67,500**

This price is fixed for the scope defined in this proposal. Additions, changes, and discoveries outside the documented scope are handled via written change orders before work begins.

*Payment schedule:* 20% on signing / 20% on API audit approval / 30% on component library / 20% on feature-complete / 10% on handoff.

---

### Assumptions

This proposal is made under the following assumptions. If any are incorrect, timeline and pricing may need to be revised.

1. The Figma design file is complete enough to implement from. Gaps requiring design decisions are resolved by client within 48 hours of being raised.
2. The Rails API is stable and will not change during the engagement. Breaking API changes are out of scope.
3. Client provides staging environment access and test data within the first week.
4. Client maintains Auth0 tenant access and can provide necessary credentials at kickoff.
5. Weekly 30-minute check-in slots are blocked on Dana and Tomás's calendars for the engagement duration.
6. Client is responsible for any third-party licensing costs (Stripe, Auth0, etc.).

---

### Why Ellis Development

- 8 years building React applications; 4 years working with TypeScript in production
- Previous engagement: rebuilt Vantage Metrics frontend from AngularJS to React in 11 weeks, 0 production incidents during cutover
- Auth0 certified partner — no learning curve on your auth layer
- Fixed-price model: I eat the overruns, not you

---

### Next Steps

1. **Review this proposal** — questions welcome by email or a 30-minute call
2. **Sign and deposit** — DocuSign sent upon verbal go-ahead; 20% deposit initiates the engagement
3. **Kickoff call** — Schedule within 5 business days of signing; Figma access, staging credentials, and API docs requested at this call

This proposal is valid through **2026-05-12**. After that date, availability cannot be guaranteed.

Jordan Ellis
jordan@ellisdev.io | (415) 555-0192

---

## 7. Post-Submission: Change Order

**Scenario:** Two weeks after signing, Dana emails: "Can we also add a dark mode toggle? The design team did Figma specs for it — it's basically done."

### Change Order #001

**Requested by:** Dana Reyes, VP Product, Marble Creek Analytics
**Date:** 2026-05-14
**Reference:** Marble Creek Frontend Rebuild — Contract dated 2026-05-01

**Change Requested:** Add dark mode support across all dashboard views, controlled by a user-level toggle persisted to their profile.

**Scope of Change:**
- Audit component library for theming readiness
- Implement CSS custom property–based dark theme from Figma dark specs
- Add toggle control to user profile settings
- Persist preference to user profile via API (assumes endpoint exists or will be added to API — TBD)
- Apply dark mode to all 12 rebuilt views

**Estimate:**
| Work | Hours |
|------|-------|
| Theming audit + CSS variable refactor | 12h |
| Dark theme implementation | 16h |
| Toggle + persistence | 6h |
| QA across all views | 8h |
| **Total** | **42h** |

42h × $185/hr = **$7,770**

**Timeline Impact:** 1 week added to delivery. New production date: Week 14 (was Week 13).

**Payment Terms:** 50% on change order signature ($3,885); 50% on delivery.

**Acceptance:**

Client signature: _________________________ Date: _________
Developer signature: _________________________ Date: _________

---

*This change order supersedes no prior terms. All other contract terms remain in effect.*

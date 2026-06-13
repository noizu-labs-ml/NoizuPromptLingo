# Deliverables Engineering Patterns

How to write excellent deliverables across different project types. A deliverable poorly specified is a contract dispute waiting to happen. A deliverable well specified is a shared reality between vendor and client.

---

## The STAMP Framework

Every deliverable must be **Specific**, **Testable**, **Assignable**, **Measurable**, and **Priced**.

### S — Specific

The deliverable must name exactly what will be produced. No ambiguity about format, medium, or content.

| Bad | Good |
|---|---|
| "Website" | "Responsive marketing website, up to 7 pages (Home, About, Services, Blog, Contact, Privacy, Terms), built in Next.js 15, deployed to Vercel" |
| "API" | "REST API with 12 endpoints (per Exhibit A endpoint list), documented in OpenAPI 3.1, deployed to production AWS environment" |
| "Report" | "Security audit report: executive summary (2–3 pages), technical findings (per scope), remediation recommendations with priority ratings, delivered as PDF and editable DOCX" |

**Rule:** If two people can read the deliverable description and disagree about what it includes, it is not specific enough.

### T — Testable

There must be a defined test or review that determines pass/fail. "Client is satisfied" is not testable.

| Bad | Good |
|---|---|
| "Working login system" | "Login system passes the acceptance test suite in Exhibit C (47 test cases covering auth, session management, and error handling)" |
| "Good design" | "Design mockups reviewed against the brand guide in Exhibit B; no brand violations present" |
| "Fast API" | "API p95 response time ≤200ms under 100 concurrent users (load test script provided)" |

**Rule:** Could you hand the acceptance test to a third party and get a consistent result? If yes, it's testable.

### A — Assignable

It must be clear who is responsible for producing the deliverable. In multi-vendor or multi-team engagements, unowned deliverables slip.

| Bad | Good |
|---|---|
| "Infrastructure setup" | "Vendor responsible for AWS infrastructure setup per Exhibit A; Client responsible for providing IAM access credentials within 3 business days of contract execution" |
| "Content" | "Vendor writes all body copy; Client provides brand messaging brief (template provided) by [date]" |

**Rule:** Every deliverable has exactly one responsible party. Shared responsibility = no responsibility.

### M — Measurable

Quantity, quality, and completeness must be quantifiable.

| Bad | Good |
|---|---|
| "Test coverage" | "Unit test coverage ≥80% for all service-layer modules (measured via Jest coverage report)" |
| "Documentation" | "API documentation: all 12 endpoints documented with request/response examples, error codes, and authentication notes; README updated with setup and deployment instructions" |
| "Training" | "2 live training sessions, 90 minutes each, recorded for async review; training guide (≥20 pages) delivered 5 business days prior to first session" |

**Rule:** If you can't measure completion at 0%, 50%, and 100%, the deliverable isn't measurable.

### P — Priced

Every deliverable must have an associated price or effort allocation. This makes scope creep visible and change order conversations objective.

| Bad | Good |
|---|---|
| Deliverables listed without cost breakdown | Milestone 2 – Backend API ($28,000): [list of deliverables] |
| "Included at no charge" for add-ons | "Up to 2 rounds of revision included; additional rounds billed at $175/h" |

**Rule:** If a deliverable has no price, the client believes it is free. Price everything, even if bundled.

---

## Deliverables Table Template

Use this structure in every SOW:

```markdown
| # | Deliverable | Description | Acceptance Criteria | Owner | Price/Milestone |
|---|-------------|-------------|---------------------|-------|-----------------|
| 1.1 | [Name] | [Specific description] | [Testable criteria] | Vendor | M1 ($X) |
| 1.2 | [Name] | [Specific description] | [Testable criteria] | Vendor | M1 ($X) |
| 2.1 | [Name] | [Specific description] | [Testable criteria] | Client | — (input) |
```

Client-owned deliverables (inputs required from the client) should be listed separately:

```markdown
## Client-Provided Inputs

| # | Input Required | Format | Required By | Blocking |
|---|----------------|--------|-------------|---------|
| C1 | API credentials for existing CRM | JSON file or env vars | Day 3 | M1 start |
| C2 | Brand guide | PDF | Day 1 | Design work |
| C3 | Content copy for homepage | Google Doc | Day 10 | Design approval |
```

**Blocking inputs** gate milestone start. Define them explicitly — delays in client inputs extend timelines at no vendor fault.

---

## 1. Software Deliverables

### APIs

```
Deliverable: Payment Processing REST API

Description:
  REST API implementing the 8 endpoints specified in Exhibit A (Payments API Spec v1.2),
  including charge, refund, subscription create/cancel, and webhook handling.
  Built in Node.js (Express), deployed to production AWS (us-east-1), integrated
  with Stripe as payment processor.

Acceptance Criteria:
  Functional:
    - All 8 endpoints respond correctly per API spec (manual smoke test + automated suite)
    - Webhook signature verification passes for all Stripe event types in scope
    - Error responses follow RFC 7807 (Problem Details) format
  Quality:
    - Unit test coverage ≥85% (Jest; coverage report attached to delivery)
    - No Critical or High severity issues in final SAST scan (tool: Semgrep)
  Performance:
    - p95 response time ≤300ms for charge endpoint under 50 concurrent requests
      (load test script provided; Client runs in staging)
  Compliance:
    - PCI DSS SAQ A-EP requirements met (no raw card data touches vendor systems)
  Documentation:
    - OpenAPI 3.1 spec updated to reflect final implementation
    - README with local dev setup, environment variables, and deployment guide
```

### Applications

```
Deliverable: Customer Portal Web Application (MVP)

Description:
  React (Next.js 15, App Router) web application, responsive (mobile-first),
  implementing the 6 user flows in the UX spec (Exhibit B). Deployed to Vercel
  (production and staging environments). Authentication via Auth0.

Acceptance Criteria:
  Functional:
    - All 6 user flows completable end-to-end without errors in Chrome (latest),
      Firefox (latest), and Safari (latest)
    - All form validations match the validation rules in Exhibit B
    - Error states handled per Exhibit B error state catalog
  Quality:
    - Lighthouse accessibility score ≥90 on all primary pages
    - WCAG 2.1 AA compliance verified for all interactive elements
    - No console errors in production build
  Performance:
    - Core Web Vitals: LCP <2.5s, CLS <0.1, FID <100ms (measured via Lighthouse CI)
  Compatibility:
    - Tested and functional on iOS 16+ Safari and Android 12+ Chrome
```

### Databases

```
Deliverable: Database Schema and Migration Scripts

Description:
  PostgreSQL 16 schema for the e-commerce platform (15 tables per ERD in Exhibit A),
  including all indexes, constraints, and foreign keys. Flyway migration scripts
  for clean install and upgrade from v0 → v1. Seed data scripts for development
  and staging environments.

Acceptance Criteria:
  Functional:
    - All 15 tables created correctly per ERD
    - All foreign key constraints enforced (verified by referential integrity tests)
    - Migration scripts run idempotently on clean and dirty databases
  Quality:
    - No N+1 query patterns in the ORM layer for the 10 primary query patterns
      (reviewed via query plan analysis)
    - All columns with expected cardinality >10K have appropriate indexes
  Documentation:
    - ERD updated to match final schema (dbdiagram.io or Lucidchart format)
    - Data dictionary: table descriptions, column descriptions, enum values documented
```

---

## 2. Design Deliverables

### Wireframes

```
Deliverable: Low-Fidelity Wireframes

Description:
  Wireframes for 12 unique page templates (per page inventory in Exhibit A) for
  the SaaS dashboard. Delivered in Figma (shared link with comment access).
  Mobile (375px) and desktop (1440px) variants for all 12 templates.

Acceptance Criteria:
  Completeness:
    - All 12 templates present with both viewport variants (24 frames total)
    - All interactive states shown: empty state, loaded state, error state
      for all data-driven components
  Quality:
    - All wireframes use consistent component library (not ad-hoc shapes)
    - Navigation flows indicated with prototype connections for all primary paths
  Review:
    - Client review session completed; all blocking feedback resolved
    - Final version exported as PDF for archival
```

### Design Systems

```
Deliverable: Design System v1.0

Description:
  Figma component library and accompanying documentation covering:
    - Color tokens (primary, secondary, semantic, neutral — light and dark mode)
    - Typography scale (6 levels, 2 weights)
    - Spacing system (8px base grid, 10 steps)
    - 40+ UI components (per component inventory in Exhibit A)
    - Usage guidelines document

Acceptance Criteria:
  Coverage:
    - All 40 components in inventory present in library
    - Each component has: default, hover, active, focused, disabled, and
      error/success states where applicable
    - All components use design tokens (no hardcoded hex values)
  Quality:
    - Component naming matches agreed naming convention (Exhibit B)
    - All text layers use text styles; all colors use color styles
    - Variants organized with Figma variant properties (not named manually)
  Documentation:
    - Usage guidelines cover: when to use, when not to use, dos and don'ts
      for each component category (not individual components)
```

---

## 3. Strategy and Advisory Deliverables

Making intangibles tangible requires defining the artifact clearly.

### Audit Reports

```
Deliverable: Security Architecture Audit Report

Description:
  Written audit report assessing the security posture of the Client's
  production infrastructure (scope defined in Exhibit A). Delivered as:
    - Executive summary (3–5 pages): business risk framing, top 5 findings
    - Technical findings (15–30 pages): findings catalog with CVSS scores,
      evidence, and remediation guidance
    - Remediation roadmap: 90-day plan with prioritized actions
  Formats: PDF (final) and DOCX (editable).

Acceptance Criteria:
  Completeness:
    - All systems in scope (Exhibit A) assessed
    - Each finding includes: description, evidence, risk rating (CVSS 3.1),
      remediation recommendation, and effort estimate
    - No fewer than 5 recommendations in the roadmap
  Quality:
    - Executive summary is written for non-technical audience
      (verified by: no unexplained acronyms, <10% jargon density)
    - All CVSS scores justified with scoring rationale
  Timeliness:
    - Draft delivered for Client review within 5 business days of assessment completion
    - Final delivered within 3 business days of receiving Client comments
```

### Roadmaps

```
Deliverable: 12-Month Product Roadmap

Description:
  Strategic roadmap document covering:
    - Vision statement and strategic pillars (1 page)
    - Now/Next/Later theme map (visual, 1 page)
    - Quarterly breakdown: themes, objectives, and key initiatives per quarter
    - Initiative cards (one per initiative): problem statement, hypothesis,
      success metrics, dependencies, rough effort (S/M/L/XL)
    - Risk and dependency register
  Formats: Notion database (live) + PDF export.

Acceptance Criteria:
  Coverage:
    - Minimum 3 strategic pillars defined
    - Minimum 12 initiative cards (one per initiative, across all quarters)
    - All Q1 initiatives have defined success metrics (OKR format preferred)
    - All cross-team dependencies identified
  Quality:
    - Each initiative card answers: who is it for, what problem, how will we know it worked
    - Roadmap reviewed in stakeholder session with feedback incorporated
  Deliverable:
    - Notion database shared with Client workspace
    - PDF export generated and delivered
```

---

## 4. Content Deliverables

### Article Sets

```
Deliverable: SEO Article Package (10 Articles)

Description:
  10 long-form articles targeting the keywords in Exhibit A (one primary keyword
  per article). Each article:
    - 1,500–2,500 words
    - H1/H2/H3 structure per the content brief template
    - Includes: introduction, 4–6 sections, conclusion, CTA
    - Internally links to at least 2 other articles in the package
    - Delivered as Google Docs with revision history enabled

Acceptance Criteria:
  Quantity: 10 articles submitted
  Quality (per article):
    - Primary keyword appears in: H1, first paragraph, at least 2 H2s or body paragraphs
    - Readability: Flesch-Kincaid grade level ≤10 (verified via Hemingway App)
    - Fact claims include citations to primary or recognized secondary sources
    - No AI-detection flags above 40% (Originality.ai, batch scan)
  Process:
    - 2 rounds of revision per article included
    - Final articles delivered in batches of 5; first batch due [date]
```

### Documentation Sets

```
Deliverable: API Developer Documentation

Description:
  Full developer documentation for the Payment API (12 endpoints), including:
    - Getting Started guide (authentication, first API call, error handling basics)
    - Endpoint reference (auto-generated from OpenAPI spec + handwritten descriptions)
    - Code examples in: JavaScript, Python, Ruby (all 12 endpoints)
    - Webhooks guide
    - Error code reference (all error codes with descriptions and resolution guidance)
    - Changelog
  Published to: docs.client.com (Mintlify or Readme.io — to be confirmed)

Acceptance Criteria:
  Coverage:
    - All 12 endpoints documented with: description, request parameters,
      response schema, example request/response, error cases
    - Code examples for all 12 endpoints in all 3 languages, verified runnable
    - All error codes in the API (per error catalog in Exhibit A) documented
  Quality:
    - Getting Started guide: new developer can make first successful API call
      within 15 minutes (verified by developer usability test with 2 participants)
    - No broken links (verified by automated link checker at time of delivery)
  Completeness:
    - Changelog covers all changes from v0 → v1
```

---

## 5. Acceptance Criteria Patterns

### Functional Criteria

"It does X correctly."

Pattern: `[Subject] [verb] [expected behavior] [under condition] [verified by]`

```
Examples:
  - User can reset password via email link; link expires after 1 hour;
    verified by manual test against test cases TC-AUTH-07 through TC-AUTH-12
  - Search returns results within 500ms for queries up to 50 characters;
    verified by automated load test (script: /tests/perf/search-load-test.js)
  - Form validation prevents submission when required fields are empty;
    error messages match copy in Exhibit C; verified by Playwright E2E test suite
```

### Quality Criteria

"It meets standard Y."

Pattern: `[Artifact] [meets/passes/scores] [standard or threshold] [tool or method]`

```
Examples:
  - Codebase passes ESLint (config: .eslintrc.project) with zero errors
  - All pages score ≥90 on Lighthouse Accessibility audit (Chrome DevTools, incognito)
  - SAST scan (Semgrep) reports zero Critical or High severity findings
  - Copy reviewed by native English speaker; no grammatical errors; Hemingway grade ≤8
```

### Performance Criteria

"It handles N."

Pattern: `[Operation] [completes in / handles / sustains] [threshold] [under load] [measurement method]`

```
Examples:
  - API p95 latency ≤200ms under 100 concurrent users (k6 load test; 5-minute run)
  - Database query for order history returns in ≤50ms for users with up to 10,000 orders
    (EXPLAIN ANALYZE; verified in staging with seeded data)
  - Application handles 500 concurrent WebSocket connections without memory leak
    (Artillery load test; heap snapshot before and after)
```

### Compliance Criteria

"It passes audit Z."

Pattern: `[System/artifact] [complies with / passes] [standard] [verified by] [by date]`

```
Examples:
  - Authentication implementation satisfies OWASP ASVS Level 2 requirements
    for Session Management (ASVS 3.x); verified by security review checklist
  - Data retention implementation complies with GDPR Article 17 (right to erasure);
    verified by privacy counsel sign-off
  - Accessibility implementation passes WCAG 2.1 AA automated and manual audit;
    verified using axe-core + manual keyboard navigation testing
```

---

## Fully Worked Examples

### Example 1: E-Commerce Backend Build

```
Milestone 2: Backend Services ($45,000)

Deliverables:
  2.1 Product Catalog Service
      REST API: 8 endpoints (CRUD + search + category browsing)
      Acceptance: All endpoints pass test suite (Exhibit C, 52 test cases);
                  p95 latency ≤150ms under 200 concurrent users;
                  OpenAPI spec published to internal dev portal

  2.2 Cart & Checkout Service
      REST API: 6 endpoints (cart management, checkout initiation, order creation)
      Acceptance: Full checkout flow completable end-to-end in staging;
                  Stripe test mode transactions succeed;
                  Order creation idempotent (duplicate request returns same order)

  2.3 PostgreSQL Schema
      12 tables per ERD (Exhibit A); all constraints; Flyway migrations v0→v1
      Acceptance: Migrations run cleanly on fresh and existing DB;
                  all foreign key constraints verified;
                  data dictionary delivered (table + column descriptions)

  2.4 Unit + Integration Test Suite
      ≥85% line coverage; all integration tests runnable in CI (GitHub Actions)
      Acceptance: Coverage report showing ≥85%; all tests green in CI on main branch

Client Inputs Required:
  - Stripe API keys (test mode) → needed by Day 3 of M2
  - Final product taxonomy (categories, attributes) → needed by Day 5 of M2
```

### Example 2: Brand Identity Design

```
Milestone 1: Brand Identity System ($12,000)

Deliverables:
  1.1 Logo System
      Primary logo + 3 lockup variants (horizontal, stacked, icon-only);
      light and dark versions of each; delivered in SVG, PNG (1x, 2x, 3x), PDF
      Acceptance: Client written approval of final logo direction;
                  all file formats delivered per above;
                  vector files editable in Illustrator CS6+

  1.2 Color System
      Primary palette (2 colors), secondary palette (3 colors),
      semantic colors (success, error, warning, info), neutrals (6 steps);
      all colors defined in: HEX, RGB, HSL, CMYK, Pantone (nearest match)
      Acceptance: All values documented in brand guide;
                  WCAG AA contrast ratio met for all text-on-background combinations

  1.3 Typography System
      Primary typeface (body + heading), secondary typeface (accent, optional);
      type scale (6 levels); line-height and letter-spacing for each level
      Acceptance: Font licenses confirmed for web + print use;
                  type scale documented with code-ready CSS variables

  1.4 Brand Guide Document
      25–40 page PDF covering: logo usage rules, color system, typography,
      photography/illustration guidelines, voice and tone (1 page summary)
      Acceptance: All sections present; no lorem ipsum; print-ready PDF (CMYK, 300dpi)
```

### Example 3: Content Strategy Engagement

```
Milestone 1: Content Strategy ($8,500)

Deliverables:
  1.1 Content Audit
      Analysis of existing 80 URLs (provided by Client) with:
      quality rating (Keep/Improve/Retire), traffic data (from GA4 export Client provides),
      keyword gaps, and content cannibalization flags
      Acceptance: All 80 URLs assessed; audit delivered as Google Sheet;
                  summary section (≤5 pages) with top 10 recommendations

  1.2 Content Pillars & Cluster Map
      3–5 content pillars with 8–12 cluster topics each;
      topic priority matrix (search volume × competition × business value)
      Acceptance: Pillar map delivered as visual + supporting data table;
                  all topics have keyword data (volume, difficulty) from Ahrefs or Semrush

  1.3 90-Day Content Calendar
      12 articles planned (1 per week, Q1); each article brief includes:
      target keyword, search intent, headline options (3), outline, internal link targets
      Acceptance: 12 briefs delivered in Notion template (template provided);
                  Client approves calendar in kickoff review session
```

### Example 4: Security Assessment

```
Milestone 1: Penetration Test + Report ($22,000)

Scope: External network perimeter + web application (3 apps per Exhibit A)
       Black-box testing; no source code access

Deliverables:
  1.1 Test Execution
      Methodology: OWASP Testing Guide v4.2; PTES standard
      Duration: 10 business days active testing
      Not a deliverable itself — gates the report deliverable

  1.2 Technical Findings Report
      Per-finding format: title, CVSS 3.1 score + vector, description,
      evidence (screenshots/payloads), reproduction steps, remediation guidance
      Acceptance: All systems in scope tested;
                  minimum 1 finding per system (or explicit "no findings" attestation);
                  all findings include CVSS score with scoring rationale;
                  delivered within 5 business days of test completion

  1.3 Executive Summary
      3–5 pages; risk summary; top 5 findings in business terms;
      overall risk posture rating; recommended next steps
      Acceptance: Readable by non-technical stakeholder (reviewed by Client CEO
                  — this is explicit in engagement kickoff);
                  no unexplained technical jargon

  1.4 Remediation Validation (post-fix)
      Re-test of all Critical and High findings after Client remediation;
      attestation letter for each remediated finding
      Scope: included for findings remediated within 60 days of report delivery
      Acceptance: Written attestation or "finding persists" note for each Critical/High
```

### Example 5: SaaS Onboarding Flow (Design + Frontend)

```
Milestone 2: Onboarding Flow ($18,000)

Deliverables:
  2.1 UX Design — Onboarding Flow (7 screens)
      Figma file: 7 screens with mobile (375px) + desktop (1440px) variants;
      all interactive states; prototype with flow connections
      Acceptance: Design review session completed with Client product team;
                  all blocking feedback resolved in final revision;
                  Figma file handed off with dev-ready inspect mode enabled

  2.2 Frontend Implementation
      Next.js 15 components for all 7 screens; integrated with Auth0;
      form state managed with React Hook Form; deployed to staging (Vercel)
      Acceptance:
        Functional: All 7 screens completable end-to-end in staging;
                    Auth0 integration creates user account;
                    onboarding completion sets user.onboarded = true in DB
        Quality: Lighthouse accessibility ≥90; no console errors; WCAG 2.1 AA
        Visual: Components match Figma designs within 5px tolerance
                (reviewed via Figma overlay comparison in review session)
        Cross-browser: Tested in Chrome, Firefox, Safari (latest stable each)

  2.3 Analytics Instrumentation
      Segment events fired for: step_viewed, step_completed, onboarding_completed,
      onboarding_abandoned (with step_last_seen property)
      Acceptance: All 4 events visible in Segment debugger during manual walkthrough;
                  event properties match schema in Exhibit B (Analytics Schema)
```

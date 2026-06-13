---
name: trl-proposal-writer
description: >
  Draft, structure, and refine professional work proposals and statements of
  work (SOW) for consulting, freelance, and agency engagements. Use this skill
  when the user wants to write a project proposal, create a statement of work,
  draft a scope document, prepare a client bid, structure deliverables and
  milestones, define acceptance criteria, choose a pricing model, respond to
  an RFP, or polish an existing proposal for submission — even if they don't
  say "proposal" or "SOW." Also trigger when users mention scope of work,
  work order, engagement letter, project scope, deliverables table, milestone
  schedule, fixed-price vs T&M, change order process, or client pitch document.
---

# Proposal Writer

Turn client conversations into winning proposals and airtight statements of work.

## Overview

This skill systematizes the process of writing professional proposals and SOW documents — from initial client discovery through a polished, submission-ready document. It eliminates the blank-page problem by providing structured workflows, reusable section templates, and pricing frameworks. It provides:

- **Document architecture** — Structural templates for proposals, SOWs, and hybrid formats with required and optional sections
- **Discovery-to-document workflow** — Phased process for extracting requirements, scoping work, and translating into professional prose
- **Pricing framework** — Decision guide for fixed-price, time-and-materials, milestone-based, and retainer models with risk allocation analysis
- **Deliverables engineering** — Techniques for defining measurable deliverables, acceptance criteria, and milestone gates
- **Risk and assumptions management** — Systematic identification of project risks, dependencies, and assumptions with mitigation strategies
- **Revision and negotiation support** — Strategies for handling scope changes, client pushback, and iterative refinement

## Core Philosophy

**Five Principles:**

1. **Clarity closes deals** — A proposal the client can understand in one read beats a impressive-sounding document they have to decode; ambiguity breeds scope disputes
2. **Scope is a contract** — Every sentence in the scope section is a promise; be precise about what's included, explicit about what's excluded, and unambiguous about the boundary
3. **Price follows scope** — Never discuss pricing before scope is locked; the price is a function of deliverables, timeline, and risk — not a number you back into
4. **Assumptions are load-bearing** — Unstated assumptions become disputes; stated assumptions become shared understanding; every assumption is a risk that hasn't materialized yet
5. **The proposal is a preview** — How you write the proposal signals how you'll run the project; professionalism, structure, and attention to detail in the document predict the engagement quality

## When to Use This Skill

- **Writing a proposal from scratch** — Client expressed interest, you need to formalize the engagement
- **Creating a statement of work** — Translating agreed-upon scope into a formal SOW with deliverables and milestones
- **Responding to an RFP** — Structuring a response that addresses requirements while differentiating your approach
- **Scoping a project** — Breaking vague requirements into concrete deliverables with effort estimates
- **Choosing a pricing model** — Deciding between fixed-price, T&M, milestone, retainer, or hybrid structures
- **Defining acceptance criteria** — Writing testable, unambiguous criteria for deliverable sign-off
- **Handling scope changes** — Drafting change orders or addenda for mid-project scope modifications
- **Polishing an existing proposal** — Reviewing and improving clarity, structure, and professionalism of a draft

> For researching the client's market and competitive landscape before writing, see **trl-market-intelligence** (`references/niche-discovery.md`).
> For designing the visual presentation of the proposal, see **trl-user-experience-engineer** (`references/outputs/landing-pages.md`).
> For SEO-optimized case studies that support proposals, see **trl-content-publishing** (`references/content-strategy.md`).

## Document Types

### Proposal vs. SOW vs. Hybrid

| Aspect | Proposal | Statement of Work | Hybrid |
|--------|----------|-------------------|--------|
| **Purpose** | Persuade — convince client to choose you | Define — specify exactly what will be delivered | Both — sell and specify in one document |
| **Tone** | Consultative, value-oriented | Precise, contractual | Professional, balanced |
| **When to use** | Competitive bids, new relationships | After verbal agreement, complex projects | Smaller engagements, existing relationships |
| **Binding** | Usually non-binding | Often contractually binding | Depends on terms section |
| **Length** | 3-8 pages | 5-20 pages | 6-15 pages |
| **Key sections** | Executive summary, approach, why us | Deliverables, milestones, acceptance criteria | All of the above |

### When to Use Which

```
Client says "send me a proposal"
├── Competitive situation? → Proposal (persuade first)
│   └── They choose you → SOW (formalize scope)
├── Already chosen you? → Hybrid or SOW
│   ├── Simple project → Hybrid (one document)
│   └── Complex project → SOW (detailed scope)
└── Existing relationship? → SOW or Change Order
    ├── New project → SOW
    └── Scope change → Change Order / Addendum
```

## Document Architecture

### Proposal Sections

| Section | Required | Purpose |
|---------|----------|---------|
| **Cover page** | Yes | Project title, client name, your name/company, date, version |
| **Executive summary** | Yes | 1-2 paragraphs: problem, solution, outcome, investment range |
| **Understanding** | Yes | Demonstrate you understand the client's situation and goals |
| **Scope of work** | Yes | What you'll do, organized by phase or workstream |
| **Out of scope** | Yes | Explicit exclusions to prevent scope creep |
| **Deliverables** | Yes | Tangible outputs with descriptions |
| **Timeline** | Yes | Phases, milestones, and durations |
| **Investment** | Yes | Pricing with model explanation |
| **Assumptions** | Yes | Conditions that must hold for the plan to work |
| **About us** | Recommended | Team, credentials, relevant experience |
| **Case studies** | Optional | 1-2 relevant past projects with outcomes |
| **Terms and conditions** | Depends | Payment terms, IP, confidentiality, termination |
| **Next steps** | Yes | Clear call to action with timeline |

### SOW Sections

| Section | Required | Purpose |
|---------|----------|---------|
| **Header block** | Yes | Parties, effective date, SOW number, reference to MSA |
| **Background** | Yes | Context for why this work exists |
| **Objectives** | Yes | Measurable goals the work must achieve |
| **Scope of work** | Yes | Detailed description of all work to be performed |
| **Out of scope** | Yes | Explicit exclusions |
| **Deliverables table** | Yes | Each deliverable with description, format, acceptance criteria |
| **Milestone schedule** | Yes | Milestones with dates, deliverables, and payment triggers |
| **Acceptance process** | Yes | How deliverables are reviewed, approved, or rejected |
| **Assumptions & dependencies** | Yes | Client obligations, environment requirements, third-party dependencies |
| **Pricing & payment** | Yes | Total cost, payment schedule, expense policy |
| **Change control** | Yes | Process for requesting and approving scope changes |
| **Roles & responsibilities** | Recommended | RACI or simple table of who does what |
| **Risk register** | Recommended | Known risks with probability, impact, and mitigation |
| **Terms** | Yes | Reference to MSA or standalone terms |

## Proposal Workflow

### Phase 1: Discovery & Requirements

Extract what you need to write a credible proposal.

| Activity | Output | Questions to Answer |
|----------|--------|---------------------|
| Client interview | Raw notes | What problem? What outcome? What constraints? |
| Stakeholder mapping | Decision-maker list | Who decides? Who influences? Who signs? |
| Requirements extraction | Requirements list | What must the solution do? What are the priorities? |
| Constraint identification | Constraint list | Budget range? Timeline? Technology? Compliance? |
| Success criteria | Measurable outcomes | How will the client judge success? |

**Key discovery questions:**

1. What's the business problem this project solves?
2. What does success look like in 6 months?
3. What's been tried before? What worked / didn't?
4. Who are the stakeholders and what are their priorities?
5. What's the budget range? (or: is this budgeted?)
6. What's driving the timeline?
7. What internal resources will be available?
8. What systems/tools must we integrate with?
9. What are the compliance or security requirements?
10. What's the decision process and timeline for selecting a vendor?

### Phase 2: Scoping & Estimation

Translate requirements into deliverables and effort.

| Activity | Output | Technique |
|----------|--------|-----------|
| Work decomposition | Work breakdown structure | Top-down decomposition into phases → tasks |
| Effort estimation | Hour/day estimates per task | Three-point estimation (optimistic, likely, pessimistic) |
| Risk assessment | Risk register | Probability × impact matrix |
| Dependency mapping | Dependency list | Client obligations, third-party, sequential constraints |
| Pricing model selection | Pricing structure | Decision matrix (see Pricing Framework below) |

### Phase 3: Drafting

Write the document section by section.

| Order | Section | Drafting Notes |
|-------|---------|----------------|
| 1 | Scope & deliverables | Write first — everything else flows from this |
| 2 | Out of scope | Write immediately after scope while boundaries are fresh |
| 3 | Timeline & milestones | Sequence the deliverables, add buffer |
| 4 | Assumptions | Capture everything you're taking for granted |
| 5 | Pricing | Calculate from scope + timeline + risk |
| 6 | Understanding | Now that you've scoped it, articulate the client's problem |
| 7 | Executive summary | Write last — it summarizes everything above |
| 8 | About us / case studies | Tailor to this specific client's concerns |
| 9 | Terms & next steps | Standard sections with project-specific adjustments |

### Phase 4: Review & Polish

Quality checks before submission.

| Check | What to Verify |
|-------|----------------|
| **Scope completeness** | Every requirement has a corresponding deliverable |
| **Scope-price alignment** | Price is justified by the scope, not arbitrary |
| **Assumptions coverage** | No unstated assumptions lurking |
| **Exclusions clarity** | Out-of-scope items would prevent a reasonable person from assuming they're included |
| **Timeline realism** | Buffer exists, dependencies are sequential, no impossible parallelism |
| **Acceptance criteria** | Each deliverable has a testable acceptance criterion |
| **Consistency** | Dates, numbers, names are consistent throughout |
| **Tone calibration** | Professional but not stiff, confident but not arrogant |
| **Client language** | Uses the client's terminology, not your internal jargon |
| **Call to action** | Clear next step with a specific timeline |

## Pricing Framework

### Model Selection

| Model | Best When | Risk Allocation | Client Preference |
|-------|-----------|-----------------|-------------------|
| **Fixed-price** | Scope is well-defined, requirements are stable | You bear scope risk | Clients who want budget certainty |
| **Time & materials** | Scope is evolving, discovery-heavy work | Client bears scope risk | Clients comfortable with uncertainty |
| **Milestone-based** | Clear phase gates, deliverable-driven work | Shared — each milestone is a mini fixed-price | Most common compromise |
| **Retainer** | Ongoing advisory, maintenance, fractional roles | Client bears utilization risk | Clients who want ongoing access |
| **Hybrid** | Mixed work types in one engagement | Split by workstream | Sophisticated buyers |

### Pricing Decision Tree

```
Is the scope well-defined and stable?
├── Yes → Can you estimate confidently (±15%)?
│   ├── Yes → Fixed-price or Milestone-based
│   └── No → Milestone-based with re-estimation gates
└── No → Is it ongoing/advisory work?
    ├── Yes → Retainer
    └── No → T&M with a cap, or Discovery phase (fixed) → Execution (milestone)
```

### Price Calculation

```
Base cost = Σ(estimated hours × rate) for each role/task
Risk buffer = Base cost × risk multiplier (10-30% depending on uncertainty)
Margin = (Base + buffer) × target margin
Price = Base + buffer + margin

Three-point estimation per task:
  Expected = (Optimistic + 4×Likely + Pessimistic) / 6
  Standard deviation = (Pessimistic - Optimistic) / 6
```

## Deliverables Engineering

### Writing Good Deliverables

Each deliverable should pass the **STAMP test:**

| Criterion | Question | Bad Example | Good Example |
|-----------|----------|-------------|--------------|
| **S**pecific | Is it a concrete thing, not an activity? | "Backend development" | "REST API with 12 endpoints per specification" |
| **T**estable | Can acceptance be objectively verified? | "High-quality code" | "Code passing all unit tests with ≥80% coverage" |
| **A**ssignable | Is someone responsible for producing it? | "System improvements" | "Performance audit report authored by lead engineer" |
| **M**easurable | Can you tell when it's done? | "Ongoing support" | "4 weekly 1-hour support calls, response within 4 business hours" |
| **P**riced | Does it map to a cost or milestone payment? | (no price link) | "Milestone 2 payment triggered on acceptance" |

### Deliverables Table Format

| # | Deliverable | Description | Format | Acceptance Criteria | Milestone |
|---|-------------|-------------|--------|---------------------|-----------|
| D1 | {Name} | {What it is and what it contains} | {PDF, repo, deploy, etc.} | {Testable condition} | M1 |
| D2 | {Name} | {Description} | {Format} | {Criteria} | M2 |

## Assumptions & Risk Management

### Assumption Categories

| Category | Examples |
|----------|---------|
| **Client obligations** | Timely feedback (within N days), access to systems, designated point of contact |
| **Environment** | Existing infrastructure works as documented, APIs are stable, data is clean |
| **Timeline** | No holidays or freezes during project, resources available as planned |
| **Scope** | Requirements are final at project start, no regulatory changes mid-project |
| **Third-party** | Vendor APIs meet documented specs, licenses are current, SLAs are honored |

### Risk Register Format

| ID | Risk | Probability | Impact | Mitigation | Owner |
|----|------|-------------|--------|------------|-------|
| R1 | {What could go wrong} | H/M/L | H/M/L | {What you'll do about it} | {Who} |

### The Assumptions-to-Change-Order Pipeline

```
Assumption stated in proposal
  → Assumption violated during project
    → Change order triggered (not a surprise)
      → Additional scope/cost/timeline negotiated formally
```

This pipeline is why assumptions matter: they're your contractual basis for handling the unexpected.

## Change Control Process

### Standard Change Order Template

1. **Change description** — What is changing and why
2. **Impact analysis** — Effect on scope, timeline, and cost
3. **Options** — At least two approaches (including "do nothing")
4. **Recommendation** — Your suggested path with rationale
5. **Approval** — Signature/email confirmation required before work begins

### Change Classification

| Type | Example | Process |
|------|---------|---------|
| **Cosmetic** | Wording changes, minor UI tweaks | Absorb within existing scope |
| **Minor** | Small feature addition, data format change | Document, estimate, get written approval |
| **Major** | New workstream, platform change, timeline shift | Formal change order with re-estimation |
| **Fundamental** | Complete direction change, project pivot | New SOW recommended |

## Quick Start Guides

### Write a Proposal from Scratch
1. Gather client discovery notes (or run through discovery questions in Phase 1)
2. Decompose work into phases and deliverables
3. Select pricing model using the decision tree
4. Draft sections in the recommended order (scope first, executive summary last)
5. Run the Phase 4 review checklist
6. Format and submit with clear next steps

### Convert a Verbal Agreement to a SOW
1. Document what was agreed verbally — scope, timeline, price
2. Expand into formal SOW sections (deliverables table, milestones, acceptance criteria)
3. Add assumptions and out-of-scope sections
4. Add change control process
5. Review for gaps between what was discussed and what's written
6. Send for client review with a specific response deadline

### Respond to an RFP
1. Read the entire RFP and extract: requirements, evaluation criteria, submission format, deadline
2. Create a compliance matrix mapping each requirement to your response
3. Draft proposal following the RFP's required structure (not your preferred structure)
4. Ensure every evaluation criterion is addressed explicitly
5. Add differentiators in permitted sections (approach, team, case studies)
6. Review compliance matrix — every cell must have a response

### Handle a Scope Change
1. Document the requested change and its origin
2. Analyze impact on scope, timeline, and cost
3. Present options (including "absorb" and "formal change order")
4. Get written approval before starting any new work
5. Update the SOW or create an addendum

## Reference Guide

### When to Read Each Reference

| Task | Read These |
|------|-----------|
| **Writing any proposal/SOW** | `doc-types/proposal-template.md`, `doc-types/sow-template.md` |
| **Choosing pricing** | `patterns/pricing-models.md` |
| **Writing deliverables** | `patterns/deliverables-patterns.md` |
| **Agent-driven generation** | `agent-playbook.claude-code.md` |
| **Full worked example** | `worked-example-saas-rebuild.md` |

All reference paths are relative to `references/`.

## Related Skills

- **trl-market-intelligence** — Research client's market, competitors, and industry context before writing the proposal
- **trl-technical-writer** — Apply technical writing best practices to proposal prose quality
- **trl-user-experience-engineer** — Design visually polished proposal presentations and pitch decks
- **trl-content-publishing** — Write case studies and thought leadership that support proposal credibility
- **trl-conversion-engineer** — Position proposals within a broader client acquisition pipeline
- **trl-monetization-strategy** — Align proposal pricing with your overall revenue strategy

## Bundled Resources

### References

**Document Types** (`references/doc-types/`):
- [proposal-template.md](references/doc-types/proposal-template.md) — Section-by-section proposal template with guidance notes
- [sow-template.md](references/doc-types/sow-template.md) — Formal SOW template with contractual language patterns
- [change-order-template.md](references/doc-types/change-order-template.md) — Change order / addendum template

**Patterns** (`references/patterns/`):
- [pricing-models.md](references/patterns/pricing-models.md) — Deep dive on pricing structures, risk allocation, and calculation methods
- [deliverables-patterns.md](references/patterns/deliverables-patterns.md) — Patterns for writing STAMP-compliant deliverables across project types

**Core**:
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition and execution workflows
- [worked-example-saas-rebuild.md](references/worked-example-saas-rebuild.md) — End-to-end worked example: proposal for a SaaS platform rebuild

### Assets

- [proposal-brief-worksheet.md](assets/proposal-brief-worksheet.md) — Fillable intake form for capturing client requirements and project parameters
- [review-checklist.md](assets/review-checklist.md) — Pre-submission quality checklist
- [project-tracker.md](assets/project-tracker.md) — Proposal-writing project tracker

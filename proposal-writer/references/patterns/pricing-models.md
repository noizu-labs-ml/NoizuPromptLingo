# Pricing Models for Proposals & SOWs

A deep-dive reference on pricing structures used in professional services proposals and statements of work. Each model carries distinct risk profiles, trust dynamics, and contractual mechanics.

---

## Comparison Table

| Model | Risk Bearer | Best For | Trust Required | Admin Overhead |
|---|---|---|---|---|
| Fixed-Price | Vendor | Well-scoped, stable requirements | Low | Low |
| Time & Materials | Client | Exploratory, evolving scope | High | High |
| Milestone-Based | Split (per gate) | Phased delivery, clear checkpoints | Medium | Medium |
| Retainer | Client | Ongoing advisory, recurring needs | High | Low-Medium |
| Hybrid | Split (by phase) | Complex engagements with unknowns | Medium | Medium-High |

---

## Decision Flowchart

```
Are requirements fully defined and stable?
├── YES → Fixed-Price
│         └── Is it large (>$50K or >3 months)?
│               ├── YES → Milestone-Based Fixed
│               └── NO  → Pure Fixed-Price
└── NO  → Are you iterating/exploring?
           ├── YES → Is client risk-tolerant and high-trust?
           │           ├── YES → T&M (with cap)
           │           └── NO  → Milestone (discovery first, then re-scope)
           └── NO  → Is this ongoing advisory/support?
                       ├── YES → Retainer
                       └── NO  → Hybrid (fixed discovery → milestone execution)
```

---

## 1. Fixed-Price

### When to Use

- Requirements are fully specified and unlikely to change
- Engagement is bounded in scope and time (typically under 3 months or $75K)
- Client is risk-averse and wants budget certainty
- You have done similar work before and can estimate confidently
- Change order process is clearly defined and enforceable

### How to Calculate: Three-Point Estimation

Use the PERT formula for each work package:

```
Expected = (Optimistic + 4×Most Likely + Pessimistic) / 6
Std Dev  = (Pessimistic - Optimistic) / 6
```

Sum all work packages. Apply risk buffer:

| Risk Level | Buffer |
|---|---|
| Low (known domain, stable requirements) | 10–15% |
| Medium (some unknowns, moderate complexity) | 20–25% |
| High (novel domain, unclear requirements) | 30–40% |
| Never quote fixed-price | Greenfield R&D, regulatory uncertainty |

**Calculation worksheet:**

```
Task 1:  Optimistic 8h, Most Likely 12h, Pessimistic 20h → Expected: 12.7h
Task 2:  Optimistic 4h, Most Likely 6h,  Pessimistic 12h → Expected:  6.3h
...
Total Expected Hours: 142h
× Blended Rate: $175/h
= Base Cost: $24,850
+ Risk Buffer (20%): $4,970
= Quoted Price: $29,820
→ Round to: $29,500 or $30,000
```

### Risk Allocation

```
CLIENT: Scope creep risk (bears cost of changes via COs)
VENDOR: Estimation risk (bears cost of underestimation)
SHARED: Requirement quality (ambiguity hurts both)
```

### Example Contract Language

```
The total fixed fee for the Services described in Exhibit A is $29,500 USD
("Fixed Fee"), payable as set forth in Section 4. The Fixed Fee is inclusive
of all labor, tools, and out-of-pocket expenses unless otherwise specified.
Any work outside the scope defined in Exhibit A requires a written Change
Order executed by both parties prior to commencement. Change Orders are priced
at the rates set forth in Exhibit B.
```

### Advantages

- Budget certainty for client
- Low administrative overhead (no timesheets)
- Aligns vendor incentive with efficiency
- Easier to sell (single number)

### Disadvantages

- Vendor bears estimation risk entirely
- Scope creep disputes are common
- Requires robust change order discipline
- Can incentivize cutting corners to protect margin

### When It Fails

- Requirements change mid-project and CO process breaks down
- Initial scope was ambiguous — both parties had different mental models
- Vendor underestimated and starts cutting scope or quality silently
- Client has a "scope expansion by interpretation" pattern

### Common Pitfalls

- Quoting fixed-price on discovery work (never do this)
- Insufficient change order language — leaves gaps that favor client
- No explicit exclusions list in scope definition
- Underestimating QA, documentation, and project management overhead

---

## 2. Time & Materials (T&M)

### When to Use

- Scope is evolving, exploratory, or genuinely unknown
- Client wants maximum flexibility to redirect effort
- Engagement is a long-running partnership
- Discovery phase output requires adaptation
- Both parties have high trust and transparency

### Rate Cards

Structure rate cards by role, not individual. Publish one blended rate or a tiered table:

```
Role                    | Rate (USD/h)
------------------------|-------------
Principal / Architect   | $225–$275
Senior Engineer         | $175–$225
Mid-Level Engineer      | $125–$175
Junior / Associate      | $85–$125
Project Manager         | $150–$185
UX Designer             | $150–$200
```

Blended rate example: "All work billed at $175/h (blended across all roles)."

### Cap Structures

| Cap Type | Description | When to Use |
|---|---|---|
| Hard Cap | Work stops at cap; no overrun | Fixed-budget clients; scope uncertain |
| Not-to-Exceed (NTE) | Vendor must notify at 80%, stops at 100% | Moderate trust; some flexibility |
| Budget Alerts | Notifications at 50%, 75%, 90% of budget | High trust; continuous collaboration |
| No Cap | Pure T&M, unlimited | Long-running partnerships only |

**NTE contract language:**

```
Total fees under this Agreement shall not exceed $85,000 USD ("Not-to-Exceed
Amount") without prior written authorization. Vendor will notify Client when
cumulative fees reach 75% of the Not-to-Exceed Amount. If the Not-to-Exceed
Amount is reached, work will pause and the parties will negotiate a budget
amendment or revised scope before resuming.
```

### Tracking and Reporting Requirements

Establish these upfront:

- Weekly time reports (role, task, hours) delivered every Monday for prior week
- Monthly invoice with itemized line items tied to deliverables or epics
- Real-time dashboard access (optional — Harvest, Toggl, or shared spreadsheet)
- Budget burn rate report alongside each invoice

### Trust-Building Techniques

- Over-communicate on hours — send a brief weekly narrative with the timesheet
- Flag overruns before they happen, not after
- Offer to cap exploration tasks ("I'll spend max 4h on this spike")
- Provide monthly retrospectives showing value delivered per dollar spent
- Use burn-up charts, not just invoices

### Risk Allocation

```
CLIENT: Bears all cost risk (scope creep = more cost)
VENDOR: Bears utilization risk (slow periods = lower revenue)
SHARED: Communication risk (poor feedback loops waste hours)
```

### Common Pitfalls

- No cap on exploratory tasks — hours spiral on rabbit holes
- Timesheets submitted too late to course-correct spending
- Rate card ambiguity (which role applies to which task?)
- Client approval delays billed as vendor hours
- No agreed process for client-caused blockers (do you still bill?)

---

## 3. Milestone-Based

### When to Use

- Large engagements (>$50K or >3 months) that benefit from fixed-price certainty
- Phased delivery where each phase has clear, verifiable outputs
- Client wants to gate payment against progress, not just time
- Complex projects where risk is unevenly distributed across phases

### Structuring Milestones

Each milestone is a mini fixed-price unit. Rules:

1. **One milestone = one verifiable output** — not a time period
2. **Milestone scope must be exhaustive** — list all inputs required and all deliverables produced
3. **Acceptance criteria must be binary** — pass/fail, not "looks good"
4. **Payment triggers on acceptance** — not on submission
5. **Acceptance window must be defined** — e.g., "Client has 5 business days to accept or provide written rejection with specific deficiencies"

### Example Milestone Structure

```
Milestone 1: Discovery & Architecture ($12,000)
  Deliverables:
    - Technical requirements document (≥15 pages)
    - System architecture diagram (C4 model, L1–L3)
    - Data model ERD
    - Risk register with mitigation strategies
  Inputs required from Client:
    - API credentials for existing systems
    - Access to 2 subject matter experts for 4h total
  Acceptance criteria:
    - All deliverables submitted
    - No blocking comments from Client review within 5 business days
  Payment: 100% due upon acceptance

Milestone 2: Backend API ($28,000)
  Deliverables: ...
```

### Payment Triggers

Standard patterns:

| Pattern | Structure |
|---|---|
| Payment on acceptance | 100% upon written acceptance |
| Split deposit | 50% on start, 50% on acceptance |
| Progress + completion | 25% on start, 25% at midpoint, 50% on acceptance |
| Retention | 90% on acceptance, 10% released at 30-day warranty end |

### What Makes a Good Milestone Gate

A good milestone gate is:
- **Objective**: Either the deliverable exists and meets criteria, or it doesn't
- **Client-reviewable**: Client can evaluate without vendor explanation
- **Bounded**: Clear list of what is and isn't included
- **Independent**: Can be delivered without depending on a later milestone

A bad milestone gate is:
- "Client is satisfied with progress" (subjective)
- "Sprint 3 is complete" (time-based, not output-based)
- "System is working" (undefined acceptance criteria)

### Handling Milestone Rejection

Contract language:

```
If Client rejects a Milestone deliverable, Client must provide written notice
within the Acceptance Period specifying, with reasonable detail, the specific
deficiencies relative to the agreed acceptance criteria. Vendor will remediate
identified deficiencies within [10] business days at no additional charge.
Disputes not resolved within [30] days shall be escalated per Section 12
(Dispute Resolution). Client may not withhold acceptance for reasons unrelated
to the acceptance criteria defined for that Milestone.
```

### Risk Allocation

```
CLIENT: Acceptance risk (must review promptly; delays cascade)
VENDOR: Delivery risk (bears cost of rework within scope)
SHARED: Requirement quality (ambiguous criteria cause disputes)
```

### Common Pitfalls

- Milestones defined as time periods instead of outputs
- Acceptance criteria are vague or subjective
- No acceptance window — client sits on deliverables indefinitely
- Cascading dependency: Milestone 3 cannot start until Milestone 2 is accepted, creating idle time
- Change requests that should trigger COs get absorbed into "the next milestone"

---

## 4. Retainer

### When to Use

- Ongoing advisory, support, or content work
- Client needs guaranteed availability, not just output
- Relationship-based engagement where trust is established
- Work is recurring but volume varies month to month
- You want predictable revenue; client wants guaranteed access

### Monthly Retainer Structures

| Type | Structure | Best For |
|---|---|---|
| Hours-Based | Client buys N hours/month | Defined-capacity advisory |
| Outcome-Based | Client buys defined output volume | Content, reporting, deliverables |
| Availability-Based | Client pays for access/priority | Fractional CTO, on-call advisory |
| Hybrid | Base hours + surge rate for overages | Most common |

**Example: 20-hour/month retainer at $175/h = $3,500/month**

### Rollover Policies

Define clearly in contract:

```
Option A (No Rollover):
  Unused hours expire at month-end. Client bears utilization risk.
  Best for: vendor; simplest to administer.

Option B (Full Rollover, capped):
  Unused hours roll forward, capped at 1.5× monthly allotment (30h cap on 20h retainer).
  Best for: clients with variable demand.

Option C (Partial Rollover):
  Up to 50% of unused hours roll forward. Expires after 60 days.
  Best for: balanced risk between parties.
```

Contract language (no rollover):

```
Unused hours in any calendar month shall not roll over to subsequent months.
Client acknowledges that the Retainer Fee represents guaranteed availability
and capacity reservation, not a deposit for future hours.
```

### Utilization Tracking

Monthly report format:

```
Month: April 2026
Hours Purchased: 20
Hours Used: 17.5
Hours Remaining: 2.5 (expires May 1)
Tasks Completed: [list]
Rollover: N/A
```

### Scope Boundaries Within Retainers

This is the most common conflict point. Define:

- **In-scope activities**: Advisory calls, document review, email Q&A, defined deliverables
- **Out-of-scope activities**: Implementation, third-party vendor management, on-site work
- **Surge handling**: Hours beyond retainer billed at $[X]/h or require a separate engagement letter

```
The Retainer covers advisory services as defined in Exhibit A. Implementation
work, defined as hands-on code, configuration, or build work, is not covered
under the Retainer and requires a separate Statement of Work or will be billed
at the applicable rate in Exhibit B.
```

### Risk Allocation

```
CLIENT: Utilization risk (pays whether or not they use hours)
VENDOR: Availability risk (must be available; limits other commitments)
SHARED: Scope creep risk (what counts as "advisory" can be disputed)
```

### Rate Calculation Guidance

Retainer rates are typically set 10–20% below T&M project rates to reflect:
- Guaranteed revenue (vendor discount)
- Predictable planning (vendor premium — offset)
- Net: slight discount for client, slight stability premium for vendor

A $175/h project rate → $150–$160/h retainer rate (15h minimum per month).

### Common Pitfalls

- No scope boundary definition — retainer becomes unlimited support
- No rollover policy — client feels cheated when months are underutilized
- Retainer rate set too low — vendor resents the arrangement over time
- No escalation path when demand spikes beyond retainer hours
- Retainer renewed month-to-month without rate review — inflation erodes margin

---

## 5. Hybrid Models

### Discovery (Fixed) → Execution (Milestone)

The most common hybrid. Addresses the core problem: you can't scope execution accurately until you've done discovery.

```
Phase 1: Discovery (Fixed-Price, $8,000, 2 weeks)
  Deliverables: Requirements doc, architecture, data model, risk register
  Outcome: Execution SOW with milestone pricing

Phase 2: Execution (Milestone-Based, TBD at Phase 1 completion)
  Milestones: Scoped after Phase 1 output is reviewed
  Option for client: Review Phase 2 SOW and proceed or not
```

Contract language:

```
This Agreement covers Phase 1 (Discovery) only. Upon completion of Phase 1
Deliverables, Vendor will deliver a Phase 2 Statement of Work for Client review.
Client has no obligation to proceed with Phase 2. Phase 2 will be governed by a
separate Agreement or Amendment incorporating the Phase 2 SOW.
```

### Advisory (Retainer) + Project (Fixed)

Common for clients with an ongoing advisory relationship who occasionally need execution:

```
Base: $3,500/month retainer (20h advisory)
Project: Separate fixed-price SOW for defined project work
         Advisory hours do not apply to project; project hours do not apply to retainer
```

### T&M Discovery → Fixed Execution

Variation for exploratory clients:

```
Phase 1: T&M (NTE $15,000) — explore options, prototype, validate
Phase 2: Fixed-price based on Phase 1 findings
```

### Common Hybrid Combinations

| Combination | Use Case |
|---|---|
| Fixed discovery + Milestone execution | Standard product builds |
| Retainer + Fixed project | Ongoing clients with periodic projects |
| T&M exploration + Fixed delivery | R&D → productization |
| Milestone build + Retainer support | Post-launch support model |
| Fixed MVP + T&M scale | Startup → growth phase |

### Risk Allocation

```
CLIENT: Phase transition risk (must commit to Phase 2 or lose momentum)
VENDOR: Estimation risk in Phase 2 (better than pure fixed because discovery de-risks it)
SHARED: Handoff quality (Phase 1 output quality directly affects Phase 2 pricing accuracy)
```

### Common Pitfalls

- Phase 1 output is insufficient to scope Phase 2 — causes re-discovery
- Client uses Phase 1 output to shop Phase 2 with other vendors
- Retainer + project hours get confused — always keep separate line items
- No explicit "option to proceed" language — client expects automatic Phase 2 start

---

## Rate Calculation Guidance (General)

### Market Rate Benchmarks (2025, USD, remote)

| Role | Freelance/h | Agency/h | Annual Salary Equivalent |
|---|---|---|---|
| Principal Engineer / Architect | $200–$300 | $250–$400 | $200K–$280K |
| Senior Engineer (5–8y) | $150–$225 | $200–$300 | $160K–$220K |
| Mid Engineer (2–5y) | $100–$150 | $150–$225 | $120K–$160K |
| UX/Product Designer | $125–$200 | $175–$275 | $130K–$180K |
| Project Manager | $100–$175 | $150–$225 | $110K–$160K |
| Technical Writer | $75–$125 | $100–$175 | $80K–$120K |

### Effective Rate Check

When quoting fixed-price, verify your implied effective rate:

```
Quoted Price: $30,000
Estimated Hours: 165h
Effective Rate: $30,000 / 165h = $181/h

Is $181/h acceptable for the roles involved? → Yes/No
```

If effective rate is below your floor rate, reprice or re-scope before quoting.

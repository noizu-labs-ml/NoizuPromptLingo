# Statement of Work Template

> **How to use this template:** An SOW is a contractual document, not a sales document. Language must be precise and unambiguous. Every obligation must name the responsible party and the completion criterion. Delete all guidance blockquotes before execution. This template assumes an executed Master Services Agreement (MSA) governs the relationship; if no MSA exists, expand the Terms & Conditions section or attach one.
>
> **Language conventions used throughout:**
> - **"shall"** — mandatory obligation (creates enforceable duty)
> - **"will"** — statement of intent or future fact (weaker than "shall")
> - **"may"** — discretionary permission (no obligation)
> - **"must"** — same force as "shall" — use consistently, not interchangeably with "shall"
> - Avoid **"should"** in contractual language — it is ambiguous between obligation and recommendation

---

## HEADER BLOCK

```
STATEMENT OF WORK

SOW Number:          SOW-[YYYY]-[NNN]
MSA Reference:       MSA-[YYYY]-[NNN] (if applicable)
Effective Date:      [Month DD, YYYY]
Expiration Date:     [Month DD, YYYY] (if SOW not signed by this date, it is void)

SERVICE PROVIDER
Company Name:        [Your Company Legal Name]
Address:             [Street, City, State/Province, Postal Code, Country]
Primary Contact:     [Name, Title]
Email:               [email]
Phone:               [phone]

CLIENT
Company Name:        [Client Legal Name]
Address:             [Street, City, State/Province, Postal Code, Country]
Primary Contact:     [Name, Title]
Email:               [email]
Phone:               [phone]
```

> **Guidance:** Use exact legal entity names — the names on file with the relevant business registry. "Acme Corp" and "Acme Corporation" are different entities. Confirm the contact has authority to execute agreements on behalf of their organization.

---

## 1. BACKGROUND & PURPOSE

> **Guidance:** State the business context that motivates this engagement. This section establishes the "why" and will be referenced if a dispute arises about intent. Be factual, not promotional. One to three paragraphs.
>
> **Language note:** Use past/present tense for facts. Reserve "shall" for obligations.

[Client Legal Name] ("Client") operates [brief description of relevant business context]. Client has determined that [description of the problem or need driving this engagement].

[Your Company Legal Name] ("Service Provider") has the expertise and capacity to provide [general description of services]. The parties have agreed to engage under the terms of this Statement of Work.

---

## 2. OBJECTIVES

> **Guidance:** List measurable outcomes, not activities. Each objective should be testable — at project close, you should be able to point to evidence that each objective was or was not met.
>
> **Common mistake:** Writing objectives as activities ("conduct workshops") rather than outcomes ("produce a validated architecture design").

This engagement shall accomplish the following objectives:

1. [Objective 1 — measurable, outcome-oriented]
2. [Objective 2]
3. [Objective 3]

---

## 3. SCOPE OF WORK

> **Guidance:** This is the core technical definition of the engagement. Be specific enough that a third party reading this section — with no prior context — could understand exactly what is and is not included. Organize by phase or workstream.
>
> **Language note:** Service Provider obligations shall use "shall." Client obligations shall also use "shall" — both parties have binding obligations.

### 3.1 Phase 1: [Phase Name]

Service Provider shall:

- [Specific deliverable or activity]
- [Specific deliverable or activity]
- [Specific deliverable or activity]

Client shall:

- [Specific client obligation, e.g., "provide access to the production database environment within five (5) business days of the Effective Date"]

### 3.2 Phase 2: [Phase Name]

Service Provider shall:

- [Specific deliverable or activity]

Client shall:

- [Specific client obligation]

### 3.3 Phase N: [Phase Name]

[Continue as needed.]

---

## 4. OUT OF SCOPE

> **Guidance:** Enumerate exclusions explicitly. "Items not listed above" is insufficient — it requires the reader to infer from absence. Name the things most likely to be assumed. Each bullet should be specific enough to resolve a real dispute.

The following are explicitly excluded from this Statement of Work and shall be addressed only via an executed Change Order:

- [Specific exclusion, e.g., "Integration with systems not identified in Section 3"]
- [Specific exclusion, e.g., "Migration of historical data predating [date]"]
- [Specific exclusion, e.g., "Training sessions beyond those defined in Section 5"]
- [Specific exclusion, e.g., "Post-delivery support, maintenance, or bug remediation"]
- [Specific exclusion, e.g., "Work requiring access to Client systems not specified in Section 8"]

---

## 5. DELIVERABLES TABLE

> **Guidance:** Every deliverable must have an acceptance criterion — a statement describing what "done" looks like. Vague acceptance criteria ("Client is satisfied") are unenforceable. Tie each deliverable to a milestone for payment tracking.
>
> **Format note:** "Format" refers to the medium of delivery (e.g., PDF, live system, workshop, executable software). "Acceptance Criteria" describes the standard the deliverable must meet.

| # | Deliverable | Description | Format | Acceptance Criteria | Milestone |
|---|-------------|-------------|--------|---------------------|-----------|
| D-01 | [Name] | [What it is and what it contains] | [PDF / DOCX / Live system / Workshop] | [Specific, testable criterion] | M-[N] |
| D-02 | | | | | |
| D-03 | | | | | |
| D-04 | | | | | |

**Example entries:**

| # | Deliverable | Description | Format | Acceptance Criteria | Milestone |
|---|-------------|-------------|--------|---------------------|-----------|
| D-01 | Discovery Report | Written summary of current-state findings and gaps | PDF, max 20 pages | Client acknowledges receipt in writing within five (5) business days | M-1 |
| D-02 | Architecture Design | System architecture diagram with component specifications | PDF + editable diagram file | No open critical or high defects after Client review period | M-2 |
| D-03 | Implementation | Configured and deployed system meeting requirements in Appendix A | Live system in Client environment | Passes acceptance test script defined in Appendix B | M-3 |

---

## 6. MILESTONE SCHEDULE

> **Guidance:** Milestones drive payments and create accountability checkpoints. Each milestone should correspond to a verifiable state — not a date. Include payment triggers. Buffer dates for Client review periods.
>
> **Language note:** "Target Date" signals these are estimates contingent on schedule assumptions in Section 9. If dates are hard contractual deadlines, use "Deadline" and state the consequence of missing it.

| Milestone | Description | Target Date | Payment Trigger |
|-----------|-------------|-------------|-----------------|
| M-0 | Agreement executed; project initiated | [Date] | [N]% of total fee due upon signing |
| M-1 | [Phase 1 complete; D-01 delivered] | [Date] | [N]% of total fee |
| M-2 | [Phase 2 complete; D-02, D-03 delivered] | [Date] | [N]% of total fee |
| M-3 | [Final delivery; all deliverables accepted] | [Date] | [N]% of total fee (final) |

Target dates assume Client meets all obligations defined in Section 3 and Section 9. Delays attributable to Client shall extend downstream milestone dates on a day-for-day basis.

---

## 7. ACCEPTANCE PROCESS

> **Guidance:** Define how deliverables get accepted. Without a defined process, "acceptance" is ambiguous and the Client can withhold payment indefinitely. Include: review period, revision rounds, deemed-accepted clause.

### 7.1 Review Period

Upon delivery of each Deliverable, Client shall have [five (5) / ten (10)] business days ("Review Period") to review and either:

(a) Accept the Deliverable in writing; or
(b) Provide a written list of specific deficiencies ("Deficiency Notice").

### 7.2 Revision Rounds

This SOW includes [two (2)] rounds of revisions per Deliverable. Service Provider shall address all deficiencies identified in a timely Deficiency Notice within [five (5)] business days of receipt. Additional revision rounds beyond those included shall be governed by Section 11 (Change Control).

### 7.3 Deemed Acceptance

If Client does not provide written acceptance or a Deficiency Notice within the Review Period, the Deliverable shall be deemed accepted as of the final day of the Review Period.

### 7.4 Partial Acceptance

Client may not withhold acceptance of an entire phase due to deficiencies in a single Deliverable. Client shall accept conforming Deliverables independently and identify non-conforming Deliverables specifically.

---

## 8. ROLES & RESPONSIBILITIES

> **Guidance:** A RACI matrix prevents "I thought you were handling that" disputes. R = Responsible (does the work), A = Accountable (owns the outcome), C = Consulted (provides input), I = Informed (receives updates). Each task should have exactly one A.

| Task | [SP Role] | [SP Role] | [Client Role] | [Client Role] |
|------|-----------|-----------|---------------|---------------|
| Project management | R/A | I | C | I |
| Requirements definition | C | I | R/A | C |
| [Task 3] | | | | |
| [Task 4] | | | | |
| Deliverable review and approval | I | I | C | R/A |
| Acceptance sign-off | I | I | I | R/A |

**Key contacts:**

| Role | Name | Email | Responsibility |
|------|------|-------|----------------|
| Service Provider Project Lead | | | Day-to-day delivery and escalations |
| Service Provider Engagement Lead | | | Commercial and contractual matters |
| Client Project Sponsor | | | Strategic decisions and final approvals |
| Client Project Contact | | | Day-to-day coordination and feedback |

---

## 9. ASSUMPTIONS & DEPENDENCIES

> **Guidance:** Every assumption is a risk. Name them. If an assumption proves false, you have contractual grounds to issue a Change Order. Dependencies on third parties (other vendors, regulatory approvals) should also be named.

This SOW is predicated on the following assumptions. If any assumption proves materially incorrect, either party may initiate a Change Order under Section 11.

### Service Provider Assumptions

1. Client shall provide access to [specific systems, environments, data] within [five (5)] business days of the Effective Date.
2. Client shall assign a named Project Contact with authority to provide approvals on behalf of Client.
3. Client feedback on Deliverables shall be provided within the Review Period defined in Section 7.
4. [Specific technical assumption, e.g., "Existing infrastructure meets the minimum specifications in Appendix A"].
5. [Organizational assumption, e.g., "Client stakeholders required for discovery workshops are available during Phase 1"].

### External Dependencies

1. [Third-party system or vendor] shall be available and accessible during the engagement.
2. [Regulatory approval / procurement process] shall be complete before [milestone].

---

## 10. PRICING & PAYMENT SCHEDULE

> **Guidance:** State the total engagement value clearly. Tie payment to milestones, not to calendar dates — milestone-based payments align incentives. Specify late payment consequences. Specify the invoicing mechanism.

### 10.1 Total Engagement Value

The total fee for services under this SOW is **[Currency] [Amount]** ("Engagement Fee"), exclusive of expenses.

### 10.2 Expenses

[Select one:]
- Expenses are included in the Engagement Fee. No additional expense charges apply.
- Expenses are billed at cost with prior written approval required for any single expense exceeding [Currency] [Amount]. Service Provider shall provide receipts for all expenses.

### 10.3 Payment Schedule

| Invoice # | Milestone | Amount | Due Date |
|-----------|-----------|--------|----------|
| INV-001 | M-0: Agreement executed | [Amount] | Due upon signing |
| INV-002 | M-1: [Milestone description] | [Amount] | Due within [N] days of milestone |
| INV-003 | M-2: [Milestone description] | [Amount] | Due within [N] days of milestone |
| INV-004 | M-3: Final acceptance | [Amount] | Due within [N] days of final acceptance |

### 10.4 Payment Terms

Invoices are due within [fifteen (15) / thirty (30)] days of the invoice date ("Due Date"). Invoices unpaid after the Due Date shall accrue interest at [1.5%] per month (or the maximum rate permitted by applicable law, whichever is lower). Service Provider reserves the right to suspend services for invoices more than [thirty (30)] days past due.

### 10.5 Invoicing

Service Provider shall submit invoices to [Client billing contact / accounts payable email]. Invoices shall reference this SOW number and the applicable Milestone.

---

## 11. CHANGE CONTROL PROCESS

> **Guidance:** Undefined change control is the leading cause of scope creep and revenue leakage. This section enforces that all scope changes are written, agreed, and priced before work begins. No verbal change orders.

### 11.1 Change Request Initiation

Either party may initiate a change to this SOW by submitting a written Change Order request. Oral instructions to perform out-of-scope work do not constitute authorization.

### 11.2 Change Order Requirements

All Change Orders shall:

- Reference this SOW by number
- Describe the requested change with specificity
- Identify the impact on scope, timeline, and fees
- Be executed in writing by authorized representatives of both parties before any out-of-scope work commences

### 11.3 Disputed Changes

If the parties disagree on whether a requested item is within scope, Service Provider may, at its discretion:

(a) Pause work on the disputed item pending resolution; or
(b) Perform the work under reservation of rights and invoice separately, pending written resolution.

Service Provider shall not be in breach for declining to perform work not covered by an executed Change Order.

---

## 12. RISK REGISTER

> **Guidance:** A risk register in the SOW sets shared expectations. It is not an admission of likely failure — it is evidence of professional judgment. Each risk should have an owner and a mitigation. Update this at kickoff.

| # | Risk | Likelihood | Impact | Owner | Mitigation |
|---|------|------------|--------|-------|------------|
| R-01 | Client stakeholder unavailability during critical phases | Medium | High | Client | Identify backup decision-makers at kickoff |
| R-02 | [Third-party system] unavailable or incompatible | Low | High | Service Provider | Validate compatibility in Phase 1 |
| R-03 | Scope creep from undocumented requirements | Medium | Medium | Both | Strict adherence to Section 11 Change Control |
| R-04 | [Project-specific risk] | | | | |

---

## 13. TERM & TERMINATION

### 13.1 Term

This SOW shall commence on the Effective Date and continue until all Deliverables have been accepted and all invoices paid, unless earlier terminated.

### 13.2 Termination for Convenience

Either party may terminate this SOW with [thirty (30)] days written notice to the other party. Upon termination:

(a) Client shall pay for all work completed and accepted to the date of termination;
(b) Client shall pay for all work in progress, pro-rated to the date of termination;
(c) Service Provider shall deliver all completed and in-progress work product to Client upon receipt of payment.

### 13.3 Termination for Cause

Either party may terminate immediately if the other party materially breaches this SOW and fails to cure such breach within [fifteen (15)] business days of written notice describing the breach.

---

## 14. SIGNATURES

> **Guidance:** Both authorized signatories must sign. Confirm each person has actual authority — not just apparent authority — to bind their organization. Date fields must be filled in at time of signing.

By signing below, the parties agree to the terms of this Statement of Work and confirm that the individuals signing have authority to bind their respective organizations.

**SERVICE PROVIDER**

```
Signature:  _______________________________

Print Name: _______________________________

Title:      _______________________________

Date:       _______________________________

Company:    [Your Company Legal Name]
```

**CLIENT**

```
Signature:  _______________________________

Print Name: _______________________________

Title:      _______________________________

Date:       _______________________________

Company:    [Client Legal Name]
```

---

*SOW Number: SOW-[YYYY]-[NNN] | Effective Date: [Date] | Version: 1.0*
*This document, together with any referenced MSA, constitutes the entire agreement between the parties with respect to its subject matter.*

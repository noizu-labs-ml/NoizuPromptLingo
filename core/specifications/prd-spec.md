# PRD (Product Requirements Document) Specification
Convention for structuring product requirements documents with consistent formatting, stakeholder alignment, and NPL syntax integration.

## NPL Dependencies

You must run the following command to proceed:

```bash
npl-load c "syntax,agent,fences,directive,pumps.intent,pumps.critique,formatting.template" --skip {@npl.def.loaded}
```

### See Also
- `npl-load c "fences"` - Fence type reference
- `npl-load c "directive"` - Directive patterns
- `npl-load c "pumps"` - Reasoning pump documentation

---

## Purpose
This specification defines the standard structure for Product Requirements Documents (PRDs), enabling consistent communication of product vision, requirements, and success criteria across teams and AI agents.

## Design Principles

**clarity**
: Requirements must be unambiguous; each requirement has one interpretation

**completeness**
: All necessary information for implementation included; no implicit assumptions

**testability**
: Every requirement maps to verifiable acceptance criteria

**traceability**
: Requirements link to business objectives, user stories, and technical specs

**prioritization**
: Clear distinction between must-have, should-have, and nice-to-have features

---

## Directive Reference

### PRD Directives

**product-overview**
: `⟪📦 product-overview: product-name | target-audience | value-proposition⟫`
: Declares product identity and core value

```example
⟪📦 product-overview: TaskFlow | remote teams | streamlined async collaboration⟫
```

**problem-statement**
: `⟪🎯 problem: problem-summary | impact | affected-users⟫`
: Defines the problem being solved

```example
⟪🎯 problem: context switching kills productivity | 2.1h/day lost | knowledge workers⟫
```

**success-metrics**
: `⟪📊 success: metric-name | target | measurement-method⟫`
: Defines measurable success criteria

```example
⟪📊 success: task completion rate | +25% | analytics tracking⟫
```

**requirement**
: `⟪📋 req: requirement-id | priority | category⟫`
: Tags individual requirements with metadata

```example
⟪📋 req: FR-001 | P0 | core-functionality⟫
```

**dependency**
: `⟪🔗 depends: requirement-id | dependency-type | blocking-status⟫`
: Declares requirement dependencies

```example
⟪🔗 depends: FR-003 | requires FR-001 | blocking⟫
```

**risk**
: `⟪⚠️ risk: risk-name | likelihood | impact | mitigation⟫`
: Documents identified risks

```example
⟪⚠️ risk: API rate limits | medium | high | implement caching layer⟫
```

### Cross-Reference Syntax

**sub-file-reference**
: `→ See: relative/path/to/file.md`
: Links to detailed sub-file documentation

```example
→ See: docs/PRD/user-stories.md
```

**section-anchor**
: `⟪📂: {section-id}⟫`
: Marks section for cross-referencing

```example
⟪📂: {auth-requirements}⟫
## Authentication Requirements
[...]
```

---

## Main File Template

```format
# PRD: <product-name>
Product Requirements Document for <product-name|brief description>.

⟪📦 product-overview: <product-name> | <target-audience> | <value-proposition>⟫

**version**
: <version-number>

**status**
: <draft|review|approved|superseded>

**owner**
: <product-owner-name>

**last-updated**
: <YYYY-MM-DD>

**stakeholders**
: <stakeholder-list>

---

## Executive Summary

[...|2-3 paragraph overview of the product, its purpose, and key objectives]

---

## Problem Statement

⟪🎯 problem: <problem-summary> | <impact> | <affected-users>⟫

### Current State
[...|description of current situation and pain points]

### Desired State
[...|description of target outcome]

### Gap Analysis
| Aspect | Current | Desired | Gap |
|:-------|:--------|:--------|:----|
| <aspect> | <current-state> | <desired-state> | <gap-description> |
| [...] ||||

---

## Goals and Objectives

### Business Objectives
1. <objective-1|measurable business goal>
2. <objective-2>
3. [...]

### User Objectives
1. <user-goal-1|what users want to achieve>
2. <user-goal-2>
3. [...]

### Non-Goals
🚫 <explicitly-excluded-scope-item-1>
🚫 <explicitly-excluded-scope-item-2>
🚫 [...]

---

## Success Metrics

⟪📊 success: <primary-metric> | <target-value> | <measurement-method>⟫

| Metric | Baseline | Target | Timeframe | Measurement |
|:-------|:---------|:-------|:----------|:------------|
| <metric-name> | <baseline-value> | <target-value> | <timeframe> | <how-measured> |
| [...] |||||

### Key Performance Indicators (KPIs)

**<kpi-name>**
: Definition: <what-it-measures>
: Target: <target-value>
: Frequency: <measurement-frequency>

[...|additional KPIs]

---

## User Personas

### <Persona-Name>

**demographics**
: <age-range>, <role>, <technical-proficiency>

**goals**
: <primary-goals>

**frustrations**
: <current-pain-points>

**behaviors**
: <relevant-behavioral-patterns>

**quote**
: "<representative-quote-capturing-mindset>"

[...|additional personas, or:]
→ See: docs/PRD/personas.md

---

## User Stories and Use Cases

### Epic: <Epic-Name>

⟪📂: {epic-<id>}⟫

**<Story-ID>**: As a <persona>, I want to <action> so that <benefit>

**acceptance-criteria**
: - [ ] <criterion-1>
: - [ ] <criterion-2>
: - [ ] <criterion-3>

**priority**
: <P0|P1|P2|P3>

[...|additional stories, or:]
→ See: docs/PRD/user-stories.md

---

## Functional Requirements

### <Requirement-Category>

⟪📂: {req-<category>}⟫

#### <FR-ID>: <Requirement-Title>

⟪📋 req: <FR-ID> | <priority> | <category>⟫

**description**
: [...|clear statement of what the system must do]

**rationale**
: [...|why this requirement exists]

**acceptance-criteria**
: - [ ] <testable-criterion-1>
: - [ ] <testable-criterion-2>

**dependencies**
: <dependency-list-or-none>

**notes**
: <implementation-notes-or-constraints>

[...|additional requirements]

→ See: docs/PRD/functional-requirements.md

---

## Non-Functional Requirements

### Performance

⟪📋 req: NFR-PERF-001 | P0 | performance⟫

| Metric | Requirement | Measurement |
|:-------|:------------|:------------|
| Response time | <target> | <how-measured> |
| Throughput | <target> | <how-measured> |
| Availability | <target> | <how-measured> |

### Security

⟪📋 req: NFR-SEC-001 | P0 | security⟫

**authentication**
: <authentication-requirements>

**authorization**
: <authorization-model>

**data-protection**
: <encryption-and-privacy-requirements>

### Scalability

⟪📋 req: NFR-SCALE-001 | P1 | scalability⟫

**expected-load**
: <user-count>, <request-volume>, <data-volume>

**growth-projection**
: <expected-growth-rate>

### Accessibility

⟪📋 req: NFR-A11Y-001 | P1 | accessibility⟫

**compliance**
: <WCAG-level-or-other-standard>

**requirements**
: <specific-accessibility-needs>

[...|additional NFR categories]

→ See: docs/PRD/non-functional-requirements.md

---

## Constraints and Assumptions

### Constraints

**technical**
: <technical-constraints-list>

**business**
: <business-constraints-list>

**regulatory**
: <regulatory-constraints-list>

**timeline**
: <timeline-constraints>

### Assumptions

| Assumption | Impact if False | Validation Plan |
|:-----------|:----------------|:----------------|
| <assumption-1> | <impact> | <how-to-validate> |
| [...] |||

---

## Dependencies

### Internal Dependencies

| Dependency | Owner | Status | Impact |
|:-----------|:------|:-------|:-------|
| <system-or-team> | <owner> | <status> | <impact-if-delayed> |
| [...] ||||

### External Dependencies

| Dependency | Provider | SLA | Fallback |
|:-----------|:---------|:----|:---------|
| <service-or-api> | <provider> | <sla-terms> | <fallback-plan> |
| [...] ||||

---

## Risks and Mitigations

⟪⚠️ risk: <primary-risk> | <likelihood> | <impact> | <mitigation>⟫

| Risk | Likelihood | Impact | Mitigation | Owner |
|:-----|:-----------|:-------|:-----------|:------|
| <risk-description> | <H/M/L> | <H/M/L> | <mitigation-strategy> | <owner> |
| [...] |||||

---

## Timeline and Milestones

### Phases

**Phase 1: <Phase-Name>**
: Scope: <what's-included>
: Dependencies: <prerequisites>

**Phase 2: <Phase-Name>**
: Scope: <what's-included>
: Dependencies: <prerequisites>

[...|additional phases]

### Milestones

| Milestone | Description | Success Criteria |
|:----------|:------------|:-----------------|
| <milestone-name> | <what-it-represents> | <how-to-verify> |
| [...] |||

---

## Open Questions

| Question | Impact | Owner | Due |
|:---------|:-------|:------|:-----|
| <question> | <decision-impact> | <who-decides> | <target-date> |
| [...] ||||

---

## Appendix

### Glossary

**<term>**
: <definition>

[...|additional terms]

### References

- <reference-1>
- <reference-2>
- [...]

### Revision History

| Version | Date | Author | Changes |
|:--------|:-----|:-------|:--------|
| <version> | <date> | <author> | <change-summary> |
| [...] ||||
```

---

## Sub-File Specifications

Sub-files are created in `docs/PRD/` when main file sections exceed 50-100 lines.

### personas.md

```format
# User Personas
Detailed persona definitions for <product-name>.

---

## <Persona-Name>

⟪📂: {persona-<id>}⟫

### Demographics

| Attribute | Value |
|:----------|:------|
| Age Range | <age-range> |
| Role | <job-title-or-role> |
| Industry | <industry> |
| Technical Skill | <novice|intermediate|advanced|expert> |
| Device Usage | <primary-devices> |

### Profile

**background**
: [...2-3s|professional and personal context]

**goals**
: - <primary-goal-1>
: - <primary-goal-2>
: - [...]

**frustrations**
: - <pain-point-1>
: - <pain-point-2>
: - [...]

**motivations**
: - <motivation-1>
: - <motivation-2>

### Behavior Patterns

**typical-workflow**
: [...|description of how they currently accomplish tasks]

**tool-usage**
: [...|current tools and services they use]

**decision-factors**
: [...|what influences their choices]

### Scenarios

**scenario-1**
: <context>: <what-they're-trying-to-do>
: <outcome>: <what-success-looks-like>

[...|additional scenarios]

### Representative Quote

> "<quote-that-captures-their-perspective>"

---

[...|repeat for each persona]
```

### user-stories.md

```format
# User Stories
Comprehensive user story catalog for <product-name>.

## Story Map Overview

```diagram
┌─────────────────────────────────────────────────────────────┐
│                     User Journey                             │
├─────────┬─────────┬─────────┬─────────┬─────────┬──────────┤
│ Discover│ Onboard │  Use    │ Manage  │ Share   │ Support  │
├─────────┼─────────┼─────────┼─────────┼─────────┼──────────┤
│ US-001  │ US-010  │ US-020  │ US-030  │ US-040  │ US-050   │
│ US-002  │ US-011  │ US-021  │ US-031  │ US-041  │ US-051   │
│ [...]   │ [...]   │ [...]   │ [...]   │ [...]   │ [...]    │
└─────────┴─────────┴─────────┴─────────┴─────────┴──────────┘
```

---

## Epic: <Epic-Name>

⟪📂: {epic-<id>}⟫

**description**
: [...|epic-level description of the feature area]

**business-value**
: [...|why this epic matters]

**success-metrics**
: [...|how we measure epic success]

---

### <US-ID>: <Story-Title>

⟪📋 req: <US-ID> | <priority> | <epic>⟫

**story**
: As a <persona>, I want to <action> so that <benefit>

**context**
: [...|additional context about when/why this story is relevant]

#### Acceptance Criteria

```gherkin
Given <precondition>
When <action>
Then <expected-result>
And <additional-result>
```

#### Definition of Done

- [ ] <criterion-1>
- [ ] <criterion-2>
- [ ] <criterion-3>
- [ ] Unit tests written and passing
- [ ] Integration tests completed
- [ ] Documentation updated
- [ ] Code reviewed and approved

#### Dependencies

⟪🔗 depends: <dependency-id> | <type> | <blocking-status>⟫

#### Notes

**edge-cases**
: [...|edge cases to consider]

**out-of-scope**
: [...|explicitly excluded scenarios]

---

[...|repeat for each user story]
```

### functional-requirements.md

```format
# Functional Requirements
Detailed functional requirements for <product-name>.

## Requirements Index

| ID | Title | Priority | Status | Category |
|:---|:------|:---------|:-------|:---------|
| FR-001 | <title> | P0 | <status> | <category> |
| [...] |||||

---

## <Category-Name>

⟪📂: {category-<id>}⟫

### FR-<ID>: <Requirement-Title>

⟪📋 req: FR-<ID> | <priority> | <category>⟫

**description**
: [...|complete, unambiguous description of the requirement]

**rationale**
: [...|business or user justification]

**source**
: <user-story-id>, <stakeholder-request>, or <compliance-requirement>

#### Acceptance Criteria

| # | Criterion | Verification Method |
|:--|:----------|:--------------------|
| 1 | <criterion-1> | <test/review/demo> |
| 2 | <criterion-2> | <test/review/demo> |
| [...] |||

#### Business Rules

**rule-1**
: <business-rule-description>
: Validation: <how-to-verify>

[...|additional rules]

#### Data Requirements

| Field | Type | Constraints | Source |
|:------|:-----|:------------|:-------|
| <field-name> | <data-type> | <validation-rules> | <data-source> |
| [...] ||||

#### UI/UX Requirements

**display**
: [...|how information should be presented]

**interaction**
: [...|how users interact with this feature]

**feedback**
: [...|system responses and notifications]

#### Error Handling

| Error Condition | User Message | System Action |
|:----------------|:-------------|:--------------|
| <error-type> | <user-facing-message> | <system-behavior> |
| [...] |||

#### Dependencies

⟪🔗 depends: <FR-ID> | <relationship> | <status>⟫

**requires**
: <list-of-prerequisite-requirements>

**enables**
: <list-of-dependent-requirements>

#### Technical Notes

[...|implementation guidance, constraints, or considerations]

---

[...|repeat for each requirement]
```

### non-functional-requirements.md

```format
# Non-Functional Requirements
Quality attributes and constraints for <product-name>.

## NFR Index

| ID | Category | Priority | Target |
|:---|:---------|:---------|:-------|
| NFR-001 | Performance | P0 | <target> |
| [...] ||||

---

## Performance Requirements

⟪📂: {nfr-performance}⟫

### NFR-PERF-<ID>: <Requirement-Title>

⟪📋 req: NFR-PERF-<ID> | <priority> | performance⟫

**requirement**
: [...|specific, measurable performance requirement]

**metrics**

| Metric | Target | Acceptable | Unacceptable |
|:-------|:-------|:-----------|:-------------|
| <metric> | <ideal> | <minimum> | <threshold> |
| [...] ||||

**measurement**
: Tool: <measurement-tool>
: Frequency: <how-often>
: Environment: <test-environment>

**scenarios**
: Normal load: <definition>
: Peak load: <definition>
: Stress conditions: <definition>

---

## Security Requirements

⟪📂: {nfr-security}⟫

### NFR-SEC-<ID>: <Requirement-Title>

⟪📋 req: NFR-SEC-<ID> | <priority> | security⟫

**requirement**
: [...|specific security requirement]

**compliance**
: <relevant-standards-or-regulations>

**controls**

| Control | Implementation | Verification |
|:--------|:---------------|:-------------|
| <control-type> | <how-implemented> | <how-verified> |
| [...] |||

**threat-model**
: → See: docs/PRD/security/threat-model.md

---

## Scalability Requirements

⟪📂: {nfr-scalability}⟫

### NFR-SCALE-<ID>: <Requirement-Title>

⟪📋 req: NFR-SCALE-<ID> | <priority> | scalability⟫

**capacity-targets**

| Dimension | Current | Year 1 | Year 3 |
|:----------|:--------|:-------|:-------|
| Users | <count> | <count> | <count> |
| Requests/sec | <count> | <count> | <count> |
| Data volume | <size> | <size> | <size> |

**scaling-strategy**
: Horizontal: <approach>
: Vertical: <approach>
: Data: <approach>

---

## Reliability Requirements

⟪📂: {nfr-reliability}⟫

### NFR-REL-<ID>: <Requirement-Title>

⟪📋 req: NFR-REL-<ID> | <priority> | reliability⟫

**availability**
: Target: <percentage>
: Measurement: <calculation-method>
: Exclusions: <planned-maintenance-windows>

**recovery**
: RTO: <recovery-time-objective>
: RPO: <recovery-point-objective>

**fault-tolerance**
: [...|fault tolerance requirements]

---

## Accessibility Requirements

⟪📂: {nfr-accessibility}⟫

### NFR-A11Y-<ID>: <Requirement-Title>

⟪📋 req: NFR-A11Y-<ID> | <priority> | accessibility⟫

**compliance**
: Standard: <WCAG-2.1-AA|Section-508|etc>
: Scope: <what's-covered>

**requirements**

| Category | Requirement | Success Criterion |
|:---------|:------------|:------------------|
| Visual | <requirement> | <WCAG-criterion> |
| Motor | <requirement> | <WCAG-criterion> |
| Cognitive | <requirement> | <WCAG-criterion> |
| [...] |||

**testing**
: Automated: <tools>
: Manual: <process>
: User testing: <approach>

---

[...|additional NFR categories as needed]
```

---

## Sub-File Creation Guidelines

### When to Create Sub-Files

**threshold**
: Create sub-file when main file section exceeds 50-100 lines

**indicators**
: - More than 10 user stories in an epic
: - More than 5 detailed requirements per category
: - Complex persona definitions with multiple scenarios
: - Extensive acceptance criteria per requirement

### Directory Structure

```diagram
project-root/
├── PRD.md                       # Main file (200-400 lines max)
└── docs/
    └── PRD/
        ├── personas.md          # Detailed persona definitions
        ├── user-stories.md      # Complete story catalog
        ├── functional-requirements.md    # FR details
        ├── non-functional-requirements.md # NFR details
        ├── wireframes/          # UI mockups
        ├── diagrams/            # System diagrams
        └── research/            # User research, competitive analysis
```

### Reference Syntax

In main file, replace detailed section with:
```example
### User Personas
[...brief 2-3 line overview of key personas]

→ See: docs/PRD/personas.md
```

---

## Priority Definitions

### Priority Levels

**P0 - Critical**
: Must have for launch; product cannot ship without this
: No workarounds exist

**P1 - High**
: Should have for launch; significant value reduction without this
: Workarounds exist but are painful

**P2 - Medium**
: Nice to have for launch; enhances product value
: Can be deferred to subsequent release

**P3 - Low**
: Future consideration; valuable but not urgent
: Long-term roadmap item

### Priority Matrix

```diagram
            High Impact
                │
    P1          │          P0
    Should Have │          Must Have
                │
  ──────────────┼──────────────
                │
    P3          │          P2
    Future      │          Nice to Have
                │
            Low Impact
        Low Effort ──────── High Effort
```

---

## Requirement Quality Checklist

### SMART Requirements

- [ ] **Specific**: Single, clear interpretation
- [ ] **Measurable**: Quantifiable success criteria
- [ ] **Achievable**: Technically and resource-feasible
- [ ] **Relevant**: Aligned with product goals
- [ ] **Traceable**: Links to business objective or user need

### Completeness Checklist

- [ ] All user personas defined
- [ ] User stories cover all persona goals
- [ ] Functional requirements traced to stories
- [ ] NFRs defined for performance, security, scalability, accessibility
- [ ] Dependencies identified and documented
- [ ] Risks assessed with mitigations
- [ ] Success metrics are measurable
- [ ] Open questions have owners and due dates
- [ ] Glossary defines domain terms

---

## Example: Filled Main File

```example
# PRD: TaskFlow
Product Requirements Document for TaskFlow, an async collaboration platform for remote teams.

⟪📦 product-overview: TaskFlow | remote teams | streamlined async collaboration⟫

**version**
: 1.2

**status**
: approved

**owner**
: Sarah Chen, Product Lead

**last-updated**
: 2024-11-15

**stakeholders**
: Engineering (Mike T.), Design (Lisa W.), Marketing (James R.), Customer Success (Anna K.)

---

## Executive Summary

TaskFlow is a collaboration platform designed specifically for distributed teams struggling with asynchronous communication. The product addresses the growing pain of context switching and information fragmentation that plagues remote work.

Our solution consolidates task management, team communication, and knowledge sharing into a unified experience that respects async-first workflows. By reducing daily context switches by 60%, we project a 25% improvement in team productivity within 90 days of adoption.

---

## Problem Statement

⟪🎯 problem: context switching kills productivity | 2.1h/day lost | knowledge workers⟫

### Current State
Remote teams use an average of 6.3 different tools daily, leading to:
- Constant context switching between applications
- Information scattered across platforms
- Missed messages and delayed responses
- Meeting overload to compensate for async failures

### Desired State
A unified workspace where teams can:
- Manage tasks, communicate, and share knowledge in one place
- Work asynchronously without fear of missing critical updates
- Reduce meetings by 40% through effective async communication
- Maintain full context without switching applications

### Gap Analysis
| Aspect | Current | Desired | Gap |
|:-------|:--------|:--------|:----|
| Daily tool switches | 47 avg | <15 | 32 switches |
| Time lost to context switch | 2.1h/day | <0.5h/day | 1.6h/day |
| Async communication success | 34% | 80% | 46% |
| Meeting hours/week | 12.3h | <7h | 5.3h |

---

## Goals and Objectives

### Business Objectives
1. Achieve 10,000 paying teams within 18 months
2. Reach $2M ARR by end of Year 1
3. Maintain NPS score above 50

### User Objectives
1. Reduce daily context switches by 60%
2. Complete tasks 25% faster through better collaboration
3. Decrease time-to-response for async requests by 50%

### Non-Goals
🚫 Real-time video conferencing (integrate with existing solutions)
🚫 Enterprise SSO in initial release (Phase 2)
🚫 Mobile app (web-responsive first, native app in Phase 3)

---

## Success Metrics

⟪📊 success: task completion rate | +25% | analytics tracking⟫

| Metric | Baseline | Target | Timeframe | Measurement |
|:-------|:---------|:-------|:----------|:------------|
| Daily active users | - | 70% of seats | 30 days post-signup | Analytics |
| Task completion rate | baseline | +25% | 90 days | In-app tracking |
| Context switches/day | 47 | <15 | 90 days | User survey |
| NPS | - | >50 | Quarterly | Survey |

---

## User Personas

### Alex - Team Lead

**demographics**
: 32-40, Engineering Manager, Advanced technical skill

**goals**
: Keep team aligned, track progress, reduce status meetings

**frustrations**
: Information scattered, chasing updates, too many meetings

**quote**
: "I spend more time asking for updates than actually leading."

### Morgan - Individual Contributor

**demographics**
: 25-35, Software Developer, Advanced technical skill

**goals**
: Focus time, clear task ownership, async collaboration

**frustrations**
: Constant interruptions, unclear priorities, notification overload

**quote**
: "Every ping destroys 20 minutes of deep work."

→ See: docs/PRD/personas.md

---

## Functional Requirements

### Core Task Management

⟪📂: {req-task-management}⟫

#### FR-001: Task Creation

⟪📋 req: FR-001 | P0 | core-functionality⟫

**description**
: Users can create tasks with title, description, assignee, due date, and priority

**acceptance-criteria**
: - [ ] Tasks support rich text descriptions with markdown
: - [ ] Tasks can be assigned to one or more team members
: - [ ] Due dates trigger automated reminders
: - [ ] Priority levels: P0-P3 with visual indicators

#### FR-002: Task Dependencies

⟪📋 req: FR-002 | P1 | core-functionality⟫

**description**
: Tasks can have blocking and non-blocking dependencies on other tasks

**acceptance-criteria**
: - [ ] Dependency graph visualizes task relationships
: - [ ] Blocked tasks show clear status indicator
: - [ ] Notifications sent when blocking tasks complete

→ See: docs/PRD/functional-requirements.md

---

## Non-Functional Requirements

### Performance

⟪📋 req: NFR-PERF-001 | P0 | performance⟫

| Metric | Requirement | Measurement |
|:-------|:------------|:------------|
| Page load | <2s on 3G | Lighthouse |
| API response | <200ms p95 | APM |
| Search results | <500ms | End-to-end |

### Security

⟪📋 req: NFR-SEC-001 | P0 | security⟫

**authentication**
: Email/password with MFA option; OAuth (Google, Microsoft)

**authorization**
: Role-based access control (Admin, Member, Guest)

**data-protection**
: AES-256 encryption at rest; TLS 1.3 in transit

→ See: docs/PRD/non-functional-requirements.md

---

## Risks and Mitigations

⟪⚠️ risk: market competition | high | high | differentiate on async-first UX⟫

| Risk | Likelihood | Impact | Mitigation | Owner |
|:-----|:-----------|:-------|:-----------|:------|
| Feature parity gap | H | H | Focus on async-first differentiators | Product |
| Scalability under growth | M | H | Cloud-native architecture from start | Engineering |
| User adoption resistance | M | M | Onboarding wizard, migration tools | Product |

---

## Open Questions

| Question | Impact | Owner | Due |
|:---------|:-------|:------|:-----|
| Integration priority order? | Roadmap | Product | 2024-11-30 |
| Freemium vs. trial model? | Revenue | Marketing | 2024-12-15 |

---

## Appendix

### Glossary

**async-first**
: Design philosophy prioritizing asynchronous communication over synchronous

**context switch**
: Mental cost of shifting attention between different tasks or tools

### Revision History

| Version | Date | Author | Changes |
|:--------|:-----|:-------|:--------|
| 1.0 | 2024-10-01 | S. Chen | Initial draft |
| 1.1 | 2024-10-15 | S. Chen | Added NFRs, risk section |
| 1.2 | 2024-11-15 | S. Chen | Approved for development |
```

---

## Agent Integration

### npl-gopher-scout Usage

When analyzing existing PRDs, gopher-scout should:

1. Identify completeness gaps against this specification
2. Extract requirement traceability (story → requirement → acceptance criteria)
3. Flag ambiguous or untestable requirements
4. Surface undocumented dependencies
5. Assess risk coverage

### npl-technical-writer Usage

When generating PRDs, npl-technical-writer should:

1. Use main file template for initial generation
2. Apply SMART criteria to all requirements
3. Ensure bidirectional traceability
4. Generate sub-files when sections exceed thresholds
5. Maintain consistent priority and status terminology

### npl-project-coordinator Usage

When planning from PRDs, npl-project-coordinator should:

1. Extract dependency graph for sequencing
2. Map requirements to implementation tasks
3. Identify resource requirements from NFRs
4. Generate milestone definitions from phases
5. Track open questions as planning blockers

---

## See Also

Load additional NPL references as needed:

```bash
# Directive syntax reference
npl-load c "directive" --skip {@npl.def.loaded}

# Core NPL syntax elements
npl-load c "syntax" --skip {@npl.def.loaded}

# Output formatting patterns
npl-load c "formatting" --skip {@npl.def.loaded}

# Reasoning pumps for analysis
npl-load c "pumps.critique,pumps.rubric" --skip {@npl.def.loaded}
```

### Related Specifications
- `project-arch-spec.md` - Architecture documentation spec
- `project-layout-spec.md` - Layout documentation spec

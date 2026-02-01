---
name: architectural-assumptions
description: Foundational assumptions underlying the TDD agent orchestration system
model: sonnet
color: yellow
---

# Architectural Assumptions

## Overview

This document catalogs the foundational assumptions that guided the design of the TDD agent orchestration system. Each assumption represents a belief about system behavior, constraints, or requirements that influenced architectural decisions.

**Purpose:** Enable reasoned evolution of the architecture by making implicit design premises explicit and interrogable.

**Related:** [agent-orchestration.md](agent-orchestration.md)

---

## Workflow Assumptions

### WF-1: Sequential Phase Progression
**Assumption:** Features naturally progress through distinct phases (Discovery → Specification → Testing → Implementation) with minimal backtracking under normal operation.

**Rationale:** Each phase produces artifacts consumed by subsequent phases, creating a natural dependency chain.

**Impact:** Agents are specialized for specific phases rather than being general-purpose.

**Risk if invalid:** If requirements frequently change mid-implementation, excessive phase transitions could reduce efficiency.

---

### WF-2: Autonomous Agent Operation
**Assumption:** Each agent can operate autonomously within its phase without constant human intervention.

**Rationale:** Reduces cognitive load on developers and enables parallel work across phases.

**Impact:** Agents must have sufficient context and decision-making capability within their domain.

**Risk if invalid:** Frequent human intervention would negate efficiency gains from orchestration.

---

### WF-3: Controller as Orchestrator, Not Implementer
**Assumption:** The controller coordinates agents but does not perform domain work (writing code, tests, or specs).

**Rationale:** Separation of concerns—orchestration logic separate from domain expertise.

**Impact:** Controller focuses on state management, routing, and phase transitions.

**Risk if invalid:** If agents cannot handle edge cases, controller scope creep could occur.

---

## Testing Assumptions

### TS-1: Tests Before Implementation
**Assumption:** Writing tests before implementation code improves design quality and reduces defects.

**Rationale:** TDD philosophy—tests define contracts, implementation satisfies contracts.

**Impact:** `tdd-tester` must run before `tdd-coder` in the workflow.

**Risk if invalid:** If tests are brittle or poorly specified, they become impediments rather than aids.

---

### TS-2: Mise Tasks Provide Sufficient Feedback
**Assumption:** `mise run test-status` and `mise run test-errors` provide adequate information for autonomous debugging.

**Rationale:** Standardized test output enables programmatic interpretation of failures.

**Impact:** `tdd-coder` and `tdd-debugger` rely on these commands for test feedback loops.

**Risk if invalid:** Ambiguous test output could cause misdiagnosis and wasted debugging effort.

---

### TS-3: Test Failures Indicate One of Three Issues
**Assumption:** Test failures stem from: (1) implementation bugs, (2) incorrect tests, or (3) unclear PRD.

**Rationale:** Covers the logical space of failure causes in a spec-driven workflow.

**Impact:** `tdd-debugger` routes feedback to `tdd-coder`, `tdd-tester`, or `prd-editor` based on diagnosis.

**Risk if invalid:** If failures stem from environmental issues (dependencies, configs), diagnosis may be incomplete.

---

## State Management Assumptions

### SM-1: PRD Hash Ensures Consistency
**Assumption:** A content hash of the PRD can detect specification drift during implementation.

**Rationale:** Prevents agents from working against outdated specs without explicit version reconciliation.

**Impact:** PRD documents include hash metadata; agents verify hash before using PRD content.

**Risk if invalid:** If PRDs are modified externally without hash updates, agents work from stale specs.

---

### SM-2: Agent State Persists Within Sessions
**Assumption:** Agents maintain context (current PRD, test suite, implementation progress) across commands within a session.

**Rationale:** Eliminates repetitive context re-establishment for each command.

**Impact:** Agents store session state; sessions end explicitly via controller or completion confirmation.

**Risk if invalid:** If agents crash mid-session, state loss could require manual recovery.

---

### SM-3: Artifacts Are Single Source of Truth
**Assumption:** Files (personas, PRDs, tests, source code) are the authoritative record of system state.

**Rationale:** File-based artifacts enable version control integration and external inspection.

**Impact:** Agents read from and write to files rather than maintaining internal state databases.

**Risk if invalid:** If file system operations fail or are non-atomic, state inconsistencies could arise.

---

## Communication Protocol Assumptions

### CP-1: Structured Message Format Suffices
**Assumption:** A simple `{command, payload}` request and `{status, ...fields, message}` response format meets all inter-agent communication needs.

**Rationale:** Simplicity reduces protocol overhead and debugging complexity.

**Impact:** All agent commands conform to this schema.

**Risk if invalid:** If complex negotiations or multi-turn dialogs are needed, protocol may require extension.

---

### CP-2: Four Status Values Cover All States
**Assumption:** Agent responses can be categorized as `ok`, `blocked`, `needs_clarification`, or `complete`.

**Rationale:** These states map to the controller's decision points: proceed, intervene, query user, or finalize.

**Impact:** Status values drive controller routing logic.

**Risk if invalid:** If nuanced states emerge (e.g., "partially complete"), status values may need refinement.

---

### CP-3: Agents Report Blocking, Don't Resolve It
**Assumption:** When an agent encounters an impediment outside its domain, it reports `blocked` rather than attempting cross-domain fixes.

**Rationale:** Maintains separation of concerns and prevents agents from making uninformed changes.

**Impact:** `tdd-coder` reports blocking when tests are wrong; doesn't modify tests directly.

**Risk if invalid:** If blocking is over-reported, controller overhead increases unnecessarily.

---

## Integration Assumptions

### IN-1: Mise Provides Test Orchestration
**Assumption:** Mise tasks (`test-status`, `test-errors`) are the standard interface for test execution across all project types.

**Rationale:** Standardized task names enable agent portability across projects using mise.

**Impact:** Agents invoke mise commands rather than project-specific test runners.

**Risk if invalid:** Projects without mise or with non-standard task names require adapter logic.

---

### IN-2: Git Tracks All Artifacts
**Assumption:** All generated artifacts (personas, PRDs, tests, source) are committed to version control.

**Rationale:** Enables rollback, branching, and collaboration on agent-generated work.

**Impact:** Workflow documentation emphasizes file-based artifacts over ephemeral state.

**Risk if invalid:** If artifacts are too large or transient, git may not be appropriate storage.

---

### IN-3: Directory Structure Is Predictable
**Assumption:** Standard locations exist for personas (`docs/personas/`), PRDs (`.prd/`), tests (`tests/`), and source (`src/`).

**Rationale:** Enables agents to locate artifacts without configuration.

**Impact:** Agents use convention-based paths for reading and writing files.

**Risk if invalid:** Non-standard project layouts require configuration or path resolution logic.

---

## Agent-Specific Assumptions

### AG-1: idea-to-spec Can Infer Personas
**Assumption:** Natural language feature descriptions contain enough context to identify or create relevant user personas.

**Rationale:** User needs imply user types; agent extracts this from feature pitch.

**Impact:** `idea-to-spec` can operate without pre-existing persona catalogs.

**Risk if invalid:** If feature pitches lack user context, persona quality may degrade.

---

### AG-2: prd-editor Can Structure User Stories
**Assumption:** User stories provide sufficient detail to create comprehensive PRDs without additional input.

**Rationale:** Well-formed user stories contain acceptance criteria and context.

**Impact:** `prd-editor` receives user stories and produces PRDs autonomously.

**Risk if invalid:** Vague user stories produce incomplete PRDs, requiring iteration.

---

### AG-3: tdd-tester Can Infer Test Cases from PRD
**Assumption:** PRD interface specifications and requirements are concrete enough to derive test cases.

**Rationale:** PRDs include function signatures, expected behaviors, and edge cases.

**Impact:** `tdd-tester` generates comprehensive test suites from PRD alone.

**Risk if invalid:** Ambiguous PRDs lead to incomplete or incorrect test coverage.

---

### AG-4: tdd-coder Can Implement Without Human Input
**Assumption:** Given a PRD and test suite, code implementation is deterministic enough for autonomous completion.

**Rationale:** Tests define success criteria; PRD provides context; implementation follows mechanically.

**Impact:** `tdd-coder` works autonomously using test feedback loops.

**Risk if invalid:** Architectural decisions or ambiguous requirements may require human judgment.

---

### AG-5: tdd-debugger Can Diagnose Root Causes
**Assumption:** Test failure messages contain sufficient information to distinguish implementation bugs from test issues from PRD ambiguities.

**Rationale:** Test frameworks provide stack traces, assertion details, and error messages.

**Impact:** `tdd-debugger` routes issues to appropriate agents based on diagnosis.

**Risk if invalid:** Misleading error messages could cause incorrect routing.

---

## Lifecycle Assumptions

### LC-1: Sessions Have Explicit Lifecycles
**Assumption:** Agent sessions begin with initialization, proceed through commands, and end with explicit completion or termination.

**Rationale:** Explicit lifecycle prevents resource leaks and enables clean state transitions.

**Impact:** Controller manages session creation and destruction.

**Risk if invalid:** If sessions leak or persist unexpectedly, resource exhaustion could occur.

---

### LC-2: Completion Requires Confirmation
**Assumption:** Agent-reported `complete` status requires controller confirmation before finalization.

**Rationale:** Prevents premature archival; allows human review before marking work done.

**Impact:** `tdd-coder` waits for `complete(confirmed: true)` before finalizing.

**Risk if invalid:** If auto-confirmation is needed, workflow requires modification.

---

### LC-3: PRDs Are Archived, Not Deleted
**Assumption:** Completed PRDs move to `.prd/archive/` rather than being removed.

**Rationale:** Preserves implementation history for future reference.

**Impact:** Archive directory grows over time; cleanup may be needed eventually.

**Risk if invalid:** If archive grows unbounded, disk space or repository size becomes an issue.

---

## Constraint Assumptions

### CN-1: Single Feature at a Time
**Assumption:** The workflow handles one feature implementation end-to-end before starting another.

**Rationale:** Simplifies state management; avoids context-switching overhead.

**Impact:** Controller processes features sequentially rather than in parallel.

**Risk if invalid:** If parallel feature development is needed, concurrency control is required.

---

### CN-2: Agents Are Stateless Between Sessions
**Assumption:** Agents do not retain memory across different feature implementations.

**Rationale:** Prevents cross-contamination of contexts; ensures reproducibility.

**Impact:** Each `init` command starts fresh; no persistent agent memory.

**Risk if invalid:** If learning or adaptation across features is desired, architecture needs revision.

---

### CN-3: Human Intervention Is Exceptional
**Assumption:** The workflow operates autonomously under normal conditions; human input resolves exceptional cases only.

**Rationale:** Maximizes automation benefits; reserves human attention for high-value decisions.

**Impact:** Agents report `needs_clarification` only when autonomous resolution is impossible.

**Risk if invalid:** Over-automation could produce suboptimal results without human oversight.

---

## Meta-Assumptions

### MA-1: Assumptions Can Be Challenged
**Assumption:** This document is a living artifact; assumptions should be validated against real-world usage and updated accordingly.

**Rationale:** Initial assumptions may prove incorrect; explicit tracking enables principled revision.

**Impact:** Assumption validation is part of architecture review process.

**Risk if invalid:** Stale assumptions misguide future development.

---

### MA-2: Explicit Is Better Than Implicit
**Assumption:** Documenting assumptions, even obvious ones, prevents future misinterpretation.

**Rationale:** What is obvious to the original designer may be opaque to future maintainers.

**Impact:** This document exists and is maintained alongside architecture docs.

**Risk if invalid:** Over-documentation could obscure critical assumptions in noise.

---

## Tracking Conventions

### Status Indicators

- ✅ **Validated** — Assumption confirmed through implementation or testing
- ⚠️ **At Risk** — Evidence suggests assumption may not hold in all cases
- ❌ **Invalidated** — Assumption proven incorrect; architecture needs revision
- 🔍 **Under Review** — Assumption being actively investigated

### Review Cadence

- **Per-implementation:** After each feature completion, review assumptions related to observed issues
- **Quarterly:** Systematic review of all assumptions against accumulated evidence
- **On-demand:** When architectural changes are proposed, identify affected assumptions

---

## Change Log

| Date | Assumption | Change | Rationale |
|------|-----------|---------|-----------|
| 2026-02-02 | Initial | Document created | Baseline assumption catalog for TDD orchestration system |

---

*End of Assumptions Document*

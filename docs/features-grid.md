# NPL Features Implementation Grid

**Last Updated**: 2026-02-02
**Source**: Legacy documentation extracted from `.tmp/docs/`
**Status**: Identifies implementation gaps and priorities

---

## Implementation Status Legend

| Symbol | Meaning | Notes |
|--------|---------|-------|
| ✅ | Implemented and tested | Feature complete and working |
| 🚧 | Partially implemented | Infrastructure exists, feature incomplete |
| 📝 | Documented only (legacy) | Feature designed, no implementation |
| ❌ | Not started | Not implemented |
| ⚠️ | At risk | Blocking other features |

---

## Feature Matrix

### MCP Tools (Artifact Management)

| Feature | Status | User Stories | Docs | Gap | Priority |
|---------|--------|--------------|------|-----|----------|
| Create versioned artifact | 📝 | US-008, US-078 | PRD-009 | ArtifactManager | Critical |
| Version artifact (new revision) | 📝 | US-009, US-078 | PRD-009 | RevisionStore | Critical |
| Create review on artifact | 📝 | US-010, US-023 | PRD-009 | ReviewManager | High |
| Add inline review comment | 📝 | US-010 | PRD-009 | InlineComment model | High |
| Complete review with summary | 📝 | US-023 | PRD-009 | ReviewSummary | Medium |
| Annotate screenshot with overlay | 📝 | US-011 | PRD-009 | Screenshot overlay | High |

**Gap Analysis**: 6 tools documented, 0 implemented - 100% gap
**Blocking Stories**: US-008, US-009, US-010, US-023
**Next Action**: Create PRD-009 for MCP tools with implementation specs

---

### MCP Tools (Chat Rooms)

| Feature | Status | User Stories | Docs | Gap | Priority |
|---------|--------|--------------|------|-----|----------|
| Create chat room | 📝 | US-007, US-069 | PRD-009 | ChatManager | Critical |
| Send message to room | 📝 | US-006, US-027 | PRD-009 | Message store | Critical |
| React to message | 📝 | US-027 | PRD-009 | Reaction system | Low |
| Share artifact in chat | 📝 | US-004 | PRD-009 | Artifact link | High |
| Create todo from chat | 📝 | US-028 | PRD-009 | Todo integration | Low |
| Receive notifications | 📝 | US-022, US-053 | PRD-009 | Notification system | Medium |
| Role-based access for rooms | 📝 | US-069 | PRD-009 | RBAC for chat | High |

**Gap Analysis**: 7 tools documented, 0 implemented - 100% gap
**Blocking Stories**: US-007, US-006, US-004, US-027
**Next Action**: Implement ChatManager as part of MCP tools phase

---

### MCP Tools (Task Queues)

| Feature | Status | User Stories | Docs | Gap | Priority |
|---------|--------|--------------|------|-----|----------|
| Create task | 📝 | US-016 | PRD-009 | TaskManager | Critical |
| Pick up task from queue | 📝 | US-014 | PRD-009 | Queue system | Critical |
| Update task status | 📝 | US-018 | PRD-009 | Status tracking | High |
| Assign task to agent | 📝 | US-032 | PRD-009 | Agent assignment | High |
| Link artifact to task | 📝 | US-017 | PRD-009 | Artifact-task linking | Medium |
| Ask question on task | 📝 | US-026 | PRD-009 | Embedded chat | Medium |
| Assign task complexity | 📝 | US-030 | PRD-009 | Complexity tagging | Low |

**Gap Analysis**: 7 tools documented, 0 implemented - 100% gap
**Blocking Stories**: US-016, US-014, US-018, US-032
**Next Action**: Define TaskManager schema and queue operations

---

### MCP Tools (Browser Automation)

| Feature | Status | User Stories | Docs | Gap | Priority |
|---------|--------|--------------|------|-----|----------|
| Navigate to URL | 📝 | US-021 | PRD-009 | BrowserManager | High |
| Capture screenshot | 📝 | US-012, US-013 | PRD-009 | Screenshot capture | High |
| Fill form and submit | 📝 | US-019, US-020 | PRD-009 | Form automation | Medium |
| Compare screenshots | 📝 | US-013 | PRD-009 | Visual regression | Medium |
| Manage browser session | 📝 | US-024 | PRD-009 | Session state | Medium |
| Inject scripts/styles | 📝 | US-029 | PRD-009 | Script injection | Low |
| Timeout & retry handling | 📝 | US-052 | PRD-009 | Error resilience | High |

**Gap Analysis**: 7 tools documented, 0 implemented - 100% gap
**Blocking Stories**: US-021, US-012, US-019, US-052
**Next Action**: Define BrowserManager and headless browser integration

---

### Agent System (Definitions)

| Feature | Status | Documented | Implemented | Gap | Priority |
|---------|--------|------------|-------------|-----|----------|
| Core Agents (16) | 📝 | 16 | 0 | Agent loader | High |
| Infrastructure Agents (3) | 📝 | 3 | 0 | Task runner | Medium |
| Project Management Agents (4) | 📝 | 4 | 0 | Orchestrator | High |
| QA Agents (4) | 📝 | 4 | 0 | Test runner | Medium |
| Specialized Agents (18+) | 📝 | 18+ | 0 | Domain loaders | Medium |

**Gap Analysis**: 45+ agents documented, 0 implemented - 100% gap
**Next Action**: Create PRD-010 for agent ecosystem with loader system
**Categories**: Authors, Researchers, Developers, QA, Infrastructure, Project Managers, Domain Specialists

---

### NPL Syntax Elements

| Category | Elements | Status | Documented | Implemented | Notes |
|----------|----------|--------|------------|-------------|-------|
| Agent Directives | ~30 | 📝 | 30 | 0 | @agent-name, @role, @context |
| Prefixes | ~20 | 📝 | 20 | 0 | Agent execution prefixes |
| Pumps | ~15 | 📝 | 15 | 0 | Variable injection {{ var }} |
| Fences | ~40 | 📝 | 40 | 0 | Code block markers with metadata |
| Boundary Markers | ~8 | 📝 | 8 | 0 | Unicode corners (⌜⌝⌞⌟) |
| Special Sections | ~22 | 📝 | 22 | 0 | Worklog, instructions, context |
| Other Elements | ~20 | 📝 | 20 | 0 | Miscellaneous syntax |

**Gap Analysis**: 155 elements documented, 0 implemented - 100% gap
**Next Action**: Create PRD-012 for NPL syntax parser with regex library
**Notes**: Comprehensive syntax reference for prompt engineering

---

### CLI Utilities (Scripts)

| Script | Status | Purpose | User Stories | Docs | Gap | Priority |
|--------|--------|---------|--------------|------|-----|----------|
| npl-load | 📝 | Resource loader | US-001, US-002, US-025 | PRD-013 | Hierarchical resolver | Critical |
| npl-persona | 📝 | Persona manager | US-047 | PRD-013 | Persona CLI | High |
| npl-session | 📝 | Session reader | US-031, US-033 | PRD-013 | Worklog reader | High |
| dump-files | 📝 | File explorer | US-025 | PRD-013 | Directory tree | Medium |
| git-tree | 📝 | Git explorer | US-025 | PRD-013 | Git history | Medium |
| npl-syntax | 📝 | Syntax validator | US-080 | PRD-013 | Parser validator | Medium |
| npl-check | 📝 | Health check | (new) | PRD-013 | Diagnostics | Low |

**Gap Analysis**: 7 scripts documented, 0 implemented - 100% gap
**Blocking Stories**: US-001, US-002, US-025, US-047
**Next Action**: Implement npl-load as priority (blocks Core NPL use)

---

### Multi-Agent Orchestration

| Pattern | Status | User Stories | Docs | Implementation | Priority |
|---------|--------|--------------|------|-----------------|----------|
| Consensus-driven | 📝 | US-058, US-065 | PRD-011 | Voting + synthesis | High |
| Pipeline with gates | 📝 | US-059, US-064 | PRD-011 | Stage execution | High |
| Hierarchical decomposition | 📝 | US-032 | PRD-011 | Task breakdown | High |
| Iterative refinement | 📝 | US-036 | PRD-011 | Draft-review loops | Medium |
| Multi-perspective synthesis | 📝 | US-060, US-063 | PRD-011 | Parallel analysis | High |

**Gap Analysis**: 5 patterns documented, 0 implemented - 100% gap
**Blocking Stories**: US-058, US-059, US-064
**Next Action**: Create PRD-011 for orchestration framework
**Notes**: Core to multi-agent capability

---

### Database & Storage

| Feature | Status | Scope | Docs | Gap | Priority |
|---------|--------|-------|------|-----|----------|
| Artifact schema | 📝 | Store versions, content, metadata | PRD-014 | Schema design | High |
| Chat room schema | 📝 | Event-sourced messages | PRD-014 | Event model | High |
| Task schema | 📝 | Queue, assignment, status | PRD-014 | Queue design | High |
| Review schema | 📝 | Inline comments, summaries | PRD-014 | Comment model | Medium |
| Schema migrations | 📝 | Version tracking | PRD-014 | Migration system | High |
| Backup/restore | 📝 | Database lifecycle | PRD-014 | Backup tooling | High |
| Row-level security | 📝 | Multi-user access | PRD-014 | RLS implementation | High |

**Gap Analysis**: 7 database features documented, 0 implemented - 100% gap
**Next Action**: Define schema and migration strategy

---

### Security & Access Control

| Feature | Status | Scope | Docs | Gap | Priority |
|---------|--------|-------|------|-----|----------|
| Artifact access control | 📝 | RBAC for artifacts | PRD-015 | Policy engine | Critical |
| Chat room role-based access | 📝 | Room membership roles | PRD-015 | Role mapper | High |
| Audit logging | 📝 | Sensitive operations | PRD-015 | Audit schema | Critical |
| Secret detection | 📝 | Prevent secret leakage | PRD-015 | Secret patterns | Critical |
| Persona permission scopes | 📝 | Per-agent permissions | PRD-015 | Scope enforcement | High |
| Multi-user SQLite access | 📝 | Concurrent writes | PRD-015 | Transaction handling | Critical |
| API key vault | 📝 | Credential storage | PRD-015 | Encryption layer | High |
| Secret knowledge bases | 📝 | Encrypted persona data | PRD-015 | Encryption | Medium |
| Access violation dashboard | 📝 | Security monitoring | PRD-015 | Monitoring | Medium |

**Gap Analysis**: 9 security features documented, 0 implemented - 100% gap
**Next Action**: Create PRD-015 for security framework

---

### Error Recovery & Observability

| Feature | Status | Scope | Docs | Gap | Priority |
|---------|--------|-------|------|-----|----------|
| Structured error logging | 📝 | JSON error records | PRD-016 | Log schema | Critical |
| Worklog error propagation | 📝 | Cross-agent errors | PRD-016 | Propagation rules | High |
| Browser timeout & retry | 📝 | Resilience | PRD-016 | Retry logic | High |
| Exception alerting | 📝 | Long-running notifications | PRD-016 | Alert system | Medium |
| Test error capture | 📝 | Test failure details | PRD-016 | Test harness | High |
| Database migration recovery | 📝 | Schema rollback | PRD-016 | Rollback logic | Critical |
| Token usage tracking | 📝 | Budget monitoring | PRD-017 | Usage metrics | Medium |
| Agent performance metrics | 📝 | Performance dashboard | PRD-017 | Metrics collection | High |
| Debugging session replay | 📝 | Agent history replay | PRD-017 | Replay system | Low |

**Gap Analysis**: 9 observability/recovery features documented, 0 implemented - 100% gap
**Next Action**: Create PRD-016 and PRD-017

---

## Phase Summary

### Phase 1: Foundation
**Status**: 🚧 In Progress (Foundation infrastructure laid)
**Features**: 4/4 (F-001 through F-004)
**Completion**: 0% (23 MCP tools designed, 2 implemented)

| Category | Status | Gap |
|----------|--------|-----|
| Artifact Management | 📝 | 6/6 tools (100%) |
| Chat Rooms | 📝 | 7/7 tools (100%) |
| Task Queues | 📝 | 7/7 tools (100%) |
| Browser Automation | 📝 | 7/7 tools (100%) |

**Critical Path**: Create MCP tools infrastructure (ArtifactManager, ChatManager, TaskManager, BrowserManager)

---

### Phase 2: Intelligence
**Status**: 📝 Planned
**Features**: 4/4 (F-005 through F-008)
**Completion**: 0%

| Category | Status | Gap |
|----------|--------|-----|
| Agent Definitions | 📝 | 45+ agents (100%) |
| NPL Parser | 📝 | 155 elements (100%) |
| CLI Utilities | 📝 | 7 scripts (100%) |
| Orchestration | 📝 | 5 patterns (100%) |

**Critical Path**: Agent loader + NPL parser (blocks most Phase 2 work)

---

### Phase 3: Collaboration
**Status**: 📝 Planned
**Features**: 4/4 (F-009 through F-012)
**Completion**: 0%

| Category | Status | Gap |
|----------|--------|-----|
| Session Management | 📝 | Worklog tracking |
| Multi-Perspective Review | 📝 | Consensus synthesis |
| Pair Programming | 📝 | Shared context |
| Database Management | 📝 | Migration system |

**Critical Path**: Multi-agent orchestration + database schema

---

### Phase 4: Enterprise
**Status**: 📝 Future
**Features**: 4/4 (F-013 through F-016)
**Completion**: 0%

| Category | Status | Gap |
|----------|--------|-----|
| Security & Access | ❌ | RBAC + encryption |
| Error Recovery | ❌ | Error handling + resilience |
| Observability | ❌ | Metrics + dashboards |
| Consensus Protocols | ❌ | Negotiation engine |

**Critical Path**: Not yet prioritized

---

## Critical Gaps & Blocking Dependencies

### Tier 1: Critical Blocking Issues (MUST FIX FIRST)

#### Gap 1.1: MCP Tool Suite - 21/23 tools missing
- **Documented**: 23 tools in `.tmp/docs/PROJECT-ARCH.brief.md`
- **Implemented**: 2 tools (hello-world only)
- **Missing**: 21 tools (91% gap)
- **Impact**: Blocks US-008 through US-030 (23 user stories)
- **Action Required**:
  1. Create PRD-009: MCP Tools Implementation
  2. Define ArtifactManager, ChatManager, TaskManager, BrowserManager classes
  3. Create SQLite schemas for artifact, chat, task storage
  4. Implement all 23 tools
- **Estimated Scope**: 8-12 weeks
- **Next Story**: Create US-078-083 new stories for remaining tools

#### Gap 1.2: Agent Definition System - 45+ agents missing
- **Documented**: 45 agents in `.tmp/docs/agents/` and `.tmp/docs/additional-agents/`
- **Implemented**: 0 agents
- **Missing**: 45+ agents (100% gap)
- **Impact**: Blocks multi-agent orchestration (Phase 2)
- **Action Required**:
  1. Create PRD-010: Agent Ecosystem
  2. Design agent definition schema (markdown + metadata)
  3. Build agent loader system
  4. Implement all 45 agents
- **Estimated Scope**: 6-10 weeks
- **Prerequisite**: MCP infrastructure from Phase 1

#### Gap 1.3: NPL Syntax Parser - 155 elements missing
- **Documented**: 155 elements in `.tmp/docs/npl-syntax-elements.brief.md`
- **Implemented**: 0 elements
- **Missing**: 155 elements (100% gap)
- **Impact**: Blocks prompt engineering features
- **Action Required**:
  1. Create PRD-012: NPL Syntax Parser
  2. Build regex pattern library (155 patterns)
  3. Implement validator and AST builder
  4. Create `npl-syntax` command
- **Estimated Scope**: 4-6 weeks

### Tier 2: High-Priority Gaps (IMPLEMENT IN PHASE 2)

#### Gap 2.1: Orchestration Patterns - 5/5 missing
- **Documented**: 5 patterns in `.tmp/docs/multi-agent-orchestration.brief.md`
- **Implemented**: 0 patterns
- **Blocking**: US-058, US-059, US-064, US-065, US-032
- **Action**: Create PRD-011 after agent system ready

#### Gap 2.2: CLI Utilities - 7/7 missing
- **Documented**: 7 scripts in `.tmp/docs/scripts/`
- **Implemented**: 0 scripts
- **Critical**: `npl-load` blocks core NPL loading
- **Action**: Implement npl-load ASAP (highest priority CLI tool)

### Tier 3: Medium-Priority Gaps (IMPLEMENT IN PHASE 3-4)

#### Gap 3.1: Database Schema & Migrations
- **Documented**: 7 features needed
- **Implemented**: 0
- **Blocks**: Multi-user access, data persistence

#### Gap 3.2: Security & Access Control
- **Documented**: 9 features needed
- **Implemented**: 0
- **Blocks**: Enterprise features

#### Gap 3.3: Error Recovery & Observability
- **Documented**: 9 features needed
- **Implemented**: 0
- **Blocks**: Production readiness

---

## Recommended Implementation Sequence

### Immediate (Next 2-4 Weeks)
1. **Create PRD-009** (MCP Tools) - Unblock artifact/chat/task/browser features
2. **Create US-078-083** (New stories from gaps) - Document scope
3. **Start MCP Tools** - Artifact manager first (highest priority)

### Following (Weeks 4-8)
4. **Create PRD-010** (Agent System) - Design agent loader
5. **Create PRD-012** (NPL Parser) - Implement `npl-syntax` command first
6. **Complete MCP Tools** - All 23 tools implemented

### Later (Weeks 8+)
7. **Implement Agent Loader** - Integrate 45 agents
8. **Create PRD-011** (Orchestration) - Multi-agent coordination
9. **Build CLI Utilities** - npl-load, npl-persona, npl-session

### Future (Weeks 16+)
10. **Security & Observability** - Phase 4 features

---

## How to Use This Grid

**For Planning**: See Phase Summary for what to build next
**For Implementation**: Check Critical Gaps for what's blocking
**For Status**: Look at Status column (✅ = done, 📝 = designed, ❌ = not started)
**For User Impacts**: See User Stories column for which features affect which personas
**For Documentation**: See Docs column for PRD references and legacy sources

---

## Legacy Documentation Sources

All documented features traced to legacy `.tmp/docs/`:

- **MCP Tools**: `.tmp/docs/PROJECT-ARCH.brief.md` (23 tools listed)
- **Agents**: `.tmp/docs/agents/summary.brief.md` (16 core + 29 others)
- **Orchestration**: `.tmp/docs/multi-agent-orchestration.brief.md` (5 patterns)
- **NPL Syntax**: `.tmp/docs/npl-syntax-elements.brief.md` (155 elements)
- **CLI Scripts**: `.tmp/docs/scripts/summary.brief.md` (7 scripts)
- **Database**: `.tmp/docs/PROJECT-ARCH.brief.md` (storage layer)
- **Security**: `.tmp/docs/PROJECT-ARCH.brief.md` (bounded context)

---

**Generated**: 2026-02-02
**Source**: Legacy documentation migration - Artifact extraction phase
**Review Date**: 2026-02-09 (recommended)

# MCP Server Consolidation: Design vs Implementation

**Date**: 2026-02-02
**Status**: Analysis Complete
**Purpose**: Bridge gap between legacy design docs and production implementation

---

## Executive Summary

Two documentation sources provide different perspectives:

| Source | Coverage | Status | Tools | Database | Web Routes |
|--------|----------|--------|-------|----------|-----------|
| `.tmp/docs/` (Legacy) | Design & specifications | 📝 Documented | 23 designed | Planned | Planned |
| `.tmp/mcp-server/` (Production) | Actual implementation | ✅ Implemented | 73 actual | 16 tables | 17 routes |

**Key Finding**: The production implementation is **~3x more comprehensive** than the legacy design documents. We have 73 working MCP tools, not 23.

---

## The Big Picture

### What Was Designed (Legacy `.tmp/docs/`)
- 23 MCP tools across 4 categories
- Database schema (conceptual)
- Orchestration patterns (5)
- Agent definitions (45)
- NPL syntax (155 elements)

### What Was Built (Production `.tmp/mcp-server/`)
- 73 MCP tools across 8 active categories + 1 hidden (executors)
- 16 database tables with migration system
- 17 web routes with API and UI
- 7 test files with varied coverage
- Production-ready implementation

### What's Missing
- Tests for Session Management (0%)
- Tests for Task Queue System (0%)
- Exposed Executor tools (10+ implemented but not exposed)
- Frontend test coverage (0%)
- Integration with legacy design patterns

---

## Tool Inventory Comparison

### By Category

#### Artifact Management (C-02)
| Aspect | Legacy | Implemented |
|--------|--------|-------------|
| Tools | 6 tools (documented) | 5 tools (actual) |
| Status | 📝 Designed | ✅ Production |
| Test Coverage | - | 53% |
| Database | 2 tables (conceptual) | 2 tables (actual) |
| Web Routes | 3 documented | 3 actual |
| User Stories | US-008-011, US-023 | US-008, US-009, US-017, US-023, US-063, US-068, US-071, US-075 |

**Note**: Legacy doc listed 6 but implementation has 5 (design evolved)

#### Chat & Collaboration (C-04)
| Aspect | Legacy | Implemented |
|--------|--------|-------------|
| Tools | 7 tools (documented) | 8 tools (actual) |
| Status | 📝 Designed | ✅ Production |
| Test Coverage | - | 78% |
| Database | 4 tables (conceptual) | 4 tables (actual) |
| Web Routes | 3 documented | 3 actual |
| User Stories | US-004-007, US-022, US-027-028 | US-005, US-012-016, US-049, US-051, US-058-059, US-064 |

**Note**: Implementation includes notification system with 78% test coverage

#### Task Queue System (C-06)
| Aspect | Legacy | Implemented |
|--------|--------|-------------|
| Tools | 7 tools (documented) | 13 tools (actual) |
| Status | 📝 Designed | ✅ Alpha (0% tested) |
| Test Coverage | - | 0% ⚠️ |
| Database | 3 tables (conceptual) | 4 tables (actual) |
| Web Routes | 11 documented | 11 actual |
| User Stories | US-014-018, US-026, US-030 | US-020-037, US-048, US-051, US-054 |

**Gap**: Implemented has 13 tools but 0% test coverage - critical gap!

#### Browser Automation (C-07)
| Aspect | Legacy | Implemented |
|--------|--------|-------------|
| Tools | 7 tools (documented) | 32 tools (actual) |
| Status | 📝 Designed | ✅ Production |
| Test Coverage | - | Unknown |
| Database | Artifact storage | Artifact storage |
| Web Routes | 5 documented | 5 actual |
| User Stories | US-012, US-013, US-019-021, US-024, US-029, US-052 | US-012-013, US-019-021, US-024, US-029, US-052, US-042, US-048, US-091-093 |

**Gap**: 32 actual tools vs 7 designed - massive expansion with Playwright integration

---

## Hidden Opportunity: Executor System (C-10)

**Status**: ✅ Implemented | ❌ Not Exposed as MCP Tools

**Implementation Details**:
- Location: `src/npl_mcp/executors/manager.py`, `fabric.py`
- Database: `taskers` table
- Features: Lifecycle management, fabric CLI integration
- Potential Tools (not exposed): 10+

**Potential New User Stories**:
- US-091: Expose Executor Spawn Tool
- US-092: Expose Executor Lifecycle Tools
- US-093: Expose Fabric Pattern Tools

---

## Database Schema: Designed vs Implemented

### Legacy Design (Conceptual)

```
Key tables:
- artifacts, revisions (2)
- reviews, inline_comments (2)
- chat_rooms, chat_events (2)
- sessions (1)
- tasks, task_queue (2)
+ notifications concept
```

**Total**: ~10-12 tables (estimated)

### Production Implementation (Actual)

```
Implemented tables (16):
1. artifacts
2. revisions
3. reviews
4. inline_comments
5. review_overlays
6. chat_rooms
7. room_members
8. chat_events
9. notifications
10. sessions
11. taskers
12. task_queues
13. tasks
14. task_events
15. task_artifacts
16. schema_version

Plus migration system (5 migrations)
```

**Difference**: Production added 6 new tables + migration system:
- `review_overlays` - image annotation support
- `room_members` - explicit membership tracking
- `task_events` - activity log for tasks
- `task_artifacts` - artifact linking
- `schema_version` - migration tracking
- `taskers` - executor lifecycle

---

## Test Coverage Analysis

### Current State

| Category | Tools | Coverage | Status |
|----------|-------|----------|--------|
| C-01 Database | 0 | 82% | ✅ Excellent |
| C-02 Artifacts | 5 | 53% | ⚠️ Adequate |
| C-03 Reviews | 6 | 25% | ⚠️ Weak |
| C-04 Chat | 8 | 78% | ✅ Good |
| C-05 Sessions | 4 | 0% | ❌ CRITICAL |
| C-06 Tasks | 13 | 0% | ❌ CRITICAL |
| C-07 Browser | 32 | ? | ? Unknown |
| C-08 Scripts | 5 | 0% | ℹ️ External |
| C-09 Web | 17 routes | 0% | ℹ️ Frontend |
| C-10 Executors | - | ? | ? Not exposed |

**Average**: 31% - **Too low for production**

### Critical Gaps (0% coverage)
- Sessions (4 tools) - ❌ Must add tests
- Tasks (13 tools) - ❌ Must add tests
- Web Routes (17) - ❌ Must add tests

---

## Integration Challenges

### 1. Design-Implementation Gap
Legacy docs describe 23 tools; actual implementation has 73 tools. Docs are **incomplete**.

**Action**: Update docs to reflect actual implementation, not just design.

### 2. Test Coverage Gap
73 tools exist but 27 are either 0% tested or untested.

**Action**: Prioritize test suite for C-05 (sessions), C-06 (tasks), C-07 (browser).

### 3. Missing Executor Exposure
10+ executor tools implemented but hidden in unified.py.

**Action**: Create simple PR to expose executor tools as MCP endpoints.

### 4. User Story Mapping
Legacy user stories don't account for 50+ additional tools in actual implementation.

**Action**: Create new user stories for:
- Implementation validation (did it work?)
- Test coverage improvement
- Executor tool exposure
- Production readiness

---

## Recommended Consolidation Strategy

### Phase 1: Update Documentation
**Goal**: Make docs reflect actual implementation, not design

**Action**:
- Update PRD-009 with 73 actual tools (not 23 designed)
- Reference tool lists from `.tmp/mcp-server/tools/by-category/*.yaml`
- Document actual database schema (16 tables, not conceptual 10)
- Note test coverage for each category
- Highlight the 10 hidden executor tools

### Phase 2: Create Implementation Validation Stories
**Goal**: Validate that production code matches documented design

**Stories to Create**:
- US-091: Validate Artifact Management Implementation
- US-092: Validate Chat System Implementation
- US-093: Validate Task Queue Implementation
- US-094: Validate Browser Automation Implementation
- US-095: Validate Web Interface Implementation

### Phase 3: Improve Test Coverage
**Goal**: Achieve >80% coverage across all categories

**Stories to Create**:
- US-096: Add Session Management Test Suite (0% → 80%)
- US-097: Add Task Queue Test Suite (0% → 80%)
- US-098: Add Browser Automation Tests (? → 80%)
- US-099: Add Web Route Tests (0% → 80%)
- US-100: Add Executor System Tests (? → 80%)

### Phase 4: Expose Hidden Features
**Goal**: Make executor system available as MCP tools

**Stories to Create**:
- US-101: Expose Executor Spawn Tool
- US-102: Expose Executor Lifecycle Tools
- US-103: Expose Fabric Pattern Tools

### Phase 5: Production Readiness
**Goal**: Ensure all 73 tools are production-ready

**Stories to Create**:
- US-104: Production Deployment Checklist
- US-105: Error Handling and Recovery
- US-106: Performance Optimization

---

## Data Integration Points

### Story Mapping

**Implemented Stories** (from production code):
- US-008, US-009, US-010, US-011, US-023 - Artifacts & Reviews ✅
- US-005, US-006, US-007, US-022, US-027, US-028 - Chat ✅
- US-012, US-013, US-019, US-020, US-021, US-024, US-029, US-052 - Browser ✅
- US-001, US-002, US-003, US-004 - Sessions (partial)
- US-014, US-015, US-016, US-017, US-018, US-026, US-030 - Tasks (partial)

**Total Mapped**: ~40 stories with code backing

**Not Yet Mapped** (~50 stories):
- US-031 through US-077 (security, coordination, collaboration)
- US-078 through US-090 (newly created from legacy design)
- US-091+ (new stories for validation and testing)

### Tool Mapping

**Already Implemented** (73 tools):
- 5 Artifact tools
- 6 Review tools
- 8 Chat tools
- 4 Session tools
- 13 Task tools
- 32 Browser tools
- 5 Script tools
- (10+ Executor tools hidden)

**Not Yet Mapped to PRD**:
- Implementation validation
- Test coverage improvement
- Executor exposure
- Production features (security, observability, error recovery)

---

## Recommended PRD Structure

### PRD-009-REVISED: MCP Tools Implementation (Updated)
**Incorporates actual implementation from `.tmp/mcp-server/`**

Content:
- [ ] Overview of 73 actual tools (not 23 designed)
- [ ] 10 categories with tool lists
- [ ] Database schema (16 tables)
- [ ] Web routes (17 endpoints)
- [ ] Test coverage by category
- [ ] 10+ hidden executor tools (opportunity)
- [ ] User stories (US-008-090+)
- [ ] Implementation checklist
- [ ] Production readiness criteria

### New PRDs from Consolidation
- **PRD-020**: Implementation Validation Framework
- **PRD-021**: Test Coverage Improvement Plan
- **PRD-022**: Executor Tool Exposure
- **PRD-023**: Production Deployment & Readiness

---

## Key Insights

### What Went Right ✅
- Production implementation is **3x more comprehensive** than design
- Core systems (Database, Chat, Artifacts, Browser) are **production-quality**
- Database architecture is **well-designed** with proper relationships
- Web interface provides **complete feature access**
- Test coverage for core systems is **respectable** (78% for Chat, 82% for Database)

### What Needs Work ⚠️
- Session system has **0% test coverage** despite production use
- Task queue has **0% test coverage** despite 13 tools
- Executor system is **completely hidden** from MCP interface
- Web routes have **0% test coverage**
- User stories are **incomplete** - don't reflect actual implementation
- Documentation is **split** between design (legacy) and implementation (production)

### Strategic Recommendations 🎯
1. **Consolidate documentation** - one source of truth for what's built
2. **Add test coverage** - prioritize 0% categories (sessions, tasks, web)
3. **Expose executors** - simple change with big impact
4. **Update user stories** - link to actual implementation
5. **Plan Phase 2** - build on solid foundation of 73 working tools

---

## Next Steps for Integration

1. **Immediate** (This week):
   - Review `.tmp/mcp-server/` structure
   - Update PRD-009 with actual tools list
   - Create user stories for validation (US-091-095)

2. **Short-term** (Next sprint):
   - Write test suites for C-05, C-06, C-09
   - Expose executor tools (simple PR)
   - Consolidate documentation

3. **Medium-term** (Next quarter):
   - Achieve 80%+ test coverage across all categories
   - Create production deployment playbook
   - Build Phase 2 features on solid foundation

---

**Status**: Ready for implementation
**Consolidation Date**: 2026-02-02
**Source Analyzed**: `.tmp/docs/` (design) + `.tmp/mcp-server/` (implementation)
**Tools Documented**: 73 + 10 hidden = 83 total
**Categories Covered**: 10/10 with implementation details

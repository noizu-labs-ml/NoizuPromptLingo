# NPL Documentation Master Index

**Last Updated**: 2026-02-02
**Purpose**: Central navigation guide for all NPL project documentation
**Scope**: Architecture, user stories, personas, PRDs, tools, frameworks, and resources

---

## Quick Navigation

### 📋 For Planning & Product
- [Roadmap](roadmap.yaml) - 4-phase implementation roadmap with 16 features
- [Features Grid](features-grid.md) - Implementation status matrix showing gaps
- [Implementation Tracker](implementation-tracker.yaml) - Gap analysis and priorities
- [User Stories Index](user-stories/index.yaml) - 90+ stories with relationships
- [Personas Index](personas/index.yaml) - Core personas and agents

### 🏗️ For Architecture & Design
- [Project Architecture](PROJ-ARCH.md) - System overview and design principles
- [Project Layout](PROJ-LAYOUT.md) - Directory structure and organization
- [Agent Orchestration](arch/agent-orchestration.md) - TDD workflow and multi-agent patterns
- [Assumptions](arch/assumptions.md) - System assumptions and constraints

### 📚 For Development
- [PRD Format Guide](prd.md) - How to write PRDs for this project
- [PRD Specifications](PRDs/) - 5 key PRDs for Phase 1-2 implementation
  - [PRD-009: MCP Tools Implementation](PRDs/prd-009-mcp-tools-implementation.md)
  - [PRD-010: Agent Ecosystem Definition](PRDs/prd-010-agent-ecosystem.md)
  - [PRD-011: Multi-Agent Orchestration](PRDs/prd-011-multi-agent-orchestration.md)
  - [PRD-012: NPL Syntax Parser](PRDs/prd-012-npl-syntax-parser.md)
  - [PRD-013: CLI Utilities Implementation](PRDs/prd-013-cli-utilities.md)

### 🛠️ For Frameworks & Tools
- [FastMCP Framework Docs](resources/fastmcp/) - 11-part guide to FastMCP 2.x
  - [Installation Guide](resources/fastmcp/01-installation.md)
  - [Core Concepts](resources/fastmcp/02-core-concepts.md)
  - [Tool Implementation](resources/fastmcp/03-tools.md)
  - [Production Deployment](resources/fastmcp/08-deployment.md)
  - [Migration Guide](resources/fastmcp/09-migration.md)

### 📖 For Reference
- [Agent Catalog](resources/agents-catalog.md) - 45+ documented agent specifications
- [Legacy Architecture Perspectives](pending/architecture-perspectives.md) - Previous iteration insights
- [Orchestration Patterns](pending/orchestration-patterns.md) - 5 coordination patterns

---

## Complete Directory Structure

```
docs/
├── README.md                           # Project documentation overview
├── PROJ-ARCH.md                        # System architecture
├── PROJ-LAYOUT.md                      # Project structure
├── prd.md                              # PRD writing guide
├── roadmap.yaml                        # 4-phase implementation roadmap
├── features-grid.md                    # Feature status matrix
├── implementation-tracker.yaml         # Gap analysis and tracking
│
├── DOCUMENTATION-INDEX.md              # This file (master navigation)
│
├── user-stories/                       # User story specifications
│   ├── index.yaml                      # Story index with relationships
│   ├── US-001-load-npl-core.md
│   ├── US-002-load-project-context.md
│   ├── ... (90+ stories total)
│   ├── US-078-implement-artifact-creation-tool.md          # NEW
│   ├── US-079-define-multi-agent-orchestration-patterns.md # NEW
│   ├── US-080-build-npl-syntax-parser.md                   # NEW
│   ├── US-081-implement-mcp-chat-room-management.md        # NEW
│   ├── US-082-implement-mcp-task-queue-system.md           # NEW
│   ├── US-083-implement-browser-automation-tools.md        # NEW
│   ├── US-084-create-agent-definition-system.md            # NEW
│   ├── US-085-implement-cli-utilities.md                   # NEW
│   ├── US-086-extract-and-load-agent-specifications.md     # NEW
│   ├── US-087-build-npl-syntax-pattern-library.md          # NEW
│   ├── US-088-implement-session-management-with-worklogs.md# NEW
│   ├── US-089-build-multi-perspective-artifact-review.md   # NEW
│   └── US-090-create-agent-handoff-protocol.md             # NEW
│
├── personas/                           # Persona definitions
│   ├── index.yaml                      # Persona index with relationships
│   ├── P-001-ai-agent/
│   ├── P-002-product-manager/
│   ├── P-003-vibe-coder/
│   ├── P-004-project-manager/
│   └── P-005-dave-developer/
│
├── PRDs/                               # Product Requirement Documents (NEW)
│   ├── prd-009-mcp-tools-implementation.md
│   ├── prd-010-agent-ecosystem.md
│   ├── prd-011-multi-agent-orchestration.md
│   ├── prd-012-npl-syntax-parser.md
│   └── prd-013-cli-utilities.md
│
├── arch/                               # Architecture documents
│   ├── agent-orchestration.md          # TDD workflow and orchestration
│   └── assumptions.md                  # System assumptions
│
├── resources/                          # Reference documentation
│   ├── fastmcp/                        # FastMCP framework guides (11 docs)
│   │   ├── index.yaml
│   │   ├── README.md
│   │   ├── 01-installation.md
│   │   ├── 02-core-concepts.md
│   │   ├── 03-tools.md
│   │   ├── 04-resources.md
│   │   ├── 05-prompts.md
│   │   ├── 06-context.md
│   │   ├── 07-client.md
│   │   ├── 08-deployment.md
│   │   ├── 09-migration.md
│   │   └── 10-examples.md
│   ├── agents-catalog.md               # Agent specifications (reference)
│   └── ...
│
├── pending/                            # Staging area for migrated content
│   ├── README.md                       # Staging area guide
│   ├── orchestration-patterns.md       # 5 orchestration patterns
│   ├── architecture-perspectives.md    # Legacy architecture insights
│   └── (other staged content)
│
└── (other directories as applicable)
```

---

## Documentation by Workflow

### 🎯 Planning a New Feature

1. **Understand the landscape**
   - Read [Roadmap](roadmap.yaml) for phase and priority
   - Check [Features Grid](features-grid.md) for implementation status
   - Review related user stories in [User Stories Index](user-stories/index.yaml)

2. **Define the requirements**
   - Read [PRD Format Guide](prd.md) for structure
   - Review existing PRDs in [PRDs/](PRDs/) for examples
   - Create a new PRD following the template

3. **Map user personas**
   - Check [Personas Index](personas/index.yaml) for affected personas
   - Review persona capabilities and constraints
   - Identify user stories for each persona

---

### 🔨 Implementing a Feature

1. **Get context**
   - Read the relevant PRD in [PRDs/](PRDs/)
   - Review user stories in [User Stories Index](user-stories/index.yaml)
   - Check [Project Architecture](PROJ-ARCH.md) for system design

2. **Understand the architecture**
   - Read [Project Architecture](PROJ-ARCH.md) for core concepts
   - Review [Agent Orchestration](arch/agent-orchestration.md) for workflow patterns
   - Check [Project Layout](PROJ-LAYOUT.md) for where to put code

3. **Framework reference**
   - For MCP tools: Read [FastMCP Framework Docs](resources/fastmcp/)
   - For orchestration: See [Orchestration Patterns](pending/orchestration-patterns.md)
   - For agents: Check [Agent Catalog](resources/agents-catalog.md)

4. **Implementation checklist**
   - [ ] Read PRD for requirements and acceptance criteria
   - [ ] Review user stories for edge cases
   - [ ] Check architecture docs for patterns to follow
   - [ ] Read framework guides for implementation details
   - [ ] Review related implementations in codebase
   - [ ] Write tests for all acceptance criteria
   - [ ] Update documentation when complete

---

### 📊 Monitoring Progress

1. **Feature progress**
   - Check [Features Grid](features-grid.md) for current status
   - Review [Implementation Tracker](implementation-tracker.yaml) for blockers
   - Cross-reference with [Roadmap](roadmap.yaml) for phase alignment

2. **Story tracking**
   - Use [User Stories Index](user-stories/index.yaml) to track completion
   - Check relationships to identify dependencies
   - Monitor story status: draft → in_progress → completed

3. **Metrics**
   - Gap analysis: See [Implementation Tracker](implementation-tracker.yaml)
   - Critical path stories: See [Roadmap](roadmap.yaml) critical_path_stories
   - Resource allocation: See [Implementation Tracker](implementation-tracker.yaml) resource_recommendations

---

### 🎓 Onboarding New Team Members

1. **Start here**
   - Read [Project Architecture](PROJ-ARCH.md) for system overview
   - Review [Project Layout](PROJ-LAYOUT.md) for codebase structure
   - Check [Assumptions](arch/assumptions.md) for design constraints

2. **Understand the roadmap**
   - Read [Roadmap](roadmap.yaml) for phases and features
   - Check [Features Grid](features-grid.md) to see what's implemented vs pending
   - Review [Implementation Tracker](implementation-tracker.yaml) for current gaps

3. **Pick a task**
   - Find tasks in [User Stories Index](user-stories/index.yaml)
   - Match difficulty to experience level
   - Read the relevant PRD and user stories

4. **Deep dive**
   - Read [FastMCP Framework Docs](resources/fastmcp/) for tool development
   - Review [Orchestration Patterns](pending/orchestration-patterns.md) for multi-agent work
   - Check [Agent Catalog](resources/agents-catalog.md) for agent system

---

## Key Documents by Category

### Architecture & Design
| Document | Purpose | When to Read |
|----------|---------|--------------|
| [PROJ-ARCH.md](PROJ-ARCH.md) | System architecture and design | Foundational understanding |
| [PROJ-LAYOUT.md](PROJ-LAYOUT.md) | Project directory structure | Finding code and resources |
| [arch/agent-orchestration.md](arch/agent-orchestration.md) | TDD workflow and patterns | Multi-agent development |
| [arch/assumptions.md](arch/assumptions.md) | System assumptions | Understanding constraints |

### Planning & Roadmap
| Document | Purpose | When to Read |
|----------|---------|--------------|
| [roadmap.yaml](roadmap.yaml) | 4-phase implementation roadmap | Strategic planning |
| [features-grid.md](features-grid.md) | Feature status and gaps | Progress tracking |
| [implementation-tracker.yaml](implementation-tracker.yaml) | Detailed gap analysis | Understanding blockers |

### User Stories & Personas
| Document | Purpose | When to Read |
|----------|---------|--------------|
| [user-stories/index.yaml](user-stories/index.yaml) | All user stories with relationships | Feature specification |
| [personas/index.yaml](personas/index.yaml) | Persona definitions | Understanding users |

### Product Requirements
| Document | Purpose | When to Read |
|----------|---------|--------------|
| [prd.md](prd.md) | PRD writing guide | Creating new PRDs |
| [PRDs/prd-009-mcp-tools-implementation.md](PRDs/prd-009-mcp-tools-implementation.md) | 23 MCP tools specification | Tool implementation |
| [PRDs/prd-010-agent-ecosystem.md](PRDs/prd-010-agent-ecosystem.md) | 45 agents system | Agent development |
| [PRDs/prd-011-multi-agent-orchestration.md](PRDs/prd-011-multi-agent-orchestration.md) | Orchestration patterns | Multi-agent workflows |
| [PRDs/prd-012-npl-syntax-parser.md](PRDs/prd-012-npl-syntax-parser.md) | NPL syntax specification | Syntax validation |
| [PRDs/prd-013-cli-utilities.md](PRDs/prd-013-cli-utilities.md) | CLI tool specifications | Command-line tools |

### Frameworks & Tools
| Document | Purpose | When to Read |
|----------|---------|--------------|
| [resources/fastmcp/](resources/fastmcp/) | FastMCP framework guides | MCP server development |
| [resources/agents-catalog.md](resources/agents-catalog.md) | Agent specifications | Agent system reference |

### Reference & Legacy
| Document | Purpose | When to Read |
|----------|---------|--------------|
| [pending/orchestration-patterns.md](pending/orchestration-patterns.md) | 5 orchestration patterns | Multi-agent design patterns |
| [pending/architecture-perspectives.md](pending/architecture-perspectives.md) | Previous architecture | Historical context |

---

## How to Use This Index

### "I need to understand..." section

**...what we're building?**
→ Start with [Roadmap](roadmap.yaml) then [Features Grid](features-grid.md)

**...how the system is designed?**
→ Read [PROJ-ARCH.md](PROJ-ARCH.md) and [Project Layout](PROJ-LAYOUT.md)

**...what feature to build?**
→ Check [User Stories Index](user-stories/index.yaml) and relevant PRD

**...how to build a feature?**
→ Read PRD, then framework docs ([FastMCP](resources/fastmcp/), patterns, agents)

**...where code should go?**
→ See [Project Layout](PROJ-LAYOUT.md) for directory structure

**...who are the users?**
→ Check [Personas Index](personas/index.yaml)

**...what's blocking progress?**
→ See [Implementation Tracker](implementation-tracker.yaml) critical gaps

**...how much work is left?**
→ Check [Features Grid](features-grid.md) and [Implementation Tracker](implementation-tracker.yaml)

---

## Legend & Symbols

| Symbol | Meaning |
|--------|---------|
| 📋 | Documentation index or planning document |
| 🏗️ | Architecture or design document |
| 📚 | Development guide or specification |
| 🛠️ | Tools, frameworks, or technical reference |
| 📖 | Reference material or examples |
| ✅ | Implemented feature |
| 🚧 | Partially implemented |
| 📝 | Documented only |
| ❌ | Not started |

---

## Recent Changes

**2026-02-02**: Legacy documentation migration - Artifact extraction phase
- Added 13 new user stories (US-078 through US-090)
- Created 5 new PRDs (PRD-009 through PRD-013)
- Copied FastMCP framework docs to `docs/resources/fastmcp/`
- Extracted orchestration patterns to `pending/orchestration-patterns.md`
- Extracted architecture perspectives to `pending/architecture-perspectives.md`
- Extracted agent catalog to `resources/agents-catalog.md`
- Created comprehensive roadmap and features grid

---

## File Organization Philosophy

This documentation follows a few key principles:

1. **Hierarchical**: Start with high-level roadmap, dive into specific PRDs and stories
2. **Cross-linked**: Documents reference each other for context
3. **Traceable**: Every feature traces back to legacy sources (`.tmp/docs/`)
4. **Actionable**: Every document guides you to the next step
5. **Versioned**: Documentation dates help track currency

---

## Feedback & Maintenance

**This index should be updated when:**
- New major documents are added
- Documentation structure changes
- Navigation becomes unclear
- New reader workflows are discovered

**Current maintainer**: NPL Documentation Team
**Last review**: 2026-02-02

---

## Quick Reference Links

- 🚀 [Getting Started](PROJ-ARCH.md)
- 📊 [Current Status](features-grid.md)
- 📖 [User Stories](user-stories/index.yaml)
- 🔨 [Next Steps](implementation-tracker.yaml)
- 📝 [Write a PRD](prd.md)
- 🛠️ [FastMCP Guide](resources/fastmcp/)

---

*Master documentation index for NoizuPromptLingo (NPL) Framework*
*Part of legacy documentation migration initiative - 2026-02-02*

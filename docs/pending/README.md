# Legacy Documentation Migration - Staging Area

**Status**: In Progress
**Source**: `.tmp/docs/` (49 files, 388KB)
**Started**: 2026-02-02
**Approach**: Artifact-First Migration (Selective)

## Purpose

This directory serves as a temporary staging area for migrating valuable planning artifacts and reference documentation from legacy project documentation (`.tmp/docs/`) into the current project structure.

Rather than comprehensive archival, we focus on **extracting actionable planning artifacts** (features grid, roadmap, user stories, PRDs) that add immediate value to project planning and implementation.

## Directory Structure

```
docs/pending/
├── README.md                          # This file
├── roadmap.yaml                       # 4-phase implementation roadmap
├── features-grid.md                   # Implementation status matrix
├── implementation-tracker.yaml        # Gap analysis and tracking
├── orchestration-patterns.md          # 5 multi-agent patterns (for merge)
├── architecture-perspectives.md       # Legacy architecture insights (for merge)
├── agents-catalog.md                  # Legacy agent catalog (reference only)
├── DOCUMENTATION-INDEX.md             # Master navigation guide
└── resources/
    └── fastmcp/                       # FastMCP framework documentation
        ├── index.yaml
        ├── 01-installation.md
        ├── 02-core-concepts.md
        ├── 03-tools.md
        ├── 04-resources.md
        ├── 05-prompts.md
        ├── 06-context.md
        ├── 07-client.md
        ├── 08-deployment.md
        ├── 09-migration.md
        ├── 10-examples.md
        └── README.md
```

## Contents

### Planning Artifacts (Direct to Final Location)

**Planning documents extracted from legacy `.tmp/docs/` for immediate use:**

1. **roadmap.yaml** - 4-phase implementation roadmap with features
   - Phases: Foundation, Intelligence, Collaboration, Enterprise
   - 13+ features with user stories and gap analysis
   - Status tracking and priority indicators
   - Direct from: `.tmp/docs/PROJECT-ARCH.brief.md`, agent catalogs

2. **features-grid.md** - Implementation status matrix
   - Shows 91% gap in MCP tools (23 documented, 2 implemented)
   - Tracks agents (45 documented, 0 implemented)
   - Maps NPL syntax (155 elements, 0 parser)
   - Organizes by feature category and phase
   - Direct from: Legacy project architecture

3. **implementation-tracker.yaml** - Comprehensive gap analysis
   - Counts documented vs implemented components
   - Identifies 5 critical gaps with blocking stories
   - Next actions for each gap
   - Legacy source references for verification

### New User Stories (Direct to `docs/user-stories/`)

**13+ new user stories extracted from legacy features:**

- US-078: Implement MCP Artifact Creation Tool
- US-079: Define Multi-Agent Orchestration Patterns
- US-080: Build NPL Syntax Parser
- US-081-090: Additional orchestration, CLI, and browser features

Created as separate `.md` files in `docs/user-stories/` with relationships tracked in `index.yaml`.

### New PRDs (Direct to PRD Location)

**5 new PRDs grouping related user stories:**

- PRD-009: MCP Tools Implementation
- PRD-010: Agent Ecosystem Definition
- PRD-011: Multi-Agent Orchestration Framework
- PRD-012: NPL Syntax Parser
- PRD-013: CLI Utilities Implementation

Created in appropriate PRD directory with legacy documentation references.

### Reference Documentation (Staged)

**Content to be reviewed before moving to final location:**

1. **resources/fastmcp/** - General FastMCP framework guides (11 files)
   - Copied from: `worktrees/main/docs/fastmcp/`
   - Staged for review before moving to `docs/resources/fastmcp/`
   - Comprehensive guides on installation, tools, resources, deployment

2. **agents-catalog.md** - Reference catalog of 45 agents
   - Organized by category (Core, Infrastructure, Project Management, QA)
   - Implementation status: Documented only (0 implemented)
   - Staged in pending; moves to `docs/resources/` after review

### Enhancement Content (Staged for Merging)

**Content to enhance current documentation:**

1. **orchestration-patterns.md** - 5 multi-agent orchestration patterns
   - Consensus-driven, pipeline with gates, hierarchical, iterative, multi-perspective
   - Staged for review; will merge into `docs/arch/agent-orchestration.md`
   - Source: `.tmp/docs/multi-agent-orchestration.brief.md`

2. **architecture-perspectives.md** - Legacy architecture insights
   - 4-layer architecture (consumer, interface, definition, storage)
   - Domain-driven design with bounded contexts
   - Design patterns from previous iteration
   - Staged for review; will merge into `docs/PROJ-ARCH.md`
   - Source: `.tmp/docs/PROJECT-ARCH/` directory

### Navigation (Staged)

1. **DOCUMENTATION-INDEX.md** - Master documentation index
   - Complete navigation guide for all documentation
   - Sections for architecture, user stories, tools, frameworks
   - Navigation tips for different workflows
   - Staged for review before moving to `docs/DOCUMENTATION-INDEX.md`

## Review Process

All content in this staging area follows a review-before-move workflow:

### Step 1: Review Staged Content
- Check quality and accuracy of planning artifacts
- Verify YAML syntax (roadmap.yaml, implementation-tracker.yaml)
- Validate markdown formatting and links
- Confirm legacy source references are correct and traceable

### Step 2: Validate YAML
```bash
# Validate YAML files
yq -y '.' docs/pending/roadmap.yaml > /dev/null && echo "roadmap.yaml valid"
yq -y '.' docs/pending/implementation-tracker.yaml > /dev/null && echo "tracker valid"
yq -y '.' docs/pending/resources/fastmcp/index.yaml > /dev/null && echo "fastmcp index valid"
```

### Step 3: Revise As Needed
- Edit files in staging until quality meets standards
- Update relationships and cross-references
- Ensure consistency with current documentation style

### Step 4: Move to Final Locations
```bash
# Planning artifacts → docs/ root
mv docs/pending/roadmap.yaml docs/
mv docs/pending/features-grid.md docs/
mv docs/pending/implementation-tracker.yaml docs/

# FastMCP docs → docs/resources/
mkdir -p docs/resources
mv docs/pending/resources/fastmcp docs/resources/

# Reference catalogs → docs/resources/
mv docs/pending/agents-catalog.md docs/resources/

# Master index → docs/ root
mv docs/pending/DOCUMENTATION-INDEX.md docs/

# Enhancement content → Manual merge into existing docs
# orchestration-patterns.md → merge into docs/arch/agent-orchestration.md
# architecture-perspectives.md → merge into docs/PROJ-ARCH.md
```

### Step 5: Update References
- Update CLAUDE.md with FastMCP documentation references
- Update cross-references to use new final locations
- Verify all links work correctly

### Step 6: Clean Up
- Remove docs/pending/ directory when migration complete
- Commit migration to git

## What's NOT Staged Here

**Direct Placement (bypass staging):**

User stories and PRDs go directly to final locations:
- New user stories → `docs/user-stories/` (with .md files)
- `docs/user-stories/index.yaml` updated with yq
- New PRDs → Appropriate PRD directory
- No staging step for these items

**Legacy Documentation Reference:**

Always available for historical context:
- Source branch reference (if applicable)
- `.tmp/docs/` directory (49 files, 388KB)
- `worktrees/main/docs/fastmcp/` (FastMCP originals)

## Migration Strategy Overview

### Phase 1: Extract Planning Artifacts ✓
Priority: Critical
Extract features grid, roadmap, implementation tracker from legacy docs

### Phase 2: Create New User Stories and PRDs ✓
Priority: High
Generate 13+ user stories and 5 PRDs based on documented features

### Phase 3: Stage FastMCP Documentation ✓
Priority: Critical
Copy and index FastMCP framework guides for review

### Phase 4: Extract Enhancement Content ✓
Priority: Medium
Orchestration patterns, architecture perspectives for merging

### Phase 5: Create Navigation ✓
Priority: Low
Master documentation index

### Phase 6: Review & Move ⏳
Priority: High
Validate all staged content and move to final locations

### Phase 7: Clean Up ⏳
Priority: Medium
Remove staging area when complete

## Success Criteria

Migration considered complete when:

1. ✅ Features grid and roadmap created from legacy features
2. ✅ 13+ new user stories extracted and indexed
3. ✅ 5 new PRDs group related stories
4. ✅ FastMCP documentation available in `docs/resources/`
5. ⏳ Current docs enhanced with valuable legacy insights
6. ⏳ Master documentation index created
7. ⏳ All artifacts traceable to legacy sources
8. ⏳ No broken links or references
9. ⏳ Staging area cleaned up

## Legacy Documentation Summary

**Source**: `.tmp/docs/` (49 files, 388KB, created 2026-02-02)

**Sections**:
- Root documentation (8 files) - INDEX, README, PROJECT-ARCH, orchestration
- agents/ (16 files) - Core agent specifications
- additional-agents/ (23 files) - Specialized agents by category
- fastmcp/ (11 files) - FastMCP framework guides
- scripts/ (7 files) - CLI utility documentation
- commands/ (4 files) - Project command docs
- prompts/ (4 files) - NPL and SQL reference
- PROJECT-ARCH/ (5 files) - Architecture deep-dives
- orchestration/ (1 file) - Orchestration summary

**Key Findings**:
- 45+ agents documented (0 implemented) - 100% gap
- 23 MCP tools documented (2 implemented) - 91% gap
- 5 orchestration patterns documented (0 implemented) - 100% gap
- 155 NPL syntax elements documented (0 parser) - 100% gap
- 7 CLI scripts documented (0 implemented) - 100% gap
- Comprehensive FastMCP integration guides available

**Disposition**:
- **Extract**: Planning artifacts (features, roadmap, tracker)
- **Migrate**: FastMCP docs (copy from worktrees)
- **Stage**: Enhancement content for review before merging
- **Reference**: Branch/`.tmp/docs/` for historical context

## Contact & Questions

For questions about migration approach or content, see plan document at:
`docs/PRDs/migration-plan-legacy-docs.md` (if available)

---

*This staging area is managed as part of the legacy documentation migration initiative. See implementation plan for detailed timeline and responsibilities.*

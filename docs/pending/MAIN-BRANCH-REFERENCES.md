# Main Branch References Update

**Status**: Planned
**Date**: 2026-02-02
**Purpose**: Document how to update PRDs and user stories to reference main branch implementation paths

---

## Overview

When referencing the production implementation (worktrees/main/mcp-server), use the format:
```
main:/path/to/file
```

This indicates the file is in the main branch worktree, not the current branch.

---

## Files to Update

### PRDs (docs/PRDs/)

**PRD-001-database-infrastructure.md**
- Add reference: `main:/mcp-server/src/npl_mcp/storage/database.py`
- Add reference: `main:/mcp-server/src/npl_mcp/storage/schema/`
- Implementation status: See main:/mcp-server/src/npl_mcp/storage/

**PRD-002-artifact-management.md**
- Add reference: `main:/mcp-server/src/npl_mcp/artifacts/manager.py`
- Implementation status: See main:/mcp-server/tools/by-category/artifact-tools.yaml

**PRD-003-review-system.md**
- Add reference: `main:/mcp-server/src/npl_mcp/reviews/`
- Implementation status: See main:/mcp-server/tools/by-category/review-tools.yaml

**PRD-004-chat-and-sessions.md**
- Add reference: `main:/mcp-server/src/npl_mcp/chat/`
- Add reference: `main:/mcp-server/src/npl_mcp/sessions/`
- Implementation status: See main:/mcp-server/tools/by-category/chat-tools.yaml

**PRD-005-task-queue-system.md**
- Add reference: `main:/mcp-server/src/npl_mcp/tasks/`
- Implementation status: See main:/mcp-server/tools/by-category/task-tools.yaml

**PRD-006-browser-automation.md**
- Add reference: `main:/mcp-server/src/npl_mcp/browser/`
- Implementation status: See main:/mcp-server/tools/by-category/browser-tools.yaml

**PRD-007-web-interface.md**
- Add reference: `main:/mcp-server/src/npl_mcp/web/`
- Implementation status: See main:/mcp-server/tools/by-category/web-routes.yaml

**PRD-008-script-wrappers.md**
- Add reference: `main:/mcp-server/src/npl_mcp/scripts/`
- Implementation status: See main:/mcp-server/tools/by-category/script-tools.yaml

**PRD-009-external-executors.md**
- Add reference: `main:/mcp-server/src/npl_mcp/executors/`
- Implementation status: See main:/mcp-server/tools/by-category/executor-tools.yaml

**prd-009-mcp-tools-implementation.md**
- Add reference: `main:/mcp-server/docs/categories/02-artifact-management.md`
- Add reference: `main:/mcp-server/docs/categories/04-chat-collaboration.md`
- Add reference: `main:/mcp-server/docs/categories/06-task-queue.md`
- Add reference: `main:/mcp-server/docs/categories/07-browser-automation.md`

**prd-010-agent-ecosystem.md**
- Add reference: `main:/mcp-server/docs/categories/10-external-executors.md`
- Note: Agents are not yet implemented in main branch

**prd-011-multi-agent-orchestration.md**
- Add reference: `main:/docs/pending/mcp-server/extraction-summary.md` (orchestration patterns)

**prd-012-npl-syntax-parser.md**
- Add reference: `.tmp/docs/npl-syntax-elements.brief.md` (design)
- Note: Parser not yet implemented in main branch

**prd-013-cli-utilities.md**
- Add reference: `main:/mcp-server/tools/by-category/script-tools.yaml`
- Note: Partial implementation in main branch

---

### User Stories (docs/user-stories/)

#### Implementation-Validated Stories (US-91-95)
- **US-91**: Add reference to main:/mcp-server/src/npl_mcp/artifacts/
- **US-92**: Add reference to main:/mcp-server/src/npl_mcp/chat/
- **US-93**: Add reference to main:/mcp-server/src/npl_mcp/tasks/
- **US-94**: Add reference to main:/mcp-server/src/npl_mcp/browser/
- **US-95**: Add reference to main:/mcp-server/src/npl_mcp/web/

#### Test Coverage Stories (US-96-100)
- **US-96**: Add reference to main:/mcp-server/tests/ (session tests needed)
- **US-97**: Add reference to main:/mcp-server/tests/ (task tests needed)
- **US-98**: Add reference to main:/mcp-server/tests/ (browser tests needed)
- **US-99**: Add reference to main:/mcp-server/tests/ (web route tests needed)
- **US-100**: Add reference to main:/mcp-server/tests/ (executor tests needed)

#### Executor Exposure Stories (US-101-103)
- **US-101**: Add reference to main:/mcp-server/src/npl_mcp/executors/manager.py
- **US-102**: Add reference to main:/mcp-server/src/npl_mcp/executors/
- **US-103**: Add reference to main:/mcp-server/src/npl_mcp/executors/fabric.py

#### Existing Stories (US-001-090)
- Add main:/path references where implementation exists
- Example for US-008: main:/mcp-server/src/npl_mcp/artifacts/manager.py

---

## Reference Format Examples

### Single File Reference
```markdown
**Implementation**: See main:/mcp-server/src/npl_mcp/artifacts/manager.py
```

### Directory Reference
```markdown
**Source Code**: main:/mcp-server/src/npl_mcp/chat/
**Tests**: main:/mcp-server/tests/test_chat.py
```

### Documentation Reference
```markdown
**Specification**: See docs/pending/mcp-server/categories/02-artifact-management.md
**Implementation**: main:/mcp-server/src/npl_mcp/artifacts/
```

### Complex Reference with Section
```markdown
**Tool List**: main:/mcp-server/tools/by-category/chat-tools.yaml
**Category Brief**: docs/pending/mcp-server/categories/04-chat-collaboration.md
**Implementation**: main:/mcp-server/src/npl_mcp/chat/manager.py
```

---

## Update Patterns

### Pattern 1: Add Implementation Section
For PRDs, add after "Functional Requirements":

```markdown
## Implementation Status

**Location**: main:/mcp-server/src/npl_mcp/[module]/
**Test Coverage**: X%
**Status**: [Implemented|Partial|Planned|Not Started]
**Tools**: See main:/mcp-server/tools/by-category/[category]-tools.yaml
```

### Pattern 2: Add Source References
For user stories, add to "Implementation Notes" section:

```markdown
## Implementation Notes
**Source Code**: main:/mcp-server/src/npl_mcp/[module]/
**Tests**: main:/mcp-server/tests/test_[module].py
**Tool Spec**: main:/mcp-server/tools/by-category/[category]-tools.yaml
```

### Pattern 3: Add Architecture References
For orchestration/design docs:

```markdown
**Architecture**: See docs/pending/mcp-server/categories/[number]-[name].md
**Implementation**: main:/mcp-server/src/npl_mcp/[module]/
**Tools**: main:/mcp-server/tools/by-category/[category]-tools.yaml
```

---

## Prioritized Update List

### High Priority (Affects Implementation)
1. PRD-001 through PRD-009 (implementation reference)
2. US-91-103 (new implementation stories)
3. US-008-090 (existing stories with implementation)

### Medium Priority (Supporting Documentation)
1. prd-009 through prd-013 (design PRDs)
2. PRD-010 through PRD-013 (agent/feature design)
3. All user story files with implementation

### Low Priority (Reference/Archive)
1. Older design documentation
2. Planning artifacts
3. Legacy references

---

## Checklist for Updates

### For Each PRD File:
- [ ] Add "Implementation Status" section
- [ ] Reference main:/mcp-server/src/npl_mcp/[module]/
- [ ] Reference main:/mcp-server/tools/by-category/[type]-tools.yaml
- [ ] Reference docs/pending/mcp-server/categories/[number]-[name].md
- [ ] Add test coverage percentage from main:/mcp-server/tests/

### For Each User Story File:
- [ ] Add main:/mcp-server path to "Implementation Notes"
- [ ] Add test file reference if tests exist
- [ ] Add tool specification reference
- [ ] Cross-link to corresponding PRD

### For Enhancement Documents:
- [ ] Update legacy references to point to docs/pending/mcp-server/
- [ ] Update implementation references to point to main:/mcp-server/
- [ ] Add test coverage information from extraction-summary.md

---

## Tools & Commands for Bulk Updates

### Find and Replace Pattern
```bash
# Find stories without main:/mcp-server references
grep -r "Implementation Notes" docs/user-stories/ | grep -v "main:/mcp-server"

# Add reference template
sed -i 's/Implementation Notes:/Implementation Notes:\n**Source Code**: main:\/mcp-server\/src\/npl_mcp\/[module]\//' docs/user-stories/*.md
```

### Validation
```bash
# Verify all references are present
for file in docs/PRDs/*.md docs/user-stories/*.md; do
  if grep -q "main:/mcp-server" "$file"; then
    echo "✅ $file has main:/mcp-server reference"
  else
    echo "❌ $file missing main:/mcp-server reference"
  fi
done
```

---

## Notes

- **main:/path** format indicates main branch worktree files
- **docs/pending/mcp-server/** references point to extracted documentation (staging area)
- **docs/PRDs/** contains both design (prd-0XX) and implementation (PRD-0XX) specifications
- Test coverage percentages from `docs/pending/mcp-server/extraction-summary.md`
- Cleanup of numbering conflicts planned for later (PRD-009 vs prd-009)

---

**Created**: 2026-02-02
**Status**: Ready for implementation
**Next Step**: Update PRDs and user stories with main:/mcp-server references

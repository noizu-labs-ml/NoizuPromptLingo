# Consolidate User Stories from PRDs to Global Bucket

## Context

User stories were incorrectly created nested under each PRD directory. They must be moved to a single global `project-management/user-stories/` directory with unique IDs.

## Task

1. **Scan all PRD directories** for user stories in `PRD-*/user-stories/` subdirectories
2. **Consolidate** all stories to `project-management/user-stories/`
3. **De-duplicate** stories that appear in multiple PRDs (keep original, remove copies)
4. **Detect drift** - check if duplicate stories have diverged content
5. **Renumber** all stories with unique global IDs (US-001 through US-NNN)
6. **Create index.yaml** at `project-management/user-stories/index.yaml`
7. **Update PRDs** to reference stories by global ID only

## Process

### Step 1: Inventory All Stories

Find all `user-stories/` subdirectories in PRDs:
```bash
find project-management/PRDs/PRD-*/user-stories/ -name "*.md" -o -name "*.yaml"
```

Create inventory:
- Source PRD
- Current story ID (US-XXX)
- Title
- Personas
- Status

### Step 2: De-duplicate

For each story title, check if it appears in multiple PRDs:
- If identical: Keep from primary PRD, remove from others, note duplicate
- If drifted: Merge content, note drift, assign new global ID
- If new: Assign new global ID

### Step 3: Consolidate to Global Location

1. **Create global directory**:
   ```bash
   mkdir -p project-management/user-stories/
   ```

2. **Move/copy files** with new naming:
   ```bash
   # From PRD subdirectories to global location
   # Rename: US-XXX-slug.md → US-NNN-slug.md (global ID)
   ```

3. **Update content** in moved files:
   - Set `Related PRD: PRD-NNN` field
   - Preserve all original content
   - Add `Global ID: US-NNN` at top

### Step 4: Create Global Index

Create `project-management/user-stories/index.yaml`:

```yaml
user_stories:
  - id: US-001
    title: "Story Title"
    description: "One-line description"
    persona: persona-id
    priority: high | medium | low
    status: draft | active | completed
    file: US-001-slug.md
    related_prd:
      - PRD-NNN
    notes: "Consolidated from PRD-XXX/user-stories/US-001-slug.md"

  - id: US-002
    # ... etc
```

### Step 5: Update PRD README.md Files

For each PRD that had nested user stories, update the `README.md` User Stories section:

**From**:
```markdown
## User Stories

| ID | Title | Persona |
|----|-------|---------|
| US-001 | [Title](./user-stories/US-001-slug.md) | persona |
```

**To**:
```markdown
## User Stories

| ID | Title | Persona |
|----|-------|---------|
| US-001 | [Story Title](../../user-stories/US-001-slug.md) | persona |
| US-002 | [Story Title](../../user-stories/US-002-slug.md) | persona |
```

Use MCP tools for story access:
- **get-story**: Load full story content by ID
- **edit-story**: Modify story fields
- **update-story**: Update metadata in index.yaml

### Step 6: Remove Nested user-stories/ Directories

After consolidation:
```bash
# Remove nested user-stories directories from all PRDs
find project-management/PRDs/PRD-*/user-stories -type f -delete
find project-management/PRDs/PRD-* -type d -name "user-stories" -delete
```

Keep only index.yaml files in PRD subdirectories for functional-requirements/ and acceptance-tests/.

### Step 7: Validation Checklist

- [ ] All user stories moved to `project-management/user-stories/`
- [ ] No duplicate story files (by title)
- [ ] All stories have unique global IDs (US-001 through US-NNN)
- [ ] Global `project-management/user-stories/index.yaml` created
- [ ] All PRD README.md files updated with global story references
- [ ] All relative paths use `../../user-stories/` format
- [ ] No nested `PRD-*/user-stories/` directories remain
- [ ] All story files follow kebab-case naming
- [ ] No file naming conflicts

## Duplicate Detection Patterns

Watch for:
- **Exact duplicates**: Same title, content across multiple PRDs → Keep one, note others
- **Drifted copies**: Same title but content diverged → Merge or create separate story
- **Related stories**: Similar titles/scope → Consolidate under single ID
- **Renamed stories**: Different titles, same scope → Consolidate under single ID

Example:
- "Load Directives Section" appears in PRD-012 and PRD-013 → Consolidate to single US
- "Token Refresh" appears as "OAuth Token Refresh" in PRD-004 → Consolidate to single US

## Output Format

Report:
1. Total stories consolidated: NNN
2. Duplicate stories found: NNN (consolidated to X unique stories)
3. Drift detected: NNN (merged/resolved)
4. New global ID range: US-001 through US-NNN
5. PRDs updated: All 16
6. Index.yaml created: ✅
7. Nested directories removed: ✅

## Notes

- Preserve all original content and metadata
- Use consistent field names across all story files
- Maintain related_prd references for traceability
- Update CLAUDE.md references if needed

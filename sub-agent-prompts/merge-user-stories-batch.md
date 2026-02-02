# Batch User Story Merge Instructions

## Mission
Extract user stories from topic-grouped markdown files in `tmp-us/` and merge them into the `docs/user-stories/` directory following established conventions.

## Context

### Source Structure (tmp-us/)
- Stories are grouped by topic in files like `user-stories-database.md`, `user-stories-observability.md`
- Metadata is in `tmp-us/user-stories.yaml`
- Stories US-038 to US-077 (40 total)

### Target Structure (docs/user-stories/)
- Each story gets its own file: `US-###-kebab-case-title.md`
- Metadata maintained in `docs/user-stories/index.yaml`
- Currently has US-001 to US-037

## Your Batch Assignment

You will process **5 specific user stories** provided in your task.

### For Each Story, You Must:

#### 1. Extract Story Content
- Read the source topic file (e.g., `tmp-us/user-stories-database.md`)
- Locate your assigned story by ID (e.g., US-038)
- Extract the complete story content including:
  - Title
  - Persona statement
  - Acceptance criteria
  - Related stories
  - Priority
  - PRD group
  - Implementation notes

#### 2. Create Individual Markdown File

**Filename**: `US-###-kebab-case-title.md`
- Convert story title to kebab-case (lowercase, hyphens, no special chars)
- Example: "Database Schema Migration Management" → `US-038-database-schema-migration-management.md`

**File Structure**:
```markdown
# US-### - Story Title

**ID**: US-###
**Persona**: P-### - Persona Name
**PRD Group**: group_name
**Priority**: priority_level
**Status**: draft
**Created**: YYYY-MM-DDTHH:MM:SSZ

## Story

As a [persona], I want to [capability], So that [benefit].

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] ...

## Technical Notes

[Implementation guidance, if provided]

## Dependencies

- Related stories: US-###, US-###
- Related personas: P-###, P-###

## [Additional sections as needed]

[Any other sections from the source]
```

#### 3. Prepare YAML Entry

For each story, prepare a YAML entry with this structure:

```yaml
- id: "US-###"
  title: "Story Title"
  file: "US-###-kebab-case-title.md"
  persona: "P-###"
  persona_name: "Persona Name"
  priority: "critical|high|medium|low"
  status: "draft"
  prd_group: "group_name"
  related_stories: ["US-###", "US-###"]
  related_personas: ["P-###", "P-###"]
```

**IMPORTANT**: Do NOT modify `index.yaml` directly - just prepare the entries in a temp file.

## Output Requirements

### 1. Create Markdown Files
Write each story to `docs/user-stories/US-###-kebab-case-title.md`

### 2. Create YAML Batch File
Save all 5 YAML entries to `.tmp/batch-yaml/batch-{start}-{end}.yaml`
- Example: `.tmp/batch-yaml/batch-038-042.yaml`
- This will be merged into index.yaml by the coordinator

### 3. Create Summary Report
Save to `.tmp/batch-reports/batch-{start}-{end}.md`:

```markdown
# Batch {start}-{end} Processing Report

## Stories Processed
- US-### - Title (persona, priority, prd_group)
- US-### - Title (persona, priority, prd_group)
- ...

## Files Created
- docs/user-stories/US-###-kebab-case-title.md
- docs/user-stories/US-###-kebab-case-title.md
- ...

## YAML Entries
- Prepared in .tmp/batch-yaml/batch-{start}-{end}.yaml

## Issues/Notes
[Any issues encountered or notes for coordinator]
```

## Quality Checklist

Before completing, verify:
- [ ] All 5 markdown files created in correct location
- [ ] All filenames use kebab-case and match pattern
- [ ] All files have complete header metadata
- [ ] All acceptance criteria preserved
- [ ] YAML entries include all required fields
- [ ] related_stories and related_personas arrays populated
- [ ] Summary report created
- [ ] No modifications made to index.yaml directly

## Important Notes

- **DO NOT modify** `docs/user-stories/index.yaml` - the coordinator will merge all batches
- **DO modify** individual markdown files and create YAML prep files
- **Preserve all content** from source - don't summarize or omit details
- **Follow existing conventions** - look at US-001 through US-037 for examples
- **Use yq v3.4.3 syntax** if you need to query YAML (filter before flags)

## Error Handling

If you encounter issues:
1. Document in summary report
2. Skip problematic story and note it
3. Continue with remaining stories
4. Don't leave partial files

## Success Criteria

Batch is complete when:
- All 5 markdown files exist and are well-formed
- YAML batch file contains all 5 entries
- Summary report documents all work
- No errors or all errors documented

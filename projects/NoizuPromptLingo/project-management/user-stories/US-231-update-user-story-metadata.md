# User Story: Update User Story Metadata

**ID**: US-231
**Persona**: P-008 (TDD Workflow Agent), P-001 (AI Agent)
**PRD Group**: pm_mcp_tools
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T18:00:00Z

## Story

As a **TDD workflow agent**,
I want to **update metadata fields for a user story in the index.yaml file**,
So that **I can track implementation progress and maintain accurate status information as I complete work**.

## Acceptance Criteria

- [ ] `update_story_metadata(story_id: str, key: str, value: str)` tool updates index.yaml
- [ ] Tool supports updating `status` field (draft, in-progress, documented, implemented, tested)
- [ ] Tool supports updating `priority` field (critical, high, medium, low)
- [ ] Tool supports adding/updating `prds` array
- [ ] Tool supports adding/updating `related_stories` array
- [ ] Tool supports adding/updating `related_personas` array
- [ ] Tool uses atomic file operations (temp file + rename) to prevent corruption
- [ ] Tool validates field values before writing (e.g., status must be valid enum)
- [ ] Tool returns the updated story entry after successful write
- [ ] Tool returns error if story_id does not exist
- [ ] Tool preserves all other fields and formatting in index.yaml

## Technical Details

### Input Schema (Single Field)
```json
{
  "story_id": "US-226",
  "key": "status",
  "value": "in-progress"
}
```

### Input Schema (Array Append)
```json
{
  "story_id": "US-226",
  "key": "prds",
  "value": "PRD-011",
  "operation": "append"
}
```

### Input Schema (Multiple Fields)
```json
{
  "story_id": "US-226",
  "updates": {
    "status": "implemented",
    "prds": ["PRD-011"],
    "related_stories": ["US-227", "US-228"]
  }
}
```

### Output Schema
```json
{
  "success": true,
  "story_id": "US-226",
  "updated_fields": ["status"],
  "previous_values": {
    "status": "draft"
  },
  "current_entry": {
    "id": "US-226",
    "title": "Read User Story by ID",
    "status": "in-progress",
    "priority": "critical",
    "persona": "P-008"
  }
}
```

### File Location
- Index file: `project-management/user-stories/index.yaml`

### Implementation Notes
Uses `yq` for YAML manipulation per CLAUDE.md guidelines:
```bash
# Update single field
yq -y '.stories |= map(if .id == "US-226" then .status = "in-progress" else . end)' \
  project-management/user-stories/index.yaml > temp.yaml && mv temp.yaml project-management/user-stories/index.yaml

# Append to array
yq -y '.stories |= map(if .id == "US-226" then .prds = (.prds + ["PRD-011"]) else . end)' \
  project-management/user-stories/index.yaml > temp.yaml && mv temp.yaml project-management/user-stories/index.yaml
```

## Notes

- This is a write operation - should have appropriate access controls
- Consider audit logging for status changes
- Agent should only update stories it is actively working on

## Dependencies

- `project-management/user-stories/index.yaml` must exist and be valid YAML
- `yq` must be available on the system (v3.4.3)

## Open Questions

- Should we support updating the markdown file content as well, or keep that separate?
- Should status transitions be validated (e.g., can't go from "implemented" back to "draft")?
- Should we maintain an audit trail of metadata changes?

## Related Tools

- `get_story` - Read story to verify before update (US-226)
- `list_stories` - Find stories to update (US-227)
- `edit_story` - Modify markdown content (future enhancement)

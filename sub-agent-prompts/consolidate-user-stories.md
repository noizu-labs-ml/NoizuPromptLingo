# Consolidate User Stories: Merge YAML and Verify

## Mission

Consolidate 8 batch-processed user story YAML files into the main `docs/user-stories/index.yaml` and verify the merge succeeded.

## Context

- All 8 batch agents have completed and created YAML entries in `.tmp/batch-yaml/batch-{start}-{end}.yaml`
- 40 new markdown files were created in `docs/user-stories/US-038-*.md` through `US-077-*.md`
- Main index currently has 37 stories (US-001 to US-037)
- Task: Merge new entries and update timestamp

## Phase 1: Consolidate YAML Entries Using yq

### 1. Combine all batch YAML files
```bash
cat .tmp/batch-yaml/batch-*.yaml > .tmp/consolidated-entries.yaml
```

### 2. Create temp file with combined stories array
Use yq to read the consolidated entries and prepare them as an array:
```bash
# Convert consolidated entries (which are already array entries) into a proper stories structure
yq -y '[.]' .tmp/consolidated-entries.yaml > .tmp/new-stories.yaml
```

### 3. Append to existing stories array using yq
Use the proper yq v3.4.3 pattern to append:
```bash
# Read consolidated entries as an array
NEW_STORIES=$(yq -r '.' .tmp/consolidated-entries.yaml)

# Append to existing stories using yq (filter before flags)
yq -y ".stories += ${NEW_STORIES}" docs/user-stories/index.yaml > .tmp/index-merged.yaml && mv .tmp/index-merged.yaml docs/user-stories/index.yaml
```

**Alternative approach if above doesn't work**:
```bash
# Create a jq/yq compatible merge by reading both files
yq -y '.stories |= . + load(".tmp/new-stories-array.yaml")' docs/user-stories/index.yaml > .tmp/index-merged.yaml && mv .tmp/index-merged.yaml docs/user-stories/index.yaml
```

### 4. Update timestamp using yq
Update the `updated` field to current UTC time:
```bash
yq -y '.updated = now | todateiso8601' docs/user-stories/index.yaml > .tmp/timestamped.yaml && mv .tmp/timestamped.yaml docs/user-stories/index.yaml
```

OR manually set a specific timestamp:
```bash
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
yq -y ".updated = \"${TIMESTAMP}\"" docs/user-stories/index.yaml > .tmp/timestamped.yaml && mv .tmp/timestamped.yaml docs/user-stories/index.yaml
```

## Phase 2: Verify Results

### Verification Checklist

1. **Count verification**:
   - Query index.yaml: should show exactly 77 total stories
   - Count files: `ls -1 docs/user-stories/US-*.md | wc -l` should be at least 77

2. **Structure verification**:
   - index.yaml parses as valid YAML
   - All 40 new entries have required fields: id, title, file, persona, persona_name, priority, status, prd_group
   - related_stories and related_personas are arrays (may be empty)

3. **ID verification**:
   - No duplicate IDs in the combined list
   - IDs range from US-001 to US-077
   - All new IDs (US-038 to US-077) are present

4. **Relationship verification** (spot check):
   - Sample 3-5 new stories
   - Verify their related_stories references point to valid story IDs
   - Verify persona references exist (P-001 through P-005)

## Expected Outputs

### Success Indicators
- `docs/user-stories/index.yaml` updated with 77 total stories
- `updated` timestamp refreshed to current time
- All YAML is valid and parseable
- No errors during verification

### Generated Report
Create `.tmp/consolidation-report.md` documenting:
```markdown
# User Story Consolidation Report

## Summary
- Stories consolidated: 40
- Total stories now: 77
- Timestamp: [datetime]
- Status: ✅ COMPLETE

## Verification Results
- YAML valid: ✅
- ID count: 77 ✅
- No duplicates: ✅
- File count: [count] ✅
- Relationships verified: ✅

## Issues (if any)
[Document any issues encountered]
```

## Quality Checklist

Before completing:
- [ ] index.yaml has exactly 77 stories
- [ ] YAML parses without errors
- [ ] No duplicate IDs
- [ ] All required fields present in new entries
- [ ] Timestamp updated to current UTC time
- [ ] Consolidation report created
- [ ] Spot-check 3-5 relationships are valid

## Important Notes

- **Preserve** existing US-001 to US-037 entries exactly as they are
- **Append** new US-038 to US-077 entries in order
- **Valid YAML output** required – use proper formatting
- **No modifications** to individual markdown files
- Use ISO 8601 UTC format for timestamp: `YYYY-MM-DDTHH:MM:SSZ`

## Error Handling

If issues occur:
1. Document in report
2. Do not leave index.yaml in partially merged state
3. Restore from backup if needed
4. Report all blocking errors

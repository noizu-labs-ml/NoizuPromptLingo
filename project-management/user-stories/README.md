# User Stories Index

This directory contains individual user story markdown files and an `index.yaml` that serves as the single source of truth for user story relationships and metadata.

## Index Structure

The `index.yaml` file maintains:
- **Story metadata**: ID, title, file reference, persona assignment, priority, status, and PRD group
- **Relationships**: Links between related stories and personas
- **Version tracking**: Timestamps and version numbers for schema changes

## Using yq to Query User Stories

The `index.yaml` file can be queried using `yq` (version 3.4.3). All examples assume you're in the `docs/user-stories/` directory.

### ⚠️ Important: yq v3.4.3 Syntax Notes

- Filter expressions come **before** flags
- Output must be piped to a file, then moved back to update in-place
- The `-i` flag is not supported in v3.4.3

```bash
# ✅ CORRECT: Filter first, then flags, pipe to temp file
yq -y '.stories[] | select(.priority == "high")' index.yaml > temp.yaml && mv temp.yaml index.yaml

# ❌ INCORRECT: Filter after flags
yq '.stories[]' -y index.yaml  # Won't work

# ❌ INCORRECT: Using -i flag
yq -i '.stories[] |= map(...)' index.yaml  # Not supported
```

---

## Common Query Patterns

### List All User Stories (ID + Title)

Get a simple list of all story IDs and titles:

```bash
yq '.stories[] | "\(.id): \(.title)"' index.yaml
```

Output:
```
US-001: Load NPL Core Components
US-002: Load Project-Specific Context
US-003: Fetch Web Content as Markdown
...
```

### List All User Stories (Table Format)

Get a structured view with ID, title, persona, and priority:

```bash
yq '.stories[] | [.id, .title, .persona_name, .priority] | @csv' index.yaml
```

### Get Stories by Priority

Find all high-priority stories:

```bash
yq '.stories[] | select(.priority == "high")' index.yaml
```

Find critical stories:

```bash
yq '.stories[] | select(.priority == "critical") | .id + ": " + .title' index.yaml
```

### Get Stories by Status

Find all draft stories:

```bash
yq '.stories[] | select(.status == "draft") | .id' index.yaml
```

### Get Stories by Persona

Find all stories assigned to the AI Agent persona:

```bash
yq '.stories[] | select(.persona == "P-001") | .id + ": " + .title' index.yaml
```

Find stories for a specific persona by name:

```bash
yq '.stories[] | select(.persona_name == "Vibe Coder") | .id' index.yaml
```

### Get Stories by PRD Group

Find all stories in the "chat" PRD group:

```bash
yq '.stories[] | select(.prd_group == "chat") | .id + ": " + .title' index.yaml
```

List all unique PRD groups:

```bash
yq '[.stories[] | .prd_group] | unique' index.yaml
```

### Get Related Stories

Find all stories related to US-001:

```bash
yq '.stories[] | select(.id == "US-001") | .related_stories[]' index.yaml
```

Find stories that reference a specific story in their `related_stories`:

```bash
yq '.stories[] | select(.related_stories[] == "US-001") | .id' index.yaml
```

### Get Related Personas

Find personas related to a specific story:

```bash
yq '.stories[] | select(.id == "US-001") | .related_personas[]' index.yaml
```

### Count Stories by Persona

Get a count of stories per persona:

```bash
yq '[.stories[] | .persona_name] | group_by(.) | map({persona: .[0], count: length})' index.yaml
```

### Count Stories by Priority

```bash
yq '[.stories[] | .priority] | group_by(.) | map({priority: .[0], count: length})' index.yaml
```

### Count Stories by PRD Group

```bash
yq '[.stories[] | .prd_group] | group_by(.) | map({group: .[0], count: length})' index.yaml
```

### Filter by Multiple Criteria

Find high-priority or critical stories for the AI Agent:

```bash
yq '.stories[] | select((.priority == "high" or .priority == "critical") and .persona == "P-001")' index.yaml
```

### Get Stories with Collaborators

Find stories that have collaborators defined:

```bash
yq '.stories[] | select(has("collaborators")) | .id + ": " + .title' index.yaml
```

---

## Updating User Stories

### Add a Related Story

Add US-005 as a related story to US-001:

```bash
yq -y '.stories |= map(if .id == "US-001" then .related_stories += ["US-005"] else . end)' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

### Update Story Priority

Change US-001 to medium priority:

```bash
yq -y '.stories |= map(if .id == "US-001" then .priority = "medium" else . end)' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

### Update Story Status

Mark US-001 as complete:

```bash
yq -y '.stories |= map(if .id == "US-001" then .status = "completed" else . end)' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

### Add Collaborators to a Story

Add P-003 and P-005 as collaborators to US-036:

```bash
yq -y '.stories |= map(if .id == "US-036" then .collaborators = ["P-003", "P-005"] else . end)' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

### Update Multiple Stories at Once

Change all "draft" stories to "in-progress":

```bash
yq -y '.stories |= map(if .status == "draft" then .status = "in-progress" else . end)' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

### Update Timestamp

Update the index timestamp to reflect recent changes:

```bash
yq -y '.updated = now | todateiso8601' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

---

## Advanced Patterns

### Find Stories Needing Review

Find all completed stories that are in the tasks PRD group:

```bash
yq '.stories[] | select(.status == "completed" and .prd_group == "tasks")' index.yaml
```

### Find Orphaned Stories

Find stories with no related_personas defined:

```bash
yq '.stories[] | select(.related_personas | length == 0) | .id' index.yaml
```

### Get Story Dependency Graph

List stories and their direct relationships:

```bash
yq '.stories[] | {id: .id, title: .title, related: .related_stories}' index.yaml
```

### Export for External Processing

Export all stories as JSON for processing elsewhere:

```bash
yq -o json '.stories[]' index.yaml > all_stories.json
```

---

## File References

Each story entry in `index.yaml` references a markdown file in this directory. The relationship is maintained in the `file` field:

```yaml
- id: US-001
  title: Load NPL Core Components
  file: US-001-load-npl-core.md  # ← Points to the markdown file
```

To verify that all referenced files exist:

```bash
for file in $(yq '.stories[] | .file' index.yaml); do
  [ ! -f "$file" ] && echo "Missing: $file"
done
```

---

## Best Practices

1. **Keep relationships bidirectional**: If US-001 relates to US-002, US-002 should relate back to US-001
2. **Use consistent naming**: Follow the `US-###-kebab-case` naming convention for IDs and files
3. **Update timestamps**: Use `yq '.updated = now | todateiso8601'` when modifying the index
4. **Validate before committing**: Query the index to ensure changes are correct before committing
5. **Document schema changes**: When modifying index structure, update this README with new patterns

---

## See Also

- [../personas/README.md](../personas/README.md) - Persona index operations
- [CLAUDE.md](../../CLAUDE.md) - Project development guidelines

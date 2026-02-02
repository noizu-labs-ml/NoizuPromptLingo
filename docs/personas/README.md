# Personas Index

This directory contains individual persona markdown files and an `index.yaml` that serves as the single source of truth for persona relationships and metadata.

## Index Structure

The `index.yaml` file maintains:
- **Persona metadata**: ID, name, file reference, and tags
- **Relationships**: Links between personas and their associated user stories
- **Version tracking**: Timestamps and version numbers for schema changes

## Using yq to Query Personas

The `index.yaml` file can be queried using `yq` (version 3.4.3). All examples assume you're in the `docs/personas/` directory.

### ⚠️ Important: yq v3.4.3 Syntax Notes

- Filter expressions come **before** flags
- Output must be piped to a file, then moved back to update in-place
- The `-i` flag is not supported in v3.4.3

```bash
# ✅ CORRECT: Filter first, then flags, pipe to temp file
yq -y '.personas[] | select(.id == "P-001")' index.yaml > temp.yaml && mv temp.yaml index.yaml

# ❌ INCORRECT: Filter after flags
yq '.personas[]' -y index.yaml  # Won't work

# ❌ INCORRECT: Using -i flag
yq -i '.personas[] |= map(...)' index.yaml  # Not supported
```

---

## Common Query Patterns

### List All Personas (ID + Name)

Get a simple list of all persona IDs and names:

```bash
yq '.personas[] | .id + ": " + .name' index.yaml
```

Output:
```
P-001: AI Agent
P-002: Product Manager
P-003: Vibe Coder
P-004: Project Manager
P-005: Dave the Fellow Developer
P-006: Control Agent
P-007: Sub-Agent
```

### List All Personas (Detailed)

Get a structured view with ID, name, and tags:

```bash
yq '.personas[] | {id: .id, name: .name, tags: .tags}' index.yaml
```

### Get a Specific Persona

Find the persona with ID P-001:

```bash
yq '.personas[] | select(.id == "P-001")' index.yaml
```

Find a persona by name:

```bash
yq '.personas[] | select(.name == "AI Agent")' index.yaml
```

### Get Persona Tags

Get all tags for a specific persona:

```bash
yq '.personas[] | select(.id == "P-001") | .tags[]' index.yaml
```

Get all unique tags across all personas:

```bash
yq '[.personas[] | .tags[]] | unique' index.yaml
```

### Find Personas by Tag

Find all personas with the "autonomous" tag:

```bash
yq '.personas[] | select(.tags[] == "autonomous") | .id + ": " + .name' index.yaml
```

Find all personas with "agent" in their tags:

```bash
yq '.personas[] | select(.tags[] | contains("agent")) | .name' index.yaml
```

### Get User Stories for a Persona

Find all stories related to the AI Agent (P-001):

```bash
yq '.personas[] | select(.id == "P-001") | .related_stories[]' index.yaml
```

Get a formatted list of story IDs for a persona:

```bash
yq '.personas[] | select(.id == "P-002") | .related_stories | @csv' index.yaml
```

### Count Stories per Persona

Get how many stories each persona is involved in:

```bash
yq '.personas[] | {id: .id, name: .name, story_count: (.related_stories | length)}' index.yaml
```

### List Personas by Story Count

Find the persona with the most associated stories:

```bash
yq '[.personas[] | {id: .id, name: .name, count: (.related_stories | length)}] | sort_by(.count) | reverse' index.yaml
```

### Find Developer-Focused Personas

Find all personas involved in code/development:

```bash
yq '.personas[] | select(.tags[] | test("developer|code|agent")) | .name' index.yaml
```

### Filter by Multiple Tags

Find personas with both "autonomous" AND "orchestration" tags:

```bash
yq '.personas[] | select(.tags | contains(["autonomous", "orchestration"]))' index.yaml
```

Find personas with either "autonomous" OR "senior-developer" tags:

```bash
yq '.personas[] | select((.tags[] == "autonomous") or (.tags[] == "senior-developer"))' index.yaml
```

### Find Personas Without Specific Tag

Find personas that do NOT have the "agent" tag:

```bash
yq '.personas[] | select(.tags | index("agent") == null)' index.yaml
```

---

## Updating Personas

### Add a Related Story

Add US-005 to the stories for persona P-001:

```bash
yq -y '.personas |= map(if .id == "P-001" then .related_stories += ["US-005"] else . end)' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

### Add a Tag to a Persona

Add the "collaboration" tag to P-005:

```bash
yq -y '.personas |= map(if .id == "P-005" then .tags += ["collaboration"] else . end)' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

### Remove a Tag from a Persona

Remove the "agent" tag from all personas:

```bash
yq -y '.personas |= map(.tags |= map(select(. != "agent")))' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

### Update Persona Name

Change the name of persona P-005:

```bash
yq -y '.personas |= map(if .id == "P-005" then .name = "Dave - Senior Developer" else . end)' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

### Remove a Story from a Persona

Remove US-001 from P-001's related stories:

```bash
yq -y '.personas |= map(if .id == "P-001" then .related_stories |= map(select(. != "US-001")) else . end)' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

### Update Multiple Stories at Once

Replace all related stories for P-003 with a new set:

```bash
yq -y '.personas |= map(if .id == "P-003" then .related_stories = ["US-003", "US-004", "US-006"] else . end)' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

### Update Timestamp

Update the index timestamp to reflect recent changes:

```bash
yq -y '.updated = now | todateiso8601' index.yaml > temp.yaml && mv temp.yaml index.yaml
```

---

## Advanced Patterns

### Cross-Reference Check

Verify that every story referenced in a persona exists in the user-stories index:

```bash
yq '.personas[] | {persona: .id, stories: .related_stories[]}' index.yaml
```

### Find Personas with Most Tags

```bash
yq '[.personas[] | {id: .id, name: .name, tag_count: (.tags | length)}] | sort_by(.tag_count) | reverse' index.yaml
```

### Export Persona-Story Mapping

Create a mapping of persona names to story IDs:

```bash
yq '.personas[] | {name: .name, stories: .related_stories}' index.yaml
```

### Get All Personas and Their Primary Characteristic

Extract the first tag as a primary characteristic:

```bash
yq '.personas[] | {id: .id, name: .name, primary_tag: .tags[0]}' index.yaml
```

### Find Personas with Overlapping Stories

Find personas that share related stories:

```bash
yq '[.personas[] as $p | {persona_id: $p.id, shared_with: [.personas[] | select(.id != $p.id and .related_stories | contains($p.related_stories))]}]' index.yaml
```

### Export for External Processing

Export all personas as JSON for processing elsewhere:

```bash
yq -o json '.personas[]' index.yaml > all_personas.json
```

---

## File References

Each persona entry in `index.yaml` references a markdown file in this directory. The relationship is maintained in the `file` field:

```yaml
- id: P-001
  name: AI Agent
  file: ai-agent.md  # ← Points to the markdown file
```

To verify that all referenced files exist:

```bash
for file in $(yq '.personas[] | .file' index.yaml); do
  [ ! -f "$file" ] && echo "Missing: $file"
done
```

---

## Integration with User Stories

The personas index is designed to work in tandem with the user-stories index. Relationships are tracked in both directions:

- **In personas/index.yaml**: `related_stories` field lists user stories for each persona
- **In user-stories/index.yaml**: `related_personas` field lists personas for each user story

This bidirectional relationship ensures consistency and enables cross-referencing across the entire project.

---

## Best Practices

1. **Keep relationships bidirectional**: If persona P-001 relates to story US-001, US-001 should reference P-001
2. **Use meaningful tags**: Tags should be lowercase, hyphen-separated (e.g., `senior-developer`, `code-review`)
3. **Avoid duplicate tags**: Each persona should have a unique set of tags
4. **Update timestamps**: Use `yq '.updated = now | todateiso8601'` when modifying the index
5. **Validate consistency**: Ensure referenced stories exist in the user-stories index
6. **Document new personas**: Add markdown files that describe persona characteristics, goals, and workflows

---

## See Also

- [../user-stories/README.md](../user-stories/README.md) - User stories index operations
- [CLAUDE.md](../../CLAUDE.md) - Project development guidelines

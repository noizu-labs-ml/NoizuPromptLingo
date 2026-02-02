# Brief Generation - Main Prompt

**Objective**: Create comprehensive briefs for commands, prompts, and scripts by consolidating paired documentation files.

## File Handling Rules

### Paired Files
When both `.md` and `.detailed.md` exist for an item:
1. Read BOTH files completely
2. Extract high-level from `.md` (typically: overview, purpose, quick reference)
3. Extract depth from `.detailed.md` (typically: implementation details, examples, advanced usage)
4. **Create ONE consolidated brief file** combining both
5. **Do NOT create separate briefs** - consolidate into single output

### Single Files
If only `.md` exists (no `.detailed.md`):
1. Read the `.md` file
2. Create brief directly from it
3. Output as single brief file

## Brief Template Structure

**Length**: 300-800 words (scale to content complexity)
**Format**: Markdown with clear sections
**Output file**: `.tmp/docs/{category}/{item-name}.brief.md`

```markdown
# {Item Name}

**Type**: [Command / Prompt / Script]
**Category**: [From source directory structure]
**Status**: [Core / Utility / Extension]

## Purpose
[1-2 paragraphs: What does this do? Why does it exist? When should it be used?]

## Key Capabilities
- [Capability 1]
- [Capability 2]
[4-6 bullets highlighting main features/functions]

## Usage & Integration
[How is it used? What triggers it? What does it feed to/receive from?]
- **Triggered by**: [What initiates execution]
- **Outputs to**: [What consumes results]
- **Complements**: [Related items]

## Core Operations
[Main workflows, commands, or procedures]
```bash
[Example command or syntax]
```
[2-3 more examples if applicable]

## Configuration & Parameters
| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| [param1] | [Description] | [Default] | [Additional info] |
[4-6 parameter rows if applicable]

## Integration Points
- **Upstream dependencies**: [What must run first]
- **Downstream consumers**: [What uses the output]
- **Related utilities**: [Similar or complementary tools]

## Limitations & Constraints
- [Limitation 1]
- [Limitation 2]
[2-4 items]

## Success Indicators
- [Indicator 1]
- [Indicator 2]
[2-3 items]

---
**Generated from**: worktrees/main/docs/{category}/{item-name}.md[.detailed.md]
```

## Processing Steps

For each item:

1. **Read source files**
   - Read: `worktrees/main/docs/{CATEGORY}/{ITEM_NAME}.md`
   - Read: `worktrees/main/docs/{CATEGORY}/{ITEM_NAME}.detailed.md` (if exists)

2. **Extract information**
   - Purpose and overview
   - Key capabilities and features
   - Usage patterns and workflows
   - Configuration options
   - Integration points
   - Limitations and constraints
   - Success criteria

3. **Consolidate into brief**
   - Combine `.md` summary with `.detailed.md` depth
   - Follow template structure
   - Keep language concise but comprehensive
   - Use tables/lists for scanability
   - Include practical examples

4. **Write output**
   - Path: `.tmp/docs/{CATEGORY}/{ITEM_NAME}.brief.md`
   - Ensure directory exists
   - Verify file is valid markdown

5. **Report**
   - Item name
   - Status: CREATED
   - Word count
   - Path written to

## Per-Item Parameters

Each agent will receive:
```
CATEGORY: [commands / prompts / scripts]
ITEM_NAME: [specific item to process]
CATEGORY_PATH: [path segment in source and output]
```

## Quality Checks

✓ Brief consolidates both .md and .detailed.md (if pair exists)
✓ Single output file (not multiple files per item)
✓ Follows template structure
✓ 300-800 words
✓ Includes practical examples
✓ Clear integration points documented
✓ Valid markdown syntax

## Special Considerations

**Commands**:
- Include full command syntax
- Show common flag combinations
- Document expected outputs
- Note side effects or state changes

**Prompts**:
- Explain purpose and use case
- Document parameters/variables
- Show composition patterns
- Describe integration with agents

**Scripts**:
- Show invocation syntax
- Document all parameters
- Explain dependencies
- Provide execution examples
- Document success/failure indicators

## Execution

Process in parallel:
- 1 agent per item
- All items in category processed concurrently
- Independent file operations (no shared state)
- Report results with counts and word totals

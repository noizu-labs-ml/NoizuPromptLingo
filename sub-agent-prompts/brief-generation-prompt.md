# Brief Generation Prompt

**Task**: Create brief files for documentation entries from `worktrees/main/docs/`.

**Instructions**:

1. For each entry, read BOTH `.md` and `.detailed.md` files (if pair exists)
2. Consolidate information into ONE brief file
3. Write brief to: `.tmp/docs/[path]/[name].brief.md`

**Brief Template** (250-1000 words, 4-7 H2 sections):

```markdown
# [Name] - Summary

## Overview
[2-3 paragraphs describing purpose and context]

## Main Categories/Capabilities
[Structured breakdown with tables/lists]

## Integration & Workflows
[How it connects to other components]

## Key Concepts
[Important terminology or patterns]

## Gaps/Questions (optional)
[Missing documentation or clarifications]

---
Generated from: [source-path]
```

**Entry Details**:
- **Entry name**: {ENTRY_NAME}
- **Source docs**: worktrees/main/docs/{SOURCE_PATH}
- **Output path**: .tmp/docs/{OUTPUT_PATH}.brief.md

**Process**:
1. Read `.md` file at: worktrees/main/docs/{SOURCE_PATH}.md
2. Read detailed file if exists: worktrees/main/docs/{SOURCE_PATH}.detailed.md
3. Extract: purpose, counts, capabilities, integration points, gaps
4. Create brief following template
5. Write to output path

**Content Guidelines**:
- Length: 250-1000 words (scale to complexity)
- Structure: 4-7 H2 sections
- Include: Purpose, categories, workflows, cross-references
- Omit: Implementation details, code snippets, extensive examples
- Style: Concise, technical, scannable (use tables/lists)

**Output Format**:
Report:
- Entry name
- Status: CREATED / ALREADY EXISTS
- Word count
- Path written to

**Special Handling**:
- Paired files (`.md` + `.detailed.md`): Generate ONE brief consolidating both
- README files: Include in briefs but also note separately
- Structure: Mirror source directory structure in .tmp/docs/

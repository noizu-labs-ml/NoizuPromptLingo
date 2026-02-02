# Utility Persona Creation Prompt

**Task**: Create a persona for a command, prompt, or script utility.

**Instructions**:

1. Check if persona exists at the output path
2. If EXISTS: Read existing + source docs. Compare and revise if outdated/incomplete.
3. If DOESN'T EXIST: Read source docs and create new persona.
4. Write output to the specified output path.

**Template Structure** (300-600 words):

```markdown
# [Utility Name] - Persona

**Type**: [Command / Prompt / Script]
**Category**: [Category from source]
**Version**: 1.0.0

## Overview
[2-3 sentences describing what this utility does and why it exists]

## Purpose & Use Cases
- [Use case 1]
- [Use case 2]
- [etc., 3-5 items]

## Key Features
✅ [Feature 1]
✅ [Feature 2]
[etc., 4-6 items]

## Usage
```bash
[Command syntax or invocation example]
```

[2-3 sentences explaining typical usage flow]

## Integration Points
- **Triggered by**: [What initiates this utility]
- **Feeds to**: [What consumes its output]
- **Complements**: [Related utilities]

## Parameters / Configuration
- [Parameter/option 1] - Description
- [Parameter/option 2] - Description
[etc., 3-5 items]

## Success Criteria
- [Criterion 1]
- [Criterion 2]
[etc., 3-4 items]

## Limitations & Constraints
- [Limitation 1]
- [Limitation 2]
[etc., 2-3 items]

## Related Utilities
- [Related utility 1]
- [Related utility 2]
```

**Utility Details**:
- **Utility name**: {UTILITY_NAME}
- **Source docs**: worktrees/main/docs/{SOURCE_PATH}
- **Output path**: {OUTPUT_PATH}

**Process**:
1. Read `.md` file at: worktrees/main/docs/{SOURCE_PATH}.md
2. Read detailed file if exists: worktrees/main/docs/{SOURCE_PATH}.detailed.md
3. Check existing at: {OUTPUT_PATH}
4. Create or revise persona following template
5. Extract: purpose, use cases, features, syntax, integration, parameters, success criteria, limitations
6. Write to output path

**Output**:
Report:
- Status: CREATED / REVISED (changes: list key updates) / NO CHANGES NEEDED
- Word count
- Path written to

**Style Notes**:
- Concise but comprehensive
- Use agent/utility-specific terminology from source docs
- Include practical examples
- Focus on integration and workflow context
- Match existing persona tone

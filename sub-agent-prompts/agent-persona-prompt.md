# Agent Persona Creation Prompt

**Task**: Create or revise a single agent persona.

**Instructions**:

1. Check if persona exists at the output path
2. If EXISTS: Read existing persona + source docs. Compare and revise if outdated/incomplete.
3. If DOESN'T EXIST: Read source docs and create new persona.
4. Write output to the specified output path.

**Template Structure** (400-800 words):
```markdown
# Agent Persona: [Agent Name]

**Agent ID**: [agent-id or derived from agent-name]
**Type**: [Category: Discovery, Content, Implementation, Planning, Security, etc.]
**Version**: 1.0.0

## Overview
[2-3 sentences describing purpose and approach]

## Role & Responsibilities
- [Responsibility 1]
- [Responsibility 2]
- [etc., 4-6 bullets]

## Strengths
✅ [Strength 1]
✅ [Strength 2]
[etc., 4-8 items]

## Needs to Work Effectively
- [Need 1]
- [Need 2]
[etc., 4-6 items]

## Communication Style
- [Style aspect 1]
- [Style aspect 2]
[etc., 3-5 aspects]

## Typical Workflows
1. [Workflow 1] - Description
2. [Workflow 2] - Description
[etc., 3-5 workflows]

## Integration Points
- **Receives from**: [Agent names or data sources]
- **Feeds to**: [Agent names or destinations]
- **Coordinates with**: [Related agents]

## Key Commands/Patterns
\`\`\`
@agent-name command --param=value
\`\`\`

## Success Metrics
- [Metric 1]
- [Metric 2]
[etc., 3-5 metrics]
```

**Agent Details**:
- **Agent name**: {AGENT_NAME}
- **Source docs**: worktrees/main/docs/{SOURCE_PATH}
- **Output path**: {OUTPUT_PATH}

**Process**:
1. Read source `.md` file at: worktrees/main/docs/{SOURCE_PATH}.md
2. Read detailed file if exists: worktrees/main/docs/{SOURCE_PATH}.detailed.md
3. Check existing at: {OUTPUT_PATH}
4. Create or revise persona following template
5. Extract information: purpose, responsibilities, strengths, needs, style, workflows, integration points, commands, metrics
6. Write to output path

**Output**:
Report:
- Status: CREATED / REVISED (changes: list key updates) / NO CHANGES NEEDED
- Word count
- Path written to

**Style Notes**:
- Match tone of existing personas in project-management/personas/agents/ and project-management/personas/
- Use agent-specific terminology from source docs
- Be concise but comprehensive
- Focus on practical value and integration

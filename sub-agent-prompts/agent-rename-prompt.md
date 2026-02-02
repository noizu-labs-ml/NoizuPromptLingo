# Agent Renaming & Documentation Task

## Overview
You are responsible for renaming one NPL agent to use the "npl-" prefix and creating/updating its documentation.

## Your Responsibilities

1. **Rename Agent File**
   - Read the agent file from path provided in task description
   - Rename it with "npl-" prefix
   - Update `name:` field in YAML frontmatter
   - Update `agent_id:` field in YAML block
   - Keep all other content identical

2. **Create Persona Documentation**
   - Create project-management/personas/agents/npl-[AGENT_NAME].md
   - Extract information from the agent definition
   - Follow the structure below

3. **Update Documentation References**
   - Update only the files specified in task description
   - Replace [OLD_NAME] with npl-[OLD_NAME]
   - Preserve all formatting and context
   - Pay special attention to Mermaid diagrams (update node labels only, not syntax)

## Persona Documentation Template

```markdown
# Agent Persona: [Agent Name from File]

**Agent ID**: npl-[agent-name]
**Type**: [Extract from agent definition or use appropriate type]
**Version**: 1.0.0

## Overview
[1-3 sentences describing the agent's purpose, extracted from the agent definition file]

## Role & Responsibilities
[Extract and format key responsibilities from agent file as bullet points]

## Strengths
✅ [Key capability 1]
✅ [Key capability 2]
[Extract all relevant strengths from agent file]

## Needs to Work Effectively
- [Requirement 1]
- [Requirement 2]
[Extract all requirements from agent file]

## Typical Workflows
1. **[Workflow Name]** - [Description]
[Extract common usage patterns]

## Integration Points
- **Receives from**: [Input sources - extract from agent file]
- **Feeds to**: [Output destinations - extract from agent file]
- **Coordinates with**: [Other agents it works with]

## Success Metrics
- **[Metric Category]** - [Measurement criteria from agent file]

## Key Commands/Patterns
```bash
# Include example invocations from agent file if any
```

## Limitations
- [Any constraints mentioned in agent file]
```

## Critical Notes

- Do NOT create new files or directories; they already exist
- Do NOT modify any files other than those specified in the task description
- Preserve exact formatting (especially in code blocks and Mermaid diagrams)
- Verify that `name:` and `agent_id:` fields match the new filename after renaming
- For Mermaid diagrams: Only update node identifiers/labels, not syntax or structure
- Update mermaid diagram node references: If a diagram shows "idea-to-spec", change to "npl-idea-to-spec"

## Validation Checklist

Before completing:
- [ ] Agent file renamed with npl- prefix
- [ ] name: field matches new name (npl-*)
- [ ] agent_id: field matches new name (npl-*)
- [ ] Persona documentation created with correct filename
- [ ] All assigned doc files updated with npl- prefix
- [ ] No broken references in updated files
- [ ] Mermaid diagram syntax preserved (only labels changed)
- [ ] File format preserved (markdown formatting, code blocks, etc.)

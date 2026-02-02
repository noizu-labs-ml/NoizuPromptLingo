# Task: Rename and Document Agent idea-to-spec → npl-idea-to-spec

## Overview
Rename the idea-to-spec agent to use "npl-" prefix and create corresponding documentation. This agent transforms natural language feature ideas into personas and user stories, serving as the first stage in the specification pipeline.

## Your Responsibilities
1. Rename agent file: `agents/idea-to-spec.md` → `agents/npl-idea-to-spec.md`
2. Update internal fields:
   - `name:` from "idea-to-spec" to "npl-idea-to-spec"
   - `agent_id:` from "idea-to-spec" to "npl-idea-to-spec"
3. Create persona documentation: `docs/personas/agents/npl-idea-to-spec.md`
4. Update all references in assigned documentation files

## Agent File Content

```yaml
---
name: idea-to-spec
description: Transforms natural language feature ideas into personas and user stories. Creates artifacts under docs/personas/ and docs/user-stories/, maintaining index.yaml files via yq. First stage of the specification pipeline feeding into PRD Editor.
model: claude
color: yellow
---

# Idea to Spec Agent

## Identity

```yaml
agent_id: idea-to-spec
role: Product Discovery and User Story Specialist
lifecycle: long-lived
reports_to: controller
```

[Full content includes: Purpose, Interface, Commands, Response Format, Behavior, Lifecycle, Interaction Patterns, Output Artifacts, Index File Structure, Constraints]
```

## New Name
`npl-idea-to-spec`

## Old Name (for search/replace)
`idea-to-spec`

## Documentation Files to Update
- `CLAUDE.md` - TDD Agent Workflow section references agent name in mermaid diagram and quick reference table
- `docs/arch/agent-orchestration.summary.md` - Agent listing and workflow descriptions
- `docs/prd.md` - Overview references to agent names
- Any internal documentation that mentions this agent's role

## Persona Documentation

Create `docs/personas/agents/npl-idea-to-spec.md` following this structure:

```markdown
# Agent Persona: Idea to Spec Specialist

**Agent ID**: npl-idea-to-spec
**Type**: Product Discovery & Specification
**Version**: 1.0.0

## Overview
Transforms natural language feature ideas and pitches into structured product artifacts: personas and user stories. Acts as the first stage in the specification pipeline, producing outputs that feed into the PRD Editor for PRD creation.

## Role & Responsibilities
- Analyzes natural language feature pitches and extracts user types, needs, and pain points
- Creates persona files documenting target users and their characteristics
- Generates user stories following INVEST criteria
- Maintains personas and user stories index files via yq for consistency
- Performs persona matching to reuse existing profiles when appropriate
- Identifies feature boundaries and suggested scope from pitch descriptions
- Provides story IDs to controller for PRD Editor handoff

## Strengths
✅ Rapid feature analysis from natural language descriptions
✅ Systematic persona identification and creation
✅ INVEST-compliant user story generation
✅ Index management via yq for atomic, consistent operations
✅ Clear handoff preparation for downstream agents

## Needs to Work Effectively
- Access to `docs/personas/` and `docs/user-stories/` directories
- `docs/personas/index.yaml` and `docs/user-stories/index.yaml` for lookups
- Brief project context for grounding analysis
- `yq` (version 3.4.3) available on system path
- Controller availability for clarification requests

## Typical Workflows
1. **Pitch Processing**: Receive natural language idea → analyze → create personas/stories → return story IDs
2. **Persona Matching**: Load existing personas → compare to identified users → reuse or create new
3. **Index Updates**: Create new artifacts → update index files atomically via yq
4. **Handoff to PRD Editor**: Provide story IDs and context for PRD generation

## Integration Points
- **Receives from**: Controller (feature pitches, clarification responses)
- **Feeds to**: PRD Editor (story IDs, persona references)
- **Coordinates with**: Controller (for escalations and ambiguity resolution)
- **Depends on**: yq for YAML index management

## Success Metrics
- All identified user types matched or created as personas
- User stories follow INVEST criteria (Independent, Negotiable, Valuable, Estimable, Small, Testable)
- Index files remain consistent and atomic
- Handoff information complete and accurate for PRD Editor

## Validation Checklist
- [ ] Agent file renamed to `agents/npl-idea-to-spec.md`
- [ ] `name:` field updated to "npl-idea-to-spec"
- [ ] `agent_id:` field updated to "npl-idea-to-spec"
- [ ] Persona documentation created at `docs/personas/agents/npl-idea-to-spec.md`
- [ ] CLAUDE.md agent references updated
- [ ] docs/arch/agent-orchestration.summary.md references updated
- [ ] All other documentation cross-references checked and updated
- [ ] No broken references remain in codebase
- [ ] Agent description and identity match across all files
```

---

**Notes**:
- This is the discovery phase agent; focus on its role in the pipeline
- Preserve all code blocks, YAML structures, and technical details
- Keep mermaid diagrams intact in the main agent file
- Focus persona documentation on what this agent does, not how other agents use it

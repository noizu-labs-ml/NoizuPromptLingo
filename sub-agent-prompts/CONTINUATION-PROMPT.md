# Continuation Prompt: Complete Agent Persona Population

## Current Status
- ✅ Created 11 core agent personas in `project-management/personas/agents/`
- ⏳ Need to complete remaining core agents (5 more)
- ⏳ Need to create group persona for tasker agents
- ⏳ Need to process worktrees/main/docs additional agents
- ⏳ Need to process worktrees/main/docs/** for other personas

## Tasker-Based Execution Strategy

**Use tasker-sonnet agents for all persona creation work**. Do NOT process these files manually. Instead:

1. **For Each Batch**: Launch tasker-sonnet agent with this instruction set
2. **Agent Responsibility**: Read source files (`.md` + `.detailed.md` pairs), extract key information, create persona files in `project-management/personas/agents/`
3. **Tasker Instructions Template**:
   ```
   Read [SOURCE_FILES] and create [PERSONA_FILE] in project-management/personas/agents/
   following the template provided. Extract:
   - Purpose and responsibilities
   - Key capabilities and strengths
   - Required inputs/dependencies
   - Communication style
   - Typical workflows
   - Integration points with other agents
   - Domain-specific sections relevant to agent type
   Keep output 1-2 pages maximum.
   ```
4. **Execute Batches Incrementally**: Launch ONE tasker per batch. When complete, review and launch next batch rather than batching all at once.
5. **Output Verification**: Each tasker should report which files were created/updated in `project-management/personas/agents/`

**Reference Materials Available to Taskers**:
- `.tmp/NPL-COMPREHENSIVE-BRIEF.md` - Full framework summary
- `.tmp/docs/agents/summary.brief.md` - Core agents context
- `.tmp/docs/additional-agents/summary.brief.md` - Additional agents context
- Source files in `worktrees/main/docs/agents/` and `worktrees/main/docs/additional-agents/`

## Remaining Work

### Phase 1: Complete Core Agent Personas (11/16 Done)

**Already Created**:
1. ✅ gopher-scout.md
2. ✅ npl-thinker.md
3. ✅ npl-grader.md
4. ✅ npl-technical-writer.md
5. ✅ npl-author.md
6. ✅ tdd-driven-builder.md
7. ✅ npl-qa.md
8. ✅ npl-fim.md
9. ✅ nimps.md
10. ✅ npl-system-digest.md
11. ✅ npl-threat-modeler.md

**Still Needed** (5 more):
- npl-persona.md (Collaboration & role-playing)
- npl-prd-manager.md (PRD lifecycle management)
- npl-templater.md (Template creation and hydration)
- npl-marketing-writer.md (Marketing content specialist)
- npl-tool-forge.md (Custom tool creation)

**Plus Group Persona**:
- tasker-agents.md (Group: all tasker-* agents as single entry)

### Phase 2: Create Additional Agent Personas

From `worktrees/main/docs/additional-agents/` (23 agents across 6 categories):

**Infrastructure (3)**:
- npl-build-manager.md
- npl-code-reviewer.md
- npl-prototyper.md

**Project Management (4)**:
- npl-project-coordinator.md
- npl-risk-monitor.md
- npl-user-impact-assessor.md
- npl-technical-reality-checker.md

**Quality Assurance (4)**:
- npl-tester.md
- npl-benchmarker.md
- npl-integrator.md
- npl-validator.md

**User Experience (4)**:
- npl-user-researcher.md
- npl-accessibility.md
- npl-performance.md
- npl-onboarding.md

**Marketing (4)**:
- npl-positioning.md
- npl-marketing-copy.md
- npl-conversion.md
- npl-community.md

**Research (4)**:
- npl-research-validator.md
- npl-performance-monitor.md
- npl-cognitive-load-assessor.md
- npl-claude-optimizer.md

### Phase 3: Create Other Doc-Based Personas

From `worktrees/main/docs/**`:
- Commands persona (for slash commands: init-project, update-arch, etc.)
- MCP Tools persona (for FastMCP tool set)
- CLI Scripts persona (for npl-load, npl-persona, npl-session, etc.)

## Template for Agent Personas

```markdown
# Agent Persona: [Agent Name]

**Agent ID**: [agent-id]
**Type**: [Category: Discovery, Content, Implementation, Planning, Security, etc.]
**Version**: 1.0.0

## Overview
[2-3 sentence description of agent's purpose and approach]

## Role & Responsibilities
- [Responsibility 1]
- [Responsibility 2]
- [etc.]

## Strengths
✅ [Strength 1]
✅ [Strength 2]
[etc.]

## Needs to Work Effectively
- [Need 1]
- [Need 2]
[etc.]

## Communication Style
- [Style aspect 1]
- [Style aspect 2]
[etc.]

## Typical Workflows
1. [Workflow 1] - Description
2. [Workflow 2] - Description
[etc.]

## Integration Points
- **Receives from**: [Agent names or data sources]
- **Feeds to**: [Agent names or destinations]
- **Coordinates with**: [Related agents]

## Key Commands/Patterns
```
@agent-name command --param=value
```

## Success Metrics
- [Metric 1]
- [Metric 2]
[etc.]

## [Domain-Specific Sections]
[Additional details specific to agent type]
```

## Instructions for Tasker Agents

### Batch 1 - Create 5 Remaining Core Agents + Tasker Group (Tasker-Sonnet)

**Task**: Create 6 agent persona files in `project-management/personas/agents/`

**Source Files**:
- `worktrees/main/docs/agents/npl-persona.md` + `npl-persona.detailed.md`
- `worktrees/main/docs/agents/npl-prd-manager.md` + `npl-prd-manager.detailed.md`
- `worktrees/main/docs/agents/npl-templater.md` + `npl-templater.detailed.md`
- `worktrees/main/docs/agents/npl-marketing-writer.md` + `npl-marketing-writer.detailed.md`
- `worktrees/main/docs/agents/npl-tool-forge.md` + `npl-tool-forge.detailed.md`
- `worktrees/main/docs/agents/tasker-*.md` (all tasker agent files for group persona)

**Process**:
1. Read each `.md` + `.detailed.md` pair together (consolidate information)
2. Extract key information:
   - Purpose and responsibilities
   - Key capabilities and strengths
   - What the agent needs to work effectively
   - Communication style and typical workflows
   - Integration with other agents
3. Create persona file following the template provided above
4. Add 2-3 domain-specific sections relevant to agent type
5. Save each to `project-management/personas/agents/{agent-name}.md`
6. For tasker group: Create single `project-management/personas/agents/tasker-agents.md` representing all tasker-* variants as one entry

**Output**: 6 files created in `project-management/personas/agents/`

### Batches 2-9 - Additional Agents (Tasker-Sonnet per Batch)

**Pattern**: Same as Batch 1, but source from `worktrees/main/docs/additional-agents/{category}/{agent-name}.md` + `.detailed.md`

**Group Personas** (Batch 9 only):
- **commands.md** - Combine slash commands (init-project, update-arch, update-layout, init-project-fast)
- **mcp-tools.md** - MCP tool collection
- **cli-scripts.md** - CLI scripts (dump-files, git-tree, npl-load, npl-persona, npl-session, etc.)

## Batch Processing Strategy (Tasker-Driven)

Launch tasker-sonnet agents ONE BATCH AT A TIME (incrementally, not all at once):

1. **Batch 1 - Tasker**: Create 5 remaining core agents + tasker group (7 files)
   - Source: `worktrees/main/docs/agents/{npl-persona,npl-prd-manager,npl-templater,npl-marketing-writer,npl-tool-forge}.md` + `.detailed.md`
   - Output: 6 personas in `project-management/personas/agents/`

2. **Batch 2 - Tasker**: Create tasker group persona
   - Source: `worktrees/main/docs/agents/tasker*.md`
   - Output: `project-management/personas/agents/tasker-agents.md`

3. **Batch 3 - Tasker**: Infrastructure agents (3)
   - Source: `worktrees/main/docs/additional-agents/infrastructure/*.md`
   - Output: 3 personas

4. **Batch 4 - Tasker**: Project Management agents (4)
   - Source: `worktrees/main/docs/additional-agents/project-management/*.md`
   - Output: 4 personas

5. **Batch 5 - Tasker**: Quality Assurance agents (4)
   - Source: `worktrees/main/docs/additional-agents/qa/*.md`
   - Output: 4 personas

6. **Batch 6 - Tasker**: User Experience agents (4)
   - Source: `worktrees/main/docs/additional-agents/ux/*.md`
   - Output: 4 personas

7. **Batch 7 - Tasker**: Marketing agents (4)
   - Source: `worktrees/main/docs/additional-agents/marketing/*.md`
   - Output: 4 personas

8. **Batch 8 - Tasker**: Research agents (4)
   - Source: `worktrees/main/docs/additional-agents/research/*.md`
   - Output: 4 personas

9. **Batch 9 - Tasker**: Group personas (3)
   - Sources: commands, MCP tools, CLI scripts docs
   - Output: `commands.md`, `mcp-tools.md`, `cli-scripts.md`

10. **Batch 10 - Manual**: Update `project-management/personas/index.yaml` with all new entries (P-100+)

## Output Location

All persona files go to: `project-management/personas/agents/`

Directory structure after completion:
```
project-management/personas/
├── agents/
│   ├── [11 existing core agents].md
│   ├── [5 remaining core agents].md
│   ├── tasker-agents.md (group)
│   ├── [23 additional agents].md
│   ├── commands.md (group)
│   ├── mcp-tools.md (group)
│   └── cli-scripts.md (group)
├── [existing human personas].md
├── control-agent.md
├── sub-agent.md
└── index.yaml (NEEDS UPDATE)
```

## Next Steps After Completion

1. Update `project-management/personas/index.yaml` with all new agent entries (IDs P-100+)
2. Create `project-management/personas/index.yaml` structure for agents (separate section or linked directory)
3. Verify all cross-references work
4. Create summary document: `project-management/personas/AGENT-PERSONAS-INDEX.md`

## Key Considerations

- Treat `.md` + `.detailed.md` pairs together (consolidate information)
- Maintain consistent voice across all personas
- Each persona should be self-contained but reference integration points
- Keep persona files concise (1-2 pages maximum)
- Focus on "why this agent exists" and "how to work with it"
- Extract key workflows and patterns for reproducibility

## Files to Reference

- `.tmp/NPL-COMPREHENSIVE-BRIEF.md` - Full framework summary
- `.tmp/docs/agents/summary.brief.md` - Core agents overview
- `.tmp/docs/additional-agents/summary.brief.md` - Additional agents overview
- `worktrees/main/docs/agents/*.md` - Primary agent docs
- `worktrees/main/docs/additional-agents/**/*.md` - Additional agent docs

## How to Execute This Plan

**Launch tasker-sonnet for Batch 1**:
```
Task tool → subagent_type: tasker-sonnet
Prompt:
"Read the 5 core agents and tasker files from worktrees/main/docs/agents/,
extract key information from .md + .detailed.md pairs, and create 6 agent
persona files in project-management/personas/agents/ following the provided template.
Return list of files created and brief summary of each persona."

Reference materials available:
- .tmp/NPL-COMPREHENSIVE-BRIEF.md
- .tmp/docs/agents/summary.brief.md
- Existing personas in project-management/personas/agents/ (for style reference)
```

**Then**:
- Review tasker output
- Verify files created in `project-management/personas/agents/`
- Launch Batch 2 tasker for next set of agents
- Continue incremental batching until all 9 batches complete

**Final Step**:
- Manually update `project-management/personas/index.yaml` with all P-100+ entries
- Create `project-management/personas/AGENT-PERSONAS-INDEX.md` summary

---

**Status**: Ready for Batch 1 tasker execution
**Estimated Total Files**: 46 agent personas + 4 group personas (50 total)
**Target**: Complete agent persona ecosystem in `project-management/personas/agents/`

# Prompts Summary

## Overview
Comprehensive collection of prompt templates, agent definitions, and sub-agent prompts organized for reuse and parallel agent execution. Prompts serve as the "code" for agent behavior, enabling consistent, composable workflows.

## Prompt Categories

### 1. Sub-Agent Prompts
**Location**: `./sub-agent-prompts/` (project root or `.tmp/`)

Reusable prompt templates for batch processing and parallel agent invocation.

**Purpose**:
- Define shared instructions used by multiple agents
- Enable DRY principle: write instructions once, use N times
- Reduce token usage in parallel execution
- Standardize output format across agents

**File Naming**:
- `{task-name}.md` - Template for specific task
- `{task-name}-v{N}.md` - Versioned templates

**Example Structure**:
```
./sub-agent-prompts/
├── batch-processor.md                    # Generic batch processing
├── user-story-generator.md               # Generate user stories
├── code-review-checklist.md              # Code review template
├── test-generator.md                     # Test generation
└── shared-instructions.md                # Shared across all
```

### 2. Agent Definitions
**Location**: `worktrees/main/core/agents/`, `docs/personas/agents/`

Full agent persona definitions with capabilities, constraints, and integration patterns.

**Content**:
- Purpose and responsibilities
- Available tools and permissions
- Communication protocols
- Integration with other agents
- Example invocation patterns
- Known limitations

### 3. CLAUDE.md Instructions
**Location**: Project root `CLAUDE.md`

Claude Code-specific instructions embedded in repository. Updated via `npl-load init-claude`.

**Sections**:
- Scratchpad directory rules
- Development commands (uv, mise)
- YAML index management (yq)
- High-level architecture
- Development workflow
- Heavy parallelization patterns
- Testing & TDD practices

### 4. Framework Personas
**Location**: `.npl/personas/`, `docs/personas/`

Persistent persona definitions for simulated identities.

**Types**:
- Team members (developers, managers)
- Specialized personas (security, performance, UX)
- AI agent personas
- Domain expert personas

**Structure per Persona**:
- `.persona.md` - Definition (role, background, expertise)
- `.journal.md` - Experience log (learnings, decisions)
- `.tasks.md` - Active work items
- `.knowledge-base.md` - Accumulated knowledge

## Sub-Agent Prompt Best Practices

### Pattern: Batch Processing with Template

**Step 1: Create Reusable Template**
```markdown
# Batch Processing Template

Read shared instructions at ./sub-agent-prompts/shared-instructions.md

For each item in your batch:
1. Extract data from source
2. Create output file following conventions
3. Prepare metadata entry

## Quality Checklist
- [ ] Output follows format spec
- [ ] Metadata complete
- [ ] References correct

Your specific batch details are in the task description.
```

**Step 2: Test with Single Agent**
```python
Task(
  description="Test batch 1 (items 1-5) from data-source.csv",
  subagent_type="npl-tasker-sonnet"
)
```

Verify:
- ✓ Output format correct
- ✓ All quality checks pass
- ✓ Metadata properly formatted

**Step 3: Spawn Parallel Agents**
```python
Task(..., description="Process batch 1 (items 1-5)")    # parallel
Task(..., description="Process batch 2 (items 6-10)")   # parallel
Task(..., description="Process batch 3 (items 11-15)")  # parallel
```

### Pattern: Shared Instructions File

**shared-instructions.md**:
```markdown
# Shared Instructions

## Output Format
- Use Markdown for all text files
- YAML for structured data
- Respect naming conventions: {entity}_{action}.{ext}

## Metadata Requirements
- Include: author, date, version, source
- Format: YAML frontmatter

## Quality Standards
- No typos or grammar issues
- Consistent terminology
- Complete cross-references

## Common Abbreviations
- US = User Story
- PR = Product Requirements
- TDD = Test-Driven Development
```

## Prompt Generation & Management

### Version Control for Prompts
```
# Versioning strategy
prompts/
├── agent-checklist-v1.md   # Initial version
├── agent-checklist-v2.md   # Refinement (more specific)
└── agent-checklist-v3.md   # Final (tested with 5+ agents)

# Archive old versions
prompts/archived/
└── agent-checklist-v1.md.bak
```

### Prompt Maintenance Workflow

1. **Create Draft**: Write initial template
2. **Test Single Agent**: Run with one agent, collect feedback
3. **Refine**: Update template based on test results
4. **Document Changes**: Update version notes
5. **Parallel Test**: Run with small batch (3-5 agents)
6. **Scale**: Deploy to full parallel batch

### Quality Checklist for Prompts

- [ ] Purpose is clear and specific
- [ ] Instructions are step-by-step and unambiguous
- [ ] Success criteria clearly defined
- [ ] Examples provided where helpful
- [ ] Edge cases addressed
- [ ] Format specifications detailed
- [ ] Dependencies listed
- [ ] Integration points noted
- [ ] Tested with multiple agents
- [ ] Version tracked

## Integration with Agent Invocation

### Loading Prompt Template
```python
# Agent reads template from shared location
agent_prompt = read_prompt("./sub-agent-prompts/user-story-generator.md")

# Agent appends task-specific details
full_prompt = agent_prompt + f"\nYour batch: items {start}-{end}"

Task(description=full_prompt, subagent_type="npl-idea-to-spec")
```

### Parallel Invocation with Shared Template
```python
# All agents use same base template, different parameters
template = read_prompt("./sub-agent-prompts/batch-processor.md")

for batch_num in range(1, num_batches + 1):
  start = (batch_num - 1) * batch_size + 1
  end = batch_num * batch_size

  Task(
    description=f"{template}\n\nBatch {batch_num}: items {start}-{end}",
    subagent_type="npl-tasker-sonnet"
  )
```

## Prompt Organization by Workflow Phase

### Phase 1: Discovery
- Prompts for persona extraction
- Prompts for user story generation
- Prompts for pain point identification

### Phase 2: Specification
- Prompts for PRD structure validation
- Prompts for requirement decomposition
- Prompts for acceptance criteria generation

### Phase 3: Testing
- Prompts for test case generation
- Prompts for edge case identification
- Prompts for fixture/mock creation

### Phase 4: Implementation
- Prompts for code skeleton generation
- Prompts for function-level implementation
- Prompts for integration patching

### Phase 5: Debugging
- Prompts for failure analysis
- Prompts for root cause diagnosis
- Prompts for fix verification

## Special Prompt Types

### Checklist Prompts
Used for validation, review, audit tasks.

```markdown
## Code Review Checklist

- [ ] Tests present and passing
- [ ] No console logs
- [ ] No commented-out code
- [ ] Follows naming conventions
- [ ] Performance reasonable
- [ ] Accessibility considered
- [ ] Security reviewed
```

### Chain-of-Thought Prompts
Used for complex reasoning and analysis.

```markdown
## Think Step-by-Step

1. First, identify the problem context
2. Consider alternative approaches
3. Analyze tradeoffs for each
4. Recommend best approach with rationale
5. List implementation steps
```

### Template-Fill Prompts
Used for consistent document generation.

```markdown
## PRD Template Fill

Complete each section:
- **Product Name**: [...]
- **Target Users**: [...]
- **Core Problem**: [...]
- **Solution**: [...]
- **Success Metrics**: [...]
```

## Prompt Storage & Access

### Project-Local Prompts
```
.tmp/sub-agent-prompts/
├── task-1.md
└── task-2.md
```

Access via:
```python
read_prompt(".tmp/sub-agent-prompts/task-1.md")
```

### User-Level Prompts
```
~/.npl/prompts/
├── personal-agents/
├── reusable-templates/
└── archived/
```

Access via:
```python
read_prompt("~/.npl/prompts/reusable-templates/template.md")
```

### System-Level Prompts
```
/etc/npl/prompts/ (or $NPL_HOME/prompts/)
├── standard-templates/
└── core-agents/
```

Access via:
```bash
npl-load p "standard-templates/batch-processor" --skip ""
```

## Key Principles

1. **DRY**: Write instructions once, reuse many times
2. **Versioning**: Track prompt evolution and improvements
3. **Modularity**: Separate shared from task-specific
4. **Clarity**: Unambiguous, step-by-step instructions
5. **Consistency**: Same format across agents
6. **Testability**: Validate with agents before scaling
7. **Discoverability**: Clear naming and organization
8. **Maintainability**: Easy to update and iterate

## Integration with NPL Systems

### with npl-load
```bash
# Load agent prompt definitions
npl-load agent npl-gopher-scout --definition

# Load personas with prompts
npl-load m "persona.qa-engineer"
```

### with Session Management
```bash
# Prompt history logged in worklog
npl-session log --agent=coder-001 --action=prompt_executed

# Prompts stored in session artifacts
.npl/sessions/YYYY-MM-DD/tmp/agent-id/prompt.summary.md
```

### with Task Orchestration
```python
# Task description often IS the prompt
Task(description=prompt_content, subagent_type=agent)
```

## Notes
- Prompts are code: treat them with version control discipline
- Test prompts with small batches before full parallelization
- Document prompt improvements and share learnings
- Archive old versions for reference and learning
- Combine templates for complex multi-step workflows
- Use consistent terminology across all prompts

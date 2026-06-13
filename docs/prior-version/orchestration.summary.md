# Agent Orchestration Summary

## Overview
NPL implements a sophisticated multi-agent orchestration system that transforms feature ideas into tested, production-ready code through specialized agents working in coordinated workflows.

## Primary TDD Workflow

```
flowchart LR
    A[💡 npl-idea-to-spec] --> B[📝 npl-prd-editor]
    B --> C[🧪 npl-tdd-tester]
    C --> D[⚙️ npl-tdd-coder]
    D --> E{Tests Pass?}
    E -->|No| F[🔍 npl-tdd-debugger]
    F -->|Fix tests| C
    F -->|Clarify PRD| B
    F -->|Fix code| D
    E -->|Yes| G[✅ Complete]

    style A fill:#e1f5ff
    style B fill:#fff4e1
    style C fill:#e1ffe1
    style D fill:#ffe1ff
    style F fill:#ffe1e1
    style G fill:#e1ffe1
```

## Agent Roles & Responsibilities

### Phase 1: Discovery (npl-idea-to-spec)
**Input**: Feature idea/description
**Output**: Personas, user stories

- Creates detailed personas from user description
- Extracts user stories organized by journey phases
- Builds relationship metadata
- Artifacts: `docs/personas/`, `docs/user-stories/`

### Phase 2: Specification (npl-prd-editor)
**Input**: User stories, personas
**Output**: Comprehensive PRD

- Generates main PRD file (200-400 lines max)
- Creates sub-files when sections exceed thresholds
- Ensures SMART requirements (Specific, Measurable, Achievable, Relevant, Traceable)
- Monitors section lengths and splits dynamically
- Artifacts: `docs/PRDs/PRD.md`, `docs/PRDs/<sub-files>`

### Phase 3: Test Creation (npl-tdd-tester)
**Input**: PRD specifications
**Output**: Comprehensive test suites

- Generates test structure based on PRD
- Creates unit, integration, and acceptance tests
- Iteratively refines tests based on feedback
- Artifacts: `tests/<module>_test.py`, etc.

### Phase 4: Implementation (npl-tdd-coder)
**Input**: PRD + test suite
**Output**: Source code implementation

- Autonomous implementation using TDD cycle
- Monitors test status via `mise run test-status`
- Gets detailed failures via `mise run test-errors`
- Reports blockers for routing to debugger
- Artifacts: `src/<implementation>`, code changes

### Phase 5: Debug Loop (npl-tdd-debugger)
**Triggered When**: Tests fail or implementation blocked
**Responsibilities**:
- Execute test suites with `mise run test-status`
- Analyze failure details with `mise run test-errors`
- Route issues to appropriate agent:
  - Test failures → route back to npl-tdd-coder
  - Specification ambiguity → route to npl-prd-editor
  - Test inadequacy → route to npl-tdd-tester
- Provide actionable debugging information

## Command-and-Control Modes

| Mode | Behavior | Use When |
|:-----|:---------|:---------|
| `lone-wolf` | Work independently; no sub-agent delegation | Need focused effort on single task |
| `team-member` | Suggest sub-agents for obvious parallel work | Complex features with natural parallelization |
| `task-master` | Aggressively parallelize; push to sub-agents | Large batch work, parallel processing needed |

## Work-Log & Session Management

### Session Directory Structure
```
.npl/sessions/YYYY-MM-DD/
├── meta.json                      # Session metadata
├── worklog.jsonl                  # Append-only entry log (shared)
├── .cursors/
│   ├── explore-codebase-001.cursor
│   ├── coder-001.cursor
│   └── debugger-001.cursor
└── tmp/
    ├── explore-codebase-001/
    │   ├── findings.summary.md
    │   ├── findings.detailed.md
    │   └── findings.yaml
    ├── coder-001/
    │   └── implementation.summary.md
    └── debugger-001/
        └── diagnostics.summary.md
```

### Interstitial Files

**Agent writes to**: `tmp/<agent-id>/`

| File | Purpose | When Generated |
|:-----|:---------|:----------------|
| `<task>.summary.md` | High-level findings; references detailed file headings | Always |
| `<task>.detailed.md` | Full content with `##` headings matching summary refs | Always |
| `<task>.yaml` | Structured data (JSON/YAML format) | When `@work-log=verbose` or `@work-log=yaml|*` |

**Reading Pattern**:
1. Reader fetches agent's `.summary.md` first
2. For details, reader fetches specific `##` sections from `.detailed.md`
3. Structured data read from `.yaml` if needed

### Worklog Communication

**Entry Schema** (each line is JSON):
```json
{
  "timestamp": "ISO-8601",
  "agent": "<agent-id>",
  "action": "<action-type>",
  "summary": "<brief description>",
  "details": "<longer context>",
  "metadata": {<additional fields>}
}
```

**Agent Operations**:
```bash
# Write entry
npl-session log --agent=explore-001 --action=found --summary="Located auth module"

# Read new entries since cursor
npl-session read --agent=primary

# Peek without advancing cursor
npl-session read --agent=primary --peek

# Fetch specific session
npl-session current
```

## Parallel Execution Patterns

### Pattern: Batch Processing Template

**Template**: `.tmp/sub-agent-prompts/batch-processor.md`
```markdown
# Batch Processing Template

Read instruction prompt at .tmp/sub-agent-prompts/shared-instructions.md

For each item in your batch:
1. Extract data from source
2. Create output file following conventions
3. Prepare metadata entry

Your specific batch details will be in the task description.
```

**Parallel Invocation**:
```
Task 1: "Process batch 1 (items 1-5)"
Task 2: "Process batch 2 (items 6-10)"
Task 3: "Process batch 3 (items 11-15)"
```

**Benefits**:
- DRY principle - instructions written once
- Consistency - all agents follow identical patterns
- Quality - single template validated upfront
- Scalability - easily spawn 10+ agents
- Efficiency - fewer tokens on repetition

## Heavy Parallelization Best Practices

### Best Practice 1: Reusable Prompt Templates
- Save shared prompt logic to `./sub-agent-prompts/{task-name}.md`
- Include quality checklist, expected outputs, format specs
- Reference from individual agent task descriptions

### Best Practice 2: Test Single Agent First
- Spawn ONE agent with template
- Verify output quality and format
- Adjust template based on results
- Create sample output for reference

### Best Practice 3: Spawn Remaining Agents
- Use tested template with different parameters
- All agents use base instructions, different context
- Monitor completion via session worklog
- Collect and aggregate results

### Example: User Story Generation

1. **Create template** → `.tmp/sub-agent-prompts/user-story-generator.md`
2. **Test** → Spawn 1 agent, validate output
3. **Scale** → Spawn N agents with different story ranges
4. **Aggregate** → Collect and merge all generated stories

## Extension Points

### Custom Agents
New agents follow the same patterns:
- Defined in `worktrees/main/core/agents/`
- Registered via `npl-load agent <name>`
- Integrate via Task tool invocation
- Communicate via session worklog

### Workflow Extensions
- Inject specialized agents at any phase
- Create new phase workflows beyond TDD
- Combine with existing validation agents
- Build domain-specific orchestrations

## Monitoring & Health

### Session Health
```bash
npl-session status                    # Current session stats
npl-session status --json             # Machine-readable format
npl-session list --all                # All sessions
```

### Agent Health
Agents maintain health via:
- Regular heartbeats to worklog
- Error reporting and recovery
- Task completion tracking
- Knowledge base health checks

### Debugging Multi-Agent Workflows

**Issue**: Agent A blocked waiting for Agent B
```bash
# Check agent B's cursor position
cat .npl/sessions/YYYY-MM-DD/.cursors/agent-b.cursor

# Read agent B's recent worklog entries
npl-session read --agent=agent-b --peek

# Check detailed output
cat .npl/sessions/YYYY-MM-DD/tmp/agent-b/*.detailed.md
```

## Key Principles

1. **Autonomy**: Agents work independently with clear context
2. **Specialization**: Each agent has focused responsibility
3. **Communication**: Shared worklog enables async coordination
4. **Composability**: Agents chain and coordinate naturally
5. **Observability**: Full session history for debugging
6. **Scalability**: Easily parallelize similar tasks
7. **Extensibility**: Add new agents without modifying core

## Integration with TDD

**Full Cycle**:
1. → Idea to spec (personas, stories)
2. → PRD generation (full specification)
3. → Test generation (comprehensive test suite)
4. → Implementation (autonomous coding)
5. → Debug loop (if needed, refine and retry)
6. → Completion (all tests passing)

**Key Commands**:
- `mise run test-status` - Quick pass/fail check
- `mise run test-errors` - Detailed failure output
- `mise run test-coverage` - Coverage report

## Notes
- Agents communicate asynchronously via worklog
- Each agent maintains independent cursor for scalability
- Sessions persist for full debugging context
- Workflows can be archived for future reference
- Parallel agents scale linearly with task granularity

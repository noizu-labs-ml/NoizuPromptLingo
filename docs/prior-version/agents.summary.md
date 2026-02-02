# Core Agents Summary

**Location**: `worktrees/main/core/agents/`

## Overview
Collection of specialized AI agent personas designed to handle specific aspects of the NPL (Noizu Prompt Lingo) development workflow. Each agent has a focused responsibility and can be invoked independently or as part of orchestrated workflows.

## Primary Core Agents

### TDD Workflow Agents
- **npl-tdd-coder** - Autonomous implementation agent; accepts PRDs and implements until complete using `mise run test-status`
- **npl-tdd-tester** - Test creation agent; generates comprehensive test suites based on PRD specifications
- **npl-tdd-debugger** - Debug/diagnostics agent; analyzes test failures and routes fixes to appropriate agents

### Discovery & Analysis Agents
- **npl-gopher-scout** - Reconnaissance and codebase exploration; identifies patterns, maps architecture, flags issues
- **npl-grader** - Validation and QA; runs edge case testing, quality checks
- **npl-fim** - Visualization agent for tool-task compatibility and artifact paths
- **npl-threat-modeler** - Security analysis; models threats and vulnerabilities

### Documentation & Planning Agents
- **npl-technical-writer** - PRD generation and documentation updates; ensures completeness and quality
- **npl-author** - Content creation and documentation polish
- **npl-project-coordinator** - Project planning; extracts dependency graphs, maps requirements to tasks
- **npl-prd-manager** - PRD lifecycle management and versioning

### Code & Infrastructure Agents
- **npl-build-master** - Build system and deployment pipeline management
- **npl-build-manager** - Infrastructure build automation
- **npl-sql-architect** - Database schema design and SQL optimization
- **npl-cpp-modernizer** - C++ code modernization and refactoring
- **npl-perf-profiler** - Performance profiling and optimization analysis

### Utility & Support Agents
- **npl-persona** - Persona management and lifecycle
- **npl-persona-manager** - Multi-persona team coordination
- **npl-thinker** - Complex reasoning and analysis
- **npl-templater** - Template generation and management
- **npl-marketing-writer** - Marketing content and messaging
- **npl-tasker** - Task and workflow management
- **nb** - Notebook/documentation utilities
- **nimps** - Specialized utility agent

## Agent File Structure
Each agent has:
- **{agent-name}.md** - Full agent definition with:
  - Purpose and responsibilities
  - Tools available
  - Communication protocols
  - Integration points
  - Example usage patterns
  - Limitations and constraints

## Key Characteristics
- **Specialized**: Each agent focuses on a specific domain or workflow
- **Autonomous**: Can work independently with clear instructions
- **Orchestrated**: Designed to work together in larger workflows
- **Tools-Aware**: Know which tools are available and how to use them
- **Debuggable**: Can diagnose failures and recommend next steps

## Invocation Pattern
```bash
# Via Task tool
Task(description="...", subagent_type="<agent-name>")

# Via npl-load
npl-load agent <agent-name> --definition
```

## Integration with TDD Workflow
```
💡 npl-idea-to-spec → 📝 npl-prd-editor → 🧪 npl-tdd-tester → ⚙️ npl-tdd-coder
                                                                    ↓
                                                          Tests Pass? →  ✅
                                                                    ↓
                                                              🔍 npl-tdd-debugger
                                                          (if failures)
```

## Notes
- Agent definitions include tool restrictions and capabilities
- Agents maintain state in `.npl/sessions/` for cross-agent communication
- Each agent logs work to shared worklog via `npl-session log`
- Agents read session entries via `npl-session read --agent=<id>`

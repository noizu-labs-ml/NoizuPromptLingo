# User Story: Share Architectural Context with Agents

**ID**: US-035
**Persona**: P-005 (Dave the Fellow Developer)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:20:00Z

## Story

As a **fellow developer**,
I want to **share architectural context and coding standards with agents**,
So that **they produce code that fits our patterns and conventions**.

## Acceptance Criteria

### Context Artifact Creation
- [ ] Can create context artifacts using `create_artifact` with type `markdown` or `yaml`
- [ ] Context artifacts support metadata tags: `scope` (project/module/task), `category` (standards/patterns/antipatterns/conventions)
- [ ] Context can be linked to specific tasks, modules (file paths), or sessions for scoping
- [ ] Context content follows standard markdown format with sections: Purpose, Standards, Patterns, Anti-patterns, Examples

### Context Loading & Application
- [ ] Agents can discover relevant context via `list_context_artifacts(scope?, category?)`
- [ ] Agents load context via `get_artifact(artifact_id)` and receive markdown/yaml content
- [ ] Agents acknowledge loaded context in work logs with format: "Loaded context: {artifact_name} (scope: {scope})"
- [ ] Context hierarchy applies: task-level overrides module-level overrides project-level

### Context Management
- [ ] Can update context by creating new revision via `add_revision(artifact_id, content_base64)`
- [ ] Context revisions include changelog notes explaining what changed
- [ ] Agents automatically use latest revision unless pinned to specific version
- [ ] Can pin task/module to specific context revision via metadata

### Effectiveness Tracking
- [ ] System tracks context usage: which artifacts were loaded per task
- [ ] Review comments can reference specific context violations with format: "Violates {context_artifact}#{section}"
- [ ] Can generate context effectiveness report: tasks with context loaded vs revision count, approval rate

## Technical Details

### Context Artifact Structure
```yaml
type: markdown  # or yaml
metadata:
  scope: "project" | "module" | "task"
  category: "standards" | "patterns" | "antipatterns" | "conventions"
  applies_to: "src/npl_mcp/**/*.py"  # glob pattern for module scope
  task_id: "task-uuid"  # for task scope
content:
  # Markdown format
  ## Purpose
  ## Coding Standards
  ## Architectural Patterns
  ## Anti-patterns to Avoid
  ## Examples
```

### Context Discovery Workflow
1. Agent starts task via `get_task(task_id)`
2. Agent discovers context via `list_context_artifacts(scope="task", task_id=task_id)`
3. Agent loads project-level context (if no task-specific)
4. Agent loads module-level context (if task specifies file paths)
5. Agent merges context (task > module > project precedence)
6. Agent logs loaded context in work log

### Integration with npl_load
- `npl_load` loads NPL core syntax/protocols (US-001, US-002)
- Context artifacts add **project-specific** coding standards and patterns
- Context artifacts are **versioned** and **reviewable** (unlike static npl_load content)
- Context artifacts can be **task/module scoped** (npl_load is global)

### Supported Formats
- **Markdown** (`.md`): Human-readable standards, patterns, examples with code blocks
- **YAML** (`.yaml`): Structured rules for automated validation (future enhancement)
- **JSON** (`.json`): Alternative structured format for tool integration

## Notes

- Context should be versioned like other artifacts (uses US-008 artifact system)
- Context inheritance: task-level > module-level > project-level
- Context effectiveness measured by: revision count, review approval rate, context violation comments
- Context violations in reviews should reference specific context artifact sections

## Dependencies

- **US-008**: Create Versioned Artifact (context stored as artifacts)
- **US-009**: Review Artifact Revision History (context evolution tracking)
- **US-001**: Load NPL Core Components (npl_load for core syntax/protocols)
- **US-014**: Pick Task from Queue (agents discover context when claiming tasks)
- **US-031**: View Agent Work Logs (agents log context loading)

## Open Questions

- [ ] Should context have max token limit? (Suggested: 4000 tokens per artifact, warn at 3000)
- [ ] Should context be mandatory or optional? (Proposed: optional, but logged if not loaded)
- [ ] Should we auto-detect context violations via linting? (Future: context-aware code analysis)
- [ ] How to handle conflicting context from multiple artifacts? (Proposed: explicit precedence rules)

## Related Commands

**Primary**:
- `create_artifact(name="coding-standards", type="markdown", metadata={"scope": "project", "category": "standards"})` - Create context artifact
- `list_context_artifacts(scope?, category?, applies_to?)` - Discover relevant context
- `get_artifact(artifact_id)` - Load context content
- `add_revision(artifact_id, content_base64, notes)` - Update context with changelog

**Related**:
- `npl_load` - Load NPL core components (complements project context)
- `add_artifact_comment(artifact_id, comment)` - Discuss context changes
- `link_artifact_to_task(task_id, artifact_id, relationship="context")` - Pin context to task

# User Story: Review Agent-Generated Code

**ID**: US-034
**Persona**: P-005 (Dave the Fellow Developer)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:20:00Z
**Updated**: 2026-02-02

## Story

As a **fellow developer**,
I want to **efficiently review code that agents have generated**,
So that **I can ensure quality while leveraging agent productivity and provide feedback that improves future agent output**.

## Acceptance Criteria

### Review Initiation
- [ ] Can start review for any artifact revision using `create_review(artifact_id, revision_id, reviewer_persona)`
- [ ] Agent-generated artifacts clearly labeled with creator persona (P-001 or specific agent ID)
- [ ] Review creation returns review ID for subsequent operations
- [ ] Can review artifacts linked to tasks to understand context (see US-017)

### Revision Comparison
- [ ] Can view artifact history using `get_artifact_history(artifact_id)` to see all revisions
- [ ] Diff view shows changes between consecutive revisions (v1→v2, v2→v3, etc.)
- [ ] Can compare any two revisions using `compare_artifact_revisions(artifact_id, revision_a, revision_b)`
- [ ] Comparison highlights additions, deletions, and modifications
- [ ] For code artifacts, line-based diff clearly shows code changes

### Inline Feedback
- [ ] Can add line-specific comments using `add_inline_comment(review_id, location, content)`
- [ ] Location supports line numbers: `{"type": "line", "line": 42}`
- [ ] Location supports line ranges: `{"type": "line_range", "start_line": 10, "end_line": 15}`
- [ ] Comments support markdown formatting for code examples and explanations
- [ ] Comments structured for agent consumption (clear, actionable, contextual)
- [ ] Can reply to existing comments to create threaded discussions

### Review Checklist
- [ ] Review workflow includes checklist tailored to common agent mistakes:
  - Error handling completeness
  - Edge case coverage
  - Code style consistency
  - Documentation clarity
  - Test coverage adequacy
  - Security considerations (input validation, authentication, etc.)
  - Performance implications (N+1 queries, unnecessary loops, etc.)
  - Dependency management (imports, version conflicts)
- [ ] Checklist items can be marked as passed/failed
- [ ] Failed checklist items link to specific inline comments explaining issues

### Approval Workflow
- [ ] Can complete review with overall summary using `complete_review(review_id, overall_summary, approval_status?)`
- [ ] Approval status options: "approved", "changes_requested", "needs_discussion"
- [ ] Completion summary provides high-level assessment and next steps
- [ ] Completed reviews visible when viewing artifact via `get_artifact(artifact_id)`
- [ ] Review completion can update linked task status (US-018)

### Revision Requests
- [ ] Can request agent to revise specific sections via inline comments
- [ ] Revision request comments can auto-create follow-up tasks (optional)
- [ ] Follow-up tasks link back to original artifact and review for context
- [ ] Agent can access review comments when creating next revision

### Agent Learning & Context
- [ ] Comments persist across sessions for agent learning
- [ ] Review patterns (common issues, approval criteria) accessible to agents via `npl_load`
- [ ] Structured feedback format helps agents understand quality expectations
- [ ] Historical reviews for similar artifacts available for agent reference

## Test Scenarios

### Scenario 1: Complete Code Review Workflow
**Given** agent creates code artifact (v1) linked to task
**When** developer starts review, adds 3 inline comments, completes with "changes_requested"
**Then** review recorded, comments visible, agent can access feedback in next session

### Scenario 2: Revision Comparison
**Given** artifact with v1 (initial) and v2 (after agent revisions)
**When** developer compares v1 vs v2
**Then** diff shows exact changes made by agent in response to feedback

### Scenario 3: Approval Integration
**Given** developer completes review with approval_status="approved"
**When** review completion updates linked task status
**Then** task marked as completed, agent notified, artifact ready for next workflow stage

### Scenario 4: Agent Learning
**Given** multiple reviews with consistent feedback patterns (e.g., "add error handling")
**When** agent starts new task and loads context via `npl_load`
**Then** agent receives summary of common review issues to avoid in current work

### Scenario 5: Threaded Discussion
**Given** developer adds inline comment requesting clarification
**When** agent replies to comment explaining design decision
**Then** threaded conversation preserved at specific code location for context

## Technical Details

### Review Data Model
```python
{
  "review_id": "r-uuid",
  "artifact_id": "a-uuid",
  "revision_id": "rev-uuid",
  "reviewer_persona": "P-005",  # Dave the Fellow Developer
  "status": "open" | "completed",
  "created_at": "2026-02-02T10:00:00Z",
  "completed_at": "2026-02-02T15:30:00Z" | null,
  "overall_summary": "Markdown summary..." | null,
  "approval_status": "approved" | "changes_requested" | "needs_discussion" | null,
  "inline_comments": [
    {
      "comment_id": "c-uuid",
      "location": {"type": "line", "line": 42},
      "content": "Add error handling for null case",
      "author_persona": "P-005",
      "created_at": "2026-02-02T11:00:00Z",
      "replies": [...]
    }
  ]
}
```

### Common Agent Code Issues Checklist
1. **Error Handling**: Try-catch blocks, null checks, edge cases
2. **Code Style**: Naming conventions, formatting, project patterns
3. **Documentation**: Docstrings, comments, inline explanations
4. **Testing**: Unit tests, edge cases, integration tests
5. **Security**: Input validation, SQL injection prevention, XSS protection
6. **Performance**: Algorithmic complexity, database queries, caching
7. **Dependencies**: Import management, version compatibility, circular deps
8. **Maintainability**: Code duplication, function length, complexity

### Agent-Aware Comment Structure
**Good Example** (clear, actionable, contextual):
```markdown
**Issue**: Missing null check at line 42
**Impact**: Will crash if `user` is None
**Fix**: Add `if user is None: return None` before access
**Why**: Agent-generated code often assumes happy path
```

**Poor Example** (vague, not actionable):
```markdown
This doesn't look right.
```

### Integration with Task Workflow
1. Agent creates artifact for task (US-008, US-017)
2. Developer reviews artifact (US-034 - this story)
3. Developer adds inline comments (US-010)
4. Developer completes review with approval status (US-023)
5. If changes requested: Developer updates task status to create revision task (US-018)
6. If approved: Task marked completed, artifact ready for deployment

## Notes

- Agent code often has consistent pattern issues—checklist catches these systematically
- Comments should be structured for agent consumption, not just human readers
- Review patterns across multiple artifacts help agents learn quality expectations
- Historical reviews serve as training data for improving agent code generation
- Consider "agent-aware" code review tools that highlight common AI-generated code patterns

## Dependencies

- **US-008**: Create Versioned Artifact (artifact must exist to review)
- **US-009**: Review Artifact Revision History (view evolution, compare versions)
- **US-010**: Add Inline Review Comment (provide specific feedback)
- **US-017**: Link Artifact to Task (understand context, update status)
- **US-018**: Update Task Status (workflow integration, approval actions)
- **US-023**: Complete Review with Summary (finalize review, record decision)
- Review system (`create_review`, `get_review`, `complete_review` commands)
- Database schema supporting review lifecycle management

## Open Questions

- **Agent Learning**: How to aggregate review feedback patterns for agent training? Proposal: Periodic analysis of review comments to generate "common issues" guide
- **Auto-Task Creation**: Should review comments auto-create revision tasks? Recommendation: Optional flag on comments to auto-generate follow-up tasks
- **Checklist Customization**: Should review checklist be customizable per project/team? Recommendation: Support default + project-specific checklist templates
- **Review Metrics**: Track review turnaround time, approval rates, common issues? Use case: Identify agent improvement areas, optimize review process
- **Multi-Reviewer**: Support multiple reviewers on same artifact? Proposal: One review per reviewer per revision, aggregate approvals
- **Batch Review**: Review multiple artifacts in single session? Use case: Reviewing agent work across multiple tasks in sprint

## Related Commands

### Primary (Review Workflow)
- `create_review(artifact_id, revision_id, reviewer_persona)` - Start review
- `add_inline_comment(review_id, location, content, parent_comment_id?)` - Add feedback
- `complete_review(review_id, overall_summary, approval_status?)` - Finalize review
- `get_review(review_id)` - Retrieve review with all comments

### Supporting (Artifact & History)
- `get_artifact(artifact_id, revision?)` - View artifact content
- `get_artifact_history(artifact_id)` - View all revisions
- `compare_artifact_revisions(artifact_id, revision_a, revision_b)` - Generate diff

### Supporting (Task Integration)
- `get_task(task_id)` - View linked task context
- `update_task_status(task_id, status)` - Update after approval/rejection
- `add_task_message(task_id, message)` - Communicate review outcome

### Supporting (Context Loading)
- `npl_load(component)` - Load review patterns, quality guidelines

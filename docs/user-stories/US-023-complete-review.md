# User Story: Complete Review with Summary

**ID**: US-023
**Persona**: P-002 (Product Manager)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z
**Updated**: 2026-02-02

## Story

As a **product manager**,
I want to **mark a review as completed with an overall summary comment**,
So that **the creator knows the review is done, understands my final decision, and can proceed with next steps**.

## Acceptance Criteria

### Review Completion
- [ ] Can mark existing review as completed by review ID
- [ ] Review must be in "open" status to complete (cannot complete "completed" or "archived" reviews)
- [ ] Completion requires overall summary comment (mandatory, not optional)
- [ ] Summary comment supports markdown formatting
- [ ] Completion timestamp recorded in ISO 8601 format (UTC)
- [ ] Returns updated review status in response

### Status Transitions
- [ ] Review status changes from "open" → "completed"
- [ ] Completed status is immutable (cannot transition to other states without explicit reopen)
- [ ] Status change is atomic (no partial completion states)
- [ ] Status transition logged for audit trail

### Comment Preservation
- [ ] All inline comments remain accessible after completion
- [ ] Comment threads preserved with full history
- [ ] Inline comments remain at original locations in artifact
- [ ] Overall summary comment stored separately from inline comments
- [ ] Overall summary visible when retrieving review via `get_review`

### Decision Recording (Optional Enhancement)
- [ ] Can optionally specify approval status: "approved", "changes_requested", "needs_discussion"
- [ ] Approval status defaults to null if not specified (completion does not require approval decision)
- [ ] Approval status stored as structured field (not inferred from comment text)

### Notifications (Future Integration)
- [ ] Artifact creator notified of review completion
- [ ] Notification includes reviewer identity, completion timestamp, and summary excerpt
- [ ] Notification system integration documented (placeholder for future implementation)

## Test Scenarios

### Scenario 1: Complete Review with Summary
**Given** review in "open" status with 3 inline comments
**When** reviewer completes review with summary "All feedback addressed. Approved for release."
**Then** review status changes to "completed", summary stored, timestamp recorded, all 3 inline comments preserved

### Scenario 2: Complete Review with Approval Status
**Given** review in "open" status
**When** reviewer completes with summary and approval_status="approved"
**Then** review marked completed with approval status recorded

### Scenario 3: Attempt to Complete Already Completed Review
**Given** review already in "completed" status
**When** user attempts to complete review again
**Then** returns error indicating review already completed

### Scenario 4: Complete Review Without Summary
**Given** review in "open" status
**When** user attempts to complete without providing summary comment
**Then** returns validation error requiring summary comment

### Scenario 5: Retrieve Completed Review
**Given** review completed with summary and inline comments
**When** user retrieves review via `get_review`
**Then** returns review with status="completed", summary, completion timestamp, and all inline comments

### Scenario 6: Complete Review for Non-Existent Review ID
**Given** non-existent review ID
**When** user attempts to complete review
**Then** returns error indicating review not found

## Technical Notes

### Review Completion Data Model
```python
{
  "review_id": "r-uuid",
  "artifact_id": "a-uuid",
  "revision_id": "rev-uuid",
  "reviewer_persona": "P-002",
  "status": "completed",  # transition from "open"
  "created_at": "2026-02-02T10:00:00Z",
  "completed_at": "2026-02-02T15:30:00Z",
  "overall_summary": "Markdown summary text...",
  "approval_status": "approved" | "changes_requested" | "needs_discussion" | null,
  "inline_comments": [
    # Array of inline comments preserved from review process
  ]
}
```

### Status State Machine
```
┌──────┐    complete_review()    ┌───────────┐
│ open │ ──────────────────────> │ completed │
└──────┘                          └───────────┘
                                        │
                                        │ reopen_review() (future)
                                        v
                                   ┌──────┐
                                   │ open │
                                   └──────┘
```

### Workflow Integration
- Completion signals end of review cycle
- Artifact creator can proceed with next revision or release
- Completed reviews serve as historical record of feedback
- Overall summary provides high-level decision without reading all inline comments
- Approval status enables filtering/reporting (e.g., "show all approved artifacts")

### Audit Trail
- Completion timestamp provides accountability
- Reviewer identity tracked via persona
- Summary and approval status provide decision rationale
- Immutable status (once completed) ensures audit integrity

## Dependencies

- **US-010**: Add Inline Review Comment (review must have been created via `create_review`)
- Review system must exist with status tracking
- Database schema supporting review lifecycle management

## Open Questions

- **Reopening Reviews**: Should completed reviews be reopenable? Proposal: Add `reopen_review()` tool for cases where additional feedback needed
- **Approval Status**: Should approval status be required or optional? Recommendation: Optional to support informational reviews without approval workflow
- **Multiple Reviewers**: Can multiple personas complete the same review, or is review tied to single reviewer? Recommendation: One review per reviewer per revision
- **Summary Length**: Should overall summary have character/word limit? Recommendation: Soft limit of 2000 characters with UI guidance
- **Edit After Completion**: Can summary be edited after completion? Recommendation: Allow edit within 15-minute window with edit history

## Related Commands

### Primary
- `complete_review(review_id, overall_summary, approval_status?)` - Mark review as completed with summary

### Supporting
- `get_review(review_id)` - Retrieve review including completion status and summary
- `create_review(artifact_id, revision_id, reviewer_persona)` - Create review before adding comments
- `add_inline_comment(review_id, location, content)` - Add inline comments before completion
- `reopen_review(review_id)` - Future: Reopen completed review for additional feedback

### Implementation Reference
See `docs/reference/mcp.md` (Review Tools section) for API payload examples.

## Examples

### Complete review with approval
```python
complete_review(
  review_id="r-abc123",
  overall_summary="All technical requirements met. Code quality is excellent. Approved for production deployment.",
  approval_status="approved"
)
```

### Complete review requesting changes
```python
complete_review(
  review_id="r-abc123",
  overall_summary="See inline comments for required changes. Need to address performance concerns in sections 3 and 7 before approval.",
  approval_status="changes_requested"
)
```

### Complete informational review (no approval decision)
```python
complete_review(
  review_id="r-abc123",
  overall_summary="Reviewed for architectural alignment. Looks good overall. A few suggestions in inline comments but no blockers."
)
```

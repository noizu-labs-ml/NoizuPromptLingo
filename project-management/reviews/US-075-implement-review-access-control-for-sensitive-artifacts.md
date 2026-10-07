# Review: Implement Review Access Control for Sensitive Artifacts

- **Story**: `project-management/user-stories/US-075-implement-review-access-control-for-sensitive-artifacts.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Reviews exist in both codebases but carry **zero access control**. Python: `src/npl_mcp/artifacts/reviews.py` implements `review_create`, `review_list_by_artifact`, `review_get`, `review_add_comment`, `review_complete` with no ACL of any kind — `review_get` (`reviews.py:131-176`) selects by review id unconditionally, and `review_complete` (`reviews.py:179-204`) updates by id with no reviewer/ACL check; the MCP tools in `src/npl_mcp/launcher.py:1606-1640` pass reviewer/persona straight through. The `npl_reviews` table has no `acl` column (see US-073 review). Elixir: `backend/lib/noizu_prompt_lingua/domains/review/reviews.ex` (124 lines) updatable fields are `~w(title reviewer_persona summary verdict status)` — no ACL; `grep -i "acl|permission"` in `domains/review/` returns nothing. Although a full ACL engine exists (`backend/lib/noizu_prompt_lingua/acl.ex`, deny-wins resolver) it is not wired into any review path. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Reviews inherit ACL from parent artifact | Not Met | no `acl` column on `npl_reviews` (`reviews.py:9-19`) nor on artifacts (`artifacts.py:123-126`); nothing to inherit |
| Only personas in artifact ACL can view review sessions | Not Met | `review_get` (`reviews.py:131-144`) fetches any review by id with no caller identity or permission check |
| Only authorized personas can add inline comments | Not Met | `review_add_comment` (`reviews.py:73-115`) accepts any persona string, no validation against an ACL |
| Review completion requires reviewer to be in ACL | Not Met | `review_complete` (`reviews.py:179-195`) completes by id unconditionally — caller need not be the reviewer at all |
| `get_review` MCP tool enforces permission checks | Not Met | `launcher.py` registers review tools passing ids/persona straight to the functions; no guard layer exists in the Python server |
| Permission denied errors clearly indicate authorization failure | Not Met | no authorization failures can occur; no `forbidden`/`403` anywhere in `src/npl_mcp/` (grep: no hits) |

## Gaps / Risks

- Any caller can read, comment on, or complete any review in the Python server — reviews on "sensitive artifacts" have no protection.
- The Elixir review domain is equally unguarded (no `authz:` metadata on its tools; ToolGuard is shadow-mode — see US-072 review).
- The existing `Acl` engine (`backend/.../acl.ex`) would support resource-scoped rules but nothing maps artifact→ACL or reviews→inheritance.

## BDD Scenario

```gherkin
Feature: Review access control for sensitive artifacts
  Story is NOT implemented — scenario describes current, unprotected behavior.

  Scenario: Unauthorized persona reads a sensitive review
    Given artifact "ProprietarySpec" with a review containing inline comments
    When any caller invokes ReviewGet with review_id=<id>
    Then the full review, its comments, and the artifact linkage are returned
    And no identity or permission is checked

  Scenario: Unauthorized completion
    When a caller other than the reviewer invokes ReviewComplete with review_id=<id>
    Then the review is marked completed regardless of caller identity
```

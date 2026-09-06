# Review: Review Artifact Revision History

- **Story**: `project-management/user-stories/US-009-review-artifact-history.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Revision history is real and immutable: `Domains.Artifacts` stores full-content snapshot revisions with `revision_number` (max+1 sequence, `backend/lib/noizu_prompt_lingua/domains/artifacts/artifacts.ex:49-58`), `Artifact.ListRevisions` MCP tool returns summaries newest-first (`tools/artifact_list_revisions.ex:22-23`; `list_revisions` orders `desc: revision_number`, `artifacts.ex:65-77`), and `Artifact.Get` returns latest content by default or a specific revision by `revision_id` (`tools/artifact_get.ex:10-21`; `get_revision` by number, `artifacts.ex:61-63`). There is no revision update/delete path, so the audit trail is immutable. Note: the story's own "Implementation Status" section self-reports "Comparison/diff features not yet implemented", and the current backend confirms it — **no diff/compare tool exists**. Also gaps: revisions carry no creator (schema `artifact_revision.ex` has no author field), `list_revisions` omits even note from... actually it selects note ✓ but no author; pagination is limit-only (default 50, no cursor); artifact deletion handling exists via... (no delete tool on the MCP surface; HTTP controller exposes delete for artifacts, orphaning nothing since revisions cascade with the artifact).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Retrieve complete revision history by artifact ID | Met | `Artifact.ListRevisions` (`artifact_list_revisions.ex:17-23`); `artifacts.ex:65-77` |
| Revisions newest-first | Met | `order_by desc revision_number` (`artifacts.ex:68`) |
| Empty history returns non-error response | Met | new artifacts always have v1; an unknown artifact yields `count: 0` + empty list, not an error (`artifact_list_revisions.ex:22-23`) |
| Each revision: number, timestamp, author, notes | Partially Met | number ✓, created_at ✓, note ✓ (`artifacts.ex:70-75`); author ✗ — no creator field (`artifact_revision.ex:8-13`) |
| Revision numbers sequential and immutable | Met | max+1 (`artifacts.ex:50-56`) — concurrency caveat: no unique constraint observed on (artifact_id, revision_number) |
| Author info includes persona/user identifier | Not Met | no evidence found: no author/creator anywhere on the revision schema or create path |
| Full content of any specific revision retrievable | Met | `Artifact.Get` + `revision_id` (`artifact_get.ex:10-21`); `get_revision` (`artifacts.ex:61-63`) |
| Most recent content without specifying revision | Met | default latest (`artifact_get.ex:4,11`; `artifacts.ex:29-30`) |
| Historical content matches at creation (immutable) | Met | full snapshots, no mutation path (`artifacts.ex` has no revision update/delete) |
| Diff/comparison between revisions | Not Met | no compare tool in `domains/artifacts/tools/` (only create/get/get_binary/list_revisions/list/add_revision); story self-reports not implemented |
| History persists as new revisions are added | Met | append-only design (`add_revision` inserts only) |
| Cannot modify/delete historical revisions | Met | no such code path exists |
| Artifact deletion handling (archive vs hard delete) | Partially Met | HTTP artifact controller exposes delete; MCP surface does not; no archival mode implemented — "documented" only in the sense of absence |

## Gaps / Risks

- No diff/compare capability — the largest functional block of this story is missing.
- No author attribution on revisions (and none on artifacts either, per US-008) — the "audit who made modifications" goal is unachievable.
- History pagination is a bare limit (default 50); a 100+-revision artifact silently truncates.
- Sequential numbering via read-max-then-insert is race-prone under concurrent `add_revision` calls.
- No export/download of a specific revision binary from the MCP surface (`Artifact.GetBinary` exists — see `tools/artifact_get_binary.ex` — but history-aware access is via UUID revision_id only, not revision_number).

## BDD Scenario

```gherkin
Feature: Review artifact revision history

  Scenario: PM reviews how a deliverable evolved
    Given an artifact with revisions 1, 2, 3
    When Artifact.ListRevisions is called
    Then revisions are returned 3, 2, 1 with revision_number, note, created_at
    When Artifact.Get is called with revision_id=<rev2>
    Then the content returned is exactly the rev-2 snapshot

  Scenario: Latest by default
    When Artifact.Get is called with no revision
    Then revision 3 content is returned

  Scenario: Immutability
    When Artifact.AddRevision creates revision 4
    Then revisions 1-3 remain byte-identical and ListRevisions shows all four

  Scenario: Compare revisions (unimplemented)
    When a diff of revisions 1 and 2 is requested
    Then no tool exists to perform it — the request cannot be served today
```

# Review: Attach a File to a Wiki Page

- **Story**: `project-management/user-stories/US-075-attach-a-file-to-a-wiki-page.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend implements wiki attachments as **metadata records, not uploads**: `Wiki.AttachmentCreate` (`backend/lib/noizu_prompt_lingua/domains/wiki/tools/attachment_create.ex:20-51`) persists `filename`, `url`, `mime_type`, `byte_size` against a validated page (`schema/wiki/attachment.ex:8-23`); `AttachmentList` (`tools/attachment_list.ex`) lists them with size; `AttachmentDelete` removes records. There is no actual file transfer — the tool's own description says "Attach a file *reference* (filename + URL)". Consequently: no uploader is recorded or shown (the schema has no uploader/author field), download depends entirely on whatever the external URL points at (no platform download endpoint, so "no separate storage credentials" is unverified), and no size limit is enforced anywhere (`byte_size` is accepted as-is; no configured cap). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Uploaded file appears in attachment list with filename, size, and uploader | Partially Met | filename + byte_size shown (`attachment_list.ex:33-40`); **uploader is not stored or returned** — no such field exists (`schema/wiki/attachment.ex:8-15`) |
| Other project members can download the attachment without separate storage credentials | Not Met | only a caller-supplied `url` string is stored (`attachment_create.ex:11,30`); no platform download path — retrieval works only if the external URL happens to be publicly reachable |
| Upload exceeding configured size limit rejected with clear size-limit error | Not Met | `byte_size` is not validated against any limit (`attachment_create.ex:33`; `schema/wiki/attachment.ex:18-22` has no numerical validation); and since nothing is uploaded, no upload size can be bounded |

## Gaps / Risks

- The story's premise (actual file upload reusing the platform object store, cf. review screenshots) is unmet; today attachments are hand-authored URL annotations.
- No uploader attribution weakens auditability and the "visible to other project members" trust model.
- `byte_size` is caller-asserted and never verified against a real object.
- Unlike `artifact_create` in Python (`src/npl_mcp/artifacts/artifacts.py:108-112`, which enforces a MAX_BINARY_BYTES cap), the wiki attachment path has no size discipline at all.

## BDD Scenario

```gherkin
Feature: Attach a file to a wiki page

  Scenario: Reference an existing file
    When the agent calls Wiki.AttachmentCreate with page=<id>, filename="cors.log", url="https://…", byte_size=4096
    Then AttachmentList(page=<id>) shows filename "cors.log" and byte_size 4096
    And no uploader is shown (the field does not exist)

  Scenario: Download as another member (unsupported)
    When another member views the page attachment
    Then the platform offers no download capability — only the raw stored URL, which may require external credentials

  Scenario: Oversized attachment (unsupported)
    When the agent calls Wiki.AttachmentCreate with byte_size=999999999999
    Then the record is accepted (no size limit is enforced)
```

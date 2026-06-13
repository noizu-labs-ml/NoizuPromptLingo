# US-224: Skip Already-Loaded Resources Using Flags

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-224 |
| **Title** | Skip Already-Loaded Resources Using Flags |
| **Priority** | Medium |
| **Status** | Draft |
| **Related Personas** | P-005 (Dave) |
| **Related PRD** | PRD-014-cli-utilities.md |

---

## Description

As a developer, I want to skip already-loaded resources using flags.

This enables efficient resource loading workflows where loaded resources are tracked and can be skipped on subsequent loads to avoid duplication, redundant I/O, or conflicting configurations.

---

## Acceptance Criteria

- [ ] **AC-1**: `--skip` flag specifies resources to skip: `--skip agent --skip tool`
- [ ] **AC-2**: `--skip-loaded` flag skips previously-loaded resources (from session memory)
- [ ] **AC-3**: `--only` flag loads ONLY specified resources: `--only agent --only tool`
- [ ] **AC-4**: Skip/only matching is case-insensitive and supports glob patterns
- [ ] **AC-5**: Skipped resources are logged with reason
- [ ] **AC-6**: Works with all resource loaders (npl-load, npl-persona, npl-session)
- [ ] **AC-7**: Conflicts are handled gracefully (skip + only conflict raises error)

---

## Technical Notes

- Skip tracking: Maintains registry of loaded resources
- Pattern matching: fnmatch for glob, lowercase for case-insensitive
- Conflict resolution: Skip takes precedence, or error on mutual exclusion
- Logging: Include reason (already loaded, explicitly skipped, filtered by only)
- State management: Session-level tracking across multiple load commands

---

## Dependencies

- Resource loader framework
- Session state management
- Pattern matching utilities (fnmatch)

---

## Test Coverage Requirements

- Unit tests for skip/only matching
- Tests for glob pattern matching
- Tests for session state tracking
- Tests for conflict handling
- Tests for logging accuracy
- Edge cases: empty patterns, mutual conflicts, missing resources
- Target coverage: 80%+ for new code paths

# PRD-006: Browser Automation

**Version**: 1.0
**Status**: Implemented
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

Playwright-based browser automation with 32 MCP tools covering screenshot capture, visual diffing, navigation, element interaction, content extraction, page modification, state management, and session handling. Supports viewport/theme control and session-based workflows.

**Implementation Status**: ✅ Complete in mcp-server worktree

## Goals

1. Provide comprehensive browser automation for testing and scraping workflows
2. Enable visual regression testing with screenshot capture and diffing
3. Support form automation and element interaction
4. Manage browser sessions with persistent state (cookies, localStorage)
5. Enable page modification through script/style injection
6. Provide robust timeout and retry handling for reliable automation

## Non-Goals

- Browser automation for non-Playwright browsers
- Video recording of browser sessions
- Mobile device emulation beyond viewport sizing
- PDF generation from web pages
- Browser extension management

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-012 | [Capture Screenshot of Current Work](../../user-stories/US-012-capture-screenshot.md) | P-003 | medium |
| US-013 | [Compare Screenshots for Visual Regression](../../user-stories/US-013-compare-screenshots.md) | P-001 | medium |
| US-019 | [Automate Form Submission](../../user-stories/US-019-automate-form-submission.md) | P-001 | medium |
| US-020 | [Quick Form Fill for Developers](../../user-stories/US-020-quick-form-fill.md) | P-003 | medium |
| US-021 | [Navigate and Interact with Web Pages](../../user-stories/US-021-browser-navigation.md) | P-001 | medium |
| US-024 | [Manage Browser Session State](../../user-stories/US-024-manage-browser-state.md) | P-001 | low |
| US-029 | [Inject Scripts and Styles](../../user-stories/US-029-inject-page-scripts.md) | P-001 | low |
| US-052 | [Browser Automation Timeout & Retry Handling](../../user-stories/US-052-browser-automation-timeout-and-retry-handling.md) | P-001 | high |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **FR-001**: [Screenshot & Visual Testing](./functional-requirements/FR-001-screenshot-visual-testing.md) (3 tools)
- **FR-002**: [Navigation & Page State](./functional-requirements/FR-002-navigation-page-state.md) (5 tools)
- **FR-003**: [Element Interaction](./functional-requirements/FR-003-element-interaction.md) (9 tools)
- **FR-004**: [Content Extraction](./functional-requirements/FR-004-content-extraction.md) (4 tools)
- **FR-005**: [Page Modification](./functional-requirements/FR-005-page-modification.md) (2 tools)
- **FR-006**: [State Management](./functional-requirements/FR-006-state-management.md) (7 tools)
- **FR-007**: [Session Management](./functional-requirements/FR-007-session-management.md) (2 tools)

**Total**: 32 MCP tools

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 80% |
| NFR-2 | Response time | Tool execution | < 5s for navigation |
| NFR-3 | Screenshot quality | Image format | PNG with lossless compression |
| NFR-4 | Session limits | Max concurrent sessions | 10 sessions |
| NFR-5 | Resource cleanup | Memory after session close | < 110% pre-session memory |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Invalid URL | ValueError | "Invalid URL format: {url}" |
| Element not found | SelectorError | "Element not found: {selector}" |
| Timeout exceeded | TimeoutError | "Operation timed out after {ms}ms" |
| Session not found | SessionError | "Session '{id}' does not exist" |
| Network failure | NetworkError | "Network request failed: {reason}" |
| Script error | ScriptError | "JavaScript error: {message}" |
| Invalid viewport | ValidationError | "Viewport dimensions must be 100-3840px" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

Test categories:
- **Integration tests**: End-to-end workflow validation (7 tests)

---

## Success Criteria

1. All 8 user stories implemented with acceptance criteria passing
2. All 32 MCP tools functional and tested
3. Test coverage >= 80% for all new code
4. All 7 acceptance tests passing
5. Clear and actionable error messages for all error conditions
6. Session management with proper resource cleanup
7. Visual diffing with < 1% false positive rate

---

## Implementation Notes

**Viewport Presets**:
- `desktop`: 1280x720
- `mobile`: 375x667
- Custom: `{width}x{height}`

**Theme Control**: Sets `prefers-color-scheme` media query

**Network Idle**: Waits for 500ms of no network activity

**Session Management**:
- Lazy-created sessions
- Shared browser instance
- Separate browser contexts per session
- Auto-cleanup on process exit

**Dependencies**:
- playwright (browser automation)
- Pillow (image processing)
- pixelmatch (visual diffing)

---

## Out of Scope

- Video recording of browser sessions
- Mobile device emulation beyond viewport sizing
- PDF generation
- Browser extension installation
- Multi-browser support (Playwright only)
- Distributed browser automation (single instance)

---

## Dependencies

**Internal**:
- C-02: Artifacts (for screenshot storage)
- C-05: Sessions (for session management)
- C-01: Database (for metadata storage)

**External**:
- playwright
- Pillow
- pixelmatch

---

## Open Questions

- [ ] Should screenshot diff threshold be configurable per PRD or per tool call?
- [ ] Should sessions auto-expire after inactivity period?
- [ ] Should we support browser profile persistence across server restarts?

---

## Documentation References

- **Category Brief**: `.tmp/mcp-server/categories/07-browser-automation.md`
- **Tool Spec**: `.tmp/mcp-server/tools/by-category/browser-tools.yaml`

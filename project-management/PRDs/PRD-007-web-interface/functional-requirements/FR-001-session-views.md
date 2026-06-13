# FR-001: Session Views

**Status**: Completed

## Description

Provide HTML routes for session listing and session detail views. The system must render session tables, room cards, and artifact cards using Jinja2 templates.

## Interface

```python
# Routes
@app.get("/")
async def index() -> HTMLResponse:
    """Render session listing page."""

@app.get("/session/{session_id}")
async def session_detail(session_id: str) -> HTMLResponse:
    """Render session detail page with rooms and artifacts."""
```

## Behavior

- **Given** a user navigates to the root URL
- **When** the index page loads
- **Then** a table of all sessions is displayed

- **Given** a user navigates to /session/{session_id}
- **When** the session detail page loads
- **Then** room cards and artifact cards for that session are displayed

## Edge Cases

- **Empty sessions**: Display "No sessions found" message
- **Invalid session ID**: Return 404 error
- **Session with no rooms**: Display empty state for rooms section

## Related User Stories

- US-005

## Test Coverage

Expected test count: 8-12 tests
Target coverage: 100% for this FR

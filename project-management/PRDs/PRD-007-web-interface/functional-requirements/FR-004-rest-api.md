# FR-004: REST API

**Status**: Completed

## Description

Provide JSON REST API endpoints for sessions, chat rooms, and screenshots. All endpoints return structured JSON responses with appropriate HTTP status codes.

## Interface

```python
# Session APIs
@app.get("/api/sessions")
async def list_sessions() -> JSONResponse:
    """List all sessions with metadata."""

@app.get("/api/session/{id}")
async def get_session(id: str) -> JSONResponse:
    """Get session details including rooms and artifacts."""

# Chat APIs
@app.get("/api/room/{id}/feed")
async def get_room_feed(id: str) -> JSONResponse:
    """Get chat room message feed."""

@app.post("/api/room/{id}/message")
async def post_room_message(id: str, message: MessageCreate) -> JSONResponse:
    """Post message to chat room."""

# Screenshot APIs
@app.get("/api/screenshots/checkpoints")
async def list_checkpoints() -> JSONResponse:
    """List all screenshot checkpoints."""

@app.get("/api/screenshots/checkpoint/{slug}")
async def get_checkpoint(slug: str) -> JSONResponse:
    """Get checkpoint metadata and screenshot list."""
```

## Behavior

- **Given** a client requests /api/sessions
- **When** the request is processed
- **Then** a JSON array of session objects is returned

- **Given** a client posts to /api/room/{id}/message
- **When** the message is valid
- **Then** the message is created and a success response is returned

## Edge Cases

- **Invalid session ID**: Return 404 with error JSON
- **Malformed JSON**: Return 400 with validation errors
- **Empty list results**: Return empty array with 200 status
- **Server error**: Return 500 with error details

## Related User Stories

- US-004
- US-005

## Test Coverage

Expected test count: 14-20 tests
Target coverage: 100% for this FR

# FR-002: Chat Interface

**Status**: Completed

## Description

Provide HTML routes for chat room views with message posting, TODO posting, and @mention support. Chat rooms display message feeds in chronological order.

## Interface

```python
# Routes
@app.get("/session/{sid}/room/{rid}")
async def session_room_view(sid: str, rid: str) -> HTMLResponse:
    """Render chat room within session context."""

@app.get("/room/{rid}")
async def standalone_room_view(rid: str) -> HTMLResponse:
    """Render standalone chat room."""

@app.post("/session/{sid}/room/{rid}/message")
async def post_message(sid: str, rid: str, message: str) -> JSONResponse:
    """Post a message to the chat room."""

@app.post("/session/{sid}/room/{rid}/todo")
async def post_todo(sid: str, rid: str, todo: str) -> JSONResponse:
    """Post a TODO item to the chat room."""
```

## Behavior

- **Given** a user navigates to a chat room URL
- **When** the page loads
- **Then** the message feed is displayed in chronological order

- **Given** a user submits a message form
- **When** the form is posted
- **Then** the message is added to the room and the feed updates

## Edge Cases

- **Empty chat room**: Display "No messages yet" placeholder
- **Invalid room ID**: Return 404 error
- **Malformed message**: Validate and return error response
- **@mention of non-existent user**: Display mention but no notification

## Related User Stories

- US-004

## Test Coverage

Expected test count: 12-16 tests
Target coverage: 100% for this FR

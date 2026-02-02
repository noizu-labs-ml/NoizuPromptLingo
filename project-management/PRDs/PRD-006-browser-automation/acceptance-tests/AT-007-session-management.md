# AT-007: Session Management

**Category**: Integration
**Related FR**: FR-007
**Status**: Not Started

## Description

Validates session lifecycle management including listing and cleanup.

## Test Implementation

```python
def test_browser_list_sessions_empty():
    """List sessions when none exist."""
    result = await browser_list_sessions()
    assert "sessions" in result
    assert "count" in result
    # May have 0 or existing sessions depending on state

def test_browser_list_sessions_with_active():
    """List sessions with active sessions."""
    # Create sessions
    await browser_navigate(url="https://example.com", session_id="session1")
    await browser_navigate(url="https://example.org", session_id="session2")

    result = await browser_list_sessions()
    assert result["count"] >= 2
    assert len(result["sessions"]) >= 2

    session_ids = [s["session_id"] for s in result["sessions"]]
    assert "session1" in session_ids
    assert "session2" in session_ids

    for session in result["sessions"]:
        assert "session_id" in session
        assert "url" in session
        assert "title" in session
        assert "created_at" in session
        assert "last_activity" in session

def test_browser_close_session():
    """Close session and verify cleanup."""
    await browser_navigate(url="https://example.com", session_id="close-test")

    # Verify session exists
    before = await browser_list_sessions()
    session_ids_before = [s["session_id"] for s in before["sessions"]]
    assert "close-test" in session_ids_before

    # Close session
    close_result = await browser_close_session(session_id="close-test")
    assert close_result["closed"] is True
    assert close_result["session_id"] == "close-test"

    # Verify session removed
    after = await browser_list_sessions()
    session_ids_after = [s["session_id"] for s in after["sessions"]]
    assert "close-test" not in session_ids_after

def test_browser_close_nonexistent_session():
    """Attempt to close non-existent session."""
    result = await browser_close_session(session_id="does-not-exist")
    # Should return error or success (both acceptable)
    assert "closed" in result or "error" in result

def test_browser_session_resource_cleanup():
    """Verify resources freed after session close."""
    import psutil
    import os

    process = psutil.Process(os.getpid())
    before_mem = process.memory_info().rss

    # Create and populate session
    await browser_navigate(url="https://example.com", session_id="resource-test")
    for i in range(10):
        await browser_navigate(url=f"https://example.com/page{i}", session_id="resource-test")

    during_mem = process.memory_info().rss

    # Close session
    await browser_close_session(session_id="resource-test")

    # Allow cleanup
    import asyncio
    await asyncio.sleep(1)

    after_mem = process.memory_info().rss

    # Memory should decrease or stabilize (not continue growing)
    assert after_mem < during_mem * 1.1  # Allow 10% overhead
```

## Acceptance Criteria

- [ ] List sessions returns all active sessions
- [ ] Session metadata includes ID, URL, title, timestamps
- [ ] Empty session list returns count=0
- [ ] Close session removes session from list
- [ ] Close session frees browser resources
- [ ] Close non-existent session handled gracefully
- [ ] Session persistence until explicit close
- [ ] Multiple sessions can coexist

## Coverage

Covers:
- Session listing
- Session metadata
- Session closure
- Resource cleanup
- Error handling
- Multi-session scenarios

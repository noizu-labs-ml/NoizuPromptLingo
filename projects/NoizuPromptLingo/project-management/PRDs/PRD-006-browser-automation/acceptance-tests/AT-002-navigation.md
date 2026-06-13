# AT-002: Browser Navigation and Page State

**Category**: Integration
**Related FR**: FR-002
**Status**: Not Started

## Description

Validates page navigation, history controls, reloading, and network idle detection.

## Test Implementation

```python
def test_browser_navigate():
    """Navigate to URL and wait for page load."""
    result = await browser_navigate(
        url="https://example.com",
        session_id="nav-test",
        wait_until="load"
    )
    assert result["url"] == "https://example.com"
    assert "title" in result
    assert result["status_code"] == 200

def test_browser_history_navigation():
    """Navigate back and forward in history."""
    await browser_navigate(url="https://example.com", session_id="history")
    await browser_navigate(url="https://example.com/page2", session_id="history")

    back_result = await browser_go_back(session_id="history")
    assert "example.com" in back_result["url"]
    assert "/page2" not in back_result["url"]

    forward_result = await browser_go_forward(session_id="history")
    assert "/page2" in forward_result["url"]

def test_browser_reload():
    """Reload current page."""
    await browser_navigate(url="https://example.com", session_id="reload")

    result = await browser_reload(session_id="reload", ignore_cache=True)
    assert result["reloaded"] is True
    assert result["url"] == "https://example.com"

def test_browser_wait_network_idle():
    """Wait for network to become idle."""
    await browser_navigate(url="https://example.com", session_id="idle")

    result = await browser_wait_network_idle(session_id="idle", timeout=5000)
    assert result["idle"] is True
    assert result["requests_pending"] == 0
```

## Acceptance Criteria

- [ ] Navigation completes and returns URL/title/status
- [ ] wait_until values supported (load, domcontentloaded, networkidle)
- [ ] History navigation works with multi-page sessions
- [ ] Reload with ignore_cache clears cache
- [ ] Network idle detects 500ms of no activity
- [ ] Timeout errors returned for slow loads
- [ ] Invalid URLs return error messages

## Coverage

Covers:
- URL navigation
- History back/forward
- Page reload with cache control
- Network idle detection
- Timeout handling
- Error conditions

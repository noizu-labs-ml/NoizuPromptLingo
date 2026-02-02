# AT-005: Page Modification

**Category**: Integration
**Related FR**: FR-005
**Status**: Not Started

## Description

Validates page modification through script and style injection.

## Test Implementation

```python
def test_browser_inject_script():
    """Inject and execute JavaScript."""
    await browser_navigate(url="https://example.com", session_id="inject")

    # Inject script that modifies DOM
    result = await browser_inject_script(
        script="document.body.style.backgroundColor = 'red'; return document.body.style.backgroundColor;",
        session_id="inject"
    )
    assert result["result"] == "red"
    assert result["error"] is None

    # Verify modification persists
    verify = await browser_evaluate(
        script="document.body.style.backgroundColor",
        session_id="inject"
    )
    assert verify["result"] == "red"

def test_browser_inject_script_error():
    """Handle script syntax/runtime errors."""
    await browser_navigate(url="https://example.com", session_id="error")

    result = await browser_inject_script(
        script="invalid syntax here!!!",
        session_id="error"
    )
    assert result["error"] is not None
    assert "syntax" in result["error"].lower() or "unexpected" in result["error"].lower()

def test_browser_inject_style():
    """Inject CSS stylesheet."""
    await browser_navigate(url="https://example.com", session_id="style")

    result = await browser_inject_style(
        css=".test-class { color: blue; font-size: 20px; }",
        session_id="style"
    )
    assert result["injected"] is True

    # Verify styles applied (create element with class)
    await browser_inject_script(
        script="document.body.innerHTML += '<div class=\"test-class\">Test</div>'",
        session_id="style"
    )

    verify = await browser_evaluate(
        script="window.getComputedStyle(document.querySelector('.test-class')).color",
        session_id="style"
    )
    assert "blue" in verify["result"].lower() or "0, 0, 255" in verify["result"]
```

## Acceptance Criteria

- [ ] Inject script executes in page context
- [ ] Inject script returns execution result
- [ ] Script modifications persist until navigation
- [ ] Script syntax errors caught and returned
- [ ] Script runtime errors caught and returned
- [ ] Inject style applies CSS to page
- [ ] Styles persist until navigation
- [ ] Invalid CSS handled gracefully

## Coverage

Covers:
- Script injection and execution
- Script return values
- Script error handling
- Style injection
- Style persistence
- Modification verification

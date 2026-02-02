# FR-005: Page Modification

**Status**: Active

## Description

Provide page modification capabilities through script and style injection. Two tools enable custom JavaScript execution and CSS styling.

**Tools**: `browser_inject_script`, `browser_inject_style` (2 tools)

## Interface

```python
async def browser_inject_script(
    script: str,
    session_id: str = None
) -> dict:
    """Inject and execute JavaScript in page context.

    Returns: {result: any, error: str|null}
    """

async def browser_inject_style(
    css: str,
    session_id: str = None
) -> dict:
    """Inject CSS stylesheet into page.

    Returns: {injected: true, selector_count: int}
    """
```

## Behavior

- **Given** JavaScript code as string
- **When** browser_inject_script is called
- **Then** script is injected and executed in page context with return value

- **Given** CSS stylesheet as string
- **When** browser_inject_style is called
- **Then** styles are injected and applied to page

## Edge Cases

- **Script syntax error**: Return error with line/column details
- **Script runtime error**: Catch and return error message
- **Invalid CSS**: Inject anyway (browser handles invalid CSS gracefully)
- **Style persistence**: Styles persist until page navigation
- **Script execution context**: Runs with full DOM access in page context

## Related User Stories

- US-029

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for this FR

**Test scenarios**:
- Inject valid script with return value
- Inject script modifying DOM
- Inject script with syntax error
- Inject script with runtime error
- Inject valid CSS styles
- Inject CSS modifying element appearance
- Verify style persistence within page
- Verify styles cleared on navigation

# FR-004: Web to Markdown Conversion

**Status**: Implemented

## Description

Provide MCP tool to fetch web content and convert to markdown using Jina Reader API.

## Interface

```python
async def web_to_md(url: str, timeout: int = 30) -> str:
    """Fetch web content as markdown.

    Args:
        url: URL to fetch
        timeout: Request timeout in seconds (default: 30)

    Returns:
        Markdown-formatted content

    Raises:
        httpx.TimeoutException: If request times out
        httpx.HTTPError: If request fails
    """
```

## Behavior

- **Given** a valid URL
- **When** web_to_md is invoked
- **Then** markdown content is returned from Jina Reader API

## Edge Cases

- **Invalid URL**: httpx raises error
- **Timeout exceeded**: Raises TimeoutException
- **API key missing**: Uses free tier if JINA_API_KEY not set
- **Network error**: httpx error propagation

## Related User Stories

- US-003

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% (internal httpx call)

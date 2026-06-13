# Web Operations

## WebFetch

**Purpose**: Fetch and analyze web content using an AI model.

**When to use**:
- Fetch and analyze public documentation
- Extract information from blog posts or articles
- Analyze web page content
- Convert HTML to markdown for processing
- **ONLY for public, unauthenticated URLs**

**When NOT to use**:
- ❌ Authenticated URLs (Google Docs, Confluence, Jira, private GitHub repos)
- ❌ URLs requiring login or access tokens
- Must use ToolSearch first to find specialized authenticated tools

**Authenticated URL alternatives**:

| Platform | Alternative approach |
|----------|---------------------|
| Private GitHub repos | `gh repo view`, `gh api`, `gh pr view`, `gh issue view` via Bash |
| Google Docs | Not directly supported — may need export links or API access |
| Confluence | Not directly supported — check for API access via CLI tools |
| Jira | Not directly supported — use `jira` CLI or API via Bash |
| Any authenticated service | Use Bash with appropriate CLI tools that handle auth (curl with headers, aws-cli, etc.) |

**Important limitations**:
- ⚠️ **WILL FAIL** for authenticated or private URLs
- Check if URL requires authentication **before** using WebFetch
- If MCP-provided web fetch tool is available, prefer it (may have fewer restrictions)

**Parameters**:
- `url` (required): Fully-formed valid URL (HTTP auto-upgraded to HTTPS)
- `prompt` (required): What information to extract or analyze from the page

**Usage examples**:

Extract specific information:
```json
{
  "url": "https://docs.python.org/3/library/asyncio.html",
  "prompt": "List all the coroutine functions mentioned with brief descriptions"
}
```

Summarize content:
```json
{
  "url": "https://fastapi.tiangolo.com/tutorial/first-steps/",
  "prompt": "Summarize the key steps to create a basic FastAPI application"
}
```

**How it works**:
1. Fetches URL content
2. Converts HTML to markdown
3. Processes content with prompt using a small, fast model
4. Returns the model's response

**Key features**:
- HTTP URLs automatically upgraded to HTTPS
- Handles redirects (reports redirect URL in special format for follow-up)
- Self-cleaning 15-minute cache for repeated access
- Read-only operation (doesn't modify any files)
- Results may be summarized if content is very large

**GitHub-specific guidance**:
- For GitHub URLs, **prefer** `gh` CLI via Bash instead
- Examples: `gh pr view <num>`, `gh issue view <num>`, `gh api repos/owner/repo/pulls`

---

## WebSearch

**Purpose**: Search the web and use results to inform responses with up-to-date information.

**When to use**:
- Information beyond Claude's knowledge cutoff (January 2025)
- Current events and recent developments
- Recent documentation or library updates
- Real-time information needs
- Technology updates in 2025-2026

**Availability**:
- ⚠️ Only available in the US

**Parameters**:
- `query` (required, min 2 chars): The search query
- `allowed_domains` (optional): Array of domains to exclusively include
- `blocked_domains` (optional): Array of domains to exclude

**Usage examples**:

Basic search (use current year for recent info):
```json
{
  "query": "FastMCP documentation 2026"
}
```

Filter to specific trusted domains:
```json
{
  "query": "Python asyncio tutorial",
  "allowed_domains": ["python.org", "realpython.com"]
}
```

Exclude unreliable sources:
```json
{
  "query": "JavaScript frameworks comparison",
  "blocked_domains": ["w3schools.com", "geeksforgeeks.org"]
}
```

**How it works**:
- Performs web search automatically within a single API call
- Returns search result blocks with links as markdown
- Results are formatted for easy integration into responses

**CRITICAL REQUIREMENT** — Sources section:
After answering the user's question, you **MUST** include a "Sources:" section:

```markdown
[Your answer here based on search results]

Sources:
- [Source Title 1](https://example.com/1)
- [Source Title 2](https://example.com/2)
- [Source Title 3](https://example.com/3)
```

**Important notes**:
- ⚠️ **Today's date is 2026-02-02** — use this year in queries for recent information
- Example: Search "React documentation 2026" NOT "React documentation 2025"
- **Never skip including sources** — this is mandatory for all WebSearch responses
- Domain filtering helps ensure quality results from trusted sources
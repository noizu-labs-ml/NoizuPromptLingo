# Web Operations Summary

| Tool | Purpose | Required Params |
|------|---------|-----------------|
| **WebFetch** | Fetch and analyze web content | `url`, `prompt` |
| **WebSearch** | Search the web for current info | `query` |

## Decision Guide: WebFetch vs WebSearch

**Use WebFetch when:**
- You have a specific URL to read
- You want to extract specific information from a known page
- You need to analyze documentation, blog posts, or articles
- The content is public and unauthenticated

**Use WebSearch when:**
- You need to find information but don't have a URL
- You need current/recent information beyond knowledge cutoff
- You want multiple sources on a topic
- You need domain filtering capabilities

**Key rules:**
- WebFetch: Does NOT support authenticated URLs (use gh CLI, aws-cli, etc. via Bash)
- WebSearch: MUST include "Sources:" section with markdown links in response
- Use current year (2026) in queries for recent information

---

**For expanded view:** [web-ops.md](web-ops.md) — Full documentation with authenticated URL alternatives, usage examples, and detailed parameter descriptions. Load for unfamiliar tools or edge cases.
---
id: US-067
title: "Search Tools by Semantic Intent"
slug: "search-tools-by-semantic-intent"
personas: [P-002]
epic: "Search & Discovery"
priority: "must-have"
complexity: "M"
tags: [mcp, discovery, semantic-search, weaviate]
---

# US-067: Search Tools by Semantic Intent

## User Story

**As an** Autonomous Coding Agent (Sable, P-002),
**I want to** run ToolSearch in semantic-intent mode with a natural-language description of what I'm trying to do,
**So that** I can find the right tool even when I don't know its exact name or the keywords it was registered under.

## Acceptance Criteria

- [ ] Given a Weaviate-backed embedding index is available for a server's tools, when ToolSearch is called with mode=semantic and a natural-language query (e.g. "how do I see who's watching a ticket"), then results are ranked by embedding similarity rather than literal substring match.
- [ ] Given the Weaviate index is unreachable or embeddings are not yet computed for a server's tools, when ToolSearch is called with mode=semantic, then the call transparently falls back to text-substring search and the response indicates the fallback occurred.
- [ ] Given a semantic query that plausibly matches tools across multiple domains (e.g. "notify me"), when ToolSearch is called against a single server, then only that server's tools are ranked and returned, not results from other domains' servers.

## Notes

Complexity M reflects the Weaviate-backed embeddings pipeline plus the graceful text-mode fallback (see US-066); implementation should reuse the elixir-weaviate integration patterns from the Noizu framework stack.

# Review: Search Tools by Semantic Intent

- **Story**: `project-management/user-stories/US-067-search-tools-by-semantic-intent.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend implements ToolSearch mode=intent as embedding-proximity ranking over `mcp_tool_vectors` in Postgres/pgvector, with per-scope indexing and a tagged text-search fallback (`backend/lib/noizu_prompt_lingua/tools/tool_search.ex:80-127`; store/indexer at `domains/mcp_overview/store.ex:224-226`, `domains/mcp_overview/indexer.ex`). Notable, explicitly documented divergence: the story specifies Weaviate, but the implementation uses Postgres/pgvector per the 2026-07-16 design instruction (`store.ex:13`). Fallback fires when embeddings are unconfigured, the scope is unindexed, or embedding fails, and the response carries `fallback: true` + `fallback_reason`. Server scoping holds: the catalog and vector scope derive from the calling server and `custom_scope_slug` ctx (`tool_search.ex:89-94,123-127`). The Python repo implements intent mode as LLM-powered selection with the same tagged fallback (`src/npl_mcp/meta_tools/search.py:136-178`). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| mode=semantic/intent ranks results by embedding similarity, not substring | Met | `backend/lib/noizu_prompt_lingua/tools/tool_search.ex:88-113` — `Embeddings.embed_one(query)` then `Store.nearest_tool_vectors(scope, vec)` ranks by distance; backend is pgvector, not Weaviate as the story names (documented divergence, `store.ex:13`) |
| Unreachable index / missing embeddings transparently falls back to text search with indication | Met | `tool_search.ex:80-86,109-121` — `Embeddings.configured?()` gate and `with ... else` both route to `text_fallback/4`, which sets `fallback: true` and `fallback_reason`; Python equivalent `src/npl_mcp/meta_tools/search.py:173-178` |
| Query spanning multiple domains returns only the target server's tools | Met | `tool_search.ex:89-90` — catalog built from the calling `server` only (Discovery excluded); vectors keyed by `scope_slug` from ctx (`:123-127`), so other domains' tools are never ranked |

## Gaps / Risks

- Story's parameter naming (`mode=semantic`) vs implementation (`mode=intent`, values `[:text, :intent]` at `tool_search.ex:15-19`) — callers following the story verbatim will get text mode silently (unknown enum values collapse to `_` → text).
- Weaviate/elixir-weaviate integration named in the story Notes is not what shipped; update the story or the design record to avoid confusion.
- `Indexer.refresh/2` is best-effort per query — first semantic query on a cold scope may silently degrade to fallback.

## BDD Scenario

```gherkin
Feature: Search tools by semantic intent

  Scenario: Agent finds a tool without knowing its name
    Given the embeddings provider is configured and the scope's tool vectors are indexed
    When the agent calls ToolSearch(mode="intent", query="how do I see who's watching a ticket")
    Then results are ranked by embedding distance (each match carries a distance value)
    And only tools registered on the calling server's catalog are returned

  Scenario: Embeddings unavailable
    Given the embeddings provider is unconfigured or the query embedding fails
    When ToolSearch is called with mode="intent"
    Then the response contains text-search matches with fallback=true and a fallback_reason string

  Scenario: Cross-domain leakage
    When a query like "notify me" plausibly matches tools on other domain servers
    And ToolSearch is called against a single server
    Then no tool from another domain appears in the results
```

# Review: Search knowledge and memory via pgvector similarity from MCP

- **Story**: `project-management/user-stories/US-406-pgvector-similarity-search-mcp.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No pgvector-backed similarity MCP tool exists. Important premise correction discovered during review: the platform's memory/knowledge similarity search is implemented and exposed as MCP tools, but it is **Weaviate-backed, not pgvector** — `backend/lib/noizu_prompt_lingua/domains/memory/vector_store.ex:2-4` states this explicitly ("Weaviate-backed store for the five named vectors per memory… This is the PRIMARY vector store for memory; there is no pgvector fallback"), with 1536-d named text vectors plus a 7-d emotional vector and HNSW indexing. The user-facing goal (semantically relevant, scoped, ranked retrieval from MCP) is served today by the memory tools (`backend/lib/noizu_prompt_lingua/domains/memory/tools/recall.ex`, `recall_by_emotion.ex`, `remember.ex`), which are org/scope-aware. However, the story's specific mechanism — server-side vector math over a pgvector column in the shared Postgres, with structured embedding-validation errors and a documented latency budget — has no implementation, and nothing in the codebase touches a pgvector column. Confidence: high (the Weaviate finding means the story's Notes premise "the shared Postgres already ships with pgvector [and agents would otherwise abuse the SELECT tool]" should be re-verified against actual infra before implementation).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Text/vector query returns nearest matches with similarity scores and source entity references | Partially Met | equivalent capability exists over Weaviate, not pgvector: `backend/lib/noizu_prompt_lingua/domains/memory/vector_store.ex` (named BYO vectors, HNSW) + MCP tools in `backend/lib/noizu_prompt_lingua/domains/memory/tools/recall.ex`; no pgvector path and no source-entity-ref contract as specified |
| Results confined to caller's tenant/session scope | Partially Met | memory tools carry org/scope fields (`recall.ex:12` org field, `scope_type` required) enforced at the tool layer — not US-403 SQL-layer scoping, but scope-aware |
| Invalid embedding (wrong dimensions, malformed) → structured error | Not Met | no evidence found for a pgvector tool; Weaviate path does BYO vectors with no dimension-validation contract visible |
| Empty/unindexed corpus → empty result set, not error | Not Met | no evidence found for the pgvector tool; Weaviate `recall` behavior on empty class not verified against this criterion |
| Bounded latency via index-backed ANN, top-k, documented latency budget | Partially Met | HNSW (ANN) and top-k semantics exist in the Weaviate path (`vector_store.ex` hnsw vectorIndexType); no pgvector index, and no documented latency budget anywhere |

## Gaps / Risks

- **Story premise check**: with Weaviate as the declared primary vector store, the cluster should decide whether US-406 is (a) a genuine pgvector column over Postgres, (b) a thin MCP wrapper formalizing the existing Weaviate memory tools, or (c) dropped as redundant. Implementing (a) creates a second vector store to keep in sync with Weaviate — a real consistency risk.
- If pgvector proceeds, embedding generation currently lives in the memory domain (`backend/lib/noizu_prompt_lingua/domains/memory/embeddings.ex`); the "embedding done in-service" requirement must specify which service owns it for the pgvector path.
- No latency budget is documented for the existing Weaviate path either — the documentation gap predates this story.

## BDD Scenario

```gherkin
Feature: pgvector similarity search MCP tool

  Scenario: Similarity query returns scored, referenced matches
    Given an embedding-backed knowledge corpus in Postgres
    When the agent queries the tool with "how do rotation credentials flow to k8s"
    Then it returns the top-k nearest matches with similarity scores
    And each match references its source entity (table, id, scope)

  Scenario: Results respect tenant scope
    Given the caller's session is scoped to org "acme"
    When a similarity search executes
    Then only content visible to "acme" is returned, regardless of ranking

  Scenario: Malformed vector input
    When the tool is submitted a 768-d vector against a 1536-d column
    Then it returns a structured error identifying the dimension mismatch
    And no partial search is executed

  Scenario: Empty corpus
    Given an org with no indexed content yet
    When a search runs
    Then an empty result set is returned (not an error)

  Scenario: Bounded latency on large corpus
    Given an HNSW-indexed pgvector column over 10M rows
    When a top-10 search runs
    Then it uses the index-backed ANN path
    And completes within the tool's documented latency budget
```

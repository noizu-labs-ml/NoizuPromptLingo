# Review: Queue and Rate-Limit Bulk Creative-Asset Generation

- **Story**: `project-management/user-stories/US-099-queue-rate-limit-bulk-creative-asset-generation.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Creative-asset generation exists but only as synchronous single-item generation: `backend/lib/noizu_prompt_lingua/domains/assets/content_generator.ex` (`generate/2` → `generate_from_config/2`, 275 lines) parses a `.media.prompt` YAML, injects context, and generates one asset on demand; sibling modules `genai_generator.ex` and `media_providers.ex` are likewise per-call. There is no bulk/batch submission path, no queue, and no rate limiting for this domain — grep for bulk/batch/concurrency/queue in `domains/assets/` returns nothing. Oban IS installed in the backend (`backend/lib/noizu_prompt_lingua/application.ex`) and already powers workers (`workers/memory/embedding_worker.ex`, `workers/session_inactivity_worker.ex`, `domains/memory/jobs.ex`), so the queueing primitive the story needs exists platform-side but is unused for asset generation. No per-item status view, queue position/ETA, or item-level retry exists anywhere in the assets domain. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Bulk request (e.g. 50 assets) enqueued and processed at bounded concurrency/rate | Not Met | `content_generator.ex:41-48` is one-shot synchronous; no batch entry point; no concurrency/rate limiter in `backend/lib/noizu_prompt_lingua/domains/assets/` |
| Batch status view: queued / in-progress / completed / failed counts without per-item polling | Not Met | No batch or batch-status entity/endpoint exists in the assets domain or its MCP surface (`domains/assets/mcp.ex`) |
| At-capacity requests wait in queue with visible position/ETA instead of failing | Not Met | No queue at all; generation either succeeds or fails immediately |
| Per-item failure reported so a single failed asset can be retried | Not Met | No item-level result tracking or retry path; `generate/2` returns a single success/error for a single asset |

## Gaps / Risks

- Could-have priority — correctly unimplemented so far, but the platform already runs Oban, so the implementation cost is moderate (a batch Oban workflow + per-item status records + a rate-limit middleware on the provider calls).
- Story's Notes expect reuse of "the rate-limiting primitive introduced in US-087" — no such primitive was found in the assets or generation paths; that dependency is also unmet.
- Media-provider API limits (per-org keys configured via `media_providers.ex`) are currently enforced only by the provider's own 429s — no client-side throttling or backoff, which is the exact failure mode this story guards against.
- No test coverage for any hypothetical queueing behavior (nothing to test yet).

## BDD Scenario

```gherkin
Feature: Queue and rate-limit bulk creative-asset generation

  Scenario: Growth operator submits a 50-asset campaign batch
    When Renee submits a bulk generation request of 50 assets
    Then the assets are enqueued and processed at bounded concurrency
    And the API responds immediately with a batch id
    # Today: FAILS — generation is synchronous and single-item (content_generator.ex:41).

  Scenario: Renee checks batch progress
    Given a batch is in flight
    When she views its status
    Then she sees counts of queued, in-progress, completed, and failed items
    Without polling each asset individually

  Scenario: Generation backend is saturated
    Given the provider is at capacity
    When a new bulk batch arrives
    Then its items wait in queue with a visible position or ETA
    Rather than failing outright

  Scenario: One asset in the batch fails
    When a single asset's generation errors while the rest complete
    Then the failure is recorded per-item
    And Renee can retry just that item
```

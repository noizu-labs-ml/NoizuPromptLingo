# Review: Build a Mock MCP Server from a Prose Description

- **Story**: `project-management/user-stories/US-103-mock-mcp-server-from-prose-description.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented on the Elixir backend as the MockMCP domain. LLM-driven generation from prose exists in `backend/lib/noizu_prompt_lingua/domains/mock_mcp/agent.ex` (the `@surface_gen_system_prompt` at :27 instructs the model to emit tools/resources/prompts with JSON-Schema `inputSchema`, private `handler` instructions, and a backing-store `schema`). Lifecycle management (`backend/lib/noizu_prompt_lingua/domains/mock_mcp/mock_mcp.ex`) supports create/update/activate/archive by slug (`:17-78`), tool/surface/module updates (`:80-139`), LLM connection config (`:150-196`), and call logging (`:198-217`). A full MCP JSON-RPC gateway serves live mocks at `mockmcp.<host>/mcp/{slug}/mcp` (`backend/lib/noizu_prompt_lingua_web/plugs/mock_mcp_gateway.ex`), exposing only the mock's generated tools, reporting `serverInfo.name = "mock-#{slug}"` (:99), refusing non-active definitions (:310-317), and executing deterministic "module" tools for real via `ModuleRuntime`/`ModuleForge`. Test coverage exists (`backend/test/noizu_prompt_lingua/domains/mock_mcp/mock_mcp_test.exs`, `noizu_prompt_lingua_web/plugs/mock_mcp_gateway_test.exs`, `.../controllers/mock_mcp_controller_test.exs`, `.../mock_mcp_gateway_controller_test.exs`, gateway surface tests). Regeneration/update preserves the slug, so the agent's endpoint identifier never changes.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Prose description → generated tool catalog (names, parameter schemas, example behavior) shown for review before serving | Met | `agent.ex:27+` generates catalog with inputSchema + private handlers; `mock_mcp.ex:60-67` activate/archive gating — a definition must be activated before the gateway serves it (`mock_mcp_gateway.ex:310-317` rejects non-active); "shown for review" is via definition management surface rather than an explicit diff view |
| Approved mock is discoverable/callable exactly like a real MCP server | Met | `mock_mcp_gateway.ex` implements the MCP JSON-RPC surface (initialize/tools/list/tools/call/resources/prompts) on a dedicated endpoint; module-backed tools execute against a real backing store |
| Mock clearly labeled as mock/test, never merged into production catalog | Met | Served only on the `mockmcp.<host>` gateway; `serverInfo.name` prefixed `mock-` (`mock_mcp_gateway.ex:99`); only the mock's own generated tools are exposed (:112), separate from the platform's production tool catalog |
| Regeneration after prose edits updates the catalog without a new endpoint/identifier | Met | `mock_mcp.ex:41-51` `update/2` and `:80-139` set_tools/set_surface/set_modules mutate by slug; endpoint remains `/mcp/{slug}/mcp` |

## Gaps / Risks

- SSE transport is unimplemented for mocks — the gateway returns 501 for GET (`mock_mcp_gateway.ex:32`), so streamable-HTTP clients work but SSE-only clients do not.
- LLM-fabricated responses depend on the configured active LLM (`active_llm_opts`); a missing/misconfigured LLM connection will degrade tool-call fidelity.
- "Shown for review" is status-gating, not a human review UI; approval is effectively whoever can call activate.
- Mock call logs (`log_call`) provide auditing, but there is no evidence of rate/cost limiting on LLM-backed mock calls.

## BDD Scenario

```gherkin
Feature: Generate and serve a mock MCP server from prose

  Scenario: Jordan generates a mock from a description
    Given Jordan submits prose describing a fake "orders" MCP server
    When the platform's MockMCP agent processes it
    Then a tool catalog is generated with names, JSON-Schema inputs, and private response handlers
    And the definition is stored inactive until approved

  Scenario: Sable connects an agent to the live mock
    Given the mock definition "orders" has been activated
    When the Autonomous Coding Agent connects to mockmcp.<host>/mcp/orders/mcp
    Then it completes MCP initialize, lists the mock's tools, and calls them
    And deterministic tools return real results from the mock's backing store
    And the server identifies itself as "mock-orders"

  Scenario: Production catalog isolation
    Given the mock "orders" is live
    When any platform catalog or tool search runs
    Then the mock's tools appear only through the mockmcp gateway
    And never in the production tool catalog

  Scenario: Regenerate after editing the prose
    When Jordan updates the description and regenerates the surface for slug "orders"
    Then the tool catalog is replaced
    And agents keep using the same endpoint /mcp/orders/mcp without reconnecting elsewhere
```

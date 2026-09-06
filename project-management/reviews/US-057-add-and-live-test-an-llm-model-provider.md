# Review: Add and Live-Test an LLM Model Provider

- **Story**: `project-management/user-stories/US-057-add-and-live-test-an-llm-model-provider.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend has an editable `llm_models` catalog with admin CRUD (`backend/lib/noizu_prompt_lingua/domains/mock_mcp/models.ex:136-165`, schema `backend/lib/noizu_prompt_lingua/schema/llm_model.ex:14-20` with provider/model/label/endpoint/enabled/sort_order/notes) wired to admin routes in `backend/lib/noizu_prompt_lingua_web/controllers/admin_controller.ex:532-595`, plus genuine live connectivity testing (`test_llm_configuration`, `admin_controller.ex:720-767`, e.g. `test_openai_inference` at :798-809 performs a real minimal chat completion) and provider model listing (:710-744). However: catalog entries carry **no per-model API key** (testing uses platform env vars via `get_openai_api_key/0` etc.), there is **no connectivity status field** (nothing persists "untested"/"connected"/"failed"), and **no enable-time warning** for untested models. Frontend page: `frontend/src/app/app/admin/llm-models/page.tsx`.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Add model entry (provider, model ID, API key) → appears in catalog with "untested" status | Partially Met | catalog CRUD exists (`admin_controller.ex:537-548`; `models.ex:147-151`) but `model_attrs/1` (`admin_controller.ex:579-581`) accepts no API key and `schema/llm_model.ex` has no connectivity-status field |
| "Test connectivity" makes a live call and updates status to connected/failed with provider error detail | Partially Met | `test_llm_configuration` (`admin_controller.ex:720-731`) makes real provider calls and returns success/error detail, but the result is never persisted to the catalog entry (no status column to update) |
| Saved API key displayed masked, never plaintext | Not Met | no per-model API key is stored at all; live tests use env-var keys (`admin_controller.ex:771-773, 1100-1102`) |
| Enabling a failed/untested model warns that connectivity testing has not passed | Not Met | `enabled` is a plain boolean toggle (`admin_controller.ex:550-564`, `models.ex:153-158`) with no connectivity precondition or warning |

## Gaps / Risks

- Credential model mismatch: story expects per-model stored keys; implementation delegates to platform-level env vars / GenAI provider config, so org-independent per-model credentials are impossible.
- Because test results are ephemeral, "connected" claims cannot be audited later; the live test is repeatable but not recorded.
- Provider roster differs from the story's fixed set: handlers exist for openai/anthropic/groq/openrouter/cerebras/deepseek/ollama plus more in `Models.resolve/2` (`models.ex:192-235`), but unsupported providers silently return "Configuration validated" (`admin_controller.ex:764`).

## BDD Scenario

```gherkin
Feature: Admin adds and live-tests an LLM model

  Scenario: Add a catalog entry
    Given Ilya is on the admin model catalog page
    When he adds provider "anthropic", model "claude-sonnet-5", and saves
    Then the entry appears in the catalog (no "untested" status shown — gap)

  Scenario: Live connectivity test
    When Ilya triggers the configuration test for the model
    Then the system performs a real minimal chat completion against the provider
    And returns success or the provider's error detail (not persisted to the entry)

  Scenario: View stored API key
    Given Ilya views the catalog
    Then no per-model key is shown because none can be stored (gap)
```

# PRD-020: MCP Endpoint UX Overhaul

**Version:** 1.0
**Status:** Approved (decisions locked by controller; encode, do not re-open)
**Owner:** npl-prd-editor
**Created:** 2026-09-06
**Epics:** MCP Endpoint UX Overhaul
**Stories:** US-105, US-106, US-107, US-108, US-109, US-110, US-111, US-112, US-113, US-114
**Personas:** P-009 Quinn Harper (Endpoint Composer, primary), P-001, P-006

---

## Overview

Quinn (P-009) composes purpose-built MCP endpoints — curated tool sets served
under a stable slug — but today has no user-facing path to clone a built-in
template, no guided creation flow, no inline slug feedback, and no way to get a
sensible tool set proposed from a plain-language description. This PRD covers
the whole epic as one specification:

1. **Clone** built-in templates (`tobor`, `core`) and own endpoints from the
   user-facing endpoint manager, with caller-supplied slug/name/description.
2. **Guided creation wizard** (3 steps): name/description/slug → LLM
   clarifying questions (skippable) → review proposed tools with
   Enabled/Visible toggles → create.
3. **Manual tool picker** as a first-class path: explicit "pick tools
   manually", plus automatic fallback whenever the LLM is unavailable.
   Creation is never blocked by LLM failure.
4. **Inline slug validation** via a cheap availability-check endpoint.
5. **Admin adoption** (US-114): the admin `mcp-custom-scopes` editor reuses
   the shared stepper, clone dialog, and tool picker.

### Locked decisions (controller — do not re-open)

| # | Decision |
|---|----------|
| D1 | Target model is `mcp_custom_scopes` served via `/api/v1/auth/mcp/endpoints` (`McpEndpointsController` / `MCPCustomScopes`). `mcp_tool_sets` is **out of scope**; kit components must remain domain-neutral so a future `mcp_tool_sets` editor can adopt them unchanged. |
| D2 | Wizard is exactly 3 steps: (1) name/description/slug, (2) LLM clarifying questions, (3) review proposed tools (toggle) → create with proposed tools **enabled + visible**. Step 2 is skippable to the manual picker; on LLM unavailability the wizard falls back to the manual picker automatically. |
| D3 | New backend endpoints: `POST /api/v1/auth/mcp/endpoints/propose-tools` and `GET /api/v1/auth/mcp/endpoints/slug-available` (full contracts in FR-2 / FR-1). `llm_unavailable` is **HTTP 200**, never 5xx, so the client falls back. |
| D4 | Proposals are grounded: filtered to names present in the catalog (`NoizuPromptLingua.Tools.Catalog.build/2` over the universe toolset); invented names are dropped. Implementation uses the `genai` lib following the precedent in `NoizuPromptLingua.Domains.MockMCP.Agent` (LLM call) and may pre-rank candidates with the existing `mcp_tool_vectors` / ToolSearch `:intent` mode to keep the prompt small. |
| D5 | Clone reuses existing copy semantics (`MCPCustomScopes.copy/2`, create with `source_slug` / `source_id`) with caller-supplied slug/name/description; surfaced in the user endpoint manager for both templates and own endpoints. |
| D6 | Frontend: new kit component `frontend/src/components/kit/wizard-stepper.tsx` (domain-neutral), new `frontend/src/components/mcp-config/endpoint-wizard.tsx`, API client functions in `frontend/src/lib/api.ts` near the existing mcp endpoints client (~line 2742). Contract tests run via the node test runner (`npm run test:contracts`). |
| D7 | Tests: backend ExUnit under `backend/test/` (controller test for `mcp_endpoints_controller` incl. new routes; unit test for the proposal module with the LLM call mocked/injected); frontend contract tests for pure logic (slug derivation, proposal→config mapping, wizard state reducer). Coverage ≥ 80% for new code. |
| D8 | **No DB schema changes.** Tool enable/visibility already rides the `mcp_custom_scopes.config` jsonb (`groups.<group>.tools.<tool>.{disabled,hidden,…}`). None of the FRs below requires a migration; if an implementation discovers otherwise it must stop and escalate with the exact schema delta. |

---

## User Stories

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| [US-105](../user-stories/US-105-clone-builtin-template-from-endpoint-manager.md) | Clone a built-in template from the endpoint manager | P-009, P-001 | must-have |
| [US-106](../user-stories/US-106-clone-own-endpoint.md) | Clone an own endpoint with its tool configuration | P-009, P-001 | must-have |
| [US-107](../user-stories/US-107-wizard-stepper-kit-component.md) | Reusable wizard/stepper component in the frontend kit | P-009, P-001 | must-have |
| [US-108](../user-stories/US-108-wizard-step1-name-description-slug.md) | Wizard step 1: name, description, auto-slug | P-009 | must-have |
| [US-109](../user-stories/US-109-propose-tools-api.md) | Backend propose-tools API | P-009, P-001 | must-have |
| [US-110](../user-stories/US-110-wizard-step2-clarifying-questions.md) | Wizard step 2: LLM clarifying questions | P-009 | must-have |
| [US-111](../user-stories/US-111-wizard-step3-review-proposed-tools-create.md) | Wizard step 3: review proposed tools, toggle, create | P-009, P-001 | must-have |
| [US-112](../user-stories/US-112-manual-tool-picker-llm-fallback.md) | Manual tool picker with LLM-unavailable fallback | P-009, P-001 | must-have |
| [US-113](../user-stories/US-113-slug-availability-check-endpoint.md) | Slug availability check endpoint | P-009, P-001 | should-have |
| [US-114](../user-stories/US-114-admin-reuse-of-wizard-and-picker.md) | Admin editor reuses clone flow, wizard, and picker | P-006, P-009 | should-have |

(Indexed stories only, per `user-stories/index.yaml`; stray unindexed files
with colliding IDs are out of scope.)

---

## Goals

1. Template/own-endpoint clone is fully user-facing: prefilled, validated,
   cancel-safe, never a 403 dead end.
2. Endpoint creation from scratch takes under two minutes without knowing the
   catalog: describe the job, answer a few questions, review, create.
3. Every failure path still lands on a working manual flow (never a partial
   or malformed success; never blocked creation).
4. One set of reusable UI components serves user manager, creation wizard,
   and admin editor.

## Non-Goals

- Any `mcp_tool_sets` surface (endpoints, editors, or data changes).
- DB schema changes (see D8).
- Changes to MCP gateway routing, auth flows, or JWT/key minting.
- Changes to the existing endpoint CRUD contracts beyond what FR-3 states.
- Admin-only capabilities (owner assignment, template management surfaces)
  moving into shared/user-facing components.
- Streaming responses from the proposal endpoint.

---

## Functional Requirements

### FR-1: Slug availability endpoint (US-113)

**Route** (declared inside the existing authenticated `/api/v1` scope —
`pipe_through [:api, :authenticated]` — and **before**
`get "/auth/mcp/endpoints/:id"` so `:id` cannot capture `slug-available`):

```elixir
get  "/auth/mcp/endpoints/slug-available", McpEndpointsController, :slug_available
post "/auth/mcp/endpoints/propose-tools",  McpEndpointsController, :propose_tools
```

**Controller action**

```elixir
@spec slug_available(Plug.Conn.t(), map()) :: Plug.Conn.t()
def slug_available(conn, params)   # slug read from params["slug"] (query string)
```

**Request** `GET /api/v1/auth/mcp/endpoints/slug-available?slug=my-endpoint`

**Response 200** — exactly one of:

```json
{"available": true}
{"available": false, "reason": "invalid"}
{"available": false, "reason": "reserved", "suggestion": "tobor-2"}
{"available": false, "reason": "taken", "suggestion": "my-endpoint-2"}
```

`reason` and `suggestion` are **omitted** when `available` is true.

**Semantics** (evaluated in this order):

1. Normalize: `String.trim/1 |> String.downcase/1` (mirrors the schema's
   `normalize_slug/1`).
2. `invalid` — normalized slug fails `^[a-z0-9][a-z0-9-]{0,62}$`
   (`MCPCustomScope` changeset format). No `suggestion`.
3. `reserved` — normalized slug ∈ `MCPCustomScopes.reserved_slugs/0`
   (`["tobor", "core"]` — new one-line context accessor over the existing
   `@default_package_slug` / `@core_variant_slug` module attributes).
4. `taken` — `MCPCustomScopes.get_by_slug/1` returns a row.
5. `available` — otherwise.

**Suggestion algorithm** (only for `reason` ∈ `["taken", "reserved"]`,
deterministic): try `String.slice("#{slug}-#{n}", 0, 63)` for `n` in 2..9;
return the first candidate that is valid per the regex, not reserved, and not
taken. Omit `suggestion` if no candidate qualifies.

**Errors**: 401 `{"error": "authentication required"}` when unauthenticated;
422 `{"errors": {"slug": ["is required"]}}` when the slug param is missing or
blank. No naked 404s/500s for malformed input.

**Performance**: single indexed lookup (unique index `uq_mcp_custom_scopes_slug`);
p95 ≤ 100 ms.

**Client integration**: debounced ~300 ms from the shared slug field; on
endpoint failure or timeout the UI degrades silently to submit-time conflict
handling (409 or 422-with-`errors.slug` surfaced inline, form state preserved).

### FR-2: Propose-tools endpoint (US-109, consumed by US-110/111)

**Route**: see FR-1 (`propose_tools` action).

**Controller action**

```elixir
@spec propose_tools(Plug.Conn.t(), map()) :: Plug.Conn.t()
def propose_tools(conn, params)
```

**Request** (POST, JSON):

```json
{
  "name": "Support bot",
  "description": "Answers support questions and files tickets",
  "answers": [{"question_id": "r1-1", "answer": "Read-only is fine"}]
}
```

- `name` optional, string ≤ 120 chars.
- `description` required, non-blank, ≤ 2000 chars.
- `answers` optional list ≤ 8 entries; `question_id` string ≤ 64 chars;
  `answer` string ≤ 1000 chars.

**Response 200** — discriminated by `status`, exactly one of:

```json
{"status": "questions", "questions": [
  {"id": "r1-1", "prompt": "Who will call this endpoint?",
   "kind": "single", "options": ["Human agents", "An automated agent"]}
]}
```

```json
{"status": "proposal", "summary": "A focused support toolkit.",
 "tools": [
   {"name": "Ticket_Create", "group": "tickets",
    "rationale": "Files tickets from the conversation."},
   {"name": "Wiki_Search", "group": "wiki",
    "rationale": "Finds published answers."}
 ]}
```

```json
{"status": "llm_unavailable"}
```

- `questions`: 1–4 entries. `kind` ∈ `"single" | "multi" | "text"`;
  `options` (array of strings) present iff `kind` ≠ `"text"`. `id` is
  server-minted (`r<round>-<n>`, round ∈ 1..2 — see FR-3 round accounting).
- `proposal`: 1–25 tools. `name` is the canonical catalog tool name;
  `group` is the group **id** from `MCPCustomScopes.catalog/0` that contains
  the tool (server-resolved, never LLM-supplied — see FR-3); `rationale` is a
  1–2 sentence string. Proposed tools default to enabled + visible on the
  client.
- `llm_unavailable`: **HTTP 200** (D3). Returned for every LLM-path failure:
  timeout, exception, unusable/garbage payload, or empty set after grounding.

**Errors**: 401 unauthenticated (existing `unauthorized/1` shape); 422
`{"errors": {...}}` for structural violations of the size limits above
(malformed `question_id`s inside an otherwise valid payload are dropped
silently, not rejected). Any LLM-path failure is **never** 4xx/5xx — it is
`200 {"status": "llm_unavailable"}`.

**Request limits** are enforced before the LLM is called.

**Latency budget**: LLM call timeout 8 s; endpoint p95 target ≤ 10 s. The
frontend request timeout must exceed it (15 s) so a timeout also lands on the
fallback path.

### FR-3: `NoizuPromptLingua.MCP.ToolProposer` (US-109)

New module `backend/lib/noizu_prompt_lingua/mcp/tool_proposer.ex`. The LLM
call follows the `MockMCP.Agent` precedent (`GenAI.chat/0` →
`with_model/2` → `with_messages/2` → `run/1`, custom-endpoint HTTP variant
included), but is **injected for tests** via application config:

```elixir
# default: genai-backed runner (MockMCP.Agent pattern)
# test seam: {Module, function} invoked as apply(mod, fun, [messages, opts])
Application.get_env(:noizu_prompt_lingua, :tool_proposer_llm, nil)
```

**Public API**

```elixir
@type question :: %{
  required(:prompt) => String.t(),
  required(:kind) => :single | :multi | :text,
  optional(:options) => [String.t()]
}
@type answer :: %{required(:question_id) => String.t(), required(:answer) => String.t()}
@type proposed_tool :: %{required(:name) => String.t(), required(:rationale) => String.t()}

@spec propose(String.t() | nil, String.t(), [answer()], keyword()) ::
        {:ok, {:questions, [question()]}}                       # round 1 (or 2) questions
        | {:ok, {:proposal, %{tools: [map()], summary: String.t()}}}
        | {:error, :llm_unavailable}
def propose(name, description, answers, opts \\ [])
```

`opts`:

- `:llm` — `{module, atom}` runner override (else the app-env seam above, else
  the genai default). Runner contract: `apply(mod, fun, [messages, opts]) ::
  {:ok, String.t()} | {:error, term()}` where the ok text is a JSON object.
- `:ranker` — `(String.t(), pos_integer()) -> [String.t()]` candidate-name
  pre-ranker (default `ranker/2`, below). Tests inject a fixed list.
- `:max_questions` — default 4. `:timeout` — default 8000 ms.

**Behavior**

1. **Round accounting (stateless)**: `answers == []` → ask the LLM for up to
   `:max_questions` clarifying questions; mint ids `r1-1..r1-4` server-side.
   Answers whose ids all start `r1-` → the LLM may return one more questions
   round (ids minted `r2-*`) or a proposal. Any answer id starting `r2-` →
   the LLM is instructed to propose; if it returns questions anyway, retry
   once with a strict proposal instruction, else `{:error, :llm_unavailable}`.
   Question ids are validated against `~s(r[12]-[a-z0-9-]{1,32})`; entries
   failing this are dropped from `answers`.
2. **Candidate pre-ranking** (default `ranker/2`): embed `description +
   flattened answers` and rank via the existing vector plumbing used by
   ToolSearch `:intent` (`MCPOverview.Indexer.refresh/2` under scope
   `"endpoint-wizard"`, then `MCPOverview.Store.nearest_tool_vectors/3`,
   limit 24). When embeddings are unconfigured, fall back to the full
   customizable-catalog name list. The ranked shortlist (plus category
   summaries) is what enters the prompt — never the raw full catalog dump.
3. **Grounding (D4 — hard rule)**: proposal names are canonicalized via
   `NoizuPromptLingua.MCP.ToolNames.canonical/1`, then intersected with the
   universe catalog (`Tools.Catalog.build/2`, default universe server) **and**
   with `MCPCustomScopes.catalog/0` group membership (so every surviving tool
   has a server-resolvable `group` id). Invented names, Discovery-category
   tools, and tools outside every customizable group are dropped. The
   response's `group` field is always derived server-side from this
   membership — the LLM never supplies it.
4. **Unusable outcomes** → `{:error, :llm_unavailable}`: runner error/timeout,
   non-JSON or schema-invalid payload, questions round > 2, or a proposal
   whose grounded tool set is empty. Never a partial success.

### FR-4: Clone from the endpoint manager (US-105, US-106)

**Backend delta (the only change to existing copy semantics; additive):**

- `MCPCustomScopes.copy/2` gains config passthrough for the wizard path:

```elixir
"config" => Map.get(attrs, "config") || %{"groups" => groups_from(source)}
```

  Clone behavior without `config` is byte-identical to today.
- `McpEndpointsController.create/2` `copy_attrs/1` take-list gains
  `"config"` (so `POST /api/v1/auth/mcp/endpoints` accepts an explicit
  per-tool config payload — required by US-111; the clone dialog never sends
  one).
- Slug conflicts keep the current changeset behavior (422 with
  `errors.slug`); the client treats 409 **or** 422-with-`errors.slug` as an
  inline slug conflict. No new status codes.

**Frontend** (`frontend/src/components/mcp-endpoint-manager.tsx`):

- Template rows (and the read-only "copy it to edit" dead-end message) gain a
  Clone affordance; own endpoints (and org endpoints where `editable`) gain a
  Clone affordance on row/detail.
- Clone opens the shared clone dialog (the same field component as wizard
  step 1): slug/name/description prefilled from the source (`name` =
  `"Copy of " <> source.name`), all three editable.
- Submit: `api.createMcpEndpoint({source_slug, name, slug, description})` for
  templates; `{source_id, …}` for own endpoints. Cancel closes without
  creating anything.
- Config carries over verbatim via `copy/2` (`groups_from(source)`); the new
  row is fully independent (fresh row + fresh jsonb) — no propagated edits.

### FR-5: Kit `WizardStepper` (US-107)

New `frontend/src/components/kit/wizard-stepper.tsx` — pure controlled,
domain-neutral (no MCP/backend imports), exported from
`frontend/src/components/kit/index.ts`.

```ts
export interface WizardStepDef<S> {
  id: string;
  title: string;
  description?: string;
  /** Gate for Next/Finish on this step; absent = always valid. */
  isValid?: (state: S) => boolean;
  invalidMessage?: string;
}

export interface WizardStepperProps<S> {
  steps: readonly WizardStepDef<S>[];
  /** Host-owned wizard state; the stepper never mutates it. */
  state: S;
  /** 0-based index of the active step. */
  currentStep: number;
  /** Back/Next/step-click; called only when the transition is allowed. */
  onStepChange: (nextStep: number) => void;
  /** Renders the active step's body. */
  renderStep: (step: WizardStepDef<S>, index: number) => ReactNode;
  onCancel?: () => void;
  cancelLabel?: string;   // default "Cancel"
  backLabel?: string;     // default "Back"
  nextLabel?: string;     // default "Next"
  finishLabel?: string;   // default "Finish"
  ariaLabel?: string;     // default "Wizard"
}
```

Behavior:

- Next (or Finish on the last step) is disabled while
  `steps[currentStep].isValid?.(state) === false`; the step's
  `invalidMessage` is shown. Back is disabled at step 0.
- Forward navigation is sequential; completed previous steps are directly
  clickable. All state survives Back/Forward (host owns it).
- Accessibility: `aria-current="step"` on the active marker, a programmatic
  `Step {n} of {total}` progress indicator, focus moved to the step heading on
  step change, native-button keyboard operation, transitions disabled under
  `prefers-reduced-motion: reduce`.
- `onCancel` is the consumer's clean discard hook.

Kit export:

```ts
export { default as WizardStepper } from './wizard-stepper';
export type { WizardStepperProps, WizardStepDef } from './wizard-stepper';
```

### FR-6: Endpoint creation wizard (US-108, US-110, US-111)

New `frontend/src/components/mcp-config/endpoint-wizard.tsx`, composed from
`WizardStepper`, plus a pure logic module
`frontend/src/components/mcp-config/endpoint-wizard-state.ts` (the contract
test target):

```ts
export interface WizardToolSelection {
  name: string; group: string; rationale?: string;
  enabled: boolean; visible: boolean;
}

export interface EndpointWizardState {
  mode: 'create' | 'clone';
  source?: { id?: string; slug?: string; kind: 'template' | 'own' };
  name: string; description: string; slug: string; slugTouched: boolean;
  slugStatus: SlugAvailabilityResponse | null;
  questions: ClarifyQuestion[];
  answers: Record<string, string | string[]>;
  selections: WizardToolSelection[];
  proposalSummary: string | null;
  status: 'idle' | 'loading-questions' | 'loading-proposal' | 'fallback' | 'submitting';
  error: string | null;
}

export function deriveSlug(name: string): string;
export function reduceWizard(state: EndpointWizardState, action: WizardAction): EndpointWizardState;
export function applyProposal(state: EndpointWizardState, tools: ProposedTool[], summary: string): EndpointWizardState;
export function proposalToConfig(selections: WizardToolSelection[]): McpCustomScopeConfig;
```

**Step 1** — name + description ("What is this endpoint for?") + slug.
Description is required (it drives the proposal). Slug auto-derives from name
while `!slugTouched` (`deriveSlug`: lowercase, `[^a-z0-9]+` → `-`, collapse,
trim `-`, cap 63; empty string when nothing valid survives); the first manual
slug keystroke sets `slugTouched` permanently. Inline regex validation and
debounced `slug-available` feedback shared with the clone dialog. Continue
disabled without valid name-derivable slug + non-empty description. When the
wizard was entered via Clone, fields prefill from the source and Continue
skips steps 2–3 (straight to submit).

**Step 2** — presents FR-2 `questions` inline; skipped questions are omitted
from the request; explicit **"Pick tools manually"** option up front (D2).
Continue fires `proposeEndpointTools` (answers verbatim); a pending proposal
shows loading and is cancellable; `llm_unavailable` or timeout routes to the
manual picker with name/description/answers preserved and a visible
explanation (D3/D2).

**Step 3** — each proposed tool listed with name, rationale, and
Enabled/Visible toggles; defaults enabled + visible; "Add more" opens the
manual picker (FR-7) and merges additions into the same list; Back/Forward
preserves selections. Create submits a single
`POST /api/v1/auth/mcp/endpoints`:

```json
{"endpoint": {
  "name": "Support bot", "description": "…", "slug": "support-bot",
  "config": {"groups": {"tickets": {"tools": {"Ticket_Create": {}}}}}
}}
```

`proposalToConfig` maps each selection to
`config.groups[group].tools[name]`: `{}` when enabled+visible,
`{"disabled": true}` / `{"hidden": true}` / both otherwise (inverted storage
semantics: the store keeps disable/hide flags). Unconfigured tools default
enabled + visible server-side. On create failure (e.g. slug conflict) the
wizard stays on step 3, error inline, no state lost. Create success closes
the wizard and refreshes the manager list.

### FR-7: Manual tool picker (US-112)

New standalone `frontend/src/components/mcp-config/tool-picker.tsx`
(wizard-decoupled; embeddable by the editor and admin page):

```ts
export interface ToolPickerProps {
  catalog: McpCustomGroup[];                    // from api.mcpCatalog()
  selected: Record<string, boolean>;            // keyed by canonical tool name
  onConfirm: (names: string[]) => void;
  onCancel?: () => void;
  title?: string;
  fallbackNotice?: string | null;               // shown when routed via llm_unavailable
}
```

Lists tools with name, group label, and description; text search + group
filter; confirm returns the selected canonical names, which the wizard merges
into its selection list with toggles. When reached as the LLM fallback, the
`fallbackNotice` explains why and all wizard state above is preserved.

### FR-8: API client (`frontend/src/lib/api.ts`, near line 2742)

```ts
export interface ClarifyQuestion {
  id: string; prompt: string; kind: 'single' | 'multi' | 'text'; options?: string[];
}
export interface ProposedTool { name: string; group: string; rationale: string; }
export type ProposeToolsResponse =
  | { status: 'questions'; questions: ClarifyQuestion[] }
  | { status: 'proposal'; tools: ProposedTool[]; summary: string }
  | { status: 'llm_unavailable' };
export interface SlugAvailabilityResponse {
  available: boolean;
  reason?: 'taken' | 'reserved' | 'invalid';
  suggestion?: string;
}

// api object additions:
proposeEndpointTools(input: {
  name?: string; description: string;
  answers?: { question_id: string; answer: string }[];
}): Promise<ProposeToolsResponse>;
// POST /api/v1/auth/mcp/endpoints/propose-tools  (body {endpoint-ish flat input})

checkSlugAvailable(slug: string): Promise<SlugAvailabilityResponse>;
// GET /api/v1/auth/mcp/endpoints/slug-available?slug=…
```

`createMcpEndpoint`'s input type gains `slug?: string` and
`config?: McpCustomScopeConfig` (backend already/now accepts both; see FR-4).

### FR-9: Admin adoption (US-114)

`frontend/src/app/app/admin/mcp-custom-scopes/page.tsx` replaces its private
`cloneScope` (~line 400) and any ad-hoc creation UI with the shared clone
dialog, `EndpointWizard`, and `ToolPicker`. The existing per-tool
Enabled/Visible table editor keeps working without regression; admin-only
capabilities (owner assignment, template management) remain in the admin
shell and never leak into the shared components (variant/prop customization
only).

---

## Error Handling

| Condition | Surface | Response / Behavior |
|---|---|---|
| Unauthenticated call to either new endpoint | Both | 401 `{"error": "authentication required"}` (existing helper) |
| Missing/blank `description`, or size-limit violation | propose-tools | 422 `{"errors": {...}}` — LLM never called |
| LLM timeout / exception / garbage payload / empty grounded set | propose-tools | **200** `{"status": "llm_unavailable"}` → wizard routes to manual picker with state preserved |
| Round-2 answers but model returns questions twice | propose-tools | 200 `{"status": "llm_unavailable"}` |
| Malformed `question_id` in answers | propose-tools | entry dropped silently; remaining valid answers processed |
| Missing/blank `slug` param | slug-available | 422 `{"errors": {"slug": ["is required"]}}` |
| Slug fails regex | slug-available + UI | `{"available": false, "reason": "invalid"}` + inline format message; Create disabled |
| Slug taken/reserved | slug-available + UI | inline uniqueness feedback (+ suggestion chip); Create disabled |
| Conflict reaches server anyway (create) | clone/wizard | 409 or 422-with-`errors.slug` surfaced inline; form/wizard state intact |
| `slug-available` endpoint unreachable | UI | silent degrade to submit-time conflict handling |
| Template edit attempt | manager | messaging offers the Clone entry point instead of dead-ending |

---

## Non-Functional Requirements

| ID | Requirement | Metric / Target |
|----|-------------|-----------------|
| NFR-1 | Coverage on all new code (backend + frontend logic modules) | ≥ 80%; 100% for proposal grounding and slug validation decision paths |
| NFR-2 | propose-tools latency budget | LLM timeout 8 s; p95 ≤ 10 s |
| NFR-3 | slug-available cost | single indexed lookup, p95 ≤ 100 ms, no scans |
| NFR-4 | Accessibility of stepper/wizard/picker | WCAG 2.2 AA: keyboard operable, focus management, `aria-current="step"`, visible focus, reduced-motion respected |
| NFR-5 | Domain neutrality of kit components | `wizard-stepper.tsx` imports no MCP/backend modules (contract-tested) |
| NFR-6 | Prompt hygiene | LLM prompt carries only user-supplied name/description/answers + candidate shortlist; no secrets, no full catalog dump |
| NFR-7 | Proposal safety | proposals ⊆ catalog, group ids server-resolved — an LLM cannot enable a nonexistent tool or mis-bucket a real one |

---

## Acceptance Tests

Backend (ExUnit; extend
`backend/test/noizu_prompt_lingua_web/controllers/mcp_endpoints_controller_test.exs`,
new `backend/test/noizu_prompt_lingua/mcp/tool_proposer_test.exs`; LLM injected
via the `:tool_proposer_llm` app-env seam, cleaned up in `on_exit`):

- **AT-1** slug-available: available / taken / reserved (`tobor`, `core`) /
  invalid; suggestion appended, clamped to 63 chars, skips collisions;
  401 unauthenticated; 422 missing slug.
- **AT-2** propose-tools questions round: mock runner returns a questions
  payload → 200 `status: "questions"`, 1–4 entries, server-minted `r1-*` ids,
  `options` presence per `kind`.
- **AT-3** propose-tools proposal round: `r1-*` answers → proposal; `r2-*`
  answers force proposal; `group` resolved from `MCPCustomScopes.catalog/0`;
  invented/Discovery/out-of-group names dropped (grounding ⊆ catalog).
- **AT-4** llm_unavailable mapping: runner error, timeout, non-JSON, empty
  grounded set → HTTP 200 `{"status": "llm_unavailable"}` (never 5xx).
- **AT-5** limits & auth: blank description 422; >8 answers 422; oversized
  description/answer 422; both endpoints 401 without a token.
- **AT-6** create-with-config: `POST /endpoints` with explicit `config`
  persists it (post-normalize); clone **without** config unchanged; clone with
  config honored; copied endpoint independent of source (edit one, other
  unchanged).

Frontend (node test runner; add
`src/components/mcp-config/endpoint-wizard-state.test.ts` and
`src/components/kit/wizard-stepper.contract.test.ts` to the
`test:contracts` script, patterns per `src/lib/tool-overrides.test.ts` and
`src/components/kit/acl-editor.contract.test.ts`):

- **AT-7** `deriveSlug`: kebab rules, collapse/trim, 63-char cap, invalid
  input → `''`; derivation stops after manual slug edit (`reduceWizard`).
- **AT-8** reducer: step gating inputs, state preservation across Back,
  clone prefill, questions/answers flow, proposal defaults enabled+visible,
  fallback preserves name/description/answers, clean reset on cancel.
- **AT-9** `proposalToConfig`: all four enabled/visible flag combinations
  produce the correct `disabled`/`hidden` jsonb entries.
- **AT-10** stepper contract: Next gated on `isValid`, Back disabled at 0,
  domain-neutral imports, `aria-current="step"` + focus management + progress
  indicator present (source-contract assertions).

---

## Success Criteria

1. All US-105..US-114 acceptance criteria pass; AT-1..AT-10 green.
2. Coverage ≥ 80% on all new code (100% grounding/slug decision paths).
3. `npm run test:contracts`, frontend build, and backend ExUnit suite pass.
4. Every LLM failure path demonstrably lands on a working manual flow.
5. Admin editor composes the shared components with zero private
   reimplementation of clone/wizard/picker logic.

## Out of Scope

- `mcp_tool_sets` editors/endpoints/data (kit components stay adoptable).
- Any DB migration (D8).
- Streaming/async proposal delivery.
- i18n of wizard copy; new telemetry beyond existing logging conventions.

## Dependencies

- Existing: `MCPCustomScopes` context, `Tools.Catalog`, `MCPCustomScopes.catalog/0`,
  `MCPOverview` indexer/vector store (`mcp_tool_vectors`), `genai` lib,
  `MockMCP.Agent` runner pattern, kit (`index.ts` exports), `api.ts` mcp
  endpoints client, admin `mcp-custom-scopes` page.
- Operational: an LLM endpoint configured for the backend runner; embeddings
  provider optional (ranker falls back when unconfigured).

## Open Questions

None — decisions D1–D8 are locked by the controller. Escalation path: any
implementation-time discovery that a DB schema change is unavoidable (D8) or
that a contract below is unimplementable as written must stop and report, not
re-interpret.

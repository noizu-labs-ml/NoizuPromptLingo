# Schema Requirements — from User Stories

Consolidated schema-impact analysis across all 150 user stories (US-001–US-150), produced by 10 parallel `npl-tasker-haiku` analyst agents on 2026-04-20.

**Status:** Raw analyst output (not yet reconciled). Review next and fold approved additions into `data-model.md`.

## Scope

Each analyst read 15 story files against the canonical schema in `docs/arch/data-model.md` (§4–§8 Wave 1 + §14 Wave 2) and returned:

1. New entities not yet in `data-model.md`
2. New fields on existing entities
3. New indexes / constraints
4. Changes to existing fields
5. Infrastructure recommendations (PostgreSQL+pgvector vs Weaviate vs TimescaleDB)
6. Per-story `schema_refs` recommendations
7. Open questions / concerns

## Infrastructure the analysts considered

- **PostgreSQL** with extensions: `pgcrypto`, `citext`, `pgvector`, `timescaledb`
- **Weaviate** — separate vector DB for large-scale semantic search
- **Redis** — caching and queueing

## Aggregate summary (from analyst self-reports)

| Batch | Stories | New entities | New fields | New indexes |
|---|---|---|---|---|
| 01 | US-001–US-015 | 0 | 0 | 0 |
| 02 | US-016–US-030 | 0 | 0 | 3 |
| 03 | US-031–US-045 | 0 | 7 | 3 |
| 04 | US-046–US-060 | 0 | 9 | — |
| 05 | US-061–US-075 | 0 | 5 | — |
| 06 | US-076–US-090 | 1 *(model_tiers, optional)* | 2 | 3 |
| 07 | US-091–US-105 | 1 *(api_tokens — redundant, in §14)* | 2 | 2 |
| 08 | US-106–US-120 | 3 *(marketplace_personas, marketplace_rubrics, node_comments)* | 5 | — |
| 09 | US-121–US-135 | 4 | 7 | — |
| 10 | US-136–US-150 | 6 *(auto_flag_rules, audit_events, webhooks, webhook_deliveries, sso_config, +1)* | 3 | — |
| **Total** | **150** | **~15 unique after dedup** | **~40** | **~11** |

## Next steps (for human review)

1. Walk each batch's "New entities" section; accept / reject / defer each
2. Dedup overlapping entities across batches (e.g. `api_tokens` already in §14; any batch-8 marketplace entries that overlap batch-10)
3. Decide Weaviate vs pgvector vs TimescaleDB placement per entity using the analyst recommendations
4. Approve a delta; fold into `data-model.md` §14 appendix (or bump to a proper §14A Wave 3 additions subsection)
5. Walk "schema_refs recommendations" and populate the `schema_refs` field on every story file — one mechanical pass via haiku taskers again

## Analyst reports

The ten raw batch reports follow, unmodified. Cross-batch consolidation is for the human-review pass.

---


# Batch 01 — US-001 to US-015

## New entities required (not in data-model.md)

None. All 15 stories in Wave 1 authoring and execution fit within existing §4–§8 entities.

## New fields on existing entities

None required beyond the schema as specified in data-model.md §4–§8.

## New indexes / constraints

- `prompts.organization_id, slug` — ensure uniqueness within org (already implicit in head pattern)
- `scripts.organization_id, slug` — ensure uniqueness within org (already implicit in head pattern)
- `agents.organization_id, slug` — ensure uniqueness within org (already implicit in head pattern)
- `script_nodes.script_version_id, node_key` — enforce uniqueness (already in data-model.md §5.2)
- `script_edges.from_node_id, priority` — support efficient edge traversal during run execution (already in data-model.md §5.2)

## Changes to existing fields

None. §4–§8 columns and types are stable for Wave 1 execution.

## Infrastructure recommendations

- **OTel partitioning (§7):** Recommend monthly `RANGE` on `start_time` / `timestamp` over daily or hash partitioning. Stories US-015 through later execution stories will generate high-volume trace/log append workloads; monthly aligns with typical log retention windows (30/60/90 days) and enables partition pruning for date-range queries during run analysis.

- **Semantic embeddings (US-005, US-004):** Wave 1 defers semantic-match embedding generation. `script_edges.match_embedding` and `expectations.reference_embedding` remain null; async population happens post-publish in Wave 2. No pgvector queries yet; Weaviate integration is out of scope for MVP.

## Story → schema_refs recommendations

| Story | schema_refs |
|---|---|
| US-001 | organizations, scripts (head) |
| US-002 | scripts, script_versions, script_nodes |
| US-003 | script_nodes, prompt_versions |
| US-004 | script_nodes, expectations, rubric_versions |
| US-005 | script_nodes, script_edges, script_versions |
| US-006 | scripts, script_versions, script_nodes, script_edges |
| US-007 | scripts, script_versions, script_nodes, script_edges, prompts, prompt_versions |
| US-008 | script_versions, prompts, prompt_versions |
| US-009 | prompts (head) |
| US-010 | prompts, prompt_versions |
| US-011 | script_nodes, prompt_versions |
| US-012 | agents (head), agent_versions |
| US-013 | agents, agent_versions (health check—no persistence) |
| US-014 | agents, agent_versions |
| US-015 | runs, run_personas, run_steps, script_versions, agent_versions, personas, persona_versions |

## Open questions / concerns

1. **Version immutability enforcement.** Data-model §9 recommends convention + optional triggers (§10, step 18). Wave 1 implementation should enforce immutability at application layer in changesets; row-level DB triggers are deferred.

2. **Deferred FK for `script_versions.root_node_id`.** Stories US-002, US-006 must coordinate: node insertion and version publish happen in the same transaction; deferred FK check resolves end-of-transaction. Ecto/Phoenix implementation details TBD.

3. **Graph integrity during draft edits.** US-002 (add node), US-005 (add edge) permit interim states where edges reference non-existent nodes. Validation is deferred to US-006 publish. No IN-FLIGHT CHECK constraints needed; application validates before state commits.

4. **Checksum uniqueness for idempotent publish.** US-006, US-010, US-014 rely on `UNIQUE (head_id, checksum)` to detect re-publishes. Implementation: compute canonical form, hash to bytea, check for row at publish time. If found, return existing version instead of insert.

5. **Prompt version pinning semantics (US-011).** `script_nodes.prompt_version_id` must pin a published version, not a draft. Queries must filter `prompt_versions` by `published_by_user_id IS NOT NULL` or add an explicit `published` column. Current schema allows nulls; confirm whether null = unpublished or missing signature.

6. **Agent adapter enum scope.** US-012 specifies `:openai` only; data-model §5.6 lists `:openai, :anthropic, :langchain, :http`. Wave 1 implementation should enforce `:openai` in application or add a CHECK constraint to restrict first-wave installs.

7. **Trace correlation for runs (US-015).** `runs.trace_id` is nullable; OTel spans/logs correlate asynchronously via a background correlator job (§7, data-model §9). Wave 1 does not require the correlator itself; correlation timing is out-of-scope for MVP but the nullable design accommodates it.

---

# Batch 02 — US-016 to US-030

## Summary

Analysis of 15 user stories across run execution, freeball protocol, and results dashboards. **0 new entities required** (all schema support already in Wave 1 `data-model.md`). **0 new fields on existing entities** (all signals already captured). **3 recommended indexes** for operational performance.

---

## New entities required

None. All 15 stories map cleanly to existing tables in §4–§8 and §14 of `data-model.md`.

---

## New fields on existing entities

None required.

**Rationale:** 
- `run_steps`, `scores`, `freeball_nodes`, `freeball_expectations` already carry all required columns (user/agent messages, latency, tokens, confidence, verdicts, rationales).
- `runs.summary_metrics` (JSONB, already in schema) holds aggregated verdicts, pass/warn/fail counts, coverage stats.
- `runs.status` and `runs.run_config` cover all run-level state (pending/running/completed/failed/cancelled, freeball thresholds, cost caps, runner config).
- Real-time streaming is a connectivity concern, not a schema concern — handled by WebSocket/SSE infrastructure.

---

## New indexes / constraints

### Performance indexes (recommended additions)

| Index Spec | Reason | Source Stories |
|---|---|---|
| `runs (organization_id, script_version_id)` | US-026: filter runs by script (joins to `script_versions.script_id`) | US-026 |
| `runs (organization_id, agent_version_id)` | US-027: filter runs by agent | US-027 |
| `run_steps (run_id, step_index)` | US-016, US-017: streaming step append + ordered traversal (already unique, now opt for CLUSTER)| US-016, US-017 |

**Note:** `runs (organization_id, inserted_at DESC)` already specified in §6.1. Composite indexes above accelerate filter joins.

---

## Changes to existing fields

None. All columns are backward-compatible with Wave 1 semantics.

---

## Infrastructure recommendations

### Postgres (primary)

- `run_steps` streaming reads in US-016 benefit from `CLUSTER` on `(run_id, step_index)` for sequential I/O (optional optimization post-MVP).
- **pgvector not needed** for this batch: semantic scoring edges (US-020 judge rationales) are text fields, not embeddings.
- **TimescaleDB not needed** for runs: append-only `run_steps` are fine on standard PostgreSQL; OTel tables (already partitioned monthly in §7) handle the time-series workload.

### Redis (optional)

- Freeball-runner configuration (US-022 `run_config.freeball_runner`) can cache model/prompt lookups (low cardinality, infrequent change).
- Run status caches during streaming (US-016) are optional; direct Postgres polls on reconnect are simpler at MVP.

### Weaviate (not needed for Batch 02)

- No stories require semantic search over run content; skipped.

---

## Story → schema_refs recommendations

| Story | Existing schema_refs | Notes |
|---|---|---|
| US-016 | runs, run_steps | Streaming via ordered `(run_id, step_index)` |
| US-017 | run_steps | `user_message`, `agent_message`, `latency_ms`, `tokens_in`, `tokens_out`, `status` |
| US-018 | runs | `status` transitions, `finished_at` set on cancel |
| US-019 | runs, scores | `summary_metrics` JSONB for `verdict`, verdict rules apply across `scores.verdict` |
| US-020 | scores, expectations, rubric_versions | `score`, `verdict`, `rationale`, `judge_model`, `judge_prompt_version_id` |
| US-021 | runs, scores, expectations | `summary_metrics` denorm: weighted avg, pass/warn/fail counts, freeball vs authored counts |
| US-022 | freeball_nodes, freeball_expectations, run_steps | `confidence`, `parent_script_node_id`, `runner_model`, freeball_policy respected |
| US-023 | freeball_nodes, run_steps | `prompt_text`, `parent_script_node_id`, `runner_model` |
| US-024 | freeball_nodes, freeball_expectations | `confidence` on both, org settings affect UI not schema |
| US-025 | runs | Index on `(organization_id, inserted_at DESC)` — already specified |
| US-026 | runs, script_versions | Join `script_versions.script_id`; add index `runs(organization_id, script_version_id)` |
| US-027 | runs, agent_versions | Join `agent_versions.agent_id`; add index `runs(organization_id, agent_version_id)` |
| US-028 | runs | Filter on `runs.status` enum; verdict filter reads `summary_metrics` JSONB |
| US-029 | runs | Navigation only; tenancy check on `organization_id` |
| US-030 | run_steps, scores | Render `run_steps` ordered by `step_index` with inline `scores` per step |

---

## Open questions / concerns

1. **Verdict aggregation formula** (US-019, US-021): Document whether `direction='negative'` failures are binary gates (any fail → run FAIL) or participate in weighted average. Current schema supports both; business rule clarification needed before implementation.

2. **`run_config.freeball_runner` structure** (US-022): Schema assumes opaque JSONB. Define shape early (runner LLM model, prompt_version_id ref, confidence threshold) to avoid mid-flight refactors.

3. **Summary metrics denormalization** (US-019, US-021): `runs.summary_metrics` JSONB keyed by `{"verdict": "pass", "weighted_score": 0.92, "pass_count": 3, ...}`. Recommend JSON schema validation at application layer to prevent typo bugs.

4. **Filtering performance** (US-026–US-028): Three new composite indexes recommended; verify cardinality (scripts per org, agents per org) to confirm B-tree is cheaper than seqscan + filter on 50-per-page queries.

---

## Migration sequencing implications

No new migrations required for Batch 02. All schema additions from Wave 1 (`data-model.md` §4–§8) are sufficient.

**Recommended follow-up (not blocking MVP):**
- Post-Wave-1, add composite indexes `runs(organization_id, script_version_id)` and `runs(organization_id, agent_version_id)` after benchmarking US-026 and US-027 filter perf.

---

## Wave 2 / Wave 3 foreshadowing

- **US-019 re-score mechanics:** Current schema supports re-scoring (new rubric version writes new `scores` rows). UI in Wave 2.
- **Freeball promotion (US-022 outbound):** `branch_promotions` table (§8.2) ready; promotion workflow UI is Wave 2 REV category.
- **Cohort comparison (US-027 outbound):** `runs` schema supports multi-agent runs via explicit `agent_version_id` pinning; Wave 3 dashboards can build comparison views.


---

# Batch 03 — US-031 to US-045

## New entities required

None. All 15 stories map to existing entities with no new tables needed.

## New fields on existing entities

### `run_steps`
- **Source stories:** US-031
- `is_visible_in_ui boolean` — whether to surface raw JSON viewer in UI (always true for V1, enables future filtering)

### `runs`
- **Source stories:** US-032
- `export_format text` — nullable; async export state tracking for JSON export pipeline (optional; exports may use request-response queue instead)

### `script_nodes`
- **Source stories:** US-041, US-042, US-043
- `kind text` — extend enum to support `:system`, `:terminal`, `:freeball_anchor` (Wave 2 addition; update schema constraint)
  - Existing: `:user_turn`, `:assistant_turn`
  - New: `:system`, `:terminal`, `:freeball_anchor`

### `script_edges`
- **Source stories:** US-042
- `allow_terminal_target boolean DEFAULT false` — whether terminal nodes may be referenced as `to_node_id` (constraint relaxation for Wave 2)

### `expectations`
- **Source stories:** US-034
- Column already exists: `rubric_version_id uuid nullable fk` — no new field needed
- Validation: enforce `rubric_version_id IS NOT NULL` when `scoring_method='rubric'` via CHECK or application logic

### `personas` / `persona_versions`
- **Source stories:** US-035
- `tone text nullable` — already in schema (Wave 2); confirmed by US-035 user story

### `run_personas`
- **Source stories:** US-036
- Columns already exist: `run_id`, `persona_version_id` — no new field needed; relationship already modeled

### `api_tokens`
- **Source stories:** US-037, US-038, US-032, US-087 / US-096 (Wave 2)
- Mentioned in §14.1 of data-model.md; required for CLI auth (already planned)

### `memberships`
- **Source stories:** US-039, US-040
- Columns already exist: `organization_id`, `user_id`, `role` — no new field needed
- Extend `role` enum (if not already): `:owner | :admin | :editor | :viewer | :ci` (`:ci` for US-037+ CLI use)

## New indexes / constraints

### `script_nodes`
- **Source stories:** US-041, US-042, US-043
- Add CHECK constraint: `(kind = 'system' AND prompt_version_id IS NULL) OR (kind = 'terminal' AND prompt_version_id IS NULL) OR (kind = 'freeball_anchor' AND prompt_version_id IS NULL) OR kind IN ('user_turn', 'assistant_turn')`
  - Ensures system/terminal/freeball-anchor nodes reject prompt attachment
- Add CHECK: `(kind = 'system' AND script_version_id NOT IN (SELECT script_version_id FROM script_nodes sn2 WHERE sn2.kind = 'system' AND sn2.script_version_id = script_nodes.script_version_id AND sn2.id <> script_nodes.id)) OR kind <> 'system'`
  - Enforces max 1 system node per script_version (alternative: application-level validation)

### `script_edges`
- **Source stories:** US-042
- Relax existing: current CHECK `from_node_id <> to_node_id OR match_method = 'always'` must permit terminal targets
- Modify to: `(to_node_id IN (SELECT id FROM script_nodes WHERE kind = 'terminal') AND match_method = 'always') OR (from_node_id <> to_node_id OR match_method = 'always')`

## Changes to existing fields

### `script_nodes.kind`
- **Source stories:** US-041, US-042, US-043
- Type remains `text`; enum constraint expands from `{user_turn, assistant_turn}` to `{user_turn, assistant_turn, system, terminal, freeball_anchor}`
- Implementation: update application-level enum + DB CHECK constraint (or use Postgres ENUM type migration — deferred if starting with text + constraint)

## Infrastructure recommendations

- **No new storage infrastructure needed.** Existing pgvector, TimescaleDB, Redis continue sufficing.
- **CLI auth (US-037, US-038):** Implement `api_tokens` table per §14.1; CLI passes bearer token in Authorization header; backend validates against `api_tokens.token_hash` and scopes to `organization_id`.
- **JSON export (US-032):** Use request-response queue (Redis) for async export; `run_id` + `format` as key; poll via GET endpoint or event stream. No `runs.export_format` column needed if stateless.
- **Graph editor support (US-041–043):** Frontend must validate system/terminal/anchor node placement before persisting; backend enforces via CHECK constraints + FKs.
- **Persona tone modulation (US-036):** Runner adapts outgoing `user_message` in `run_steps` based on `run_personas.persona_version_id.tone` tag (application logic; no schema change).

## Story → schema_refs recommendations

| Story | schema_refs |
|---|---|
| US-031 | `run_steps(agent_raw, user_message, agent_message, tokens_in, tokens_out, latency_ms, trace_id, span_id, error)` |
| US-032 | `runs(id, script_version_id, agent_version_id, run_steps)`, `run_personas`, `scores` |
| US-033 | `rubrics`, `rubric_versions(judge_prompt_version_id, judge_model, scale, criteria)` |
| US-034 | `expectations(rubric_version_id)`, `rubric_versions` |
| US-035 | `personas`, `persona_versions(tone, description)` |
| US-036 | `runs`, `run_personas(persona_version_id)`, `persona_versions` |
| US-037 | `scripts`, `script_versions`, `agents`, `agent_versions`, `api_tokens` (Wave 2) |
| US-038 | `runs(status, run_config)`, `scores(verdict)`, `api_tokens` (Wave 2) |
| US-039 | `organizations(slug, name)`, `memberships` (auto-create with `:owner` role) |
| US-040 | `users`, `memberships(role)`, `organizations` |
| US-041 | `script_nodes(kind, prompt_version_id)`, `script_edges` (constraint: max 1 system per version) |
| US-042 | `script_nodes(kind)`, `script_edges(to_node_id)` (constraint: terminal sink-only) |
| US-043 | `script_nodes(kind)`, `freeball_nodes` |
| US-044 | `script_versions(parent_version_id)`, `scripts`, `script_nodes`, `script_edges`, `expectations`, `personas`, `persona_versions` |
| US-045 | `script_versions` (diff via checksum + YAML audit trail), `script_nodes` (node-level changes), `script_edges`, `expectations` |

## Open questions / concerns

1. **System node constraint enforcement.** Should max-1-system-node-per-version be a DB CHECK constraint (heavyweight migration) or application guard? Recommend: application guard + optional trigger migration in Wave 3.

2. **CLI auth via `api_tokens`.** Is token rotation / expiry policy defined (US-037 references `api_tokens` indirectly; full token CRUD in US-096 Wave 2)? Recommend: defer token lifecycle to Wave 2; MVP supports creation + bearer auth only.

3. **Persona tone application.** How does runner mutate prompts per tone tag (US-036: "runner mutates outgoing prompts per persona's tone")? Is tone a freeform string or enum? Current schema allows `text nullable`; suggest enum constraint for MVP or accept open string and document expected values.

4. **Script diff visual representation (US-045).** Schema provides `script_versions.yaml_source` + `checksum` for audit trail; visual diff requires frontend graph diff algorithm (not schema-dependent). Recommend: store diff result as async job + JSONB cache if performance needed; no table addition required.

5. **Export format and async state (US-032).** If exporting large runs becomes slow, consider eventual-consistency pattern: POST `/runs/{id}/export` → returns job_id; GET `/export-jobs/{job_id}` polls status. Avoids blocking request handler but requires async queue infrastructure. Current schema supports this via `runs.run_config` JSONB; no new column needed.

6. **Terminal node semantic.** Does terminal node `kind='terminal'` auto-complete the run, or does completion happen when *no* outgoing edges match (existing behavior)? Recommend: explicit terminal completion (cleaner control flow; supports deliberate early exits).

7. **Freeball-anchor semantics.** Does freeball-anchor invocation consume a turn (step_index increments, `run_steps` row written), or is it transparent (no row)? Recommend: explicit row with `kind='freeball_anchor'` for auditability; implies `run_steps.to_node_id` becomes nullable (already supported).

---

**Summary:** 0 new entities, 7 new/modified fields, 3 constraint additions, 2 enum expansions. All wave-2 stories fit existing schema with minor application-level changes. No infrastructure upgrades required.

---

# Batch 04 — US-046 to US-060

## New entities required

**None.** All 15 stories map to fields on existing entities or enhance features already in the data model.

## New fields on existing entities

### `prompt_versions`
- **Source stories:** US-048, US-049
- `template_vars jsonb` — already modeled (§5.1); this story activates it: declared variables with name, description, default, required-flag
- `tool_defs jsonb` — already modeled (§5.1); this story activates it: JSON Schema definitions for tools the prompt exposes to the agent

### `script_versions`
- **Source stories:** US-046
- `parent_version_id uuid fk nullable` — already modeled (§5.2); activation of fork lineage: points to the source script_version when a fork is created

### `scripts`, `prompts`, `rubrics`, `personas`, `agents`
- **Source stories:** US-047
- `archived_at utc_datetime nullable` — applies to all head tables; soft-archive semantics (default NULL; set to timestamp on archive action)
  - Index: `(organization_id, archived_at)` for filtered listing ("show archived" toggle)

### `persona_versions`
- **Source stories:** US-053
- `system_prompt_version_id uuid fk nullable` — already modeled (§5.4); FK to `prompt_versions`; preamble injected ahead of script system node at runtime

### `rubric_versions`
- **Source stories:** US-056, US-057
- `scale jsonb` — already modeled (§5.5); now explicitly supports `type: ladder` with enum values mapped to numbers; examples: `{"type":"ladder","options":["poor","ok","good"],"mapping":{"poor":0,"ok":0.5,"good":1}}` or `{"type":"continuous","min":0,"max":1}`
- `criteria jsonb` — already modeled (§5.5); structured array of weighted criteria: `[{label, description, weight, judge_model_override?}]`; scorer normalizes weights at score time

## New indexes / constraints

### `script_versions` (fork lineage)
- Index: `(parent_version_id)` — already listed in data model; activates "all forks of script X" query

### All head tables (`scripts`, `prompts`, `rubrics`, `personas`, `agents`, `organizations`)
- Index: `(organization_id, archived_at)` — filter active vs. archived in list views

### `run_steps` (persona breakdowns)
- Index: `(run_id, persona_version_id)` — already listed; activates per-persona result grouping on multi-persona runs

## Changes to existing fields

**None.** No existing fields require type changes or semantic redefinition.

## Infrastructure recommendations

1. **Rubric criteria scoring:** The weighted average aggregation happens in application code (runner), not in stored procedures. `scores.raw_output` JSONB stores per-criterion sub-scores for audit; final numeric `scores.score` is the normalized weighted average.

2. **Archive semantics:** `archived_at IS NULL` in default list views; `archived_at IS NOT NULL` in "Show archived" pane. No cascading archive (archiving a script does not archive its prompts). Archived entities remain fully queryable and referenced by runs.

3. **Ladder enum mapping:** Stored as JSONB in `rubric_versions.scale`; judge prompt template is parameterized by the enum list at generation time. No migration needed — custom enum-to-number mappings are user-supplied in the scale definition.

4. **Persona preamble ordering:** At runtime, compose system context as: `[persona.system_prompt.body, script.system_node.rendered_prompt]` then pass to adapter. No new column needed; runtime behavior only.

5. **Multi-persona fan-out:** `run_personas` already captures the N personas selected; runner spawns N parallel OTP processes under shared supervisor. `run_steps.persona_version_id` non-null in each step identifies which persona stream it belongs to.

6. **Template variables + validation:** At publish time, verify every `{{var_name}}` in `prompt_versions.body` has a declaration in `template_vars`. At node edit, expose bindings for required vars. No schema change — validation happens in application.

## Story → schema_refs recommendations

| Story | schema_refs |
|---|---|
| US-046 | `script_versions.parent_version_id` |
| US-047 | `scripts.archived_at`, `prompts.archived_at`, `rubrics.archived_at`, `personas.archived_at`, `agents.archived_at` |
| US-048 | `prompt_versions.template_vars` |
| US-049 | `prompt_versions.tool_defs` |
| US-050 | `prompts` (read-only; no schema change) |
| US-051 | `persona_expectations` (existing; activation only) |
| US-052 | `run_personas` (existing; activation only), `run_steps.persona_version_id` |
| US-053 | `persona_versions.system_prompt_version_id` |
| US-054 | `run_steps.persona_version_id` (existing; read-only aggregation) |
| US-055 | `personas` (import logic only; no schema change) |
| US-056 | `rubric_versions.criteria` |
| US-057 | `rubric_versions.scale` (ladder enum support) |
| US-058 | None (preview is out-of-band; no `scores` row created) |
| US-059 | `scores` (partial-unique constraint validates re-score logic) |
| US-060 | `scores` (read-only; comparison via `rubric_version_id` FK) |

## Open questions / concerns

1. **Archive defaults in UI:** Should "Show archived" default to off in all list views, or context-dependent (e.g., on during editing if org has archived entities)? Recommend: off by default, explicit opt-in.

2. **Prompt template rendering:** Is `template_vars` sufficient, or do we need an `evaluated_template_vars` field to record which variables were bound at a specific run? Currently assumes node-level bindings are captured in the `user_message` column; clarify in runner implementation.

3. **Rubric criteria override:** Can individual criteria in a rubric override the rubric-level `judge_model`? Currently noted "optionally override" but no schema column. Recommend storing `judge_model_override` in the criteria JSONB array item (nullable per criterion).

4. **Ladder scale consistency:** Ensure enum-to-number mappings are strictly monotonic (ascending). No CHECK constraint possible on JSONB; enforce in application.

5. **Persona preamble placement:** Document that persona preamble is always "outer" and not user-reorderable. Confirm runner code aligns.

6. **Multi-persona partial failures:** US-052 notes "partial failures don't cancel others." Clarify: if one persona stream times out, the run status is `:failed` or `:completed` with partial data? Recommend: run status = worst persona status; partial data is visible.

---

**Summary:** 0 new entities, 9 new/activated fields on existing tables. All stories fit cleanly within Wave 1 schema footprint. Archive functionality is the only net-new column pattern across heads; everything else activates existing JSONB or FK columns.

---

# Batch 05 — US-061 to US-075

## New entities required

None. All 15 stories map to existing entity classes or modeled fields.

## New fields on existing entities

### `agent_versions`
- **Source stories:** US-061, US-062, US-063
- `max_tokens integer nullable` — Anthropic-specific param; stored as part of agent request config
- **Note:** Model variants (Opus/Sonnet/Haiku) already covered by `agent_versions.model` enum; headers/auth_ref reuse existing columns

### `agents` (head table)
- **Source stories:** US-064, US-065
- `daily_cost_cap_usd numeric(12,2) nullable` — org-wide spend limit for this agent
- `rate_limit_per_min integer nullable` — max calls per minute; enforced via Redis
- `health_check_enabled boolean default true` — opt-out toggle per-agent for US-065
- **Note:** Lives on head (not per-version) so limits are mutable immediately

### `runs`
- **Source stories:** US-066, US-067, US-070, US-072
- **Existing fields sufficient:** `run_config jsonb` already captures:
  - `retry_parent_run_id uuid` (US-066: lineage for retry chain)
  - `batch_id text` (US-070: tags multiple runs as cohort)
  - `cost_cap_usd numeric` (US-067: per-run override of agent cap)
  - `freeball_max_depth integer` (US-072: cap consecutive freeball steps)
  - `freeball_max_total integer` (US-072: cap total freeball steps per run)
  - `freeball_runner model text, prompt_version_id uuid` (US-071: per-run runner override)
- **No schema column changes needed** (JSONB flexibility sufficient for config keys)

### `run_steps`
- **Source stories:** US-066, US-068
- **Check:** `status enum` already includes `:ok, :freeball, :error, :timeout` — sufficient for US-066/US-067 retryable error tracking
- **Note:** Score streaming (US-068) is application-layer; no schema change

### `freeball_nodes`
- **Source stories:** US-072, US-073
- `parent_freeball_node_id uuid fk nullable` — **already modeled** (§6.4 of data-model.md)
- **Note:** Depth cap enforcement walks this chain; no new column

### `organizations`
- **Source stories:** US-071
- **Existing field sufficient:** `settings jsonb` can store:
  - `freeball_runner_model text` (org default)
  - `freeball_runner_prompt_version_id uuid` (org default)
- **No schema column changes needed**

### `script_nodes`
- **Source stories:** US-074, US-075
- **Existing field sufficient:** `freeball_policy text` already modeled (§5.2: enum `:allow | :strict | :required`)
- **No schema column changes needed**

## New indexes / constraints

### Health check status tracking (US-065)
- Add table: `agent_health_checks` (not modeled in Wave 1, application-managed)
  - `id uuid pk`, `agent_version_id uuid fk`, `organization_id uuid fk`
  - `status text enum (healthy|unhealthy)`, `last_check_at utc_datetime`, `last_error text nullable`
  - `inserted_at`, `updated_at`
  - Index: `(agent_version_id, last_check_at DESC)` for list badge
- **Alternative:** Store `last_health_check_result` JSONB on `agents` head; simpler, no new table

### Cost tracking for agent cap (US-064)
- **Application-managed via Redis:** daily spend aggregation; no DB table required
- Compute: `sum(run_steps.tokens_in + tokens_out) × published_rate WHERE run.created_at > now() - interval '24h' AND run.agent_version_id = X` on demand

## Changes to existing fields

None required. All rate/cost caps use existing JSONB + enum `run_config` and `agents` head mutability.

## Infrastructure recommendations

| Component | Recommendation |
|---|---|
| **Redis** | Essential for `rate_limit_per_min` enforcement per-agent; key: `agent:{agent_id}:rate_limit:{minute}` |
| **Background job scheduler** | Required for health checks every 15min (US-065); Quantum/Oban for Phoenix |
| **Batch processing** | `batch_id` tag in `run_config` grouping requires dashboard query aggregation; no schema dependency |
| **Streaming (US-068)** | WebSocket/SSE handler for score events; `scored_at` cursor for mid-run reconnect; application layer only |

## Story → schema_refs recommendations

| Story | schema_refs | Notes |
|---|---|---|
| US-061 | `agent_versions.adapter='anthropic'`, `agent_versions.model` | Model enum to include Claude aliases |
| US-062 | `agent_versions.adapter='langchain'`, `agent_versions.endpoint_url`, `agent_versions.request_template` | Flexible mapping templates in JSONB |
| US-063 | `agent_versions.adapter='http'`, `agent_versions.endpoint_url`, `agent_versions.response_jsonpath` | Error mapping stored in `agent_versions.metadata` JSONB |
| US-064 | `agents.daily_cost_cap_usd`, `agents.rate_limit_per_min` | Head-table mutability for immediate effect |
| US-065 | `agent_health_checks` (new) or `agents.last_health_check` JSONB | 15min cadence background job, UI badge via query |
| US-066 | `runs.run_config.retry_parent_run_id`, `run_steps.status enum` | Step copy logic app-layer; FK on retry lineage |
| US-067 | `runs.run_config.cost_cap_usd`, `runs.status`, `run_steps.tokens_in/out` | Cost sum enforced during step post-processing |
| US-068 | `scores.scored_at`, `runs.trace_id` (WebSocket grouping) | Score stream via messaging; no new column |
| US-069 | `runs.trigger_source='scheduled'` | `schedules` table out-of-scope Wave 2; link via app config |
| US-070 | `runs.run_config.batch_id`, `runs` rows (N per agent) | Batch grouping is tag-based, not parent FK |
| US-071 | `organizations.settings` JSONB freeball config, `run_config` per-run override, `freeball_nodes.runner_prompt_version_id` | Prompt version pinning at creation time |
| US-072 | `run_config.freeball_max_depth`, `run_config.freeball_max_total`, `freeball_nodes.sequence` | Depth count walks sequence; total count via aggregate |
| US-073 | `freeball_nodes.parent_freeball_node_id` | Already modeled; depth cap walks chain |
| US-074 | `script_nodes.freeball_policy` enum `:strict` | Already modeled; validation at publish time |
| US-075 | `script_nodes.freeball_policy` enum `:required` | Already modeled; enforced during traversal |

## Open questions / concerns

| Issue | Impact | Recommendation |
|---|---|---|
| Agent health check storage | Low | Use lightweight JSONB on `agents` head (`last_health_check` blob) vs. dedicated table — decide at implementation |
| Cost rate maintenance | Medium | Keep `(provider, model)` → `cents_per_token_{in,out}` in app config (not DB); update manually when pricing changes |
| Batch run fan-out with personas | Medium | US-070 + persona fan-out (US-052) creates N×M run matrix; ensure dashboard filters handle Cartesian explosion |
| Retry step copy semantics | Medium | New run does not re-execute prior steps; ensure read-only access to prior `run_steps.agent_message` during retry payload construction |
| Scheduled run source | Low | US-069 uses `trigger_source='scheduled'`; actual job trigger (`schedules` table) deferred to later migration |
| Freeball policy validation | Low | At script publish time, enforce that strict nodes have outbound edges; runtime check for required mode noop |

---

**Summary:** 0 new entities, 5 new fields on existing heads/configs, all modeling challenges addressed via existing JSONB flexibility and head-table mutability.

---

# Batch 06 — US-076 to US-090

## New entities required

### `model_tiers` (or denormalized into `runs.runner_model_tier`, `agent_versions.model_tier`)

- **Source stories:** US-076
- **Purpose:** Capability ranking for cross-provider model comparison (Opus > Sonnet > Haiku, etc.) to validate runner can generate coherent freeball continuations
- **Proposed columns:** 
  - `id uuid pk`
  - `provider text` (anthropic, openai, etc.)
  - `model_id text` (e.g. "claude-opus-4-1")
  - `tier integer` (higher = more capable; can be denormalized as computed column on agents/runs lookup tables)
  - `label text` (human description)
  - `inserted_at`, `updated_at`
- **Relationships:** Self-referential for ranking; used in `agent_versions` and run-time runner validation
- **Infrastructure fit:** Small lookup table; config-driven; not a transaction bottleneck. Can live in app config YAML if schema burden is low; if in DB, minimal indexes needed.

## New fields on existing entities

### `runs`
- **Source stories:** US-078, US-079, US-082
- `aggregate_score numeric(6,4)` — denormalized from `summary_metrics` JSONB for efficient trending and filtering (open question #11 in data-model.md; this batch confirms demand)

### `run_steps`
- **Source stories:** US-077, US-082
- `runner_model_tier integer` — cached tier of the freeball runner if step deviated; null for authored steps. Used by US-076 warning validation.

### `agent_versions`
- **Source stories:** US-076
- `model_tier integer` — cached capability tier; allows fast < comparison without external lookup at trigger time

### `freeball_nodes`
- **Source stories:** US-089
- `review_status` already exists per data-model.md §6.4; no new column needed (transitions: `:pending` → `:approved | :rejected | :promoted`)

## New indexes / constraints

- **`runs (organization_id, inserted_at DESC)`** — already specified in data-model.md §6.1; required for US-079 date-range filtering
- **`runs (script_version_id, inserted_at DESC)`** — required for US-078 trending query (script → all runs over time)
- **`runs (aggregate_score DESC)`** — required for US-078 score-based sorts on trends
- **`review_queue (organization_id, status, priority DESC, inserted_at DESC)`** — required for US-088 queue list + sorting; refine from data-model.md §8.1
- **`freeball_nodes (review_status)`** — support US-089 state-transition queries (filter by `:pending`, `:approved`, etc.)

## Changes to existing fields

None identified. All required fields already present in canonical schema.

## Infrastructure recommendations

| Story | Recommendation |
|---|---|
| US-078 (trends) | **TimescaleDB consideration**: if `runs.aggregate_score` queries dominate analytics, consider hypertable on `runs` keyed by time. For MVP, simple indexes sufficient; Weaviate not needed. |
| US-081, US-082 (OTLP ingest + correlation) | **Confirmed TimescaleDB use case**: monthly partitioning on `otel_spans.start_time` and `otel_logs.timestamp` is load-bearing for time-series at scale. Background correlation worker (US-082) matches `trace_id` across tables; keep correlation idempotent. |
| US-087 (API token management) | **Infrastructure requirement**: Requires `api_tokens` table (already scoped in data-model.md §14.1). Token hash must use bcrypt or argon2; raw token shown once at creation, never stored. |
| US-076, US-089, US-090 (freeball guardrails + review) | **Model tier lookup**: Keep lightweight — config YAML + app-cached ranking, or minimal DB table with once-per-startup load. No impact on transaction path. |

## Story → schema_refs recommendations

| Story | schema_refs |
|---|---|
| US-076 | `agent_versions`, `runs`, `run_steps` (tier caching; no new entities) |
| US-077 | `runs`, `run_steps`, `script_nodes`, `expectations`, `scores` (read-only; no new tables) |
| US-078 | `runs`, `summary_metrics` JSONB → add `aggregate_score` column per US-011 open question |
| US-079 | `runs` (index requirement only; `inserted_at` already in schema) |
| US-080 | `runs`, `run_personas`, `persona_versions`, `personas` (read-only join; no new tables) |
| US-081 | `otel_spans`, `otel_logs`, `organizations` (API token auth derived from token → org_id) |
| US-082 | `otel_spans`, `otel_logs`, `runs`, `run_steps` (correlation worker; idempotent updates to run_id/run_step_id) |
| US-083 | None (CLI formatter; reads from `run_steps`, `expectations`, `scores`, `personas`) |
| US-084 | None (CLI arg parsing; reads from `persona_versions`, `personas`, `runs`) |
| US-085 | None (GitHub Actions wrapper; delegates to CLI) |
| US-086 | None (GitLab CI template wrapper; delegates to CLI) |
| US-087 | `api_tokens` (table already scoped in data-model.md §14.1), `organizations` (scope lookup), `memberships` (role check) |
| US-088 | `review_queue`, `freeball_nodes`, `script_nodes`, `script_versions`, `persona_versions` (read-only list + filters) |
| US-089 | `review_queue`, `freeball_nodes` (state mutations on both), `personas` (context only) |
| US-090 | `branch_promotions`, `freeball_nodes`, `script_versions`, `script_nodes`, `script_edges`, `prompt_versions`, `expectations` (new branch_promotions row; new script_nodes, script_edges, expectations, prompt_versions for promoted chain) |

## Open questions / concerns

1. **Model tier table vs. config YAML** (US-076): Is a small lookup table in the schema preferred, or keep provider/model rankings in app config? Recommend YAML for MVP; migrate to DB if third-party integrations need dynamic rankings.

2. **API token scope for post-MVP** (US-087): Current schema supports role-based only (`:owner | :admin | :editor | :viewer | :ci`). If per-entity ACLs become P0 later, add `scope jsonb` column.

3. **Regression suite persistence** (US-089 notes): Freeball nodes flagged as `:rejected` currently only set `review_status`. Wave 3 will define how rejected deviations feed back into future runs (e.g., as a regression suite constraint). No schema needed for MVP beyond the status field.

4. **Nested freeball chains** (US-090): `parent_freeball_node_id` in `freeball_nodes` already supports nesting; `branch_promotions.node_mapping` JSONB tracks the full tree. Confirm promotion logic handles depth > 2 correctly.

5. **Concurrent promotion safety** (US-090): `UNIQUE (source_freeball_node_id)` on `branch_promotions` prevents double promotion. Version increment must be atomic; recommend app-level `SELECT ... FOR UPDATE` on head row during publish.

---

**Summary:** 1 potential new table (model_tiers; optional), 2 new columns (runs.aggregate_score, agent_versions.model_tier), 3 refined indexes, no schema changes to existing entities. All data-model.md core structures remain intact; batch 06 is largely read-heavy queries + one new audit record (branch_promotions).

---

# Batch 07 — US-091 to US-105

## Summary

**New entities:** 1 (`api_tokens`)  
**Existing entities extended:** 1 (`runs`)  
**New indexes/constraints:** 2  
**Changes:** `run_config` JSONB gains optional `dataset_version_id` lookup field; `otel_spans` gets optional `name_embedding` column for US-100.

---

## New Entities Required

### `api_tokens`
- **Source stories:** US-096, US-097
- **Purpose:** Tenancy-scoped API credentials for SDK / CLI use; authentication via `Authorization: Bearer <token>` header
- **Proposed columns:**
  - `id uuid pk`
  - `organization_id uuid fk not null` (on delete cascade)
  - `name text not null` — human-readable label
  - `token_hash bytea not null` — bcrypt/argon2 of raw token (never plaintext)
  - `key_prefix text not null` — first N chars of raw token for support lookup
  - `role text not null` — enum: `:owner`, `:admin`, `:editor`, `:viewer`, `:ci`
  - `created_by_user_id uuid fk nullable` (on delete set null)
  - `expires_at utc_datetime nullable` — default 90 days from creation
  - `last_used_at utc_datetime nullable` — updated on successful auth (deferred batch update acceptable)
  - `revoked_at utc_datetime nullable` — soft-revocation; 401 on subsequent use
  - `inserted_at utc_datetime not null`
  - `updated_at utc_datetime not null` — mutable through revocation workflow
- **Relationships:**
  - FK: `organization_id` → `organizations(id)`
  - FK: `created_by_user_id` → `users(id)`
- **Uniqueness:** `(organization_id, name)`, `(token_hash)`
- **Indexes:** `(organization_id, revoked_at DESC)` for listing active/revoked tokens; `(token_hash)` for auth lookup (unique implied)
- **Infrastructure fit:** PostgreSQL. Raw token shown ONCE at creation; never retrievable. Hash comparison on every auth request. Cache invalidation in Redis keyed by token hash + 60s TTL (for US-097 grace period).

---

## New Fields on Existing Entities

### `otel_spans`
- **Source stories:** US-100
- `name_embedding vector(1536) nullable` — async-populated embedding of span name for semantic search. Dimensionality matches `text-embedding-3-small` (1536d). Set by background worker; queries filter by `name_embedding IS NOT NULL` for "indexed" spans. NULL spans included in text-only filtering.

### `runs`
- **Source stories:** US-105 (implicit via datasets)
- `run_config` JSONB (existing) gains optional key: `"dataset_version_id": "<uuid>"` (searchable via GIN index if necessary, deferred). Non-null when `trigger_source='dataset'` or when dataset run is initiated.

---

## New Indexes / Constraints

### `api_tokens`
- **Unique constraint:** `(organization_id, name)` — one token name per org
- **Unique constraint:** `(token_hash)` — enforce one hash entry
- **Index:** `(organization_id, revoked_at DESC)` — list active/revoked tokens for an org
- **Index:** `(token_hash)` — implicit from unique; ensures fast auth lookups
- **Check:** `expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP` (optional; enforce in app layer or trigger)

### `otel_spans`
- **IVFFLAT or HNSW index on `name_embedding`** (if pgvector extension supports; deferred post-MVP). For MVP, sequential scan acceptable given monthly partitioning by `start_time`.

---

## Changes to Existing Fields

None beyond the additions above. `otel_spans.name_embedding` is nullable and backward-compatible. `runs.run_config` is JSONB and absorbs `dataset_version_id` as an optional key without schema disruption.

---

## Infrastructure Recommendations

| Component | Recommendation | Rationale |
|---|---|---|
| **API token storage** | Postgres `api_tokens` table; bcrypt/argon2 hashing at rest | Matches existing tenancy model; single source of truth for auth |
| **Token validation cache** | Redis keyed by `token_hash`, TTL 60s | 60s grace period for revocation propagation (US-097); query frequency is high during SDK/CLI use |
| **Span embeddings** | Async background worker populates `otel_spans.name_embedding` | Non-blocking ingestion; SDK queries wait for embedding if needed; backfill sampled initially (cost control) |
| **Embedding model** | OpenAI `text-embedding-3-small` (1536d) or user-configurable in org settings | Matches schema dimensionality; cost per span embedding ~0.02¢; per-org override allows team flexibility |
| **Weaviate for datasets?** | Not needed for MVP | `dataset_entries` are small; simple JSONB search sufficient. Revisit if semantic search over dataset inputs becomes P0. |

---

## Story → Schema Refs Recommendations

| Story | Schema Refs |
|---|---|
| US-091 (Python SDK) | None (client library; no schema changes) |
| US-092 (Elixir SDK) | None |
| US-093 (TypeScript SDK) | None |
| US-094 (SDK OTel bridge) | `otel_spans`, `otel_logs` (reads; no schema changes) |
| US-095 (SDK query helpers) | None (pagination over `runs`, `run_steps`, `scores` — no new columns) |
| US-096 (Issue API token) | `api_tokens` (new entity) |
| US-097 (Revoke/rotate token) | `api_tokens` (revoke adds `revoked_at` mutation; rotate creates new row) |
| US-098 (OTel span query by attribute) | `otel_spans` (GIN on `attributes jsonb_path_ops` — existing; no schema change) |
| US-099 (OTel span drilldown) | `otel_spans`, `run_steps` (reads via `run_step_id` FK; no schema change) |
| US-100 (OTel semantic span search) | `otel_spans.name_embedding` (new field) |
| US-101 (Create dataset) | `datasets` (head table — already defined in §14.2 of data-model.md) |
| US-102 (Publish dataset version) | `dataset_versions` (immutable version; checksum, version_number) |
| US-103 (Add dataset entries) | `dataset_entries` (new rows in draft version) |
| US-104 (Import dataset CSV/JSON) | `dataset_entries` (bulk insert; idempotency via entry_key uniqueness) |
| US-105 (Run dataset against agent) | `runs` (new `dataset_version_id` in `run_config`), `run_steps` (no `from_node_id`/`to_node_id` for dataset runs), `scores` (rubric scoring of dataset entries) |

---

## Open Questions / Concerns

| # | Question | Impact | Recommendation |
|---|---|---|---|
| 1 | **Token cache invalidation timing** | If cache TTL is too short, token validation traffic spikes; if too long, revoked tokens remain active longer than acceptable. | Stick with 60s (matches US-097 grace period); monitor in metrics. Reduce to 10s if token churn is high. |
| 2 | **Span embedding backfill strategy** | Embedding 10M+ existing spans at full density is expensive (~$200+). Sampled backfill acceptable for MVP? | Yes; recommend 10% random sample initially. Full backfill can be async batch job later. UI shows "X% indexed" progress. |
| 3 | **`dataset_version_id` in `run_config` JSONB vs. new column** | JSONB is backward-compatible but requires app-layer parsing; dedicated column is slightly faster to query. | JSONB for MVP (aligns with existing `run_config` shape). If dataset runs dominate traffic, migrate to column in Wave 3. |
| 4 | **Role-based access control on `api_tokens`** | Current design is `role` enum (`:viewer` / `:editor` / `:admin` / `:owner` / `:ci`). Should fine-grained per-entity ACLs be added? | No; defer to Wave 3. Enum roles sufficient for MVP (CI tokens get `:ci`, SDK users get `:editor`). |
| 5 | **Org settings inheritance for embedding model** | Should all spans in an org use the same embedding model, or allow per-token-type variance? | Single model per org for simplicity. Store `embedding_model` in `organizations.settings` JSONB; SDKs read during init. |

---

## Migration Sequencing

Extend §10 of `data-model.md`:

**After step 17** (`add_version_immutability_triggers`), insert:

- **17a.** `create_api_tokens` — `api_tokens` table with unique/index constraints
- **17b.** `add_otel_spans_name_embedding` — add nullable `vector(1536)` column; no default backfill (async job separate)
- **17c.** `create_datasets_and_versions` — (folded from §14.2)
- **17d.** `create_dataset_entries`
- **17e.** `add_runs_dataset_config_gin_index` — optional GIN on `run_config` if queries prove necessary

Continue with step 18 (`add_tenancy_composite_fks`).

---

## Notes

- **SDK stories (US-091–US-095)** require no schema changes; they consume existing `runs`, `run_steps`, `scores` tables. `api_tokens` is the blocker for all three (US-096 dependency).
- **API token strategy** (US-096, US-097) is minimal: hash at rest, cache on read, soft-revoke via `revoked_at`. No OAuth, no fine-grained scopes yet.
- **OTel semantic search (US-100)** reuses `pgvector` infrastructure already present. `name_embedding` is the sole addition; async backfill keeps ingestion path unblocked.
- **Datasets (US-101–US-105)** use the head + version-table pattern already defined in §14 of `data-model.md`. Integration with `runs` / `run_steps` / `scores` is non-invasive (dataset_version_id in JSONB, no foreign keys).

---

# Batch 08 — US-106 to US-120 Schema Requirements Report

## Summary
- **15 stories analyzed**
- **3 new entities required** (marketplace_personas, marketplace_rubrics, node_comments)
- **5 new fields on existing entities**
- **Migration sequencing impact**: extends Wave 2/3 coverage

---

## New entities required

### `marketplace_personas`
- **Source stories:** US-116
- **Purpose:** Track cross-org persona sharing; enables browse/import flow
- **Proposed columns:**
  - `id uuid pk`
  - `persona_version_id uuid fk not null` — the published persona version
  - `author_organization_id uuid fk not null` — original author's org
  - `title text not null` — marketplace display name (may differ from persona.name)
  - `description text` — pitch for discovery
  - `published_at utc_datetime not null`
  - `download_count integer default 0` — popularity metric
  - `average_rating numeric(3,2) nullable` — community rating (US-116 note: no explicit rating mechanism, deferred; MVP uses download_count)
  - `curation_status text default 'pending'` — enum: `:pending`, `:approved`, `:featured`, `:flagged`
  - `inserted_at utc_datetime not null`
- **Relationships:**
  - FK: `persona_version_id → persona_versions(id)` on delete cascade
  - FK: `author_organization_id → organizations(id)` on delete restrict (preserve attribution)
- **Infrastructure fit:** Small write volume; queryable by `curation_status`, `published_at` (index: `(curation_status, published_at DESC)`)

### `marketplace_rubrics`
- **Source stories:** US-119
- **Purpose:** Track cross-org rubric sharing; mirror persona marketplace structure
- **Proposed columns:**
  - `id uuid pk`
  - `rubric_version_id uuid fk not null`
  - `author_organization_id uuid fk not null`
  - `title text not null`
  - `description text`
  - `domain text` — enum: `:safety`, `:rag`, `:code_generation`, `:summarization`, `:other`
  - `published_at utc_datetime not null`
  - `download_count integer default 0`
  - `average_rating numeric(3,2) nullable`
  - `curation_status text default 'pending'`
  - `inserted_at utc_datetime not null`
- **Relationships:** FK mirroring `marketplace_personas`
- **Infrastructure fit:** Identical query patterns to personas; dual index on `(domain, curation_status, published_at DESC)`

### `node_comments`
- **Source stories:** US-112
- **Purpose:** Thread-based comments on script nodes; does NOT persist in YAML (editor-only metadata)
- **Proposed columns:**
  - `id uuid pk`
  - `script_node_id uuid fk not null` — node is permanent; comment follows across versions
  - `organization_id uuid fk not null` — denorm
  - `thread_id uuid fk not null` — groups replies to same comment
  - `parent_comment_id uuid fk nullable` — reply to another comment
  - `author_user_id uuid fk not null`
  - `body text not null` — markdown
  - `resolved_at utc_datetime nullable` — null = active, set = resolved
  - `resolved_by_user_id uuid fk nullable`
  - `inserted_at utc_datetime not null`
  - `updated_at utc_datetime not null` — comments are mutable (edits are inline, not versioned)
- **Relationships:** FK to script_nodes (on delete cascade); users (created_by, resolved_by)
- **Infrastructure fit:** High update frequency post-publish; standard relational table. Index: `(script_node_id, thread_id, inserted_at)`

---

## New fields on existing entities

### `script_nodes`
- **Source stories:** US-118
- `switch_persona_to uuid nullable` — FK to `persona_versions`; null = no switch. Runtime validation: switch target must exist in `run_personas` before step executes.

### `rubric_versions`
- **Source stories:** US-120
- `n_samples integer default 1` — number of times judge is invoked for confidence sampling; max 10
- Schema migration: add CHECK constraint `n_samples >= 1 AND n_samples <= 10`

### `scores`
- **Source stories:** US-120
- Existing `raw_output jsonb` field repurposed to store confidence interval. No new column; structure within existing JSON: `{"confidence_interval": {"mean": 0.82, "stddev": 0.04, "n_samples": 3}}`

### `dataset_versions`
- **Source stories:** US-110
- `default_rubric_version_id uuid fk nullable` — which rubric scores dataset entries by default; can be overridden at run time (US-105)
- FK to `rubric_versions`; NULL allowed (user must select rubric at run time if not set)

### `flagged_captures`
- **Source stories:** US-106, US-107, US-108, US-109
- Already specified in §14.3 of data-model.md; no new fields needed for Wave 3 stories

---

## New indexes / constraints

| Table | Index | Rationale |
|---|---|---|
| `marketplace_personas` | `(curation_status, published_at DESC)` | Browse published personas |
| `marketplace_personas` | `(author_organization_id)` | Audit trail: show all personas by author |
| `marketplace_rubrics` | `(domain, curation_status, published_at DESC)` | Filter by domain + browse |
| `marketplace_rubrics` | `(author_organization_id)` | Audit trail |
| `node_comments` | `(script_node_id, inserted_at DESC)` | Fetch all comments for a node |
| `node_comments` | `(author_user_id)` | Show user's recent comments |
| `rubric_versions` | No change | n_samples is integer, no index needed |
| `script_nodes` | No change | persona FK does not require new index (lookups via existing (script_version_id, id) composite) |
| `dataset_versions` | No change | rubric FK nullable, use partial index `(default_rubric_version_id) WHERE default_rubric_version_id IS NOT NULL` if cardinality is very low |

---

## Changes to existing fields

**None.** Wave 3 stories maintain backward compatibility; no column drops, renames, or type changes.

---

## Infrastructure recommendations

| Concern | Recommendation |
|---|---|
| **Marketplace scaling** | Both `marketplace_personas` and `marketplace_rubrics` are append-mostly with low mutation. Cache browse results (Marketplace tab) with 1-hour TTL; invalidate on curator approval. |
| **Persona switching FK path** | `script_nodes.switch_persona_to` references `persona_versions` directly (not composite FK). Validate at runtime in runner before executing step: confirm target persona exists in `run_personas` for this run. |
| **Comment volume** | `node_comments` will grow unbounded per org. No archival mechanism yet (non-goal for Wave 3). For large scripts, paginate comments on detail view (load 20, lazy-load more). |
| **Confidence interval storage** | Store in `scores.raw_output.confidence_interval` object; no migration to normalize (JSONB supports nested structure). Aggregation queries at dashboard level (not DB-side materialization for MVP). |
| **Rubric import provenance** | `marketplace_rubrics` + imported copy in `rubrics` head: set `metadata.imported_from` JSONB pointer in the imported `rubric_versions` for attribution link. No new column; use existing metadata. |

---

## Story → schema_refs recommendations

| Story | schema_refs | Note |
|---|---|---|
| US-106 | `flagged_captures` | Already in data-model §14.3 |
| US-107 | `flagged_captures` | Browse/filter requires index on `(organization_id, inserted_at DESC)` |
| US-108 | `flagged_captures`, `script_nodes`, `script_versions` | Promotion updates `flagged_captures.promoted_to_script_node_id` |
| US-109 | `flagged_captures`, `dataset_entries` | Promotion creates new `dataset_entries` row |
| US-110 | `dataset_versions`, `rubric_versions` | New FK: `dataset_versions.default_rubric_version_id` |
| US-111 | (none) | Frontend-only (bulk graph ops); no schema impact |
| US-112 | `node_comments` (new entity) | Comments thread-based, pinned to `script_node_id` |
| US-113 | (none) | Frontend-only (auto-layout); `script_nodes.position` already exists |
| US-114 | (none) | Sandbox invocations out-of-band; no `runs` row created |
| US-115 | (none) | Template expansion in prompt body; no schema change |
| US-116 | `marketplace_personas` (new entity), `personas`, `persona_versions` | Import deep-copies persona_version into org |
| US-117 | (none) | Materialized view (denormalization for dashboard) is optional optimization |
| US-118 | `script_nodes`, `run_steps` | New field: `script_nodes.switch_persona_to uuid` |
| US-119 | `marketplace_rubrics` (new entity), `rubrics`, `rubric_versions` | Import deep-copies rubric_version into org |
| US-120 | `rubric_versions`, `scores` | New field: `rubric_versions.n_samples`; confidence in `scores.raw_output` |

---

## Open questions / concerns

1. **Marketplace curation UI.**
   - Acceptance criteria mention "soft-flag" for flagged personas (US-116 out-of-scope note).
   - Recommend: curator dashboard page (Wave 3 admin feature, not in public scope yet); manual flip of `curation_status` via admin panel.
   - Risk: no moderation workflow defined; "approved" is curator click — consider light moderation (diff against prior version, safety scan) in future.

2. **Persona import reconciliation.**
   - Story US-116 says "deep-copy into the caller's org" (like library flow US-055).
   - Current data model has no `imported_from` provenance column on `personas` head.
   - Recommendation: Store in `personas.metadata.imported_from` JSONB, not as a new column. Avoids schema churn; queryable via GIN.

3. **Rubric import `n_samples` inheritance.**
   - US-120 adds `n_samples` to rubric config (confidence sampling).
   - Imported rubrics (US-119) copy the rubric version *with its n_samples*.
   - No additional concern; inheritance is automatic via `rubric_versions` table copy.

4. **Node comments deletion.**
   - Comments do NOT round-trip through YAML (editor-only).
   - No requirement for soft-delete or archival yet.
   - If a node is deleted, comments cascade-delete via FK `(script_node_id)`.
   - Risk: comments lost if node is deleted. Accept for MVP; Wave 3+ can soft-delete nodes if needed.

5. **Confidence interval aggregation.**
   - US-120 Acceptance says "variance sums" for aggregate views.
   - DB does not compute aggregation; frontend/dashboard must do it.
   - Store full distribution in `scores.raw_output` (mean, stddev, n_samples); dashboard layer computes aggregate variance.
   - No schema support needed; application responsibility.

6. **Marketplace initial seed data.**
   - Stories mention "curator-edited starter pack" (US-119 notes).
   - No migration defined to seed `marketplace_*` tables.
   - Recommendation: Create a seed script that inserts canonical personas/rubrics (e.g., "Anthropic Safety Rubric v2") into `marketplace_*` tables post-deployment.

---

## Migration sequencing

Extend §10 of data-model.md. Insert between step 17 (add_version_immutability_triggers) and step 18 (add_tenancy_composite_fks):

- **17a.** `create_marketplace_personas` — new table + indexes
- **17b.** `create_marketplace_rubrics` — new table + indexes
- **17c.** `create_node_comments` — new table + indexes
- **17d.** `add_script_nodes_switch_persona_to` — add column + FK + check
- **17e.** `add_rubric_versions_n_samples` — add column + check constraint
- **17f.** `add_dataset_versions_default_rubric_version_id` — add column + FK

No changes to existing version-table immutability or tenancy structure.

---

## Backward compatibility

- ✅ `switch_persona_to` nullable on `script_nodes` — existing scripts unaffected
- ✅ `n_samples` defaults to 1 on `rubric_versions` — existing rubrics behave identically
- ✅ `default_rubric_version_id` nullable on `dataset_versions` — existing datasets require explicit rubric at run time (current behavior)
- ✅ All new tables are independent; no cascade deletes affecting existing entities except marketplace imports (which update only the importing org's copy)

---

## Recommendations for post-Wave-3 alignment pass

1. Collapse `marketplace_personas` and `marketplace_rubrics` into a single `marketplace_items` table with `item_type` enum if the browse/filter UI becomes unified.
2. Consider a `content_hash` or `version_signature` on `marketplace_*` to detect when a marketplace item has been updated (enables "update available" notifications).
3. Document the comment deletion cascade risk in operations handbook; consider soft-delete strategy for Wave 3.1.
4. Add confidence-interval aggregation utilities to dashboard backend layer (not DB-side for MVP).


---

# Batch 09 — US-121 to US-135

## New entities required

### `dashboards`
- **Source stories:** US-130
- **Purpose:** Store org-scoped dashboard templates with versioning pattern
- **Proposed columns:**
  - `id uuid pk`, `organization_id uuid fk`, `slug citext`, `name text`
  - `current_version_id uuid fk nullable` (deferred)
  - `archived_at utc_datetime nullable`
  - `created_by_user_id uuid fk nullable`, `inserted_at`, `updated_at`
- **Relationships:** 1 org : N dashboards; head → version pattern
- **Infrastructure fit:** Follows existing versioned-entity pattern; no special indexing needed

### `dashboard_versions`
- **Source stories:** US-130
- **Purpose:** Immutable snapshots of dashboard configuration
- **Proposed columns:**
  - `id uuid pk`, `dashboard_id uuid fk on delete cascade`, `organization_id uuid fk` (denorm)
  - `version_number integer`, `checksum bytea`
  - `layout jsonb` (grid config: `{widgets: [{type, filters, position, size}, ...]}`)
  - `published_by_user_id uuid fk nullable`, `inserted_at utc_datetime`
- **Relationships:** FK to `dashboard_id` (parent); same immutability guarantees as `prompt_versions`
- **Infrastructure fit:** TimestampTZ for `inserted_at`; GIN index on layout JSONB for widget-type drill-downs

### `otel_sampling_policies`
- **Source stories:** US-132
- **Purpose:** Org-scoped sampling rules applied at OTLP receiver
- **Proposed columns:**
  - `id uuid pk`, `organization_id uuid fk`, `name text`
  - `head_sampling_rate numeric(4,3)` (0.0–1.0; null = inherit plan default)
  - `tail_rules jsonb` (e.g. `{error_traces: 1.0, run_linked: 1.0, default: 0.1}`)
  - `effective_from utc_datetime nullable` (for gradual rollout)
  - `metadata jsonb` (audit trail of rate changes), `inserted_at`, `updated_at`
- **Relationships:** N per org; no run linkage (config-only)
- **Infrastructure fit:** Lightweight; config cache in app; no heavy indexing

## New fields on existing entities

### `runs`
- **Source stories:** US-124, US-128
- `cost_estimate_usd numeric(10,4)` — formula-derived; logged before trigger
- `cost_cap_usd numeric(10,4)` — optional runtime guardrail (triggers warning in US-124)

### `freeball_nodes`
- **Source stories:** US-127, US-128
- `learning_examples jsonb` — when learning mode active, approved freeball context appended (metadata)
- `adaptive_depth_policy text nullable` — enum: `fixed | adaptive` (default null = inherit run config); logged decisions in existing `metadata`

### `organizations`
- **Source stories:** US-131, US-132
- `otel_retention_days integer nullable` — null = indefinite, max by plan (admin-set)
- `otel_head_sampling_rate numeric(4,3) nullable` — org-level default; can be overridden per policy

## New indexes / constraints

### On `dashboards` / `dashboard_versions`
| Table | Index | Rationale |
|---|---|---|
| `dashboards` | `(organization_id, slug)` UNIQUE | Lookup by org + dashboard slug |
| `dashboard_versions` | `(dashboard_id, version_number)` UNIQUE | Immutability constraint |
| `dashboard_versions` | GIN on `layout` JSONB | Widget-type + filter queries |

### On `otel_sampling_policies`
| Table | Index | Rationale |
|---|---|---|
| `otel_sampling_policies` | `(organization_id)` | Receiver config lookup on ingest |

### On `otel_spans` / `otel_logs` (mutation)
- Add `sample_decision_reason text nullable` (one of: `head_sampling`, `tail_sampled`, `run_linked`, `dropped`) — denormalized from sampling policy for audit
- Add `sample_rate numeric(4,3) nullable` — the rate that was active when span ingested

## Changes to existing fields

### `otel_spans`
- `sampled boolean` — rename from implicit status_code; explicit flag for sampling decision (US-132)
- Add partial index `(organization_id, sampled, start_time)` for "sampled traces only" queries

### `script_nodes`
- `freeball_policy text` — already exists; confirm values include `:adaptive` for US-128

### `run_steps`
- `dataset_entry_ref jsonb nullable` — add for US-125 dataset-persona fanout (points to `dataset_entry_id` + `entry_key`)

## Infrastructure recommendations

| Technology | Use | Stories |
|---|---|---|
| **pgvector** | Not new; confirm for dashboard metric embeddings if semantic search on heatmap values explored | US-130 research |
| **TimescaleDB hypertable** | Existing strategy for `otel_spans`; apply same monthly partitioning to any new `otel_sampling_*` audit tables | US-131, US-132 |
| **ClickHouse dual-write** | Spans mirror at 60s lag (US-133); adds `otel_spans_ch` table schema matching Postgres + run-linking columns | US-133 |
| **Redis** | Cache sampling policy config per org; 60s reload SLA (US-132) | US-132 |

## Story → schema_refs recommendations

| Story | schema_refs |
|---|---|
| US-121 | `rubric_versions`, `scores`, `run_steps`, `expectations` (existing; no new schema) |
| US-122 | `agent_versions.adapter`, `.endpoint_url`, `.auth_ref` (existing; confirms enums) |
| US-123 | `run_steps.agent_raw` JSONB, `.latency_ms`, `.tokens_in`, `.tokens_out` (existing; streaming enriches agent_raw) |
| US-124 | `runs.cost_estimate_usd`, `.cost_cap_usd`, `run_config` JSONB |
| US-125 | `run_steps.dataset_entry_ref` JSONB, `run_personas` (existing; fanout multiplier) |
| US-126 | `freeball_nodes.confidence`, aggregation queries (existing; no new table) |
| US-127 | `freeball_nodes.learning_examples`, `organizations.settings` JSONB (learning_mode flag) |
| US-128 | `freeball_nodes.adaptive_depth_policy`, `run_config` adaptive policy choice |
| US-129 | `runs.run_config` JSONB (batch_id tag), aggregation queries (existing) |
| US-130 | `dashboards`, `dashboard_versions`, `organization_id` tenancy |
| US-131 | `otel_spans.inserted_at` monthly partition, `organizations.otel_retention_days` |
| US-132 | `otel_sampling_policies`, `otel_spans.sample_decision_reason`, `.sampled` flag |
| US-133 | `otel_spans_ch` new table (ClickHouse mirror schema), run-linking columns stable |
| US-134 | None (CLI scaffolding; no schema impact) |
| US-135 | None (CLI watch mode; no schema impact) |

## Open questions / concerns

1. **Dashboard JSONB schema finalization** — widget types, filter shapes, position encoding should be documented before migration
2. **Sampling audit trail depth** — `otel_sampling_policies.metadata` is append-only; alternative is dedicated `policy_change_log` table for precise compliance
3. **Cost estimate formula tuning** — after 10+ runs, estimate switches to historical model; define persistence (cache in `run_config` or separate `run_cost_models` table?)
4. **ClickHouse dual-write ordering** — should Postgres writes block until ClickHouse confirm, or fire-and-forget with async lag tolerance? (US-133)
5. **Learning mode scoping** — US-127 is org-level; per-script or per-agent learning modes out of scope but may resurface

## Summary

**4 new entities, 7 new fields, 3 strategic infrastructure integrations**

- Dashboards versioning adds 2 tables (follows pattern)
- Sampling policy config adds 1 table (lightweight operational)
- Cost/learning/adaptive depth as fields on existing entities (low-risk surface expansion)
- ClickHouse mirror (US-133) is largest new infrastructure burden; schema already supports it
- US-134, US-135 (CLI) require no schema changes

Migration sequencing: dashboards → otel_sampling_policies → field additions → (post-MVP) ClickHouse schema bootstrap.

---

# Batch 10 — US-136 to US-150

## New entities required

### `auto_flag_rules`
- **Source stories:** US-147
- **Purpose:** Store deterministic rules for auto-flagging OTel captures by regex, attribute thresholds, latency spikes
- **Proposed columns:**
  - `id uuid pk`
  - `organization_id uuid fk not null`
  - `name text not null`
  - `rule_type text not null` — enum: `:regex_input`, `:regex_response`, `:attribute_match`, `:latency_threshold`, `:token_count_threshold`
  - `config jsonb not null` — method-specific: pattern, threshold, attribute path/value
  - `default_reason text not null` — enum: `:deviation`, `:bug`, `:edge_case`, `:good_example`, `:regression`
  - `default_tags text[] not null`
  - `enabled boolean not null default true`
  - `soft_deleted_at utc_datetime nullable` — rules stay in history
  - `match_count integer not null default 0` — denormalized for UI tuning visibility
  - `inserted_at`, `updated_at utc_datetime not null`
- **Relationships:** `organization_id → organizations`; linked implicitly to `flagged_captures` via rules-evaluation pipeline (no FK, evaluated async)
- **Infrastructure fit:** Stateless deterministic evaluation on OTel ingest; rule config is small JSONB

### `audit_events`
- **Source stories:** US-143
- **Purpose:** Append-only log of administrative actions for SOC2 compliance
- **Proposed columns:**
  - `id uuid pk`
  - `organization_id uuid fk not null`
  - `actor_user_id uuid fk nullable` — null for system-initiated
  - `action text not null` — enum: `membership_created|updated|deleted`, `token_created|revoked`, `script_published|archived`, `freeball_promoted`, `expectation_added|removed`, etc.
  - `subject_type text not null` — `membership|token|script|expectation|persona|rule|webhook`
  - `subject_id uuid nullable` — resource ID
  - `subject_slug text nullable` — human-readable identifier
  - `diff jsonb nullable` — before/after for mutations
  - `metadata jsonb not null default '{}'` — contextual fields (IP, user agent, etc.)
  - `timestamp utc_datetime not null` — for range queries
  - `inserted_at utc_datetime not null` — immutable
- **Relationships:** `organization_id → organizations`; `actor_user_id → users`; `subject_id` is polymorphic (no FK; validated in app)
- **Infrastructure fit:** Append-only; TimescaleDB hypertable on `timestamp` for long-tail retention queries; 365+ day minimum retention

### `webhooks`
- **Source stories:** US-144
- **Purpose:** Org-scoped webhook subscriptions for run/review/freeball events
- **Proposed columns:**
  - `id uuid pk`
  - `organization_id uuid fk not null`
  - `name text not null`
  - `endpoint_url text not null`
  - `secret bytea not null` — for HMAC-SHA256 signing
  - `event_filters text[] not null` — `['run.completed', 'review_item.created', 'freeball.promoted']` etc.
  - `active boolean not null default true`
  - `created_by_user_id uuid fk nullable`
  - `inserted_at`, `updated_at utc_datetime not null`
- **Relationships:** `organization_id → organizations`
- **Infrastructure fit:** Small, mutable configuration; webhook dispatch is out-of-band job queue

### `webhook_deliveries`
- **Source stories:** US-144
- **Purpose:** Audit log of webhook event deliveries for debugging and retry management
- **Proposed columns:**
  - `id uuid pk`
  - `webhook_id uuid fk not null`
  - `organization_id uuid fk not null` — denorm
  - `event_type text not null` — `run.completed`, etc.
  - `event_payload jsonb not null` — full event body
  - `http_status integer nullable` — response code; null if not yet sent
  - `error_message text nullable`
  - `retry_count integer not null default 0`
  - `next_retry_at utc_datetime nullable` — exponential backoff schedule
  - `sent_at utc_datetime nullable`
  - `inserted_at utc_datetime not null`
- **Relationships:** `webhook_id → webhooks`, `organization_id → organizations`
- **Infrastructure fit:** Append-only; index on `(webhook_id, sent_at)` for listing; dead-letter after 5 failures

### `sso_config`
- **Source stories:** US-142
- **Purpose:** Per-org SAML/OIDC SSO configuration for enterprise tenancy
- **Proposed columns:**
  - `id uuid pk`
  - `organization_id uuid fk not null unique` — one config per org
  - `provider text not null` — enum: `:saml`, `:oidc`
  - `enabled boolean not null default false`
  - `metadata jsonb not null` — provider-specific config (IdP metadata URL, issuer, client_id, etc.); **secrets handled via auth_ref pattern**
  - `role_mapping jsonb not null default '{}'` — IdP group → org role mapping
  - `sso_required boolean not null default false` — disallow password login if true
  - `inserted_at`, `updated_at utc_datetime not null`
- **Relationships:** `organization_id → organizations` with `on delete cascade`
- **Infrastructure fit:** Small, mutable; single row per org; actual secrets (client_secret) stored externally via `auth_ref`

## New fields on existing entities

### `review_queue`
- **Source stories:** US-140, US-141
- `assigned_to_user_id uuid fk nullable` — already in schema; adding index optimization
- `assigned_at utc_datetime nullable` — timestamp for SLA age calculations
- `sla_warning_sent_at utc_datetime nullable` — deduplicate email alerts (US-141)

### `organizations`
- **Source stories:** US-141
- `freeball_review_sla_days integer not null default 7` — configurable threshold for aging alerts (US-141)

### `flagged_captures`
- **Source stories:** US-147
- `auto_rule_id uuid fk nullable` — links to `auto_flag_rules` when auto-flagged; null for manual flags
- Existing columns sufficient; no new fields needed

### `runs`
- **Source stories:** US-137 (regression suite)
- `regression_suite_dataset_version_id uuid fk nullable` — if set, run appends regression-dataset steps post-graph; failures always FAIL verdict

### `branch_promotions`
- **Source stories:** US-139
- `target_kind text not null default 'script_version'` — enum: `:script_version | :persona_version` (allows promoting freeball expectations to persona_expectations)
- `target_persona_version_id uuid fk nullable` — set iff `target_kind='persona_version'`; FK to `persona_versions`

### `memberships`
- **Source stories:** US-141, US-148
- `digest_frequency text nullable` — enum: `:daily | :weekly | :monthly`; null = opt-out (US-148)

## New indexes / constraints

| Table | Index | Purpose |
|---|---|---|
| `audit_events` | `(organization_id, timestamp DESC)` | Range queries for export |
| `audit_events` | `(actor_user_id)` | "Actions by user" UI filter |
| `audit_events` | `(subject_id) WHERE subject_id IS NOT NULL` | Drill-down from resource |
| `auto_flag_rules` | `(organization_id, enabled)` | Rules evaluation on ingest |
| `webhook_deliveries` | `(webhook_id, sent_at DESC)` | Delivery log UI |
| `webhook_deliveries` | `(next_retry_at) WHERE sent_at IS NULL` | Retry job queue trigger |
| `review_queue` | `(organization_id, assigned_to_user_id, status)` | "My queue" filtering |
| `review_queue` | `(assigned_at) WHERE status='pending'` | SLA age sorting |
| `sso_config` | `(organization_id)` unique | One config per org |

## Changes to existing fields

| Entity | Field | Change | Rationale |
|---|---|---|---|
| `run_steps` | `dataset_entry_ref jsonb nullable` | **New field** | Links dataset-run steps to entry for drill-down (Wave 2 dataset foundation) |
| `script_versions` | `regression_suite_dataset_version_id uuid fk nullable` | **New field on `scripts` head** | Attaches regression dataset to script for US-137 |
| `review_queue` | `status text` | Add `:dismissed` value | Supports bulk dismiss action (US-138) |

## Infrastructure recommendations

1. **Audit events as TimescaleDB hypertable:** `timestamp` partition key (monthly); 365+ day retention enforced by data-warehouse cleanup job
2. **Webhook deliveries retry queue:** Use Redis sorted set `webhook:retry:{org_id}` with backoff schedule; simple state machine in app (max 5 retries, 5min → 2hr max delay)
3. **Auto-flagging rules eval:** Sync evaluation on OTel span ingest; rule config is small enough for in-memory cache (refresh on mutation)
4. **SSO metadata secrets:** Store in external vault (AWS Secrets Manager, HashiCorp Vault, or Infisical); `sso_config.metadata` references via `auth_ref` pattern established in agent_versions

## Story → schema_refs recommendations

| Story | schema_refs |
|---|---|
| US-136 | *(CLI output; no schema)* |
| US-137 | `runs, scripts, datasets, regression_suite_dataset_version_id` |
| US-138 | `review_queue` |
| US-139 | `branch_promotions, persona_versions, persona_expectations, target_kind` |
| US-140 | `review_queue, assigned_to_user_id, assigned_at` |
| US-141 | `review_queue, organizations, freeball_review_sla_days, sla_warning_sent_at` |
| US-142 | `sso_config, organizations, memberships` |
| US-143 | `audit_events` |
| US-144 | `webhooks, webhook_deliveries` |
| US-145 | *(SDK; no schema)* |
| US-146 | *(SDK publish; no schema)* |
| US-147 | `auto_flag_rules, flagged_captures, auto_rule_id` |
| US-148 | `memberships, digest_frequency, flagged_captures` |
| US-149 | `datasets, dataset_versions, dataset_entries, source: huggingface` tag |
| US-150 | `dataset_versions, dataset_entries` *(no new schema; export only)* |

## Open questions / concerns

1. **Audit event redaction:** Default capture all (metadata, IP, UA), or user-configurable/PII-scrubbed? Recommend default-capture for SOC2; redaction policy can tighten later.
2. **Webhook event schema versioning:** Events are currently unversioned JSON; if agent output or run structure changes, backward compat? Recommend version field in event envelope.
3. **Auto-rule JSONB config complexity:** Current design stores pattern/threshold inline. If rules grow complex (e.g., compound AND/OR logic), consider migrating to rule-chain table later.
4. **Regression suite attachment:** Current `runs.regression_suite_dataset_version_id` assumes one regression dataset per script. If users want multiple (e.g., "regressions" vs. "edge cases"), consider junction table.
5. **SLA config:** Currently org-wide (`organizations.freeball_review_sla_days`); confirm no per-queue variation needed.

---

**Report:** Done. **6 new entities** (`auto_flag_rules`, `audit_events`, `webhooks`, `webhook_deliveries`, `sso_config`), **3 new fields on existing** (`branch_promotions.target_kind/target_persona_version_id`, `runs.regression_suite_dataset_version_id`, `sso_config` entity new), **9 new indexes**, **4 existing-field changes/additions**.

---

# US-107: LLM Prompt Template Registry

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Dave, I want a centralized, versioned registry of prompt templates for every AI generation domain so that I can tune, A/B test, and hot-swap prompts without deploying new code — and so every LLM call in the system uses a known, auditable template rather than ad-hoc string construction.

## Acceptance Criteria
- [ ] ETS-backed template registry stores prompt templates per domain key: `{domain, variant, version}` — domains include room, npc_dialogue, combat, item, quest_step, ambient, help, moderation, summarization
- [ ] Templates are versioned with semantic versioning; active version per domain configurable at runtime via admin panel without application restart
- [ ] A/B testing support: each domain can have multiple active variants with traffic split weights (e.g., 70% variant_a, 30% variant_b); variant assignment deterministic per player_id for consistent experience per player
- [ ] Templates loaded from `priv/ai/templates/` directory at startup and hot-reloadable via admin panel "Reload Templates" action — no deploy required
- [ ] Each template defines: system_prompt, user_prompt_template (EEx), required_assigns (list of atoms), optional_assigns with defaults, token_budget (max tokens for this template), and model_hint (optional preferred model)
- [ ] Template validation on load: required_assigns verified against template interpolations; EEx compilation errors surfaced as admin alerts; invalid templates rejected, previous version retained
- [ ] Admin panel shows per-template usage stats: call count, avg latency, avg token usage, cache hit rate, A/B variant performance comparison (quality scores from US-125)
- [ ] Template registry state backed by DETS for persistence across restarts; ETS serves reads (zero-copy), DETS backs writes

## Notes
`BladeOfEternity.AI.TemplateRegistry` — GenServer owning ETS table `:ai_templates` and DETS file `priv/ai/templates.dets`. On start: loads DETS into ETS; if DETS is empty or stale, loads from `priv/ai/templates/*.yaml` and populates both.

Template YAML format:
```yaml
domain: npc_dialogue
variant: default
version: "1.2.0"
model_hint: claude-sonnet
token_budget: 1200
required_assigns: [npc_name, npc_archetype, player_name, conversation_history]
optional_assigns:
  npc_mood: calm
  world_event: null
system_prompt: |
  You are the voice of <%= npc_name %>, a <%= npc_archetype %>...
user_prompt_template: |
  Player says: "<%= last_player_utterance %>"
  ...
```

Hot-reload triggered via `TemplateRegistry.reload/0` — reads all YAML files, validates each, updates ETS entries for valid templates, emits `{:template_reloaded, domain, version}` events for logging, leaves invalid templates unchanged.

A/B assignment: `TemplateRegistry.get_template/2` accepts `player_id`; hashes `{domain, player_id}` with `:erlang.phash2/2`, takes modulo against total variant weight. Same player always gets same variant within an experiment window. Experiment windows configurable per domain.

Admin panel implemented in Phoenix LiveView at `/admin/ai/templates`. Shows template list with current version, variant weights, and aggregated stats pulled from Telemetry/Prometheus. "Edit" opens inline YAML editor with validation; "Activate" promotes draft to active without restart. "A/B Config" form sets variant weights.

Template quality scores (US-125) joined to registry display via admin dashboard query: avg score per `{domain, variant}` over last 7 days, enabling data-driven variant promotion decisions.

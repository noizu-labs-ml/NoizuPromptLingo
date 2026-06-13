# YAML Script Schema (canonical)

This is the authoritative spec for the CodeFresh YAML script format. Round-trip
invariants, contract-frozen in Stage 0.5, enforced by `Codefresh.Scripts.YamlCodec`
(backend) and the CLI importer (Stage 7).

## Round-trip invariant

For any published script version `V`, the following must always hold:

```
checksum(V) == sha256(encode(V)) == sha256(encode(decode(encode(V))))
```

This drives dedup at `Rubrics.Marketplace.import/3`, `Scripts.publish_version/2`,
and enables git-versioning workflows in Stage 7. Breaking this invariant is a
hard no-go.

## Document shape

```yaml
script:
  slug: greeter-flow           # required; lowercase-dash; unique within org
  name: "Greeter Flow"         # required; 1-200 chars
  description: null            # nullable
  version: 1                   # integer ≥1

root: start                    # node_key of root_node; must exist in `nodes`

nodes:
  - key: start                 # required; lowercase alphanumeric with _-
    kind: user_turn            # user_turn | system | assistant_turn | terminal | freeball_anchor
    prompt:                    # null or {slug: string, version: int}
      slug: welcome
      version: 1
    tone: null                 # optional free-text tag
    eval_tags: []              # optional list of strings
    freeball_policy: allow     # allow | deny | anchor
    position:                  # optional map (editor layout hint)
      x: 0
      y: 0
    metadata: {}               # optional free-form JSON object
    expectations:
      - label: "contains greeting"         # required; 1-400 chars
        weight: "1.000"                    # decimal string, 0.000-1.000
        direction: positive                # positive | negative
        scoring_method: regex              # lm_judge | rubric | regex | semantic | structural
        config:                            # method-specific shape; see below
          pattern: "(?i)hello|hi"
        rubric: null                       # null unless scoring_method == "rubric"

edges:
  - from: start                # source node_key
    to: end                    # target node_key; self-loops only allowed if match_method=always
    match_method: always       # regex | semantic | lm_judge | structural | always | freeball
    match_config: {}           # method-specific
    priority: 0                # integer, lower wins ties
    label: null                # optional
```

## Ordering (determinism)

For re-encoded output to be identical to the original (checksum stability),
collections MUST be sorted:

- `nodes[]` ascending by `key`
- `nodes[*].expectations[]` ascending by `label`
- `edges[]` by `(from_node_id, priority, to_node_id)` — in the canonical
  encoder the backend sorts by UUID, but from the YAML consumer perspective
  this equates to `(from, priority, to)` since node keys are 1:1 with ids
  within a version

## Scoring-method config shapes

| method | required config fields | optional |
|---|---|---|
| `regex` | `pattern` (PCRE) | `flags` |
| `rubric` | (none in config; pin via `rubric: {slug, version}`) | `criteria_weights` override |
| `lm_judge` | `judge_prompt: {slug, version}`, `judge_model` | `temperature` |
| `semantic` | `reference_text` (embedding populated async) | `threshold` |
| `structural` | `json_schema` or `shape` | — |

## Reference resolution policy

All `prompt`, `rubric`, `judge_prompt` refs use `{slug, version}`. On import:

- **Strict** (MVP): missing refs abort with `{:prompt_not_found, slug, version}` or `{:rubric_not_found, slug, version}`. The importer surfaces an actionable message pointing to the missing entity.
- **Auto-create** (Wave 2, out of scope): deferred.

Cross-org imports fail at the backend's `pinnable?/2` check — any imported YAML's
prompt/rubric must already exist in the target organization.

## Error taxonomy (decoder)

| Code | Meaning |
|---|---|
| `yaml_root_must_be_mapping` | File does not parse to a YAML map |
| `yaml_missing_script_fields` | `script.slug` or `script.name` absent |
| `no_nodes` | `nodes[]` empty |
| `{root_not_in_nodes, key}` | `root` references a `node_key` not present |
| `{edge_from_missing, key}` | `edges[].from` references a missing node |
| `{edge_to_missing, key}` | `edges[].to` references a missing node |
| `{prompt_not_found, slug, version}` | Prompt ref unresolvable |
| `{rubric_not_found, slug, version}` | Rubric ref unresolvable |
| `{yaml_parse_error, reason}` | Underlying `yaml_elixir` failure |

## Reserved keys (future-compatibility)

The following YAML keys are reserved and IGNORED on decode; do not repurpose:

- `persona_overlays` — will carry US-051 persona expectations in a cross-version
  shareable form (Wave 2).
- `freeball_anchors` — US-022 anchor metadata (Wave 2).
- `metadata.codefresh.*` — reserved namespace for engine-managed hints
  (`imported_from`, `fork_of`, `generated_by`).

## Round-trip tests

Located at `app/backend/test/codefresh/scripts/publish_test.exs`. The critical
test is `"exports YAML and re-imports produces identical checksum"` — any change
to the canonical encoder that breaks this is a regression.

---

**Status:** Contract-frozen at v1.0.0 (2026-04-20). Breaking changes require a
major version bump of the YAML schema and an explicit migration note.

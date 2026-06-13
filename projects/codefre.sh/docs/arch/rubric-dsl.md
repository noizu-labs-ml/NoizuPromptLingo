# Rubric DSL (canonical)

The rubric DSL governs how LLM-as-judge evaluation is declared and dedup'd.
Contract-frozen in Stage 0.5, enforced by `Codefresh.Rubrics.RubricVersion`
changesets and `Codefresh.Rubrics.Scoring`.

## Rubric version shape

A `rubric_version` row pins the following canonical body:

```json
{
  "judge_prompt_version_id": "uuid",
  "judge_model": "anthropic:claude-sonnet-4-5",
  "scale": { ... },
  "criteria": { ... },
  "n_samples": 1
}
```

`checksum = sha256(canonical(...))` drives publish dedup. Two rubric versions
in the same rubric head with identical canonical bodies return `{:ok, :noop}`.

## Scale types

### `continuous`
```json
{"type": "continuous", "min": 0, "max": 1}
```
Numeric score in `[min, max]`. Judge returns a float.

### `discrete`
```json
{"type": "discrete", "min": 0, "max": 5}
```
Numeric score in `[min, max]`, rounded to integers. Judge returns an int.

### `ladder`
```json
{
  "type": "ladder",
  "values": [
    {"label": "poor",        "score": 0.0},
    {"label": "adequate",    "score": 0.5},
    {"label": "excellent",   "score": 1.0}
  ]
}
```
Enum with monotonic non-decreasing scores. Judge returns a `label`; backend maps
to numeric via `Rubrics.Scoring.score_for_label/2` for aggregation. Results UI
displays the label prominently (US-057 — Nia's academic reporting preference).

### `enum`
Same shape as `ladder`. Semantic distinction: `enum` is unordered (e.g.
pass/warn/fail), `ladder` is strictly ordered.

## Criteria (US-056 multi-criterion)

```json
{
  "items": [
    {"name": "accuracy",   "weight": 0.6, "direction": "positive"},
    {"name": "helpfulness","weight": 0.3, "direction": "positive"},
    {"name": "safety",     "weight": 0.1, "direction": "negative"}
  ]
}
```

- `weight ∈ [0.0, 1.0]`; weights need not sum to 1 — `Rubrics.Scoring.weighted_average/2`
  normalizes at score time by dividing by `Σ weights`.
- `direction` ∈ `{positive, negative}`. Negative criteria invert: score `1.0` means
  "worst behavior maximally present"; penalized in the aggregate.
- Empty `criteria` (map with no `items`) is valid — single-judgment rubric.

### Per-criterion judge model override

```json
{
  "items": [
    {"name": "safety", "weight": 1.0, "judge_model": "anthropic:claude-opus-4-1"}
  ]
}
```

Individual criteria may override the rubric-level `judge_model` (Wave 2 — stub
accepted by changeset now; runner dispatch in Stage 5+).

## `n_samples` (US-120 confidence bands)

`n_samples ∈ [1, 10]`. When `> 1`:

- Judge is invoked `n_samples` times per score
- Backend computes `%{mean, stddev, low, high}` via `Rubrics.Scoring.confidence_band/1`
  (±1σ by default; wider intervals configurable per call)
- Cost scales linearly — runner warns before triggering `n > 3` runs

Single-sample (`n=1`) is the default; stddev is `0.0`.

## Preview (US-058 render-only)

`Rubrics.preview_render/3` renders the judge prompt against a `{sample_input,
sample_response}` pair without invoking the LLM. Returns:

```json
{
  "judge_model": "anthropic:claude-sonnet-4-5",
  "scale": { ... },
  "criteria": { ... },
  "n_samples": 1,
  "rendered_judge_prompt": "...",
  "estimated_tokens": 420,
  "mode": "render_only"
}
```

LLM execution is deferred to Stage 4 adapter integration; the preview UX never
charges the user before invocation (Sofia's calibration workflow).

## Marketplace (US-119)

The cross-org rubric marketplace catalogs curated rubrics for import. Import:
1. Deep-copies the `rubric_version` body (not the ID reference) into the
   importer's org as a fresh rubric head + version
2. Fails explicitly with `:judge_prompt_requires_local_copy` if the author's
   `judge_prompt_version_id` isn't pinnable in the importer's org — the UI
   surfaces this as "copy the judge prompt first, then retry"
3. Increments `marketplace_rubrics.download_count`

Publishing back to the marketplace (author side) is Wave 3.

## Validation rules (summary)

| Rule | Changeset location |
|---|---|
| `scale.type ∈ {continuous, discrete, ladder, enum}` | `validate_scale/1` |
| continuous/discrete: `max > min`, both numeric | `validate_numeric_scale/2` |
| ladder/enum: non-empty `values`, each `{label, score}`, non-decreasing scores | `validate_enum_scale/2` |
| criteria: each `{name, weight ∈ [0,1]}`; empty map OK | `validate_criteria/1` |
| `n_samples ∈ [1, 10]` | `validate_number/3` |
| `judge_prompt_version_id` pinnable within org | `Rubrics.publish_version/2` |

---

**Status:** Contract-frozen at v1.0.0 (2026-04-20). Any change to canonical
checksum computation is a breaking change; bump DSL version + write a migration
note.

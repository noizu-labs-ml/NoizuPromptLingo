# US-125: LLM Observability and Quality Metrics

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Dave, I want full observability into every LLM call the system makes — latency, token usage, quality scores, failure rates, cache performance — organized by generation domain, so that I can diagnose problems, optimize costs, and demonstrate quality improvements with data rather than intuition.

## Acceptance Criteria
- [ ] Every LLM call emits a Telemetry event with: domain, variant_id, model_id, prompt_tokens, completion_tokens, latency_ms, cache_hit (bool), error (if any), content_hash — consumed by multiple handlers
- [ ] Quality scoring pipeline runs asynchronously on a sample of completions: automated voice consistency score (US-110), semantic coherence score (embedding distance from expected style), and human rating (when available from US-119 feedback) — all stored in `ai_quality_log`
- [ ] Prometheus metrics exported: `ai_request_latency_ms` (histogram, labels: domain, model_id), `ai_token_usage_total` (counter, labels: domain, model_id, type), `ai_cache_hit_ratio` (gauge, labels: domain), `ai_error_rate` (counter, labels: domain, error_type), `ai_quality_score` (gauge, labels: domain, score_type)
- [ ] Grafana dashboards pre-configured: (1) AI System Health — latency percentiles, error rate, cache hit rate; (2) Quality Trends — quality scores by domain over time, A/B comparison; (3) Cost Analysis — token spend by domain, cost trends, budget utilization
- [ ] Distributed tracing via OpenTelemetry: each LLM call carries a trace spanning context assembly → cache check → LLM dispatch → safety filter → ARIA delivery; traces inspectable in Jaeger/Tempo for latency root cause analysis
- [ ] Failure analysis: errors classified by type (provider_timeout, token_limit_exceeded, content_filtered, circuit_open, context_assembly_failure) and tracked per domain — error spike alerts via Alertmanager
- [ ] Quality regression detection: if any domain's 7-day rolling quality score drops >10% from its 30-day baseline, admin alert fired with domain, score delta, and recent sample outputs for review
- [ ] AI observability data retained: raw `ai_usage_log` 90 days, aggregated metrics indefinitely, quality scores with content references 30 days (privacy), traces 7 days

## Notes
Telemetry instrumentation: `BladeOfEternity.AI.Telemetry` module defines event names following Telemetry conventions: `[:blade, :ai, :request, :start]`, `[:blade, :ai, :request, :stop]`, `[:blade, :ai, :request, :exception]`. Measurements: `{latency_ms, prompt_tokens, completion_tokens, cache_hit}`. Metadata: `{domain, variant_id, model_id, player_id, content_hash}`.

Telemetry handlers:
1. `BladeOfEternity.AI.Telemetry.PrometheusHandler` — maps events to `TelemetryMetricsPrometheus` metrics; emits Prometheus-scrapable metrics at `/metrics`
2. `BladeOfEternity.AI.Telemetry.LogHandler` — writes structured log entries to `ai_usage_log` PostgreSQL table with all fields
3. `BladeOfEternity.AI.Telemetry.QualityHandler` — on `:stop` events, samples at configured rate per domain, enqueues quality scoring Oban jobs

Quality scoring Oban worker (`BladeOfEternity.Workers.QualityScorer`): retrieves completion text from `ai_usage_log` by content_hash, runs voice consistency scorer (re-uses US-110 classifier), writes result to `ai_quality_log`. Human ratings joined to `ai_quality_log` by content_hash when feedback arrives (US-119).

`ai_quality_log` schema: `{id, content_hash, domain, variant_id, model_id, voice_score, coherence_score, human_rating, composite_score, scored_at}`. Composite score formula: `voice_score * 0.4 + coherence_score * 0.4 + coalesce(human_rating, 0.5) * 0.2`.

OpenTelemetry integration: `opentelemetry_phoenix` and a custom `BladeOfEternity.AI.OtelWrapper` add span instrumentation around the LLM pipeline. Span names: `ai.context_assemble`, `ai.cache_check`, `ai.llm_dispatch`, `ai.safety_filter`, `ai.sentence_buffer`, `ai.aria_deliver`. Each span carries domain and player_id as attributes (player_id hashed for privacy in traces). Traces exported to OTLP collector → Tempo → Grafana.

Grafana dashboards defined as code in the k8 infra repo (`helm/observability/grafana/dashboards/ai-*.json`). Panels use PromQL queries against Prometheus. Key panels: latency heatmap (domain × time), quality score trend line (domain, 30-day), cache hit ratio gauge per domain, error rate bar chart by type, cost area chart by domain over week.

Quality regression detection: Oban scheduled job (`BladeOfEternity.Workers.QualityRegressionCheck`) runs daily. For each domain: queries 7-day rolling avg and 30-day baseline from `ai_quality_log`. If `rolling_avg < baseline * 0.9`, fires Alertmanager alert via Prometheus alerting rule. Alert payload includes: domain, rolling_avg, baseline, delta_percent, and link to Grafana quality trend dashboard.

Privacy handling: `ai_usage_log` stores content_hash (SHA-256 of completion text), not raw text. Raw text retained for quality scoring window (30 days) in a separate `ai_content_cache` table partitioned by week, auto-dropped after retention period via PostgreSQL partition management. This allows quality scoring within window without indefinite raw content retention.

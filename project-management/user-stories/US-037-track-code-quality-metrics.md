# User Story: Track Code Quality Metrics for Agent Output

**ID**: US-037
**Persona**: P-005 (Dave the Fellow Developer)
**Priority**: Low
**Status**: Draft
**Created**: 2026-02-02T10:20:00Z

## Story

As a **fellow developer**,
I want to **track quality metrics for agent-generated code over time**,
So that **I can identify patterns and improve agent effectiveness**.

## Acceptance Criteria

### Metric Definitions
- [ ] **Revision Count**: Track number of edits per artifact (stored in artifact_versions table)
- [ ] **Review Cycles**: Count iterations from submission to approval (review_events table)
- [ ] **Defect Rate**: Ratio of bugs found post-merge / total artifacts (defect_reports table)
- [ ] **Style Violations**: Lint/format errors per 1000 LOC (code_quality_checks table)
- [ ] Each metric has formula, units, and baseline value documented

### Data Collection & Storage
- [ ] Metrics captured automatically on: commit, review completion, test failure, lint run
- [ ] Database schema includes `code_quality_metrics` table with:
  - `id`, `artifact_id`, `agent_id`, `metric_type`, `value`, `timestamp`, `context_hash`
- [ ] Metrics aggregated daily via scheduled task
- [ ] Historical data retained for minimum 90 days

### Analysis & Reporting
- [ ] Metrics queryable by: agent_id, task_type, date_range, artifact_type
- [ ] Baseline metrics calculated from human-authored code in same project
- [ ] Dashboard displays: current value, 30-day moving average, % change from baseline
- [ ] Trend charts show metrics over time with standard deviation bands
- [ ] Export to CSV/JSON for external analysis

### Alerts & Thresholds
- [ ] Alert triggers defined:
  - Defect rate > 2x baseline for 3 consecutive days
  - Review cycles > 5 for any single artifact
  - Style violations increase > 50% week-over-week
- [ ] Alerts sent to monitoring channel (chat room or webhook)
- [ ] Alert includes metric value, threshold, and affected artifacts

### Context Correlation
- [ ] Track `context_hash` (hash of context artifacts used) with each metric
- [ ] Compare metrics before/after context changes
- [ ] Report shows: "Context v2 → 30% fewer review cycles than v1"

## Technical Details

### Database Schema
```sql
CREATE TABLE code_quality_metrics (
    id INTEGER PRIMARY KEY,
    artifact_id INTEGER REFERENCES artifacts(id),
    agent_id TEXT,
    metric_type TEXT CHECK(metric_type IN ('revision_count', 'review_cycles', 'defect_rate', 'style_violations')),
    value REAL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    context_hash TEXT,
    metadata JSON
);

CREATE INDEX idx_metrics_agent ON code_quality_metrics(agent_id, timestamp);
CREATE INDEX idx_metrics_type ON code_quality_metrics(metric_type, timestamp);
```

### Metric Calculation Formulas
- **Revision Count**: `COUNT(artifact_versions WHERE artifact_id = X)`
- **Review Cycles**: `COUNT(DISTINCT review_events.cycle WHERE artifact_id = X)`
- **Defect Rate**: `COUNT(defects WHERE created > merge_date) / COUNT(merged_artifacts) * 100`
- **Style Violations**: `SUM(lint_errors + format_errors) / (lines_of_code / 1000)`

### API Endpoints
- `GET /api/metrics/summary?agent_id={id}&period={days}` - Aggregate metrics
- `GET /api/metrics/trend?metric={type}&granularity={day|week|month}` - Time series data
- `GET /api/metrics/compare?baseline=human&agent_id={id}` - Comparison view
- `POST /api/metrics/record` - Manual metric recording (for testing)

## Notes

- Not about punishing agents—about continuous improvement
- Should inform context artifact updates (US-035)
- Privacy: metrics are aggregate, not individual shaming
- Metrics focused on code quality, not agent "performance"
- Human baseline calculated from commits authored by actual developers

## Dependencies

- Work logs (US-031)
- Reviews (US-034)
- Artifacts (US-008)

## Implementation Tasks

1. **Database Setup**
   - Create `code_quality_metrics` table and indexes
   - Add migration script to `src/npl_mcp/storage/migrations/`

2. **Data Collection Hooks**
   - Hook into artifact save/update to record revision_count
   - Hook into review completion to record review_cycles
   - Hook into test runs to detect defects
   - Hook into lint/format tasks to capture style_violations

3. **Aggregation Service**
   - Create `src/npl_mcp/metrics/aggregator.py`
   - Scheduled task runs daily to compute aggregate metrics
   - Calculate baselines from human-authored code

4. **API Endpoints**
   - Implement metrics query endpoints in `src/npl_mcp/web/api/metrics.py`
   - Add authentication/authorization checks

5. **Dashboard UI**
   - Create metrics dashboard page (optional, can use API + external tools)
   - Charts library (e.g., Chart.js or Plotly)

6. **Alerting**
   - Implement threshold checks in aggregator
   - Send alerts via chat room or webhook

## Open Questions

- [ ] What's a fair baseline for agent vs. human code quality?
  - **Proposal**: Calculate baseline from last 90 days of human commits in same repo
- [ ] How to attribute quality issues (agent vs. unclear requirements)?
  - **Proposal**: Track correlation with requirement changes; if requirements updated, reset defect attribution
- [ ] Should we track positive metrics (e.g., test coverage, documentation completeness)?
  - **Proposal**: Add in v2 after core metrics stable
- [ ] What retention policy for raw metric data?
  - **Proposal**: Keep daily aggregates indefinitely, raw data for 90 days

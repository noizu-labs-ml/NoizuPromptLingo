# DBA -- Database Designer and Tuning -- Project Tracker

## Project Metadata
- **Database**: {PostgreSQL 16}
- **Application**: {project name}
- **ORM/Migration Tool**: {Ecto / Prisma / Drizzle / ActiveRecord / raw SQL}
- **Current Schema Version**: {migration ID or timestamp}
- **Target Date**: {YYYY-MM-DD}
- **Status**: Design / Review / Optimization / Migration / Validation

## Phase Checklist

| Phase | Status | Completed | Notes |
|-------|--------|-----------|-------|
| Requirements Analysis | ☐ Not Started | -- | {data model requirements, access patterns, scale targets} |
| Schema Design | ☐ Not Started | -- | {ERD, table definitions, relationship mapping} |
| Index Strategy | ☐ Not Started | -- | {index plan based on query patterns} |
| Query Optimization | ☐ Not Started | -- | {EXPLAIN analysis, rewrite candidates} |
| Migration Planning | ☐ Not Started | -- | {migration sequence, rollback plan, downtime estimate} |
| Validation | ☐ Not Started | -- | {load testing, query benchmarks, constraint verification} |

Status values: ☐ Not Started | ◧ In Progress | ☑ Complete | ⊘ Blocked | ── Skipped

## Schema Decisions Log

| Decision | Rationale | Alternatives Considered | Date |
|----------|-----------|------------------------|------|
| {e.g., UUID primary keys} | {e.g., distributed-safe, no enumeration} | {e.g., BIGSERIAL -- simpler but not merge-safe} | -- |
| -- | -- | -- | -- |

## Findings Log

| Date | Category | Finding | Severity | Resolution |
|------|----------|---------|----------|------------|
| -- | Schema | -- | Critical / High / Medium / Low | -- |
| -- | Index | -- | -- | -- |
| -- | Query | -- | -- | -- |
| -- | Config | -- | -- | -- |

Categories: Schema / Index / Query / Config / Security / Data Integrity

## Migration Log

| Migration ID | Description | Status | Rollback Tested | Downtime Required | Notes |
|-------------|-------------|--------|-----------------|-------------------|-------|
| -- | -- | Pending / Applied / Rolled Back | Yes / No | Yes ({duration}) / No | -- |

## Performance Baselines

Capture before optimization begins. Re-measure after each change.

| Metric | Baseline | Current | Target | Date Measured |
|--------|----------|---------|--------|---------------|
| p50 query latency | -- ms | -- ms | -- ms | -- |
| p99 query latency | -- ms | -- ms | -- ms | -- |
| Avg queries/sec | -- | -- | -- | -- |
| Table bloat (largest) | -- MB | -- MB | -- MB | -- |
| Index bloat (largest) | -- MB | -- MB | -- MB | -- |
| Connection pool utilization | --% | --% | --% | -- |
| Cache hit ratio | --% | --% | >99% | -- |

## Open Questions

| # | Question | Context | Answer | Resolved |
|---|----------|---------|--------|----------|
| 1 | -- | -- | -- | ☐ |

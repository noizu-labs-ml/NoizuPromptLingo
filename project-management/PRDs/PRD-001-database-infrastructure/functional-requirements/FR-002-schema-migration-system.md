# FR-002: Schema Migration System

**Status**: Completed

## Description

Automatic migration system with version tracking and idempotent column additions. Applies migrations on startup and records applied versions in schema_version table.

## Interface

```python
async def run_migrations(conn: aiosqlite.Connection) -> list[str]:
    """
    Apply all pending migrations to the database.

    Returns list of migration descriptions that were applied.
    Skips migrations already recorded in schema_version table.
    All migrations are idempotent (safe to run multiple times).
    """
```

## Behavior

- **Given** database with no schema_version table
- **When** run_migrations() executes
- **Then** all migrations apply and schema_version records each one

- **Given** database with some migrations applied
- **When** run_migrations() executes
- **Then** only new migrations apply, existing ones are skipped

- **Given** migration adds column that already exists
- **When** migration runs again (idempotent check)
- **Then** migration skips ALTER TABLE and succeeds without error

## Migrations Applied

1. **Migration 1**: Add sessions table with indexes
2. **Migration 2**: Add session_id column to artifacts
3. **Migration 3**: Add session_id column to chat_rooms
4. **Migration 4**: Add taskers table for ephemeral agents
5. **Migration 5**: Add task queue system (queues, tasks, events, artifacts)

## Edge Cases

- **Column already exists**: PRAGMA table_info() checked before ALTER TABLE
- **Migration failure mid-run**: Transaction rollback prevents partial state
- **Concurrent migrations**: Single-writer constraint prevents race conditions
- **Missing schema_version table**: Migration 0 creates it before applying others

## Related User Stories

- US-038
- US-042
- US-044

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for migration logic
Actual coverage: Included in 82% Database Layer coverage

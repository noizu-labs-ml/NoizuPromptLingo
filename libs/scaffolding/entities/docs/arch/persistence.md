# Persistence Architecture

## Overview

Entities declare persistence layers via `@persistence` module attributes using helper functions: `ecto_store/2`, `mnesia_store/2`, `amnesia_store/2`, `redis_store/2`, `dummy_store/2`. Multiple layers can be declared — CRUD operations iterate over all of them.

## Persistence Settings

Each layer is a `persistence_settings` record with:

| Field | Description |
|-------|-------------|
| `table` | The store-specific schema module (e.g., Ecto schema) |
| `store` | The connection/repo module (e.g., `MyApp.Repo`) |
| `type` | The store adapter module (e.g., `Noizu.Entity.Store.Ecto`) |
| `kind` | The entity module (auto-set by `def_entity`) |

## CRUD Pipeline (`Noizu.Repo.Meta`)

Each operation follows a three-phase pipeline:

```
__before_*__(entity, context, options)
    → __do_*__(entity, context, options)
        → __after_*__(entity, context, options)
```

All three phases are `defoverridable` in the generated repo module.

### Create

1. **before**: Generates ID if missing (via identifier handler's `format_id/3`), runs `type__before_create` on typed fields
2. **do**: For each persistence layer, converts entity to record (`as_record`), then persists (`persist(:create, ...)`)
3. **after**: No-op (overridable)

### Get

1. **before**: No-op (overridable)
2. **do**: Tries each persistence layer in order via `fetch_as_entity`, halts on first success
3. **after**: No-op (overridable)

### Update

1. **before**: Validates ID is present, runs `type__before_update` on typed fields
2. **do**: For each persistence layer, converts to record and persists with `:update`
3. **after**: No-op (overridable)

### Delete

1. **before**: Validates ID is present
2. **do**: Iterates persistence layers in reverse order, calling `delete_record`
3. **after**: Runs `type__after_delete` on typed fields

## Store Adapter Protocol

Each store adapter exposes two protocols:

- **`EntityProtocol`** — Entity-level: `persist`, `as_record`, `fetch_as_entity`, `as_entity`, `delete_record`, `from_record`, `merge_from_record`
- **`Entity.FieldProtocol`** — Field-level: same signatures, applied per-field during record conversion

Ecto and Redis additionally provide a `Behaviour` module with default implementations that entities can derive via `@derive`.

## Ecto Integration

Ecto is the primary persistence adapter. It supports `Ecto.Changeset` as input to `create/3` and `update/3` — the changeset is applied to the entity struct before entering the pipeline.

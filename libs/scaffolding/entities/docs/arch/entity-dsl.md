# Entity Definition DSL

## Usage

```elixir
defmodule MyApp.Users.User do
  use Noizu.Entities

  @vsn 1.0
  @repo MyApp.Users
  @sref "user"
  @persistence ecto_store(MyApp.Schema.User, MyApp.Repo)

  def_entity do
    id :uuid
    field :name, nil, :string
    field :email, nil, :string
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end
end

defmodule MyApp.Users do
  use Noizu.Entities
  def_repo()
end
```

## How `def_entity` Works

1. **Attribute registration** — Registers accumulating module attributes for fields (`@__nz_fields`), identifiers (`@__nz_ids`), persistence (`@__nz_persistence`), JSON config (`@__nz_json`), and ACL (`@__nz_acl`).

2. **Persistence extraction** — Reads `@persistence` attributes set before the block and normalizes them into `persistence_settings` records, injecting the current module as `kind`.

3. **Block evaluation** — The user's `id`, `field`, `transient`, and `pii` macro calls execute, each pushing settings into the registered attributes.

4. **Default fields** — Automatically adds `:vsn`, `:meta`, and `:__transient__` fields if not declared.

5. **Struct emission** — Calls `defstruct` with the accumulated field defaults.

6. **Metadata injection** — Builds the `__noizu_meta__/0` map containing all field, identifier, JSON, ACL, and persistence metadata. Also derives `Noizu.EntityReference.Protocol`.

7. **ERP hooks** — Based on the identifier type (`:uuid`, `:integer`, `:atom`, `:ref`, `:dual_ref`), injects `kind/1`, `id/1`, `ref/1`, `sref/1`, `entity/2`, and `stub/0,3` functions via the appropriate identifier handler module.

## Field Macros

| Macro | Purpose |
|-------|---------|
| `id(type, opts)` | Declares the entity identifier and its type |
| `field(name, default, type, opts)` | Declares a field with optional ecto type and store/config overrides |
| `transient do ... end` | Wraps fields that should not be persisted |
| `pii(level) do ... end` | Wraps fields with PII sensitivity (`:sensitive`, `:private`) |

## Field Type Mapping

Primitive types (`:string`, `:integer`, `:uuid`, etc.) are tagged as `{:ecto, type}` for changeset generation. Module types (e.g., `Noizu.Entity.TimeStamp`) are stored directly and expected to implement `type__before_create/4` and `type__before_update/4` callbacks.

## Repo Convention

By default, the repo module is inferred from the entity module path:
- `MyApp.Users.User` → repo is `MyApp.Users`
- With `legacy_mode` config: `MyApp.User` → repo is `MyApp.User.Repo`

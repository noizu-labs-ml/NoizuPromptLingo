# noizu_labs_entities (0.3.1)

Entity/Repo macros with rich metadata for persistence, access control, JSON serialization, and schema evolution.

## Installation
```elixir
{:noizu_labs_entities, "~> 0.3.1"}
# Pulls in noizu_labs_core automatically
```

## Defining an Entity

```elixir
defmodule MyApp.Entity.User do
  use Noizu.Entity

  @vsn 1.0
  @sref "user"
  @persistence ecto_store(MyApp.Schema.User, MyApp.Repo)

  def_entity do
    id :uuid
    field :name
    field :email
    field :title, "default_value"
    field :time_stamp, nil, Noizu.Entity.TimeStamp

    @transient true
    field :ephemeral_data

    @pii :sensitive
    field :passport_number

    @restrict :admin
    field :internal_notes

    @json as: :display_name
    field :name_formatted

    @json omit: true
    field :password_hash
  end
end
```

## Defining a Repo

```elixir
defmodule MyApp.Entity.Users do
  use Noizu.Repo
  def_repo()
end
```

## Entity Configuration

### Identifier Types
- `:uuid` — UUID v4 auto-generated
- `:integer` — Integer ID (typically from database sequence)
- `:string` — String identifier
- Custom — Any type, must implement encoding

### Persistence Layers
```elixir
@persistence ecto_store(SchemaModule, RepoModule)  # Ecto/SQL
@persistence dummy_store()                          # No-op (testing)
# Mnesia support via nuamnesia optional dep
```

### Schema Versioning
```elixir
@vsn 1.0  # Increment when schema changes
```
Enables schema evolution — old records can be migrated on read.

### String Reference (sref)
```elixir
@sref "user"  # Produces refs like "ref.user.abc123"
```
Human-readable entity identifier for logging, debugging, cross-system references.

## Field Annotations

### @transient
```elixir
@transient true
field :computed_value

# Block syntax
transient do
  field :cache_data
  field :temp_state
end
```
Field is NOT persisted to database or cache. Exists only in memory.

### @pii
```elixir
@pii :sensitive
field :ssn

@pii :low
field :email

# Block syntax
pii do
  field :phone
  field :address
end

pii(:low) do
  field :city
end
```
Marks personally identifiable information. Affects inspect output and logging — sensitive fields are redacted.

### @restrict
```elixir
@restrict :admin
field :internal_score

@restrict :user
field :preferences

@restrict {:role, :manager}
field :team_budget
```
Access control annotations. Checked during serialization and access.

### @json
```elixir
@json true           # Include in JSON output
@json omit: true     # Exclude from JSON output
@json as: :alias     # Rename in JSON output
```
Controls Jason encoding behavior.

### @config
```elixir
@config auto: true   # Automatic configuration
```

## Built-in Field Types

| Type | Module | Fields |
|------|--------|--------|
| TimeStamp | `Noizu.Entity.TimeStamp` | `created_on`, `modified_on` |
| UUIDReference | `Noizu.Entity.UUIDReference` | Reference to another entity by UUID |
| Extended UUIDReference | `Noizu.Entity.Extended.UUIDReference` | Reference with metadata |
| Path | `Noizu.Entity.Path` | Hierarchical path data |

## Metadata Inspection

```elixir
Noizu.Entity.Meta.meta(MyApp.Entity.User)        # Full metadata map
Noizu.Entity.Meta.sref(MyApp.Entity.User)         # "user"
Noizu.Entity.Meta.persistence(MyApp.Entity.User)  # Persistence config
Noizu.Entity.Meta.repo(MyApp.Entity.User)         # Repo module
Noizu.Entity.Meta.id(MyApp.Entity.User)           # ID type
Noizu.Entity.Meta.fields(MyApp.Entity.User)       # Field definitions
```

## Jason Encoding

```elixir
defmodule MyApp.Entity.User do
  use Noizu.Entity
  def_entity do
    # ...
  end
  jason_encoder()  # or jason_encoder(only: [:name, :email])
end

defmodule MyApp.Entity.Users do
  use Noizu.Repo
  def_repo()
  jason_repo_encoder()
end
```

## Umbrella Mode
```elixir
use Noizu.Entities, umbrella: true
```
For monorepo setups — uses `in_umbrella: true` for core dependency.

## Full Worked Example

```elixir
# 1. Define entity
defmodule MyApp.Entity.Post do
  use Noizu.Entity
  @vsn 1.0
  @sref "post"
  @persistence ecto_store(MyApp.Schema.Post, MyApp.Repo)

  def_entity do
    id :uuid
    field :title
    field :body
    field :author, nil, Noizu.Entity.UUIDReference
    field :time_stamp, nil, Noizu.Entity.TimeStamp
    field :status, :draft

    @pii :low
    field :author_email

    @transient true
    field :word_count

    @json omit: true
    field :internal_flags
  end
  jason_encoder()
end

# 2. Define repo
defmodule MyApp.Entity.Posts do
  use Noizu.Repo
  def_repo()
  jason_repo_encoder()
end

# 3. Use it
ctx = Noizu.Context.admin()
{:ok, ref} = Noizu.EntityReference.Protocol.ref(post)
{:ok, "post"} = Noizu.EntityReference.Protocol.sref(post) |> then(fn {:ok, s} -> {:ok, String.split(s, ".") |> hd()} end)
```

## Key Concepts
1. `def_entity` generates a struct + `__noizu_meta__/0` callback with all annotations
2. `def_repo` generates persistence operations keyed off the entity's `@persistence`
3. Every entity auto-implements EntityReference Protocol via the macros
4. Annotations are module attributes that accumulate — order matters for block syntax
5. Multiple persistence layers can coexist (e.g., Ecto primary + Mnesia cache)

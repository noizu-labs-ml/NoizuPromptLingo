# seed_helper (0.1.1)

Incremental database seeding with dependency ordering and environment filtering.

## Installation
```elixir
{:seed_helper, "~> 0.1.1"}
```

## Setup
```elixir
# config.exs
config :seed_helper, repo: MyApp.Repo

# Migration
defmodule MyApp.Repo.Migrations.SetupSeedHelper do
  use Ecto.Migration
  def up(), do: SeedHelper.Migration.up(1)
  def down(), do: SeedHelper.Migration.down(1)
end
```

Creates tables: `seed_helper_seeds` (tracks applied seeds) and `seed_helper_handles` (named values).

## Usage (priv/repo/seeds.exs)

```elixir
require SeedHelper
import SeedHelper

begin_session()

# Basic seed — runs once, tracked by {name, version}
seed({"Users", "1"}) do
  user = Repo.insert!(%User{name: "Alice", email: "alice@example.com"})
  set_handle("alice_id", user.id)
end

# Dependent seed — queued until prerequisite applied
requires_seed({"Users", "1"}) do
  seed({"Posts", "1"}) do
    alice_id = handle("alice_id")
    Repo.insert!(%Post{user_id: alice_id, title: "Hello World"})
  end
end

# Multiple dependencies
requires_seed([{"Users", "1"}, {"Categories", "1"}]) do
  seed({"UserCategories", "1"}) do
    # Both Users and Categories seeds have run
  end
end

# Environment-specific
if_env(:test) do
  seed({"TestFixtures", "1"}) do
    Repo.insert!(%User{name: "TestUser"})
  end
end

if_env([:dev, :test]) do
  seed({"DevData", "1"}) do
    # Dev and test only
  end
end

:ok = end_session()
```

## Handle System
```elixir
set_handle("alice_id", 42)         # Store named value
handle("alice_id")                  # Retrieve (from ETS cache)
handle("missing_key", "default")   # With default
```
Persisted to database + cached in ETS for fast access.

## Key Concepts
1. **Idempotent** — Seeds tracked in DB, only run once per (name, version)
2. **Dependency ordering** — `requires_seed` queues until prerequisites met (Agent-based)
3. **Handle system** — Named values bridge seeds (no manual ID tracking)
4. **Version bumping** — Change version string to re-run a modified seed
5. **Environment gates** — `if_env` checks `Mix.env()` at seed time

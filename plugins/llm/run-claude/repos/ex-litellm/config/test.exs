import Config

# Test: in-memory SQLite, ports that won't collide with a running dev/prod proxy.
config :ex_litellm,
  port: 14_445,
  # Don't auto-start the HTTP listener during unit tests unless a test opts in.
  start_servers: false,
  # In-memory SQLite is per-connection — migrations can't run through the
  # sandbox pool. Tests that need tables create them explicitly.
  auto_migrate: false

config :ex_litellm, ExLiteLLM.Schema.Repo,
  database: ":memory:",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 5

config :logger, level: :warning

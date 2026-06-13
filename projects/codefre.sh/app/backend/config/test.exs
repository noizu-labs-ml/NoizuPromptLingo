import Config

config :codefresh, Codefresh.Repo,
  username: System.get_env("DB_USER", "codefresh"),
  password: System.get_env("DB_PASS", "codefresh_dev"),
  hostname: System.get_env("DB_HOST", "localhost"),
  database:
    "#{System.get_env("DB_NAME", "codefresh")}_test#{System.get_env("MIX_TEST_PARTITION")}",
  port: String.to_integer(System.get_env("DB_PORT") || "5432"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :codefresh, CodefreshWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test-secret-key-base-must-be-at-least-64-bytes-long-for-phoenix!!!!!!!!!!!",
  server: false

config :codefresh, Codefresh.Mailer, adapter: Swoosh.Adapters.Test

# Oban in test mode: inline execution so jobs run synchronously without starting queues.
config :codefresh, Oban, testing: :manual

# US-069: skip starting the scheduler ticker in tests; tests drive tick/1 directly.
config :codefresh, start_scheduler_ticker: false

config :junit_formatter, report_file: "results.xml"

config :swoosh, :api_client, false

config :logger, level: :warning

config :opentelemetry, traces_exporter: :none

config :phoenix, :plug_init_mode, :runtime

import Config

config :seed_helper,
  repo: Codefresh.Repo

config :codefresh, Codefresh.Repo,
  types: Codefresh.PostgrexTypes,
  migration_primary_key: [name: :id, type: :uuid]

config :codefresh,
  ecto_repos: [Codefresh.Repo],
  generators: [timestamp_type: :utc_datetime]

config :codefresh, CodefreshWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: CodefreshWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Codefresh.PubSub

config :codefresh, Codefresh.Mailer, adapter: Swoosh.Adapters.Local

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :codefresh, Codefresh.Guardian,
  issuer: "codefresh",
  secret_key: "dev-secret-key-change-in-production"

# Oban — background job queues for runner (Stage 5) + scheduled runs (US-069)
config :codefresh, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10, runner: 5, scheduled: 2, webhook: 5],
  repo: Codefresh.Repo

# OpenTelemetry — compile-time safe defaults; exporter gated at runtime in runtime.exs
config :opentelemetry,
  resource: [service: %{name: "codefresh-backend"}],
  span_processor: :batch,
  traces_exporter: :none

import_config "#{config_env()}.exs"

import Config

config :seed_helper,
  repo: Derobot.Repo

config :derobot, Derobot.Repo,
  types: Derobot.PostgrexTypes,
  migration_primary_key: [name: :id, type: :uuid]

config :derobot,
  ecto_repos: [Derobot.Repo],
  generators: [timestamp_type: :utc_datetime]

config :derobot, DerobotWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: DerobotWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Derobot.PubSub

config :derobot, Derobot.Mailer, adapter: Swoosh.Adapters.Local

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :derobot, Derobot.Guardian,
  issuer: "derobot",
  secret_key: "dev-secret-key-change-in-production"

config :derobot, :redis, uri: "redis://localhost:6379"

config :derobot, :frontend_url, "http://localhost:3000"

config :derobot, :oidc_enabled, false
config :derobot, :saml_enabled, false
config :derobot, :google_enabled, false
config :derobot, :facebook_enabled, false
config :derobot, :github_enabled, false
config :derobot, :linkedin_enabled, false
config :derobot, :sso_require_invite, false

config :samly, Samly.Provider, []
config :samly, Samly.State, store: Samly.State.Session

config :ueberauth, Ueberauth, providers: []

config :junit_formatter,
  report_file: "results.xml"

import_config "#{config_env()}.exs"

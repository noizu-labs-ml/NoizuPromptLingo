import Config

config :seed_helper,
  repo: Starter.Repo

config :smart_token,
  repo: Starter.Repo

config :starter, Starter.Repo,
  types: Starter.PostgrexTypes,
  migration_primary_key: [name: :id, type: :uuid]

config :starter,
  ecto_repos: [Starter.Repo],
  generators: [timestamp_type: :utc_datetime]

config :starter, StarterWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: StarterWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Starter.PubSub

config :noizu_sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY") || "SG.dev-placeholder"

config :starter, :mail_from,
  {"Starter", "noreply@starter.local"}

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :starter, :redis, uri: "redis://localhost:6379/0", key_prefix: "starter:"

config :starter, Starter.Guardian,
  issuer: "starter",
  secret_key: "dev-secret-key-change-in-production"

# SSO feature flags (all disabled by default, enabled via runtime env vars)
config :ueberauth, Ueberauth, providers: []

config :starter, :oidc_enabled, false
config :starter, :saml_enabled, false
config :starter, :google_enabled, false
config :starter, :facebook_enabled, false
config :starter, :github_enabled, false
config :starter, :linkedin_enabled, false
config :starter, :sso_require_invite, false

config :junit_formatter,
  report_file: "results.xml"

# Rate limiting
config :hammer,
  backend: {Hammer.Backend.ETS,
    [expiry_ms: 60_000 * 60, cleanup_interval_ms: 60_000 * 10]}

# SAML handler
config :samly, Samly.Provider,
  pipeline_handler: StarterWeb.SAMLHandler

# Background jobs
config :starter, Oban,
  repo: Starter.Repo,
  queues: [mailer: 10, default: 10, cleanup: 5],
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7},
    {Oban.Plugins.Cron,
     crontab: [
       {"0 */6 * * *", Starter.Workers.CleanupWorker}
     ]}
  ]

# Feature flags
config :starter, :feature_flags, %{
  email_verification: true,
  webhooks: false,
  file_uploads: false
}

# i18n
config :starter, StarterWeb.Gettext, default_locale: "en"

import_config "#{config_env()}.exs"

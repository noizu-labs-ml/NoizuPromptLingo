import Config

config :seed_helper,
  repo: NoizuPromptLingua.Repo

config :smart_token,
  repo: NoizuPromptLingua.Repo

config :noizu_prompt_lingua, NoizuPromptLingua.Repo,
  types: NoizuPromptLingua.PostgrexTypes,
  migration_primary_key: [name: :id, type: :uuid]

config :noizu_prompt_lingua,
  ecto_repos: [NoizuPromptLingua.Repo],
  generators: [timestamp_type: :utc_datetime]

config :noizu_prompt_lingua, NoizuPromptLinguaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: NoizuPromptLinguaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: NoizuPromptLingua.PubSub

config :noizu_sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY") || "SG.dev-placeholder"

config :noizu_prompt_lingua, :mail_from,
  {"NoizuPromptLingua", "noreply@starter.local"}

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :noizu_prompt_lingua, :redis, uri: "redis://localhost:6379/0", key_prefix: "starter:"

config :noizu_prompt_lingua, NoizuPromptLingua.Guardian,
  issuer: "noizu_prompt_lingua",
  secret_key: "dev-secret-key-change-in-production"

# SSO feature flags (all disabled by default, enabled via runtime env vars)
config :ueberauth, Ueberauth, providers: []

config :noizu_prompt_lingua, :oidc_enabled, false
config :noizu_prompt_lingua, :saml_enabled, false
config :noizu_prompt_lingua, :google_enabled, false
config :noizu_prompt_lingua, :facebook_enabled, false
config :noizu_prompt_lingua, :github_enabled, false
config :noizu_prompt_lingua, :linkedin_enabled, false
config :noizu_prompt_lingua, :sso_require_invite, false

config :junit_formatter,
  report_file: "results.xml"

# Rate limiting
config :hammer,
  backend: {Hammer.Backend.ETS,
    [expiry_ms: 60_000 * 60, cleanup_interval_ms: 60_000 * 10]}

# SAML handler
config :samly, Samly.Provider,
  pipeline_handler: NoizuPromptLinguaWeb.SAMLHandler

# Background jobs
config :noizu_prompt_lingua, Oban,
  repo: NoizuPromptLingua.Repo,
  queues: [mailer: 10, default: 10, cleanup: 5],
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7},
    {Oban.Plugins.Cron,
     crontab: [
       {"0 */6 * * *", NoizuPromptLingua.Workers.CleanupWorker}
     ]}
  ]

# Feature flags
config :noizu_prompt_lingua, :feature_flags, %{
  email_verification: true,
  webhooks: false,
  file_uploads: false
}

# i18n
config :noizu_prompt_lingua, NoizuPromptLinguaWeb.Gettext, default_locale: "en"

import_config "#{config_env()}.exs"

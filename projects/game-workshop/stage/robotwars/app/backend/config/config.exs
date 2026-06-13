import Config

config :seed_helper,
  repo: TheRobotWars.Repo

config :smart_token,
  repo: TheRobotWars.Repo

config :the_robot_wars, TheRobotWars.Repo,
  types: TheRobotWars.PostgrexTypes,
  migration_primary_key: [name: :id, type: :uuid]

config :the_robot_wars,
  ecto_repos: [TheRobotWars.Repo],
  generators: [timestamp_type: :utc_datetime]

config :the_robot_wars, TheRobotWarsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: TheRobotWarsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TheRobotWars.PubSub

config :noizu_sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY") || "SG.dev-placeholder"

config :the_robot_wars, :mail_from,
  {"TheRobotWars", "noreply@starter.local"}

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :the_robot_wars, :redis, uri: "redis://localhost:6379/0", key_prefix: "starter:"

config :the_robot_wars, TheRobotWars.Guardian,
  issuer: "the_robot_wars",
  secret_key: "dev-secret-key-change-in-production"

# SSO feature flags (all disabled by default, enabled via runtime env vars)
config :ueberauth, Ueberauth, providers: []

config :the_robot_wars, :oidc_enabled, false
config :the_robot_wars, :saml_enabled, false
config :the_robot_wars, :google_enabled, false
config :the_robot_wars, :facebook_enabled, false
config :the_robot_wars, :github_enabled, false
config :the_robot_wars, :linkedin_enabled, false
config :the_robot_wars, :sso_require_invite, false

config :junit_formatter,
  report_file: "results.xml"

# Rate limiting
config :hammer,
  backend: {Hammer.Backend.ETS,
    [expiry_ms: 60_000 * 60, cleanup_interval_ms: 60_000 * 10]}

# SAML handler
config :samly, Samly.Provider,
  pipeline_handler: TheRobotWarsWeb.SAMLHandler

# Background jobs
config :the_robot_wars, Oban,
  repo: TheRobotWars.Repo,
  queues: [mailer: 10, default: 10, cleanup: 5],
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7},
    {Oban.Plugins.Cron,
     crontab: [
       {"0 */6 * * *", TheRobotWars.Workers.CleanupWorker}
     ]}
  ]

# Feature flags
config :the_robot_wars, :feature_flags, %{
  email_verification: true,
  webhooks: false,
  file_uploads: false
}

# i18n
config :the_robot_wars, TheRobotWarsWeb.Gettext, default_locale: "en"

import_config "#{config_env()}.exs"

# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :boe,
  ecto_repos: [Boe.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :boe, BoeWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: BoeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Boe.PubSub

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :boe, Boe.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Seed helper
config :seed_helper, repo: Boe.Repo

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian JWT configuration
config :boe, Boe.Guardian,
  issuer: "boe",
  secret_key: "dev-secret-key-change-in-production"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

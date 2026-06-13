import Config

# Configure your database
config :boe, Boe.Repo,
  username: "boe",
  password: "boe_dev",
  hostname: "localhost",
  database: "blade_of_eternity_dev",
  port: String.to_integer(System.get_env("PG_PORT") || "5432"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
config :boe, BoeWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT") || "8083")],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "+FdWSrjfIh9BlSlR/PbnYJqgdgMfE7aCowUc02Ru/K8kQAUGNVcUtv4DmonVeVbK"

# Enable dev routes for dashboard and mailbox
config :boe, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :default_formatter, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

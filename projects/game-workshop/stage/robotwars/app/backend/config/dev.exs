import Config

config :the_robot_wars, TheRobotWars.Repo,
  username: System.get_env("DB_USER", "the_robot_wars"),
  password: System.get_env("DB_PASS", "trw_dev"),
  hostname: System.get_env("DB_HOST", "localhost"),
  database: System.get_env("DB_NAME", "trw_dev"),
  port: String.to_integer(System.get_env("DB_PORT") || "5432"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :the_robot_wars, TheRobotWarsWeb.Endpoint,
  http: [
    ip:
      case System.get_env("PHX_IP") do
        nil -> {127, 0, 0, 1}
        ip_str -> ip_str |> String.to_charlist() |> :inet.parse_address() |> elem(1)
      end,
    port: String.to_integer(System.get_env("PORT") || "5585")
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "CHANGE-ME-generate-with-mix-phx-gen-secret-at-least-64-bytes-long!!!!!!!!!"

config :the_robot_wars, dev_routes: true

config :the_robot_wars, :frontend_url, "http://localhost:3000"

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :noizu_sendgrid,
  sandbox_enable: true

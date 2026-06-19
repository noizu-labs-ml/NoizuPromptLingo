import Config

config :noizu_prompt_lingua, NoizuPromptLingua.Repo,
  username: System.get_env("DB_USER", "noizu_prompt_lingua"),
  password: System.get_env("DB_PASS", "npl_dev"),
  hostname: System.get_env("DB_HOST", "localhost"),
  database: "#{System.get_env("DB_NAME", "noizu_prompt_lingua")}_test#{System.get_env("MIX_TEST_PARTITION")}",
  port: String.to_integer(System.get_env("DB_PORT") || "5432"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :noizu_prompt_lingua, NoizuPromptLinguaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test-secret-key-base-must-be-at-least-64-bytes-long-for-phoenix!!!!!!!!!!!",
  server: false

config :noizu_sendgrid,
  sandbox_enable: true

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :noizu_prompt_lingua, Oban, testing: :inline

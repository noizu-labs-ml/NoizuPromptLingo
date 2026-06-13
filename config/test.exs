import Config

config :noizu_prompt_lingua, NoizuPromptLingua.Repo,
  url: System.get_env("DATABASE_URL", "ecto://tobor:tobor_dev_password@localhost:5432/tobor_locker_test"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :noizu_prompt_lingua, NPLWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warning

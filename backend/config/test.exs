import Config

config :noizu_prompt_lingua, NoizuPromptLingua.Repo,
  username: System.get_env("DB_USER", "noizu_prompt_lingua"),
  password: System.get_env("DB_PASS", "npl_dev"),
  hostname: System.get_env("DB_HOST", "localhost"),
  database: "#{System.get_env("DB_NAME", "noizu_prompt_lingua")}_test#{System.get_env("MIX_TEST_PARTITION")}",
  port: String.to_integer(System.get_env("DB_PORT") || "5432"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2,
  # Shared-mode (async: false) memory tests hold one connection for the whole test; the heavy
  # suites can run >15s, tripping the default 15s ownership/checkout timeout. Give them headroom.
  ownership_timeout: 120_000,
  timeout: 120_000

config :noizu_prompt_lingua, NoizuPromptLinguaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test-secret-key-base-must-be-at-least-64-bytes-long-for-phoenix!!!!!!!!!!!",
  server: false

config :noizu_sendgrid,
  sandbox_enable: true

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :noizu_prompt_lingua, Oban, testing: :inline

# Run memory side-effect workers synchronously in the test process (see
# NoizuPromptLingua.Domains.Memory.Jobs). Bypasses Oban's executor, which corrupts the shared
# Ecto Sandbox connection under load.
config :noizu_prompt_lingua, :jobs_mode, :sync

# Keep asset generation off the genai/network path by default in tests (no real provider
# calls). Tests opt in explicitly via `generator: :genai` (+ a stub generator).
config :noizu_prompt_lingua, :assets_genai_media, false

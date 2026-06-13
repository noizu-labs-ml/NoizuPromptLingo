import Config

config :noizu_prompt_lingua, ecto_repos: [NoizuPromptLingua.Repo]

config :noizu_prompt_lingua, NoizuPromptLingua.Repo,
  url: System.get_env("DATABASE_URL", "ecto://tobor:tobor_dev_password@localhost:5432/tobor_locker"),
  pool_size: 10

config :noizu_prompt_lingua, NPLWeb.Endpoint,
  url: [host: "tobor.locker"],
  http: [port: 4040],
  secret_key_base: System.get_env("SECRET_KEY_BASE", "dev-secret-key-base-that-is-at-least-64-bytes-long-for-phoenix-to-be-happy-about-it"),
  server: true,
  render_errors: [formats: [json: NPLWeb.ErrorJSON]]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"

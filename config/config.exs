import Config

config :noizu_prompt_lingua, ecto_repos: [NoizuPromptLingua.Repo]

config :noizu_prompt_lingua, NoizuPromptLingua.Repo,
  url: System.get_env("DATABASE_URL", "ecto://tobor:tobor_dev_password@localhost:5432/tobor_locker"),
  pool_size: 10

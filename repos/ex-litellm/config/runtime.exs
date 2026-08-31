import Config

# Runtime configuration — evaluated when the release BOOTS (not at build time),
# so env vars set by run-claude's launcher are honored. The CLI/Runtime already
# reads most env vars directly; this covers the ones that must be app-env before
# the supervision tree starts.

if config_env() == :prod do
  # Gateway port: EX_LITELLM_PORT (or PORT) overrides the compiled prod default
  # (4443). run-claude sets this to bind where Claude Code already points.
  port =
    System.get_env("EX_LITELLM_PORT") || System.get_env("PORT")

  if port do
    config :ex_litellm, port: String.to_integer(port)
  end

  if host = System.get_env("EX_LITELLM_HOST") do
    config :ex_litellm, host: host
  end

  # DB path override for the SQLite default (Postgres URL handled at boot by
  # Repo.Config from LITELLM_DATABASE_URL).
  if db = System.get_env("EX_LITELLM_DB_PATH") do
    config :ex_litellm, ExLiteLLM.Schema.Repo, database: db
  end
end

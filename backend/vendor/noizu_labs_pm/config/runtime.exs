import Config

# Noizu.PM.Repo runtime connection — bound from PM_CORE_DATABASE_URL.
#
# In prod the URL is required. In dev we fall back to a local pm_core database
# so `iex -S mix` boots without env vars (mirrors npl-mcp's DATABASE_URL handling).
if config_env() == :prod or config_env() == :dev do
  if database_url = System.get_env("PM_CORE_DATABASE_URL") do
    config :noizu_labs_pm, Noizu.PM.Repo,
      url: database_url,
      pool_size: String.to_integer(System.get_env("PM_CORE_POOL_SIZE") || "10")
  else
    if config_env() == :prod do
      raise """
      environment variable PM_CORE_DATABASE_URL is missing.
      For example: ecto://user:pass@host/pm_core
      """
    end

    # Dev fallback: local pm_core on the shared postgres host.
    config :noizu_labs_pm, Noizu.PM.Repo,
      username: System.get_env("PM_CORE_DB_USER", "tobor_locker"),
      password: System.get_env("PM_CORE_DB_PASS", "pm_core_dev"),
      hostname: System.get_env("PM_CORE_DB_HOST", "localhost"),
      database: System.get_env("PM_CORE_DB_NAME", "pm_core"),
      port: String.to_integer(System.get_env("PM_CORE_DB_PORT") || "5432"),
      stacktrace: true,
      show_sensitive_data_on_connection_error: true,
      pool_size: 10
  end
end

import Config

# Noizu.PM.Repo — the shared pm_core database.
#
# The runtime connection (url/pool) is bound in config/runtime.exs from
# PM_CORE_DATABASE_URL. Here we only declare the repo's static shape: UUID
# primary keys + the project's Postgrex type module (mirrors how npl-mcp wires
# its own repo in config/config.exs).
config :noizu_labs_pm, Noizu.PM.Repo,
  types: Noizu.PM.PostgrexTypes,
  migration_primary_key: [name: :id, type: :uuid]

config :noizu_labs_pm,
  ecto_repos: [Noizu.PM.Repo],
  generators: [timestamp_type: :utc_datetime]

# Library-safe env import: pm ships no dev/test/prod.exs by design (the host
# application supplies environment config). Guard the import so consumers don't
# hit `File.Error: could not read .../config/dev.exs` on first deps.get/compile.
if File.exists?(Path.join(__DIR__, "#{config_env()}.exs")) do
  import_config("#{config_env()}.exs")
end

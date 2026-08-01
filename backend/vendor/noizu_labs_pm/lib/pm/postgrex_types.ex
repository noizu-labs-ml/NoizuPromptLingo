# Postgrex type module for Noizu.PM.Repo.
#
# The PM schema set is intentionally free of pgvector / PostGIS columns (those
# live in the npl app's own type module), so this defines only the stock
# Ecto Postgres extensions + JSON (Jason). Declared via
# `config :noizu_labs_pm, Noizu.PM.Repo, types: Noizu.PM.PostgrexTypes`.
Postgrex.Types.define(
  Noizu.PM.PostgrexTypes,
  Ecto.Adapters.Postgres.extensions(),
  json: Jason
)

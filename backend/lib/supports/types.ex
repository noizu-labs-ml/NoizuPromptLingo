Postgrex.Types.define(
  Starter.PostgrexTypes,
  [
    Pgvector.Extensions.Vector,
    Geo.PostGIS.Extension
  ] ++ Ecto.Adapters.Postgres.extensions(),
  json: Jason
)

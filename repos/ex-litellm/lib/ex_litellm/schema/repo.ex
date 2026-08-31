defmodule ExLiteLLM.Schema.Repo do
  @moduledoc """
  The ex-litellm Ecto repository.

  Defaults to SQLite (`ecto_sqlite3`) — a single self-contained file, no
  container, no Prisma query-engine subprocess. The DB path is resolved at boot
  from `database_url` / `LITELLM_DATABASE_URL` (falling back to the compiled
  default under `~/.local/state/ex-litellm/`). Postgres support (selected by a
  `postgres://` URL) lands with the persistence phase; the schema and migration
  set are written to serve both backends.
  """
  use Ecto.Repo,
    otp_app: :ex_litellm,
    adapter: Ecto.Adapters.SQLite3
end

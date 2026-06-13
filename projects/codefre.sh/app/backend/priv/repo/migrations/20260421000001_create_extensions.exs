defmodule Codefresh.Repo.Migrations.CreateExtensions do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS pgcrypto")
    execute("CREATE EXTENSION IF NOT EXISTS citext")
    execute("CREATE EXTENSION IF NOT EXISTS vector")
    execute("CREATE EXTENSION IF NOT EXISTS timescaledb")
  end

  def down do
    # pgcrypto, citext, vector safe to drop individually; timescaledb requires
    # CASCADE and should be retained on the cluster in most cases.
    execute("DROP EXTENSION IF EXISTS vector")
    execute("DROP EXTENSION IF EXISTS citext")
    execute("DROP EXTENSION IF EXISTS pgcrypto")
  end
end

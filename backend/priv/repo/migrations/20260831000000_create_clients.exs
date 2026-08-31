defmodule NoizuPromptLingua.Repo.Migrations.CreateClients do
  @moduledoc """
  Local app-DB mirror of the former pm_core `clients` table (W4 cutover —
  TRP v1 exposes no clients endpoints; MCP client tools keep working locally).
  """
  use Ecto.Migration

  def change do
    create table(:clients, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :organization_id, :uuid, null: false
      add :name, :string, null: false
      add :slug, :string, null: false
      add :status, :string, default: "active"
      add :notes, :string, default: ""
      add :default_hourly_rate_cents, :integer
      add :currency, :string, default: "USD"
      add :external_ids, :map, default: %{}
      add :settings, :map, default: %{}
      add :created_by, :uuid
      add :archived_at, :utc_datetime_usec
      add :lock_version, :integer, default: 0

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:clients, [:organization_id, :slug])
    create index(:clients, [:organization_id, :status])
  end
end

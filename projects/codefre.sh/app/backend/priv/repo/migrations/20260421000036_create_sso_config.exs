defmodule Codefresh.Repo.Migrations.CreateSsoConfig do
  use Ecto.Migration

  def change do
    create table(:sso_config) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :provider, :string, null: false
      add :enabled, :boolean, null: false, default: false
      add :metadata, :map, null: false, default: %{}
      add :role_mapping, :map, null: false, default: %{}
      add :sso_required, :boolean, null: false, default: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:sso_config, [:organization_id])
  end
end

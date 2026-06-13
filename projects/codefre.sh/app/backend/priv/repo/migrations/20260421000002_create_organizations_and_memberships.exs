defmodule Codefresh.Repo.Migrations.CreateOrganizationsAndMemberships do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :slug, :citext, null: false
      add :name, :string, null: false
      add :settings, :map, null: false, default: %{}
      timestamps(type: :utc_datetime)
    end

    create unique_index(:organizations, [:slug])

    create table(:memberships) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :role, :string, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:memberships, [:organization_id, :user_id])
    create index(:memberships, [:user_id])
  end
end

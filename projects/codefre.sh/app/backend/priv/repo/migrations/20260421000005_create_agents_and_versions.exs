defmodule Codefresh.Repo.Migrations.CreateAgentsAndVersions do
  use Ecto.Migration

  def change do
    create table(:agents) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :slug, :citext, null: false
      add :name, :string, null: false
      add :description, :text
      add :current_version_id, :uuid
      add :archived_at, :utc_datetime
      add :created_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:agents, [:organization_id, :slug])

    create table(:agent_versions) do
      add :agent_id, references(:agents, type: :uuid, on_delete: :restrict), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :version_number, :integer, null: false
      add :adapter, :string, null: false
      add :endpoint_url, :text
      add :model, :string
      add :auth_ref, :map, null: false, default: %{}
      add :headers, :map, null: false, default: %{}
      add :request_template, :map, null: false, default: %{}
      add :response_jsonpath, :text
      add :checksum, :binary, null: false
      add :published_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:agent_versions, [:agent_id, :version_number])
    create unique_index(:agent_versions, [:agent_id, :checksum])

    alter table(:agents) do
      modify :current_version_id, references(:agent_versions, type: :uuid, on_delete: :nilify_all)
    end
  end
end

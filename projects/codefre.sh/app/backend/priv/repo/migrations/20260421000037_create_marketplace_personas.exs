defmodule Codefresh.Repo.Migrations.CreateMarketplacePersonas do
  use Ecto.Migration

  def change do
    create table(:marketplace_personas) do
      add :persona_version_id, references(:persona_versions, type: :uuid, on_delete: :delete_all), null: false
      add :author_organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :title, :string, null: false
      add :description, :text
      add :published_at, :utc_datetime, null: false
      add :download_count, :integer, null: false, default: 0
      add :average_rating, :decimal, precision: 3, scale: 2
      add :curation_status, :string, null: false, default: "pending"
      add :inserted_at, :utc_datetime, null: false
    end

    create index(:marketplace_personas, [:curation_status, :published_at])
    create index(:marketplace_personas, [:author_organization_id])
  end
end
